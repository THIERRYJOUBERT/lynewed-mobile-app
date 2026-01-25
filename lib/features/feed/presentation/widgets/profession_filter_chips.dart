/// Profession Filter Chips Widget
///
/// Horizontal scrolling list of filter chips for profession selection.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// A horizontally scrolling list of profession filter chips.
class ProfessionFilterChips extends StatelessWidget {
  const ProfessionFilterChips({
    super.key,
    required this.professions,
    required this.selectedProfessions,
    required this.onProfessionToggled,
    this.showAllChip = false,
    this.onAllSelected,
  });

  /// List of available professions.
  final List<String> professions;

  /// Currently selected professions.
  final List<String> selectedProfessions;

  /// Callback when a profession chip is toggled.
  final void Function(String profession) onProfessionToggled;

  /// Whether to show an "All" chip at the start.
  final bool showAllChip;

  /// Callback when the "All" chip is selected.
  final VoidCallback? onAllSelected;

  /// Capitalizes the first letter and replaces underscores with spaces.
  String _formatProfession(String profession) {
    final cleaned = profession.replaceAll('_', ' ');
    if (cleaned.isEmpty) return '';
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    if (professions.isEmpty && !showAllChip) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (showAllChip) ...[
            FilterChip(
              label: const Text('All'),
              selected: selectedProfessions.isEmpty,
              onSelected: (_) => onAllSelected?.call(),
              selectedColor: LynewedColors.primary.withValues(alpha: 0.2),
              checkmarkColor: LynewedColors.primary,
              backgroundColor: LynewedColors.surface,
              labelStyle: TextStyle(
                color: selectedProfessions.isEmpty
                    ? LynewedColors.primary
                    : LynewedColors.textPrimary,
                fontWeight: selectedProfessions.isEmpty
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
              side: BorderSide(
                color: selectedProfessions.isEmpty
                    ? LynewedColors.primary
                    : LynewedColors.gray300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 8),
          ],
          ...professions.map((profession) {
            final isSelected = selectedProfessions.contains(profession);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_formatProfession(profession)),
                selected: isSelected,
                onSelected: (_) => onProfessionToggled(profession),
                selectedColor: LynewedColors.primary.withValues(alpha: 0.2),
                checkmarkColor: LynewedColors.primary,
                backgroundColor: LynewedColors.surface,
                labelStyle: TextStyle(
                  color: isSelected
                      ? LynewedColors.primary
                      : LynewedColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color:
                      isSelected ? LynewedColors.primary : LynewedColors.gray300,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
