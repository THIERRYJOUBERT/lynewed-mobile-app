/// Photo Tile Widget - Selectable media tile for gallery grid.
///
/// Displays a photo/video thumbnail with selection overlay.
/// Supports long press to enter selection mode, tap to select/deselect.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/core/design/design.dart';
import 'shared_badge.dart';

/// A selectable photo/video tile widget for the gallery grid.
///
/// Shows the media thumbnail with an optional selection overlay
/// and checkmark when in selection mode.
class PhotoTile extends StatelessWidget {
  /// Creates a photo tile widget.
  const PhotoTile({
    super.key,
    required this.mediaId,
    required this.imageUrl,
    this.thumbnailUrl,
    this.isVideo = false,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.isShared = false,
    this.onTap,
    this.onLongPress,
  });

  /// The unique ID of the media item.
  final String mediaId;

  /// The URL of the full-size image.
  final String imageUrl;

  /// The URL of the thumbnail image (optional, uses imageUrl if not provided).
  final String? thumbnailUrl;

  /// Whether this media item is a video.
  final bool isVideo;

  /// Whether the gallery is in selection mode.
  final bool isSelectionMode;

  /// Whether this media item is selected.
  final bool isSelected;

  /// Whether this media item is shared with guests.
  final bool isShared;

  /// Callback when the tile is tapped.
  final VoidCallback? onTap;

  /// Callback when the tile is long pressed.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          CachedNetworkImage(
            imageUrl: thumbnailUrl ?? imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: LynewedColors.gray200,
            ),
            errorWidget: (_, __, ___) => Container(
              color: LynewedColors.gray200,
              child: const Icon(
                Icons.broken_image_outlined,
                color: LynewedColors.gray300,
              ),
            ),
          ),
          // Selection overlay
          if (isSelectionMode)
            Container(
              color: isSelected
                  ? LynewedColors.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          // Selection checkmark
          if (isSelectionMode)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected
                      ? LynewedColors.primary
                      : Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? LynewedColors.primary
                        : LynewedColors.gray300,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ),
          // Video play icon overlay (only when not in selection mode)
          if (isVideo && !isSelectionMode)
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
          // Shared badge (bottom-left, only when not in selection mode)
          if (isShared && !isSelectionMode)
            const Positioned(
              bottom: 4,
              left: 4,
              child: SharedBadge(size: 20),
            ),
        ],
      ),
    );
  }
}
