/// Guest Album Card widget.
///
/// Displays a guest's album summary in a card format.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/guest_album.dart';

/// Card widget displaying a guest's album summary.
///
/// Shows guest avatar, name, media count, and optional thumbnail.
/// Style reference: conversation_tile.dart
class GuestAlbumCard extends StatelessWidget {
  /// Creates a GuestAlbumCard.
  const GuestAlbumCard({
    super.key,
    required this.album,
    required this.onTap,
  });

  /// The album to display.
  final GuestAlbum album;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LynewedColors.gray200),
        ),
        child: Row(
          children: [
            // Guest avatar
            _buildAvatar(),
            const SizedBox(width: 12),

            // Album info (name + count)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.guestName,
                    style: LynewedTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildMediaCountText(),
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Thumbnail preview
            if (album.thumbnailUrl != null) ...[
              _buildThumbnail(),
              const SizedBox(width: 8),
            ],

            // Chevron
            const Icon(
              Icons.chevron_right,
              color: LynewedColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the guest avatar with fallback to initial.
  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 22,
      backgroundColor: LynewedColors.gray200,
      backgroundImage: album.guestAvatarUrl != null
          ? CachedNetworkImageProvider(album.guestAvatarUrl!)
          : null,
      child: album.guestAvatarUrl == null
          ? Text(
              album.guestName.isNotEmpty
                  ? album.guestName[0].toUpperCase()
                  : '?',
              style: LynewedTextStyles.titleSmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            )
          : null,
    );
  }

  /// Builds the thumbnail preview.
  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: album.thumbnailUrl!,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: 44,
          height: 44,
          color: LynewedColors.gray200,
        ),
        errorWidget: (_, __, ___) => Container(
          width: 44,
          height: 44,
          color: LynewedColors.gray200,
          child: const Icon(
            Icons.broken_image_outlined,
            size: 20,
            color: LynewedColors.gray300,
          ),
        ),
      ),
    );
  }

  /// Builds the media count text.
  ///
  /// Examples:
  /// - "5 photos, 2 videos"
  /// - "10 photos"
  /// - "3 videos"
  /// - "No media yet"
  String _buildMediaCountText() {
    if (album.isEmpty) {
      return 'No media yet';
    }

    final parts = <String>[];
    if (album.photoCount > 0) {
      parts.add('${album.photoCount} photo${album.photoCount > 1 ? 's' : ''}');
    }
    if (album.videoCount > 0) {
      parts.add('${album.videoCount} video${album.videoCount > 1 ? 's' : ''}');
    }
    return parts.join(', ');
  }
}
