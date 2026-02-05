/// Magazine Layout Service for generating page layouts.
///
/// Creates the initial cover page and provides utilities for creating
/// individual pages from layout types.
library;

import '../entities/magazine_page.dart';
import '../../presentation/bloc/magazine_selection_state.dart';

/// Service for generating magazine page layouts from photos.
class MagazineLayoutService {
  /// Creates a MagazineLayoutService.
  const MagazineLayoutService();

  /// Creates a single page from a layout type and photos.
  ///
  /// The [photos] list must have at least [layout.photoCount] items.
  /// Only the first [layout.photoCount] photos are used.
  static MagazinePage createPageFromLayout(
    EditablePageLayout layout,
    List<MagazinePhoto> photos,
  ) {
    return switch (layout) {
      EditablePageLayout.single => SinglePage(photo: photos[0]),
      EditablePageLayout.double => DoublePage(
          leftPhoto: photos[0],
          rightPhoto: photos[1],
        ),
      EditablePageLayout.doubleStacked => DoublePage(
          leftPhoto: photos[0],
          rightPhoto: photos[1],
          isStacked: true,
        ),
      EditablePageLayout.mosaic4 =>
        MosaicPage(mosaicPhotos: photos.sublist(0, 4)),
      EditablePageLayout.feature4 => MosaicPage(
          mosaicPhotos: photos.sublist(0, 4),
          isFeatureLayout: true,
        ),
      EditablePageLayout.mosaic5 =>
        MosaicPage(mosaicPhotos: photos.sublist(0, 5)),
      EditablePageLayout.mosaic6 =>
        MosaicPage(mosaicPhotos: photos.sublist(0, 6)),
    };
  }

  /// Generates the initial magazine layout from the given photos.
  ///
  /// Returns a list containing only a [CoverPage] with the first photo.
  /// All remaining photos should be placed in the unassigned pool by the
  /// caller, allowing the bride to manually create pages.
  List<MagazinePage> generateLayouts({
    required List<MagazinePhoto> photos,
    required String weddingTitle,
    required DateTime weddingDate,
  }) {
    if (photos.isEmpty) {
      return [];
    }

    final pages = <MagazinePage>[];

    // First page is always the cover
    pages.add(CoverPage(
      photo: photos.first,
      weddingTitle: weddingTitle,
      weddingDate: weddingDate,
    ));

    return pages;
  }
}
