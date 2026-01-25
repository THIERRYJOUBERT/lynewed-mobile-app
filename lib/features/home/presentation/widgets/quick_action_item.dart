/// Quick action item widget for the home page.
///
/// A tappable item that displays an icon and label for quick navigation.
/// Used in the QuickActionsRow to provide fast access to common features.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';

/// A quick action item with an icon and label.
///
/// Displays a circular icon above a text label, with tap functionality.
/// Used in [QuickActionsRow] for quick navigation to common features.
class QuickActionItem extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The label text below the icon.
  final String label;

  /// Callback when the item is tapped.
  final VoidCallback onTap;

  /// Creates a quick action item.
  const QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon container
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: LynewedColors.surface,
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color: LynewedColors.gray200,
                width: 1.0,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 22.0,
                color: LynewedColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          // Label
          Text(
            label,
            style: LynewedTextStyles.labelSmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
