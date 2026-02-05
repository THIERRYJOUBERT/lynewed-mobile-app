/// ActionButtonsBar widget for listing detail pages.
///
/// Bottom bar with Contact Seller, Make Offer, and Buy Now buttons.
/// All show "Coming soon" snackbar since S18/S19/S20 are not yet implemented.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// Bottom action bar for listing detail page.
///
/// Contains three actions:
/// - Contact Seller (icon button with chat icon)
/// - Make Offer (secondary button)
/// - Buy Now (primary button)
///
/// All actions currently show "Coming soon" until S18, S19, S20 are implemented.
class ActionButtonsBar extends StatelessWidget {
  /// Creates an action buttons bar.
  const ActionButtonsBar({
    required this.onContact,
    required this.onMakeOffer,
    required this.onBuyNow,
    super.key,
  });

  /// Callback when Contact Seller is tapped.
  final VoidCallback onContact;

  /// Callback when Make Offer is tapped.
  final VoidCallback onMakeOffer;

  /// Callback when Buy Now is tapped.
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(LynewedSpacing.md),
        decoration: const BoxDecoration(
          color: LynewedColors.background,
          border: Border(
            top: BorderSide(color: LynewedColors.gray200),
          ),
        ),
        child: Row(
          children: [
            // Contact Seller (icon button)
            LynewedIconButton(
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: LynewedColors.primary,
                size: 22,
              ),
              onPressed: onContact,
              borderColor: LynewedColors.gray200,
              borderWidth: 1,
              borderRadius: 0,
              buttonSize: LynewedSpacing.buttonHeight,
            ),
            SizedBox(width: LynewedSpacing.sm),

            // Make Offer (secondary)
            Expanded(
              child: LynewedButton(
                text: 'Make Offer',
                type: LynewedButtonType.secondary,
                onPressed: onMakeOffer,
              ),
            ),
            SizedBox(width: LynewedSpacing.sm),

            // Buy Now (primary)
            Expanded(
              child: LynewedButton(
                text: 'Buy Now',
                type: LynewedButtonType.primary,
                onPressed: onBuyNow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
