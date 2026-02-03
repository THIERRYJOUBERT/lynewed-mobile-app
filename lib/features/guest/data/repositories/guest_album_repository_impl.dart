/// Guest Album Repository Implementation.
///
/// Implements GuestAlbumRepository using Supabase.
library;

import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/error/failures.dart';
import '/core/utils/result.dart';
import '/utils/secure_logger.dart';
import '../../domain/entities/guest_media.dart';
import '../../domain/repositories/guest_album_repository.dart';
import '../models/guest_media_model.dart';

/// Implementation of GuestAlbumRepository using Supabase.
///
/// Handles:
/// - Auto-creating guest album on first upload
/// - Uploading to storage with progress tracking
/// - Managing guest media records
class GuestAlbumRepositoryImpl implements GuestAlbumRepository {
  /// Creates the repository with optional Supabase client.
  GuestAlbumRepositoryImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Storage bucket name for wedding albums.
  static const String _storageBucket = 'wedding-albums';

  @override
  Future<Result<List<GuestMedia>>> getMyMedia({
    required String weddingId,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Failure(AuthFailure('Not authenticated'));
      }

      // Get album for this wedding and user
      final albumResult = await _getMyAlbumIdInternal(weddingId, userId);
      if (albumResult == null) {
        // No album yet = no media
        return const Success([]);
      }

      // Fetch media from guest_media table
      final response = await _client
          .from('guest_media')
          .select()
          .eq('album_id', albumResult)
          .order('created_at', ascending: false);

      final media =
          (response as List).map((e) => GuestMediaModel.fromJson(e)).toList();

      return Success(media);
    } catch (e) {
      SecureLogger.error('Failed to get guest media: $e');
      return Failure(ServerFailure('Failed to load media: $e'));
    }
  }

  @override
  Future<Result<String>> uploadMedia({
    required File file,
    required String weddingId,
    required String mediaType,
    String? caption,
    int? durationSeconds,
    void Function(double)? onProgress,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Failure(AuthFailure('Not authenticated'));
      }

      // Get or create album
      final albumId = await _getOrCreateAlbum(weddingId, userId);

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _getExtension(file.path);
      final filename = '${mediaType}_$timestamp.$extension';
      final storagePath = '$weddingId/guests/$userId/$filename';

      // Upload to storage
      // Note: Supabase Flutter SDK doesn't support progress tracking for upload
      // So we simulate progress callback at key points
      onProgress?.call(0.0);

      await _client.storage.from(_storageBucket).upload(
            storagePath,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      onProgress?.call(0.7);

      // Get file size
      final fileSizeBytes = await file.length();

      // Create database record
      final response = await _client.from('guest_media').insert({
        'album_id': albumId,
        'media_type': mediaType,
        'storage_path': storagePath,
        'caption': caption,
        'duration_seconds': durationSeconds,
        'file_size_bytes': fileSizeBytes,
      }).select('id').single();

      onProgress?.call(1.0);

      return Success(response['id'] as String);
    } catch (e) {
      SecureLogger.error('Failed to upload guest media: $e');
      return Failure(ServerFailure('Failed to upload media: $e'));
    }
  }

  @override
  Future<Result<void>> deleteMedia({
    required String mediaId,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Failure(AuthFailure('Not authenticated'));
      }

      // Get media to find storage path
      final mediaResponse = await _client
          .from('guest_media')
          .select('storage_path, album_id')
          .eq('id', mediaId)
          .maybeSingle();

      if (mediaResponse == null) {
        return const Failure(ValidationFailure('Media not found'));
      }

      final storagePath = mediaResponse['storage_path'] as String;
      final albumId = mediaResponse['album_id'] as String;

      // Verify ownership - check that this album belongs to the user
      final albumResponse = await _client
          .from('guest_albums')
          .select('guest_user_id')
          .eq('id', albumId)
          .maybeSingle();

      if (albumResponse == null ||
          albumResponse['guest_user_id'] != userId) {
        return const Failure(AuthFailure('Not authorized to delete this media'));
      }

      // Delete database record FIRST (more important for data consistency)
      // If this fails, we haven't touched storage yet - clean rollback
      await _client.from('guest_media').delete().eq('id', mediaId);

      // Delete from storage (best effort)
      // If DB delete succeeded but storage fails, we have an orphan file
      // which is acceptable - a cleanup job can handle it later
      // This is better than the reverse (DB record pointing to missing file)
      try {
        await _client.storage.from(_storageBucket).remove([storagePath]);
      } catch (storageError) {
        // Log but don't fail - orphan file is acceptable
        SecureLogger.warning(
          'Storage cleanup failed for $storagePath: $storageError',
        );
      }

      return const Success(null);
    } catch (e) {
      SecureLogger.error('Failed to delete guest media: $e');
      return Failure(ServerFailure('Failed to delete media: $e'));
    }
  }

  @override
  Future<Result<String?>> getMyAlbumId({
    required String weddingId,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Failure(AuthFailure('Not authenticated'));
      }

      final albumId = await _getMyAlbumIdInternal(weddingId, userId);
      return Success(albumId);
    } catch (e) {
      SecureLogger.error('Failed to get album ID: $e');
      return Failure(ServerFailure('Failed to get album: $e'));
    }
  }

  /// Gets the album ID for a user's wedding, or null if none exists.
  Future<String?> _getMyAlbumIdInternal(String weddingId, String userId) async {
    final response = await _client
        .from('guest_albums')
        .select('id')
        .eq('wedding_id', weddingId)
        .eq('guest_user_id', userId)
        .maybeSingle();

    return response?['id'] as String?;
  }

  /// Gets or creates an album for the user's wedding.
  ///
  /// This implements the auto-create album logic on first upload.
  /// Handles race conditions by catching unique constraint violations
  /// and retrying the lookup.
  Future<String> _getOrCreateAlbum(String weddingId, String userId) async {
    // Check if album exists
    final existing = await _getMyAlbumIdInternal(weddingId, userId);
    if (existing != null) {
      return existing;
    }

    try {
      // Create new album
      final result = await _client.from('guest_albums').insert({
        'wedding_id': weddingId,
        'guest_user_id': userId,
      }).select('id').single();

      SecureLogger.debug('Created guest album for wedding $weddingId');
      return result['id'] as String;
    } catch (e) {
      // Handle potential race condition - album may have been created
      // by another concurrent request. Try to fetch it again.
      final retryExisting = await _getMyAlbumIdInternal(weddingId, userId);
      if (retryExisting != null) {
        SecureLogger.debug('Album already existed after race condition');
        return retryExisting;
      }
      // Re-throw if it's a different error
      rethrow;
    }
  }

  /// Extracts file extension from a path.
  String _getExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1 || lastDot == path.length - 1) {
      return 'bin';
    }
    return path.substring(lastDot + 1).toLowerCase();
  }
}
