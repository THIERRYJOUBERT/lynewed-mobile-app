/// Tests for QuickActionCard widget.
///
/// Verifies the quick action card widget:
/// - Renders icon and title correctly
/// - Handles tap callback
/// - Proper styling and layout
/// - Accessibility (touch target size)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/support/presentation/widgets/quick_action_card.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('QuickActionCard', () {
    group('Basic rendering', () {
      testWidgets('should display icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionCard(
            icon: Icons.email,
            title: 'Email',
            onTap: () {},
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.email), findsOneWidget);
      });

      testWidgets('should display title', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionCard(
            icon: Icons.email,
            title: 'Email Us',
            onTap: () {},
          ),
        ));

        // Assert
        expect(find.text('Email Us'), findsOneWidget);
      });

      testWidgets('should display subtitle when provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionCard(
            icon: Icons.email,
            title: 'Email Us',
            subtitle: 'support@lynewed.com',
            onTap: () {},
          ),
        ));

        // Assert
        expect(find.text('Email Us'), findsOneWidget);
        expect(find.text('support@lynewed.com'), findsOneWidget);
      });

      testWidgets('should not display subtitle when not provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionCard(
            icon: Icons.email,
            title: 'Email Us',
            onTap: () {},
          ),
        ));

        // Assert
        expect(find.text('Email Us'), findsOneWidget);
        expect(find.text('support@lynewed.com'), findsNothing);
      });
    });

    group('Tap handling', () {
      testWidgets('should call onTap when tapped', (tester) async {
        // Arrange
        var tapped = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionCard(
            icon: Icons.email,
            title: 'Email',
            onTap: () => tapped = true,
          ),
        ));
        await tester.tap(find.byType(QuickActionCard));
        await tester.pump();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('should handle multiple taps', (tester) async {
        // Arrange
        var tapCount = 0;

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionCard(
            icon: Icons.chat,
            title: 'Chat',
            onTap: () => tapCount++,
          ),
        ));
        await tester.tap(find.byType(QuickActionCard));
        await tester.pump();
        await tester.tap(find.byType(QuickActionCard));
        await tester.pump();

        // Assert
        expect(tapCount, equals(2));
      });
    });

    group('Layout', () {
      testWidgets('icon should be centered in container', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionCard(
            icon: Icons.email,
            title: 'Email',
            onTap: () {},
          ),
        ));

        // Assert - icon should be positioned above title
        final iconPosition = tester.getCenter(find.byIcon(Icons.email));
        final titlePosition = tester.getCenter(find.text('Email'));
        expect(iconPosition.dy, lessThan(titlePosition.dy));
      });

      testWidgets('title should be below icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionCard(
            icon: Icons.email,
            title: 'Email',
            onTap: () {},
          ),
        ));

        // Assert
        final iconPosition = tester.getTopLeft(find.byIcon(Icons.email));
        final titlePosition = tester.getTopLeft(find.text('Email'));
        expect(iconPosition.dy, lessThan(titlePosition.dy));
      });
    });

    group('Widget configuration', () {
      testWidgets('should accept all required parameters', (tester) async {
        // Arrange
        void tapCallback() {}

        // Act
        final widget = QuickActionCard(
          icon: Icons.phone,
          title: 'Call',
          onTap: tapCallback,
        );

        // Assert
        expect(widget.icon, Icons.phone);
        expect(widget.title, 'Call');
        expect(widget.onTap, tapCallback);
      });

      testWidgets('should accept optional subtitle parameter', (tester) async {
        // Arrange
        void tapCallback() {}

        // Act
        final widget = QuickActionCard(
          icon: Icons.phone,
          title: 'Call',
          subtitle: '+33 1 23 45 67 89',
          onTap: tapCallback,
        );

        // Assert
        expect(widget.icon, Icons.phone);
        expect(widget.title, 'Call');
        expect(widget.subtitle, '+33 1 23 45 67 89');
        expect(widget.onTap, tapCallback);
      });
    });

    group('Accessibility', () {
      testWidgets('should be tappable with sufficient size', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionCard(
            icon: Icons.email,
            title: 'Email',
            onTap: () {},
          ),
        ));

        // Assert - widget should have reasonable tap target
        final size = tester.getSize(find.byType(QuickActionCard));
        expect(size.height, greaterThanOrEqualTo(48)); // Minimum touch target
        expect(size.width, greaterThanOrEqualTo(48));
      });
    });

    group('Styling', () {
      testWidgets('should have rounded corners', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionCard(
            icon: Icons.email,
            title: 'Email',
            onTap: () {},
          ),
        ));

        // Assert - find Container with BoxDecoration
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(QuickActionCard),
            matching: find.byType(Container),
          ).first,
        );
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration?.borderRadius, isNotNull);
      });

      testWidgets('should use surface color background', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionCard(
            icon: Icons.email,
            title: 'Email',
            onTap: () {},
          ),
        ));

        // Assert - find Container with BoxDecoration
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(QuickActionCard),
            matching: find.byType(Container),
          ).first,
        );
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration?.color, isNotNull);
      });
    });
  });
}
