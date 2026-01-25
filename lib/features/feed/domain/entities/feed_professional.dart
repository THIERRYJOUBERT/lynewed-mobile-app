/// Feed Professional entity for Feed feature
///
/// Represents a professional with their portfolio in the bride's feed.
library;

import 'package:flutter/foundation.dart';

import 'portfolio_item.dart';

/// Feed Professional entity
@immutable
class FeedProfessional {
  const FeedProfessional({
    required this.profileId,
    required this.displayName,
    required this.profession,
    this.avatarUrl,
    this.portfolioItems = const [],
    this.isFavorited = false,
  });

  /// UUID of the professional's profile
  final String profileId;

  /// Display name of the professional
  final String displayName;

  /// Avatar URL
  final String? avatarUrl;

  /// Profession type (e.g., 'photographer', 'florist')
  final String profession;

  /// List of portfolio items
  final List<PortfolioItem> portfolioItems;

  /// Whether the bride has favorited this professional
  final bool isFavorited;

  /// Whether the professional has any portfolio items
  bool get hasPortfolio => portfolioItems.isNotEmpty;

  /// Number of portfolio items
  int get portfolioCount => portfolioItems.length;

  /// Display-friendly profession name with capitalized first letter
  String get displayProfession {
    if (profession.isEmpty) return '';
    final cleaned = profession.replaceAll('_', ' ');
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  /// Factory from Supabase JSON
  factory FeedProfessional.fromJson(Map<String, dynamic> json) {
    final itemsList = json['portfolio_items'] as List<dynamic>?;
    final items = itemsList != null
        ? itemsList
            .map((item) =>
                PortfolioItem.fromJson(item as Map<String, dynamic>))
            .toList()
        : <PortfolioItem>[];

    return FeedProfessional(
      profileId: json['profile_id'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      profession: json['profession'] as String,
      portfolioItems: items,
      isFavorited: json['is_favorited'] as bool? ?? false,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'profession': profession,
      'portfolio_items': portfolioItems.map((item) => item.toJson()).toList(),
      'is_favorited': isFavorited,
    };
  }

  /// Create a copy with updated values
  FeedProfessional copyWith({
    String? profileId,
    String? displayName,
    String? avatarUrl,
    String? profession,
    List<PortfolioItem>? portfolioItems,
    bool? isFavorited,
  }) {
    return FeedProfessional(
      profileId: profileId ?? this.profileId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      profession: profession ?? this.profession,
      portfolioItems: portfolioItems ?? this.portfolioItems,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedProfessional &&
        other.profileId == profileId &&
        other.displayName == displayName &&
        other.avatarUrl == avatarUrl &&
        other.profession == profession &&
        listEquals(other.portfolioItems, portfolioItems) &&
        other.isFavorited == isFavorited;
  }

  @override
  int get hashCode => Object.hash(
        profileId,
        displayName,
        avatarUrl,
        profession,
        Object.hashAll(portfolioItems),
        isFavorited,
      );

  @override
  String toString() => 'FeedProfessional($profileId, $displayName)';
}
