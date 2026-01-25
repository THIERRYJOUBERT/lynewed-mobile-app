/// Quick actions row widget for the home page.
///
/// Displays a horizontal row of 4 quick action items:
/// Find Pros, Favorites, Messages, Inspirations.
library;

import 'package:flutter/material.dart';
import 'quick_action_item.dart';

/// A row of quick action items for common navigation.
///
/// Displays 4 actions that brides frequently access:
/// - Find Pros: Navigate to professional search
/// - Favorites: View saved/favorited professionals
/// - Messages: Access chat conversations
/// - Inspirations: View saved inspiration albums
class QuickActionsRow extends StatelessWidget {
  /// Callback when Find Pros is tapped.
  final VoidCallback onFindProsTap;

  /// Callback when Favorites is tapped.
  final VoidCallback onFavoritesTap;

  /// Callback when Messages is tapped.
  final VoidCallback onMessagesTap;

  /// Callback when Inspirations is tapped.
  final VoidCallback onInspirationsTap;

  /// Creates a quick actions row.
  const QuickActionsRow({
    required this.onFindProsTap,
    required this.onFavoritesTap,
    required this.onMessagesTap,
    required this.onInspirationsTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: QuickActionItem(
              icon: Icons.search,
              label: 'Find Pros',
              onTap: onFindProsTap,
            ),
          ),
          Expanded(
            child: QuickActionItem(
              icon: Icons.favorite_outline,
              label: 'Favorites',
              onTap: onFavoritesTap,
            ),
          ),
          Expanded(
            child: QuickActionItem(
              icon: Icons.chat_bubble_outline,
              label: 'Messages',
              onTap: onMessagesTap,
            ),
          ),
          Expanded(
            child: QuickActionItem(
              icon: Icons.photo_library_outlined,
              label: 'Inspirations',
              onTap: onInspirationsTap,
            ),
          ),
        ],
      ),
    );
  }
}
