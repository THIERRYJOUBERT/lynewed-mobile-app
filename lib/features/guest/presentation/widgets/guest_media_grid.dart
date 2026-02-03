/// Guest Media Grid Widget.
///
/// Displays a grid of media items for the guest album.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/guest_media.dart';
import 'guest_media_tile.dart';

/// Displays a grid of guest media items.
///
/// Shows:
/// - 3-column grid with 4px spacing
/// - Pull-to-refresh support
/// - Delegates tap and long-press to parent
class GuestMediaGrid extends StatelessWidget {
  /// Creates a guest media grid.
  const GuestMediaGrid({
    super.key,
    required this.media,
    required this.onRefresh,
    required this.onMediaTap,
    required this.onMediaLongPress,
  });

  /// The list of media to display.
  final List<GuestMedia> media;

  /// Callback for pull-to-refresh.
  final Future<void> Function() onRefresh;

  /// Callback when a media item is tapped.
  final void Function(GuestMedia) onMediaTap;

  /// Callback when a media item is long-pressed.
  final void Function(GuestMedia) onMediaLongPress;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: LynewedColors.primary,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: media.length,
        itemBuilder: (context, index) {
          final item = media[index];
          return GuestMediaTile(
            media: item,
            onTap: () => onMediaTap(item),
            onLongPress: () => onMediaLongPress(item),
          );
        },
      ),
    );
  }
}
