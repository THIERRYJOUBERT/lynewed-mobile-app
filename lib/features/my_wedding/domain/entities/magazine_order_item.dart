/// Magazine Order Item entity.
///
/// Represents a photo snapshot in a completed magazine order.
/// Stored in the magazine_order_items table with frozen URLs.
library;

/// A single photo item in a magazine order.
class MagazineOrderItem {
  /// Creates a magazine order item.
  const MagazineOrderItem({
    required this.id,
    required this.orderId,
    required this.mediaType,
    required this.mediaId,
    required this.position,
    required this.storageUrl,
    this.caption,
  });

  /// Item ID.
  final String id;

  /// Parent order ID.
  final String orderId;

  /// Media type: 'album_image' or 'guest_media'.
  final String mediaType;

  /// Original media ID (reference only).
  final String mediaId;

  /// Position in the magazine (1-indexed).
  final int position;

  /// Storage URL or path for the photo.
  ///
  /// For album_image: full public URL.
  /// For guest_media: relative storage path (needs URL resolution).
  final String storageUrl;

  /// Optional caption text.
  final String? caption;

  /// Whether this is a guest media item (needs URL resolution).
  bool get isGuestMedia => mediaType == 'guest_media';

  /// Whether the storage URL is already a full URL.
  bool get hasFullUrl => storageUrl.startsWith('http');

  /// Creates from Supabase JSON row.
  factory MagazineOrderItem.fromJson(Map<String, dynamic> json) {
    return MagazineOrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      mediaType: json['media_type'] as String,
      mediaId: json['media_id'] as String,
      position: json['position'] as int,
      storageUrl: json['storage_url'] as String,
      caption: json['caption'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MagazineOrderItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
