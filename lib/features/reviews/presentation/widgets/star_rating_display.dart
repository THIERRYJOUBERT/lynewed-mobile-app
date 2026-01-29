import 'package:flutter/material.dart';
import '../../../../core/design/design.dart';

/// Read-only star rating display widget.
///
/// Displays a rating as 5 stars with support for half-star increments.
/// Used for displaying review ratings on profiles.
class StarRatingDisplay extends StatelessWidget {
  /// Creates a star rating display.
  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.starSize = 16.0,
    this.starColor = LynewedColors.primary,
    this.emptyColor = LynewedColors.gray300,
    this.showValue = true,
  });

  /// Rating value from 0.0 to 5.0.
  final double rating;

  /// Size of each star icon.
  final double starSize;

  /// Color for filled stars.
  final Color starColor;

  /// Color for empty (unfilled) stars.
  final Color emptyColor;

  /// Whether to show the numeric value next to stars.
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    // Clamp rating to valid range
    final clampedRating = rating.clamp(0.0, 5.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) => _buildStar(index, clampedRating)),
        if (showValue) ...[
          SizedBox(width: LynewedSpacing.xs),
          Text(
            clampedRating.toStringAsFixed(1),
            style: LynewedTextStyles.bodyMedium,
          ),
        ],
      ],
    );
  }

  Widget _buildStar(int index, double clampedRating) {
    final starPosition = index + 1;
    final difference = clampedRating - index;

    IconData iconData;
    Color color;

    if (difference >= 1.0) {
      // Full star
      iconData = Icons.star_rounded;
      color = starColor;
    } else if (difference >= 0.5) {
      // Half star
      iconData = Icons.star_half_rounded;
      color = starColor;
    } else {
      // Empty star
      iconData = Icons.star_outline_rounded;
      color = emptyColor;
    }

    return Padding(
      padding: EdgeInsets.only(
        right: starPosition < 5 ? LynewedSpacing.xxs : 0,
      ),
      child: Icon(
        iconData,
        size: starSize,
        color: color,
      ),
    );
  }
}
