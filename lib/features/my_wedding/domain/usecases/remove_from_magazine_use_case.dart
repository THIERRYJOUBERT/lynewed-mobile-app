/// Remove from Magazine Use Case.
///
/// Handles removing a photo from the magazine selection.
library;

import '../repositories/my_wedding_repository.dart';

/// Use case for removing a photo from a magazine.
class RemoveFromMagazineUseCase {
  /// Creates the use case with required repository.
  const RemoveFromMagazineUseCase(this._repository);

  final MyWeddingRepository _repository;

  /// Removes a photo from the magazine selection.
  ///
  /// Returns [RemoveFromMagazineResult.success] if successful,
  /// or [RemoveFromMagazineResult.failure] with an error message.
  ///
  /// Parameters:
  /// - [selectionId]: The ID of the magazine_selections row to remove.
  /// - [weddingId]: The wedding ID (for recompacting positions).
  Future<RemoveFromMagazineResult> call({
    required String selectionId,
    required String weddingId,
  }) async {
    // Validate input
    if (selectionId.isEmpty) {
      return const RemoveFromMagazineResult.failure('Invalid selection ID');
    }

    // Remove from repository
    final result = await _repository.removeFromMagazine(
      selectionId: selectionId,
      weddingId: weddingId,
    );

    if (result.isSuccess) {
      return const RemoveFromMagazineResult.success();
    } else {
      return RemoveFromMagazineResult.failure(
        result.error ?? 'Failed to remove photo',
      );
    }
  }
}

/// Result of removing a photo from magazine.
class RemoveFromMagazineResult {
  const RemoveFromMagazineResult.success() : error = null;
  const RemoveFromMagazineResult.failure(this.error);

  /// Error message if failed.
  final String? error;

  /// Returns true if the operation was successful.
  bool get isSuccess => error == null;

  /// Returns true if the operation failed.
  bool get isFailure => error != null;
}
