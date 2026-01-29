/// ProRating entity - Aggregated rating for a professional
///
/// Immutable data class representing the aggregated rating
/// and review count for a wedding professional.
library;

import 'package:flutter/foundation.dart';

/// Represents aggregated rating data for a professional.
///
/// Contains average rating (1.0-5.0) and total review count.
/// Used for displaying rating summary on professional profiles.
@immutable
class ProRating {
  /// Creates a pro rating.
  const ProRating({
    required this.proId,
    required this.averageRating,
    required this.reviewCount,
  });

  /// Professional ID.
  final String proId;

  /// Average rating from 1.0 to 5.0.
  final double averageRating;

  /// Total number of reviews.
  final int reviewCount;

  /// Returns formatted rating string: "4.5/5 (12 reviews)"
  String get displayRating {
    final reviewText = reviewCount == 1 ? 'review' : 'reviews';
    return '${averageRating.toStringAsFixed(1)}/5 ($reviewCount $reviewText)';
  }

  /// Returns just the rating number: "4.5"
  String get shortRating => averageRating.toStringAsFixed(1);

  /// Whether this professional has any reviews.
  bool get hasReviews => reviewCount > 0;

  /// Creates a ProRating from Supabase JSON (pro_ratings view).
  factory ProRating.fromJson(Map<String, dynamic> json) {
    return ProRating(
      proId: json['pro_id'] as String,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as int?) ?? 0,
    );
  }

  /// Creates an empty ProRating for a professional with no reviews.
  factory ProRating.empty(String proId) {
    return ProRating(
      proId: proId,
      averageRating: 0.0,
      reviewCount: 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProRating &&
        other.proId == proId &&
        other.averageRating == averageRating &&
        other.reviewCount == reviewCount;
  }

  @override
  int get hashCode => Object.hash(proId, averageRating, reviewCount);

  @override
  String toString() =>
      'ProRating($proId, average: $averageRating, count: $reviewCount)';
}
