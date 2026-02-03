/// Magazine Layout Service for generating page layouts.
///
/// Distributes photos across different page types (cover, single, double, mosaic)
/// to create a visually appealing magazine layout.
library;

import '../entities/magazine_page.dart';
import '../../presentation/bloc/magazine_selection_state.dart';

/// Service for generating magazine page layouts from photos.
class MagazineLayoutService {
  /// Creates a MagazineLayoutService.
  const MagazineLayoutService();

  /// Generates magazine page layouts from the given photos.
  ///
  /// Returns an ordered list of [MagazinePage] instances:
  /// - First page is always a cover with the first photo
  /// - Remaining photos are distributed across mosaic, double, and single pages
  ///
  /// Layout algorithm:
  /// - 6+ remaining: mosaic page (6 photos)
  /// - 4-5 remaining: mosaic page (4 or 5 photos)
  /// - 2-3 remaining: double page (2 photos)
  /// - 1 remaining: single page
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

    // Distribute remaining photos
    if (photos.length > 1) {
      final remaining = photos.sublist(1);
      pages.addAll(_distributePhotos(remaining));
    }

    return pages;
  }

  /// Distributes photos across page types.
  List<MagazinePage> _distributePhotos(List<MagazinePhoto> photos) {
    final pages = <MagazinePage>[];
    var index = 0;

    while (index < photos.length) {
      final photosLeft = photos.length - index;

      if (photosLeft >= 6) {
        // Full mosaic page (6 photos)
        pages.add(MosaicPage(
          mosaicPhotos: photos.sublist(index, index + 6),
        ));
        index += 6;
      } else if (photosLeft >= 4) {
        // Partial mosaic page (4-5 photos)
        pages.add(MosaicPage(
          mosaicPhotos: photos.sublist(index, index + photosLeft),
        ));
        index += photosLeft;
      } else if (photosLeft >= 2) {
        // Double page (2 photos)
        pages.add(DoublePage(
          leftPhoto: photos[index],
          rightPhoto: photos[index + 1],
        ));
        index += 2;
      } else {
        // Single page (1 photo)
        pages.add(SinglePage(photo: photos[index]));
        index += 1;
      }
    }

    return pages;
  }
}
