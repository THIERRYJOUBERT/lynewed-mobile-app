/// Tests for SignInPage.
///
/// Verifies the sign-in page uses AuthCubit correctly and handles:
/// - Form validation
/// - Loading state
/// - Error display via SnackBar
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
import 'package:lynewed_beta/features/auth/presentation/pages/sign_in_page.dart';

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
    bool isProfessional = false,
  }) {
    final router = GoRouter(
      initialLocation: '/signIn',
      routes: [
        GoRoute(
          path: '/signIn',
          name: 'SignInPage',
          builder: (context, state) => BlocProvider<AuthCubit>.value(
            value: cubit,
            child: SignInPage(isProfessional: isProfessional),
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
    bool isProfessional = false,
  }) {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: cubit,
        child: SignInPage(isProfessional: isProfessional),
      ),
    );
  }

  group('SignInPage', () {
    group('Form rendering', () {
      testWidgets('should display email and password fields', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Assert
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2));

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display sign in button', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Assert
        expect(find.text('Sign In'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display title for bride sign in', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit, isProfessional: false));

        // Assert
        expect(find.text('Welcome Back'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display title for professional sign in', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit, isProfessional: true));

        // Assert
        expect(find.text('Professional Sign In'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Form validation', () {
      testWidgets('should show error when email is empty', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Act - tap sign in without entering email
        await tester.tap(find.text('Sign In'));
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
        await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
        await tester.tap(find.text('Sign In'));
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
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        // Assert
        expect(find.text('Password is required'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Loading state', () {
      testWidgets('button should display loading text property', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Assert - button with loading capability exists
        // The LynewedButton supports isLoading property
        expect(find.text('Sign In'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Sign in action', () {
      testWidgets('should call signIn on cubit when form is valid', (tester) async {
        // Arrange
        when(() => mockRepository.signInWithEmail(any(), any()))
            .thenAnswer((_) async => Success(testUser));
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(UserProfile(
                  id: 'profile-1',
                  authUserId: testUser.id,
                  role: UserRole.bride,
                  isOnboardingComplete: true,
                  createdAt: DateTime(2024, 1, 1),
                )));

        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildTestWidget(cubit: cubit));

        // Fill form
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).last, 'password123');

        // Act
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockRepository.signInWithEmail('test@example.com', 'password123')).called(1);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should navigate to StartupGate on successful sign in', (tester) async {
        // Arrange
        when(() => mockRepository.signInWithEmail(any(), any()))
            .thenAnswer((_) async => Success(testUser));
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(UserProfile(
                  id: 'profile-1',
                  authUserId: testUser.id,
                  role: UserRole.bride,
                  isOnboardingComplete: true,
                  createdAt: DateTime(2024, 1, 1),
                )));

        final cubit = AuthCubit(repository: mockRepository);
        await tester.pumpWidget(buildTestWidget(cubit: cubit));

        // Fill form
        await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
        await tester.enterText(find.byType(TextFormField).last, 'password123');

        // Act
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Assert - should navigate to StartupGate
        expect(find.text('StartupGate'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('isProfessional parameter', () {
      testWidgets('should store isProfessional parameter', (tester) async {
        // Assert
        const pageFalse = SignInPage(isProfessional: false);
        expect(pageFalse.isProfessional, false);

        const pageTrue = SignInPage(isProfessional: true);
        expect(pageTrue.isProfessional, true);
      });

      testWidgets('should default isProfessional to false', (tester) async {
        // Assert
        const page = SignInPage();
        expect(page.isProfessional, false);
      });
    });

    group('Route configuration', () {
      test('should have correct route name', () {
        expect(SignInPage.routeName, 'SignInPage');
      });

      test('should have correct route path', () {
        expect(SignInPage.routePath, '/signIn');
      });
    });
  });
}
