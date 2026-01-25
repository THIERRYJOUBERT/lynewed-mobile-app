/// Settings tile widget.
///
/// A styled list tile for settings menu items with icon, title,
/// optional subtitle, trailing widget, tap callback, and destructive style.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// A widget that displays a settings tile item.
///
/// Follows the Lynewed design system styling with support for:
/// - Icon and title (required)
/// - Optional subtitle for additional context
/// - Optional trailing widget (defaults to chevron)
/// - Destructive style for dangerous actions (delete, logout)
/// - Tap callback for navigation or actions
class SettingsTile extends StatelessWidget {
  /// The icon to display on the left side.
  final IconData icon;

  /// The main title text.
  final String title;

  /// Optional subtitle text below the title.
  final String? subtitle;

  /// Optional callback when tile is tapped.
  final VoidCallback? onTap;

  /// Whether this tile represents a destructive action.
  /// When true, icon and title use error color.
  final bool isDestructive;

  /// Optional trailing widget. Defaults to chevron_right icon.
  final Widget? trailing;

  /// Creates a settings tile widget.
  const SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        isDestructive ? LynewedColors.error : LynewedColors.textSecondary;
    final titleColor =
        isDestructive ? LynewedColors.error : LynewedColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          children: [
            // Leading icon
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: isDestructive
                    ? LynewedColors.error.withValues(alpha: 0.1)
                    : LynewedColors.gray200,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20.0,
                  color: effectiveColor,
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2.0),
                    Text(
                      subtitle!,
                      style: LynewedTextStyles.labelMedium.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Trailing widget (default to chevron)
            trailing ??
                Icon(
                  Icons.chevron_right,
                  size: 20.0,
                  color: isDestructive
                      ? LynewedColors.error
                      : LynewedColors.textSecondary,
                ),
          ],
        ),
      ),
    );
  }
}
