/// Guest Media Tile Widget.
///
/// Displays a single media item in the guest album masonry grid.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/design/design.dart';
import '../../domain/entities/guest_media.dart';

/// Displays a single media tile in the guest album masonry grid.
///
/// Shows:
/// - Thumbnail image for photos and videos
/// - Play icon overlay for videos
/// - Favorite badge when bride has liked the media
/// - Caption indicator when caption exists
/// - Supports tap and long-press gestures
/// - Variable aspect ratio for masonry layout
class GuestMediaTile extends StatelessWidget {
  /// Creates a guest media tile.
  const GuestMediaTile({
    super.key,
    required this.media,
    this.onTap,
    this.onLongPress,
    this.isFavorited = false,
    this.isHero = false,
  });

  /// The media to display.
  final GuestMedia media;

  /// Callback when the tile is tapped.
  final VoidCallback? onTap;

  /// Callback when the tile is long-pressed.
  final VoidCallback? onLongPress;

  /// Whether the bride has favorited this media.
  final bool isFavorited;

  /// Whether this is the hero (first) tile in a date group.
  final bool isHero;

  /// Computes the aspect ratio for masonry layout.
  ///
  /// Uses the media ID hash to generate a consistent
  /// pseudo-random aspect ratio between 0.7 and 1.3.
  /// Hero tiles get a taller ratio (~0.65).
  double get aspectRatio {
    if (isHero) return 0.65;
    // Generate consistent ratio from media ID hash
    final hash = media.id.hashCode.abs();
    // Map to range 0.75 - 1.25
    return 0.75 + (hash % 50) / 100.0;
  }

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
      child: AspectRatio(
        aspectRatio: aspectRatio,
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          LynewedColors.gray300,
                        ),
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

            // Favorite badge (top-right)
            if (isFavorited)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    size: 12,
                    color: LynewedColors.error,
                  ),
                ),
              ),

            // Caption indicator (bottom-right)
            if (media.caption != null && media.caption!.isNotEmpty)
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
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
}
