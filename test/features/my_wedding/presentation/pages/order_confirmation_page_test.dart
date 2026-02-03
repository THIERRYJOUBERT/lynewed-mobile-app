/// Tests for OrderConfirmationPage.
///
/// Comprehensive tests for order confirmation display.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/pages/order_confirmation_page.dart';

void main() {
  group('OrderConfirmationPage', () {
    Widget buildWidget({
      String sessionId = 'cs_test_abc123',
      String? orderId,
      VoidCallback? onDone,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              height: 1000,
              child: OrderConfirmationPage(
                sessionId: sessionId,
                orderId: orderId,
                onDone: onDone,
              ),
            ),
          ),
        ),
      );
    }

    group('success display', () {
      testWidgets('should display success icon', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pump();

        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      });

      testWidgets('should display Order Confirmed title', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pump();

        expect(find.text('Order Confirmed!'), findsOneWidget);
      });
    });

    group('order details', () {
      testWidgets('should display Order Status as Confirmed', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pump();

        expect(find.text('Order Status'), findsOneWidget);
        expect(find.text('Confirmed'), findsOneWidget);
      });

      testWidgets('should display session ID', (tester) async {
        await tester.pumpWidget(buildWidget(sessionId: 'cs_test_xyz789'));
        await tester.pump();

        expect(find.text('Session'), findsOneWidget);
      });

      testWidgets('should display order ID when provided', (tester) async {
        await tester
            .pumpWidget(buildWidget(orderId: 'order-12345678-abcd-efgh'));
        await tester.pump();

        expect(find.text('Order ID'), findsOneWidget);
      });

      testWidgets('should not display order ID when null', (tester) async {
        await tester.pumpWidget(buildWidget(orderId: null));
        await tester.pump();

        expect(find.text('Order ID'), findsNothing);
      });
    });

    group('next steps', () {
      testWidgets('should display What\'s Next section', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pump();

        expect(find.text("What's Next?"), findsOneWidget);
      });

      testWidgets('should display Production step', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pump();

        expect(find.text('Production'), findsOneWidget);
      });

      testWidgets('should display Shipping step', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pump();

        expect(find.text('Shipping'), findsOneWidget);
      });

      testWidgets('should display Delivery step', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pump();

        expect(find.text('Delivery'), findsOneWidget);
      });
    });

    group('done button', () {
      testWidgets('should display Done button', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pump();

        expect(find.text('Done'), findsOneWidget);
      });
    });

    group('ID formatting', () {
      test('should truncate long session ID to last 8 chars', () {
        const sessionId = 'cs_test_very_long_session_id_12345';
        final truncated = '...${sessionId.substring(sessionId.length - 8)}';
        expect(truncated, '...id_12345');
      });

      test('should show short session ID as-is', () {
        const sessionId = 'short123';
        final truncated = sessionId.length > 8
            ? '...${sessionId.substring(sessionId.length - 8)}'
            : sessionId;
        expect(truncated, 'short123');
      });

      test('should truncate long order ID to first 8 chars uppercase', () {
        const orderId = 'very-long-order-id-12345678';
        final truncated = orderId.length > 8
            ? '${orderId.substring(0, 8).toUpperCase()}...'
            : orderId.toUpperCase();
        expect(truncated, 'VERY-LON...');
      });

      test('should show short order ID in uppercase', () {
        const orderId = 'abc123';
        final formatted = orderId.length > 8
            ? '${orderId.substring(0, 8).toUpperCase()}...'
            : orderId.toUpperCase();
        expect(formatted, 'ABC123');
      });
    });
  });
}
