import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_photo.dart';

void main() {
  group('MarketplacePhoto', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create MarketplacePhoto with required fields', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        expect(photo.id, 'photo-123');
        expect(photo.listingId, 'listing-456');
        expect(photo.storagePath, 'listing-456/photo_0.jpg');
        expect(photo.position, 0);
        expect(photo.createdAt, now);
        expect(photo.thumbnailPath, isNull);
      });

      test('should create MarketplacePhoto with thumbnail', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          thumbnailPath: 'listing-456/thumb_0.jpg',
          position: 0,
          createdAt: now,
        );

        expect(photo.thumbnailPath, 'listing-456/thumb_0.jpg');
      });

      test('should be immutable', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        // Verify fields are final (compile-time check)
        // Cannot reassign: photo.position = 1; // Would not compile
        expect(photo.position, 0);
      });
    });

    // ==============================================================
    // POSITION / isCover TESTS
    // ==============================================================

    group('position', () {
      test('position 0 should be cover photo', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        expect(photo.isCover, isTrue);
      });

      test('position > 0 should not be cover photo', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_1.jpg',
          position: 1,
          createdAt: now,
        );

        expect(photo.isCover, isFalse);
      });

      test('should support multiple positions', () {
        final now = DateTime.now();
        final photos = List.generate(
          5,
          (index) => MarketplacePhoto(
            id: 'photo-$index',
            listingId: 'listing-456',
            storagePath: 'listing-456/photo_$index.jpg',
            position: index,
            createdAt: now,
          ),
        );

        expect(photos[0].position, 0);
        expect(photos[1].position, 1);
        expect(photos[4].position, 4);

        expect(photos[0].isCover, isTrue);
        expect(photos[1].isCover, isFalse);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is the same', () {
        final now = DateTime.now();
        final photo1 = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        final photo2 = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-999',
          storagePath: 'different/path.jpg',
          position: 5,
          createdAt: now.add(const Duration(days: 1)),
        );

        expect(photo1, equals(photo2));
        expect(photo1.hashCode, equals(photo2.hashCode));
      });

      test('should not be equal when id differs', () {
        final now = DateTime.now();
        final photo1 = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        final photo2 = MarketplacePhoto(
          id: 'photo-999',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        expect(photo1, isNot(equals(photo2)));
        expect(photo1.hashCode, isNot(equals(photo2.hashCode)));
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should create copy with updated position', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        final updated = photo.copyWith(position: 2);

        expect(updated.position, 2);
        expect(updated.id, photo.id);
        expect(updated.listingId, photo.listingId);
        expect(updated.storagePath, photo.storagePath);
      });

      test('should create copy with updated storage path', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        final updated = photo.copyWith(storagePath: 'listing-456/photo_1.jpg');

        expect(updated.storagePath, 'listing-456/photo_1.jpg');
        expect(updated.id, photo.id);
      });

      test('should preserve all fields when no parameter provided', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          thumbnailPath: 'listing-456/thumb_0.jpg',
          position: 0,
          createdAt: now,
        );

        final copied = photo.copyWith();

        expect(copied.id, photo.id);
        expect(copied.listingId, photo.listingId);
        expect(copied.storagePath, photo.storagePath);
        expect(copied.thumbnailPath, photo.thumbnailPath);
        expect(copied.position, photo.position);
        expect(copied.createdAt, photo.createdAt);
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should provide readable string representation', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        final str = photo.toString();

        expect(str, contains('photo-123'));
        expect(str, contains('listing-456'));
        expect(str, contains('0'));
        expect(str, contains('listing-456/photo_0.jpg'));
      });
    });

    // ==============================================================
    // fromJson TESTS
    // ==============================================================

    group('fromJson', () {
      test('should create MarketplacePhoto from valid JSON', () {
        final json = {
          'id': 'abc-123',
          'listing_id': 'listing-456',
          'storage_path': 'listing-456/photo_0.jpg',
          'thumbnail_path': 'listing-456/thumb_0.jpg',
          'position': 0,
          'created_at': '2026-02-04T10:00:00.000Z',
        };

        final photo = MarketplacePhoto.fromJson(json);

        expect(photo.id, 'abc-123');
        expect(photo.listingId, 'listing-456');
        expect(photo.storagePath, 'listing-456/photo_0.jpg');
        expect(photo.thumbnailPath, 'listing-456/thumb_0.jpg');
        expect(photo.position, 0);
        expect(photo.createdAt, DateTime.parse('2026-02-04T10:00:00.000Z'));
      });

      test('should handle null thumbnail in JSON', () {
        final json = {
          'id': 'abc-123',
          'listing_id': 'listing-456',
          'storage_path': 'listing-456/photo_0.jpg',
          'thumbnail_path': null,
          'position': 2,
          'created_at': '2026-02-04T10:00:00.000Z',
        };

        final photo = MarketplacePhoto.fromJson(json);

        expect(photo.thumbnailPath, isNull);
        expect(photo.position, 2);
      });

      test('should handle missing thumbnail key in JSON', () {
        final json = {
          'id': 'abc-123',
          'listing_id': 'listing-456',
          'storage_path': 'listing-456/photo_0.jpg',
          'position': 1,
          'created_at': '2026-02-04T10:00:00.000Z',
        };

        final photo = MarketplacePhoto.fromJson(json);

        expect(photo.thumbnailPath, isNull);
      });
    });

    // ==============================================================
    // toJson TESTS
    // ==============================================================

    group('toJson', () {
      test('should convert to JSON with correct keys', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          thumbnailPath: 'listing-456/thumb_0.jpg',
          position: 0,
          createdAt: now,
        );

        final json = photo.toJson();

        expect(json['listing_id'], 'listing-456');
        expect(json['storage_path'], 'listing-456/photo_0.jpg');
        expect(json['thumbnail_path'], 'listing-456/thumb_0.jpg');
        expect(json['position'], 0);
      });

      test('should exclude auto-generated fields (id, created_at)', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        final json = photo.toJson();

        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('created_at'), isFalse);
      });

      test('should include null thumbnail in JSON', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        final json = photo.toJson();

        expect(json.containsKey('thumbnail_path'), isTrue);
        expect(json['thumbnail_path'], isNull);
      });
    });
  });
}
