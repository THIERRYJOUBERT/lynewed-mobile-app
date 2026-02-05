/// Category filter chips for marketplace feed.
///
/// Horizontal row of filter chips: All, Dresses, Shoes.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// Horizontal row of category filter chips for the marketplace feed.
///
/// Shows "All", "Dresses", and "Shoes" options. Selected category is
/// highlighted. Tapping a chip triggers [onCategoryChanged] with the
/// category value (null for "All", 'dress', or 'shoes').
class CategoryChips extends StatelessWidget {
  /// Creates category chips.
  const CategoryChips({
    required this.selectedCategory,
    required this.onCategoryChanged,
    super.key,
  });

  /// Currently selected category (null = All).
  final String? selectedCategory;

  /// Callback when category selection changes.
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          LynewedChip(
            label: 'All',
            selected: selectedCategory == null,
            onSelected: (_) => onCategoryChanged(null),
          ),
          const SizedBox(width: LynewedSpacing.sm),
          LynewedChip(
            label: 'Dresses',
            selected: selectedCategory == 'dress',
            onSelected: (_) => onCategoryChanged('dress'),
          ),
          const SizedBox(width: LynewedSpacing.sm),
          LynewedChip(
            label: 'Shoes',
            selected: selectedCategory == 'shoes',
            onSelected: (_) => onCategoryChanged('shoes'),
          ),
        ],
      ),
    );
  }
}
