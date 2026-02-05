/// FilterBadgeRow widget - Displays active filter badges on the feed.
///
/// Shows a horizontal scrollable row of filter summary chips.
/// Each badge has a remove (X) button to clear that specific filter.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../data/sizes_data.dart';
import '../../domain/entities/listing_filter.dart';

/// Horizontal scrollable row of active filter badges.
///
/// Displays a summary chip for each active filter dimension.
/// Tapping the X on a badge removes that filter and triggers [onFilterChanged].
/// A "Clear All" button is appended at the end.
class FilterBadgeRow extends StatelessWidget {
  /// Creates a filter badge row.
  const FilterBadgeRow({
    required this.filter,
    required this.onFilterChanged,
    super.key,
  });

  /// The current active filter.
  final ListingFilter filter;

  /// Callback when a filter is removed or cleared.
  final ValueChanged<ListingFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    if (!filter.hasActiveFilters) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Category badge
          if (filter.category != null)
            _buildBadge(
              label: categoryLabels[filter.category!] ?? filter.category!,
              onRemove: () => onFilterChanged(
                filter.copyWith(clearCategory: true, clearSizes: true, clearBrands: true),
              ),
            ),

          // Price range badge
          if (filter.minPriceCents != null || filter.maxPriceCents != null)
            _buildBadge(
              label: _formatPriceRange(
                filter.minPriceCents,
                filter.maxPriceCents,
              ),
              onRemove: () => onFilterChanged(
                filter.copyWith(clearPriceRange: true),
              ),
            ),

          // Sizes badge
          if (filter.sizes != null && filter.sizes!.isNotEmpty)
            _buildBadge(
              label: filter.sizes!.length == 1
                  ? filter.sizes!.first
                  : '${filter.sizes!.length} sizes',
              onRemove: () => onFilterChanged(
                filter.copyWith(clearSizes: true),
              ),
            ),

          // Brands badge
          if (filter.brands != null && filter.brands!.isNotEmpty)
            _buildBadge(
              label: filter.brands!.length == 1
                  ? filter.brands!.first
                  : '${filter.brands!.length} brands',
              onRemove: () => onFilterChanged(
                filter.copyWith(clearBrands: true),
              ),
            ),

          // Conditions badge
          if (filter.conditions != null && filter.conditions!.isNotEmpty)
            _buildBadge(
              label: filter.conditions!.length == 1
                  ? conditionLabels[filter.conditions!.first] ??
                      filter.conditions!.first
                  : '${filter.conditions!.length} conditions',
              onRemove: () => onFilterChanged(
                filter.copyWith(clearConditions: true),
              ),
            ),

          // Country badge
          if (filter.country != null)
            _buildBadge(
              label: filter.country!,
              onRemove: () => onFilterChanged(
                filter.copyWith(clearCountry: true),
              ),
            ),

          // Clear all button
          if (filter.activeFilterCount > 1)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: GestureDetector(
                onTap: () => onFilterChanged(const ListingFilter.empty()),
                child: Text(
                  'Clear All',
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: LynewedColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: LynewedTextStyles.chipText.copyWith(
              color: LynewedColors.textOnPrimary,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: LynewedColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a price range for display.
  String _formatPriceRange(int? minCents, int? maxCents) {
    final minDollars = minCents != null ? (minCents / 100).toInt() : 0;
    final maxDollars = maxCents != null ? (maxCents / 100).toInt() : null;

    if (maxDollars == null) {
      return '\$$minDollars+';
    }
    if (minCents == null || minCents == 0) {
      return 'Up to \$$maxDollars';
    }
    return '\$$minDollars - \$$maxDollars';
  }
}
