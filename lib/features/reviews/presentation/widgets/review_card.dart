import 'package:flutter/material.dart';
import '../../../../core/design/design.dart';
import '../../domain/entities/review.dart';
import 'star_rating_display.dart';

/// Card widget displaying a single review.
///
/// Shows the bride's avatar, name, star rating, optional comment, and time ago.
/// Used within ReviewsSection to display individual reviews.
class ReviewCard extends StatelessWidget {
  /// Creates a review card.
  const ReviewCard({
    super.key,
    required this.review,
  });

  /// The review to display.
  final Review review;

  @override
  Widget build(BuildContext context) {
    final displayName = review.brideName ?? 'Anonymous';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: LynewedSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Name + Time
          Row(
            children: [
              _buildAvatar(initial),
              SizedBox(width: LynewedSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      displayName,
                      style: LynewedTextStyles.titleSmall,
                    ),
                    SizedBox(height: LynewedSpacing.xxs),
                    // Rating and time
                    Row(
                      children: [
                        StarRatingDisplay(
                          rating: review.rating.toDouble(),
                          starSize: 14.0,
                        ),
                        SizedBox(width: LynewedSpacing.sm),
                        Text(
                          review.timeAgo,
                          style: LynewedTextStyles.labelLarge.copyWith(
                            color: LynewedColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Comment (if present)
          if (review.hasComment) ...[
            SizedBox(height: LynewedSpacing.sm),
            Text(
              review.comment!,
              style: LynewedTextStyles.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String initial) {
    if (review.brideAvatarUrl != null && review.brideAvatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(review.brideAvatarUrl!),
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: LynewedColors.surface,
      child: Text(
        initial,
        style: LynewedTextStyles.titleSmall.copyWith(
          color: LynewedColors.textSecondary,
        ),
      ),
    );
  }
}
