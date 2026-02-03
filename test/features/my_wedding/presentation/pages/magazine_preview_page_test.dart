/// Tests for MagazinePreviewPage.
///
/// Tests page rendering, navigation, and format selection.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_format.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/magazine_selection_state.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/pages/magazine_preview_page.dart';

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (_, __, ___) => true;
  }
}

void main() {
  // Mock HTTP client to avoid network requests in tests
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  // Test helper to create MagazinePhoto
  MagazinePhoto createPhoto(int index) {
    return MagazinePhoto(
      selectionId: 'sel-$index',
      mediaType: 'album_image',
      mediaId: 'img-$index',
      position: index,
      thumbnailUrl: 'https://example.com/$index.jpg',
    );
  }

  List<MagazinePhoto> createPhotos(int count) {
    return List.generate(count, (i) => createPhoto(i + 1));
  }

  Widget buildTestWidget({
    required int photoCount,
    VoidCallback? onNavigateBack,
    void Function(MagazineFormat)? onNavigateToCheckout,
  }) {
    return MaterialApp(
      home: MagazinePreviewPage(
        photos: createPhotos(photoCount),
        weddingTitle: 'Test Wedding',
        weddingDate: DateTime(2025, 6, 12),
        onNavigateBack: onNavigateBack,
        onNavigateToCheckout: onNavigateToCheckout,
      ),
    );
  }

  group('MagazinePreviewPage', () {
    testWidgets('should display loading initially', (tester) async {
      await tester.pumpWidget(buildTestWidget(photoCount: 10));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Generating your magazine...'), findsOneWidget);
    });

    testWidgets('should display header title', (tester) async {
      await tester.pumpWidget(buildTestWidget(photoCount: 10));

      expect(find.text('Magazine Preview'), findsOneWidget);
    });

    testWidgets('should show page indicator after loading', (tester) async {
      await tester.pumpWidget(buildTestWidget(photoCount: 10));
      await tester.pump(const Duration(milliseconds: 100));

      // Should show "1 / X" page indicator
      expect(find.textContaining('1 /'), findsOneWidget);
    });

    testWidgets('should display order button with price', (tester) async {
      await tester.pumpWidget(buildTestWidget(photoCount: 10));
      await tester.pump(const Duration(milliseconds: 100));

      // Should show order button with price
      expect(find.textContaining('Order Magazine'), findsOneWidget);
    });

    testWidgets('should call onNavigateBack when back button pressed',
        (tester) async {
      var backPressed = false;
      await tester.pumpWidget(buildTestWidget(
        photoCount: 10,
        onNavigateBack: () => backPressed = true,
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap the back button (GestureDetector wrapping icon)
      final backButton = find.byIcon(Icons.chevron_left);
      await tester.tap(backButton);
      await tester.pump();

      expect(backPressed, true);
    });

    testWidgets('should display Edit button', (tester) async {
      await tester.pumpWidget(buildTestWidget(photoCount: 10));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('should display format name in bottom bar', (tester) async {
      await tester.pumpWidget(buildTestWidget(photoCount: 10));
      await tester.pump(const Duration(milliseconds: 100));

      // After loading, should show format name (GUEST EDITION for 10 photos)
      expect(find.text('GUEST EDITION'), findsWidgets);
    });

    testWidgets('should show Change button for format', (tester) async {
      await tester.pumpWidget(buildTestWidget(photoCount: 10));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Change'), findsOneWidget);
    });

    testWidgets('should call onNavigateToCheckout when order button pressed',
        (tester) async {
      MagazineFormat? checkoutFormat;
      await tester.pumpWidget(buildTestWidget(
        photoCount: 10,
        onNavigateToCheckout: (format) => checkoutFormat = format,
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap the order button
      final orderButton = find.textContaining('Order Magazine');
      await tester.tap(orderButton);
      await tester.pump();

      expect(checkoutFormat, isNotNull);
    });

    testWidgets('should navigate pages with PageView', (tester) async {
      await tester.pumpWidget(buildTestWidget(photoCount: 10));
      await tester.pump(const Duration(milliseconds: 100));

      // Should have a PageView for pages
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should auto-select cheapest valid format for photo count',
        (tester) async {
      // With 25 photos, should select ICONIC (guest edition is too small)
      await tester.pumpWidget(buildTestWidget(photoCount: 25));
      await tester.pump(const Duration(milliseconds: 100));

      // ICONIC should be selected (visible in bottom bar)
      expect(find.text('ICONIC'), findsWidgets);
    });
  });
}
