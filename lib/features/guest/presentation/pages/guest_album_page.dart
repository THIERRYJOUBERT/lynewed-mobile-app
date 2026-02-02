/// Album page for guests.
///
/// Displays the guest's personal album with photos and videos.
/// Full implementation will be in EPIC-10.
library;

import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';

/// Album page for guests.
///
/// Shows elegant empty state with FAB for future photo upload.
/// Full grid implementation will be added in EPIC-10 (Photos/Videos).
class GuestAlbumPage extends StatelessWidget {
  /// Creates a guest album page.
  const GuestAlbumPage({super.key});

  @override
  Widget build(BuildContext context) {
    // For EPIC-09: Always show empty state
    // EPIC-10 will add: _isLoading, _media list, _buildMediaGrid()
    return Stack(
      children: [
        // Empty state content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 64,
                color: LynewedColors.gray300,
              ),
              SizedBox(height: LynewedSpacing.lg),
              Text(
                'Your Wedding Memories',
                style: LynewedTextStyles.titleSmall.copyWith(
                  color: LynewedColors.textPrimary,
                ),
              ),
              SizedBox(height: LynewedSpacing.sm),
              Text(
                'Photos and videos you capture\nwill appear here',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // FAB for adding photos (placeholder for EPIC-10)
        Positioned(
          right: 0,
          bottom: 0,
          child: FloatingActionButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Photo upload coming in next update!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            backgroundColor: LynewedColors.primary,
            child: Icon(
              Icons.add,
              color: LynewedColors.background,
            ),
          ),
        ),
      ],
    );
  }
}
