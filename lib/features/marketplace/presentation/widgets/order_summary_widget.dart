/// Order summary widget for marketplace checkout.
///
/// Displays a breakdown of the purchase: item price, shipping cost,
/// platform fee (informational), and total amount.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// Displays an order summary with price breakdown.
///
/// Shows item price, shipping cost, platform fee (10% informational),
/// and the total the buyer will pay.
class OrderSummaryWidget extends StatelessWidget {
  /// Creates an order summary widget.
  const OrderSummaryWidget({
    required this.itemTitle,
    required this.itemPriceCents,
    required this.shippingCostCents,
    required this.platformFeeCents,
    required this.totalCents,
    super.key,
  });

  /// The listing title.
  final String itemTitle;

  /// Item price in cents.
  final int itemPriceCents;

  /// Shipping cost in cents.
  final int shippingCostCents;

  /// Platform fee in cents (10% of item price, informational).
  final int platformFeeCents;

  /// Total amount the buyer will pay in cents.
  final int totalCents;

  String _formatCents(int cents) {
    return '\$${(cents / 100).toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Order Summary'),
        const SizedBox(height: 10),

        // Summary card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LynewedColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LynewedColors.gray200),
          ),
          child: Column(
            children: [
              // Item
              _buildRow(itemTitle, _formatCents(itemPriceCents)),
              const SizedBox(height: 12),

              // Shipping
              _buildRow('Shipping', _formatCents(shippingCostCents)),
              const SizedBox(height: 12),

              // Platform fee (informational)
              _buildRow(
                'Platform fee (10%)',
                _formatCents(platformFeeCents),
                isSubtle: true,
              ),
              const SizedBox(height: 12),

              // Divider
              const Divider(color: LynewedColors.gray200),
              const SizedBox(height: 12),

              // Total
              _buildRow('Total', _formatCents(totalCents), isBold: true),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Informational note
        Text(
          'The platform fee is included for transparency. You pay the item price + shipping.',
          style: LynewedTextStyles.bodySmall.copyWith(
            color: LynewedColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value,
      {bool isBold = false, bool isSubtle = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: isBold
                ? LynewedTextStyles.titleSmall
                : LynewedTextStyles.bodySmall.copyWith(
                    color: isSubtle
                        ? LynewedColors.textSecondary
                        : LynewedColors.textPrimary,
                  ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: isBold
              ? LynewedTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                )
              : LynewedTextStyles.bodySmall.copyWith(
                  color: isSubtle
                      ? LynewedColors.textSecondary
                      : LynewedColors.textPrimary,
                ),
        ),
      ],
    );
  }
}
