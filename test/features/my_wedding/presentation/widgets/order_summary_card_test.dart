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
      int spreadCount = 0,
      int magazinePriceCents = 5900,
      int quantity = 1,
      String? coverPhotoUrl,
      String? weddingTitle,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: OrderSummaryCard(
            format: format ?? MagazineFormats.iconic,
            photoCount: photoCount,
            spreadCount: spreadCount,
            magazinePriceCents: magazinePriceCents,
            quantity: quantity,
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

      testWidgets('should display format size when no spread count',
          (tester) async {
        await tester.pumpWidget(buildWidget(format: MagazineFormats.iconic));
        await tester.pump();

        expect(find.text('21x30cm'), findsOneWidget);
      });

      testWidgets('should display actual spread count when provided',
          (tester) async {
        await tester.pumpWidget(
            buildWidget(format: MagazineFormats.iconic, spreadCount: 5));
        await tester.pump();

        expect(find.text('21x30cm \u2022 5 spreads'), findsOneWidget);
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

      testWidgets('should display shipping note', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pump();

        expect(
            find.text('Shipping calculated at checkout'), findsOneWidget);
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
        await tester.pumpWidget(buildWidget(
          coverPhotoUrl: 'https://example.com/cover.jpg',
        ));
        await tester.pump();

        expect(find.byType(OrderSummaryCard), findsOneWidget);
      });
    });

    group('format variations', () {
      testWidgets('should display GUEST EDITION format', (tester) async {
        await tester.pumpWidget(
            buildWidget(format: MagazineFormats.guestEdition, spreadCount: 4));
        await tester.pump();

        expect(find.text('GUEST EDITION Wedding Magazine'), findsOneWidget);
        expect(find.text('21x30cm \u2022 4 spreads'), findsOneWidget);
      });

      testWidgets('should display MEMORY format', (tester) async {
        await tester.pumpWidget(
            buildWidget(format: MagazineFormats.memory, spreadCount: 12));
        await tester.pump();

        expect(find.text('MEMORY Wedding Magazine'), findsOneWidget);
        expect(find.text('21x30cm \u2022 12 spreads'), findsOneWidget);
      });

      testWidgets('should display COLLECTOR format', (tester) async {
        await tester.pumpWidget(
            buildWidget(format: MagazineFormats.collector, spreadCount: 8));
        await tester.pump();

        expect(find.text('COLLECTOR Wedding Magazine'), findsOneWidget);
        expect(find.text('25x32cm \u2022 8 spreads'), findsOneWidget);
      });
    });

    group('quantity display', () {
      testWidgets('should show quantity row when quantity > 1',
          (tester) async {
        await tester.pumpWidget(buildWidget(
          magazinePriceCents: 5900,
          quantity: 3,
        ));
        await tester.pump();

        expect(find.text('Quantity'), findsOneWidget);
        expect(find.text('x 3'), findsOneWidget);
      });

      testWidgets('should show subtotal when quantity > 1',
          (tester) async {
        await tester.pumpWidget(buildWidget(
          magazinePriceCents: 5900,
          quantity: 3,
        ));
        await tester.pump();

        expect(find.text('Subtotal'), findsOneWidget);
        expect(find.text(r'$177.00'), findsOneWidget);
      });

      testWidgets('should not show quantity row when quantity is 1',
          (tester) async {
        await tester.pumpWidget(buildWidget(
          magazinePriceCents: 5900,
          quantity: 1,
        ));
        await tester.pump();

        expect(find.text('Quantity'), findsNothing);
        expect(find.text('Subtotal'), findsNothing);
      });

      testWidgets('should show unit price as Magazine line for quantity > 1',
          (tester) async {
        await tester.pumpWidget(buildWidget(
          magazinePriceCents: 5900,
          quantity: 2,
        ));
        await tester.pump();

        expect(find.text('Magazine (ICONIC)'), findsOneWidget);
        expect(find.text(r'$59.00'), findsOneWidget);
        expect(find.text('Subtotal'), findsOneWidget);
        expect(find.text(r'$118.00'), findsOneWidget);
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

      testWidgets('should handle prices with cents', (tester) async {
        await tester.pumpWidget(buildWidget(
          magazinePriceCents: 5950, // $59.50
        ));
        await tester.pump();

        expect(find.text(r'$59.50'), findsOneWidget);
      });
    });
  });
}
