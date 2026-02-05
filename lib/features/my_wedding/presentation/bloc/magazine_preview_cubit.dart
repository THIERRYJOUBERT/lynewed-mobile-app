/// Magazine Preview Cubit for managing magazine preview state.
///
/// Handles format selection, layout generation, page navigation,
/// page editing, and auto-save/restore of drafts.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/magazine_draft.dart';
import '../../domain/entities/magazine_format.dart';
import '../../domain/entities/magazine_page.dart';
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
    required this.weddingId,
    MagazineLayoutService? layoutService,
  })  : _layoutService = layoutService ?? const MagazineLayoutService(),
        super(const MagazinePreviewState());

  /// Photos to include in the magazine.
  final List<MagazinePhoto> photos;

  /// Wedding title for the cover.
  final String weddingTitle;

  /// Wedding date for the cover.
  final DateTime weddingDate;

  /// Wedding ID used as key for draft persistence.
  final String weddingId;

  /// Layout service for generating pages.
  final MagazineLayoutService _layoutService;

  /// SharedPreferences key for this wedding's draft.
  String get _draftKey => 'magazine_draft_$weddingId';

  /// Initializes the preview by restoring a draft or generating fresh layouts.
  Future<void> initialize() async {
    // Try to restore a saved draft first.
    final draft = await _loadDraft();
    if (draft != null && _restoreFromDraft(draft)) {
      return;
    }

    // No draft or restoration failed — generate fresh layout.
    final pages = _layoutService.generateLayouts(
      photos: photos,
      weddingTitle: weddingTitle,
      weddingDate: weddingDate,
    );

    final cheapestFormat = MagazineFormats.getCheapestValidFormat(photos.length);

    // All photos except the cover photo go into the unassigned pool.
    final unassigned =
        photos.length > 1 ? photos.sublist(1) : <MagazinePhoto>[];

    emit(MagazinePreviewState(
      isLoading: false,
      pages: pages,
      selectedFormat: cheapestFormat,
      currentPageIndex: 0,
      photoCount: photos.length,
      unassignedPhotos: unassigned,
    ));
  }

  @override
  void onChange(Change<MagazinePreviewState> change) {
    super.onChange(change);
    if (!change.nextState.isLoading) {
      _saveDraft(change.nextState);
    }
  }

  // ── Draft Persistence ─────────────────────────────────────────────────

  Future<void> _saveDraft(MagazinePreviewState state) async {
    try {
      final coverTitle = _coverTitle(state);
      final coverSubtitle = _coverSubtitle(state);

      final draftPages = state.pages.map((page) {
        final type = switch (page) {
          CoverPage() => 'cover',
          SinglePage() => 'single',
          DoublePage(isStacked: true) => 'double_stacked',
          DoublePage() => 'double',
          MosaicPage(isFeatureLayout: true) => 'feature4',
          MosaicPage() => 'mosaic',
          _ => 'single',
        };
        return MagazineDraftPage(
          type: type,
          photoIds: page.photos.map((p) => p.selectionId).toList(),
        );
      }).toList();

      final draft = MagazineDraft(
        pages: draftPages,
        unassignedIds:
            state.unassignedPhotos.map((p) => p.selectionId).toList(),
        formatName: state.selectedFormat?.name,
        coverTitle: coverTitle,
        coverSubtitle: coverSubtitle,
        savedAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_draftKey, draft.encode());
    } on Object {
      // Silently ignore save failures — non-critical.
    }
  }

  Future<MagazineDraft?> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_draftKey);
      if (json == null) return null;
      return MagazineDraft.decode(json);
    } on Object {
      return null;
    }
  }

  bool _restoreFromDraft(MagazineDraft draft) {
    final photoMap = {for (final p in photos) p.selectionId: p};
    final restoredPages = <MagazinePage>[];
    final usedIds = <String>{};

    for (final draftPage in draft.pages) {
      final pagePhotos = <MagazinePhoto>[];
      for (final id in draftPage.photoIds) {
        final photo = photoMap[id];
        if (photo == null) return false; // Photo no longer exists.
        pagePhotos.add(photo);
      }
      usedIds.addAll(draftPage.photoIds);

      if (draftPage.type == 'cover' && pagePhotos.isNotEmpty) {
        restoredPages.add(CoverPage(
          photo: pagePhotos.first,
          weddingTitle: draft.coverTitle,
          weddingDate: weddingDate,
          coverSubtitle: draft.coverSubtitle,
        ));
      } else {
        final layout = _layoutForType(draftPage.type, pagePhotos.length);
        restoredPages.add(
          MagazineLayoutService.createPageFromLayout(layout, pagePhotos),
        );
      }
    }

    // Only truly new photos (added since the draft was saved).
    final accountedIds = {...usedIds, ...draft.unassignedIds};
    final newPhotos =
        photos.where((p) => !accountedIds.contains(p.selectionId)).toList();
    // Photos from draft unassigned list that still exist.
    final draftUnassigned = draft.unassignedIds
        .where((id) => photoMap.containsKey(id))
        .map((id) => photoMap[id]!)
        .toList();

    final allUnassigned = [...draftUnassigned, ...newPhotos];
    final format = draft.formatName != null
        ? MagazineFormats.getByName(draft.formatName!)
        : MagazineFormats.getCheapestValidFormat(photos.length);

    emit(MagazinePreviewState(
      isLoading: false,
      pages: restoredPages,
      selectedFormat: format,
      unassignedPhotos: allUnassigned,
      photoCount: photos.length,
      hasManualEdits: true,
    ));
    return true;
  }

  EditablePageLayout _layoutForType(String type, int photoCount) {
    return switch (type) {
      'single' => EditablePageLayout.single,
      'double' => EditablePageLayout.double,
      'double_stacked' => EditablePageLayout.doubleStacked,
      'feature4' => EditablePageLayout.feature4,
      'mosaic' => switch (photoCount) {
          4 => EditablePageLayout.mosaic4,
          5 => EditablePageLayout.mosaic5,
          _ => EditablePageLayout.mosaic6,
        },
      _ => EditablePageLayout.single,
    };
  }

  String _coverTitle(MagazinePreviewState state) {
    if (state.pages.isNotEmpty && state.pages.first is CoverPage) {
      return (state.pages.first as CoverPage).weddingTitle;
    }
    return weddingTitle;
  }

  String _coverSubtitle(MagazinePreviewState state) {
    if (state.pages.isNotEmpty && state.pages.first is CoverPage) {
      return (state.pages.first as CoverPage).coverSubtitle;
    }
    return 'Captured by our loved ones';
  }

  /// Selects a magazine format.
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
    if (state.pages.isEmpty) return;
    final clampedIndex = index.clamp(0, state.pageCount - 1);
    if (clampedIndex == state.currentPageIndex) return;
    emit(state.copyWith(currentPageIndex: clampedIndex));
  }

  // ── Page Editing Methods ──────────────────────────────────────────────

  /// Changes the layout of a page at [pageIndex].
  ///
  /// Redistributes photos: excess goes to unassigned pool,
  /// deficit is filled from unassigned pool.
  void changePageLayout(int pageIndex, EditablePageLayout newLayout) {
    if (pageIndex < 0 || pageIndex >= state.pages.length) return;

    final page = state.pages[pageIndex];

    // Cannot change cover layout.
    if (page is CoverPage) return;

    final currentPhotos = page.photos;
    final needed = newLayout.photoCount;
    final available = currentPhotos.length;

    List<MagazinePhoto> pagePhotos;
    List<MagazinePhoto> newUnassigned;

    if (needed <= available) {
      // Shrinking: excess photos go to unassigned.
      pagePhotos = currentPhotos.sublist(0, needed);
      final excess = currentPhotos.sublist(needed);
      newUnassigned = [...state.unassignedPhotos, ...excess];
    } else {
      // Growing: pull from unassigned pool.
      final deficit = needed - available;
      if (state.unassignedPhotos.length < deficit) return; // Not enough photos.
      final pulled = state.unassignedPhotos.sublist(0, deficit);
      pagePhotos = [...currentPhotos, ...pulled];
      newUnassigned = state.unassignedPhotos.sublist(deficit);
    }

    final newPage =
        MagazineLayoutService.createPageFromLayout(newLayout, pagePhotos);
    final newPages = [...state.pages];
    newPages[pageIndex] = newPage;

    emit(state.copyWith(
      pages: newPages,
      unassignedPhotos: newUnassigned,
      hasManualEdits: true,
    ));
  }

  /// Removes a photo from a page at [pageIndex].
  ///
  /// The photo moves to the unassigned pool.
  /// If the page becomes empty, it is removed.
  /// If the page type needs more photos than remaining, the layout adjusts.
  void removePhotoFromPage(int pageIndex, int photoIndexInPage) {
    if (pageIndex < 0 || pageIndex >= state.pages.length) return;

    final page = state.pages[pageIndex];
    if (photoIndexInPage < 0 || photoIndexInPage >= page.photos.length) return;

    // Cannot remove cover photo (use swapCoverPhoto instead).
    if (page is CoverPage) return;

    final removedPhoto = page.photos[photoIndexInPage];
    final remainingPhotos = [...page.photos]..removeAt(photoIndexInPage);
    final newUnassigned = [...state.unassignedPhotos, removedPhoto];
    final newPages = [...state.pages];

    if (remainingPhotos.isEmpty) {
      // Remove the page entirely.
      newPages.removeAt(pageIndex);
      final newIndex = state.currentPageIndex >= newPages.length
          ? (newPages.length - 1).clamp(0, newPages.length)
          : state.currentPageIndex;
      emit(state.copyWith(
        pages: newPages,
        unassignedPhotos: newUnassigned,
        hasManualEdits: true,
        currentPageIndex: newIndex,
      ));
      return;
    }

    // Rebuild page with appropriate layout for remaining photo count.
    final newLayout = _bestLayoutForCount(remainingPhotos.length);
    final newPage =
        MagazineLayoutService.createPageFromLayout(newLayout, remainingPhotos);
    newPages[pageIndex] = newPage;

    emit(state.copyWith(
      pages: newPages,
      unassignedPhotos: newUnassigned,
      hasManualEdits: true,
    ));
  }

  /// Adds an unassigned photo to the page at [pageIndex].
  ///
  /// Returns false if the page is at capacity for its current layout.
  bool addPhotoToPage(int pageIndex, MagazinePhoto photo) {
    if (pageIndex < 0 || pageIndex >= state.pages.length) return false;

    final page = state.pages[pageIndex];

    // Cover can only have 1 photo.
    if (page is CoverPage) return false;

    final currentLayout = EditablePageLayout.fromPage(page);
    final currentPhotos = page.photos;

    if (currentPhotos.length >= currentLayout.photoCount) return false;

    final newPhotos = [...currentPhotos, photo];
    final newPage =
        MagazineLayoutService.createPageFromLayout(currentLayout, newPhotos);
    final newPages = [...state.pages];
    newPages[pageIndex] = newPage;

    final newUnassigned =
        state.unassignedPhotos.where((p) => p != photo).toList();

    emit(state.copyWith(
      pages: newPages,
      unassignedPhotos: newUnassigned,
      hasManualEdits: true,
    ));
    return true;
  }

  /// Reorders photos within a page.
  void reorderPhotosInPage(int pageIndex, int oldIndex, int newIndex) {
    if (pageIndex < 0 || pageIndex >= state.pages.length) return;

    final page = state.pages[pageIndex];
    if (page is CoverPage) return;

    final photos = [...page.photos];
    if (oldIndex < 0 ||
        oldIndex >= photos.length ||
        newIndex < 0 ||
        newIndex >= photos.length) {
      return;
    }

    final photo = photos.removeAt(oldIndex);
    photos.insert(newIndex, photo);

    final layout = EditablePageLayout.fromPage(page);
    final newPage =
        MagazineLayoutService.createPageFromLayout(layout, photos);
    final newPages = [...state.pages];
    newPages[pageIndex] = newPage;

    emit(state.copyWith(
      pages: newPages,
      hasManualEdits: true,
    ));
  }

  /// Swaps a photo in a page with an unassigned photo.
  ///
  /// The old photo goes to unassigned, and [newPhoto] takes its position.
  void swapPhotoInPage(
      int pageIndex, int photoIndexInPage, MagazinePhoto newPhoto) {
    if (pageIndex < 0 || pageIndex >= state.pages.length) return;

    final page = state.pages[pageIndex];
    if (page is CoverPage) return;
    if (photoIndexInPage < 0 || photoIndexInPage >= page.photos.length) return;

    final oldPhoto = page.photos[photoIndexInPage];
    final newPhotos = [...page.photos];
    newPhotos[photoIndexInPage] = newPhoto;

    final layout = EditablePageLayout.fromPage(page);
    final newPage =
        MagazineLayoutService.createPageFromLayout(layout, newPhotos);
    final newPages = [...state.pages];
    newPages[pageIndex] = newPage;

    final newUnassigned = state.unassignedPhotos
        .where((p) => p != newPhoto)
        .toList()
      ..add(oldPhoto);

    emit(state.copyWith(
      pages: newPages,
      unassignedPhotos: newUnassigned,
      hasManualEdits: true,
    ));
  }

  /// Updates the cover text (title and/or subtitle).
  void updateCoverText({String? title, String? subtitle}) {
    if (state.pages.isEmpty || state.pages.first is! CoverPage) return;
    final cover = state.pages.first as CoverPage;
    final newCover = CoverPage(
      photo: cover.photo,
      weddingTitle: title ?? cover.weddingTitle,
      weddingDate: cover.weddingDate,
      coverSubtitle: subtitle ?? cover.coverSubtitle,
    );
    final newPages = [...state.pages];
    newPages[0] = newCover;
    emit(state.copyWith(pages: newPages, hasManualEdits: true));
  }

  /// Swaps the cover photo with another photo.
  void swapCoverPhoto(MagazinePhoto newPhoto) {
    if (state.pages.isEmpty || state.pages.first is! CoverPage) return;

    final cover = state.pages.first as CoverPage;
    final oldPhoto = cover.photo;

    final newCover = CoverPage(
      photo: newPhoto,
      weddingTitle: cover.weddingTitle,
      weddingDate: cover.weddingDate,
      coverSubtitle: cover.coverSubtitle,
    );

    final newPages = [...state.pages];
    newPages[0] = newCover;

    // Old cover photo goes to unassigned, new photo removed from unassigned.
    final newUnassigned = state.unassignedPhotos
        .where((p) => p != newPhoto)
        .toList()
      ..add(oldPhoto);

    emit(state.copyWith(
      pages: newPages,
      unassignedPhotos: newUnassigned,
      hasManualEdits: true,
    ));
  }

  /// Replaces a page's content and unassigned photos atomically.
  ///
  /// Used by the edit sheet to commit local changes on Save.
  void setPageContent(
    int pageIndex,
    EditablePageLayout layout,
    List<MagazinePhoto> photos,
    List<MagazinePhoto> unassigned,
  ) {
    if (pageIndex < 0 || pageIndex >= state.pages.length) return;
    if (state.pages[pageIndex] is CoverPage) return;

    final newPage =
        MagazineLayoutService.createPageFromLayout(layout, photos);
    final newPages = [...state.pages];
    newPages[pageIndex] = newPage;

    emit(state.copyWith(
      pages: newPages,
      unassignedPhotos: unassigned,
      hasManualEdits: true,
    ));
  }

  /// Adds a new page with specific photos at the given position.
  ///
  /// Used by the edit sheet in create mode to commit a new page on Save.
  void addPageWithPhotos(
    int afterIndex,
    EditablePageLayout layout,
    List<MagazinePhoto> photos,
    List<MagazinePhoto> unassigned,
  ) {
    final newPage =
        MagazineLayoutService.createPageFromLayout(layout, photos);
    final insertIndex = (afterIndex + 1).clamp(0, state.pages.length);
    final newPages = [...state.pages]..insert(insertIndex, newPage);

    emit(state.copyWith(
      pages: newPages,
      unassignedPhotos: unassigned,
      hasManualEdits: true,
      currentPageIndex: insertIndex,
    ));
  }

  /// Adds a new page after [afterIndex] with the given layout.
  ///
  /// Photos are pulled from the unassigned pool.
  void addPage(int afterIndex, EditablePageLayout layout) {
    if (state.unassignedPhotos.length < layout.photoCount) return;

    final pagePhotos = state.unassignedPhotos.sublist(0, layout.photoCount);
    final newPage =
        MagazineLayoutService.createPageFromLayout(layout, pagePhotos);
    final newUnassigned = state.unassignedPhotos.sublist(layout.photoCount);

    final insertIndex = (afterIndex + 1).clamp(0, state.pages.length);
    final newPages = [...state.pages]..insert(insertIndex, newPage);

    emit(state.copyWith(
      pages: newPages,
      unassignedPhotos: newUnassigned,
      hasManualEdits: true,
      currentPageIndex: insertIndex,
    ));
  }

  /// Deletes a page at [pageIndex]. All photos go to unassigned.
  ///
  /// Cannot delete the cover page.
  void deletePage(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= state.pages.length) return;
    if (state.pages[pageIndex] is CoverPage) return;

    final page = state.pages[pageIndex];
    final newUnassigned = [...state.unassignedPhotos, ...page.photos];
    final newPages = [...state.pages]..removeAt(pageIndex);
    final newIndex = state.currentPageIndex >= newPages.length
        ? (newPages.length - 1).clamp(0, newPages.length)
        : state.currentPageIndex;

    emit(state.copyWith(
      pages: newPages,
      unassignedPhotos: newUnassigned,
      hasManualEdits: true,
      currentPageIndex: newIndex,
    ));
  }

  /// Regenerates the entire layout from scratch, discarding manual edits.
  void regenerateLayout() {
    final allPhotos = <MagazinePhoto>[];
    for (final page in state.pages) {
      allPhotos.addAll(page.photos);
    }
    allPhotos.addAll(state.unassignedPhotos);

    final pages = _layoutService.generateLayouts(
      photos: allPhotos,
      weddingTitle: weddingTitle,
      weddingDate: weddingDate,
    );

    // All photos except the cover go to unassigned.
    final unassigned = allPhotos.length > 1
        ? allPhotos.sublist(1)
        : <MagazinePhoto>[];

    emit(state.copyWith(
      pages: pages,
      unassignedPhotos: unassigned,
      hasManualEdits: false,
      currentPageIndex: 0,
    ));
  }

  /// Returns the best layout for a given photo count.
  EditablePageLayout _bestLayoutForCount(int count) {
    return switch (count) {
      1 => EditablePageLayout.single,
      2 => EditablePageLayout.double,
      3 => EditablePageLayout.double, // 2 + 1 unassigned handled elsewhere
      4 => EditablePageLayout.mosaic4,
      5 => EditablePageLayout.mosaic5,
      _ => EditablePageLayout.mosaic6,
    };
  }
}
