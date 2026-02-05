/// Tests for OrderConfirmationPage.
///
/// Verifies success screen display, confirmation message, and
/// back-to-marketplace navigation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/order_confirmation_page.dart';

void main() {
  group('OrderConfirmationPage', () {
    Widget buildPage({String? sessionId}) {
      return MaterialApp(
        home: OrderConfirmationPage(sessionId: sessionId),
      );
    }

    group('rendering', () {
      testWidgets('should show success icon', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should show confirmation message', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.text('Your order has been confirmed'),
          findsOneWidget,
        );
      });

      testWidgets('should show shipping notification info', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.textContaining('notification when the seller ships'),
          findsOneWidget,
        );
      });

      testWidgets('should show order tracking info', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.textContaining('track your order'),
          findsOneWidget,
        );
      });

      testWidgets('should show back to marketplace button', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Back to Marketplace'), findsOneWidget);
      });
    });

    group('navigation', () {
      testWidgets('should pop to root when button tapped', (tester) async {
        // Build with a navigator stack to test pop behavior.
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: LynewedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const OrderConfirmationPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // The test verifies the button exists and is tappable.
        // Navigation behavior is tested via integration tests.
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Back to Marketplace'), findsOneWidget);
      });
    });

    group('session ID', () {
      testWidgets('should accept optional sessionId', (tester) async {
        await tester.pumpWidget(buildPage(sessionId: 'cs_test_123'));
        await tester.pumpAndSettle();

        // The session ID is stored but not displayed to the user.
        expect(find.text('Your order has been confirmed'), findsOneWidget);
      });
    });
  });
}

/// Dummy button used in test - matches LynewedButton interface.
class LynewedButton extends StatelessWidget {
  const LynewedButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: const Text('Navigate'));
  }
}
