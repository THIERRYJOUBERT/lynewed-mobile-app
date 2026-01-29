import 'package:flutter/material.dart';
import '../../../../core/design/design.dart';
import '../../domain/entities/review.dart';
import '../widgets/star_rating_input.dart';

/// Bottom sheet for submitting or editing a review.
///
/// Provides a star rating input and optional comment field.
/// Supports both create and edit modes.
class ReviewSubmitSheet extends StatefulWidget {
  /// Creates a review submit sheet.
  const ReviewSubmitSheet({
    super.key,
    required this.proId,
    required this.proName,
    this.existingReview,
    required this.onSubmit,
  });

  /// ID of the professional being reviewed.
  final String proId;

  /// Name of the professional (for display).
  final String proName;

  /// Existing review for edit mode (null for new review).
  final Review? existingReview;

  /// Callback when user submits the review.
  /// Returns the rating (1-5) and optional comment.
  final Future<void> Function(int rating, String? comment) onSubmit;

  @override
  State<ReviewSubmitSheet> createState() => _ReviewSubmitSheetState();
}

class _ReviewSubmitSheetState extends State<ReviewSubmitSheet> {
  late int _rating;
  late TextEditingController _commentController;
  bool _isLoading = false;

  /// Returns true if editing an existing review.
  bool get _isEditMode => widget.existingReview != null;

  /// Returns true if form is valid for submission.
  bool get _canSubmit => _rating > 0 && !_isLoading;

  /// Rating labels based on rating value.
  static const Map<int, String> _ratingLabels = {
    1: 'Poor',
    2: 'Fair',
    3: 'Good',
    4: 'Very Good',
    5: 'Excellent',
  };

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 0;
    _commentController = TextEditingController(
      text: widget.existingReview?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    setState(() => _isLoading = true);

    try {
      final comment = _commentController.text.trim();
      await widget.onSubmit(
        _rating,
        comment.isEmpty ? null : comment,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: _isEditMode ? 'Edit Review' : 'Write a Review',
      subtitle: Text(
        widget.proName,
        style: LynewedTextStyles.bodyMedium.copyWith(
          color: LynewedColors.textSecondary,
        ),
      ),
      onClose: () => Navigator.of(context).pop(),
      bottomAction: SizedBox(
        width: double.infinity,
        child: LynewedButton(
          text: _isEditMode ? 'Update Review' : 'Submit Review',
          onPressed: _canSubmit ? _handleSubmit : null,
          isLoading: _isLoading,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating section
          _buildRatingSection(),

          SizedBox(height: LynewedSpacing.formSectionGap),

          // Comment section
          _buildCommentSection(),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Rating',
          style: LynewedTextStyles.sectionTitle,
        ),
        SizedBox(height: LynewedSpacing.labelFieldGap),

        // Stars centered
        Center(
          child: StarRatingInput(
            rating: _rating,
            onRatingChanged: (rating) {
              setState(() => _rating = rating);
            },
            starSize: 40.0,
          ),
        ),

        // Rating label
        if (_rating > 0) ...[
          SizedBox(height: LynewedSpacing.sm),
          Center(
            child: Text(
              _ratingLabels[_rating] ?? '',
              style: LynewedTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Review (optional)',
          style: LynewedTextStyles.sectionTitle,
        ),
        SizedBox(height: LynewedSpacing.labelFieldGap),

        TextFormField(
          controller: _commentController,
          maxLines: 4,
          maxLength: 500,
          textInputAction: TextInputAction.done,
          onEditingComplete: () => FocusScope.of(context).unfocus(),
          style: LynewedTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w300,
          ),
          decoration: InputDecoration(
            hintText: 'Share your experience with this professional...',
            hintStyle: LynewedTextStyles.inputHint,
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
