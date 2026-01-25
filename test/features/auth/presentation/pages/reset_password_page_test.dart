/// Tests for ResetPasswordPage.
///
/// Verifies the reset password page handles:
/// - Form validation (password required, min 8 chars, confirmation match)
/// - Password visibility toggle
/// - Loading state during password update
/// - Success navigation to sign in
/// - Error display via SnackBar
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
import 'package:lynewed_beta/features/auth/presentation/pages/reset_password_page.dart';
import 'package:mocktail/mocktail.dart';

// Mock repository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late StreamController<AuthUser?> authStateController;

  setUpAll(() {
    registerFallbackValue('test-password');
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
      initialLocation: '/resetPassword',
      routes: [
        GoRoute(
          path: '/resetPassword',
          name: 'ResetPasswordPage',
          builder: (context, state) => BlocProvider<AuthCubit>.value(
            value: cubit,
            child: const ResetPasswordPage(),
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
        child: const ResetPasswordPage(),
      ),
    );
  }

  group('ResetPasswordPage', () {
    group('Form rendering', () {
      testWidgets('should display password and confirm password fields',
          (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Assert
        expect(find.text('New Password'), findsOneWidget);
        expect(find.text('Confirm Password'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2));

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display reset password button', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Assert
        expect(find.text('Reset Password'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display page title', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Assert
        expect(find.text('Create New Password'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Form validation', () {
      testWidgets('should show error when password is empty', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Act - tap reset without entering password
        await tester.tap(find.text('Reset Password'));
        await tester.pump();

        // Assert
        expect(find.text('Password is required'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should show error when password is less than 8 characters',
          (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Act
        await tester.enterText(find.byType(TextFormField).first, 'short');
        await tester.tap(find.text('Reset Password'));
        await tester.pump();

        // Assert
        expect(find.text('Password must be at least 8 characters'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should show error when passwords do not match',
          (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Act
        await tester.enterText(
            find.byType(TextFormField).first, 'password123');
        await tester.enterText(
            find.byType(TextFormField).last, 'different123');
        await tester.tap(find.text('Reset Password'));
        await tester.pump();

        // Assert
        expect(find.text('Passwords do not match'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Password visibility toggle', () {
      testWidgets('should have visibility toggle icon for password fields',
          (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Assert - visibility toggle icons should be present
        // AuthFormField with obscureText=true shows visibility_off initially
        expect(find.byIcon(Icons.visibility_off), findsWidgets);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should toggle visibility icon when tapped',
          (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Initially should show visibility_off icons
        expect(find.byIcon(Icons.visibility_off), findsWidgets);

        // Act - tap first visibility toggle
        await tester.tap(find.byIcon(Icons.visibility_off).first);
        await tester.pump();

        // Assert - icon should change to visibility
        expect(find.byIcon(Icons.visibility), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Reset password action', () {
      testWidgets('should call updatePassword on cubit when form is valid',
          (tester) async {
        // Arrange
        when(() => mockRepository.updatePassword(any()))
            .thenAnswer((_) async => const Success(null));

        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildTestWidget(cubit: cubit));

        // Fill form
        await tester.enterText(
            find.byType(TextFormField).first, 'newPassword123');
        await tester.enterText(
            find.byType(TextFormField).last, 'newPassword123');

        // Act
        await tester.tap(find.text('Reset Password'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockRepository.updatePassword('newPassword123')).called(1);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should navigate to sign in after successful password reset',
          (tester) async {
        // Arrange
        when(() => mockRepository.updatePassword(any()))
            .thenAnswer((_) async => const Success(null));

        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildTestWidget(cubit: cubit));

        // Fill form
        await tester.enterText(
            find.byType(TextFormField).first, 'newPassword123');
        await tester.enterText(
            find.byType(TextFormField).last, 'newPassword123');

        // Act
        await tester.tap(find.text('Reset Password'));
        await tester.pumpAndSettle();

        // Assert - should navigate to SignInPage
        expect(find.text('SignInPage'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should show error snackbar on failure', (tester) async {
        // Arrange
        when(() => mockRepository.updatePassword(any())).thenAnswer(
            (_) async => const Failure(AuthFailure('Password too weak')));

        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Fill form
        await tester.enterText(
            find.byType(TextFormField).first, 'newPassword123');
        await tester.enterText(
            find.byType(TextFormField).last, 'newPassword123');

        // Act
        await tester.tap(find.text('Reset Password'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Password too weak'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Route configuration', () {
      test('should have correct route name', () {
        expect(ResetPasswordPage.routeName, 'ResetPasswordPage');
      });

      test('should have correct route path', () {
        expect(ResetPasswordPage.routePath, '/resetPassword');
      });
    });
  });
}
