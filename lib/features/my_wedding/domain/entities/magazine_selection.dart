/// Magazine Selection entity for wedding photo magazines.
///
/// Represents a photo selected for inclusion in a printed wedding magazine.
/// Stores the position for ordering and references to the source media.
library;

import 'package:flutter/foundation.dart';

/// Magazine Selection entity - a photo selected for a wedding magazine.
@immutable
class MagazineSelection {
  /// Creates a magazine selection.
  const MagazineSelection({
    required this.id,
    required this.weddingId,
    required this.userId,
    required this.mediaType,
    required this.mediaId,
    required this.position,
    required this.createdAt,
    this.thumbnailUrl,
  });

  /// UUID of this selection.
  final String id;

  /// UUID of the wedding this magazine belongs to.
  final String weddingId;

  /// UUID of the user who selected this photo.
  final String userId;

  /// Type of media: 'album_image' or 'guest_media'.
  final String mediaType;

  /// UUID of the source media (album_images.id or guest_media.id).
  final String mediaId;

  /// Position in the magazine (1-indexed).
  final int position;

  /// When this photo was added to the magazine.
  final DateTime createdAt;

  /// Optional thumbnail URL for display (populated from join).
  final String? thumbnailUrl;

  /// Maximum photos allowed in a COLLECTOR format magazine.
  static const int maxPhotosCollector = 60;

  /// Maximum photos allowed in a CLASSIC format magazine.
  static const int maxPhotosClassic = 30;

  /// Factory from Supabase JSON.
  factory MagazineSelection.fromJson(Map<String, dynamic> json) {
    return MagazineSelection(
      id: json['id'] as String,
      weddingId: json['wedding_id'] as String,
      userId: json['user_id'] as String,
      mediaType: json['media_type'] as String,
      mediaId: json['media_id'] as String,
      position: json['position'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }

  /// Converts to JSON for Supabase insert.
  Map<String, dynamic> toJson() {
    return {
      'wedding_id': weddingId,
      'user_id': userId,
      'media_type': mediaType,
      'media_id': mediaId,
      'position': position,
    };
  }

  /// Creates a copy with updated values.
  MagazineSelection copyWith({
    String? id,
    String? weddingId,
    String? userId,
    String? mediaType,
    String? mediaId,
    int? position,
    DateTime? createdAt,
    String? thumbnailUrl,
  }) {
    return MagazineSelection(
      id: id ?? this.id,
      weddingId: weddingId ?? this.weddingId,
      userId: userId ?? this.userId,
      mediaType: mediaType ?? this.mediaType,
      mediaId: mediaId ?? this.mediaId,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MagazineSelection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MagazineSelection($id, position: $position)';
}
