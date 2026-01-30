/// Navigation bar for guest users.
///
/// Displays 3 tabs: Album, Chat, Profil.
library;

import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';

/// Bottom navigation bar for guest users.
///
/// Shows 3 tabs with icons and labels:
/// - Album (photos/videos)
/// - Chat (wedding team) with optional unread badge
/// - Profil (guest profile)
class GuestNavBar extends StatelessWidget {
  /// Currently selected tab index.
  final int currentIndex;

  /// Callback when a tab is tapped.
  final ValueChanged<int> onTap;

  /// Number of unread messages to show as badge on Chat tab.
  final int unreadCount;

  /// Creates a guest navigation bar.
  const GuestNavBar({
    required this.currentIndex,
    required this.onTap,
    this.unreadCount = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: LynewedColors.background,
      selectedItemColor: LynewedColors.primary,
      unselectedItemColor: LynewedColors.textSecondary,
      selectedLabelStyle: LynewedTextStyles.labelSmall.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: LynewedTextStyles.labelSmall,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.photo_library_outlined),
          activeIcon: Icon(Icons.photo_library),
          label: 'Album',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text(unreadCount.toString()),
            child: const Icon(Icons.chat_bubble_outline),
          ),
          activeIcon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text(unreadCount.toString()),
            child: const Icon(Icons.chat_bubble),
          ),
          label: 'Chat',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
