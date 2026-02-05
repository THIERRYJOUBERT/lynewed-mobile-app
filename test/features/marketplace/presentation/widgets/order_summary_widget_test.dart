/// Tests for OrderSummaryWidget.
///
/// Verifies order summary display with price breakdown.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/order_summary_widget.dart';

void main() {
  group('OrderSummaryWidget', () {
    Widget buildWidget({
      String itemTitle = 'Beautiful Wedding Dress',
      int itemPriceCents = 29999,
      int shippingCostCents = 1250,
      int platformFeeCents = 3000,
      int totalCents = 31249,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OrderSummaryWidget(
              itemTitle: itemTitle,
              itemPriceCents: itemPriceCents,
              shippingCostCents: shippingCostCents,
              platformFeeCents: platformFeeCents,
              totalCents: totalCents,
            ),
          ),
        ),
      );
    }

    group('rendering', () {
      testWidgets('should show section title', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        expect(find.text('Order Summary'), findsOneWidget);
      });

      testWidgets('should show item title and price', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        expect(find.text('Beautiful Wedding Dress'), findsOneWidget);
        expect(find.text('\$299.99'), findsOneWidget);
      });

      testWidgets('should show shipping cost', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        expect(find.text('Shipping'), findsOneWidget);
        expect(find.text('\$12.50'), findsOneWidget);
      });

      testWidgets('should show platform fee', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        expect(find.text('Platform fee (10%)'), findsOneWidget);
        expect(find.text('\$30.00'), findsOneWidget);
      });

      testWidgets('should show total', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        expect(find.text('Total'), findsOneWidget);
        expect(find.text('\$312.49'), findsOneWidget);
      });

      testWidgets('should show informational note', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        expect(
          find.textContaining('platform fee is included for transparency'),
          findsOneWidget,
        );
      });
    });

    group('price formatting', () {
      testWidgets('should format zero cents correctly', (tester) async {
        await tester.pumpWidget(buildWidget(
          itemPriceCents: 10000,
          shippingCostCents: 0,
          platformFeeCents: 1000,
          totalCents: 10000,
        ));
        await tester.pumpAndSettle();

        expect(find.text('\$100.00'), findsAtLeast(1));
        expect(find.text('\$0.00'), findsOneWidget);
      });

      testWidgets('should format single-digit cents', (tester) async {
        await tester.pumpWidget(buildWidget(
          itemPriceCents: 1001,
          shippingCostCents: 500,
          platformFeeCents: 100,
          totalCents: 1501,
        ));
        await tester.pumpAndSettle();

        expect(find.text('\$10.01'), findsOneWidget);
        expect(find.text('\$5.00'), findsOneWidget);
      });
    });
  });
}
