import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/saved_post.dart';

void main() {
  group('SavedPost', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create SavedPost with required fields', () {
        const post = SavedPost(
          id: 'saved-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(post.id, 'saved-123');
        expect(post.albumId, 'album-456');
        expect(post.imageUrl, 'https://example.com/image.jpg');
        expect(post.sourceProfileId, isNull);
        expect(post.sourceProfileName, isNull);
        expect(post.savedAt, isNull);
      });

      test('should create SavedPost with all optional fields', () {
        final savedAt = DateTime(2025, 1, 24, 10, 0, 0);
        final post = SavedPost(
          id: 'saved-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
          sourceProfileId: 'pro-789',
          sourceProfileName: 'Photographe Pro',
          savedAt: savedAt,
        );

        expect(post.sourceProfileId, 'pro-789');
        expect(post.sourceProfileName, 'Photographe Pro');
        expect(post.savedAt, savedAt);
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse saved post with all fields', () {
        final json = {
          'id': 'saved-123',
          'album_id': 'album-456',
          'image_url': 'https://example.com/image.jpg',
          'source_profile_id': 'pro-789',
          'profiles': {
            'full_name': 'Jean Dupont',
            'business_name': 'Studio Pro',
          },
          'saved_at': '2025-01-24T10:00:00Z',
        };

        final post = SavedPost.fromJson(json);

        expect(post.id, 'saved-123');
        expect(post.albumId, 'album-456');
        expect(post.imageUrl, 'https://example.com/image.jpg');
        expect(post.sourceProfileId, 'pro-789');
        expect(post.sourceProfileName, 'Jean Dupont'); // full_name takes precedence
        expect(post.savedAt?.year, 2025);
      });

      test('should parse saved post with minimal fields', () {
        final json = {
          'id': 'saved-123',
          'album_id': 'album-456',
          'image_url': 'https://example.com/image.jpg',
        };

        final post = SavedPost.fromJson(json);

        expect(post.id, 'saved-123');
        expect(post.albumId, 'album-456');
        expect(post.imageUrl, 'https://example.com/image.jpg');
        expect(post.sourceProfileId, isNull);
        expect(post.sourceProfileName, isNull);
        expect(post.savedAt, isNull);
      });

      test('should use full_name from profiles when available', () {
        final json = {
          'id': 'saved-123',
          'album_id': 'album-456',
          'image_url': 'https://example.com/image.jpg',
          'profiles': {
            'full_name': 'Jean Dupont',
            'business_name': 'Studio Pro',
          },
        };

        final post = SavedPost.fromJson(json);

        expect(post.sourceProfileName, 'Jean Dupont');
      });

      test('should use business_name when full_name is null', () {
        final json = {
          'id': 'saved-123',
          'album_id': 'album-456',
          'image_url': 'https://example.com/image.jpg',
          'profiles': {
            'full_name': null,
            'business_name': 'Studio Pro',
          },
        };

        final post = SavedPost.fromJson(json);

        expect(post.sourceProfileName, 'Studio Pro');
      });

      test('should handle null profiles', () {
        final json = {
          'id': 'saved-123',
          'album_id': 'album-456',
          'image_url': 'https://example.com/image.jpg',
          'profiles': null,
        };

        final post = SavedPost.fromJson(json);

        expect(post.sourceProfileName, isNull);
      });

      test('should handle missing profiles key', () {
        final json = {
          'id': 'saved-123',
          'album_id': 'album-456',
          'image_url': 'https://example.com/image.jpg',
        };

        final post = SavedPost.fromJson(json);

        expect(post.sourceProfileName, isNull);
      });

      test('should handle profiles with both names null', () {
        final json = {
          'id': 'saved-123',
          'album_id': 'album-456',
          'image_url': 'https://example.com/image.jpg',
          'profiles': {
            'full_name': null,
            'business_name': null,
          },
        };

        final post = SavedPost.fromJson(json);

        expect(post.sourceProfileName, isNull);
      });

      test('should handle null saved_at', () {
        final json = {
          'id': 'saved-123',
          'album_id': 'album-456',
          'image_url': 'https://example.com/image.jpg',
          'saved_at': null,
        };

        final post = SavedPost.fromJson(json);

        expect(post.savedAt, isNull);
      });
    });

    // ==============================================================
    // TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should serialize required fields', () {
        const post = SavedPost(
          id: 'saved-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
        );

        final json = post.toJson();

        expect(json['album_id'], 'album-456');
        expect(json['image_url'], 'https://example.com/image.jpg');
        // id, source_profile_name, saved_at are not serialized
        expect(json.containsKey('id'), false);
        expect(json.containsKey('source_profile_name'), false);
        expect(json.containsKey('saved_at'), false);
      });

      test('should include source_profile_id when present', () {
        const post = SavedPost(
          id: 'saved-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
          sourceProfileId: 'pro-789',
        );

        final json = post.toJson();

        expect(json['source_profile_id'], 'pro-789');
      });

      test('should not include source_profile_id when null', () {
        const post = SavedPost(
          id: 'saved-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
          sourceProfileId: null,
        );

        final json = post.toJson();

        expect(json.containsKey('source_profile_id'), false);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is same', () {
        const post1 = SavedPost(
          id: 'saved-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image1.jpg',
        );
        const post2 = SavedPost(
          id: 'saved-123',
          albumId: 'album-789',
          imageUrl: 'https://example.com/image2.jpg',
        );

        expect(post1, equals(post2));
        expect(post1.hashCode, equals(post2.hashCode));
      });

      test('should not be equal when id differs', () {
        const post1 = SavedPost(
          id: 'saved-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
        );
        const post2 = SavedPost(
          id: 'saved-789',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(post1, isNot(equals(post2)));
      });

      test('should return identical for same instance', () {
        const post = SavedPost(
          id: 'saved-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(post == post, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        const post = SavedPost(
          id: 'saved-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
        );

        final result = post.toString();

        expect(result, contains('saved-123'));
        expect(result, contains('https://example.com/image.jpg'));
      });
    });
  });
}
