/// Replay player page.
///
/// Displays a video replay with player controls and metadata.
/// Shows title, description, duration, and video type.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/replay.dart';
import '../widgets/video_player_widget.dart';

/// The replay player page.
///
/// Displays a video replay with:
/// - Video player placeholder
/// - Title and description
/// - Duration indicator
/// - Video type badge
class ReplayPlayerPage extends StatelessWidget {
  /// Route name for navigation.
  static const String routeName = 'replay-player';

  /// Route path for navigation.
  static const String routePath = '/replay/:id';

  /// The replay to display.
  final Replay replay;

  /// Creates the replay player page.
  const ReplayPlayerPage({
    required this.replay,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1.0, color: LynewedColors.gray200),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video player
                    VideoPlayerWidget(
                      videoUrl: replay.videoUrl,
                      videoType: replay.videoType,
                      thumbnailUrl: replay.thumbnailUrl,
                      title: replay.title,
                      onTap: _onVideoTap,
                    ),
                    const SizedBox(height: 24.0),

                    // Title
                    Text(
                      replay.title,
                      style: LynewedTextStyles.headlineMedium,
                    ),

                    // Duration
                    if (replay.hasDuration) ...[
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 16.0,
                            color: LynewedColors.textSecondary,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            replay.formattedDuration!,
                            style: LynewedTextStyles.labelMedium.copyWith(
                              color: LynewedColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Description
                    if (replay.hasDescription) ...[
                      const SizedBox(height: 16.0),
                      Text(
                        replay.description!,
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          color: LynewedColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],

                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            color: LynewedColors.textPrimary,
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: Text(
              'Replay',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20.0),
            ),
          ),
        ],
      ),
    );
  }

  void _onVideoTap() {
    // TODO: Open full-screen video player or external URL
    // This would typically launch the video in the appropriate player
    // based on the video type (YouTube, Vimeo, or direct)
  }
}
