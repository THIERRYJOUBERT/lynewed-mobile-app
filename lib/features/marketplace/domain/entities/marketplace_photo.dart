/// MarketplacePhoto entity - A photo attached to a marketplace listing
///
/// Immutable data class representing a photo with ordering (position).
library;

import 'package:flutter/foundation.dart';

/// Represents a photo attached to a marketplace listing.
///
/// Contains storage paths for full image and thumbnail, plus position for ordering.
@immutable
class MarketplacePhoto {
  /// Creates a marketplace photo.
  const MarketplacePhoto({
    required this.id,
    required this.listingId,
    required this.storagePath,
    this.thumbnailPath,
    required this.position,
    required this.createdAt,
  });

  /// Unique identifier (UUID from database).
  final String id;

  /// Listing ID this photo belongs to.
  final String listingId;

  /// Full image storage path (e.g., "listing-id/photo_0.jpg").
  final String storagePath;

  /// Optional thumbnail storage path.
  final String? thumbnailPath;

  /// Position for ordering (0 = cover photo).
  final int position;

  /// When the photo was created.
  final DateTime createdAt;

  /// Whether this is the cover photo (position 0).
  bool get isCover => position == 0;

  /// Creates a MarketplacePhoto from Supabase JSON row.
  factory MarketplacePhoto.fromJson(Map<String, dynamic> json) {
    return MarketplacePhoto(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      storagePath: json['storage_path'] as String,
      thumbnailPath: json['thumbnail_path'] as String?,
      position: json['position'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts to JSON for database insert (excludes auto-generated fields).
  Map<String, dynamic> toJson() {
    return {
      'listing_id': listingId,
      'storage_path': storagePath,
      'thumbnail_path': thumbnailPath,
      'position': position,
    };
  }

  /// Equality based on id.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplacePhoto &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// String representation for debugging.
  @override
  String toString() =>
      'MarketplacePhoto(id: $id, listingId: $listingId, '
      'position: $position, storagePath: $storagePath)';

  /// Creates a copy with updated fields.
  MarketplacePhoto copyWith({
    String? id,
    String? listingId,
    String? storagePath,
    String? thumbnailPath,
    int? position,
    DateTime? createdAt,
  }) {
    return MarketplacePhoto(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      storagePath: storagePath ?? this.storagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
