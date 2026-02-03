/// Reorder Magazine Use Case.
///
/// Handles reordering photos in the magazine selection via drag & drop.
library;

import '../repositories/my_wedding_repository.dart';

/// Use case for reordering photos in a magazine.
class ReorderMagazineUseCase {
  /// Creates the use case with required repository.
  const ReorderMagazineUseCase(this._repository);

  final MyWeddingRepository _repository;

  /// Reorders a photo in the magazine selection.
  ///
  /// Moves the photo at [oldIndex] to [newIndex] and shifts other photos.
  ///
  /// Returns [ReorderMagazineResult.success] if successful,
  /// or [ReorderMagazineResult.failure] with an error message.
  ///
  /// Parameters:
  /// - [weddingId]: The wedding ID.
  /// - [oldIndex]: The current 0-based index of the photo.
  /// - [newIndex]: The target 0-based index for the photo.
  Future<ReorderMagazineResult> call({
    required String weddingId,
    required int oldIndex,
    required int newIndex,
  }) async {
    // Validate input
    if (oldIndex < 0 || newIndex < 0) {
      return const ReorderMagazineResult.failure('Invalid position');
    }

    if (oldIndex == newIndex) {
      // No change needed
      return const ReorderMagazineResult.success();
    }

    // Reorder in repository
    final result = await _repository.reorderMagazine(
      weddingId: weddingId,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );

    if (result.isSuccess) {
      return const ReorderMagazineResult.success();
    } else {
      return ReorderMagazineResult.failure(
        result.error ?? 'Failed to reorder photos',
      );
    }
  }
}

/// Result of reordering photos in magazine.
class ReorderMagazineResult {
  const ReorderMagazineResult.success() : error = null;
  const ReorderMagazineResult.failure(this.error);

  /// Error message if failed.
  final String? error;

  /// Returns true if the operation was successful.
  bool get isSuccess => error == null;

  /// Returns true if the operation failed.
  bool get isFailure => error != null;
}
