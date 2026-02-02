/// Tests for GuestNavBar widget.
///
/// Verifies the guest navigation bar including:
/// - 3 tabs display
/// - Tab selection
/// - Icon states
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/guest/presentation/widgets/guest_nav_bar.dart';

void main() {
  group('GuestNavBar', () {
    Widget buildTestWidget({
      int currentIndex = 0,
      ValueChanged<int>? onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          bottomNavigationBar: GuestNavBar(
            currentIndex: currentIndex,
            onTap: onTap ?? (_) {},
          ),
        ),
      );
    }

    group('Basic rendering', () {
      testWidgets('should display exactly 3 tabs', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final navBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(navBar.items.length, 3);
      });

      testWidgets('should display Album tab', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Album'), findsOneWidget);
        expect(find.byIcon(Icons.photo_library), findsOneWidget);
      });

      testWidgets('should display Chat tab', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Chat'), findsOneWidget);
        expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      });

      testWidgets('should display Profile tab', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Profile'), findsOneWidget);
        expect(find.byIcon(Icons.person_outline), findsOneWidget);
      });
    });

    group('Tab selection', () {
      testWidgets('should highlight Album tab when index is 0', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(currentIndex: 0));

        // Assert
        final navBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(navBar.currentIndex, 0);
        // Active icon for Album
        expect(find.byIcon(Icons.photo_library), findsOneWidget);
      });

      testWidgets('should highlight Chat tab when index is 1', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(currentIndex: 1));

        // Assert
        final navBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(navBar.currentIndex, 1);
        // Active icon for Chat
        expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
      });

      testWidgets('should highlight Profile tab when index is 2', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(currentIndex: 2));

        // Assert
        final navBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(navBar.currentIndex, 2);
        // Active icon for Profile
        expect(find.byIcon(Icons.person), findsOneWidget);
      });
    });

    group('Unread badge', () {
      Widget buildTestWidgetWithBadge({
        int currentIndex = 0,
        int unreadCount = 0,
        ValueChanged<int>? onTap,
      }) {
        return MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GuestNavBar(
              currentIndex: currentIndex,
              onTap: onTap ?? (_) {},
              unreadCount: unreadCount,
            ),
          ),
        );
      }

      testWidgets('should not display badge when unreadCount is 0',
          (tester) async {
        await tester.pumpWidget(buildTestWidgetWithBadge(unreadCount: 0));

        // Badge widget exists but is not visible
        expect(find.byType(Badge), findsWidgets);
        final badges = tester.widgetList<Badge>(find.byType(Badge));
        for (final badge in badges) {
          expect(badge.isLabelVisible, isFalse);
        }
      });

      testWidgets('should display badge when unreadCount > 0', (tester) async {
        await tester.pumpWidget(buildTestWidgetWithBadge(unreadCount: 5));

        // At least one badge should be visible
        final badges = tester.widgetList<Badge>(find.byType(Badge));
        final visibleBadges = badges.where((b) => b.isLabelVisible == true);
        expect(visibleBadges.length, greaterThanOrEqualTo(1));
      });

      testWidgets('should display correct count on badge', (tester) async {
        await tester.pumpWidget(buildTestWidgetWithBadge(unreadCount: 3));

        expect(find.text('3'), findsOneWidget);
      });
    });

    group('Tab interaction', () {
      testWidgets('should call onTap when Album tab is tapped', (tester) async {
        // Arrange
        int? tappedIndex;
        await tester.pumpWidget(buildTestWidget(
          currentIndex: 1, // Start on Chat
          onTap: (index) => tappedIndex = index,
        ));

        // Act
        await tester.tap(find.text('Album'));
        await tester.pump();

        // Assert
        expect(tappedIndex, 0);
      });

      testWidgets('should call onTap when Chat tab is tapped', (tester) async {
        // Arrange
        int? tappedIndex;
        await tester.pumpWidget(buildTestWidget(
          currentIndex: 0, // Start on Album
          onTap: (index) => tappedIndex = index,
        ));

        // Act
        await tester.tap(find.text('Chat'));
        await tester.pump();

        // Assert
        expect(tappedIndex, 1);
      });

      testWidgets('should call onTap when Profile tab is tapped', (tester) async {
        // Arrange
        int? tappedIndex;
        await tester.pumpWidget(buildTestWidget(
          currentIndex: 0, // Start on Album
          onTap: (index) => tappedIndex = index,
        ));

        // Act
        await tester.tap(find.text('Profile'));
        await tester.pump();

        // Assert
        expect(tappedIndex, 2);
      });
    });
  });
}
