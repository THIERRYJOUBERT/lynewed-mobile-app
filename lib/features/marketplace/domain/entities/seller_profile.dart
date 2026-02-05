/// SellerProfile entity - A marketplace seller's public profile.
///
/// Immutable data class for displaying seller info on listing detail pages.
library;

import 'package:flutter/foundation.dart';

/// Represents a marketplace seller's public profile.
///
/// Contains the seller's display name, optional avatar, and listing count.
/// Used by the listing detail page to show seller information.
@immutable
class SellerProfile {
  /// Creates a seller profile.
  const SellerProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.listingsCount,
  });

  /// Seller ID (references profiles table).
  final String id;

  /// Display name.
  final String name;

  /// Avatar URL (optional).
  final String? avatarUrl;

  /// Number of active listings.
  final int listingsCount;

  /// Creates a SellerProfile from Supabase JSON row.
  factory SellerProfile.fromJson(Map<String, dynamic> json) {
    return SellerProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      listingsCount: json['listings_count'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SellerProfile &&
        other.id == id &&
        other.name == name &&
        other.avatarUrl == avatarUrl &&
        other.listingsCount == listingsCount;
  }

  @override
  int get hashCode => Object.hash(id, name, avatarUrl, listingsCount);

  @override
  String toString() => 'SellerProfile(id: $id, name: $name)';

  /// Creates a copy with updated fields.
  SellerProfile copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    int? listingsCount,
  }) {
    return SellerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      listingsCount: listingsCount ?? this.listingsCount,
    );
  }
}
