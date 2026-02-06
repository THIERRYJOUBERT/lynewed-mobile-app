/// Guest Album Repository Interface.
///
/// Defines the contract for guest album operations.
library;

import 'dart:io';

import 'package:lynewed_beta/core/utils/result.dart';
import '../entities/guest_media.dart';

/// Repository interface for guest album operations.
///
/// Handles:
/// - Auto-creating guest album on first upload
/// - Uploading photos and videos
/// - Retrieving guest's media
/// - Deleting media
abstract class GuestAlbumRepository {
  /// Gets all media uploaded by the current guest for a wedding.
  ///
  /// Returns an empty list if no album exists yet.
  Future<Result<List<GuestMedia>>> getMyMedia({
    required String weddingId,
  });

  /// Uploads a media file to the guest's album.
  ///
  /// Auto-creates the album if this is the first upload.
  ///
  /// Parameters:
  /// - [file]: The local file to upload
  /// - [weddingId]: The wedding this media belongs to
  /// - [mediaType]: 'photo' or 'video'
  /// - [caption]: Optional caption (max 500 chars)
  /// - [durationSeconds]: Video duration for validation
  /// - [thumbnailPath]: Local path to thumbnail image (for videos)
  /// - [onProgress]: Upload progress callback (0.0 to 1.0)
  ///
  /// Returns the created media ID on success.
  Future<Result<String>> uploadMedia({
    required File file,
    required String weddingId,
    required String mediaType,
    String? caption,
    int? durationSeconds,
    String? thumbnailPath,
    void Function(double)? onProgress,
  });

  /// Deletes a media file from the guest's album.
  ///
  /// Also removes the file from storage.
  Future<Result<void>> deleteMedia({
    required String mediaId,
  });

  /// Gets the album ID for the current guest's wedding album.
  ///
  /// Returns null if no album exists.
  Future<Result<String?>> getMyAlbumId({
    required String weddingId,
  });

  /// Gets the set of media IDs that have been favorited by the bride.
  ///
  /// Queries the photo_favorites table for media belonging to
  /// the current guest's album.
  /// Returns an empty set if no favorites exist.
  Future<Result<Set<String>>> getFavoritedMediaIds({
    required String weddingId,
  });
}
