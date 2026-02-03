/// Guest Album Model for data layer.
///
/// Extends GuestAlbum entity with JSON serialization for Supabase.
library;

import '../../domain/entities/guest_album.dart';

/// Data model for GuestAlbum with Supabase serialization.
class GuestAlbumModel extends GuestAlbum {
  /// Creates a GuestAlbumModel.
  const GuestAlbumModel({
    required super.id,
    required super.weddingId,
    required super.guestUserId,
    required super.guestName,
    super.guestAvatarUrl,
    required super.photoCount,
    required super.videoCount,
    super.thumbnailUrl,
    required super.createdAt,
  });

  /// Creates a GuestAlbumModel from Supabase JSON.
  ///
  /// Expects a structure like:
  /// ```json
  /// {
  ///   "id": "album-id",
  ///   "wedding_id": "wedding-id",
  ///   "guest_user_id": "user-id",
  ///   "created_at": "2026-01-01T00:00:00Z",
  ///   "profiles": {
  ///     "first_name": "Alice",
  ///     "last_name": "Smith",
  ///     "avatar_url": "https://..."
  ///   },
  ///   "photo_count": 5,
  ///   "video_count": 2,
  ///   "thumbnail_url": "https://..."
  /// }
  /// ```
  factory GuestAlbumModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    return GuestAlbumModel(
      id: json['id'] as String,
      weddingId: json['wedding_id'] as String,
      guestUserId: json['guest_user_id'] as String,
      guestName: _buildGuestName(profile),
      guestAvatarUrl: profile?['avatar_url'] as String?,
      photoCount: json['photo_count'] as int? ?? 0,
      videoCount: json['video_count'] as int? ?? 0,
      thumbnailUrl: json['thumbnail_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Builds the guest's display name from profile data.
  ///
  /// Combines first_name and last_name, falling back to "Guest" if empty.
  static String _buildGuestName(Map<String, dynamic>? profile) {
    if (profile == null) return 'Guest';

    final firstName = profile['first_name'] as String? ?? '';
    final lastName = profile['last_name'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();

    return fullName.isEmpty ? 'Guest' : fullName;
  }
}
