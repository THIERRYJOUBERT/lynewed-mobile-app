/// Tests for GuestAlbumCard widget.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/guest_album.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/guest_album_card.dart';

void main() {
  group('GuestAlbumCard', () {
    final testDate = DateTime(2026, 6, 15);

    GuestAlbum createTestAlbum({
      String id = 'album-123',
      String guestName = 'Alice Smith',
      String? guestAvatarUrl,
      int photoCount = 5,
      int videoCount = 2,
      String? thumbnailUrl,
    }) {
      return GuestAlbum(
        id: id,
        weddingId: 'wedding-456',
        guestUserId: 'guest-789',
        guestName: guestName,
        guestAvatarUrl: guestAvatarUrl,
        photoCount: photoCount,
        videoCount: videoCount,
        thumbnailUrl: thumbnailUrl,
        createdAt: testDate,
      );
    }

    Widget buildWidget(GuestAlbum album, {VoidCallback? onTap}) {
      return MaterialApp(
        home: Scaffold(
          body: GuestAlbumCard(
            album: album,
            onTap: onTap ?? () {},
          ),
        ),
      );
    }

    testWidgets('should display guest name', (tester) async {
      final album = createTestAlbum(guestName: 'Alice Smith');
      await tester.pumpWidget(buildWidget(album));

      expect(find.text('Alice Smith'), findsOneWidget);
    });

    testWidgets('should display photo and video count', (tester) async {
      final album = createTestAlbum(photoCount: 5, videoCount: 2);
      await tester.pumpWidget(buildWidget(album));

      expect(find.text('5 photos, 2 videos'), findsOneWidget);
    });

    testWidgets('should display only photos when no videos', (tester) async {
      final album = createTestAlbum(photoCount: 10, videoCount: 0);
      await tester.pumpWidget(buildWidget(album));

      expect(find.text('10 photos'), findsOneWidget);
    });

    testWidgets('should display only videos when no photos', (tester) async {
      final album = createTestAlbum(photoCount: 0, videoCount: 3);
      await tester.pumpWidget(buildWidget(album));

      expect(find.text('3 videos'), findsOneWidget);
    });

    testWidgets('should display singular form for 1 photo', (tester) async {
      final album = createTestAlbum(photoCount: 1, videoCount: 0);
      await tester.pumpWidget(buildWidget(album));

      expect(find.text('1 photo'), findsOneWidget);
    });

    testWidgets('should display singular form for 1 video', (tester) async {
      final album = createTestAlbum(photoCount: 0, videoCount: 1);
      await tester.pumpWidget(buildWidget(album));

      expect(find.text('1 video'), findsOneWidget);
    });

    testWidgets('should display "No media yet" for empty album', (tester) async {
      final album = createTestAlbum(photoCount: 0, videoCount: 0);
      await tester.pumpWidget(buildWidget(album));

      expect(find.text('No media yet'), findsOneWidget);
    });

    testWidgets('should display avatar initial when no avatar URL', (tester) async {
      final album = createTestAlbum(guestName: 'Alice', guestAvatarUrl: null);
      await tester.pumpWidget(buildWidget(album));

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('should display chevron icon', (tester) async {
      final album = createTestAlbum();
      await tester.pumpWidget(buildWidget(album));

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      bool wasTapped = false;
      final album = createTestAlbum();
      await tester.pumpWidget(buildWidget(album, onTap: () => wasTapped = true));

      await tester.tap(find.byType(GuestAlbumCard));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('should display CircleAvatar for guest avatar', (tester) async {
      final album = createTestAlbum();
      await tester.pumpWidget(buildWidget(album));

      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });
}
