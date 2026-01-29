import 'package:flutter/material.dart';
import '../../../../core/design/design.dart';
import 'star_rating_display.dart';

/// Slider widget for filtering by minimum rating.
///
/// Displays a slider from 0 to 5 stars with 0.5 increments.
/// Value of null or 0 means "any rating" (no filter).
class RatingFilterSlider extends StatelessWidget {
  /// Creates a rating filter slider.
  const RatingFilterSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// Current minimum rating value (null or 0 = any rating).
  final double? value;

  /// Callback when the value changes.
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    final effectiveValue = value ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with label and current value
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Minimum rating',
              style: LynewedTextStyles.labelMedium,
            ),
            Text(
              _getValueLabel(effectiveValue),
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: effectiveValue > 0
                    ? LynewedColors.primary
                    : LynewedColors.textSecondary,
                fontWeight:
                    effectiveValue > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: LynewedSpacing.sm),

        // Stars and slider row
        Row(
          children: [
            // Star display
            StarRatingDisplay(
              rating: effectiveValue,
              starSize: 20,
              showValue: false,
            ),
            const SizedBox(width: LynewedSpacing.sm),

            // Slider
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: LynewedColors.primary,
                  inactiveTrackColor: LynewedColors.gray200,
                  thumbColor: LynewedColors.primary,
                  overlayColor: LynewedColors.primary.withAlpha(50),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                ),
                child: Slider(
                  value: effectiveValue,
                  min: 0,
                  max: 5,
                  divisions: 10, // 0.5 increments
                  onChanged: (newValue) {
                    // Convert 0 to null (no filter)
                    onChanged(newValue > 0 ? newValue : null);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Returns display label for current value.
  String _getValueLabel(double effectiveValue) {
    if (effectiveValue <= 0) {
      return 'Any rating';
    }
    return '${effectiveValue.toStringAsFixed(1)}+ stars';
  }
}
