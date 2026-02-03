/// Photo Share entity for tracking shared photos with wedding guests.
///
/// Represents a record of a photo or video that has been shared
/// by the bride with her wedding guests.
library;

import 'package:flutter/foundation.dart';

/// Type of media being shared.
///
/// Determines which table the media_id references.
enum MediaShareType {
  /// Image from inspiration albums (album_images table)
  albumImage('album_image'),

  /// Media uploaded by guests (guest_media table)
  guestMedia('guest_media');

  const MediaShareType(this.value);

  /// String value stored in database.
  final String value;

  /// Creates MediaShareType from string value.
  ///
  /// Returns [albumImage] for unknown values.
  static MediaShareType fromString(String? value) {
    return MediaShareType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MediaShareType.albumImage,
    );
  }
}

/// Photo Share entity - tracks photos shared with wedding guests.
@immutable
class PhotoShare {
  /// Creates a PhotoShare instance.
  const PhotoShare({
    required this.id,
    required this.weddingId,
    required this.mediaType,
    required this.mediaId,
    required this.sharedBy,
    required this.sharedAt,
  });

  /// UUID of this share record.
  final String id;

  /// UUID of the wedding this share belongs to.
  final String weddingId;

  /// Type of media: album_image or guest_media.
  final MediaShareType mediaType;

  /// UUID of the media item in the respective table.
  final String mediaId;

  /// UUID of the user who shared (bride).
  final String sharedBy;

  /// Timestamp when the media was shared.
  final DateTime sharedAt;

  /// Returns true if this is an album image share.
  bool get isAlbumImage => mediaType == MediaShareType.albumImage;

  /// Returns true if this is a guest media share.
  bool get isGuestMedia => mediaType == MediaShareType.guestMedia;

  /// Factory from Supabase JSON.
  factory PhotoShare.fromJson(Map<String, dynamic> json) {
    return PhotoShare(
      id: json['id'] as String,
      weddingId: json['wedding_id'] as String,
      mediaType: MediaShareType.fromString(json['media_type'] as String?),
      mediaId: json['media_id'] as String,
      sharedBy: json['shared_by'] as String,
      sharedAt: DateTime.parse(json['shared_at'] as String),
    );
  }

  /// Converts to JSON for Supabase insert.
  ///
  /// Does not include id (server generates it).
  Map<String, dynamic> toJson() {
    return {
      'wedding_id': weddingId,
      'media_type': mediaType.value,
      'media_id': mediaId,
      'shared_by': sharedBy,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotoShare && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PhotoShare($id, ${mediaType.value})';
}
