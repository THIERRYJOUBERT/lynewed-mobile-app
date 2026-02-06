/// Date group header for the guest album masonry grid.
///
/// Displays a date label and item count for each date section.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// Header widget for a date-grouped section in the album grid.
///
/// Layout: Today                    4 items
class DateGroupHeader extends StatelessWidget {
  /// Creates a date group header.
  const DateGroupHeader({
    super.key,
    required this.label,
    required this.itemCount,
  });

  /// The date label (e.g., "Today", "Yesterday", "Jan 28").
  final String label;

  /// Number of items in this date group.
  final int itemCount;

  /// Formats a DateTime into a human-readable date label.
  static String formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Yesterday';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: LynewedTextStyles.titleSmall.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
          Text(
            '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
            style: LynewedTextStyles.labelMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
