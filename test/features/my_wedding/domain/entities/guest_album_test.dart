/// Tests for GuestAlbum entity.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/guest_album.dart';

void main() {
  group('GuestAlbum', () {
    final testDate = DateTime(2026, 6, 15, 10, 30);

    GuestAlbum createTestAlbum({
      String id = 'album-123',
      String weddingId = 'wedding-456',
      String guestUserId = 'guest-789',
      String guestName = 'Alice Smith',
      String? guestAvatarUrl = 'https://example.com/avatar.jpg',
      int photoCount = 5,
      int videoCount = 2,
      String? thumbnailUrl = 'https://example.com/thumb.jpg',
      DateTime? createdAt,
    }) {
      return GuestAlbum(
        id: id,
        weddingId: weddingId,
        guestUserId: guestUserId,
        guestName: guestName,
        guestAvatarUrl: guestAvatarUrl,
        photoCount: photoCount,
        videoCount: videoCount,
        thumbnailUrl: thumbnailUrl,
        createdAt: createdAt ?? testDate,
      );
    }

    test('should create GuestAlbum with all required fields', () {
      final album = createTestAlbum();

      expect(album.id, 'album-123');
      expect(album.weddingId, 'wedding-456');
      expect(album.guestUserId, 'guest-789');
      expect(album.guestName, 'Alice Smith');
      expect(album.guestAvatarUrl, 'https://example.com/avatar.jpg');
      expect(album.photoCount, 5);
      expect(album.videoCount, 2);
      expect(album.thumbnailUrl, 'https://example.com/thumb.jpg');
      expect(album.createdAt, testDate);
    });

    test('should create GuestAlbum with null optional fields', () {
      final album = createTestAlbum(
        guestAvatarUrl: null,
        thumbnailUrl: null,
      );

      expect(album.guestAvatarUrl, isNull);
      expect(album.thumbnailUrl, isNull);
    });

    group('totalMediaCount', () {
      test('should return sum of photos and videos', () {
        final album = createTestAlbum(photoCount: 5, videoCount: 2);
        expect(album.totalMediaCount, 7);
      });

      test('should return 0 when no media', () {
        final album = createTestAlbum(photoCount: 0, videoCount: 0);
        expect(album.totalMediaCount, 0);
      });

      test('should handle only photos', () {
        final album = createTestAlbum(photoCount: 10, videoCount: 0);
        expect(album.totalMediaCount, 10);
      });

      test('should handle only videos', () {
        final album = createTestAlbum(photoCount: 0, videoCount: 5);
        expect(album.totalMediaCount, 5);
      });
    });

    group('isEmpty', () {
      test('should return true when no media', () {
        final album = createTestAlbum(photoCount: 0, videoCount: 0);
        expect(album.isEmpty, isTrue);
      });

      test('should return false when has photos', () {
        final album = createTestAlbum(photoCount: 1, videoCount: 0);
        expect(album.isEmpty, isFalse);
      });

      test('should return false when has videos', () {
        final album = createTestAlbum(photoCount: 0, videoCount: 1);
        expect(album.isEmpty, isFalse);
      });

      test('should return false when has both', () {
        final album = createTestAlbum(photoCount: 3, videoCount: 2);
        expect(album.isEmpty, isFalse);
      });
    });

    group('Equatable', () {
      test('should be equal when all props match', () {
        final album1 = createTestAlbum();
        final album2 = createTestAlbum();
        expect(album1, equals(album2));
      });

      test('should not be equal when id differs', () {
        final album1 = createTestAlbum(id: 'album-1');
        final album2 = createTestAlbum(id: 'album-2');
        expect(album1, isNot(equals(album2)));
      });

      test('should not be equal when weddingId differs', () {
        final album1 = createTestAlbum(weddingId: 'wedding-1');
        final album2 = createTestAlbum(weddingId: 'wedding-2');
        expect(album1, isNot(equals(album2)));
      });

      test('should not be equal when photoCount differs', () {
        final album1 = createTestAlbum(photoCount: 5);
        final album2 = createTestAlbum(photoCount: 10);
        expect(album1, isNot(equals(album2)));
      });
    });
  });
}
