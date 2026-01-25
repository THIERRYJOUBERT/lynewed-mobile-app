/// Tests for StartupGatePage.
///
/// Verifies the startup gate behavior:
/// - Shows loading state during auth check
/// - Redirects to AuthWelcomePage when Unauthenticated
/// - Redirects to appropriate page when Authenticated
/// - Shows error snackbar on AuthError
library;

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lynewed_beta/features/auth/domain/entities/entities.dart';
import 'package:lynewed_beta/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:lynewed_beta/features/auth/presentation/bloc/auth_state.dart';
import 'package:lynewed_beta/features/auth/presentation/pages/auth_welcome_page.dart';
import 'package:lynewed_beta/features/auth/presentation/pages/startup_gate_page.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  final testUser = AuthUser(
    id: 'test-user-id',
    email: 'test@example.com',
    createdAt: DateTime(2024, 1, 1),
  );

  final testBrideProfile = UserProfile(
    id: 'test-profile-id',
    authUserId: 'test-user-id',
    role: UserRole.bride,
    isOnboardingComplete: true,
    createdAt: DateTime(2024, 1, 1),
  );

  final testProProfile = UserProfile(
    id: 'test-pro-profile-id',
    authUserId: 'test-user-id',
    role: UserRole.professional,
    isOnboardingComplete: true,
    createdAt: DateTime(2024, 1, 1),
  );

  final testBrideNeedsOnboarding = UserProfile(
    id: 'test-profile-id',
    authUserId: 'test-user-id',
    role: UserRole.bride,
    isOnboardingComplete: false,
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    // Default state
    when(() => mockAuthCubit.state).thenReturn(const AuthInitial());
    when(() => mockAuthCubit.checkAuthStatus()).thenAnswer((_) async {});
  });

  Widget buildTestWidget() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: StartupGatePage.routeName,
          builder: (context, state) => BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: const StartupGatePage(),
          ),
        ),
        GoRoute(
          path: '/welcome',
          name: AuthWelcomePage.routeName,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('AuthWelcomePage')),
          ),
        ),
        GoRoute(
          path: '/home-brides',
          name: 'HomeBrides',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('HomeBrides')),
          ),
        ),
        GoRoute(
          path: '/dashboard-pro',
          name: 'DashboardPro',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('DashboardPro')),
          ),
        ),
        GoRoute(
          path: '/onboarding-brides',
          name: 'OnboardingBridesWizard',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('OnboardingBridesWizard')),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  // Simple widget without routing for basic tests
  Widget buildSimpleTestWidget() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: mockAuthCubit,
        child: const StartupGatePage(),
      ),
    );
  }

  group('StartupGatePage', () {
    group('Route configuration', () {
      test('should have correct route name', () {
        expect(StartupGatePage.routeName, 'StartupGate');
      });

      test('should have correct route path', () {
        expect(StartupGatePage.routePath, '/');
      });
    });

    group('Initial state', () {
      testWidgets('should display app branding LYNEWED', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildSimpleTestWidget());

        // Assert
        expect(find.text('LYNEWED'), findsOneWidget);
      });

      testWidgets('should display loading indicator', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildSimpleTestWidget());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should call checkAuthStatus on init', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildSimpleTestWidget());

        // Assert
        verify(() => mockAuthCubit.checkAuthStatus()).called(1);
      });
    });

    group('Loading state', () {
      testWidgets('should show loading indicator during AuthLoading',
          (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthLoading());

        // Act
        await tester.pumpWidget(buildSimpleTestWidget());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should show loading indicator during AuthInitial',
          (tester) async {
        // Arrange
        when(() => mockAuthCubit.state).thenReturn(const AuthInitial());

        // Act
        await tester.pumpWidget(buildSimpleTestWidget());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Unauthenticated state', () {
      testWidgets('should navigate to AuthWelcomePage when Unauthenticated',
          (tester) async {
        // Arrange
        final controller = StreamController<AuthState>.broadcast();
        whenListen(mockAuthCubit, controller.stream,
            initialState: const AuthInitial());

        await tester.pumpWidget(buildTestWidget());

        // Act - emit Unauthenticated state
        controller.add(const Unauthenticated());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('AuthWelcomePage'), findsOneWidget);

        // Cleanup
        await controller.close();
      });
    });

    group('Authenticated state - Bride', () {
      testWidgets('should navigate to HomeBrides when bride is authenticated',
          (tester) async {
        // Arrange
        final controller = StreamController<AuthState>.broadcast();
        whenListen(mockAuthCubit, controller.stream,
            initialState: const AuthInitial());

        await tester.pumpWidget(buildTestWidget());

        // Act - emit Authenticated state with bride profile
        controller.add(Authenticated(user: testUser, profile: testBrideProfile));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('HomeBrides'), findsOneWidget);

        // Cleanup
        await controller.close();
      });

      testWidgets(
          'should navigate to OnboardingBridesWizard when bride needs onboarding',
          (tester) async {
        // Arrange
        final controller = StreamController<AuthState>.broadcast();
        whenListen(mockAuthCubit, controller.stream,
            initialState: const AuthInitial());

        await tester.pumpWidget(buildTestWidget());

        // Act - emit Authenticated state with bride needing onboarding
        controller
            .add(Authenticated(user: testUser, profile: testBrideNeedsOnboarding));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('OnboardingBridesWizard'), findsOneWidget);

        // Cleanup
        await controller.close();
      });
    });

    group('Authenticated state - Professional', () {
      testWidgets(
          'should navigate to DashboardPro when professional is authenticated',
          (tester) async {
        // Arrange
        final controller = StreamController<AuthState>.broadcast();
        whenListen(mockAuthCubit, controller.stream,
            initialState: const AuthInitial());

        await tester.pumpWidget(buildTestWidget());

        // Act - emit Authenticated state with pro profile
        controller.add(Authenticated(user: testUser, profile: testProProfile));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('DashboardPro'), findsOneWidget);

        // Cleanup
        await controller.close();
      });
    });

    group('Authenticated state - No profile', () {
      testWidgets(
          'should navigate to OnboardingBridesWizard when profile is null',
          (tester) async {
        // Arrange
        final controller = StreamController<AuthState>.broadcast();
        whenListen(mockAuthCubit, controller.stream,
            initialState: const AuthInitial());

        await tester.pumpWidget(buildTestWidget());

        // Act - emit Authenticated state with null profile (defaults to bride)
        controller.add(Authenticated(user: testUser, profile: null));
        await tester.pumpAndSettle();

        // Assert - null profile defaults to bride role and needs onboarding
        expect(find.text('OnboardingBridesWizard'), findsOneWidget);

        // Cleanup
        await controller.close();
      });
    });

    group('Error state', () {
      testWidgets(
          'should show snackbar and navigate to welcome on AuthError',
          (tester) async {
        // Arrange
        final controller = StreamController<AuthState>.broadcast();
        whenListen(mockAuthCubit, controller.stream,
            initialState: const AuthInitial());

        await tester.pumpWidget(buildTestWidget());

        // Act - emit AuthError state
        controller.add(const AuthError('Session expired'));
        await tester.pumpAndSettle();

        // Assert - should show snackbar with error message
        expect(find.text('Session expired'), findsOneWidget);
        // And navigate to welcome page
        expect(find.text('AuthWelcomePage'), findsOneWidget);

        // Cleanup
        await controller.close();
      });
    });
  });
}
