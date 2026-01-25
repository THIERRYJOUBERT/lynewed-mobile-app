import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/inspiration_album.dart';

void main() {
  group('InspirationAlbum', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create InspirationAlbum with required fields', () {
        const album = InspirationAlbum(
          id: 'album-123',
          weddingId: 'wedding-456',
          brideProfileId: 'bride-789',
          name: 'Robes de mariee',
        );

        expect(album.id, 'album-123');
        expect(album.weddingId, 'wedding-456');
        expect(album.brideProfileId, 'bride-789');
        expect(album.name, 'Robes de mariee');
        expect(album.coverImageUrl, isNull);
        expect(album.category, AlbumCategory.general);
        expect(album.customCategory, isNull);
        expect(album.isPrivate, false);
        expect(album.sortOrder, 0);
        expect(album.imagesCount, 0);
        expect(album.createdAt, isNull);
      });

      test('should create InspirationAlbum with all optional fields', () {
        final createdAt = DateTime(2025, 1, 24, 10, 0, 0);
        final album = InspirationAlbum(
          id: 'album-123',
          weddingId: 'wedding-456',
          brideProfileId: 'bride-789',
          name: 'Robes de mariee',
          coverImageUrl: 'https://example.com/cover.jpg',
          category: AlbumCategory.dress,
          customCategory: null,
          isPrivate: true,
          sortOrder: 5,
          imagesCount: 10,
          createdAt: createdAt,
        );

        expect(album.coverImageUrl, 'https://example.com/cover.jpg');
        expect(album.category, AlbumCategory.dress);
        expect(album.isPrivate, true);
        expect(album.sortOrder, 5);
        expect(album.imagesCount, 10);
        expect(album.createdAt, createdAt);
      });

      test('should create InspirationAlbum with custom category', () {
        const album = InspirationAlbum(
          id: 'album-123',
          weddingId: 'wedding-456',
          brideProfileId: 'bride-789',
          name: 'Mon album special',
          category: AlbumCategory.custom,
          customCategory: 'Cadeaux invites',
        );

        expect(album.category, AlbumCategory.custom);
        expect(album.customCategory, 'Cadeaux invites');
      });
    });

    // ==============================================================
    // DISPLAYCATEGORY COMPUTED PROPERTY
    // ==============================================================

    group('displayCategory', () {
      test('should return customCategory when category is custom', () {
        const album = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Test',
          category: AlbumCategory.custom,
          customCategory: 'Cadeaux invites',
        );

        expect(album.displayCategory, 'Cadeaux invites');
      });

      test('should return capitalized category name when not custom', () {
        const album = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Test',
          category: AlbumCategory.dress,
        );

        expect(album.displayCategory, 'Dress');
      });

      test('should return capitalized general when category is general', () {
        const album = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Test',
          category: AlbumCategory.general,
        );

        expect(album.displayCategory, 'General');
      });

      test('should return capitalized venue when category is venue', () {
        const album = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Test',
          category: AlbumCategory.venue,
        );

        expect(album.displayCategory, 'Venue');
      });

      test('should capitalize first letter of flowers category', () {
        const album = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Test',
          category: AlbumCategory.flowers,
        );

        expect(album.displayCategory, 'Flowers');
      });

      test('should handle custom category with null customCategory field', () {
        const album = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Test',
          category: AlbumCategory.custom,
          customCategory: null,
        );

        // When custom but no customCategory set, falls back to capitalized "Custom"
        expect(album.displayCategory, 'Custom');
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse album with all fields', () {
        final json = {
          'id': 'album-123',
          'wedding_id': 'wedding-456',
          'bride_profile_id': 'bride-789',
          'name': 'Robes de mariee',
          'cover_image_url': 'https://example.com/cover.jpg',
          'category': 'dress',
          'custom_category': null,
          'is_private': true,
          'sort_order': 5,
          'images_count': 10,
          'created_at': '2025-01-24T10:00:00Z',
        };

        final album = InspirationAlbum.fromJson(json);

        expect(album.id, 'album-123');
        expect(album.weddingId, 'wedding-456');
        expect(album.brideProfileId, 'bride-789');
        expect(album.name, 'Robes de mariee');
        expect(album.coverImageUrl, 'https://example.com/cover.jpg');
        expect(album.category, AlbumCategory.dress);
        expect(album.customCategory, isNull);
        expect(album.isPrivate, true);
        expect(album.sortOrder, 5);
        expect(album.imagesCount, 10);
        expect(album.createdAt?.year, 2025);
      });

      test('should parse album with minimal fields', () {
        final json = {
          'id': 'album-123',
          'wedding_id': 'wedding-456',
          'bride_profile_id': 'bride-789',
          'name': 'Mon album',
        };

        final album = InspirationAlbum.fromJson(json);

        expect(album.id, 'album-123');
        expect(album.weddingId, 'wedding-456');
        expect(album.brideProfileId, 'bride-789');
        expect(album.name, 'Mon album');
        expect(album.coverImageUrl, isNull);
        expect(album.category, AlbumCategory.general);
        expect(album.customCategory, isNull);
        expect(album.isPrivate, false);
        expect(album.sortOrder, 0);
        expect(album.imagesCount, 0);
        expect(album.createdAt, isNull);
      });

      test('should parse category "dress" correctly', () {
        final json = {
          'id': 'album-1',
          'wedding_id': 'wedding-1',
          'bride_profile_id': 'bride-1',
          'name': 'Test',
          'category': 'dress',
        };

        expect(InspirationAlbum.fromJson(json).category, AlbumCategory.dress);
      });

      test('should parse category "decor" correctly', () {
        final json = {
          'id': 'album-1',
          'wedding_id': 'wedding-1',
          'bride_profile_id': 'bride-1',
          'name': 'Test',
          'category': 'decor',
        };

        expect(InspirationAlbum.fromJson(json).category, AlbumCategory.decor);
      });

      test('should parse category "flowers" correctly', () {
        final json = {
          'id': 'album-1',
          'wedding_id': 'wedding-1',
          'bride_profile_id': 'bride-1',
          'name': 'Test',
          'category': 'flowers',
        };

        expect(InspirationAlbum.fromJson(json).category, AlbumCategory.flowers);
      });

      test('should parse category "venue" correctly', () {
        final json = {
          'id': 'album-1',
          'wedding_id': 'wedding-1',
          'bride_profile_id': 'bride-1',
          'name': 'Test',
          'category': 'venue',
        };

        expect(InspirationAlbum.fromJson(json).category, AlbumCategory.venue);
      });

      test('should parse category "beauty" correctly', () {
        final json = {
          'id': 'album-1',
          'wedding_id': 'wedding-1',
          'bride_profile_id': 'bride-1',
          'name': 'Test',
          'category': 'beauty',
        };

        expect(InspirationAlbum.fromJson(json).category, AlbumCategory.beauty);
      });

      test('should parse category "photos" correctly', () {
        final json = {
          'id': 'album-1',
          'wedding_id': 'wedding-1',
          'bride_profile_id': 'bride-1',
          'name': 'Test',
          'category': 'photos',
        };

        expect(InspirationAlbum.fromJson(json).category, AlbumCategory.photos);
      });

      test('should parse category "stationery" correctly', () {
        final json = {
          'id': 'album-1',
          'wedding_id': 'wedding-1',
          'bride_profile_id': 'bride-1',
          'name': 'Test',
          'category': 'stationery',
        };

        expect(InspirationAlbum.fromJson(json).category, AlbumCategory.stationery);
      });

      test('should parse category "custom" correctly', () {
        final json = {
          'id': 'album-1',
          'wedding_id': 'wedding-1',
          'bride_profile_id': 'bride-1',
          'name': 'Test',
          'category': 'custom',
          'custom_category': 'Mon theme',
        };

        final album = InspirationAlbum.fromJson(json);
        expect(album.category, AlbumCategory.custom);
        expect(album.customCategory, 'Mon theme');
      });

      test('should default to general for invalid category', () {
        final json = {
          'id': 'album-1',
          'wedding_id': 'wedding-1',
          'bride_profile_id': 'bride-1',
          'name': 'Test',
          'category': 'invalid_category',
        };

        expect(InspirationAlbum.fromJson(json).category, AlbumCategory.general);
      });

      test('should default to general for null category', () {
        final json = {
          'id': 'album-1',
          'wedding_id': 'wedding-1',
          'bride_profile_id': 'bride-1',
          'name': 'Test',
          'category': null,
        };

        expect(InspirationAlbum.fromJson(json).category, AlbumCategory.general);
      });

      test('should default to false for null is_private', () {
        final json = {
          'id': 'album-1',
          'wedding_id': 'wedding-1',
          'bride_profile_id': 'bride-1',
          'name': 'Test',
          'is_private': null,
        };

        expect(InspirationAlbum.fromJson(json).isPrivate, false);
      });

      test('should default to 0 for null sort_order', () {
        final json = {
          'id': 'album-1',
          'wedding_id': 'wedding-1',
          'bride_profile_id': 'bride-1',
          'name': 'Test',
          'sort_order': null,
        };

        expect(InspirationAlbum.fromJson(json).sortOrder, 0);
      });

      test('should default to 0 for null images_count', () {
        final json = {
          'id': 'album-1',
          'wedding_id': 'wedding-1',
          'bride_profile_id': 'bride-1',
          'name': 'Test',
          'images_count': null,
        };

        expect(InspirationAlbum.fromJson(json).imagesCount, 0);
      });
    });

    // ==============================================================
    // TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should serialize all fields correctly', () {
        const album = InspirationAlbum(
          id: 'album-123',
          weddingId: 'wedding-456',
          brideProfileId: 'bride-789',
          name: 'Robes de mariee',
          coverImageUrl: 'https://example.com/cover.jpg',
          category: AlbumCategory.dress,
          customCategory: null,
          isPrivate: true,
          sortOrder: 5,
        );

        final json = album.toJson();

        expect(json['wedding_id'], 'wedding-456');
        expect(json['bride_profile_id'], 'bride-789');
        expect(json['name'], 'Robes de mariee');
        expect(json['cover_image_url'], 'https://example.com/cover.jpg');
        expect(json['category'], 'dress');
        expect(json['custom_category'], isNull);
        expect(json['is_private'], true);
        expect(json['sort_order'], 5);
        // id, images_count, created_at are not serialized
        expect(json.containsKey('id'), false);
        expect(json.containsKey('images_count'), false);
        expect(json.containsKey('created_at'), false);
      });

      test('should serialize null optional fields', () {
        const album = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Test',
        );

        final json = album.toJson();

        expect(json['cover_image_url'], isNull);
        expect(json['custom_category'], isNull);
      });

      test('should serialize general category correctly', () {
        const album = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Test',
          category: AlbumCategory.general,
        );

        expect(album.toJson()['category'], 'general');
      });

      test('should serialize custom category correctly', () {
        const album = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Test',
          category: AlbumCategory.custom,
          customCategory: 'Mon theme',
        );

        final json = album.toJson();
        expect(json['category'], 'custom');
        expect(json['custom_category'], 'Mon theme');
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final createdAt = DateTime(2025, 1, 24);
        final original = InspirationAlbum(
          id: 'album-123',
          weddingId: 'wedding-456',
          brideProfileId: 'bride-789',
          name: 'Original',
          coverImageUrl: 'https://example.com/original.jpg',
          category: AlbumCategory.dress,
          customCategory: null,
          isPrivate: true,
          sortOrder: 5,
          imagesCount: 10,
          createdAt: createdAt,
        );

        final copied = original.copyWith(name: 'New Name');

        expect(copied.id, 'album-123');
        expect(copied.weddingId, 'wedding-456');
        expect(copied.brideProfileId, 'bride-789');
        expect(copied.name, 'New Name');
        expect(copied.coverImageUrl, 'https://example.com/original.jpg');
        expect(copied.category, AlbumCategory.dress);
        expect(copied.isPrivate, true);
        expect(copied.sortOrder, 5);
        expect(copied.imagesCount, 10);
        expect(copied.createdAt, createdAt);
      });

      test('should update multiple fields at once', () {
        const original = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Test',
          isPrivate: false,
          sortOrder: 0,
        );

        final copied = original.copyWith(
          isPrivate: true,
          sortOrder: 10,
        );

        expect(copied.isPrivate, true);
        expect(copied.sortOrder, 10);
      });

      test('should not modify original', () {
        const original = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Original',
        );

        original.copyWith(name: 'Modified');

        expect(original.name, 'Original');
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is same', () {
        const album1 = InspirationAlbum(
          id: 'album-123',
          weddingId: 'wedding-456',
          brideProfileId: 'bride-789',
          name: 'Album 1',
        );
        const album2 = InspirationAlbum(
          id: 'album-123',
          weddingId: 'wedding-456',
          brideProfileId: 'bride-789',
          name: 'Album 2',
        );

        expect(album1, equals(album2));
        expect(album1.hashCode, equals(album2.hashCode));
      });

      test('should not be equal when id differs', () {
        const album1 = InspirationAlbum(
          id: 'album-123',
          weddingId: 'wedding-456',
          brideProfileId: 'bride-789',
          name: 'Album',
        );
        const album2 = InspirationAlbum(
          id: 'album-789',
          weddingId: 'wedding-456',
          brideProfileId: 'bride-789',
          name: 'Album',
        );

        expect(album1, isNot(equals(album2)));
      });

      test('should return identical for same instance', () {
        const album = InspirationAlbum(
          id: 'album-123',
          weddingId: 'wedding-456',
          brideProfileId: 'bride-789',
          name: 'Album',
        );

        expect(album == album, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        const album = InspirationAlbum(
          id: 'album-123',
          weddingId: 'wedding-456',
          brideProfileId: 'bride-789',
          name: 'Robes de mariee',
        );

        final result = album.toString();

        expect(result, contains('album-123'));
        expect(result, contains('Robes de mariee'));
      });
    });
  });

  // ==============================================================
  // ALBUMCATEGORY ENUM TESTS
  // ==============================================================

  group('AlbumCategory', () {
    test('should have all expected values', () {
      expect(AlbumCategory.values, contains(AlbumCategory.dress));
      expect(AlbumCategory.values, contains(AlbumCategory.decor));
      expect(AlbumCategory.values, contains(AlbumCategory.flowers));
      expect(AlbumCategory.values, contains(AlbumCategory.venue));
      expect(AlbumCategory.values, contains(AlbumCategory.beauty));
      expect(AlbumCategory.values, contains(AlbumCategory.photos));
      expect(AlbumCategory.values, contains(AlbumCategory.stationery));
      expect(AlbumCategory.values, contains(AlbumCategory.general));
      expect(AlbumCategory.values, contains(AlbumCategory.custom));
      expect(AlbumCategory.values.length, 9);
    });
  });
}
