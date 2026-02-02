/// Custom navigation bar for guest users.
///
/// 84px height navbar with 3 tabs: Album, Chat (with badge), Profile.
/// Pattern identical to NavBarBridesWidget but with 3 tabs and callback.
library;

import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';

/// Bottom navigation bar for guest users.
///
/// Custom Stack-based implementation (not BottomNavigationBar) for
/// precise control over styling. Matches Bride navbar pattern.
///
/// Features:
/// - 84px fixed height with Stack layout
/// - 3 tabs: Album, Chat, Profile
/// - Unread badge on Chat tab
/// - InkWell with transparent splash
/// - Top divider (1px)
class GuestNavBarV2 extends StatelessWidget {
  /// Currently selected tab index (0=Album, 1=Chat, 2=Profile).
  final int currentIndex;

  /// Callback when a tab is tapped.
  final ValueChanged<int> onTap;

  /// Number of unread messages to show as badge on Chat tab.
  /// Shows nothing if 0, shows "99+" if > 99.
  final int unreadCount;

  /// Creates a guest navigation bar.
  const GuestNavBarV2({
    required this.currentIndex,
    required this.onTap,
    this.unreadCount = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84.0,
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          // Main content
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 84.0,
              decoration: BoxDecoration(
                color: LynewedColors.background,
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  24.0,
                  12.0,
                  24.0,
                  0.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Album tab
                    _buildTab(
                      index: 0,
                      icon: Icons.photo_library_outlined,
                      label: 'Album',
                    ),
                    // Chat tab (with badge)
                    _buildChatTab(),
                    // Profile tab
                    _buildTab(
                      index: 2,
                      icon: Icons.person_outline,
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Top divider
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: Container(
              width: double.infinity,
              height: 1.0,
              decoration: BoxDecoration(
                color: LynewedColors.gray200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = currentIndex == index;
    final color =
        isActive ? LynewedColors.textPrimary : LynewedColors.textSecondary;

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 23.0,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Haas Grot Text Trial',
                color: color,
                fontSize: 14.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    final isActive = currentIndex == 1;
    final color =
        isActive ? LynewedColors.textPrimary : LynewedColors.textSecondary;

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => onTap(1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with optional badge
          SizedBox(
            width: 32,
            height: 24,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 4.5,
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: color,
                    size: 23.0,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      constraints: const BoxConstraints(
                        maxWidth: 16,
                        maxHeight: 16,
                      ),
                      decoration: BoxDecoration(
                        color: LynewedColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
            child: Text(
              'Chat',
              style: TextStyle(
                fontFamily: 'Haas Grot Text Trial',
                color: color,
                fontSize: 14.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
