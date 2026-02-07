/// Tests for marketplace OrderConfirmationPage.
///
/// Verifies success screen display, What's Next steps, session ID display,
/// onDone callback, and button rendering.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/order_confirmation_page.dart';

void main() {
  group('OrderConfirmationPage', () {
    Widget buildPage({String? sessionId, VoidCallback? onDone}) {
      return MaterialApp(
        home: OrderConfirmationPage(
          sessionId: sessionId,
          onDone: onDone,
        ),
      );
    }

    group('rendering', () {
      testWidgets('should show success icon', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      });

      testWidgets('should show Order Confirmed title', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Order Confirmed!'), findsOneWidget);
      });

      testWidgets('should show purchase confirmation description',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Your purchase is confirmed'),
          findsOneWidget,
        );
      });

      testWidgets('should show order status as Confirmed', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Order Status'), findsOneWidget);
        expect(find.text('Confirmed'), findsOneWidget);
      });
    });

    group("What's Next section", () {
      testWidgets('should show What\'s Next heading', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text("What's Next?"), findsOneWidget);
      });

      testWidgets('should show step 1 - Payment Confirmed', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Payment Confirmed'), findsOneWidget);
        expect(
          find.text('Your payment has been processed successfully.'),
          findsOneWidget,
        );
      });

      testWidgets('should show step 2 - Seller Ships', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Seller Ships'), findsOneWidget);
        expect(
          find.textContaining('FedEx shipping label'),
          findsOneWidget,
        );
      });

      testWidgets('should show step 3 - Track Delivery', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Track Delivery'), findsOneWidget);
        expect(
          find.textContaining('tracking updates'),
          findsOneWidget,
        );
      });

      testWidgets('should show step numbers 1, 2, 3', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });
    });

    group('buttons', () {
      testWidgets('should show View My Purchases button', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('View My Purchases'), findsOneWidget);
      });

      testWidgets('should show Done button', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Done'), findsOneWidget);
      });

      testWidgets('should call onDone when Done button tapped',
          (tester) async {
        var doneCalled = false;
        await tester.pumpWidget(buildPage(onDone: () => doneCalled = true));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();

        expect(doneCalled, isTrue);
      });
    });

    group('session ID', () {
      testWidgets('should display truncated session ID when provided',
          (tester) async {
        await tester.pumpWidget(
          buildPage(sessionId: 'cs_test_abc123456789'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Session'), findsOneWidget);
        expect(find.text('...23456789'), findsOneWidget);
      });

      testWidgets('should not show session row when sessionId is null',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Session'), findsNothing);
      });

      testWidgets('should not show session row when sessionId is empty',
          (tester) async {
        await tester.pumpWidget(buildPage(sessionId: ''));
        await tester.pumpAndSettle();

        expect(find.text('Session'), findsNothing);
      });

      testWidgets('should show short session ID without truncation',
          (tester) async {
        await tester.pumpWidget(buildPage(sessionId: 'abc'));
        await tester.pumpAndSettle();

        expect(find.text('Session'), findsOneWidget);
        expect(find.text('abc'), findsOneWidget);
      });
    });
  });
}
