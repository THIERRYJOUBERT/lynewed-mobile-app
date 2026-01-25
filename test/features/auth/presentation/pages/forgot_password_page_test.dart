/// Tests for ForgotPasswordPage.
///
/// Verifies the forgot password page handles:
/// - Form validation (email required, valid format)
/// - Loading state during email send
/// - Success state with confirmation message
/// - Error display via SnackBar
/// - Navigation back to sign in
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/auth/domain/entities/entities.dart';
import 'package:lynewed_beta/features/auth/domain/repositories/auth_repository.dart';
import 'package:lynewed_beta/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:lynewed_beta/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:mocktail/mocktail.dart';

// Mock repository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late StreamController<AuthUser?> authStateController;

  setUpAll(() {
    registerFallbackValue('test-email');
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    authStateController = StreamController<AuthUser?>.broadcast();

    when(() => mockRepository.watchAuthState())
        .thenAnswer((_) => authStateController.stream);
  });

  tearDown(() {
    authStateController.close();
  });

  // Helper to build widget with provider and router
  Widget buildTestWidget({
    required AuthCubit cubit,
  }) {
    final router = GoRouter(
      initialLocation: '/forgotPassword',
      routes: [
        GoRoute(
          path: '/forgotPassword',
          name: 'ForgotPasswordPage',
          builder: (context, state) => BlocProvider<AuthCubit>.value(
            value: cubit,
            child: const ForgotPasswordPage(),
          ),
        ),
        GoRoute(
          path: '/signIn',
          name: 'SignInPage',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('SignInPage')),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  // Simpler widget without router for form tests
  Widget buildSimpleTestWidget({
    required AuthCubit cubit,
  }) {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: cubit,
        child: const ForgotPasswordPage(),
      ),
    );
  }

  group('ForgotPasswordPage', () {
    group('Form rendering', () {
      testWidgets('should display email field', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Assert
        expect(find.text('Email'), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display send reset link button', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Assert
        expect(find.text('Send Reset Link'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display page title', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Assert
        expect(find.text('Forgot Password'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display back to login link', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Assert
        expect(find.text('Back to Sign In'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Form validation', () {
      testWidgets('should show error when email is empty', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Act - tap send without entering email
        await tester.tap(find.text('Send Reset Link'));
        await tester.pump();

        // Assert
        expect(find.text('Email is required'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should show error when email is invalid', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Act
        await tester.enterText(find.byType(TextFormField), 'invalid-email');
        await tester.tap(find.text('Send Reset Link'));
        await tester.pump();

        // Assert
        expect(find.text('Please enter a valid email'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Send reset email action', () {
      testWidgets('should call sendPasswordResetEmail on cubit when form is valid',
          (tester) async {
        // Arrange
        when(() => mockRepository.sendPasswordResetEmail(any()))
            .thenAnswer((_) async => const Success(null));

        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Fill form
        await tester.enterText(find.byType(TextFormField), 'test@example.com');

        // Act
        await tester.tap(find.text('Send Reset Link'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockRepository.sendPasswordResetEmail('test@example.com'))
            .called(1);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should show confirmation view after successful send',
          (tester) async {
        // Arrange
        when(() => mockRepository.sendPasswordResetEmail(any()))
            .thenAnswer((_) async => const Success(null));

        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Fill form
        await tester.enterText(find.byType(TextFormField), 'test@example.com');

        // Act
        await tester.tap(find.text('Send Reset Link'));
        await tester.pumpAndSettle();

        // Assert - confirmation message should be visible
        expect(find.text('Check Your Email'), findsOneWidget);
        expect(
            find.textContaining('We sent a password reset link'),
            findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should show error snackbar on failure', (tester) async {
        // Arrange
        when(() => mockRepository.sendPasswordResetEmail(any())).thenAnswer(
            (_) async => const Failure(AuthFailure('User not found')));

        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Fill form
        await tester.enterText(find.byType(TextFormField), 'unknown@example.com');

        // Act
        await tester.tap(find.text('Send Reset Link'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('User not found'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Navigation', () {
      testWidgets('should navigate to sign in when back button tapped',
          (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildTestWidget(cubit: cubit));

        // Act
        await tester.tap(find.text('Back to Sign In'));
        await tester.pumpAndSettle();

        // Assert - should navigate to SignInPage
        expect(find.text('SignInPage'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Route configuration', () {
      test('should have correct route name', () {
        expect(ForgotPasswordPage.routeName, 'ForgotPasswordPage');
      });

      test('should have correct route path', () {
        expect(ForgotPasswordPage.routePath, '/forgotPassword');
      });
    });
  });
}
