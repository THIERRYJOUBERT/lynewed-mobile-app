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
  });

  /// The cover photo.
  final MagazinePhoto photo;

  /// Wedding title (e.g., 'Jessica & Kyle').
  final String weddingTitle;

  /// Wedding date.
  final DateTime weddingDate;

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
  });

  /// The left photo.
  final MagazinePhoto leftPhoto;

  /// The right photo.
  final MagazinePhoto rightPhoto;

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
  const MosaicPage({required this.mosaicPhotos});

  /// The photos in the mosaic (typically 4-6).
  final List<MagazinePhoto> mosaicPhotos;

  @override
  MagazinePageType get type => MagazinePageType.mosaic;

  @override
  int get photoCount => mosaicPhotos.length;

  @override
  List<MagazinePhoto> get photos => mosaicPhotos;
}
