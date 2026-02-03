/// Tests for GuestAlbumsPage.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/guest_album.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/pages/guest_albums_page.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/guest_album_card.dart';

void main() {
  group('GuestAlbumsPage', () {
    final testDate = DateTime(2026, 6, 15);

    GuestAlbum createTestAlbum({
      String id = 'album-1',
      String guestName = 'Alice',
      int photoCount = 5,
      int videoCount = 2,
    }) {
      return GuestAlbum(
        id: id,
        weddingId: 'wedding-456',
        guestUserId: 'guest-$id',
        guestName: guestName,
        photoCount: photoCount,
        videoCount: videoCount,
        createdAt: testDate,
      );
    }

    Widget buildPage({List<GuestAlbum>? albums, String? error}) {
      return MaterialApp(
        home: GuestAlbumsPage(
          weddingId: 'wedding-456',
          testAlbums: albums,
          testError: error,
        ),
      );
    }

    testWidgets('should display header with title', (tester) async {
      await tester.pumpWidget(buildPage(albums: []));
      await tester.pumpAndSettle();

      expect(find.text('Guest Albums'), findsOneWidget);
    });

    testWidgets('should display back button', (tester) async {
      await tester.pumpWidget(buildPage(albums: []));
      await tester.pumpAndSettle();

      // Back button should be present (uses chevron_left per design system)
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('should display empty state when no albums', (tester) async {
      await tester.pumpWidget(buildPage(albums: []));
      await tester.pumpAndSettle();

      expect(find.text('No guest albums yet'), findsOneWidget);
      expect(
        find.text('Photos and videos from your guests will appear here'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.photo_album_outlined), findsOneWidget);
    });

    testWidgets('should display list of albums', (tester) async {
      final albums = [
        createTestAlbum(id: 'album-1', guestName: 'Alice', photoCount: 5, videoCount: 2),
        createTestAlbum(id: 'album-2', guestName: 'Bob', photoCount: 3, videoCount: 0),
      ];
      await tester.pumpWidget(buildPage(albums: albums));
      await tester.pumpAndSettle();

      expect(find.byType(GuestAlbumCard), findsNWidgets(2));
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('should display error state with retry button', (tester) async {
      await tester.pumpWidget(buildPage(error: 'Failed to load albums'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to load albums'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display media counts for each album', (tester) async {
      final albums = [
        createTestAlbum(id: 'album-1', guestName: 'Alice', photoCount: 5, videoCount: 2),
      ];
      await tester.pumpWidget(buildPage(albums: albums));
      await tester.pumpAndSettle();

      expect(find.text('5 photos, 2 videos'), findsOneWidget);
    });
  });
}
