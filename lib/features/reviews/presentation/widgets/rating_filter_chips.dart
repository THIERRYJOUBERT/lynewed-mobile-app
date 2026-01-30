import 'package:flutter/material.dart';
import '../../../../core/design/design.dart';

/// Rating filter with chips (Amazon-style).
///
/// Displays selectable chips: "4+ stars", "3+ stars", etc.
/// More intuitive than a slider for rating filters.
class RatingFilterChips extends StatelessWidget {
  const RatingFilterChips({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// Current minimum rating value (null = any rating).
  final double? value;

  /// Callback when the value changes.
  final ValueChanged<double?> onChanged;

  static const _options = [
    (rating: 5.0, label: '5 stars'),
    (rating: 4.0, label: '4 stars & up'),
    (rating: 3.0, label: '3 stars & up'),
    (rating: 2.0, label: '2 stars & up'),
    (rating: 1.0, label: '1 star & up'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Any rating" chip
        _buildChip(
          label: 'Any rating',
          rating: null,
          isSelected: value == null,
        ),
        const SizedBox(height: LynewedSpacing.sm),

        // Rating options
        ..._options.map((option) => Padding(
              padding: const EdgeInsets.only(bottom: LynewedSpacing.sm),
              child: _buildChip(
                label: option.label,
                rating: option.rating,
                isSelected: value == option.rating,
              ),
            )),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required double? rating,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onChanged(rating),
      child: Row(
        children: [
          // Radio indicator
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? LynewedColors.primary : LynewedColors.gray300,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: LynewedColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: LynewedSpacing.sm),

          // Stars (if rating option)
          if (rating != null) ...[
            _buildStars(rating.toInt()),
            const SizedBox(width: LynewedSpacing.xs),
          ],

          // Label
          Text(
            label,
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: isSelected ? LynewedColors.textPrimary : LynewedColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStars(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isFilled = index < count;
        return Icon(
          isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 18,
          color: isFilled ? LynewedColors.primary : LynewedColors.gray300,
        );
      }),
    );
  }
}
