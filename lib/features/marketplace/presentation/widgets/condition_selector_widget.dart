/// Condition selector widget for marketplace listings.
///
/// Displays condition options as LynewedChip widgets.
/// Supports: new, excellent, good, fair.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../data/sizes_data.dart';

/// Widget for selecting the condition of a marketplace item.
///
/// Displays condition options as selectable chips.
/// Only one condition can be selected at a time.
class ConditionSelectorWidget extends StatelessWidget {
  /// Creates a condition selector.
  const ConditionSelectorWidget({
    super.key,
    required this.selectedCondition,
    required this.onConditionSelected,
    this.errorText,
  });

  /// The currently selected condition value (e.g., 'new', 'excellent').
  final String? selectedCondition;

  /// Callback when a condition is selected.
  final ValueChanged<String> onConditionSelected;

  /// Optional error text to display below the chips.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Condition'),
        const SizedBox(height: LynewedSpacing.labelFieldGap),
        Wrap(
          spacing: LynewedSpacing.sm,
          runSpacing: LynewedSpacing.sm,
          children: conditionOptions.map((condition) {
            final isSelected = selectedCondition == condition;
            return LynewedChip(
              label: conditionLabels[condition] ?? condition,
              selected: isSelected,
              onSelected: (_) => onConditionSelected(condition),
            );
          }).toList(),
        ),
        if (errorText != null) ...[
          const SizedBox(height: LynewedSpacing.xs),
          Text(
            errorText!,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
