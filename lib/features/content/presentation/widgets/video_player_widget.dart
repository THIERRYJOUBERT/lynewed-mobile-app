/// Video player widget for content feature.
///
/// A placeholder widget for video playback that displays a thumbnail
/// and play button. Supports YouTube, Vimeo, and direct video URLs.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/wed_article.dart';

/// Video player widget.
///
/// Displays a video thumbnail with a play button overlay.
/// Supports different video types (YouTube, Vimeo, direct).
///
/// This is a placeholder implementation that shows the video
/// thumbnail and type label. Full video playback can be added
/// using youtube_player_flutter or similar packages.
class VideoPlayerWidget extends StatelessWidget {
  /// The video URL.
  final String videoUrl;

  /// The type of video (youtube, vimeo, direct).
  final VideoType videoType;

  /// Optional thumbnail URL.
  final String? thumbnailUrl;

  /// Optional title to display.
  final String? title;

  /// Aspect ratio of the video player.
  final double aspectRatio;

  /// Callback when the widget is tapped.
  final VoidCallback? onTap;

  /// Creates a video player widget.
  const VideoPlayerWidget({
    required this.videoUrl,
    required this.videoType,
    this.thumbnailUrl,
    this.title,
    this.aspectRatio = 16 / 9,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background - thumbnail or placeholder
              _buildBackground(),
              // Gradient overlay
              _buildGradientOverlay(),
              // Play button and info
              _buildOverlayContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    if (thumbnailUrl != null) {
      return Container(
        decoration: BoxDecoration(
          color: LynewedColors.gray100,
          image: DecorationImage(
            image: NetworkImage(thumbnailUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      color: LynewedColors.gray200,
      child: Center(
        child: Icon(
          _getVideoIcon(),
          size: 48.0,
          color: LynewedColors.gray300,
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.6),
          ],
          stops: const [0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildOverlayContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Play button
        Container(
          width: 64.0,
          height: 64.0,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_circle_outline,
            size: 48.0,
            color: LynewedColors.primary,
          ),
        ),
        const SizedBox(height: 16.0),
        // Video type label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: _getVideoBadgeColor(),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            _getVideoTypeLabel(),
            style: LynewedTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Title if provided
        if (title != null) ...[
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title!,
              style: LynewedTextStyles.titleSmall.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  IconData _getVideoIcon() {
    switch (videoType) {
      case VideoType.youtube:
        return Icons.smart_display;
      case VideoType.vimeo:
        return Icons.video_library;
      case VideoType.direct:
        return Icons.play_circle_fill;
    }
  }

  String _getVideoTypeLabel() {
    switch (videoType) {
      case VideoType.youtube:
        return 'YouTube';
      case VideoType.vimeo:
        return 'Vimeo';
      case VideoType.direct:
        return 'Video';
    }
  }

  Color _getVideoBadgeColor() {
    switch (videoType) {
      case VideoType.youtube:
        return const Color(0xFFFF0000); // YouTube red
      case VideoType.vimeo:
        return const Color(0xFF1AB7EA); // Vimeo blue
      case VideoType.direct:
        return LynewedColors.primary;
    }
  }
}
