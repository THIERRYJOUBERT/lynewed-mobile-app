/// Quick action card widget.
///
/// A tappable card displaying an icon and title for quick actions
/// in the support page (e.g., Email, Chat).
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// A widget that displays a quick action card.
///
/// Used in the support page for quick actions like:
/// - Email support
/// - Chat with team
/// - Call support
///
/// Follows the Lynewed design system styling with:
/// - Icon centered in card
/// - Title below icon
/// - Optional subtitle for additional context
/// - Tap callback for action
class QuickActionCard extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The action title.
  final String title;

  /// Optional subtitle text.
  final String? subtitle;

  /// Callback when card is tapped.
  final VoidCallback onTap;

  /// Creates a quick action card widget.
  const QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 80.0,
          minWidth: 80.0,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: LynewedColors.border,
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: LynewedColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(22.0),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 22.0,
                  color: LynewedColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            // Title
            Text(
              title,
              style: LynewedTextStyles.titleSmall,
              textAlign: TextAlign.center,
            ),
            // Subtitle (optional)
            if (subtitle != null) ...[
              const SizedBox(height: 4.0),
              Text(
                subtitle!,
                style: LynewedTextStyles.labelMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
