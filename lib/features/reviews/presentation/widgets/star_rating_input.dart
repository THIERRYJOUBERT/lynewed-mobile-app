import 'package:flutter/material.dart';
import '../../../../core/design/design.dart';

/// Interactive star rating input widget.
///
/// Displays 5 tappable stars for selecting a rating from 1 to 5.
/// Used in review submission forms.
class StarRatingInput extends StatelessWidget {
  /// Creates a star rating input.
  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starSize = 40.0,
    this.starColor = LynewedColors.primary,
    this.emptyColor = LynewedColors.gray300,
  });

  /// Current rating value (0-5). 0 means no rating selected.
  final int rating;

  /// Callback when user taps a star.
  final ValueChanged<int> onRatingChanged;

  /// Size of each star icon.
  final double starSize;

  /// Color for filled stars.
  final Color starColor;

  /// Color for empty (unselected) stars.
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    // Clamp rating to valid range
    final clampedRating = rating.clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isFilled = starNumber <= clampedRating;

        return GestureDetector(
          onTap: () => onRatingChanged(starNumber),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: LynewedSpacing.xs),
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: starSize,
              color: isFilled ? starColor : emptyColor,
            ),
          ),
        );
      }),
    );
  }
}
