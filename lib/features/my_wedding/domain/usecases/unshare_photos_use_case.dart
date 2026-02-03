/// Unshare Photos Use Case
///
/// Handles removing share records for photos/videos from wedding guests.
library;

import '../repositories/my_wedding_repository.dart';

/// Use case for removing photo/video shares from wedding guests.
///
/// Allows the bride to unshare previously shared media items.
/// The unshared media will no longer be visible to guests.
class UnsharePhotosUseCase {
  /// Creates the use case with the required repository.
  const UnsharePhotosUseCase(this._repository);

  final MyWeddingRepository _repository;

  /// Removes share records for the provided media items.
  ///
  /// [weddingId] - The wedding to unshare photos for.
  /// [mediaItems] - List of media items to unshare.
  ///
  /// Returns the number of items successfully unshared.
  Future<RepositoryResult<int>> execute({
    required String weddingId,
    required List<ShareMediaItem> mediaItems,
  }) {
    return _repository.unsharePhotos(
      weddingId: weddingId,
      mediaItems: mediaItems,
    );
  }
}
