/// Delete Media Use Case - manages soft-deleting photos from gallery.
///
/// Handles soft-deleting photos for single and batch operations.
/// Updates the guest_media status column to 'deleted_by_bride'.
/// The guest can still see their photos in their own album.
library;

import '/core/utils/result.dart';
import 'toggle_favorite_use_case.dart';

/// Use case for soft-deleting media items.
///
/// Provides methods for deleting single items and batch operations.
/// Soft-deleted photos can potentially be restored.
class DeleteMediaUseCase {
  /// Creates the use case with the required data source.
  const DeleteMediaUseCase(this._dataSource);

  final MediaActionsDataSource _dataSource;

  /// Soft-deletes a single media item.
  ///
  /// Sets the status to 'deleted_by_bride'.
  Future<Result<void>> deleteSingle({required String mediaId}) {
    return _dataSource.updateMediaStatus(
      mediaId: mediaId,
      status: 'deleted_by_bride',
    );
  }

  /// Soft-deletes multiple media items.
  ///
  /// Returns the count of successfully deleted items.
  /// Continues processing even if some items fail.
  Future<Result<int>> deleteMultiple({required List<String> mediaIds}) async {
    if (mediaIds.isEmpty) {
      return const Success(0);
    }

    var successCount = 0;

    for (final mediaId in mediaIds) {
      final result = await _dataSource.updateMediaStatus(
        mediaId: mediaId,
        status: 'deleted_by_bride',
      );
      if (result.isSuccess) {
        successCount++;
      }
    }

    return Success(successCount);
  }

  /// Restores a single soft-deleted media item.
  ///
  /// Sets the status back to 'active'.
  Future<Result<void>> restoreSingle({required String mediaId}) {
    return _dataSource.updateMediaStatus(
      mediaId: mediaId,
      status: 'active',
    );
  }
}
