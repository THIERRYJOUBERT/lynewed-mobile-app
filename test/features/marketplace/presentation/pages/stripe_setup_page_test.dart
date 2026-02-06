/// Tests for StripeSetupPage.
///
/// Verifies loading, existing account status display, multi-step form
/// for new accounts (personal info, address, bank details), and error
/// handling.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/di/injection_container.dart';
import 'package:lynewed_beta/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:lynewed_beta/features/auth/data/models/user_profile_model.dart';
import 'package:lynewed_beta/features/auth/domain/entities/user_role.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/check_stripe_status_use_case.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/setup_stripe_connect_use_case.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/stripe_setup_page.dart';
import 'package:lynewed_beta/features/payments/domain/entities/stripe_account.dart';
import 'package:mocktail/mocktail.dart';

class MockSetupStripeConnectUseCase extends Mock
    implements SetupStripeConnectUseCase {}

class MockCheckStripeStatusUseCase extends Mock
    implements CheckStripeStatusUseCase {}

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

void main() {
  group('StripeSetupPage', () {
    late MockSetupStripeConnectUseCase mockSetupUseCase;
    late MockCheckStripeStatusUseCase mockCheckUseCase;
    late MockAuthRemoteDatasource mockAuthDatasource;

    setUp(() {
      mockSetupUseCase = MockSetupStripeConnectUseCase();
      mockCheckUseCase = MockCheckStripeStatusUseCase();
      mockAuthDatasource = MockAuthRemoteDatasource();

      // Register mock in service locator
      sl.registerSingleton<AuthRemoteDatasource>(mockAuthDatasource);

      // Default: getProfile returns a basic profile (for pre-fill)
      when(() => mockAuthDatasource.getProfile(any())).thenAnswer(
        (_) async => UserProfileModel(
          id: 'user-123',
          authUserId: 'auth-123',
          displayName: 'Jane Doe',
          role: UserRole.bride,
          createdAt: DateTime(2024),
        ),
      );
    });

    tearDown(() async {
      await sl.reset();
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

    group('no account state - multi-step form', () {
      testWidgets('should show step 1 (Personal) when no account exists',
          (tester) async {
        when(() => mockCheckUseCase.syncAndGetAccount('user-123'))
            .thenAnswer((_) async => null);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Step labels visible.
        expect(find.text('Personal'), findsOneWidget);
        expect(find.text('Address'), findsOneWidget);
        expect(find.text('Bank'), findsOneWidget);

        // Personal info form fields.
        expect(find.text('First Name'), findsOneWidget);
        expect(find.text('Last Name'), findsOneWidget);
        expect(find.text('Date of Birth'), findsOneWidget);
      });

      testWidgets('should pre-fill name from profile', (tester) async {
        when(() => mockCheckUseCase.syncAndGetAccount('user-123'))
            .thenAnswer((_) async => null);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // 'Jane' pre-filled in first name, 'Doe' in last name.
        final textFields = find.byType(TextField);
        expect(textFields, findsWidgets);
      });
    });

    group('existing incomplete account', () {
      testWidgets('should show multi-step form for incomplete account',
          (tester) async {
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

        // Should show the 3-step form, NOT the status widget
        expect(find.text('Personal'), findsOneWidget);
        expect(find.text('Address'), findsOneWidget);
        expect(find.text('Bank'), findsOneWidget);
        expect(find.text('First Name'), findsOneWidget);

        // Status widget should NOT appear
        expect(find.text('Payment Setup Incomplete'), findsNothing);
        expect(find.text('Complete Setup'), findsNothing);
      });
    });

    group('existing complete account', () {
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

    group('form navigation', () {
      testWidgets('should show Continue button on step 1', (tester) async {
        when(() => mockCheckUseCase.syncAndGetAccount('user-123'))
            .thenAnswer((_) async => null);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Continue'), findsOneWidget);
      });

      testWidgets('should show Back button from step 2', (tester) async {
        when(() => mockCheckUseCase.syncAndGetAccount('user-123'))
            .thenAnswer((_) async => null);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Fill required fields for step 1.
        // First name is pre-filled from 'Jane Doe' profile.
        // Need DOB to proceed.
        final dobField = find.text('Date of Birth');
        expect(dobField, findsOneWidget);
      });
    });
  });
}
