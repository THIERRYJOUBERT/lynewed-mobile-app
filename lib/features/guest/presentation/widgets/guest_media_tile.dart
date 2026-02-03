/// Guest Media Tile Widget.
///
/// Displays a single media item in the guest album grid.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/design/design.dart';
import '../../domain/entities/guest_media.dart';

/// Displays a single media tile in the guest album grid.
///
/// Shows:
/// - Thumbnail image for photos and videos
/// - Play icon overlay for videos
/// - Timestamp badge showing upload time
/// - Supports tap and long-press gestures
class GuestMediaTile extends StatelessWidget {
  /// Creates a guest media tile.
  const GuestMediaTile({
    super.key,
    required this.media,
    this.onTap,
    this.onLongPress,
    this.showTimestamp = true,
  });

  /// The media to display.
  final GuestMedia media;

  /// Callback when the tile is tapped.
  final VoidCallback? onTap;

  /// Callback when the tile is long-pressed.
  final VoidCallback? onLongPress;

  /// Whether to show timestamp badge.
  final bool showTimestamp;

  /// Storage bucket base URL.
  String get _bucketBaseUrl {
    final supabase = Supabase.instance.client;
    return supabase.storage.from('wedding-albums').getPublicUrl('');
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail image
          if (imageUrl != null)
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: LynewedColors.gray200,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(LynewedColors.gray300),
                    ),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: LynewedColors.gray200,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: LynewedColors.gray300,
                ),
              ),
            )
          else
            Container(
              color: LynewedColors.gray200,
              child: Icon(
                media.isVideo ? Icons.videocam : Icons.image,
                color: LynewedColors.gray300,
              ),
            ),

          // Video play icon overlay
          if (media.isVideo)
            Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),

          // Timestamp badge
          if (showTimestamp)
            Positioned(
              left: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatRelativeTime(media.createdAt),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Gets the URL for the image to display.
  ///
  /// For videos, prefers thumbnail if available.
  /// For photos, uses the storage path directly.
  String? _getImageUrl() {
    final baseUrl = _bucketBaseUrl;

    // For videos, prefer thumbnail
    if (media.isVideo && media.thumbnailPath != null) {
      return '$baseUrl${media.thumbnailPath}';
    }

    // Use main storage path
    return '$baseUrl${media.storagePath}';
  }

  /// Formats a DateTime as relative time string.
  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      // Format as "Jan 15"
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}';
    }
  }
}
