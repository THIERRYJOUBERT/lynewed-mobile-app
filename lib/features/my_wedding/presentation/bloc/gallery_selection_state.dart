/// Gallery Selection State for GallerySelectionCubit.
///
/// Defines the state for managing gallery selection mode and filters.
/// Supports multi-select functionality (style Photos iOS/Vinted).
library;

import 'package:flutter/foundation.dart';

/// Filter options for the gallery view.
enum GalleryFilter {
  /// Show all media items.
  all,

  /// Show only favorited media items.
  favorites,

  /// Show only hidden media items.
  hidden,
}

/// State for the gallery selection Cubit.
///
/// Tracks selection mode, selected media IDs, and the current filter.
@immutable
class GallerySelectionState {
  /// Creates a gallery selection state.
  const GallerySelectionState({
    this.isSelectionMode = false,
    this.selectedMediaIds = const {},
    this.currentFilter = GalleryFilter.all,
  });

  /// Whether the gallery is in selection mode.
  final bool isSelectionMode;

  /// Set of selected media IDs.
  final Set<String> selectedMediaIds;

  /// Current filter applied to the gallery.
  final GalleryFilter currentFilter;

  /// Returns the number of selected items.
  int get selectedCount => selectedMediaIds.length;

  /// Returns whether a specific media item is selected.
  bool isSelected(String mediaId) => selectedMediaIds.contains(mediaId);

  /// Returns whether any items are selected.
  bool get hasSelection => selectedMediaIds.isNotEmpty;

  /// Creates a copy with updated values.
  GallerySelectionState copyWith({
    bool? isSelectionMode,
    Set<String>? selectedMediaIds,
    GalleryFilter? currentFilter,
  }) {
    return GallerySelectionState(
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedMediaIds: selectedMediaIds ?? this.selectedMediaIds,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GallerySelectionState &&
        other.isSelectionMode == isSelectionMode &&
        setEquals(other.selectedMediaIds, selectedMediaIds) &&
        other.currentFilter == currentFilter;
  }

  @override
  int get hashCode => Object.hash(
        isSelectionMode,
        Object.hashAll(selectedMediaIds),
        currentFilter,
      );
}
