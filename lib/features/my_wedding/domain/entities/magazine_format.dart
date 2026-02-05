/// Magazine Format entity for wedding photo magazines.
///
/// Defines the available magazine formats with their specifications.
/// Each format has a size, number of spreads, max photos, and price.
library;

import 'package:flutter/foundation.dart';

/// Magazine Format entity - defines a magazine size/format option.
@immutable
class MagazineFormat {
  /// Creates a magazine format.
  const MagazineFormat({
    required this.id,
    required this.name,
    required this.size,
    required this.spreads,
    required this.maxPhotos,
    required this.priceCents,
    required this.widthCm,
    required this.heightCm,
  });

  /// Unique identifier for this format.
  final String id;

  /// Display name (e.g., 'GUEST EDITION', 'ICONIC').
  final String name;

  /// Physical size (e.g., '21x30cm', '25x32cm').
  final String size;

  /// Number of spreads (double pages) in the magazine.
  final int spreads;

  /// Maximum number of photos allowed in this format.
  final int maxPhotos;

  /// Price in cents (USD).
  final int priceCents;

  /// Width in centimeters.
  final int widthCm;

  /// Height in centimeters.
  final int heightCm;

  /// Aspect ratio (width / height) for preview rendering.
  double get aspectRatio => widthCm / heightCm;

  /// Returns true if the given photo count fits in this format.
  bool isValidForPhotoCount(int photoCount) => photoCount <= maxPhotos;

  /// Formatted price string (e.g., '$29' or '$29.50').
  String get priceFormatted {
    final dollars = priceCents ~/ 100;
    final cents = priceCents % 100;
    if (cents == 0) {
      return '\$$dollars';
    }
    return '\$$dollars.${cents.toString().padLeft(2, '0')}';
  }

  /// Returns true if this is the premium collector format.
  bool get isPremium => id == 'collector';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MagazineFormat && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MagazineFormat($id, $name)';
}

/// Predefined magazine formats available for order.
class MagazineFormats {
  MagazineFormats._();

  /// Guest Edition - Entry level, 20 photos max.
  static const guestEdition = MagazineFormat(
    id: 'guest_edition',
    name: 'GUEST EDITION',
    size: '21x30cm',
    spreads: 20,
    maxPhotos: 20,
    priceCents: 2900,
    widthCm: 21,
    heightCm: 30,
  );

  /// Iconic - Mid-tier, 40 photos max.
  static const iconic = MagazineFormat(
    id: 'iconic',
    name: 'ICONIC',
    size: '21x30cm',
    spreads: 40,
    maxPhotos: 40,
    priceCents: 5900,
    widthCm: 21,
    heightCm: 30,
  );

  /// Memory - Standard premium, 60 photos max.
  static const memory = MagazineFormat(
    id: 'memory',
    name: 'MEMORY',
    size: '21x30cm',
    spreads: 60,
    maxPhotos: 60,
    priceCents: 6900,
    widthCm: 21,
    heightCm: 30,
  );

  /// Collector - Premium large format, 60 photos max.
  static const collector = MagazineFormat(
    id: 'collector',
    name: 'COLLECTOR',
    size: '25x32cm',
    spreads: 60,
    maxPhotos: 60,
    priceCents: 8900,
    widthCm: 25,
    heightCm: 32,
  );

  /// All available formats, ordered by price ascending.
  static const List<MagazineFormat> all = [
    guestEdition,
    iconic,
    memory,
    collector,
  ];

  /// Returns formats that can accommodate the given photo count.
  static List<MagazineFormat> getValidFormats(int photoCount) {
    return all.where((f) => f.isValidForPhotoCount(photoCount)).toList();
  }

  /// Returns the cheapest format that can accommodate the given photo count.
  static MagazineFormat? getCheapestValidFormat(int photoCount) {
    final valid = getValidFormats(photoCount);
    if (valid.isEmpty) return null;
    return valid.first; // Already sorted by price
  }

  /// Finds a format by its ID.
  static MagazineFormat? getFormatById(String id) {
    for (final format in all) {
      if (format.id == id) return format;
    }
    return null;
  }

  /// Finds a format by its display name.
  static MagazineFormat? getByName(String name) {
    for (final format in all) {
      if (format.name == name) return format;
    }
    return null;
  }
}
