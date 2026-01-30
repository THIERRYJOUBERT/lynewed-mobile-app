/// Widget for the discrete guest join button on the auth welcome page.
///
/// Provides a subtle entry point for guests to join a wedding using an
/// invitation code.
library;

import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';

/// A discrete button for guests to join a wedding.
///
/// This button is designed to be subtle and positioned below the main
/// sign-in options on the auth welcome page.
class GuestJoinButton extends StatelessWidget {
  /// Creates a guest join button.
  const GuestJoinButton({
    required this.onPressed,
    super.key,
  });

  /// Callback when the button is pressed.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: LynewedColors.border,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: LynewedSpacing.md),
              child: Text(
                'OR',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.gray100,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: LynewedColors.border,
                thickness: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: LynewedSpacing.lg),
        // Guest join button
        TextButton.icon(
          onPressed: onPressed,
          icon: Icon(
            Icons.person_add_outlined,
            size: 18,
            color: LynewedColors.gray100,
          ),
          label: Text(
            "Rejoindre en tant qu'invité",
            style: LynewedTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w400,
              color: LynewedColors.gray100,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: LynewedSpacing.md,
              vertical: LynewedSpacing.sm,
            ),
          ),
        ),
      ],
    );
  }
}
