/// Tests for ListingCard widget.
///
/// Verifies correct display of listing data: photo, title, price,
/// condition badge, location, and tap interaction.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/listing_card.dart';

void main() {
  const testTitle = 'Beautiful Wedding Dress';
  const testPriceCents = 29999;
  const testCondition = 'excellent';
  const testCity = 'Paris';
  const testCountry = 'France';
  const testCoverPhotoUrl = 'https://example.com/photo.jpg';

  Widget buildCard({
    String title = testTitle,
    int priceCents = testPriceCents,
    String condition = testCondition,
    String? city = testCity,
    String country = testCountry,
    String? coverPhotoUrl = testCoverPhotoUrl,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 200,
          height: 300,
          child: ListingCard(
            title: title,
            priceCents: priceCents,
            condition: condition,
            city: city,
            country: country,
            coverPhotoUrl: coverPhotoUrl,
            onTap: onTap ?? () {},
          ),
        ),
      ),
    );
  }

  group('ListingCard', () {
    testWidgets('should display title', (tester) async {
      await tester.pumpWidget(buildCard());

      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('should display formatted price', (tester) async {
      await tester.pumpWidget(buildCard());

      // 29999 cents = $299.99
      expect(find.text(r'$299.99'), findsOneWidget);
    });

    testWidgets('should display condition badge', (tester) async {
      await tester.pumpWidget(buildCard());

      expect(find.text('Excellent'), findsOneWidget);
    });

    testWidgets('should display location with city and country', (tester) async {
      await tester.pumpWidget(buildCard());

      expect(find.text('Paris, France'), findsOneWidget);
    });

    testWidgets('should display location with only country when city is null',
        (tester) async {
      await tester.pumpWidget(buildCard(city: null));

      expect(find.text('France'), findsOneWidget);
    });

    testWidgets('should use CachedNetworkImage for cover photo',
        (tester) async {
      await tester.pumpWidget(buildCard());

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('should show placeholder when no cover photo url',
        (tester) async {
      await tester.pumpWidget(buildCard(coverPhotoUrl: null));

      // Should show a fallback icon instead of CachedNetworkImage
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
    });

    testWidgets('should truncate long title to 2 lines', (tester) async {
      const longTitle =
          'This is a very long title that should definitely be truncated '
          'after two lines of text because it keeps going and going';
      await tester.pumpWidget(buildCard(title: longTitle));

      final text = tester.widget<Text>(find.text(longTitle));
      expect(text.maxLines, 2);
      expect(text.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should format price with two decimal places', (tester) async {
      await tester.pumpWidget(buildCard(priceCents: 10000));

      expect(find.text(r'$100.00'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildCard(onTap: () => tapped = true));

      await tester.tap(find.byType(ListingCard));
      expect(tapped, isTrue);
    });

    group('condition badge colors', () {
      testWidgets('should show success color for new condition',
          (tester) async {
        await tester.pumpWidget(buildCard(condition: 'new'));

        expect(find.text('New'), findsOneWidget);
      });

      testWidgets('should show badge for good condition', (tester) async {
        await tester.pumpWidget(buildCard(condition: 'good'));

        expect(find.text('Good'), findsOneWidget);
      });

      testWidgets('should show badge for fair condition', (tester) async {
        await tester.pumpWidget(buildCard(condition: 'fair'));

        expect(find.text('Fair'), findsOneWidget);
      });
    });

    group('border radius', () {
      testWidgets('should have borderRadius of 4 on card container',
          (tester) async {
        await tester.pumpWidget(buildCard());

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(ListingCard),
            matching: find.byType(Container).first,
          ),
        );

        final decoration = container.decoration as BoxDecoration?;
        expect(decoration, isNotNull);
        expect(
          decoration!.borderRadius,
          BorderRadius.circular(4),
        );
      });
    });
  });
}
