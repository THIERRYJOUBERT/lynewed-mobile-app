import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/reviews/domain/entities/pro_rating.dart';
import 'package:lynewed_beta/features/reviews/domain/entities/review.dart';
import 'package:lynewed_beta/features/reviews/presentation/widgets/reviews_section.dart';

void main() {
  group('ReviewsSection', () {
    // ==============================================================
    // SETUP
    // ==============================================================

    late ProRating rating;
    late List<Review> reviews;
    late Review myReview;

    setUp(() {
      rating = const ProRating(
        proId: 'pro-456',
        averageRating: 4.5,
        reviewCount: 12,
      );

      reviews = [
        Review(
          id: 'review-1',
          proId: 'pro-456',
          brideId: 'bride-1',
          rating: 5,
          comment: 'Excellent!',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          brideName: 'Marie Dupont',
        ),
        Review(
          id: 'review-2',
          proId: 'pro-456',
          brideId: 'bride-2',
          rating: 4,
          comment: 'Very good service.',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          brideName: 'Sophie Martin',
        ),
        Review(
          id: 'review-3',
          proId: 'pro-456',
          brideId: 'bride-3',
          rating: 4,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          brideName: 'Claire Bernard',
        ),
      ];

      myReview = Review(
        id: 'my-review',
        proId: 'pro-456',
        brideId: 'current-user',
        rating: 5,
        comment: 'My review comment.',
        createdAt: DateTime.now(),
        brideName: 'Current User',
      );
    });

    // ==============================================================
    // AC1: Rating Display
    // Given pro-A has average rating 4.5 with 12 reviews
    // When viewing pro-A's profile
    // Then "4.5/5 (12 reviews)" should be displayed
    // And 4.5 stars should be visually shown
    // ==============================================================

    testWidgets('AC1: should display average rating with count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewsSection(
              rating: rating,
              reviews: reviews,
            ),
          ),
        ),
      );

      // Should display formatted rating "4.5/5 (12 reviews)"
      expect(find.textContaining('4.5'), findsOneWidget);
      expect(find.textContaining('12'), findsOneWidget);
      expect(find.textContaining('reviews'), findsOneWidget);
    });

    testWidgets('AC1: should display star rating visually', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewsSection(
              rating: rating,
              reviews: reviews,
            ),
          ),
        ),
      );

      // Should find star icons for rating display
      expect(find.byIcon(Icons.star_rounded), findsWidgets);
      // For 4.5 rating, should find half star
      expect(find.byIcon(Icons.star_half_rounded), findsOneWidget);
    });

    // ==============================================================
    // AC2: Review List
    // Given pro-B has 5 reviews
    // When expanding the reviews section
    // Then all 5 reviews should be listed
    // ==============================================================

    testWidgets('AC2: should display all reviews in list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReviewsSection(
                rating: rating,
                reviews: reviews,
              ),
            ),
          ),
        ),
      );

      // Should find all reviewer names
      expect(find.text('Marie Dupont'), findsOneWidget);
      expect(find.text('Sophie Martin'), findsOneWidget);
      expect(find.text('Claire Bernard'), findsOneWidget);
    });

    // ==============================================================
    // AC3: Empty State
    // Given pro-C has no reviews
    // When viewing pro-C's profile
    // Then "Not rated yet" message should be displayed
    // ==============================================================

    testWidgets('AC3: should display empty state when no reviews',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReviewsSection(
              rating: null,
              reviews: [],
            ),
          ),
        ),
      );

      // Should display empty state message
      expect(find.textContaining('No reviews yet'), findsOneWidget);
    });

    testWidgets('AC3: should display "Not rated yet" for null rating',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReviewsSection(
              rating: null,
              reviews: [],
            ),
          ),
        ),
      );

      // Should display "Not rated yet" or similar message
      expect(
        find.textContaining('Not rated'),
        findsOneWidget,
      );
    });

    // ==============================================================
    // AC4: Write a Review Button
    // Given bride is viewing pro-D's profile
    // And bride has not reviewed pro-D
    // When seeing the reviews section
    // Then "Write a review" button should be displayed
    // ==============================================================

    testWidgets('AC4: should display "Write a review" button when onWriteReview provided',
        (tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewsSection(
              rating: rating,
              reviews: reviews,
              onWriteReview: () => buttonPressed = true,
            ),
          ),
        ),
      );

      // Should find "Write a review" button
      expect(find.text('Write a review'), findsOneWidget);

      // Tap the button
      await tester.tap(find.text('Write a review'));
      await tester.pump();

      expect(buttonPressed, true);
    });

    // ==============================================================
    // AC5: Edit Your Review Button
    // Given bride has already reviewed pro-E
    // When viewing pro-E's profile
    // Then "Edit your review" button should be displayed
    // ==============================================================

    testWidgets('AC5: should display "Edit your review" when myReview exists',
        (tester) async {
      bool editPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewsSection(
              rating: rating,
              reviews: reviews,
              myReview: myReview,
              onEditReview: () => editPressed = true,
            ),
          ),
        ),
      );

      // Should find "Edit your review" button
      expect(find.text('Edit your review'), findsOneWidget);
      // Should NOT find "Write a review" button
      expect(find.text('Write a review'), findsNothing);

      // Tap the button
      await tester.tap(find.text('Edit your review'));
      await tester.pump();

      expect(editPressed, true);
    });

    // ==============================================================
    // AC6: Professional Cannot Review Themselves
    // Given professional is viewing their own profile
    // When seeing the reviews section
    // Then no "Write a review" button should be displayed
    // ==============================================================

    testWidgets('AC6: should not display any button when callbacks are null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewsSection(
              rating: rating,
              reviews: reviews,
              // No onWriteReview or onEditReview callback = pro viewing own profile
            ),
          ),
        ),
      );

      // Should NOT find either button
      expect(find.text('Write a review'), findsNothing);
      expect(find.text('Edit your review'), findsNothing);
    });

    // ==============================================================
    // AC7: Review Without Comment
    // Given a review has no comment
    // When displaying the review card
    // Then only the rating and metadata should be shown
    // ==============================================================

    testWidgets('AC7: reviews without comments should not show empty space',
        (tester) async {
      final reviewsWithNoComments = [
        Review(
          id: 'review-no-comment',
          proId: 'pro-456',
          brideId: 'bride-x',
          rating: 4,
          comment: null,
          createdAt: DateTime.now(),
          brideName: 'Test User',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewsSection(
              rating: const ProRating(
                proId: 'pro-456',
                averageRating: 4.0,
                reviewCount: 1,
              ),
              reviews: reviewsWithNoComments,
            ),
          ),
        ),
      );

      // Should display the reviewer name
      expect(find.text('Test User'), findsOneWidget);

      // Should display rating stars
      expect(find.byIcon(Icons.star_rounded), findsWidgets);
    });

    // ==============================================================
    // LOADING STATE
    // ==============================================================

    testWidgets('should display loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReviewsSection(
              rating: null,
              reviews: [],
              isLoading: true,
            ),
          ),
        ),
      );

      // Should find loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // ==============================================================
    // SECTION HEADER
    // ==============================================================

    testWidgets('should display "Reviews" section title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewsSection(
              rating: rating,
              reviews: reviews,
            ),
          ),
        ),
      );

      // Should find "Reviews" header
      expect(find.text('Reviews'), findsOneWidget);
    });

    // ==============================================================
    // BE THE FIRST ENCOURAGEMENT
    // ==============================================================

    testWidgets('should show "Be the first!" encouragement in empty state',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewsSection(
              rating: null,
              reviews: const [],
              onWriteReview: () {},
            ),
          ),
        ),
      );

      // Should find encouragement text
      expect(
        find.textContaining('Be the first'),
        findsOneWidget,
      );
    });
  });
}
