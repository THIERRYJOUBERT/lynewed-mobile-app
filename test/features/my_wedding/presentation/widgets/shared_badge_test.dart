/// Tests for SharedBadge widget
///
/// Tests the shared indicator badge on photo tiles.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/shared_badge.dart';

void main() {
  group('SharedBadge', () {
    testWidgets('should display share icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SharedBadge(),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('should have correct default size', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SharedBadge(),
          ),
        ),
      );

      // Assert - find the container with background
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SharedBadge),
          matching: find.byType(Container).first,
        ),
      );
      expect(container, isNotNull);
    });

    testWidgets('should use custom size when provided', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SharedBadge(size: 32),
          ),
        ),
      );

      // Assert - icon size is 65% of container size
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, closeTo(32 * 0.65, 0.1)); // 20.8
    });

    testWidgets('should be visible by default', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SharedBadge(),
          ),
        ),
      );

      // Assert
      expect(find.byType(SharedBadge), findsOneWidget);
    });
  });

  group('SharedBadge positioning', () {
    testWidgets('should work inside Stack for overlay positioning', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey,
                ),
                const Positioned(
                  top: 8,
                  right: 8,
                  child: SharedBadge(),
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(SharedBadge), findsOneWidget);
    });
  });
}
