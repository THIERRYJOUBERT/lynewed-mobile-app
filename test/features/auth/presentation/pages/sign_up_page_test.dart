/// Tests for SignUpPage.
///
/// Verifies the sign-up page for bride users handles:
/// - Form fields (email, password, displayName)
/// - Form validation
/// - Loading state
/// - Navigation on success
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/auth/domain/entities/entities.dart';
import 'package:lynewed_beta/features/auth/domain/repositories/auth_repository.dart';
import 'package:lynewed_beta/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:lynewed_beta/features/auth/presentation/pages/sign_up_page.dart';

// Mock repository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late StreamController<AuthUser?> authStateController;

  final testUser = AuthUser(
    id: 'test-user-id',
    email: 'test@example.com',
    createdAt: DateTime(2024, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue('test-email');
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
      initialLocation: '/signUp',
      routes: [
        GoRoute(
          path: '/signUp',
          name: 'SignUpPage',
          builder: (context, state) => BlocProvider<AuthCubit>.value(
            value: cubit,
            child: const SignUpPage(),
          ),
        ),
        GoRoute(
          path: '/startup',
          name: 'StartupGate',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('StartupGate')),
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
        child: const SignUpPage(),
      ),
    );
  }

  group('SignUpPage', () {
    group('Form rendering', () {
      testWidgets('should display email, password and display name fields', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Assert
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Display Name'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(3));

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display sign up button', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Assert
        expect(find.text('Sign Up'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display appropriate title', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Assert
        expect(find.text('Create Account'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Form validation', () {
      testWidgets('should show error when email is empty', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Act - tap sign up without entering email
        await tester.tap(find.text('Sign Up'));
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

        // Act - enter invalid email
        await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
        await tester.tap(find.text('Sign Up'));
        await tester.pump();

        // Assert
        expect(find.text('Please enter a valid email'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should show error when password is empty', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Act
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.tap(find.text('Sign Up'));
        await tester.pump();

        // Assert
        expect(find.text('Password is required'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should show error when password is too short', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Act
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), '12345'); // 5 chars
        await tester.tap(find.text('Sign Up'));
        await tester.pump();

        // Assert
        expect(find.text('Password must be at least 6 characters'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should allow empty display name (optional field)', (tester) async {
        // Arrange
        when(() => mockRepository.signUpBride(
              email: any(named: 'email'),
              password: any(named: 'password'),
              displayName: any(named: 'displayName'),
            )).thenAnswer((_) async => Success(testUser));
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(UserProfile(
                  id: 'profile-1',
                  authUserId: testUser.id,
                  role: UserRole.bride,
                  isOnboardingComplete: false,
                  createdAt: DateTime(2024, 1, 1),
                )));

        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildTestWidget(cubit: cubit));

        // Act - fill required fields only
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Assert - sign up was called (no validation error for display name)
        verify(() => mockRepository.signUpBride(
              email: 'test@example.com',
              password: 'password123',
              displayName: null,
            )).called(1);

        // Cleanup
        await cubit.close();
      });
    });

    group('Sign up action', () {
      testWidgets('should call signUp on cubit when form is valid', (tester) async {
        // Arrange
        when(() => mockRepository.signUpBride(
              email: any(named: 'email'),
              password: any(named: 'password'),
              displayName: any(named: 'displayName'),
            )).thenAnswer((_) async => Success(testUser));
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(UserProfile(
                  id: 'profile-1',
                  authUserId: testUser.id,
                  role: UserRole.bride,
                  isOnboardingComplete: false,
                  createdAt: DateTime(2024, 1, 1),
                )));

        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildTestWidget(cubit: cubit));

        // Fill all fields
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.enterText(find.byType(TextFormField).last, 'Test User');

        // Act
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockRepository.signUpBride(
              email: 'test@example.com',
              password: 'password123',
              displayName: 'Test User',
            )).called(1);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should navigate to StartupGate on successful sign up', (tester) async {
        // Arrange
        when(() => mockRepository.signUpBride(
              email: any(named: 'email'),
              password: any(named: 'password'),
              displayName: any(named: 'displayName'),
            )).thenAnswer((_) async => Success(testUser));
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(UserProfile(
                  id: 'profile-1',
                  authUserId: testUser.id,
                  role: UserRole.bride,
                  isOnboardingComplete: false,
                  createdAt: DateTime(2024, 1, 1),
                )));

        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildTestWidget(cubit: cubit));

        // Fill form
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.enterText(find.byType(TextFormField).last, 'Test User');

        // Act
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Assert - should navigate to StartupGate
        expect(find.text('StartupGate'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Route configuration', () {
      test('should have correct route name', () {
        expect(SignUpPage.routeName, 'SignUpPage');
      });

      test('should have correct route path', () {
        expect(SignUpPage.routePath, '/signUp');
      });
    });
  });
}
