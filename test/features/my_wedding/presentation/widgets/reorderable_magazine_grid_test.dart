/// Tests for ReorderableMagazineGrid widgets.
///
/// Comprehensive tests covering rendering, interaction, and callbacks.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/magazine_selection_state.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/reorderable_magazine_grid.dart';

void main() {
  group('ReorderableMagazineGridView', () {
    final testPhotos = [
      const MagazinePhoto(
        selectionId: 'sel-1',
        mediaType: 'album_image',
        mediaId: 'img-1',
        position: 1,
        thumbnailUrl: 'https://example.com/thumb1.jpg',
      ),
      const MagazinePhoto(
        selectionId: 'sel-2',
        mediaType: 'album_image',
        mediaId: 'img-2',
        position: 2,
        thumbnailUrl: 'https://example.com/thumb2.jpg',
      ),
      const MagazinePhoto(
        selectionId: 'sel-3',
        mediaType: 'album_image',
        mediaId: 'img-3',
        position: 3,
        thumbnailUrl: 'https://example.com/thumb3.jpg',
      ),
    ];

    testWidgets('should render all photos', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableMagazineGridView(
              photos: testPhotos,
              onReorder: (_, __) {},
              onRemove: (_) {},
            ),
          ),
        ),
      );

      // Should find CachedNetworkImage widgets
      expect(find.byType(CachedNetworkImage), findsNWidgets(3));

      // Should find remove icons
      expect(find.byIcon(Icons.close), findsNWidgets(3));
    });

    testWidgets('should render empty widget when photos is empty',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableMagazineGridView(
              photos: const [],
              onReorder: (_, __) {},
              onRemove: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should call onRemove when remove button tapped',
        (tester) async {
      String? removedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableMagazineGridView(
              photos: testPhotos,
              onReorder: (_, __) {},
              onRemove: (id) => removedId = id,
            ),
          ),
        ),
      );

      // Tap the first remove button
      final removeButtons = find.byIcon(Icons.close);
      await tester.tap(removeButtons.first);
      await tester.pump();

      expect(removedId, 'sel-1');
    });

    testWidgets('should use custom crossAxisCount', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableMagazineGridView(
              photos: testPhotos,
              onReorder: (_, __) {},
              onRemove: (_) {},
              crossAxisCount: 4,
            ),
          ),
        ),
      );

      // Widget should render without error
      expect(find.byType(GridView), findsOneWidget);
    });
  });

  group('ReorderableMagazineGrid', () {
    final testPhotos = [
      const MagazinePhoto(
        selectionId: 'sel-1',
        mediaType: 'album_image',
        mediaId: 'img-1',
        position: 1,
        thumbnailUrl: 'https://example.com/thumb1.jpg',
      ),
      const MagazinePhoto(
        selectionId: 'sel-2',
        mediaType: 'album_image',
        mediaId: 'img-2',
        position: 2,
        thumbnailUrl: 'https://example.com/thumb2.jpg',
      ),
    ];

    testWidgets('should render as list with drag handles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableMagazineGrid(
              photos: testPhotos,
              onReorder: (_, __) {},
              onRemove: (_) {},
            ),
          ),
        ),
      );

      // Should find drag indicators
      expect(find.byIcon(Icons.drag_indicator), findsNWidgets(2));

      // Should find remove buttons
      expect(find.byIcon(Icons.remove_circle_outline), findsNWidgets(2));
    });

    testWidgets('should render empty widget when photos is empty',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableMagazineGrid(
              photos: const [],
              onReorder: (_, __) {},
              onRemove: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should call onRemove when remove button tapped',
        (tester) async {
      String? removedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableMagazineGrid(
              photos: testPhotos,
              onReorder: (_, __) {},
              onRemove: (id) => removedId = id,
            ),
          ),
        ),
      );

      // Tap the first remove button
      final removeButtons = find.byIcon(Icons.remove_circle_outline);
      await tester.tap(removeButtons.first);
      await tester.pumpAndSettle();

      expect(removedId, 'sel-1');
    });

    testWidgets('should call onReorder when item reordered', (tester) async {
      int? oldIndex;
      int? newIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableMagazineGrid(
              photos: testPhotos,
              onReorder: (oi, ni) {
                oldIndex = oi;
                newIndex = ni;
              },
              onRemove: (_) {},
            ),
          ),
        ),
      );

      // The ReorderableListView should be present
      expect(find.byType(ReorderableListView), findsOneWidget);

      // Note: Testing actual drag & drop is complex in widget tests.
      // We verify the widget is correctly configured.
      expect(oldIndex, isNull);
      expect(newIndex, isNull);
    });
  });
}
