/// Magazine Preview Cubit for managing magazine preview state.
///
/// Handles format selection, layout generation, and page navigation.
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/magazine_format.dart';
import '../../domain/services/magazine_layout_service.dart';
import 'magazine_preview_state.dart';
import 'magazine_selection_state.dart';

/// Cubit for managing magazine preview state.
class MagazinePreviewCubit extends Cubit<MagazinePreviewState> {
  /// Creates a MagazinePreviewCubit.
  MagazinePreviewCubit({
    required this.photos,
    required this.weddingTitle,
    required this.weddingDate,
    MagazineLayoutService? layoutService,
  })  : _layoutService = layoutService ?? const MagazineLayoutService(),
        super(const MagazinePreviewState());

  /// Photos to include in the magazine.
  final List<MagazinePhoto> photos;

  /// Wedding title for the cover.
  final String weddingTitle;

  /// Wedding date for the cover.
  final DateTime weddingDate;

  /// Layout service for generating pages.
  final MagazineLayoutService _layoutService;

  /// Initializes the preview by generating layouts and selecting format.
  void initialize() {
    final pages = _layoutService.generateLayouts(
      photos: photos,
      weddingTitle: weddingTitle,
      weddingDate: weddingDate,
    );

    final cheapestFormat = MagazineFormats.getCheapestValidFormat(photos.length);

    emit(MagazinePreviewState(
      isLoading: false,
      pages: pages,
      selectedFormat: cheapestFormat,
      currentPageIndex: 0,
      photoCount: photos.length,
    ));
  }

  /// Selects a magazine format.
  ///
  /// Only accepts formats valid for the current photo count.
  void selectFormat(MagazineFormat format) {
    if (format == state.selectedFormat) return;
    if (!format.isValidForPhotoCount(state.photoCount)) return;

    emit(state.copyWith(selectedFormat: format));
  }

  /// Navigates to the next page.
  void nextPage() {
    if (!state.canGoNext) return;
    emit(state.copyWith(currentPageIndex: state.currentPageIndex + 1));
  }

  /// Navigates to the previous page.
  void previousPage() {
    if (!state.canGoPrevious) return;
    emit(state.copyWith(currentPageIndex: state.currentPageIndex - 1));
  }

  /// Navigates to a specific page.
  void goToPage(int index) {
    final clampedIndex = index.clamp(0, state.pageCount - 1);
    if (clampedIndex == state.currentPageIndex) return;
    emit(state.copyWith(currentPageIndex: clampedIndex));
  }
}
