import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/reviews/presentation/widgets/star_rating_input.dart';

void main() {
  group('StarRatingInput', () {
    testWidgets('displays 5 stars', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRatingInput(
              rating: 0,
              onRatingChanged: (_) {},
            ),
          ),
        ),
      );

      // Should find 5 star icons (either filled or outline)
      final starIcons = find.byType(Icon);
      expect(starIcons, findsNWidgets(5));
    });

    testWidgets('displays empty stars when rating is 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRatingInput(
              rating: 0,
              onRatingChanged: (_) {},
            ),
          ),
        ),
      );

      // All stars should be outline (empty)
      final outlineStars = find.byIcon(Icons.star_outline_rounded);
      expect(outlineStars, findsNWidgets(5));
    });

    testWidgets('displays filled stars based on rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRatingInput(
              rating: 3,
              onRatingChanged: (_) {},
            ),
          ),
        ),
      );

      // 3 filled stars, 2 empty stars
      final filledStars = find.byIcon(Icons.star_rounded);
      final emptyStars = find.byIcon(Icons.star_outline_rounded);
      expect(filledStars, findsNWidgets(3));
      expect(emptyStars, findsNWidgets(2));
    });

    testWidgets('tapping star 4 fills stars 1-4', (tester) async {
      int? capturedRating;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRatingInput(
              rating: 0,
              onRatingChanged: (rating) => capturedRating = rating,
            ),
          ),
        ),
      );

      // Find all star wrappers (GestureDetector or InkWell)
      final starButtons = find.byType(GestureDetector);
      expect(starButtons, findsAtLeast(5));

      // Tap the 4th star (index 3)
      await tester.tap(starButtons.at(3));
      await tester.pump();

      expect(capturedRating, equals(4));
    });

    testWidgets('tapping star 5 when rating is 3 fills all 5 stars',
        (tester) async {
      int? capturedRating;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRatingInput(
              rating: 3,
              onRatingChanged: (rating) => capturedRating = rating,
            ),
          ),
        ),
      );

      // Find all star buttons
      final starButtons = find.byType(GestureDetector);

      // Tap the 5th star (index 4)
      await tester.tap(starButtons.at(4));
      await tester.pump();

      expect(capturedRating, equals(5));
    });

    testWidgets('uses custom star size', (tester) async {
      const customSize = 32.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRatingInput(
              rating: 1,
              onRatingChanged: (_) {},
              starSize: customSize,
            ),
          ),
        ),
      );

      final starIcon = tester.widget<Icon>(find.byIcon(Icons.star_rounded));
      expect(starIcon.size, equals(customSize));
    });

    testWidgets('uses custom colors', (tester) async {
      const customFilledColor = Colors.amber;
      const customEmptyColor = Colors.grey;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRatingInput(
              rating: 2,
              onRatingChanged: (_) {},
              starColor: customFilledColor,
              emptyColor: customEmptyColor,
            ),
          ),
        ),
      );

      final filledStar = tester.widget<Icon>(find.byIcon(Icons.star_rounded).first);
      final emptyStar = tester.widget<Icon>(find.byIcon(Icons.star_outline_rounded).first);

      expect(filledStar.color, equals(customFilledColor));
      expect(emptyStar.color, equals(customEmptyColor));
    });

    testWidgets('rating is clamped between 0 and 5', (tester) async {
      // Test with rating > 5 (should display as 5 filled)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRatingInput(
              rating: 10, // Out of range
              onRatingChanged: (_) {},
            ),
          ),
        ),
      );

      // Should show 5 filled stars max
      final filledStars = find.byIcon(Icons.star_rounded);
      expect(filledStars, findsNWidgets(5));
    });

    testWidgets('negative rating is treated as 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRatingInput(
              rating: -1, // Out of range
              onRatingChanged: (_) {},
            ),
          ),
        ),
      );

      // Should show 5 empty stars
      final emptyStars = find.byIcon(Icons.star_outline_rounded);
      expect(emptyStars, findsNWidgets(5));
    });
  });
}
