/// Add to Magazine Use Case.
///
/// Handles adding photos to the magazine selection with validation.
library;

import '../entities/magazine_selection.dart';
import '../repositories/my_wedding_repository.dart';

/// Use case for adding photos to a magazine.
///
/// Validates the maximum photo limit before adding.
class AddToMagazineUseCase {
  /// Creates the use case with required repository.
  const AddToMagazineUseCase(this._repository);

  final MyWeddingRepository _repository;

  /// Adds photos to the magazine selection.
  ///
  /// Returns [AddToMagazineResult.success] with the count of added photos,
  /// or [AddToMagazineResult.failure] with an error message.
  ///
  /// Parameters:
  /// - [weddingId]: The wedding to add photos to.
  /// - [userId]: The user adding the photos.
  /// - [mediaItems]: List of media items to add.
  /// - [currentCount]: Current number of photos in the magazine.
  /// - [maxPhotos]: Maximum photos allowed (default 60 for COLLECTOR).
  Future<AddToMagazineResult> call({
    required String weddingId,
    required String userId,
    required List<MagazineMediaItem> mediaItems,
    required int currentCount,
    int maxPhotos = MagazineSelection.maxPhotosCollector,
  }) async {
    // Validate input
    if (mediaItems.isEmpty) {
      return const AddToMagazineResult.failure('No photos selected');
    }

    // Check if adding would exceed limit
    final newTotal = currentCount + mediaItems.length;
    if (newTotal > maxPhotos) {
      final available = maxPhotos - currentCount;
      if (available <= 0) {
        return AddToMagazineResult.failure(
          'Maximum $maxPhotos photos per magazine',
        );
      }
      return AddToMagazineResult.failure(
        'Can only add $available more photos (limit: $maxPhotos)',
      );
    }

    // Add to repository
    final result = await _repository.addToMagazine(
      weddingId: weddingId,
      userId: userId,
      mediaItems: mediaItems,
      maxPhotos: maxPhotos,
    );

    if (result.isSuccess) {
      return AddToMagazineResult.success(result.data!);
    } else {
      return AddToMagazineResult.failure(result.error ?? 'Failed to add photos');
    }
  }
}

/// Result of adding photos to magazine.
class AddToMagazineResult {
  const AddToMagazineResult.success(this.addedCount) : error = null;
  const AddToMagazineResult.failure(this.error) : addedCount = 0;

  /// Number of photos successfully added.
  final int addedCount;

  /// Error message if failed.
  final String? error;

  /// Returns true if the operation was successful.
  bool get isSuccess => error == null;

  /// Returns true if the operation failed.
  bool get isFailure => error != null;
}
