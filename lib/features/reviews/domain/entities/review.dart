/// Review entity - Client review for a professional
///
/// Immutable data class representing a review submitted by a bride
/// for a wedding professional.
library;

import 'package:flutter/foundation.dart';

/// Represents a review submitted by a bride for a professional.
///
/// Contains rating (1-5), optional comment, and metadata about
/// the review (timestamps, bride info for display).
@immutable
class Review {
  /// Creates a review.
  const Review({
    required this.id,
    required this.proId,
    required this.brideId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
    this.brideName,
    this.brideAvatarUrl,
  });

  /// Unique identifier (UUID from database).
  final String id;

  /// Professional ID this review is for.
  final String proId;

  /// Bride ID who submitted this review.
  final String brideId;

  /// Rating from 1 to 5.
  final int rating;

  /// Optional text comment.
  final String? comment;

  /// When the review was created.
  final DateTime createdAt;

  /// When the review was last updated (optional).
  final DateTime? updatedAt;

  /// Bride's display name (joined from profiles).
  final String? brideName;

  /// Bride's avatar URL (joined from profiles).
  final String? brideAvatarUrl;

  /// Whether the review has a non-empty comment.
  bool get hasComment => comment != null && comment!.isNotEmpty;

  /// Returns a human-readable time difference from creation.
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? '1 day ago' : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? '1 minute ago' : '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }

  /// Creates a Review from Supabase JSON row.
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      proId: json['pro_id'] as String,
      brideId: json['bride_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      brideName: json['bride_name'] as String?,
      brideAvatarUrl: json['bride_avatar_url'] as String?,
    );
  }

  /// Converts to JSON for database insert (excludes auto-generated fields).
  Map<String, dynamic> toJson() {
    return {
      'pro_id': proId,
      'bride_id': brideId,
      'rating': rating,
      'comment': comment,
    };
  }

  /// Creates a copy with updated fields.
  Review copyWith({
    String? id,
    String? proId,
    String? brideId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? brideName,
    String? brideAvatarUrl,
  }) {
    return Review(
      id: id ?? this.id,
      proId: proId ?? this.proId,
      brideId: brideId ?? this.brideId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      brideName: brideName ?? this.brideName,
      brideAvatarUrl: brideAvatarUrl ?? this.brideAvatarUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review &&
        other.id == id &&
        other.proId == proId &&
        other.brideId == brideId &&
        other.rating == rating &&
        other.comment == comment &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.brideName == brideName &&
        other.brideAvatarUrl == brideAvatarUrl;
  }

  @override
  int get hashCode => Object.hash(
        id,
        proId,
        brideId,
        rating,
        comment,
        createdAt,
        updatedAt,
        brideName,
        brideAvatarUrl,
      );

  @override
  String toString() => 'Review($id, rating: $rating)';
}
