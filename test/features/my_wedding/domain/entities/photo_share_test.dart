/// Tests for PhotoShare entity
///
/// Tests creation, JSON parsing, equality, and helper methods.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/photo_share.dart';

void main() {
  group('PhotoShare', () {
    group('construction', () {
      test('should create PhotoShare with all required fields', () {
        // Arrange
        final sharedAt = DateTime(2026, 2, 3, 10, 30);

        // Act
        final share = PhotoShare(
          id: 'share-123',
          weddingId: 'wedding-456',
          mediaType: MediaShareType.albumImage,
          mediaId: 'media-789',
          sharedBy: 'user-abc',
          sharedAt: sharedAt,
        );

        // Assert
        expect(share.id, 'share-123');
        expect(share.weddingId, 'wedding-456');
        expect(share.mediaType, MediaShareType.albumImage);
        expect(share.mediaId, 'media-789');
        expect(share.sharedBy, 'user-abc');
        expect(share.sharedAt, sharedAt);
      });

      test('should support both media types', () {
        // Act & Assert
        final albumShare = PhotoShare(
          id: '1',
          weddingId: 'w1',
          mediaType: MediaShareType.albumImage,
          mediaId: 'm1',
          sharedBy: 'u1',
          sharedAt: DateTime.now(),
        );
        expect(albumShare.isAlbumImage, true);
        expect(albumShare.isGuestMedia, false);

        final guestShare = PhotoShare(
          id: '2',
          weddingId: 'w2',
          mediaType: MediaShareType.guestMedia,
          mediaId: 'm2',
          sharedBy: 'u2',
          sharedAt: DateTime.now(),
        );
        expect(guestShare.isAlbumImage, false);
        expect(guestShare.isGuestMedia, true);
      });
    });

    group('fromJson', () {
      test('should create PhotoShare from valid JSON with album_image type', () {
        // Arrange
        final json = {
          'id': 'share-123',
          'wedding_id': 'wedding-456',
          'media_type': 'album_image',
          'media_id': 'media-789',
          'shared_by': 'user-abc',
          'shared_at': '2026-02-03T10:30:00.000Z',
        };

        // Act
        final share = PhotoShare.fromJson(json);

        // Assert
        expect(share.id, 'share-123');
        expect(share.weddingId, 'wedding-456');
        expect(share.mediaType, MediaShareType.albumImage);
        expect(share.mediaId, 'media-789');
        expect(share.sharedBy, 'user-abc');
        expect(share.sharedAt.year, 2026);
      });

      test('should create PhotoShare from valid JSON with guest_media type', () {
        // Arrange
        final json = {
          'id': 'share-456',
          'wedding_id': 'wedding-789',
          'media_type': 'guest_media',
          'media_id': 'media-abc',
          'shared_by': 'user-def',
          'shared_at': '2026-02-03T15:00:00.000Z',
        };

        // Act
        final share = PhotoShare.fromJson(json);

        // Assert
        expect(share.mediaType, MediaShareType.guestMedia);
      });

      test('should default to albumImage for unknown media_type', () {
        // Arrange
        final json = {
          'id': 'share-123',
          'wedding_id': 'wedding-456',
          'media_type': 'unknown_type',
          'media_id': 'media-789',
          'shared_by': 'user-abc',
          'shared_at': '2026-02-03T10:30:00.000Z',
        };

        // Act
        final share = PhotoShare.fromJson(json);

        // Assert
        expect(share.mediaType, MediaShareType.albumImage);
      });
    });

    group('toJson', () {
      test('should convert PhotoShare to JSON for album_image', () {
        // Arrange
        final share = PhotoShare(
          id: 'share-123',
          weddingId: 'wedding-456',
          mediaType: MediaShareType.albumImage,
          mediaId: 'media-789',
          sharedBy: 'user-abc',
          sharedAt: DateTime.utc(2026, 2, 3, 10, 30),
        );

        // Act
        final json = share.toJson();

        // Assert
        expect(json['wedding_id'], 'wedding-456');
        expect(json['media_type'], 'album_image');
        expect(json['media_id'], 'media-789');
        expect(json['shared_by'], 'user-abc');
        // Note: toJson doesn't include id (server generates it)
        expect(json.containsKey('id'), false);
      });

      test('should convert PhotoShare to JSON for guest_media', () {
        // Arrange
        final share = PhotoShare(
          id: 'share-123',
          weddingId: 'wedding-456',
          mediaType: MediaShareType.guestMedia,
          mediaId: 'media-789',
          sharedBy: 'user-abc',
          sharedAt: DateTime.now(),
        );

        // Act
        final json = share.toJson();

        // Assert
        expect(json['media_type'], 'guest_media');
      });
    });

    group('equality', () {
      test('should be equal when ids match', () {
        // Arrange
        final share1 = PhotoShare(
          id: 'same-id',
          weddingId: 'wedding-1',
          mediaType: MediaShareType.albumImage,
          mediaId: 'media-1',
          sharedBy: 'user-1',
          sharedAt: DateTime(2026, 1, 1),
        );
        final share2 = PhotoShare(
          id: 'same-id',
          weddingId: 'wedding-2',
          mediaType: MediaShareType.guestMedia,
          mediaId: 'media-2',
          sharedBy: 'user-2',
          sharedAt: DateTime(2026, 12, 31),
        );

        // Assert
        expect(share1, equals(share2));
        expect(share1.hashCode, equals(share2.hashCode));
      });

      test('should not be equal when ids differ', () {
        // Arrange
        final share1 = PhotoShare(
          id: 'id-1',
          weddingId: 'wedding-1',
          mediaType: MediaShareType.albumImage,
          mediaId: 'media-1',
          sharedBy: 'user-1',
          sharedAt: DateTime.now(),
        );
        final share2 = PhotoShare(
          id: 'id-2',
          weddingId: 'wedding-1',
          mediaType: MediaShareType.albumImage,
          mediaId: 'media-1',
          sharedBy: 'user-1',
          sharedAt: DateTime.now(),
        );

        // Assert
        expect(share1, isNot(equals(share2)));
      });
    });

    group('toString', () {
      test('should return readable string representation', () {
        // Arrange
        final share = PhotoShare(
          id: 'share-123',
          weddingId: 'wedding-456',
          mediaType: MediaShareType.albumImage,
          mediaId: 'media-789',
          sharedBy: 'user-abc',
          sharedAt: DateTime.now(),
        );

        // Act
        final str = share.toString();

        // Assert
        expect(str, contains('PhotoShare'));
        expect(str, contains('share-123'));
        expect(str, contains('album_image'));
      });
    });
  });

  group('MediaShareType', () {
    test('should have correct string values', () {
      expect(MediaShareType.albumImage.value, 'album_image');
      expect(MediaShareType.guestMedia.value, 'guest_media');
    });

    test('fromString should return correct enum values', () {
      expect(MediaShareType.fromString('album_image'), MediaShareType.albumImage);
      expect(MediaShareType.fromString('guest_media'), MediaShareType.guestMedia);
      expect(MediaShareType.fromString('unknown'), MediaShareType.albumImage);
      expect(MediaShareType.fromString(null), MediaShareType.albumImage);
    });
  });
}
