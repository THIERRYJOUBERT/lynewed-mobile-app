/// Guest Album entity for the bride's view of guest albums.
///
/// Represents a guest's album containing photos and videos from the wedding.
/// Each guest has exactly one album per wedding.
library;

import 'package:flutter/foundation.dart';

/// Represents a guest's album for the bride's view.
///
/// Each guest has exactly one album per wedding.
/// The bride sees ALL albums automatically (no opt-in required).
@immutable
class GuestAlbum {
  /// Creates a GuestAlbum entity.
  const GuestAlbum({
    required this.id,
    required this.weddingId,
    required this.guestUserId,
    required this.guestName,
    this.guestAvatarUrl,
    required this.photoCount,
    required this.videoCount,
    this.thumbnailUrl,
    required this.createdAt,
  });

  /// Unique identifier for this album.
  final String id;

  /// ID of the wedding this album belongs to.
  final String weddingId;

  /// ID of the guest who owns this album.
  final String guestUserId;

  /// Display name of the guest.
  final String guestName;

  /// Avatar URL of the guest (optional).
  final String? guestAvatarUrl;

  /// Number of photos in the album.
  final int photoCount;

  /// Number of videos in the album.
  final int videoCount;

  /// Thumbnail URL from the first media (optional).
  final String? thumbnailUrl;

  /// When the album was created.
  final DateTime createdAt;

  /// Returns the total number of media items.
  int get totalMediaCount => photoCount + videoCount;

  /// Returns true if the album has no media.
  bool get isEmpty => totalMediaCount == 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuestAlbum &&
        other.id == id &&
        other.weddingId == weddingId &&
        other.guestUserId == guestUserId &&
        other.photoCount == photoCount &&
        other.videoCount == videoCount;
  }

  @override
  int get hashCode => Object.hash(
        id,
        weddingId,
        guestUserId,
        photoCount,
        videoCount,
      );

  @override
  String toString() => 'GuestAlbum($id, $guestName, $totalMediaCount media)';
}
