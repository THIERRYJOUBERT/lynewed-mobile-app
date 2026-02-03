/// Order Confirmation Page - Displays order success after magazine purchase.
///
/// Shows confirmation message, order number, and next steps.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';

/// Page displaying order confirmation after successful magazine purchase.
class OrderConfirmationPage extends StatelessWidget {
  /// Creates an order confirmation page.
  const OrderConfirmationPage({
    super.key,
    required this.sessionId,
    this.orderId,
    this.onDone,
  });

  /// Stripe Checkout session ID.
  final String sessionId;

  /// Order ID (if available).
  final String? orderId;

  /// Callback when user taps done.
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
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
                'Thank you for your order. Your wedding magazine is being prepared and will be shipped to your address soon.',
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
                    if (orderId != null && orderId!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Order ID',
                        _formatOrderId(orderId!),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Session',
                      _truncateSessionId(sessionId),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: LynewedColors.border),
                    const SizedBox(height: 16),
                    // What's next section
                    Text(
                      'What\'s Next?',
                      style: LynewedTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    _buildStep(
                      1,
                      'Production',
                      'Your magazine will be printed within 3-5 business days.',
                    ),
                    const SizedBox(height: 8),
                    _buildStep(
                      2,
                      'Shipping',
                      'You\'ll receive a tracking number via email once shipped.',
                    ),
                    const SizedBox(height: 8),
                    _buildStep(
                      3,
                      'Delivery',
                      'Estimated delivery: 5-10 business days after shipping.',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Done button
              LynewedButton(
                text: 'Done',
                onPressed: onDone,
                width: double.infinity,
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
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

  String _formatOrderId(String id) {
    // Show first 8 characters of order ID for readability
    if (id.length > 8) {
      return '${id.substring(0, 8).toUpperCase()}...';
    }
    return id.toUpperCase();
  }

  String _truncateSessionId(String id) {
    // Show last 8 characters of session ID
    if (id.length > 8) {
      return '...${id.substring(id.length - 8)}';
    }
    return id;
  }
}
