/// Magazine Preview State for MagazinePreviewCubit.
///
/// Manages the state for magazine preview including selected format,
/// generated pages, current page navigation, and page editing.
library;

import 'package:flutter/foundation.dart';

import '../../domain/entities/magazine_format.dart';
import '../../domain/entities/magazine_page.dart';
import 'magazine_selection_state.dart';

/// State for the magazine preview Cubit.
@immutable
class MagazinePreviewState {
  /// Creates a magazine preview state.
  const MagazinePreviewState({
    this.isLoading = true,
    this.pages = const [],
    this.selectedFormat,
    this.currentPageIndex = 0,
    this.photoCount = 0,
    this.errorMessage,
    this.unassignedPhotos = const [],
    this.hasManualEdits = false,
  });

  /// Whether the preview is loading.
  final bool isLoading;

  /// Generated magazine pages.
  final List<MagazinePage> pages;

  /// Currently selected magazine format.
  final MagazineFormat? selectedFormat;

  /// Current page index for navigation.
  final int currentPageIndex;

  /// Total number of photos in the magazine (assigned + unassigned).
  final int photoCount;

  /// Error message if something went wrong.
  final String? errorMessage;

  /// Photos not currently assigned to any page.
  final List<MagazinePhoto> unassignedPhotos;

  /// Whether the layout has been manually edited.
  final bool hasManualEdits;

  /// Returns the total number of pages.
  int get pageCount => pages.length;

  /// Returns the current page.
  MagazinePage? get currentPage =>
      pages.isNotEmpty && currentPageIndex < pages.length
          ? pages[currentPageIndex]
          : null;

  /// Returns whether navigation to next page is possible.
  bool get canGoNext => currentPageIndex < pages.length - 1;

  /// Returns whether navigation to previous page is possible.
  bool get canGoPrevious => currentPageIndex > 0;

  /// Returns all valid formats for the current photo count.
  List<MagazineFormat> get validFormats =>
      MagazineFormats.getValidFormats(photoCount);

  /// Returns whether a format is valid for the current photo count.
  bool isFormatValid(MagazineFormat format) =>
      format.isValidForPhotoCount(photoCount);

  /// Returns the price of the selected format in cents.
  int get priceCents => selectedFormat?.priceCents ?? 0;

  /// Returns the formatted price string.
  String get priceFormatted => selectedFormat?.priceFormatted ?? '\$0';

  /// Returns whether there are unassigned photos.
  bool get hasUnassignedPhotos => unassignedPhotos.isNotEmpty;

  /// Returns the count of unassigned photos.
  int get unassignedCount => unassignedPhotos.length;

  /// Creates a copy with updated values.
  MagazinePreviewState copyWith({
    bool? isLoading,
    List<MagazinePage>? pages,
    MagazineFormat? selectedFormat,
    int? currentPageIndex,
    int? photoCount,
    String? errorMessage,
    bool clearError = false,
    List<MagazinePhoto>? unassignedPhotos,
    bool? hasManualEdits,
  }) {
    return MagazinePreviewState(
      isLoading: isLoading ?? this.isLoading,
      pages: pages ?? this.pages,
      selectedFormat: selectedFormat ?? this.selectedFormat,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      photoCount: photoCount ?? this.photoCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      unassignedPhotos: unassignedPhotos ?? this.unassignedPhotos,
      hasManualEdits: hasManualEdits ?? this.hasManualEdits,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MagazinePreviewState &&
        other.isLoading == isLoading &&
        listEquals(other.pages, pages) &&
        other.selectedFormat == selectedFormat &&
        other.currentPageIndex == currentPageIndex &&
        other.photoCount == photoCount &&
        other.errorMessage == errorMessage &&
        listEquals(other.unassignedPhotos, unassignedPhotos) &&
        other.hasManualEdits == hasManualEdits;
  }

  @override
  int get hashCode => Object.hash(
        isLoading,
        Object.hashAll(pages),
        selectedFormat,
        currentPageIndex,
        photoCount,
        errorMessage,
        Object.hashAll(unassignedPhotos),
        hasManualEdits,
      );
}
