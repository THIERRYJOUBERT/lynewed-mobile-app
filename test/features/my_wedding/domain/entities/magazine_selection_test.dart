/// Tests for MagazineSelection entity.
///
/// Comprehensive tests covering creation, JSON serialization,
/// equality, and static constants.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_selection.dart';

void main() {
  group('MagazineSelection', () {
    final testDate = DateTime(2026, 2, 1, 12, 0, 0);

    group('creation', () {
      test('should create with all required fields', () {
        final selection = MagazineSelection(
          id: 'sel-1',
          weddingId: 'wed-1',
          userId: 'user-1',
          mediaType: 'album_image',
          mediaId: 'img-1',
          position: 1,
          createdAt: testDate,
        );

        expect(selection.id, 'sel-1');
        expect(selection.weddingId, 'wed-1');
        expect(selection.userId, 'user-1');
        expect(selection.mediaType, 'album_image');
        expect(selection.mediaId, 'img-1');
        expect(selection.position, 1);
        expect(selection.createdAt, testDate);
        expect(selection.thumbnailUrl, isNull);
      });

      test('should create with optional thumbnailUrl', () {
        final selection = MagazineSelection(
          id: 'sel-1',
          weddingId: 'wed-1',
          userId: 'user-1',
          mediaType: 'guest_media',
          mediaId: 'media-1',
          position: 5,
          createdAt: testDate,
          thumbnailUrl: 'https://example.com/thumb.jpg',
        );

        expect(selection.thumbnailUrl, 'https://example.com/thumb.jpg');
      });
    });

    group('static constants', () {
      test('maxPhotosCollector should be 60', () {
        expect(MagazineSelection.maxPhotosCollector, 60);
      });

      test('maxPhotosClassic should be 30', () {
        expect(MagazineSelection.maxPhotosClassic, 30);
      });
    });

    group('fromJson', () {
      test('should create from JSON with all fields', () {
        final json = {
          'id': 'sel-1',
          'wedding_id': 'wed-1',
          'user_id': 'user-1',
          'media_type': 'album_image',
          'media_id': 'img-1',
          'position': 3,
          'created_at': '2026-02-01T12:00:00.000',
          'thumbnail_url': 'https://example.com/thumb.jpg',
        };

        final selection = MagazineSelection.fromJson(json);

        expect(selection.id, 'sel-1');
        expect(selection.weddingId, 'wed-1');
        expect(selection.userId, 'user-1');
        expect(selection.mediaType, 'album_image');
        expect(selection.mediaId, 'img-1');
        expect(selection.position, 3);
        expect(selection.thumbnailUrl, 'https://example.com/thumb.jpg');
      });

      test('should create from JSON without optional thumbnail_url', () {
        final json = {
          'id': 'sel-2',
          'wedding_id': 'wed-1',
          'user_id': 'user-1',
          'media_type': 'guest_media',
          'media_id': 'media-2',
          'position': 1,
          'created_at': '2026-02-01T12:00:00.000',
        };

        final selection = MagazineSelection.fromJson(json);

        expect(selection.thumbnailUrl, isNull);
      });
    });

    group('toJson', () {
      test('should convert to JSON for insert', () {
        final selection = MagazineSelection(
          id: 'sel-1',
          weddingId: 'wed-1',
          userId: 'user-1',
          mediaType: 'album_image',
          mediaId: 'img-1',
          position: 2,
          createdAt: testDate,
        );

        final json = selection.toJson();

        expect(json['wedding_id'], 'wed-1');
        expect(json['user_id'], 'user-1');
        expect(json['media_type'], 'album_image');
        expect(json['media_id'], 'img-1');
        expect(json['position'], 2);
        // id and created_at are not included (auto-generated)
        expect(json.containsKey('id'), false);
        expect(json.containsKey('created_at'), false);
      });
    });

    group('copyWith', () {
      test('should create copy with updated position', () {
        final original = MagazineSelection(
          id: 'sel-1',
          weddingId: 'wed-1',
          userId: 'user-1',
          mediaType: 'album_image',
          mediaId: 'img-1',
          position: 1,
          createdAt: testDate,
        );

        final copy = original.copyWith(position: 5);

        expect(copy.id, original.id);
        expect(copy.weddingId, original.weddingId);
        expect(copy.position, 5);
      });

      test('should create copy with updated thumbnailUrl', () {
        final original = MagazineSelection(
          id: 'sel-1',
          weddingId: 'wed-1',
          userId: 'user-1',
          mediaType: 'album_image',
          mediaId: 'img-1',
          position: 1,
          createdAt: testDate,
        );

        final copy = original.copyWith(thumbnailUrl: 'https://new-url.com');

        expect(copy.thumbnailUrl, 'https://new-url.com');
        expect(copy.position, original.position);
      });

      test('should preserve original values when no changes', () {
        final original = MagazineSelection(
          id: 'sel-1',
          weddingId: 'wed-1',
          userId: 'user-1',
          mediaType: 'album_image',
          mediaId: 'img-1',
          position: 1,
          createdAt: testDate,
          thumbnailUrl: 'https://original.com',
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.weddingId, original.weddingId);
        expect(copy.userId, original.userId);
        expect(copy.mediaType, original.mediaType);
        expect(copy.mediaId, original.mediaId);
        expect(copy.position, original.position);
        expect(copy.createdAt, original.createdAt);
        expect(copy.thumbnailUrl, original.thumbnailUrl);
      });
    });

    group('equality', () {
      test('should be equal when id matches', () {
        final selection1 = MagazineSelection(
          id: 'sel-1',
          weddingId: 'wed-1',
          userId: 'user-1',
          mediaType: 'album_image',
          mediaId: 'img-1',
          position: 1,
          createdAt: testDate,
        );

        final selection2 = MagazineSelection(
          id: 'sel-1',
          weddingId: 'wed-2', // Different wedding
          userId: 'user-2', // Different user
          mediaType: 'guest_media', // Different type
          mediaId: 'img-2', // Different media
          position: 5, // Different position
          createdAt: DateTime(2026, 3, 1), // Different date
        );

        expect(selection1, equals(selection2));
        expect(selection1.hashCode, equals(selection2.hashCode));
      });

      test('should not be equal when id differs', () {
        final selection1 = MagazineSelection(
          id: 'sel-1',
          weddingId: 'wed-1',
          userId: 'user-1',
          mediaType: 'album_image',
          mediaId: 'img-1',
          position: 1,
          createdAt: testDate,
        );

        final selection2 = MagazineSelection(
          id: 'sel-2',
          weddingId: 'wed-1',
          userId: 'user-1',
          mediaType: 'album_image',
          mediaId: 'img-1',
          position: 1,
          createdAt: testDate,
        );

        expect(selection1, isNot(equals(selection2)));
      });
    });

    group('toString', () {
      test('should return formatted string with id and position', () {
        final selection = MagazineSelection(
          id: 'sel-123',
          weddingId: 'wed-1',
          userId: 'user-1',
          mediaType: 'album_image',
          mediaId: 'img-1',
          position: 42,
          createdAt: testDate,
        );

        expect(selection.toString(), 'MagazineSelection(sel-123, position: 42)');
      });
    });
  });
}
