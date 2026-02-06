/// Stats header for the guest album page.
///
/// Displays photo count, video count, and loved count.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// Compact stats bar showing media and favorite counts.
///
/// Layout: [camera] 12 photos  [videocam] 3 videos  [heart] 2 loved
class AlbumStatsHeader extends StatelessWidget {
  /// Creates an album stats header.
  const AlbumStatsHeader({
    super.key,
    required this.photoCount,
    required this.videoCount,
    required this.lovedCount,
  });

  /// Number of photos in the album.
  final int photoCount;

  /// Number of videos in the album.
  final int videoCount;

  /// Number of media items loved by the bride.
  final int lovedCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            icon: Icons.photo_camera_outlined,
            count: photoCount,
            label: photoCount == 1 ? 'photo' : 'photos',
          ),
          _StatItem(
            icon: Icons.videocam_outlined,
            count: videoCount,
            label: videoCount == 1 ? 'video' : 'videos',
          ),
          _StatItem(
            icon: Icons.favorite,
            count: lovedCount,
            label: 'loved',
            accentColor:
                lovedCount > 0 ? LynewedColors.error : null,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.count,
    required this.label,
    this.accentColor,
  });

  final IconData icon;
  final int count;
  final String label;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final iconColor = accentColor ?? LynewedColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: LynewedTextStyles.titleSmall.copyWith(
            color: LynewedColors.textPrimary,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: LynewedTextStyles.labelSmall.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
