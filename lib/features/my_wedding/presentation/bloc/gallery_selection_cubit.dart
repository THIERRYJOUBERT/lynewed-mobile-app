/// Gallery Selection Cubit for managing multi-select gallery state.
///
/// Handles entering/exiting selection mode, selecting/deselecting media,
/// select all, deselect all, and filter changes.
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import 'gallery_selection_state.dart';

/// Cubit for managing gallery selection mode and filters.
///
/// Provides methods for entering/exiting selection mode, toggling selection,
/// selecting/deselecting all items, and changing the filter.
class GallerySelectionCubit extends Cubit<GallerySelectionState> {
  /// Creates a GallerySelectionCubit with initial state.
  GallerySelectionCubit() : super(const GallerySelectionState());

  /// Enters selection mode and selects the initial media item.
  ///
  /// This is typically triggered by a long press on a media item.
  /// Does nothing if already in selection mode.
  void enterSelectionMode(String mediaId) {
    if (state.isSelectionMode) return;

    emit(state.copyWith(
      isSelectionMode: true,
      selectedMediaIds: {mediaId},
    ));
  }

  /// Exits selection mode and clears all selections.
  ///
  /// Does nothing if not in selection mode.
  void exitSelectionMode() {
    if (!state.isSelectionMode) return;

    emit(state.copyWith(
      isSelectionMode: false,
      selectedMediaIds: const {},
    ));
  }

  /// Toggles the selection state of a media item.
  ///
  /// If the media is selected, it will be deselected.
  /// If the media is not selected, it will be selected.
  /// If deselecting the last item, exits selection mode.
  /// Does nothing if not in selection mode.
  void toggleSelection(String mediaId) {
    if (!state.isSelectionMode) return;

    final newSelection = Set<String>.from(state.selectedMediaIds);

    if (newSelection.contains(mediaId)) {
      newSelection.remove(mediaId);
    } else {
      newSelection.add(mediaId);
    }

    // Exit selection mode if no items are selected
    if (newSelection.isEmpty) {
      emit(state.copyWith(
        isSelectionMode: false,
        selectedMediaIds: const {},
      ));
    } else {
      emit(state.copyWith(selectedMediaIds: newSelection));
    }
  }

  /// Selects all provided media IDs.
  ///
  /// Replaces the current selection with all provided IDs.
  /// Does nothing if not in selection mode.
  void selectAll(List<String> allMediaIds) {
    if (!state.isSelectionMode) return;

    emit(state.copyWith(selectedMediaIds: allMediaIds.toSet()));
  }

  /// Deselects all media items and exits selection mode.
  ///
  /// Does nothing if not in selection mode.
  void deselectAll() {
    if (!state.isSelectionMode) return;

    emit(state.copyWith(
      isSelectionMode: false,
      selectedMediaIds: const {},
    ));
  }

  /// Sets the current gallery filter.
  ///
  /// Does nothing if the same filter is already set.
  void setFilter(GalleryFilter filter) {
    if (state.currentFilter == filter) return;

    emit(state.copyWith(currentFilter: filter));
  }
}
