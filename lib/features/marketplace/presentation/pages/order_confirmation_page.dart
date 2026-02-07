/// Order confirmation page shown after successful marketplace payment.
///
/// Displays a success message with order details, next steps timeline,
/// and navigation to purchase history.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/core/design/design.dart';
import 'my_purchases_page.dart';

/// Success screen shown after a marketplace purchase is confirmed.
///
/// Follows the same pattern as the magazine [OrderConfirmationPage] with
/// marketplace-specific steps and navigation.
class OrderConfirmationPage extends StatelessWidget {
  /// Creates an order confirmation page.
  const OrderConfirmationPage({
    this.sessionId,
    this.onDone,
    super.key,
  });

  /// Route name for navigation.
  static const String routeName = 'MarketplaceOrderConfirmation';

  /// Route path for GoRouter registration.
  static const String routePath = '/marketplace/order-confirmation';

  /// Optional Stripe session ID for reference.
  final String? sessionId;

  /// Callback when user taps done.
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                child: Column(
                  children: [
                    // Success icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: LynewedColors.success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: LynewedColors.success,
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Order Confirmed!',
                      style: LynewedTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Your purchase is confirmed. The seller will be notified to prepare and ship your item.',
                      style: LynewedTextStyles.bodyMedium.copyWith(
                        color: LynewedColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Order details card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: LynewedColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: LynewedColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            'Order Status',
                            'Confirmed',
                            valueColor: LynewedColors.success,
                          ),
                          if (sessionId != null &&
                              sessionId!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Session',
                              _truncateSessionId(sessionId!),
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Divider(color: LynewedColors.border),
                          const SizedBox(height: 16),

                          // What's next section
                          Text(
                            "What's Next?",
                            style: LynewedTextStyles.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          _buildStep(
                            1,
                            'Payment Confirmed',
                            'Your payment has been processed successfully.',
                          ),
                          const SizedBox(height: 8),
                          _buildStep(
                            2,
                            'Seller Ships',
                            'The seller will prepare your item and generate a FedEx shipping label.',
                          ),
                          const SizedBox(height: 8),
                          _buildStep(
                            3,
                            'Track Delivery',
                            "You'll receive notifications with tracking updates.",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Column(
                children: [
                  LynewedButton(
                    text: 'View My Purchases',
                    type: LynewedButtonType.secondary,
                    onPressed: () =>
                        GoRouter.of(context).go(MyPurchasesPage.routePath),
                    width: double.infinity,
                  ),
                  const SizedBox(height: 12),
                  LynewedButton(
                    text: 'Done',
                    onPressed: onDone ?? () => GoRouter.of(context).go('/'),
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: LynewedTextStyles.bodyMedium.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: LynewedTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: valueColor ?? LynewedColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStep(int number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: LynewedColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: LynewedTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _truncateSessionId(String id) {
    if (id.length > 8) {
      return '...${id.substring(id.length - 8)}';
    }
    return id;
  }
}
