/// Inspiration Album entity for My Wedding Suite
///
/// Represents a moodboard album for wedding inspiration.
/// Can be private (bride only) or shared with wedding team.
library;

import 'package:flutter/foundation.dart';

/// Album category enum
enum AlbumCategory {
  dress,
  decor,
  flowers,
  venue,
  beauty,
  photos,
  stationery,
  general,
  custom,
}

/// Inspiration Album entity
@immutable
class InspirationAlbum {
  const InspirationAlbum({
    required this.id,
    required this.weddingId,
    required this.brideProfileId,
    required this.name,
    this.coverImageUrl,
    this.category = AlbumCategory.general,
    this.customCategory,
    this.isPrivate = false,
    this.sortOrder = 0,
    this.imagesCount = 0,
    this.createdAt,
  });

  /// UUID of the album
  final String id;

  /// UUID of the wedding
  final String weddingId;

  /// UUID of the bride owner
  final String brideProfileId;

  /// Album name
  final String name;

  /// Cover image URL
  final String? coverImageUrl;

  /// Album category
  final AlbumCategory category;

  /// Custom category name (if category is custom)
  final String? customCategory;

  /// Is private (bride only) or shared with team
  final bool isPrivate;

  /// Sort order for display
  final int sortOrder;

  /// Number of images in the album
  final int imagesCount;

  /// Creation date
  final DateTime? createdAt;

  /// Display category name
  String get displayCategory {
    if (category == AlbumCategory.custom && customCategory != null) {
      return customCategory!;
    }
    return category.name.replaceFirst(category.name[0], category.name[0].toUpperCase());
  }

  /// Factory from Supabase JSON
  factory InspirationAlbum.fromJson(Map<String, dynamic> json) {
    return InspirationAlbum(
      id: json['id'] as String,
      weddingId: json['wedding_id'] as String,
      brideProfileId: json['bride_profile_id'] as String,
      name: json['name'] as String,
      coverImageUrl: json['cover_image_url'] as String?,
      category: _parseCategory(json['category'] as String?),
      customCategory: json['custom_category'] as String?,
      isPrivate: json['is_private'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      imagesCount: json['images_count'] as int? ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
    );
  }

  static AlbumCategory _parseCategory(String? value) {
    switch (value) {
      case 'dress':
        return AlbumCategory.dress;
      case 'decor':
        return AlbumCategory.decor;
      case 'flowers':
        return AlbumCategory.flowers;
      case 'venue':
        return AlbumCategory.venue;
      case 'beauty':
        return AlbumCategory.beauty;
      case 'photos':
        return AlbumCategory.photos;
      case 'stationery':
        return AlbumCategory.stationery;
      case 'custom':
        return AlbumCategory.custom;
      default:
        return AlbumCategory.general;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'wedding_id': weddingId,
      'bride_profile_id': brideProfileId,
      'name': name,
      'cover_image_url': coverImageUrl,
      'category': category.name,
      'custom_category': customCategory,
      'is_private': isPrivate,
      'sort_order': sortOrder,
    };
  }

  InspirationAlbum copyWith({
    String? id,
    String? weddingId,
    String? brideProfileId,
    String? name,
    String? coverImageUrl,
    AlbumCategory? category,
    String? customCategory,
    bool? isPrivate,
    int? sortOrder,
    int? imagesCount,
    DateTime? createdAt,
  }) {
    return InspirationAlbum(
      id: id ?? this.id,
      weddingId: weddingId ?? this.weddingId,
      brideProfileId: brideProfileId ?? this.brideProfileId,
      name: name ?? this.name,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      category: category ?? this.category,
      customCategory: customCategory ?? this.customCategory,
      isPrivate: isPrivate ?? this.isPrivate,
      sortOrder: sortOrder ?? this.sortOrder,
      imagesCount: imagesCount ?? this.imagesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InspirationAlbum && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'InspirationAlbum($id, $name)';
}
