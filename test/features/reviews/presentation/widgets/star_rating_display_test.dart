import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/reviews/presentation/widgets/star_rating_display.dart';

void main() {
  group('StarRatingDisplay', () {
    testWidgets('displays 5 stars', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingDisplay(rating: 0.0),
          ),
        ),
      );

      // Should find 5 star-related icons
      final starIcons = find.byType(Icon);
      expect(starIcons, findsNWidgets(5));
    });

    testWidgets('displays all empty stars for rating 0.0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingDisplay(rating: 0.0),
          ),
        ),
      );

      final emptyStars = find.byIcon(Icons.star_outline_rounded);
      expect(emptyStars, findsNWidgets(5));
    });

    testWidgets('displays all filled stars for rating 5.0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingDisplay(rating: 5.0),
          ),
        ),
      );

      final filledStars = find.byIcon(Icons.star_rounded);
      expect(filledStars, findsNWidgets(5));
    });

    testWidgets('displays correct stars for rating 3.0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingDisplay(rating: 3.0),
          ),
        ),
      );

      // 3 filled + 2 empty
      final filledStars = find.byIcon(Icons.star_rounded);
      final emptyStars = find.byIcon(Icons.star_outline_rounded);
      expect(filledStars, findsNWidgets(3));
      expect(emptyStars, findsNWidgets(2));
    });

    testWidgets('displays half star for rating 3.5', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingDisplay(rating: 3.5),
          ),
        ),
      );

      // 3 filled + 1 half + 1 empty
      final filledStars = find.byIcon(Icons.star_rounded);
      final halfStars = find.byIcon(Icons.star_half_rounded);
      final emptyStars = find.byIcon(Icons.star_outline_rounded);
      expect(filledStars, findsNWidgets(3));
      expect(halfStars, findsNWidgets(1));
      expect(emptyStars, findsNWidgets(1));
    });

    testWidgets('displays numeric value when showValue is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingDisplay(
              rating: 4.5,
              showValue: true,
            ),
          ),
        ),
      );

      expect(find.text('4.5'), findsOneWidget);
    });

    testWidgets('hides numeric value when showValue is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingDisplay(
              rating: 4.5,
              showValue: false,
            ),
          ),
        ),
      );

      expect(find.text('4.5'), findsNothing);
    });

    testWidgets('uses custom star size', (tester) async {
      const customSize = 24.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingDisplay(
              rating: 1.0,
              starSize: customSize,
            ),
          ),
        ),
      );

      final starIcon = tester.widget<Icon>(find.byIcon(Icons.star_rounded));
      expect(starIcon.size, equals(customSize));
    });

    testWidgets('clamps rating between 0.0 and 5.0', (tester) async {
      // Rating > 5
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingDisplay(rating: 10.0),
          ),
        ),
      );

      // Should show 5 filled stars max
      final filledStars = find.byIcon(Icons.star_rounded);
      expect(filledStars, findsNWidgets(5));
    });

    testWidgets('clamps negative rating to 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingDisplay(rating: -1.0),
          ),
        ),
      );

      // Should show 5 empty stars
      final emptyStars = find.byIcon(Icons.star_outline_rounded);
      expect(emptyStars, findsNWidgets(5));
    });

    testWidgets('displays integer rating as X.0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingDisplay(
              rating: 4.0,
              showValue: true,
            ),
          ),
        ),
      );

      expect(find.text('4.0'), findsOneWidget);
    });
  });
}
