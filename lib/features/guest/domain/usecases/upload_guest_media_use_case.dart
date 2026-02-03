/// Upload Guest Media Use Case.
///
/// Validates and uploads media files for guests.
library;

import 'dart:io';

import 'package:lynewed_beta/core/error/failures.dart';
import 'package:lynewed_beta/core/utils/result.dart';
import '../repositories/guest_album_repository.dart';

/// Use case to upload a media file to the guest's album.
///
/// Handles:
/// - Validating file constraints (size, duration, caption)
/// - Delegating upload to repository (which auto-creates album)
class UploadGuestMediaUseCase {
  /// Creates the use case with a repository.
  const UploadGuestMediaUseCase(this.repository);

  /// The repository for album operations.
  final GuestAlbumRepository repository;

  /// Maximum photo file size in bytes (20 MB).
  static const int maxPhotoSizeBytes = 20 * 1024 * 1024;

  /// Maximum video file size in bytes (500 MB).
  static const int maxVideoSizeBytes = 500 * 1024 * 1024;

  /// Maximum video duration in seconds (10 minutes).
  static const int maxVideoDurationSeconds = 600;

  /// Maximum caption length.
  static const int maxCaptionLength = 500;

  /// Uploads a media file to the guest's album.
  ///
  /// Parameters:
  /// - [file]: The local file to upload
  /// - [weddingId]: The wedding this media belongs to
  /// - [mediaType]: 'photo' or 'video'
  /// - [caption]: Optional caption (max 500 chars)
  /// - [durationSeconds]: Video duration for validation
  /// - [onProgress]: Upload progress callback (0.0 to 1.0)
  ///
  /// Returns the created media ID on success.
  Future<Result<String>> call({
    required File file,
    required String weddingId,
    required String mediaType,
    String? caption,
    int? durationSeconds,
    void Function(double)? onProgress,
  }) async {
    // Validate constraints
    final validationError = _validateConstraints(
      file: file,
      mediaType: mediaType,
      caption: caption,
      durationSeconds: durationSeconds,
    );

    if (validationError != null) {
      return Failure(ValidationFailure(validationError));
    }

    // Delegate to repository for upload
    return repository.uploadMedia(
      file: file,
      weddingId: weddingId,
      mediaType: mediaType,
      caption: caption,
      durationSeconds: durationSeconds,
      onProgress: onProgress,
    );
  }

  /// Validates upload constraints.
  ///
  /// Returns an error message if validation fails, null if valid.
  String? _validateConstraints({
    required File file,
    required String mediaType,
    String? caption,
    int? durationSeconds,
  }) {
    final fileSizeBytes = file.lengthSync();

    // Caption validation
    if (caption != null && caption.length > maxCaptionLength) {
      return 'Caption must be under 500 characters';
    }

    // Video constraints
    if (mediaType == 'video') {
      // Duration check
      if (durationSeconds != null && durationSeconds > maxVideoDurationSeconds) {
        return 'Video must be under 10 minutes';
      }
      // Size check
      if (fileSizeBytes > maxVideoSizeBytes) {
        return 'Video must be under 500 MB';
      }
    }

    // Photo constraints
    if (mediaType == 'photo') {
      if (fileSizeBytes > maxPhotoSizeBytes) {
        return 'Photo must be under 20 MB';
      }
    }

    return null;
  }
}
