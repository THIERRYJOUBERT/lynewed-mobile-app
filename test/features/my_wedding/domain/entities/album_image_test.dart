import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/album_image.dart';

void main() {
  group('AlbumImage', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create AlbumImage with required fields', () {
        const image = AlbumImage(
          id: 'image-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(image.id, 'image-123');
        expect(image.albumId, 'album-456');
        expect(image.imageUrl, 'https://example.com/image.jpg');
        expect(image.thumbnailUrl, isNull);
        expect(image.uploadedAt, isNull);
        expect(image.mediaType, 'photo'); // Default value
        expect(image.caption, isNull);
        expect(image.durationSeconds, isNull);
        expect(image.fileSizeBytes, isNull);
      });

      test('should create AlbumImage with all optional fields', () {
        final uploadedAt = DateTime(2025, 1, 24, 10, 0, 0);
        final image = AlbumImage(
          id: 'image-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          uploadedAt: uploadedAt,
          mediaType: 'video',
          caption: 'Wedding venue tour',
          durationSeconds: 120,
          fileSizeBytes: 52428800,
        );

        expect(image.thumbnailUrl, 'https://example.com/thumb.jpg');
        expect(image.uploadedAt, uploadedAt);
        expect(image.mediaType, 'video');
        expect(image.caption, 'Wedding venue tour');
        expect(image.durationSeconds, 120);
        expect(image.fileSizeBytes, 52428800);
      });

      test('should have isVideo getter return true for video mediaType', () {
        const image = AlbumImage(
          id: 'image-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/video.mp4',
          mediaType: 'video',
        );

        expect(image.isVideo, true);
        expect(image.isPhoto, false);
      });

      test('should have isPhoto getter return true for photo mediaType', () {
        const image = AlbumImage(
          id: 'image-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
          mediaType: 'photo',
        );

        expect(image.isVideo, false);
        expect(image.isPhoto, true);
      });

      test('should default to photo mediaType', () {
        const image = AlbumImage(
          id: 'image-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(image.mediaType, 'photo');
        expect(image.isPhoto, true);
        expect(image.isVideo, false);
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse image with all fields', () {
        final json = {
          'id': 'image-123',
          'album_id': 'album-456',
          'image_url': 'https://example.com/image.jpg',
          'thumbnail_url': 'https://example.com/thumb.jpg',
          'uploaded_at': '2025-01-24T10:00:00Z',
          'media_type': 'photo',
          'caption': 'Beautiful venue',
          'duration_seconds': null,
          'file_size_bytes': 1048576,
        };

        final image = AlbumImage.fromJson(json);

        expect(image.id, 'image-123');
        expect(image.albumId, 'album-456');
        expect(image.imageUrl, 'https://example.com/image.jpg');
        expect(image.thumbnailUrl, 'https://example.com/thumb.jpg');
        expect(image.uploadedAt?.year, 2025);
        expect(image.uploadedAt?.month, 1);
        expect(image.uploadedAt?.day, 24);
        expect(image.mediaType, 'photo');
        expect(image.caption, 'Beautiful venue');
        expect(image.durationSeconds, isNull);
        expect(image.fileSizeBytes, 1048576);
      });

      test('should parse video with all fields', () {
        final json = {
          'id': 'video-123',
          'album_id': 'album-456',
          'image_url': 'https://example.com/video.mp4',
          'thumbnail_url': 'https://example.com/thumb.jpg',
          'uploaded_at': '2025-01-24T10:00:00Z',
          'media_type': 'video',
          'caption': 'Venue tour',
          'duration_seconds': 120,
          'file_size_bytes': 52428800,
        };

        final image = AlbumImage.fromJson(json);

        expect(image.id, 'video-123');
        expect(image.mediaType, 'video');
        expect(image.isVideo, true);
        expect(image.caption, 'Venue tour');
        expect(image.durationSeconds, 120);
        expect(image.fileSizeBytes, 52428800);
      });

      test('should parse image with minimal fields', () {
        final json = {
          'id': 'image-123',
          'album_id': 'album-456',
          'image_url': 'https://example.com/image.jpg',
        };

        final image = AlbumImage.fromJson(json);

        expect(image.id, 'image-123');
        expect(image.albumId, 'album-456');
        expect(image.imageUrl, 'https://example.com/image.jpg');
        expect(image.thumbnailUrl, isNull);
        expect(image.uploadedAt, isNull);
        expect(image.mediaType, 'photo'); // Default
        expect(image.caption, isNull);
        expect(image.durationSeconds, isNull);
        expect(image.fileSizeBytes, isNull);
      });

      test('should handle null thumbnail_url', () {
        final json = {
          'id': 'image-123',
          'album_id': 'album-456',
          'image_url': 'https://example.com/image.jpg',
          'thumbnail_url': null,
        };

        final image = AlbumImage.fromJson(json);

        expect(image.thumbnailUrl, isNull);
      });

      test('should handle null uploaded_at', () {
        final json = {
          'id': 'image-123',
          'album_id': 'album-456',
          'image_url': 'https://example.com/image.jpg',
          'uploaded_at': null,
        };

        final image = AlbumImage.fromJson(json);

        expect(image.uploadedAt, isNull);
      });

      test('should default media_type to photo when null', () {
        final json = {
          'id': 'image-123',
          'album_id': 'album-456',
          'image_url': 'https://example.com/image.jpg',
          'media_type': null,
        };

        final image = AlbumImage.fromJson(json);

        expect(image.mediaType, 'photo');
      });
    });

    // ==============================================================
    // TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should serialize all fields correctly', () {
        const image = AlbumImage(
          id: 'image-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          mediaType: 'video',
          caption: 'Tour video',
          durationSeconds: 180,
          fileSizeBytes: 104857600,
        );

        final json = image.toJson();

        expect(json['album_id'], 'album-456');
        expect(json['image_url'], 'https://example.com/image.jpg');
        expect(json['thumbnail_url'], 'https://example.com/thumb.jpg');
        expect(json['media_type'], 'video');
        expect(json['caption'], 'Tour video');
        expect(json['duration_seconds'], 180);
        expect(json['file_size_bytes'], 104857600);
        // id and uploaded_at are not serialized (auto-generated by DB)
        expect(json.containsKey('id'), false);
        expect(json.containsKey('uploaded_at'), false);
      });

      test('should serialize null optional fields', () {
        const image = AlbumImage(
          id: 'image-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
        );

        final json = image.toJson();

        expect(json['thumbnail_url'], isNull);
        expect(json['media_type'], 'photo');
        expect(json['caption'], isNull);
        expect(json['duration_seconds'], isNull);
        expect(json['file_size_bytes'], isNull);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is same', () {
        const image1 = AlbumImage(
          id: 'image-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image1.jpg',
        );
        const image2 = AlbumImage(
          id: 'image-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image2.jpg',
        );

        expect(image1, equals(image2));
        expect(image1.hashCode, equals(image2.hashCode));
      });

      test('should not be equal when id differs', () {
        const image1 = AlbumImage(
          id: 'image-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
        );
        const image2 = AlbumImage(
          id: 'image-789',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(image1, isNot(equals(image2)));
      });

      test('should return identical for same instance', () {
        const image = AlbumImage(
          id: 'image-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(image == image, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        const image = AlbumImage(
          id: 'image-123',
          albumId: 'album-456',
          imageUrl: 'https://example.com/image.jpg',
        );

        final result = image.toString();

        expect(result, contains('image-123'));
      });
    });
  });
}
