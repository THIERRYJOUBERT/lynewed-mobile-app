/// Profile menu item data entity.
///
/// Represents a menu item in the profile page with icon, title,
/// optional subtitle, trailing widget, and tap callback.
library;

import 'package:flutter/material.dart';

/// Data class for profile menu items.
///
/// Used to configure menu items displayed in the profile page.
/// Supports customization via icon, title, subtitle, trailing widget,
/// and tap callback.
@immutable
class ProfileMenuItemData {
  /// The icon displayed at the leading position.
  final IconData icon;

  /// The main title text.
  final String title;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional subtitle text displayed below the title.
  final String? subtitle;

  /// Optional trailing widget (e.g., chevron, badge).
  final Widget? trailing;

  /// Creates a profile menu item data.
  const ProfileMenuItemData({
    required this.icon,
    required this.title,
    this.onTap,
    this.subtitle,
    this.trailing,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileMenuItemData &&
        other.icon == icon &&
        other.title == title &&
        other.subtitle == subtitle;
  }

  @override
  int get hashCode => Object.hash(icon, title, subtitle);

  @override
  String toString() => 'ProfileMenuItemData($title)';
}
