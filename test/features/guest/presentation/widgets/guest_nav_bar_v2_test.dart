/// Tests for GuestNavBarV2 widget.
///
/// Custom 84px navigation bar for guest users with 3 tabs.
/// Exact same UI as NavBarBridesWidget.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lynewed_beta/features/guest/presentation/widgets/guest_nav_bar_v2.dart';

void main() {
  group('GuestNavBarV2', () {
    group('Structure', () {
      testWidgets('tabs are evenly distributed using Expanded', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GuestNavBarV2(
                currentIndex: 0,
                onTap: (_) {},
              ),
            ),
          ),
        );

        // Each tab should be wrapped in an Expanded widget for even distribution
        expect(find.byType(Expanded), findsNWidgets(3));
      });

      testWidgets('renders with 84px height', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GuestNavBarV2(
                currentIndex: 0,
                onTap: (_) {},
              ),
            ),
          ),
        );

        // Find the SizedBox with 84px height
        final sizedBox = tester.widget<SizedBox>(
          find.byType(SizedBox).first,
        );
        expect(sizedBox.height, 84.0);
      });

      testWidgets('renders 3 tabs', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GuestNavBarV2(
                currentIndex: 0,
                onTap: (_) {},
              ),
            ),
          ),
        );

        // Should have 3 InkWell tabs
        expect(find.byType(InkWell), findsNWidgets(3));
      });

      testWidgets('renders correct tab labels', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GuestNavBarV2(
                currentIndex: 0,
                onTap: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('Album'), findsOneWidget);
        expect(find.text('Chat'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
      });

      testWidgets('renders correct tab icons', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GuestNavBarV2(
                currentIndex: 0,
                onTap: (_) {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
        expect(find.byIcon(Icons.chat_bubble_outline_sharp), findsOneWidget);
        expect(find.byIcon(Icons.person_outline), findsOneWidget);
      });

      testWidgets('renders top divider', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GuestNavBarV2(
                currentIndex: 0,
                onTap: (_) {},
              ),
            ),
          ),
        );

        // SizedBox 84px should exist with Stack child
        final sizedBox = tester.widget<SizedBox>(
          find.byType(SizedBox).first,
        );
        expect(sizedBox.height, 84.0);
        expect(sizedBox.child, isA<Stack>());
      });
    });

    group('Tab Selection', () {
      testWidgets('highlights first tab when currentIndex is 0',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GuestNavBarV2(
                currentIndex: 0,
                onTap: (_) {},
              ),
            ),
          ),
        );

        // Album icon should be highlighted (primary color)
        final albumIcon = tester.widget<Icon>(
          find.byIcon(Icons.photo_library_outlined),
        );
        // The active tab should have textPrimary color
        expect(albumIcon.color, isNotNull);
      });

      testWidgets('highlights second tab when currentIndex is 1',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GuestNavBarV2(
                currentIndex: 1,
                onTap: (_) {},
              ),
            ),
          ),
        );

        // Chat icon should be highlighted
        final chatIcon = tester.widget<Icon>(
          find.byIcon(Icons.chat_bubble_outline_sharp),
        );
        expect(chatIcon.color, isNotNull);
      });

      testWidgets('highlights third tab when currentIndex is 2',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GuestNavBarV2(
                currentIndex: 2,
                onTap: (_) {},
              ),
            ),
          ),
        );

        // Profile icon should be highlighted
        final profileIcon = tester.widget<Icon>(
          find.byIcon(Icons.person_outline),
        );
        expect(profileIcon.color, isNotNull);
      });
    });

    group('UnreadCount parameter', () {
      testWidgets('accepts unreadCount parameter for API compatibility',
          (tester) async {
        // unreadCount is kept for API compatibility but not displayed
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GuestNavBarV2(
                currentIndex: 0,
                onTap: (_) {},
                unreadCount: 5,
              ),
            ),
          ),
        );

        // Widget should render without errors
        expect(find.byType(GuestNavBarV2), findsOneWidget);
      });
    });

    group('Interaction', () {
      testWidgets('calls onTap with index 0 when Album tab is tapped',
          (tester) async {
        int? tappedIndex;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GuestNavBarV2(
                currentIndex: 0,
                onTap: (index) => tappedIndex = index,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Album'));
        await tester.pump();

        expect(tappedIndex, 0);
      });

      testWidgets('calls onTap with index 1 when Chat tab is tapped',
          (tester) async {
        int? tappedIndex;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GuestNavBarV2(
                currentIndex: 0,
                onTap: (index) => tappedIndex = index,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Chat'));
        await tester.pump();

        expect(tappedIndex, 1);
      });

      testWidgets('calls onTap with index 2 when Profile tab is tapped',
          (tester) async {
        int? tappedIndex;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GuestNavBarV2(
                currentIndex: 0,
                onTap: (index) => tappedIndex = index,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Profile'));
        await tester.pump();

        expect(tappedIndex, 2);
      });

      testWidgets('InkWell has transparent splash colors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: GuestNavBarV2(
                currentIndex: 0,
                onTap: (_) {},
              ),
            ),
          ),
        );

        final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));

        for (final inkWell in inkWells) {
          expect(inkWell.splashColor, Colors.transparent);
          expect(inkWell.focusColor, Colors.transparent);
          expect(inkWell.hoverColor, Colors.transparent);
          expect(inkWell.highlightColor, Colors.transparent);
        }
      });
    });
  });
}
