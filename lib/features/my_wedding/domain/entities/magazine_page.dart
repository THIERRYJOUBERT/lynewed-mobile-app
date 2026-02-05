/// Magazine Page entity for wedding photo magazine layouts.
///
/// Defines the different page types used in magazine preview:
/// - CoverPage: The magazine cover with title and date
/// - SinglePage: A page with one large photo
/// - DoublePage: A spread with two photos side by side
/// - MosaicPage: A page with multiple photos in a grid layout
library;

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../presentation/bloc/magazine_selection_state.dart';

/// Types of magazine pages.
enum MagazinePageType {
  /// Cover page with branding and title.
  cover,

  /// Single large photo page.
  single,

  /// Two photos side by side.
  double,

  /// Multiple photos in mosaic/grid layout.
  mosaic,
}

/// Editable layout options for magazine pages.
///
/// Used in the page edit sheet to let users choose page layouts.
enum EditablePageLayout {
  /// Single full-page photo.
  single(photoCount: 1, label: 'Full Page'),

  /// Two photos side by side.
  double(photoCount: 2, label: 'Spread'),

  /// Two photos stacked vertically.
  doubleStacked(photoCount: 2, label: 'Stacked'),

  /// 2x2 grid of 4 photos.
  mosaic4(photoCount: 4, label: 'Grid 2x2'),

  /// 1 feature photo + 3 smaller photos.
  feature4(photoCount: 4, label: 'Feature'),

  /// Asymmetric grid of 5 photos.
  mosaic5(photoCount: 5, label: 'Grid 5'),

  /// 3x2 grid of 6 photos.
  mosaic6(photoCount: 6, label: 'Grid 3x2');

  const EditablePageLayout({required this.photoCount, required this.label});

  /// Number of photos this layout requires.
  final int photoCount;

  /// Display label for this layout.
  final String label;

  /// Returns the layout matching a given page.
  static EditablePageLayout fromPage(MagazinePage page) {
    return switch (page) {
      CoverPage() => EditablePageLayout.single,
      SinglePage() => EditablePageLayout.single,
      DoublePage(isStacked: true) => EditablePageLayout.doubleStacked,
      DoublePage() => EditablePageLayout.double,
      MosaicPage(isFeatureLayout: true, mosaicPhotos: final p)
          when p.length == 4 =>
        EditablePageLayout.feature4,
      MosaicPage(mosaicPhotos: final p) when p.length == 4 =>
        EditablePageLayout.mosaic4,
      MosaicPage(mosaicPhotos: final p) when p.length == 5 =>
        EditablePageLayout.mosaic5,
      MosaicPage() => EditablePageLayout.mosaic6,
      _ => EditablePageLayout.single,
    };
  }
}

/// Base class for magazine pages.
@immutable
abstract class MagazinePage {
  /// Creates a magazine page.
  const MagazinePage();

  /// The type of page layout.
  MagazinePageType get type;

  /// Number of photos on this page.
  int get photoCount;

  /// All photos on this page.
  List<MagazinePhoto> get photos;
}

/// Cover page for the magazine.
@immutable
class CoverPage extends MagazinePage {
  /// Creates a cover page.
  const CoverPage({
    required this.photo,
    required this.weddingTitle,
    required this.weddingDate,
    this.coverSubtitle = 'Captured by our loved ones',
  });

  /// The cover photo.
  final MagazinePhoto photo;

  /// Wedding title (e.g., 'Jessica & Kyle').
  final String weddingTitle;

  /// Wedding date.
  final DateTime weddingDate;

  /// Subtitle shown below the title.
  final String coverSubtitle;

  @override
  MagazinePageType get type => MagazinePageType.cover;

  @override
  int get photoCount => 1;

  @override
  List<MagazinePhoto> get photos => [photo];

  /// Formatted wedding date (e.g., 'June 12, 2025').
  String get formattedDate => DateFormat('MMMM d, y').format(weddingDate);
}

/// Single photo page.
@immutable
class SinglePage extends MagazinePage {
  /// Creates a single photo page.
  const SinglePage({required this.photo});

  /// The photo on this page.
  final MagazinePhoto photo;

  @override
  MagazinePageType get type => MagazinePageType.single;

  @override
  int get photoCount => 1;

  @override
  List<MagazinePhoto> get photos => [photo];
}

/// Double photo spread page.
@immutable
class DoublePage extends MagazinePage {
  /// Creates a double photo spread.
  const DoublePage({
    required this.leftPhoto,
    required this.rightPhoto,
    this.isStacked = false,
  });

  /// The left photo.
  final MagazinePhoto leftPhoto;

  /// The right photo.
  final MagazinePhoto rightPhoto;

  /// When true, photos are stacked vertically instead of side by side.
  final bool isStacked;

  @override
  MagazinePageType get type => MagazinePageType.double;

  @override
  int get photoCount => 2;

  @override
  List<MagazinePhoto> get photos => [leftPhoto, rightPhoto];
}

/// Mosaic/grid layout page with multiple photos.
@immutable
class MosaicPage extends MagazinePage {
  /// Creates a mosaic page.
  const MosaicPage({
    required this.mosaicPhotos,
    this.isFeatureLayout = false,
  });

  /// The photos in the mosaic (typically 4-6).
  final List<MagazinePhoto> mosaicPhotos;

  /// When true, uses feature layout (1 large + 3 small) instead of grid.
  final bool isFeatureLayout;

  @override
  MagazinePageType get type => MagazinePageType.mosaic;

  @override
  int get photoCount => mosaicPhotos.length;

  @override
  List<MagazinePhoto> get photos => mosaicPhotos;
}
