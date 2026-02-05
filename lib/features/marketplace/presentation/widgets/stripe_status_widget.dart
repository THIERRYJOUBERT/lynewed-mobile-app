/// Widget displaying the Stripe Connect account status.
///
/// Shows a warning card when setup is incomplete or a success card
/// when the seller can receive payments.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// Displays the current Stripe Connect payment status.
///
/// Shows different states:
/// - **Incomplete**: Yellow warning card with "Complete Setup" button
/// - **Complete**: Green success card with charges/payouts status
class StripeStatusWidget extends StatelessWidget {
  /// Whether onboarding has been completed on Stripe.
  final bool onboardingComplete;

  /// Whether the account can accept charges.
  final bool chargesEnabled;

  /// Whether the account can receive payouts.
  final bool payoutsEnabled;

  /// Callback when the setup button is tapped.
  final VoidCallback? onSetupTap;

  const StripeStatusWidget({
    required this.onboardingComplete,
    required this.chargesEnabled,
    required this.payoutsEnabled,
    this.onSetupTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!onboardingComplete || !chargesEnabled) {
      return _buildIncompleteCard();
    }
    return _buildCompleteCard();
  }

  Widget _buildIncompleteCard() {
    return Card(
      color: LynewedColors.warning.withValues(alpha: 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: LynewedColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: LynewedColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Payment Setup Incomplete',
                    style: LynewedTextStyles.titleSmall.copyWith(
                      color: LynewedColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your Stripe setup to receive payments from sales.',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            LynewedButton(
              text: 'Complete Setup',
              onPressed: onSetupTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteCard() {
    return Card(
      color: LynewedColors.success.withValues(alpha: 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: LynewedColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: LynewedColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Payment Setup Complete',
                    style: LynewedTextStyles.titleSmall.copyWith(
                      color: LynewedColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Charges: ${chargesEnabled ? "Enabled" : "Disabled"}',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Payouts: ${payoutsEnabled ? "Enabled" : "Disabled"}',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
