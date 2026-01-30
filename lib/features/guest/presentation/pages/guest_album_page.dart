/// Album page for guests (placeholder).
///
/// Displays the guest's personal album with photos and videos.
/// Full implementation will be in EPIC-10.
library;

import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';

/// Placeholder album page for guests.
///
/// Shows empty state with option to add photos/videos.
/// Will be fully implemented in EPIC-10 (Photos/Videos).
class GuestAlbumPage extends StatelessWidget {
  /// Creates a guest album page.
  const GuestAlbumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(LynewedSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library,
            size: 80,
            color: LynewedColors.textSecondary,
          ),
          SizedBox(height: LynewedSpacing.lg),
          Text(
            'Mes photos et vidéos',
            style: LynewedTextStyles.headlineSmall.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
          SizedBox(height: LynewedSpacing.sm),
          Text(
            'Ajoutez vos photos du mariage !',
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: LynewedSpacing.xxl),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: EPIC-10 implementation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cette fonctionnalité arrive bientôt !'),
                ),
              );
            },
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Ajouter photo/vidéo'),
          ),
        ],
      ),
    );
  }
}
