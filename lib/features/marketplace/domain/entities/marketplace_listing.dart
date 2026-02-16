/// MarketplaceListing entity - A wedding dress or shoes listing
///
/// Immutable data class representing a marketplace item (dress or shoes)
/// listed for sale by a bride.
library;

import 'package:flutter/foundation.dart';

/// Represents a marketplace listing for wedding dress or shoes.
///
/// Contains product details, pricing, location, and status.
@immutable
class MarketplaceListing {
  /// Creates a marketplace listing.
  const MarketplaceListing({
    required this.id,
    required this.sellerId,
    required this.title,
    this.description,
    required this.category,
    required this.priceCents,
    this.displayCurrency = 'USD',
    this.designerBrand,
    this.size,
    required this.condition,
    this.sleeveLength,
    this.city,
    required this.country,
    this.countryCode,
    this.latitude,
    this.longitude,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.soldAt,
    this.coverPhotoStoragePath,
    this.weightKg,
  });

  /// Unique identifier (UUID from database).
  final String id;

  /// Seller ID (profile UUID).
  final String sellerId;

  /// Listing title (max 255 chars).
  final String title;

  /// Optional description.
  final String? description;

  /// Category: 'dress' or 'shoes'.
  final String category;

  /// Price in cents (e.g., 29999 = $299.99).
  final int priceCents;

  /// Display currency (default USD).
  final String displayCurrency;

  /// Optional designer/brand.
  final String? designerBrand;

  /// Optional size.
  final String? size;

  /// Condition: 'new', 'excellent', 'good', or 'fair'.
  final String condition;

  /// Sleeve length (required for dresses, null for shoes).
  final String? sleeveLength;

  /// City (optional).
  final String? city;

  /// Country (required).
  final String country;

  /// Country code (2 chars).
  final String? countryCode;

  /// Latitude (for geospatial queries).
  final double? latitude;

  /// Longitude (for geospatial queries).
  final double? longitude;

  /// Status: 'draft', 'active', 'reserved', 'sold', 'deleted'.
  final String status;

  /// When the listing was created.
  final DateTime createdAt;

  /// When the listing was last updated.
  final DateTime updatedAt;

  /// When the listing was sold (if applicable).
  final DateTime? soldAt;

  /// Cover photo storage path (from joined marketplace_photos query).
  ///
  /// This is populated by queries that join marketplace_photos (e.g., feed).
  /// The path can be used to construct a public URL via Supabase storage.
  final String? coverPhotoStoragePath;

  /// Item weight in kilograms (optional).
  ///
  /// If null, FedEx API will use category defaults:
  /// - dress: 3.0 kg
  /// - shoes: 2.0 kg
  ///
  /// Valid range: 0.1 - 50.0 kg (enforced by DB constraint).
  final double? weightKg;

  /// Price formatted as dollars (e.g., 29999 -> 299.99).
  double get priceInDollars => priceCents / 100;

  /// Whether this listing is for a dress.
  bool get isDress => category == 'dress';

  /// Whether this listing is for shoes.
  bool get isShoes => category == 'shoes';

  /// Whether this listing is currently active and visible.
  bool get isActive => status == 'active';

  /// Creates a MarketplaceListing from Supabase JSON row.
  ///
  /// If the query joins marketplace_photos, the cover photo (position 0)
  /// storage path is extracted and stored in [coverPhotoStoragePath].
  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    // Extract cover photo path from joined marketplace_photos if present.
    String? coverPath;
    final photos = json['marketplace_photos'];
    if (photos is List && photos.isNotEmpty) {
      // Find the photo with position 0 (cover), or use the first one.
      final coverPhoto = photos.cast<Map<String, dynamic>>().firstWhere(
            (p) => p['position'] == 0,
            orElse: () => photos.first as Map<String, dynamic>,
          );
      coverPath = coverPhoto['storage_path'] as String?;
    }

    return MarketplaceListing(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      priceCents: json['price_cents'] as int,
      displayCurrency: json['display_currency'] as String? ?? 'USD',
      designerBrand: json['designer_brand'] as String?,
      size: json['size'] as String?,
      condition: json['condition'] as String,
      sleeveLength: json['sleeve_length'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String,
      countryCode: json['country_code'] as String?,
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      soldAt: json['sold_at'] != null
          ? DateTime.parse(json['sold_at'] as String)
          : null,
      coverPhotoStoragePath: coverPath,
      weightKg: json['weight_kg'] != null
          ? double.parse(json['weight_kg'].toString())
          : null,
    );
  }

  /// Converts to JSON for database insert (excludes auto-generated fields).
  Map<String, dynamic> toJson() {
    return {
      'seller_id': sellerId,
      'title': title,
      'description': description,
      'category': category,
      'price_cents': priceCents,
      'display_currency': displayCurrency,
      'designer_brand': designerBrand,
      'size': size,
      'condition': condition,
      'sleeve_length': sleeveLength,
      'city': city,
      'country': country,
      'country_code': countryCode,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      if (weightKg != null) 'weight_kg': weightKg,
    };
  }

  /// Equality based on id.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplaceListing &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// String representation for debugging.
  @override
  String toString() =>
      'MarketplaceListing(id: $id, title: $title, category: $category, '
      'priceCents: $priceCents, status: $status)';

  /// Creates a copy with updated fields.
  MarketplaceListing copyWith({
    String? id,
    String? sellerId,
    String? title,
    String? description,
    String? category,
    int? priceCents,
    String? displayCurrency,
    String? designerBrand,
    String? size,
    String? condition,
    String? sleeveLength,
    String? city,
    String? country,
    String? countryCode,
    double? latitude,
    double? longitude,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? soldAt,
    String? coverPhotoStoragePath,
    double? weightKg,
  }) {
    return MarketplaceListing(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priceCents: priceCents ?? this.priceCents,
      displayCurrency: displayCurrency ?? this.displayCurrency,
      designerBrand: designerBrand ?? this.designerBrand,
      size: size ?? this.size,
      condition: condition ?? this.condition,
      sleeveLength: sleeveLength ?? this.sleeveLength,
      city: city ?? this.city,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      soldAt: soldAt ?? this.soldAt,
      coverPhotoStoragePath:
          coverPhotoStoragePath ?? this.coverPhotoStoragePath,
      weightKg: weightKg ?? this.weightKg,
    );
  }
}
