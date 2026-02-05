/// Order confirmation page shown after successful marketplace payment.
///
/// Displays a success message with order details and a button
/// to return to the marketplace.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// Success screen shown after a marketplace purchase is confirmed.
///
/// Displays:
/// - Success checkmark icon
/// - Confirmation message
/// - Shipping notification info
/// - "Back to Marketplace" button
class OrderConfirmationPage extends StatelessWidget {
  /// Creates an order confirmation page.
  const OrderConfirmationPage({
    this.sessionId,
    super.key,
  });

  /// Route name for navigation.
  static const String routeName = 'OrderConfirmation';

  /// Optional Stripe session ID for reference.
  final String? sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Your order has been confirmed',
                style: LynewedTextStyles.titleSmall.copyWith(
                  fontSize: 22,
                  color: LynewedColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'You will receive a notification when the seller ships your item.',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Additional info
              Text(
                'You can track your order status in your purchase history.',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Back to marketplace button
              LynewedButton(
                text: 'Back to Marketplace',
                type: LynewedButtonType.primary,
                onPressed: () {
                  // Pop all checkout pages and go back to marketplace.
                  Navigator.of(context).popUntil(
                    (route) => route.isFirst,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
