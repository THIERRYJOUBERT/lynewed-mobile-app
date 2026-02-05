/// Widget for selecting a FedEx shipping rate.
///
/// Displays a list of radio cards for each available shipping rate option.
/// Uses the Lynewed Design System for consistent styling.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/shipping_rate.dart';

/// Displays shipping rate options as selectable radio cards.
///
/// Shows service name, price, and estimated delivery days for each rate.
/// Highlights the selected rate with the primary color.
class ShippingRateSelector extends StatefulWidget {
  /// Available shipping rate options.
  final List<ShippingRate> rates;

  /// Currently selected rate (if any).
  final ShippingRate? selectedRate;

  /// Callback when a rate is selected.
  final ValueChanged<ShippingRate> onRateSelected;

  const ShippingRateSelector({
    required this.rates,
    this.selectedRate,
    required this.onRateSelected,
    super.key,
  });

  @override
  State<ShippingRateSelector> createState() => _ShippingRateSelectorState();
}

class _ShippingRateSelectorState extends State<ShippingRateSelector> {
  ShippingRate? _selectedRate;

  @override
  void initState() {
    super.initState();
    _selectedRate = widget.selectedRate;
  }

  @override
  void didUpdateWidget(ShippingRateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedRate != oldWidget.selectedRate) {
      _selectedRate = widget.selectedRate;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rates.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.rates.map(_buildRateCard).toList(),
    );
  }

  Widget _buildRateCard(ShippingRate rate) {
    final isSelected = _selectedRate == rate;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() => _selectedRate = rate);
          widget.onRateSelected(rate);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? LynewedColors.primary : LynewedColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? LynewedColors.primary
                    : LynewedColors.gray300,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rate.serviceName,
                      style: LynewedTextStyles.titleSmall.copyWith(
                        color: LynewedColors.textPrimary,
                      ),
                    ),
                    if (rate.estimatedDays != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${rate.estimatedDays} business days',
                        style: LynewedTextStyles.bodySmall.copyWith(
                          color: LynewedColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '\$${rate.priceInDollars.toStringAsFixed(2)}',
                style: LynewedTextStyles.titleSmall.copyWith(
                  color: LynewedColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No shipping options available',
          style: LynewedTextStyles.bodySmall.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
