/// Tests for GuestAlbumModel.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/data/models/guest_album_model.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/guest_album.dart';

void main() {
  group('GuestAlbumModel', () {
    final testDate = DateTime(2026, 6, 15, 10, 30);

    test('should extend GuestAlbum', () {
      final model = GuestAlbumModel(
        id: 'album-123',
        weddingId: 'wedding-456',
        guestUserId: 'guest-789',
        guestName: 'Alice Smith',
        photoCount: 5,
        videoCount: 2,
        createdAt: testDate,
      );

      expect(model, isA<GuestAlbum>());
    });

    group('fromJson', () {
      test('should create model from JSON with all fields', () {
        final json = {
          'id': 'album-123',
          'wedding_id': 'wedding-456',
          'guest_user_id': 'guest-789',
          'created_at': '2026-06-15T10:30:00.000Z',
          'profiles': {
            'first_name': 'Alice',
            'last_name': 'Smith',
            'avatar_url': 'https://example.com/avatar.jpg',
          },
          'photo_count': 5,
          'video_count': 2,
          'thumbnail_url': 'https://example.com/thumb.jpg',
        };

        final model = GuestAlbumModel.fromJson(json);

        expect(model.id, 'album-123');
        expect(model.weddingId, 'wedding-456');
        expect(model.guestUserId, 'guest-789');
        expect(model.guestName, 'Alice Smith');
        expect(model.guestAvatarUrl, 'https://example.com/avatar.jpg');
        expect(model.photoCount, 5);
        expect(model.videoCount, 2);
        expect(model.thumbnailUrl, 'https://example.com/thumb.jpg');
      });

      test('should handle null profile gracefully', () {
        final json = {
          'id': 'album-123',
          'wedding_id': 'wedding-456',
          'guest_user_id': 'guest-789',
          'created_at': '2026-06-15T10:30:00.000Z',
          'profiles': null,
          'photo_count': 3,
          'video_count': 1,
        };

        final model = GuestAlbumModel.fromJson(json);

        expect(model.guestName, 'Guest');
        expect(model.guestAvatarUrl, isNull);
      });

      test('should build guest name from first name only', () {
        final json = {
          'id': 'album-123',
          'wedding_id': 'wedding-456',
          'guest_user_id': 'guest-789',
          'created_at': '2026-06-15T10:30:00.000Z',
          'profiles': {
            'first_name': 'Alice',
            'last_name': null,
          },
          'photo_count': 0,
          'video_count': 0,
        };

        final model = GuestAlbumModel.fromJson(json);

        expect(model.guestName, 'Alice');
      });

      test('should build guest name from last name only', () {
        final json = {
          'id': 'album-123',
          'wedding_id': 'wedding-456',
          'guest_user_id': 'guest-789',
          'created_at': '2026-06-15T10:30:00.000Z',
          'profiles': {
            'first_name': null,
            'last_name': 'Smith',
          },
          'photo_count': 0,
          'video_count': 0,
        };

        final model = GuestAlbumModel.fromJson(json);

        expect(model.guestName, 'Smith');
      });

      test('should fallback to Guest when names are empty', () {
        final json = {
          'id': 'album-123',
          'wedding_id': 'wedding-456',
          'guest_user_id': 'guest-789',
          'created_at': '2026-06-15T10:30:00.000Z',
          'profiles': {
            'first_name': '',
            'last_name': '',
          },
          'photo_count': 0,
          'video_count': 0,
        };

        final model = GuestAlbumModel.fromJson(json);

        expect(model.guestName, 'Guest');
      });

      test('should handle missing counts with defaults', () {
        final json = {
          'id': 'album-123',
          'wedding_id': 'wedding-456',
          'guest_user_id': 'guest-789',
          'created_at': '2026-06-15T10:30:00.000Z',
          'profiles': null,
        };

        final model = GuestAlbumModel.fromJson(json);

        expect(model.photoCount, 0);
        expect(model.videoCount, 0);
      });
    });

    group('computed properties', () {
      test('totalMediaCount should work on model', () {
        final model = GuestAlbumModel(
          id: 'album-123',
          weddingId: 'wedding-456',
          guestUserId: 'guest-789',
          guestName: 'Alice',
          photoCount: 5,
          videoCount: 3,
          createdAt: testDate,
        );

        expect(model.totalMediaCount, 8);
      });

      test('isEmpty should work on model', () {
        final emptyModel = GuestAlbumModel(
          id: 'album-123',
          weddingId: 'wedding-456',
          guestUserId: 'guest-789',
          guestName: 'Alice',
          photoCount: 0,
          videoCount: 0,
          createdAt: testDate,
        );

        final nonEmptyModel = GuestAlbumModel(
          id: 'album-123',
          weddingId: 'wedding-456',
          guestUserId: 'guest-789',
          guestName: 'Alice',
          photoCount: 1,
          videoCount: 0,
          createdAt: testDate,
        );

        expect(emptyModel.isEmpty, isTrue);
        expect(nonEmptyModel.isEmpty, isFalse);
      });
    });
  });
}
