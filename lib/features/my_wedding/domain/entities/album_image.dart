/// Album Image entity for My Wedding Suite
///
/// Represents an image or video uploaded from gallery to an inspiration album.
/// Supports both photos and videos with metadata like duration and file size.
library;

import 'package:flutter/foundation.dart';

/// Album Image entity - supports photos and videos
@immutable
class AlbumImage {
  const AlbumImage({
    required this.id,
    required this.albumId,
    required this.imageUrl,
    this.thumbnailUrl,
    this.uploadedAt,
    this.mediaType = 'photo',
    this.caption,
    this.durationSeconds,
    this.fileSizeBytes,
  });

  /// UUID of the album image
  final String id;

  /// UUID of the album
  final String albumId;

  /// Full image/video URL
  final String imageUrl;

  /// Thumbnail URL (for both images and videos)
  final String? thumbnailUrl;

  /// Upload date
  final DateTime? uploadedAt;

  /// Media type: 'photo' or 'video'
  final String mediaType;

  /// Optional caption for the media
  final String? caption;

  /// Video duration in seconds (null for photos)
  final int? durationSeconds;

  /// File size in bytes
  final int? fileSizeBytes;

  /// Returns true if this is a video
  bool get isVideo => mediaType == 'video';

  /// Returns true if this is a photo
  bool get isPhoto => mediaType == 'photo';

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
      mediaType: json['media_type'] as String? ?? 'photo',
      caption: json['caption'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      fileSizeBytes: json['file_size_bytes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'album_id': albumId,
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'media_type': mediaType,
      'caption': caption,
      'duration_seconds': durationSeconds,
      'file_size_bytes': fileSizeBytes,
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
  String toString() => 'AlbumImage($id, $mediaType)';
}
