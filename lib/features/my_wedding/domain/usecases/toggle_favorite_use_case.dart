/// Toggle Favorite Use Case - manages photo favorites.
///
/// Handles adding/removing photos from favorites for single and batch operations.
/// Works with the photo_favorites table.
library;

import '/core/utils/result.dart';

/// Data source interface for media actions.
///
/// Implemented by the data layer to perform actual database operations.
abstract class MediaActionsDataSource {
  /// Adds a media item to the user's favorites.
  ///
  /// [mediaId] - The ID of the media item.
  /// [mediaType] - Type of media: 'photo' or 'video'.
  Future<Result<void>> addToFavorites({
    required String mediaId,
    required String mediaType,
  });

  /// Removes a media item from the user's favorites.
  ///
  /// [mediaId] - The ID of the media item.
  Future<Result<void>> removeFromFavorites({
    required String mediaId,
  });

  /// Updates the status of a media item.
  ///
  /// [mediaId] - The ID of the media item.
  /// [status] - New status: 'active', 'hidden_by_bride', or 'deleted_by_bride'.
  Future<Result<void>> updateMediaStatus({
    required String mediaId,
    required String status,
  });
}

/// Use case for toggling favorite status on media items.
///
/// Provides methods for toggling single items and batch operations.
class ToggleFavoriteUseCase {
  /// Creates the use case with the required data source.
  const ToggleFavoriteUseCase(this._dataSource);

  final MediaActionsDataSource _dataSource;

  /// Toggles the favorite status of a single media item.
  ///
  /// If [currentlyFavorited] is false, adds to favorites.
  /// If [currentlyFavorited] is true, removes from favorites.
  Future<Result<void>> toggleSingle({
    required String mediaId,
    required String mediaType,
    required bool currentlyFavorited,
  }) {
    if (currentlyFavorited) {
      return _dataSource.removeFromFavorites(mediaId: mediaId);
    } else {
      return _dataSource.addToFavorites(
        mediaId: mediaId,
        mediaType: mediaType,
      );
    }
  }

  /// Adds multiple media items to favorites.
  ///
  /// Returns the count of successfully added items.
  /// Continues processing even if some items fail.
  Future<Result<int>> addMultiple({
    required List<String> mediaIds,
    required String mediaType,
  }) async {
    if (mediaIds.isEmpty) {
      return const Success(0);
    }

    var successCount = 0;

    for (final mediaId in mediaIds) {
      final result = await _dataSource.addToFavorites(
        mediaId: mediaId,
        mediaType: mediaType,
      );
      if (result.isSuccess) {
        successCount++;
      }
    }

    return Success(successCount);
  }

  /// Removes multiple media items from favorites.
  ///
  /// Returns the count of successfully removed items.
  /// Continues processing even if some items fail.
  Future<Result<int>> removeMultiple({
    required List<String> mediaIds,
  }) async {
    if (mediaIds.isEmpty) {
      return const Success(0);
    }

    var successCount = 0;

    for (final mediaId in mediaIds) {
      final result = await _dataSource.removeFromFavorites(mediaId: mediaId);
      if (result.isSuccess) {
        successCount++;
      }
    }

    return Success(successCount);
  }
}
