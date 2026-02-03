/// Tests for OrderSummaryCard widget.
///
/// Comprehensive tests for order summary display.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_format.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/order_summary_card.dart';

void main() {
  group('OrderSummaryCard', () {
    Widget buildWidget({
      MagazineFormat? format,
      int photoCount = 25,
      int magazinePriceCents = 5900,
      int shippingCostCents = 1500,
      String? coverPhotoUrl,
      String? weddingTitle,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: OrderSummaryCard(
            format: format ?? MagazineFormats.iconic,
            photoCount: photoCount,
            magazinePriceCents: magazinePriceCents,
            shippingCostCents: shippingCostCents,
            coverPhotoUrl: coverPhotoUrl,
            weddingTitle: weddingTitle,
          ),
        ),
      );
    }

    group('format display', () {
      testWidgets('should display format name', (tester) async {
        await tester.pumpWidget(buildWidget(format: MagazineFormats.iconic));
        await tester.pump();

        expect(find.text('ICONIC Wedding Magazine'), findsOneWidget);
      });

      testWidgets('should display format size and spreads', (tester) async {
        await tester.pumpWidget(buildWidget(format: MagazineFormats.iconic));
        await tester.pump();

        expect(find.text('21x30cm - 40 spreads'), findsOneWidget);
      });

      testWidgets('should display photo count', (tester) async {
        await tester.pumpWidget(buildWidget(photoCount: 30));
        await tester.pump();

        expect(find.text('30 photos'), findsOneWidget);
      });
    });

    group('pricing display', () {
      testWidgets('should display magazine price', (tester) async {
        await tester
            .pumpWidget(buildWidget(magazinePriceCents: 5900, photoCount: 25));
        await tester.pump();

        expect(find.text('Magazine (ICONIC)'), findsOneWidget);
        expect(find.text(r'$59.00'), findsOneWidget);
      });

      testWidgets('should display shipping cost', (tester) async {
        await tester.pumpWidget(buildWidget(shippingCostCents: 1500));
        await tester.pump();

        expect(find.text('Shipping'), findsOneWidget);
        expect(find.text(r'$15.00'), findsOneWidget);
      });

      testWidgets('should display total', (tester) async {
        await tester.pumpWidget(buildWidget(
          magazinePriceCents: 5900,
          shippingCostCents: 1500,
        ));
        await tester.pump();

        expect(find.text('Total'), findsOneWidget);
        expect(find.text(r'$74.00'), findsOneWidget);
      });

      testWidgets('should calculate total correctly', (tester) async {
        await tester.pumpWidget(buildWidget(
          magazinePriceCents: 8900,
          shippingCostCents: 2500,
        ));
        await tester.pump();

        // Total should be $89 + $25 = $114
        expect(find.text(r'$114.00'), findsOneWidget);
      });
    });

    group('thumbnail', () {
      testWidgets('should display placeholder when no cover photo',
          (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pump();

        expect(find.byIcon(Icons.auto_stories_outlined), findsOneWidget);
      });

      testWidgets('should display wedding title in placeholder',
          (tester) async {
        await tester.pumpWidget(buildWidget(weddingTitle: 'John & Jane'));
        await tester.pump();

        expect(find.text('John & Jane'), findsOneWidget);
      });

      testWidgets('should handle cover photo URL provided',
          (tester) async {
        // Just verify the widget builds without error with a cover photo URL
        await tester.pumpWidget(buildWidget(
          coverPhotoUrl: 'https://example.com/cover.jpg',
        ));
        await tester.pump();

        // The CachedNetworkImage handles the display
        expect(find.byType(OrderSummaryCard), findsOneWidget);
      });
    });

    group('format variations', () {
      testWidgets('should display GUEST EDITION format', (tester) async {
        await tester
            .pumpWidget(buildWidget(format: MagazineFormats.guestEdition));
        await tester.pump();

        expect(find.text('GUEST EDITION Wedding Magazine'), findsOneWidget);
        expect(find.text('21x30cm - 20 spreads'), findsOneWidget);
      });

      testWidgets('should display MEMORY format', (tester) async {
        await tester.pumpWidget(buildWidget(format: MagazineFormats.memory));
        await tester.pump();

        expect(find.text('MEMORY Wedding Magazine'), findsOneWidget);
        expect(find.text('21x30cm - 60 spreads'), findsOneWidget);
      });

      testWidgets('should display COLLECTOR format', (tester) async {
        await tester.pumpWidget(buildWidget(format: MagazineFormats.collector));
        await tester.pump();

        expect(find.text('COLLECTOR Wedding Magazine'), findsOneWidget);
        expect(find.text('25x32cm - 60 spreads'), findsOneWidget);
      });
    });

    group('edge cases', () {
      testWidgets('should handle zero photo count', (tester) async {
        await tester.pumpWidget(buildWidget(photoCount: 0));
        await tester.pump();

        expect(find.text('0 photos'), findsOneWidget);
      });

      testWidgets('should handle single photo', (tester) async {
        await tester.pumpWidget(buildWidget(photoCount: 1));
        await tester.pump();

        expect(find.text('1 photos'), findsOneWidget);
      });

      testWidgets('should handle free shipping', (tester) async {
        await tester.pumpWidget(buildWidget(shippingCostCents: 0));
        await tester.pump();

        expect(find.text(r'$0.00'), findsOneWidget);
      });

      testWidgets('should handle prices with cents', (tester) async {
        await tester.pumpWidget(buildWidget(
          magazinePriceCents: 5950, // $59.50
          shippingCostCents: 1599, // $15.99
        ));
        await tester.pump();

        expect(find.text(r'$59.50'), findsOneWidget);
        expect(find.text(r'$15.99'), findsOneWidget);
        expect(find.text(r'$75.49'), findsOneWidget);
      });
    });
  });
}
