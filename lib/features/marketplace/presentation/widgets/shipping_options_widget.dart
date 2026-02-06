/// Shipping options widget for marketplace checkout.
///
/// Fetches available FedEx shipping rates and displays them as selectable
/// cards. Handles loading, error, and empty states.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/shipping_rate.dart';

/// Displays a list of shipping rate options as selectable cards.
///
/// Shows loading indicator while rates are being fetched,
/// error state with retry, or the list of available options.
class ShippingOptionsWidget extends StatelessWidget {
  /// Creates a shipping options widget.
  const ShippingOptionsWidget({
    required this.rates,
    required this.selectedRate,
    required this.onRateSelected,
    required this.isLoading,
    this.errorMessage,
    this.onRetry,
    super.key,
  });

  /// Available shipping rates.
  final List<ShippingRate> rates;

  /// Currently selected rate, or null if none selected.
  final ShippingRate? selectedRate;

  /// Called when a rate is selected.
  final ValueChanged<ShippingRate> onRateSelected;

  /// Whether rates are being loaded.
  final bool isLoading;

  /// Error message if rate fetching failed.
  final String? errorMessage;

  /// Retry callback for error state.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Shipping Options'),
        const SizedBox(height: 10),
        if (isLoading) _buildLoading(),
        if (!isLoading && errorMessage != null) _buildError(),
        if (!isLoading && errorMessage == null && rates.isEmpty)
          _buildEmpty(),
        if (!isLoading && errorMessage == null && rates.isNotEmpty)
          _buildRatesList(),
      ],
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: LynewedColors.primary),
            SizedBox(height: 12),
            Text('Calculating shipping rates...'),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: LynewedColors.error, size: 40),
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.error,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            LynewedButton(
              text: 'Retry',
              type: LynewedButtonType.secondary,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'No shipping options available',
          style: LynewedTextStyles.bodySmall.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildRatesList() {
    return Column(
      children: rates.map((rate) {
        final isSelected = selectedRate == rate;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => onRateSelected(rate),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LynewedColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? LynewedColors.primary
                      : LynewedColors.gray200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Selection indicator
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? LynewedColors.primary
                            : LynewedColors.gray300,
                        width: 2,
                      ),
                      color: isSelected
                          ? LynewedColors.primary
                          : LynewedColors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                            size: 14, color: LynewedColors.background)
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Service info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rate.serviceName,
                          style: LynewedTextStyles.titleSmall,
                        ),
                        if (rate.estimatedDaysLabel != null ||
                            rate.estimatedDays != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            rate.estimatedDaysLabel ??
                                '${rate.estimatedDays} business days',
                            style: LynewedTextStyles.bodySmall.copyWith(
                              color: LynewedColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Price
                  Text(
                    '\$${rate.priceInDollars.toStringAsFixed(2)}',
                    style: LynewedTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
