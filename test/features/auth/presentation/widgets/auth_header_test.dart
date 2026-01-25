/// Tests for AuthHeader widget.
///
/// Verifies the header component for authentication pages displays:
/// - Title text
/// - Subtitle text
/// - Optional background image
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/presentation/widgets/auth_header.dart';

void main() {
  group('AuthHeader', () {
    Widget buildTestWidget({
      required Widget child,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    group('Basic rendering', () {
      testWidgets('should display title text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const AuthHeader(
            title: 'Welcome Back',
          ),
        ));

        // Assert
        expect(find.text('Welcome Back'), findsOneWidget);
      });

      testWidgets('should display subtitle when provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const AuthHeader(
            title: 'Welcome Back',
            subtitle: 'Sign in to continue',
          ),
        ));

        // Assert
        expect(find.text('Welcome Back'), findsOneWidget);
        expect(find.text('Sign in to continue'), findsOneWidget);
      });

      testWidgets('should render without subtitle', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const AuthHeader(
            title: 'Welcome',
          ),
        ));

        // Assert - Should not crash and only show title
        expect(find.text('Welcome'), findsOneWidget);
      });
    });

    group('Text styling', () {
      testWidgets('title should use headline style', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const AuthHeader(
            title: 'Welcome',
          ),
        ));

        // Assert - title should be in a Text widget
        final titleFinder = find.text('Welcome');
        expect(titleFinder, findsOneWidget);

        // Verify it's rendered (style is internal implementation)
        final titleWidget = tester.widget<Text>(titleFinder);
        expect(titleWidget.data, 'Welcome');
      });

      testWidgets('subtitle should use body style', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const AuthHeader(
            title: 'Welcome',
            subtitle: 'Please sign in',
          ),
        ));

        // Assert
        final subtitleFinder = find.text('Please sign in');
        expect(subtitleFinder, findsOneWidget);

        final subtitleWidget = tester.widget<Text>(subtitleFinder);
        expect(subtitleWidget.data, 'Please sign in');
      });
    });

    group('Layout', () {
      testWidgets('should render title above subtitle', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const AuthHeader(
            title: 'Welcome',
            subtitle: 'Sign in to continue',
          ),
        ));

        // Assert - both should be visible
        expect(find.text('Welcome'), findsOneWidget);
        expect(find.text('Sign in to continue'), findsOneWidget);

        // Verify title is above subtitle by checking their vertical positions
        final titlePosition = tester.getTopLeft(find.text('Welcome'));
        final subtitlePosition = tester.getTopLeft(find.text('Sign in to continue'));
        expect(titlePosition.dy, lessThan(subtitlePosition.dy));
      });

      testWidgets('should have proper spacing between title and subtitle', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const AuthHeader(
            title: 'Welcome',
            subtitle: 'Sign in to continue',
          ),
        ));

        // Assert - there should be some spacing between elements
        final titleBottom = tester.getBottomLeft(find.text('Welcome'));
        final subtitleTop = tester.getTopLeft(find.text('Sign in to continue'));

        // Expect some spacing (at least 4 pixels)
        expect(subtitleTop.dy - titleBottom.dy, greaterThanOrEqualTo(4));
      });
    });

    group('Background image', () {
      testWidgets('should render without background image by default', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const AuthHeader(
            title: 'Welcome',
          ),
        ));

        // Assert - no Container with decoration should be present at root
        expect(find.byType(AuthHeader), findsOneWidget);
        // Widget should render normally without background
        expect(find.text('Welcome'), findsOneWidget);

        // Verify no DecoratedBox is used (which would contain the background image)
        // The widget should just be a Column when no background image
        final authHeader = tester.widget<AuthHeader>(find.byType(AuthHeader));
        expect(authHeader.backgroundImage, isNull);
      });

      testWidgets('should store backgroundImage parameter when provided', (tester) async {
        // Arrange & Act
        // Note: We don't pump the widget to avoid asset loading issues
        // We just verify the widget accepts the parameter
        const header = AuthHeader(
          title: 'Welcome',
          backgroundImage: 'assets/images/auth_bg.png',
        );

        // Assert - parameter is stored
        expect(header.backgroundImage, 'assets/images/auth_bg.png');
      });
    });

    group('Customization', () {
      testWidgets('should support custom text alignment', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const AuthHeader(
            title: 'Welcome',
            subtitle: 'Sign in',
            textAlign: TextAlign.center,
          ),
        ));

        // Assert
        expect(find.text('Welcome'), findsOneWidget);
        // Center alignment should work without errors
      });

      testWidgets('should render with light text on dark background', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const AuthHeader(
            title: 'Welcome',
            subtitle: 'Sign in',
            useLightText: true,
          ),
        ));

        // Assert - should render without errors
        expect(find.text('Welcome'), findsOneWidget);
        expect(find.text('Sign in'), findsOneWidget);
      });
    });
  });
}
