/// Grid card widget for displaying a guest album.
///
/// Visual style matches inspiration album cards from [InspirationAlbumsGrid].
/// Shows cover thumbnail, guest avatar badge, guest name, and media count.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/guest_album.dart';

/// Card widget displaying a guest album in a grid layout.
///
/// Matches the visual style of inspiration album cards:
/// - Cover image fills top area
/// - Guest avatar badge at bottom-left of cover
/// - Name and media count below
class GuestAlbumGridCard extends StatelessWidget {
  const GuestAlbumGridCard({
    super.key,
    required this.album,
    required this.onTap,
  });

  /// The guest album to display.
  final GuestAlbum album;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image with avatar badge
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Thumbnail or placeholder
                    if (album.thumbnailUrl != null && album.thumbnailUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: album.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _buildPlaceholder(),
                        errorWidget: (_, __, ___) => _buildPlaceholder(),
                      )
                    else
                      _buildPlaceholder(),
                    // Guest avatar badge at bottom-left
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: _buildAvatarBadge(),
                    ),
                  ],
                ),
              ),
            ),
            // Album info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.guestName,
                    style: LynewedTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _buildMediaCountText(),
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: LynewedColors.gray200,
      child: const Center(
        child: Icon(Icons.photo_album_outlined, color: LynewedColors.gray300, size: 32),
      ),
    );
  }

  Widget _buildAvatarBadge() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 14,
        backgroundColor: LynewedColors.gray200,
        backgroundImage: album.guestAvatarUrl != null
            ? CachedNetworkImageProvider(album.guestAvatarUrl!)
            : null,
        child: album.guestAvatarUrl == null
            ? Text(
                album.guestName.isNotEmpty ? album.guestName[0].toUpperCase() : '?',
                style: LynewedTextStyles.labelSmall.copyWith(
                  color: LynewedColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
    );
  }

  /// Builds the media count text.
  String _buildMediaCountText() {
    if (album.isEmpty) return 'No media yet';

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
