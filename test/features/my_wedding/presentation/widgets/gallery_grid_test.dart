/// Tests for GalleryGrid widget.
///
/// Comprehensive tests covering:
/// - Grid display
/// - Filter tabs
/// - Selection mode
/// - Empty states
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/design/widgets/lynewed_chip.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/gallery_grid.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/photo_tile.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/selection_action_bar.dart';

void main() {
  final testMediaItems = [
    const GalleryMediaItem(
      id: 'media-1',
      imageUrl: 'https://example.com/1.jpg',
      isFavorite: true,
    ),
    const GalleryMediaItem(
      id: 'media-2',
      imageUrl: 'https://example.com/2.jpg',
    ),
    const GalleryMediaItem(
      id: 'media-3',
      imageUrl: 'https://example.com/3.jpg',
      isHidden: true,
    ),
    const GalleryMediaItem(
      id: 'media-4',
      imageUrl: 'https://example.com/4.jpg',
      isVideo: true,
    ),
    const GalleryMediaItem(
      id: 'media-5',
      imageUrl: 'https://example.com/5.jpg',
      isFavorite: true,
    ),
  ];

  Widget buildGalleryGrid({
    List<GalleryMediaItem>? mediaItems,
    void Function(GalleryMediaItem)? onMediaTap,
    void Function(Set<String>)? onDownloadSelected,
    void Function(Set<String>)? onDeleteSelected,
    void Function(Set<String>)? onShareSelected,
    void Function(Set<String>)? onAddToMagazine,
    bool showFilterTabs = true,
    bool isReadOnly = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: GalleryGrid(
          mediaItems: mediaItems ?? testMediaItems,
          onMediaTap: onMediaTap,
          onDownloadSelected: onDownloadSelected,
          onDeleteSelected: onDeleteSelected,
          onShareSelected: onShareSelected,
          onAddToMagazine: onAddToMagazine,
          showFilterTabs: showFilterTabs,
          isReadOnly: isReadOnly,
        ),
      ),
    );
  }

  group('GalleryGrid', () {
    group('display', () {
      testWidgets('should display photo tiles', (tester) async {
        await tester.pumpWidget(buildGalleryGrid());
        await tester.pumpAndSettle();

        // Should show 4 items (all except hidden)
        expect(find.byType(PhotoTile), findsNWidgets(4));
      });

      testWidgets('should display filter tabs when showFilterTabs is true',
          (tester) async {
        await tester.pumpWidget(buildGalleryGrid(showFilterTabs: true));
        await tester.pumpAndSettle();

        expect(find.byType(LynewedChip), findsNWidgets(3));
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Favorites'), findsOneWidget);
        expect(find.text('Hidden'), findsOneWidget);
      });

      testWidgets('should not display filter tabs when showFilterTabs is false',
          (tester) async {
        await tester.pumpWidget(buildGalleryGrid(showFilterTabs: false));
        await tester.pumpAndSettle();

        expect(find.byType(LynewedChip), findsNothing);
      });

      testWidgets('should not display selection action bar initially',
          (tester) async {
        await tester.pumpWidget(buildGalleryGrid());
        await tester.pumpAndSettle();

        expect(find.byType(SelectionActionBar), findsNothing);
      });
    });

    group('filtering', () {
      testWidgets('should filter to show only favorites when Favorites tapped',
          (tester) async {
        await tester.pumpWidget(buildGalleryGrid());
        await tester.pumpAndSettle();

        // Tap Favorites filter
        await tester.tap(find.text('Favorites'));
        await tester.pumpAndSettle();

        // Should show only 2 favorite items
        expect(find.byType(PhotoTile), findsNWidgets(2));
      });

      testWidgets('should filter to show only hidden when Hidden tapped',
          (tester) async {
        await tester.pumpWidget(buildGalleryGrid());
        await tester.pumpAndSettle();

        // Tap Hidden filter
        await tester.tap(find.text('Hidden'));
        await tester.pumpAndSettle();

        // Should show only 1 hidden item
        expect(find.byType(PhotoTile), findsNWidgets(1));
      });

      testWidgets('should show all non-hidden when All tapped', (tester) async {
        await tester.pumpWidget(buildGalleryGrid());
        await tester.pumpAndSettle();

        // First go to favorites
        await tester.tap(find.text('Favorites'));
        await tester.pumpAndSettle();
        expect(find.byType(PhotoTile), findsNWidgets(2));

        // Then back to all
        await tester.tap(find.text('All'));
        await tester.pumpAndSettle();
        expect(find.byType(PhotoTile), findsNWidgets(4));
      });
    });

    group('selection mode', () {
      testWidgets('should enter selection mode on long press', (tester) async {
        await tester.pumpWidget(buildGalleryGrid());
        await tester.pumpAndSettle();

        // Long press on first item
        await tester.longPress(find.byType(PhotoTile).first);
        await tester.pumpAndSettle();

        // Selection action bar should appear
        expect(find.byType(SelectionActionBar), findsOneWidget);
        // Should show 1 selected
        expect(find.text('1 selected'), findsOneWidget);
      });

      testWidgets('should not enter selection mode when read only',
          (tester) async {
        await tester.pumpWidget(buildGalleryGrid(isReadOnly: true));
        await tester.pumpAndSettle();

        // Long press on first item
        await tester.longPress(find.byType(PhotoTile).first);
        await tester.pumpAndSettle();

        // Selection action bar should NOT appear
        expect(find.byType(SelectionActionBar), findsNothing);
      });

      testWidgets('should hide filter tabs in selection mode', (tester) async {
        await tester.pumpWidget(buildGalleryGrid());
        await tester.pumpAndSettle();

        // Verify filter tabs are visible
        expect(find.byType(LynewedChip), findsNWidgets(3));

        // Enter selection mode
        await tester.longPress(find.byType(PhotoTile).first);
        await tester.pumpAndSettle();

        // Filter tabs should be hidden
        expect(find.byType(LynewedChip), findsNothing);
      });

      testWidgets('should select additional items on tap in selection mode',
          (tester) async {
        await tester.pumpWidget(buildGalleryGrid());
        await tester.pumpAndSettle();

        // Enter selection mode
        await tester.longPress(find.byType(PhotoTile).first);
        await tester.pumpAndSettle();

        // Tap on second item
        await tester.tap(find.byType(PhotoTile).at(1));
        await tester.pumpAndSettle();

        // Should show 2 selected
        expect(find.text('2 selected'), findsOneWidget);
      });

      testWidgets('should exit selection mode when close button tapped',
          (tester) async {
        await tester.pumpWidget(buildGalleryGrid());
        await tester.pumpAndSettle();

        // Enter selection mode
        await tester.longPress(find.byType(PhotoTile).first);
        await tester.pumpAndSettle();

        // Tap close button
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        // Selection action bar should disappear
        expect(find.byType(SelectionActionBar), findsNothing);
        // Filter tabs should reappear
        expect(find.byType(LynewedChip), findsNWidgets(3));
      });
    });

    group('empty states', () {
      testWidgets('should display empty state when no items', (tester) async {
        await tester.pumpWidget(buildGalleryGrid(mediaItems: []));
        await tester.pumpAndSettle();

        expect(find.text('No photos yet'), findsOneWidget);
        expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      });

      testWidgets('should display favorites empty state', (tester) async {
        await tester.pumpWidget(buildGalleryGrid(
          mediaItems: [
            const GalleryMediaItem(
              id: 'media-1',
              imageUrl: 'https://example.com/1.jpg',
              isFavorite: false,
            ),
          ],
        ));
        await tester.pumpAndSettle();

        // Go to favorites
        await tester.tap(find.text('Favorites'));
        await tester.pumpAndSettle();

        expect(find.text('No favorites yet'), findsOneWidget);
        expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
      });

      testWidgets('should display hidden empty state', (tester) async {
        await tester.pumpWidget(buildGalleryGrid(
          mediaItems: [
            const GalleryMediaItem(
              id: 'media-1',
              imageUrl: 'https://example.com/1.jpg',
              isHidden: false,
            ),
          ],
        ));
        await tester.pumpAndSettle();

        // Go to hidden
        await tester.tap(find.text('Hidden'));
        await tester.pumpAndSettle();

        expect(find.text('No hidden photos'), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      });
    });

    group('callbacks', () {
      testWidgets('should call onMediaTap when item tapped in normal mode',
          (tester) async {
        GalleryMediaItem? tappedItem;
        await tester.pumpWidget(buildGalleryGrid(
          onMediaTap: (item) => tappedItem = item,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(PhotoTile).first);
        await tester.pumpAndSettle();

        expect(tappedItem, isNotNull);
        expect(tappedItem!.id, 'media-1');
      });

      testWidgets(
          'should not call onMediaTap when item tapped in selection mode',
          (tester) async {
        GalleryMediaItem? tappedItem;
        await tester.pumpWidget(buildGalleryGrid(
          onMediaTap: (item) => tappedItem = item,
        ));
        await tester.pumpAndSettle();

        // Enter selection mode
        await tester.longPress(find.byType(PhotoTile).first);
        await tester.pumpAndSettle();

        // Tap on second item
        await tester.tap(find.byType(PhotoTile).at(1));
        await tester.pumpAndSettle();

        // onMediaTap should not have been called for second tap
        expect(tappedItem, isNull);
      });
    });
  });

  group('GalleryMediaItem', () {
    test('should create with required parameters', () {
      const item = GalleryMediaItem(
        id: 'test-1',
        imageUrl: 'https://example.com/test.jpg',
      );

      expect(item.id, 'test-1');
      expect(item.imageUrl, 'https://example.com/test.jpg');
      expect(item.thumbnailUrl, isNull);
      expect(item.isVideo, false);
      expect(item.isFavorite, false);
      expect(item.isHidden, false);
    });

    test('should create with all parameters', () {
      const item = GalleryMediaItem(
        id: 'test-1',
        imageUrl: 'https://example.com/test.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        isVideo: true,
        isFavorite: true,
        isHidden: true,
      );

      expect(item.id, 'test-1');
      expect(item.imageUrl, 'https://example.com/test.jpg');
      expect(item.thumbnailUrl, 'https://example.com/thumb.jpg');
      expect(item.isVideo, true);
      expect(item.isFavorite, true);
      expect(item.isHidden, true);
    });
  });
}
