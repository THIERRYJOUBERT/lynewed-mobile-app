/// Guest Media entity for photos and videos uploaded by guests.
///
/// Represents a media file (photo/video) in a guest's personal album.
library;

import 'package:flutter/foundation.dart';

/// Represents a media file (photo/video) uploaded by a guest.
///
/// Each guest has one album per wedding. Media files are stored in:
/// `wedding-albums/{wedding_id}/guests/{guest_user_id}/{filename}`
@immutable
class GuestMedia {
  /// Creates a GuestMedia entity.
  const GuestMedia({
    required this.id,
    required this.albumId,
    required this.mediaType,
    required this.storagePath,
    this.thumbnailPath,
    this.caption,
    this.durationSeconds,
    this.fileSizeBytes,
    required this.createdAt,
  });

  /// Unique identifier for this media.
  final String id;

  /// ID of the album this media belongs to.
  final String albumId;

  /// Type of media: 'photo' or 'video'.
  final String mediaType;

  /// Storage path in Supabase Storage.
  final String storagePath;

  /// Thumbnail path for videos (optional).
  final String? thumbnailPath;

  /// User-provided caption (max 500 characters).
  final String? caption;

  /// Duration in seconds for videos only.
  final int? durationSeconds;

  /// File size in bytes.
  final int? fileSizeBytes;

  /// When the media was uploaded.
  final DateTime createdAt;

  /// Returns true if this media is a video.
  bool get isVideo => mediaType == 'video';

  /// Returns true if this media is a photo.
  bool get isPhoto => mediaType == 'photo';

  /// Constructs the full storage URL from a base URL.
  String getFullUrl(String bucketBaseUrl) {
    return '$bucketBaseUrl/$storagePath';
  }

  /// Constructs the full thumbnail URL if available.
  String? getThumbnailUrl(String bucketBaseUrl) {
    if (thumbnailPath == null) return null;
    return '$bucketBaseUrl/$thumbnailPath';
  }

  /// Factory from Supabase JSON.
  factory GuestMedia.fromJson(Map<String, dynamic> json) {
    return GuestMedia(
      id: json['id'] as String,
      albumId: json['album_id'] as String,
      mediaType: json['media_type'] as String,
      storagePath: json['storage_path'] as String,
      thumbnailPath: json['thumbnail_path'] as String?,
      caption: json['caption'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      fileSizeBytes: json['file_size_bytes'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts to JSON for Supabase insert.
  Map<String, dynamic> toJson() {
    return {
      'album_id': albumId,
      'media_type': mediaType,
      'storage_path': storagePath,
      'thumbnail_path': thumbnailPath,
      'caption': caption,
      'duration_seconds': durationSeconds,
      'file_size_bytes': fileSizeBytes,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuestMedia && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GuestMedia($id, $mediaType)';
}
