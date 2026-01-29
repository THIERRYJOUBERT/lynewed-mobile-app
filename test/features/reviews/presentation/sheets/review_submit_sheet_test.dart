import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/reviews/domain/entities/review.dart';
import 'package:lynewed_beta/features/reviews/presentation/sheets/review_submit_sheet.dart';
import 'package:lynewed_beta/features/reviews/presentation/widgets/star_rating_input.dart';

void main() {
  group('ReviewSubmitSheet', () {
    // Helper to tap on a specific star (1-5)
    Future<void> tapStar(WidgetTester tester, int starNumber) async {
      // Find the StarRatingInput widget
      final starRating = find.byType(StarRatingInput);
      expect(starRating, findsOneWidget);

      // Get the center position to calculate star positions
      final center = tester.getCenter(starRating);

      // Calculate approximate position of the star (stars are 40px + 8px padding)
      // Stars are centered, so we need to find the row width first
      final starSize = 40.0;
      final padding = 8.0; // 4px on each side
      final totalWidth = 5 * (starSize + padding);
      final startX = center.dx - totalWidth / 2;
      final starX = startX + (starNumber - 1) * (starSize + padding) + starSize / 2 + padding / 2;

      await tester.tapAt(Offset(starX, center.dy));
      await tester.pump();
    }

    testWidgets('displays professional name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewSubmitSheet(
              proId: 'pro-123',
              proName: 'John Photography',
              onSubmit: (_, __) async {},
            ),
          ),
        ),
      );

      expect(find.text('John Photography'), findsOneWidget);
    });

    testWidgets('displays star rating input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewSubmitSheet(
              proId: 'pro-123',
              proName: 'John Photography',
              onSubmit: (_, __) async {},
            ),
          ),
        ),
      );

      expect(find.byType(StarRatingInput), findsOneWidget);
    });

    testWidgets('displays comment text field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewSubmitSheet(
              proId: 'pro-123',
              proName: 'John Photography',
              onSubmit: (_, __) async {},
            ),
          ),
        ),
      );

      // Should find a TextField for comment
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('submit button is disabled when no rating selected',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewSubmitSheet(
              proId: 'pro-123',
              proName: 'John Photography',
              onSubmit: (_, __) async {},
            ),
          ),
        ),
      );

      // Find submit button
      final submitButton = find.widgetWithText(ElevatedButton, 'Submit Review');
      expect(submitButton, findsOneWidget);

      // Button should be disabled (onPressed is null)
      final button = tester.widget<ElevatedButton>(submitButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('submit button is enabled when rating is selected',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewSubmitSheet(
              proId: 'pro-123',
              proName: 'John Photography',
              onSubmit: (_, __) async {},
            ),
          ),
        ),
      );

      // Tap on 4th star to select rating
      await tapStar(tester, 4);

      // Button should now be enabled
      final submitButton = find.widgetWithText(ElevatedButton, 'Submit Review');
      final button = tester.widget<ElevatedButton>(submitButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('comment is optional - button enabled with rating only',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewSubmitSheet(
              proId: 'pro-123',
              proName: 'John Photography',
              onSubmit: (_, __) async {},
            ),
          ),
        ),
      );

      // Select rating without entering comment
      await tapStar(tester, 5);

      // Button should be enabled
      final submitButton = find.widgetWithText(ElevatedButton, 'Submit Review');
      final button = tester.widget<ElevatedButton>(submitButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('calls onSubmit with rating and comment', (tester) async {
      int? capturedRating;
      String? capturedComment;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewSubmitSheet(
              proId: 'pro-123',
              proName: 'John Photography',
              onSubmit: (rating, comment) async {
                capturedRating = rating;
                capturedComment = comment;
              },
            ),
          ),
        ),
      );

      // Select 5 star rating
      await tapStar(tester, 5);

      // Enter comment
      final textField = find.byType(TextFormField);
      await tester.enterText(textField, 'Amazing photographer!');
      await tester.pump();

      // Tap submit
      final submitButton = find.widgetWithText(ElevatedButton, 'Submit Review');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(capturedRating, equals(5));
      expect(capturedComment, equals('Amazing photographer!'));
    });

    testWidgets('pre-fills existing review in edit mode', (tester) async {
      final existingReview = Review(
        id: 'review-123',
        proId: 'pro-123',
        brideId: 'bride-456',
        rating: 4,
        comment: 'Great work!',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewSubmitSheet(
              proId: 'pro-123',
              proName: 'John Photography',
              existingReview: existingReview,
              onSubmit: (_, __) async {},
            ),
          ),
        ),
      );

      // Check comment is pre-filled
      final textField = find.byType(TextFormField);
      final textFormField = tester.widget<TextFormField>(textField);
      expect(textFormField.controller?.text, equals('Great work!'));

      // Check rating is pre-filled (4 filled stars + 1 empty)
      final filledStars = find.byIcon(Icons.star_rounded);
      final emptyStars = find.byIcon(Icons.star_outline_rounded);
      expect(filledStars, findsNWidgets(4));
      expect(emptyStars, findsNWidgets(1));
    });

    testWidgets('shows "Update Review" button in edit mode', (tester) async {
      final existingReview = Review(
        id: 'review-123',
        proId: 'pro-123',
        brideId: 'bride-456',
        rating: 4,
        comment: 'Great work!',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewSubmitSheet(
              proId: 'pro-123',
              proName: 'John Photography',
              existingReview: existingReview,
              onSubmit: (_, __) async {},
            ),
          ),
        ),
      );

      // Should show "Update Review" instead of "Submit Review"
      expect(find.text('Update Review'), findsOneWidget);
      expect(find.text('Submit Review'), findsNothing);
    });

    testWidgets('displays loading indicator during submission', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewSubmitSheet(
              proId: 'pro-123',
              proName: 'John Photography',
              onSubmit: (_, __) async {
                // Simulate slow submission
                await Future.delayed(const Duration(seconds: 1));
              },
            ),
          ),
        ),
      );

      // Select rating
      await tapStar(tester, 5);

      // Tap submit
      final submitButton = find.widgetWithText(ElevatedButton, 'Submit Review');
      await tester.tap(submitButton);
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future
      await tester.pumpAndSettle();
    });

    testWidgets('displays rating labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewSubmitSheet(
              proId: 'pro-123',
              proName: 'John Photography',
              onSubmit: (_, __) async {},
            ),
          ),
        ),
      );

      // Select 5 star rating
      await tapStar(tester, 5);

      // Should show "Excellent" label for 5 stars
      expect(find.text('Excellent'), findsOneWidget);
    });

    testWidgets('displays different labels for different ratings',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewSubmitSheet(
              proId: 'pro-123',
              proName: 'John Photography',
              onSubmit: (_, __) async {},
            ),
          ),
        ),
      );

      // Test each rating label
      final labels = ['Poor', 'Fair', 'Good', 'Very Good', 'Excellent'];

      for (var i = 0; i < 5; i++) {
        await tapStar(tester, i + 1);
        expect(find.text(labels[i]), findsOneWidget);
      }
    });

    testWidgets('comment has max 500 characters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewSubmitSheet(
              proId: 'pro-123',
              proName: 'John Photography',
              onSubmit: (_, __) async {},
            ),
          ),
        ),
      );

      // Enter more than 500 characters
      final textField = find.byType(TextFormField);
      final longText = 'A' * 600; // 600 characters
      await tester.enterText(textField, longText);
      await tester.pump();

      // The field should truncate to 500 characters
      final textFormField = tester.widget<TextFormField>(textField);
      expect(textFormField.controller!.text.length, equals(500));
    });
  });
}
