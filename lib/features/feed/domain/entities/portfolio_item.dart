/// Portfolio Item entity for Feed feature
///
/// Represents a single image in a professional's portfolio.
library;

import 'package:flutter/foundation.dart';

/// Portfolio Item entity
@immutable
class PortfolioItem {
  const PortfolioItem({
    required this.id,
    required this.imageUrl,
    required this.professionalId,
    required this.createdAt,
    this.caption,
  });

  /// UUID of the portfolio item
  final String id;

  /// URL of the portfolio image
  final String imageUrl;

  /// UUID of the professional who owns this item
  final String professionalId;

  /// Optional caption for the image
  final String? caption;

  /// Creation date
  final DateTime createdAt;

  /// Factory from Supabase JSON
  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      professionalId: json['professional_id'] as String,
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'professional_id': professionalId,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with updated values
  PortfolioItem copyWith({
    String? id,
    String? imageUrl,
    String? professionalId,
    String? caption,
    DateTime? createdAt,
  }) {
    return PortfolioItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      professionalId: professionalId ?? this.professionalId,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortfolioItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PortfolioItem($id, $professionalId)';
}
