/// Share Photos With Guests Use Case
///
/// Handles sharing selected photos/videos with wedding guests.
/// Creates share records in the photo_shares table.
library;

import '../repositories/my_wedding_repository.dart';

/// Use case for sharing photos/videos with wedding guests.
///
/// Allows the bride to share selected media items with all wedding guests.
/// The shared media will be visible to guests on their home page.
class SharePhotosWithGuestsUseCase {
  /// Creates the use case with the required repository.
  const SharePhotosWithGuestsUseCase(this._repository);

  final MyWeddingRepository _repository;

  /// Shares the provided media items with wedding guests.
  ///
  /// [weddingId] - The wedding to share photos for.
  /// [mediaItems] - List of media items to share.
  ///
  /// Returns the number of items successfully shared.
  /// Duplicate shares are silently ignored.
  Future<RepositoryResult<int>> execute({
    required String weddingId,
    required List<ShareMediaItem> mediaItems,
  }) {
    return _repository.sharePhotosWithGuests(
      weddingId: weddingId,
      mediaItems: mediaItems,
    );
  }
}
