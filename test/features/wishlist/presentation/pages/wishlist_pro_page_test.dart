/// Tests for WishlistProPage
///
/// Verifies the page displays brides who added the pro to their wishlist
/// using Clean Architecture patterns.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/wishlist/domain/entities/entities.dart';
import 'package:lynewed_beta/features/wishlist/presentation/pages/wishlist_pro_page.dart';

void main() {
  // Helper to create test brides
  WishlistBride createTestBride({
    String id = 'bride-1',
    String fullName = 'Jane Doe',
    String? avatarUrl,
    ContactStatus contactStatus = ContactStatus.none,
    DateTime? addedAt,
  }) {
    return WishlistBride(
      profileId: id,
      fullName: fullName,
      avatarUrl: avatarUrl,
      addedAt: addedAt ?? DateTime.now(),
      contactStatus: contactStatus,
    );
  }

  // Helper to build widget for testing
  Widget buildTestWidget({
    List<WishlistBride>? initialBrides,
    bool isLoading = false,
    String? error,
  }) {
    return MaterialApp(
      home: WishlistProPage.withTestData(
        initialBrides: initialBrides,
        isLoading: isLoading,
        error: error,
      ),
    );
  }

  group('WishlistProPage', () {
    // ==============================================================
    // ROUTE TESTS
    // ==============================================================

    group('route configuration', () {
      test('should have correct route name', () {
        expect(WishlistProPage.routeName, 'WishlistPro');
      });

      test('should have correct route path', () {
        expect(WishlistProPage.routePath, '/wishlistPro');
      });
    });

    // ==============================================================
    // LOADING STATE TESTS
    // ==============================================================

    group('loading state', () {
      testWidgets('should display loading indicator when loading', (tester) async {
        await tester.pumpWidget(buildTestWidget(isLoading: true));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    // ==============================================================
    // EMPTY STATE TESTS
    // ==============================================================

    group('empty state', () {
      testWidgets('should display empty state when no brides', (tester) async {
        await tester.pumpWidget(buildTestWidget(initialBrides: []));

        expect(find.text('No fans yet'), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      });

      testWidgets('should display subheader with zero count', (tester) async {
        await tester.pumpWidget(buildTestWidget(initialBrides: []));

        expect(
          find.text('No brides have added you to their wishlist yet.'),
          findsOneWidget,
        );
      });
    });

    // ==============================================================
    // ERROR STATE TESTS
    // ==============================================================

    group('error state', () {
      testWidgets('should display error state when error occurs', (tester) async {
        await tester.pumpWidget(buildTestWidget(error: 'Network error'));

        expect(find.text('Failed to load wishlist'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('should have retry button in error state', (tester) async {
        await tester.pumpWidget(buildTestWidget(error: 'Network error'));

        expect(find.text('Retry'), findsOneWidget);
      });
    });

    // ==============================================================
    // LOADED STATE TESTS
    // ==============================================================

    group('loaded state', () {
      testWidgets('should display list of brides', (tester) async {
        final brides = [
          createTestBride(id: 'bride-1', fullName: 'Jane Doe'),
          createTestBride(id: 'bride-2', fullName: 'Sarah Smith'),
        ];

        await tester.pumpWidget(buildTestWidget(initialBrides: brides));

        expect(find.text('Jane Doe'), findsOneWidget);
        expect(find.text('Sarah Smith'), findsOneWidget);
      });

      testWidgets('should display subheader with correct count for single bride', (tester) async {
        final brides = [createTestBride()];

        await tester.pumpWidget(buildTestWidget(initialBrides: brides));

        expect(
          find.text('1 bride has added you to their wishlist.'),
          findsOneWidget,
        );
      });

      testWidgets('should display subheader with correct count for multiple brides', (tester) async {
        final brides = [
          createTestBride(id: 'bride-1'),
          createTestBride(id: 'bride-2'),
          createTestBride(id: 'bride-3'),
        ];

        await tester.pumpWidget(buildTestWidget(initialBrides: brides));

        expect(
          find.text('3 brides have added you to their wishlist.'),
          findsOneWidget,
        );
      });
    });

    // ==============================================================
    // HEADER TESTS
    // ==============================================================

    group('header', () {
      testWidgets('should display MY FANS title', (tester) async {
        await tester.pumpWidget(buildTestWidget(initialBrides: []));

        expect(find.text('MY FANS'), findsOneWidget);
      });

      testWidgets('should have back button', (tester) async {
        await tester.pumpWidget(buildTestWidget(initialBrides: []));

        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      });
    });

    // ==============================================================
    // BRIDE TILE TESTS
    // ==============================================================

    group('bride tile', () {
      testWidgets('should display Contact button for none status', (tester) async {
        final brides = [
          createTestBride(contactStatus: ContactStatus.none),
        ];

        await tester.pumpWidget(buildTestWidget(initialBrides: brides));

        expect(find.text('Contact'), findsOneWidget);
      });

      testWidgets('should display Pending badge for pending status', (tester) async {
        final brides = [
          createTestBride(contactStatus: ContactStatus.pending),
        ];

        await tester.pumpWidget(buildTestWidget(initialBrides: brides));

        expect(find.text('Pending'), findsOneWidget);
      });

      testWidgets('should display Chat button for accepted status', (tester) async {
        final brides = [
          createTestBride(contactStatus: ContactStatus.accepted),
        ];

        await tester.pumpWidget(buildTestWidget(initialBrides: brides));

        expect(find.text('Chat'), findsOneWidget);
      });
    });

    // ==============================================================
    // REFRESH TESTS
    // ==============================================================

    group('refresh', () {
      testWidgets('should have RefreshIndicator when loaded', (tester) async {
        final brides = [createTestBride()];

        await tester.pumpWidget(buildTestWidget(initialBrides: brides));

        expect(find.byType(RefreshIndicator), findsOneWidget);
      });
    });
  });
}
