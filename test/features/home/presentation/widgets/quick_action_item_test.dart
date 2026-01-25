/// Tests for QuickActionItem widget.
///
/// Verifies the quick action item widget:
/// - Renders icon and label correctly
/// - Handles tap callback
/// - Proper styling and layout
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/home/presentation/widgets/quick_action_item.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('QuickActionItem', () {
    group('Basic rendering', () {
      testWidgets('should display icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionItem(
            icon: Icons.search,
            label: 'Find Pros',
            onTap: () {},
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('should display label', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionItem(
            icon: Icons.search,
            label: 'Find Pros',
            onTap: () {},
          ),
        ));

        // Assert
        expect(find.text('Find Pros'), findsOneWidget);
      });

      testWidgets('should display custom icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionItem(
            icon: Icons.favorite,
            label: 'Favorites',
            onTap: () {},
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        expect(find.text('Favorites'), findsOneWidget);
      });

      testWidgets('should display different labels correctly', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionItem(
            icon: Icons.message,
            label: 'Messages',
            onTap: () {},
          ),
        ));

        // Assert
        expect(find.text('Messages'), findsOneWidget);
      });
    });

    group('Tap handling', () {
      testWidgets('should call onTap when tapped', (tester) async {
        // Arrange
        var tapped = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionItem(
            icon: Icons.search,
            label: 'Find Pros',
            onTap: () => tapped = true,
          ),
        ));
        await tester.tap(find.byType(QuickActionItem));
        await tester.pump();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('should call onTap when tapping on icon', (tester) async {
        // Arrange
        var tapped = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionItem(
            icon: Icons.search,
            label: 'Find Pros',
            onTap: () => tapped = true,
          ),
        ));
        await tester.tap(find.byIcon(Icons.search));
        await tester.pump();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('should call onTap when tapping on label', (tester) async {
        // Arrange
        var tapped = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionItem(
            icon: Icons.search,
            label: 'Find Pros',
            onTap: () => tapped = true,
          ),
        ));
        await tester.tap(find.text('Find Pros'));
        await tester.pump();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('should not crash when onTap is called multiple times', (tester) async {
        // Arrange
        var tapCount = 0;

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionItem(
            icon: Icons.search,
            label: 'Find Pros',
            onTap: () => tapCount++,
          ),
        ));
        await tester.tap(find.byType(QuickActionItem));
        await tester.pump();
        await tester.tap(find.byType(QuickActionItem));
        await tester.pump();

        // Assert
        expect(tapCount, 2);
      });
    });

    group('Layout', () {
      testWidgets('icon should be above label', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionItem(
            icon: Icons.search,
            label: 'Find Pros',
            onTap: () {},
          ),
        ));

        // Assert
        final iconPosition = tester.getCenter(find.byIcon(Icons.search));
        final labelPosition = tester.getCenter(find.text('Find Pros'));
        expect(iconPosition.dy, lessThan(labelPosition.dy));
      });

      testWidgets('should be tappable across entire widget area', (tester) async {
        // Arrange
        var tapped = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionItem(
            icon: Icons.search,
            label: 'Find Pros',
            onTap: () => tapped = true,
          ),
        ));

        // Tap the widget
        await tester.tap(find.byType(QuickActionItem));
        await tester.pump();

        // Assert
        expect(tapped, isTrue);
      });
    });

    group('Widget configuration', () {
      testWidgets('should accept all required parameters', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: QuickActionItem(
            icon: Icons.photo_library,
            label: 'Inspirations',
            onTap: () {},
          ),
        ));

        // Assert
        expect(find.byType(QuickActionItem), findsOneWidget);
        expect(find.byIcon(Icons.photo_library), findsOneWidget);
        expect(find.text('Inspirations'), findsOneWidget);
      });

      testWidgets('should handle long labels gracefully', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: SizedBox(
            width: 80, // Constrained width
            child: QuickActionItem(
              icon: Icons.search,
              label: 'Very Long Label Text',
              onTap: () {},
            ),
          ),
        ));

        // Assert - should not crash and render
        expect(find.byType(QuickActionItem), findsOneWidget);
      });
    });
  });
}
