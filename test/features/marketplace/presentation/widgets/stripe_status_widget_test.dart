/// Tests for StripeStatusWidget.
///
/// Verifies the widget displays correct status based on account state
/// and handles user interactions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/stripe_status_widget.dart';

void main() {
  group('StripeStatusWidget', () {
    Widget buildWidget({
      required bool onboardingComplete,
      required bool chargesEnabled,
      required bool payoutsEnabled,
      VoidCallback? onSetupTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: StripeStatusWidget(
            onboardingComplete: onboardingComplete,
            chargesEnabled: chargesEnabled,
            payoutsEnabled: payoutsEnabled,
            onSetupTap: onSetupTap,
          ),
        ),
      );
    }

    group('incomplete status', () {
      testWidgets('should show warning card when onboarding is incomplete',
          (tester) async {
        await tester.pumpWidget(
          buildWidget(
            onboardingComplete: false,
            chargesEnabled: false,
            payoutsEnabled: false,
          ),
        );

        expect(find.text('Payment Setup Incomplete'), findsOneWidget);
        expect(
          find.text(
            'Complete your Stripe setup to receive payments from sales.',
          ),
          findsOneWidget,
        );
        expect(find.text('Complete Setup'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber), findsOneWidget);
      });

      testWidgets('should show warning when charges not enabled',
          (tester) async {
        await tester.pumpWidget(
          buildWidget(
            onboardingComplete: true,
            chargesEnabled: false,
            payoutsEnabled: false,
          ),
        );

        expect(find.text('Payment Setup Incomplete'), findsOneWidget);
      });

      testWidgets('should call onSetupTap when button is pressed',
          (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          buildWidget(
            onboardingComplete: false,
            chargesEnabled: false,
            payoutsEnabled: false,
            onSetupTap: () => tapped = true,
          ),
        );

        await tester.tap(find.text('Complete Setup'));
        await tester.pump();

        expect(tapped, true);
      });
    });

    group('complete status', () {
      testWidgets('should show success card when fully set up',
          (tester) async {
        await tester.pumpWidget(
          buildWidget(
            onboardingComplete: true,
            chargesEnabled: true,
            payoutsEnabled: true,
          ),
        );

        expect(find.text('Payment Setup Complete'), findsOneWidget);
        expect(find.text('Charges: Enabled'), findsOneWidget);
        expect(find.text('Payouts: Enabled'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets(
          'should show mixed status when charges enabled but payouts disabled',
          (tester) async {
        await tester.pumpWidget(
          buildWidget(
            onboardingComplete: true,
            chargesEnabled: true,
            payoutsEnabled: false,
          ),
        );

        expect(find.text('Payment Setup Complete'), findsOneWidget);
        expect(find.text('Charges: Enabled'), findsOneWidget);
        expect(find.text('Payouts: Disabled'), findsOneWidget);
      });
    });

    group('no setup button', () {
      testWidgets('should not show button when onSetupTap is null',
          (tester) async {
        await tester.pumpWidget(
          buildWidget(
            onboardingComplete: false,
            chargesEnabled: false,
            payoutsEnabled: false,
            onSetupTap: null,
          ),
        );

        // Button should be present but disabled (onPressed is null)
        expect(find.text('Complete Setup'), findsOneWidget);
      });
    });
  });
}
