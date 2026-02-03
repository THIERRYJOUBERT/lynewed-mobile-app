/// Magazine Selection Cubit for managing magazine photo selection.
///
/// Handles loading, adding, removing, reordering, and clearing photos.
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import 'magazine_selection_state.dart';

/// Cubit for managing magazine selection state.
class MagazineSelectionCubit extends Cubit<MagazineSelectionState> {
  /// Creates a MagazineSelectionCubit.
  MagazineSelectionCubit({
    required this.weddingId,
    required this.userId,
    MyWeddingRepository? repository,
    required this.getThumbnailUrl,
  })  : _repository = repository ?? MyWeddingRepositoryImpl(),
        super(const MagazineSelectionState());

  /// The wedding ID for this magazine.
  final String weddingId;

  /// The current user ID.
  final String userId;

  /// Repository for data operations.
  final MyWeddingRepository _repository;

  /// Function to get thumbnail URL for a media item.
  /// Takes (mediaType, mediaId) and returns the thumbnail URL.
  final Future<String?> Function(String mediaType, String mediaId)
      getThumbnailUrl;

  /// Loads magazine selections from the database.
  Future<void> loadSelections() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.getMagazineSelections(weddingId: weddingId);

    if (result.isSuccess) {
      final selections = result.data ?? [];
      final photos = <MagazinePhoto>[];

      for (final selection in selections) {
        final thumbnailUrl =
            await getThumbnailUrl(selection.mediaType, selection.mediaId);
        if (thumbnailUrl != null) {
          photos.add(MagazinePhoto.fromSelection(selection, thumbnailUrl));
        }
      }

      emit(state.copyWith(
        photos: photos,
        isLoading: false,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      ));
    }
  }

  /// Adds photos to the magazine from media items.
  ///
  /// Returns true if all photos were added successfully.
  Future<bool> addPhotos(List<MagazineMediaItem> mediaItems) async {
    if (mediaItems.isEmpty) return true;

    // Check if adding would exceed limit
    final newCount = state.count + mediaItems.length;
    if (newCount > state.maxPhotos) {
      emit(state.copyWith(
        errorMessage: 'Maximum ${state.maxPhotos} photos per magazine',
      ));
      return false;
    }

    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    final result = await _repository.addToMagazine(
      weddingId: weddingId,
      userId: userId,
      mediaItems: mediaItems,
      maxPhotos: state.maxPhotos,
    );

    if (result.isSuccess) {
      // Reload to get the new photos with positions
      await loadSelections();
      final added = result.data ?? 0;
      final requested = mediaItems.length;
      final duplicates = requested - added;

      String message;
      if (added == 0 && duplicates > 0) {
        message = duplicates == 1
            ? 'Photo already in magazine'
            : 'All $duplicates photos already in magazine';
      } else if (duplicates > 0) {
        message = '$added photo${added != 1 ? 's' : ''} added'
            ' ($duplicates already in magazine)';
      } else {
        message = '$added photo${added != 1 ? 's' : ''} added to magazine';
      }

      emit(state.copyWith(successMessage: message));
      return true;
    } else {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: result.error,
      ));
      return false;
    }
  }

  /// Removes a photo from the magazine.
  Future<void> removePhoto(String selectionId) async {
    // Optimistic update: remove from UI immediately
    final originalPhotos = List<MagazinePhoto>.from(state.photos);
    final updatedPhotos =
        state.photos.where((p) => p.selectionId != selectionId).toList();

    // Recompact positions in memory
    for (var i = 0; i < updatedPhotos.length; i++) {
      updatedPhotos[i] = updatedPhotos[i].copyWithPosition(i + 1);
    }

    emit(state.copyWith(
      photos: updatedPhotos,
      clearError: true,
      clearSuccess: true,
    ));

    final result = await _repository.removeFromMagazine(
      selectionId: selectionId,
      weddingId: weddingId,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        successMessage: 'Photo removed from magazine',
      ));
    } else {
      // Revert on failure
      emit(state.copyWith(
        photos: originalPhotos,
        errorMessage: result.error,
      ));
    }
  }

  /// Reorders photos via drag and drop.
  ///
  /// Moves the photo at [oldIndex] to [newIndex].
  Future<void> reorderPhoto(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    if (oldIndex < 0 || newIndex < 0) return;
    if (oldIndex >= state.photos.length || newIndex >= state.photos.length) {
      return;
    }

    // Optimistic update: reorder in UI immediately
    final originalPhotos = List<MagazinePhoto>.from(state.photos);
    final reorderedPhotos = List<MagazinePhoto>.from(state.photos);

    final movedPhoto = reorderedPhotos.removeAt(oldIndex);
    reorderedPhotos.insert(newIndex, movedPhoto);

    // Update positions in memory
    for (var i = 0; i < reorderedPhotos.length; i++) {
      reorderedPhotos[i] = reorderedPhotos[i].copyWithPosition(i + 1);
    }

    emit(state.copyWith(
      photos: reorderedPhotos,
      isReordering: true,
      clearError: true,
    ));

    final result = await _repository.reorderMagazine(
      weddingId: weddingId,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );

    if (result.isSuccess) {
      emit(state.copyWith(isReordering: false));
    } else {
      // Revert on failure
      emit(state.copyWith(
        photos: originalPhotos,
        isReordering: false,
        errorMessage: result.error,
      ));
    }
  }

  /// Clears all photos from the magazine.
  Future<void> clearAll() async {
    if (state.isEmpty) return;

    final originalPhotos = List<MagazinePhoto>.from(state.photos);

    emit(state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    ));

    final result =
        await _repository.clearMagazineSelections(weddingId: weddingId);

    if (result.isSuccess) {
      emit(state.copyWith(
        photos: const [],
        isLoading: false,
        successMessage: 'All photos removed from magazine',
      ));
    } else {
      emit(state.copyWith(
        photos: originalPhotos,
        isLoading: false,
        errorMessage: result.error,
      ));
    }
  }

  /// Clears error message.
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Clears success message.
  void clearSuccess() {
    emit(state.copyWith(clearSuccess: true));
  }

  /// Sets the maximum photos allowed.
  void setMaxPhotos(int maxPhotos) {
    emit(state.copyWith(maxPhotos: maxPhotos));
  }
}
