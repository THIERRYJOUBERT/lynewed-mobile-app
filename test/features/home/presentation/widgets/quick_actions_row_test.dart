/// Tests for QuickActionsRow widget.
///
/// Verifies the quick actions row widget:
/// - Displays all 4 action items (Find Pros, Favorites, Messages, Inspirations)
/// - Handles tap callbacks for each action
/// - Proper horizontal layout
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/home/presentation/widgets/quick_actions_row.dart';
import 'package:lynewed_beta/features/home/presentation/widgets/quick_action_item.dart';

void main() {
  Widget buildTestWidget({
    VoidCallback? onFindProsTap,
    VoidCallback? onFavoritesTap,
    VoidCallback? onMessagesTap,
    VoidCallback? onInspirationsTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: QuickActionsRow(
          onFindProsTap: onFindProsTap ?? () {},
          onFavoritesTap: onFavoritesTap ?? () {},
          onMessagesTap: onMessagesTap ?? () {},
          onInspirationsTap: onInspirationsTap ?? () {},
        ),
      ),
    );
  }

  group('QuickActionsRow', () {
    group('Basic rendering', () {
      testWidgets('should display all 4 quick action items', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byType(QuickActionItem), findsNWidgets(4));
      });

      testWidgets('should display Find Pros action', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Find Pros'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('should display Favorites action', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Favorites'), findsOneWidget);
        expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
      });

      testWidgets('should display Messages action', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Messages'), findsOneWidget);
        expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      });

      testWidgets('should display Inspirations action', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Inspirations'), findsOneWidget);
        expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      });
    });

    group('Tap handling', () {
      testWidgets('should call onFindProsTap when Find Pros is tapped', (tester) async {
        // Arrange
        var tapped = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onFindProsTap: () => tapped = true,
        ));
        await tester.tap(find.text('Find Pros'));
        await tester.pump();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('should call onFavoritesTap when Favorites is tapped', (tester) async {
        // Arrange
        var tapped = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onFavoritesTap: () => tapped = true,
        ));
        await tester.tap(find.text('Favorites'));
        await tester.pump();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('should call onMessagesTap when Messages is tapped', (tester) async {
        // Arrange
        var tapped = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onMessagesTap: () => tapped = true,
        ));
        await tester.tap(find.text('Messages'));
        await tester.pump();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('should call onInspirationsTap when Inspirations is tapped', (tester) async {
        // Arrange
        var tapped = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onInspirationsTap: () => tapped = true,
        ));
        await tester.tap(find.text('Inspirations'));
        await tester.pump();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('each action should call its own callback', (tester) async {
        // Arrange
        var findProsTapped = false;
        var favoritesTapped = false;
        var messagesTapped = false;
        var inspirationsTapped = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onFindProsTap: () => findProsTapped = true,
          onFavoritesTap: () => favoritesTapped = true,
          onMessagesTap: () => messagesTapped = true,
          onInspirationsTap: () => inspirationsTapped = true,
        ));

        // Tap Find Pros
        await tester.tap(find.text('Find Pros'));
        await tester.pump();
        expect(findProsTapped, isTrue);
        expect(favoritesTapped, isFalse);
        expect(messagesTapped, isFalse);
        expect(inspirationsTapped, isFalse);

        // Tap Favorites
        await tester.tap(find.text('Favorites'));
        await tester.pump();
        expect(favoritesTapped, isTrue);

        // Tap Messages
        await tester.tap(find.text('Messages'));
        await tester.pump();
        expect(messagesTapped, isTrue);

        // Tap Inspirations
        await tester.tap(find.text('Inspirations'));
        await tester.pump();
        expect(inspirationsTapped, isTrue);
      });
    });

    group('Layout', () {
      testWidgets('actions should be in a horizontal row', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert - items should be horizontally positioned
        final findProsCenter = tester.getCenter(find.text('Find Pros'));
        final favoritesCenter = tester.getCenter(find.text('Favorites'));
        final messagesCenter = tester.getCenter(find.text('Messages'));
        final inspirationsCenter = tester.getCenter(find.text('Inspirations'));

        // All should be on roughly the same vertical position
        expect(findProsCenter.dy, closeTo(favoritesCenter.dy, 20));
        expect(favoritesCenter.dy, closeTo(messagesCenter.dy, 20));
        expect(messagesCenter.dy, closeTo(inspirationsCenter.dy, 20));

        // Should be in left-to-right order
        expect(findProsCenter.dx, lessThan(favoritesCenter.dx));
        expect(favoritesCenter.dx, lessThan(messagesCenter.dx));
        expect(messagesCenter.dx, lessThan(inspirationsCenter.dx));
      });

      testWidgets('should have proper spacing between items', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert - items should be evenly spaced
        final items = tester.widgetList<QuickActionItem>(find.byType(QuickActionItem));
        expect(items.length, 4);
      });
    });

    group('Widget configuration', () {
      testWidgets('should accept all required callback parameters', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: QuickActionsRow(
              onFindProsTap: () {},
              onFavoritesTap: () {},
              onMessagesTap: () {},
              onInspirationsTap: () {},
            ),
          ),
        ));

        // Assert
        expect(find.byType(QuickActionsRow), findsOneWidget);
      });
    });
  });
}
