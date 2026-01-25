/// Tests for AuthWelcomePage.
///
/// Verifies the welcome page displays:
/// - App branding
/// - Sign in options for bride and professional
/// - Navigation buttons
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lynewed_beta/features/auth/presentation/pages/auth_welcome_page.dart';

void main() {
  // Helper to build widget with router
  Widget buildTestWidget() {
    final router = GoRouter(
      initialLocation: '/welcome',
      routes: [
        GoRoute(
          path: '/welcome',
          name: 'AuthWelcomePage',
          builder: (context, state) => const AuthWelcomePage(),
        ),
        GoRoute(
          path: '/signIn',
          name: 'SignInPage',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final isPro = extra?['isProfessional'] ?? false;
            return Scaffold(
              body: Center(
                child: Text(isPro ? 'Pro SignIn' : 'Bride SignIn'),
              ),
            );
          },
        ),
        GoRoute(
          path: '/signUp',
          name: 'SignUpPage',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('SignUpPage')),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  // Simple widget without router for rendering tests
  Widget buildSimpleTestWidget() {
    return const MaterialApp(
      home: AuthWelcomePage(),
    );
  }

  group('AuthWelcomePage', () {
    group('Branding', () {
      testWidgets('should display app title', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildSimpleTestWidget());

        // Assert
        expect(find.text('LYNEWED'), findsOneWidget);
      });

      testWidgets('should display tagline', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildSimpleTestWidget());

        // Assert
        expect(find.textContaining('wedding'), findsOneWidget);
      });
    });

    group('Sign in buttons', () {
      testWidgets('should display sign in button for brides', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildSimpleTestWidget());

        // Assert
        expect(find.text('Sign In'), findsOneWidget);
      });

      testWidgets('should display professional sign in option', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildSimpleTestWidget());

        // Assert
        expect(find.textContaining('Professional'), findsOneWidget);
      });

      testWidgets('should display create account button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildSimpleTestWidget());

        // Assert
        expect(find.text('Create Account'), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('should navigate to bride sign in when Sign In tapped', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Bride SignIn'), findsOneWidget);
      });

      testWidgets('should navigate to pro sign in when Professional tapped', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act
        await tester.tap(find.textContaining('Professional'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Pro SignIn'), findsOneWidget);
      });

      testWidgets('should navigate to sign up when Create Account tapped', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act
        await tester.tap(find.text('Create Account'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('SignUpPage'), findsOneWidget);
      });
    });

    group('Route configuration', () {
      test('should have correct route name', () {
        expect(AuthWelcomePage.routeName, 'AuthWelcomePage');
      });

      test('should have correct route path', () {
        expect(AuthWelcomePage.routePath, '/welcome');
      });
    });

    group('Design system', () {
      testWidgets('should use design system colors and styles', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildSimpleTestWidget());

        // Assert - page should render without errors using design system
        expect(find.byType(AuthWelcomePage), findsOneWidget);
        expect(find.text('LYNEWED'), findsOneWidget);
      });
    });
  });
}
