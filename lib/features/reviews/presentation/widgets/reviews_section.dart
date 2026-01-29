import 'package:flutter/material.dart';
import '../../../../core/design/design.dart';
import '../../domain/entities/pro_rating.dart';
import '../../domain/entities/review.dart';
import 'review_card.dart';
import 'star_rating_display.dart';

/// Section widget displaying reviews for a professional.
///
/// Shows:
/// - Average rating header with stars
/// - Write/Edit review button (if applicable)
/// - List of individual reviews
/// - Empty state when no reviews
class ReviewsSection extends StatelessWidget {
  /// Creates a reviews section.
  const ReviewsSection({
    super.key,
    required this.rating,
    required this.reviews,
    this.myReview,
    this.onWriteReview,
    this.onEditReview,
    this.isLoading = false,
  });

  /// Aggregated rating for the professional. Null if no reviews.
  final ProRating? rating;

  /// List of reviews to display.
  final List<Review> reviews;

  /// Current user's review (if they have reviewed this pro).
  final Review? myReview;

  /// Callback when user taps "Write a review" button.
  /// If null, button is not shown (e.g., pro viewing own profile).
  final VoidCallback? onWriteReview;

  /// Callback when user taps "Edit your review" button.
  /// Only shown when myReview is not null.
  final VoidCallback? onEditReview;

  /// Whether the section is in loading state.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoading();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: LynewedSpacing.lg),
        _buildRatingDisplay(),
        SizedBox(height: LynewedSpacing.md),
        _buildActionButton(),
        if (reviews.isEmpty) ...[
          SizedBox(height: LynewedSpacing.lg),
          _buildEmptyState(),
        ] else ...[
          SizedBox(height: LynewedSpacing.md),
          _buildReviewsList(),
        ],
      ],
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: LynewedSpacing.xxl),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Reviews',
      style: LynewedTextStyles.titleMedium,
    );
  }

  Widget _buildRatingDisplay() {
    if (rating == null || !rating!.hasReviews) {
      return Text(
        'Not rated yet',
        style: LynewedTextStyles.bodyMedium.copyWith(
          color: LynewedColors.textSecondary,
        ),
      );
    }

    return Row(
      children: [
        StarRatingDisplay(
          rating: rating!.averageRating,
          starSize: 18.0,
          showValue: false,
        ),
        SizedBox(width: LynewedSpacing.sm),
        Text(
          rating!.displayRating,
          style: LynewedTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    // Show "Edit your review" if user has reviewed
    if (myReview != null && onEditReview != null) {
      return _ActionButton(
        label: 'Edit your review',
        onTap: onEditReview!,
      );
    }

    // Show "Write a review" if callback provided
    if (onWriteReview != null) {
      return _ActionButton(
        label: 'Write a review',
        onTap: onWriteReview!,
      );
    }

    // No button (pro viewing own profile)
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No reviews yet',
          style: LynewedTextStyles.bodyMedium.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
        if (onWriteReview != null) ...[
          SizedBox(height: LynewedSpacing.xs),
          Text(
            'Be the first to share your experience!',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewsList() {
    return Column(
      children: reviews
          .map((review) => ReviewCard(review: review))
          .toList(),
    );
  }
}

/// Internal action button widget for write/edit review.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: LynewedSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_outlined,
              size: 16,
              color: LynewedColors.primary,
            ),
            SizedBox(width: LynewedSpacing.xs),
            Text(
              label,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
