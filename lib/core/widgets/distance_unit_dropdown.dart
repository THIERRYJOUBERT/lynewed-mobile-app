import 'package:flutter/material.dart';
import '/core/design/design.dart';

/// Data class for distance unit
class DistanceUnitData {
  final String code;
  final String name;
  final String abbreviation;

  const DistanceUnitData({
    required this.code,
    required this.name,
    required this.abbreviation,
  });

  static const List<DistanceUnitData> all = [
    DistanceUnitData(code: 'km', name: 'Kilometers', abbreviation: 'km'),
    DistanceUnitData(code: 'miles', name: 'Miles', abbreviation: 'mi'),
  ];

  static DistanceUnitData? getByCode(String code) {
    try {
      return all.firstWhere((u) => u.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Get default unit for a currency
  /// USD, GBP → miles
  /// EUR, others → km
  static String getDefaultForCurrency(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
      case 'GBP':
        return 'miles';
      default:
        return 'km';
    }
  }
}

/// A dropdown for selecting distance unit (km or miles)
/// Matches the style of CurrencyDropdown
class DistanceUnitDropdown extends StatelessWidget {
  const DistanceUnitDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.compact = false,
  });

  /// Current selected unit code ('km' or 'miles')
  final String value;

  /// Callback when unit is selected
  final ValueChanged<String> onChanged;

  /// Optional label above the dropdown
  final String? label;

  /// Compact mode for inline usage
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactDropdown(context);
    }
    return _buildFullDropdown(context);
  }

  Widget _buildCompactDropdown(BuildContext context) {
    final unit = DistanceUnitData.getByCode(value);
    return InkWell(
      onTap: () => _showUnitPicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: LynewedColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              unit?.abbreviation ?? value,
              style: LynewedTextStyles.bodyMedium,
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 20, color: LynewedColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildFullDropdown(BuildContext context) {
    final unit = DistanceUnitData.getByCode(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: LynewedTextStyles.labelMedium),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: () => _showUnitPicker(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: LynewedColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    unit != null ? '${unit.abbreviation} - ${unit.name}' : value,
                    style: LynewedTextStyles.bodyMedium,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: LynewedColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showUnitPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: LynewedColors.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                'Distance unit',
                style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              // Options
              ...DistanceUnitData.all.map((unit) {
                final isSelected = value == unit.code;
                return InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    onChanged(unit.code);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: LynewedColors.gray200,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${unit.abbreviation} - ${unit.name}',
                            style: LynewedTextStyles.bodyMedium.copyWith(
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check, size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
