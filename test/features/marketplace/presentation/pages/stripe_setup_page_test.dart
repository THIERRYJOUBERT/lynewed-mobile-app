/// Tests for StripeSetupPage.
///
/// Verifies the page displays correct status, handles loading states,
/// and triggers the Stripe Connect onboarding flow.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/stripe_connect_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/check_stripe_status_use_case.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/setup_stripe_connect_use_case.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/stripe_setup_page.dart';
import 'package:lynewed_beta/features/payments/domain/entities/stripe_account.dart';
import 'package:mocktail/mocktail.dart';

class MockSetupStripeConnectUseCase extends Mock
    implements SetupStripeConnectUseCase {}

class MockCheckStripeStatusUseCase extends Mock
    implements CheckStripeStatusUseCase {}

class MockStripeConnectRepository extends Mock
    implements StripeConnectRepository {}

void main() {
  group('StripeSetupPage', () {
    late MockSetupStripeConnectUseCase mockSetupUseCase;
    late MockCheckStripeStatusUseCase mockCheckUseCase;

    setUp(() {
      mockSetupUseCase = MockSetupStripeConnectUseCase();
      mockCheckUseCase = MockCheckStripeStatusUseCase();
    });

    Widget buildPage({
      String userId = 'user-123',
      String email = 'seller@test.com',
    }) {
      return MaterialApp(
        home: StripeSetupPage(
          userId: userId,
          email: email,
          setupUseCase: mockSetupUseCase,
          checkStatusUseCase: mockCheckUseCase,
        ),
      );
    }

    group('initial state', () {
      testWidgets('should show loading indicator initially', (tester) async {
        when(() => mockCheckUseCase.syncAndGetAccount('user-123'))
            .thenAnswer((_) async => null);

        await tester.pumpWidget(buildPage());

        // Initially shows loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should show page title', (tester) async {
        when(() => mockCheckUseCase.syncAndGetAccount('user-123'))
            .thenAnswer((_) async => null);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Payment Setup'), findsOneWidget);
      });
    });

    group('no account state', () {
      testWidgets('should show setup button when no account exists',
          (tester) async {
        when(() => mockCheckUseCase.syncAndGetAccount('user-123'))
            .thenAnswer((_) async => null);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Setup Payments'), findsOneWidget);
        expect(
          find.text(
            'Complete your Stripe setup to receive payments from sales.',
          ),
          findsOneWidget,
        );
      });
    });

    group('incomplete account state', () {
      testWidgets('should show incomplete status widget', (tester) async {
        final account = StripeAccount(
          userId: 'user-123',
          stripeAccountId: 'acct_123',
          onboardingComplete: false,
          chargesEnabled: false,
          payoutsEnabled: false,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );

        when(() => mockCheckUseCase.syncAndGetAccount('user-123'))
            .thenAnswer((_) async => account);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Payment Setup Incomplete'), findsOneWidget);
        expect(find.text('Complete Setup'), findsOneWidget);
      });
    });

    group('complete account state', () {
      testWidgets('should show success status widget', (tester) async {
        final account = StripeAccount(
          userId: 'user-123',
          stripeAccountId: 'acct_123',
          onboardingComplete: true,
          chargesEnabled: true,
          payoutsEnabled: true,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );

        when(() => mockCheckUseCase.syncAndGetAccount('user-123'))
            .thenAnswer((_) async => account);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Payment Setup Complete'), findsOneWidget);
        expect(find.text('Charges: Enabled'), findsOneWidget);
        expect(find.text('Payouts: Enabled'), findsOneWidget);
      });
    });

    group('error handling', () {
      testWidgets('should show error message when loading fails',
          (tester) async {
        when(() => mockCheckUseCase.syncAndGetAccount('user-123'))
            .thenThrow(Exception('Network error'));

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(
          find.text('Failed to load account status. Please try again.'),
          findsOneWidget,
        );
      });
    });

    group('setup flow', () {
      testWidgets('should show loading state when setup is triggered',
          (tester) async {
        final completer = Completer<Map<String, dynamic>>();

        when(() => mockCheckUseCase.syncAndGetAccount('user-123'))
            .thenAnswer((_) async => null);
        when(
          () => mockSetupUseCase(
            userId: any(named: 'userId'),
            email: any(named: 'email'),
            returnUrl: any(named: 'returnUrl'),
            refreshUrl: any(named: 'refreshUrl'),
          ),
        ).thenAnswer((_) => completer.future);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Tap setup button
        await tester.tap(find.text('Setup Payments'));
        await tester.pump();

        // Should show loading indicator on the button
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete the future with error to avoid launchUrl side effects
        completer.completeError(Exception('test cancel'));
        await tester.pumpAndSettle();
      });

      testWidgets('should show error when setup fails', (tester) async {
        when(() => mockCheckUseCase.syncAndGetAccount('user-123'))
            .thenAnswer((_) async => null);
        when(
          () => mockSetupUseCase(
            userId: any(named: 'userId'),
            email: any(named: 'email'),
            returnUrl: any(named: 'returnUrl'),
            refreshUrl: any(named: 'refreshUrl'),
          ),
        ).thenThrow(Exception('Stripe API error'));

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Tap setup button
        await tester.tap(find.text('Setup Payments'));
        await tester.pumpAndSettle();

        expect(
          find.text('Failed to start payment setup. Please try again.'),
          findsOneWidget,
        );
      });
    });
  });
}
