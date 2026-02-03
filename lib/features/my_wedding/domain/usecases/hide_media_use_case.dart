/// Hide Media Use Case - manages hiding photos from gallery.
///
/// Handles hiding/unhiding photos for single and batch operations.
/// Updates the guest_media status column.
library;

import '/core/utils/result.dart';
import 'toggle_favorite_use_case.dart';

/// Use case for hiding/unhiding media items.
///
/// Provides methods for hiding single items and batch operations.
/// Hidden photos are still accessible via the Hidden filter tab.
class HideMediaUseCase {
  /// Creates the use case with the required data source.
  const HideMediaUseCase(this._dataSource);

  final MediaActionsDataSource _dataSource;

  /// Hides a single media item.
  ///
  /// Sets the status to 'hidden_by_bride'.
  Future<Result<void>> hideSingle({required String mediaId}) {
    return _dataSource.updateMediaStatus(
      mediaId: mediaId,
      status: 'hidden_by_bride',
    );
  }

  /// Unhides a single media item.
  ///
  /// Sets the status back to 'active'.
  Future<Result<void>> unhideSingle({required String mediaId}) {
    return _dataSource.updateMediaStatus(
      mediaId: mediaId,
      status: 'active',
    );
  }

  /// Hides multiple media items.
  ///
  /// Returns the count of successfully hidden items.
  /// Continues processing even if some items fail.
  Future<Result<int>> hideMultiple({required List<String> mediaIds}) async {
    if (mediaIds.isEmpty) {
      return const Success(0);
    }

    var successCount = 0;

    for (final mediaId in mediaIds) {
      final result = await _dataSource.updateMediaStatus(
        mediaId: mediaId,
        status: 'hidden_by_bride',
      );
      if (result.isSuccess) {
        successCount++;
      }
    }

    return Success(successCount);
  }

  /// Unhides multiple media items.
  ///
  /// Returns the count of successfully unhidden items.
  /// Continues processing even if some items fail.
  Future<Result<int>> unhideMultiple({required List<String> mediaIds}) async {
    if (mediaIds.isEmpty) {
      return const Success(0);
    }

    var successCount = 0;

    for (final mediaId in mediaIds) {
      final result = await _dataSource.updateMediaStatus(
        mediaId: mediaId,
        status: 'active',
      );
      if (result.isSuccess) {
        successCount++;
      }
    }

    return Success(successCount);
  }
}
