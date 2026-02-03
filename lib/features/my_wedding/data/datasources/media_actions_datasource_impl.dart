/// Media Actions DataSource Implementation
///
/// Handles Supabase operations for photo favorites and media status updates.
/// Works with photo_favorites and guest_media tables.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/error/failures.dart';
import '/core/utils/result.dart';
import '/utils/secure_logger.dart';
import '../../domain/usecases/toggle_favorite_use_case.dart';

/// Implementation of MediaActionsDataSource using Supabase.
///
/// Handles adding/removing favorites and updating media status.
class MediaActionsDataSourceImpl implements MediaActionsDataSource {
  /// Creates the datasource with optional Supabase client.
  MediaActionsDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Get current user ID.
  String? get _currentUserId => _client.auth.currentUser?.id;

  @override
  Future<Result<void>> addToFavorites({
    required String mediaId,
    required String mediaType,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      SecureLogger.warning('addToFavorites: No authenticated user');
      return Failure(const AuthFailure('Not authenticated'));
    }

    try {
      // Check if already favorited to avoid duplicate key error
      final existing = await _client
          .from('photo_favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('media_id', mediaId)
          .maybeSingle();

      if (existing != null) {
        // Already favorited, consider it a success
        SecureLogger.info('addToFavorites: Media $mediaId already favorited');
        return const Success(null);
      }

      await _client.from('photo_favorites').insert({
        'user_id': userId,
        'media_type': mediaType,
        'media_id': mediaId,
      });

      SecureLogger.info('addToFavorites: Added $mediaId to favorites');
      return const Success(null);
    } catch (e) {
      SecureLogger.error('addToFavorites error: $e');
      return Failure(ServerFailure('Failed to add to favorites: $e'));
    }
  }

  @override
  Future<Result<void>> removeFromFavorites({
    required String mediaId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      SecureLogger.warning('removeFromFavorites: No authenticated user');
      return Failure(const AuthFailure('Not authenticated'));
    }

    try {
      await _client
          .from('photo_favorites')
          .delete()
          .eq('user_id', userId)
          .eq('media_id', mediaId);

      SecureLogger.info('removeFromFavorites: Removed $mediaId from favorites');
      return const Success(null);
    } catch (e) {
      SecureLogger.error('removeFromFavorites error: $e');
      return Failure(ServerFailure('Failed to remove from favorites: $e'));
    }
  }

  @override
  Future<Result<void>> updateMediaStatus({
    required String mediaId,
    required String status,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      SecureLogger.warning('updateMediaStatus: No authenticated user');
      return Failure(const AuthFailure('Not authenticated'));
    }

    try {
      // Validate status
      final validStatuses = ['active', 'hidden_by_bride', 'deleted_by_bride'];
      if (!validStatuses.contains(status)) {
        return Failure(ValidationFailure('Invalid status: $status'));
      }

      await _client
          .from('guest_media')
          .update({'status': status})
          .eq('id', mediaId);

      SecureLogger.info('updateMediaStatus: Set $mediaId status to $status');
      return const Success(null);
    } catch (e) {
      SecureLogger.error('updateMediaStatus error: $e');
      return Failure(ServerFailure('Failed to update media status: $e'));
    }
  }

  /// Checks if a media item is favorited by the current user.
  ///
  /// Returns true if favorited, false otherwise.
  Future<Result<bool>> isFavorited({required String mediaId}) async {
    final userId = _currentUserId;
    if (userId == null) {
      SecureLogger.warning('isFavorited: No authenticated user');
      return Failure(const AuthFailure('Not authenticated'));
    }

    try {
      final result = await _client
          .from('photo_favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('media_id', mediaId)
          .maybeSingle();

      return Success(result != null);
    } catch (e) {
      SecureLogger.error('isFavorited error: $e');
      return Failure(ServerFailure('Failed to check favorite status: $e'));
    }
  }

  /// Gets all favorited media IDs for the current user.
  ///
  /// Returns a set of media IDs that are favorited.
  Future<Result<Set<String>>> getFavoritedMediaIds() async {
    final userId = _currentUserId;
    if (userId == null) {
      SecureLogger.warning('getFavoritedMediaIds: No authenticated user');
      return Failure(const AuthFailure('Not authenticated'));
    }

    try {
      final results = await _client
          .from('photo_favorites')
          .select('media_id')
          .eq('user_id', userId);

      final ids = results.map((r) => r['media_id'] as String).toSet();
      return Success(ids);
    } catch (e) {
      SecureLogger.error('getFavoritedMediaIds error: $e');
      return Failure(ServerFailure('Failed to get favorites: $e'));
    }
  }
}
