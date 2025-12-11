/// Album Image entity for My Wedding Suite
///
/// Represents an image uploaded from gallery to an inspiration album.
library;

import 'package:flutter/foundation.dart';

/// Album Image entity
@immutable
class AlbumImage {
  const AlbumImage({
    required this.id,
    required this.albumId,
    required this.imageUrl,
    this.thumbnailUrl,
    this.uploadedAt,
  });

  /// UUID of the album image
  final String id;

  /// UUID of the album
  final String albumId;

  /// Full image URL
  final String imageUrl;

  /// Thumbnail URL
  final String? thumbnailUrl;

  /// Upload date
  final DateTime? uploadedAt;

  /// Factory from Supabase JSON
  factory AlbumImage.fromJson(Map<String, dynamic> json) {
    return AlbumImage(
      id: json['id'] as String,
      albumId: json['album_id'] as String,
      imageUrl: json['image_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      uploadedAt: json['uploaded_at'] != null 
          ? DateTime.parse(json['uploaded_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'album_id': albumId,
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlbumImage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AlbumImage($id)';
}
