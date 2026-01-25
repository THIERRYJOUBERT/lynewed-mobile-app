/// Tests for Replay entity.
///
/// Comprehensive tests covering:
/// - Entity creation with required and optional fields
/// - JSON serialization/deserialization
/// - copyWith functionality
/// - Equality and hashCode
/// - Computed properties
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/content/domain/entities/replay.dart';
import 'package:lynewed_beta/features/content/domain/entities/wed_article.dart';

void main() {
  group('Replay', () {
    final testDate = DateTime(2025, 6, 15, 10, 30);
    const testDuration = Duration(minutes: 45, seconds: 30);

    group('creation', () {
      test('should create with all required fields', () {
        final replay = Replay(
          id: 'replay-1',
          title: 'Wedding Ceremony Replay',
          videoUrl: 'https://vimeo.com/123456',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );

        expect(replay.id, 'replay-1');
        expect(replay.title, 'Wedding Ceremony Replay');
        expect(replay.videoUrl, 'https://vimeo.com/123456');
        expect(replay.videoType, VideoType.vimeo);
        expect(replay.createdAt, testDate);
        expect(replay.description, isNull);
        expect(replay.thumbnailUrl, isNull);
        expect(replay.duration, isNull);
      });

      test('should create with optional description', () {
        final replay = Replay(
          id: 'replay-1',
          title: 'Wedding Ceremony Replay',
          description: 'A beautiful ceremony in Paris',
          videoUrl: 'https://vimeo.com/123456',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );

        expect(replay.description, 'A beautiful ceremony in Paris');
      });

      test('should create with optional thumbnail', () {
        final replay = Replay(
          id: 'replay-1',
          title: 'Wedding Ceremony Replay',
          thumbnailUrl: 'https://example.com/thumbnail.jpg',
          videoUrl: 'https://vimeo.com/123456',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );

        expect(replay.thumbnailUrl, 'https://example.com/thumbnail.jpg');
      });

      test('should create with optional duration', () {
        final replay = Replay(
          id: 'replay-1',
          title: 'Wedding Ceremony Replay',
          videoUrl: 'https://vimeo.com/123456',
          videoType: VideoType.vimeo,
          duration: testDuration,
          createdAt: testDate,
        );

        expect(replay.duration, testDuration);
      });

      test('should create with all fields', () {
        final replay = Replay(
          id: 'replay-1',
          title: 'Wedding Ceremony Replay',
          description: 'A beautiful ceremony in Paris',
          thumbnailUrl: 'https://example.com/thumbnail.jpg',
          videoUrl: 'https://vimeo.com/123456',
          videoType: VideoType.vimeo,
          duration: testDuration,
          createdAt: testDate,
        );

        expect(replay.id, 'replay-1');
        expect(replay.title, 'Wedding Ceremony Replay');
        expect(replay.description, 'A beautiful ceremony in Paris');
        expect(replay.thumbnailUrl, 'https://example.com/thumbnail.jpg');
        expect(replay.videoUrl, 'https://vimeo.com/123456');
        expect(replay.videoType, VideoType.vimeo);
        expect(replay.duration, testDuration);
        expect(replay.createdAt, testDate);
      });

      test('should create with youtube video type', () {
        final replay = Replay(
          id: 'replay-1',
          title: 'YouTube Replay',
          videoUrl: 'https://youtube.com/watch?v=abc123',
          videoType: VideoType.youtube,
          createdAt: testDate,
        );

        expect(replay.videoType, VideoType.youtube);
      });

      test('should create with direct video type', () {
        final replay = Replay(
          id: 'replay-1',
          title: 'Direct Replay',
          videoUrl: 'https://example.com/video.mp4',
          videoType: VideoType.direct,
          createdAt: testDate,
        );

        expect(replay.videoType, VideoType.direct);
      });
    });

    group('computed properties', () {
      test('hasThumbnail should return true when thumbnailUrl is not null', () {
        final replayWithThumbnail = Replay(
          id: 'replay-1',
          title: 'Test',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );
        final replayWithoutThumbnail = Replay(
          id: 'replay-2',
          title: 'Test',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );

        expect(replayWithThumbnail.hasThumbnail, isTrue);
        expect(replayWithoutThumbnail.hasThumbnail, isFalse);
      });

      test('hasDescription should return true when description is not null', () {
        final replayWithDesc = Replay(
          id: 'replay-1',
          title: 'Test',
          description: 'Some description',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );
        final replayWithoutDesc = Replay(
          id: 'replay-2',
          title: 'Test',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );

        expect(replayWithDesc.hasDescription, isTrue);
        expect(replayWithoutDesc.hasDescription, isFalse);
      });

      test('hasDuration should return true when duration is not null', () {
        final replayWithDuration = Replay(
          id: 'replay-1',
          title: 'Test',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          duration: testDuration,
          createdAt: testDate,
        );
        final replayWithoutDuration = Replay(
          id: 'replay-2',
          title: 'Test',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );

        expect(replayWithDuration.hasDuration, isTrue);
        expect(replayWithoutDuration.hasDuration, isFalse);
      });

      test('isYouTube should return true for youtube videos', () {
        final youtubeReplay = Replay(
          id: 'replay-1',
          title: 'Test',
          videoUrl: 'https://youtube.com/watch?v=abc',
          videoType: VideoType.youtube,
          createdAt: testDate,
        );

        expect(youtubeReplay.isYouTube, isTrue);
        expect(youtubeReplay.isVimeo, isFalse);
        expect(youtubeReplay.isDirect, isFalse);
      });

      test('isVimeo should return true for vimeo videos', () {
        final vimeoReplay = Replay(
          id: 'replay-1',
          title: 'Test',
          videoUrl: 'https://vimeo.com/123456',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );

        expect(vimeoReplay.isVimeo, isTrue);
        expect(vimeoReplay.isYouTube, isFalse);
        expect(vimeoReplay.isDirect, isFalse);
      });

      test('isDirect should return true for direct videos', () {
        final directReplay = Replay(
          id: 'replay-1',
          title: 'Test',
          videoUrl: 'https://example.com/video.mp4',
          videoType: VideoType.direct,
          createdAt: testDate,
        );

        expect(directReplay.isDirect, isTrue);
        expect(directReplay.isYouTube, isFalse);
        expect(directReplay.isVimeo, isFalse);
      });

      test('formattedDuration should return formatted string for duration', () {
        final replay = Replay(
          id: 'replay-1',
          title: 'Test',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          duration: const Duration(hours: 1, minutes: 23, seconds: 45),
          createdAt: testDate,
        );

        expect(replay.formattedDuration, '1:23:45');
      });

      test('formattedDuration should handle minutes and seconds only', () {
        final replay = Replay(
          id: 'replay-1',
          title: 'Test',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          duration: const Duration(minutes: 5, seconds: 30),
          createdAt: testDate,
        );

        expect(replay.formattedDuration, '5:30');
      });

      test('formattedDuration should pad seconds with zero', () {
        final replay = Replay(
          id: 'replay-1',
          title: 'Test',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          duration: const Duration(minutes: 5, seconds: 5),
          createdAt: testDate,
        );

        expect(replay.formattedDuration, '5:05');
      });

      test('formattedDuration should return null when no duration', () {
        final replay = Replay(
          id: 'replay-1',
          title: 'Test',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );

        expect(replay.formattedDuration, isNull);
      });
    });

    group('fromJson', () {
      test('should parse valid JSON with all fields', () {
        final json = {
          'id': 'replay-1',
          'title': 'Wedding Ceremony Replay',
          'description': 'A beautiful ceremony',
          'thumbnail_url': 'https://example.com/thumbnail.jpg',
          'video_url': 'https://vimeo.com/123456',
          'video_type': 'vimeo',
          'duration_seconds': 2730, // 45:30
          'created_at': '2025-06-15T10:30:00.000',
        };

        final replay = Replay.fromJson(json);

        expect(replay.id, 'replay-1');
        expect(replay.title, 'Wedding Ceremony Replay');
        expect(replay.description, 'A beautiful ceremony');
        expect(replay.thumbnailUrl, 'https://example.com/thumbnail.jpg');
        expect(replay.videoUrl, 'https://vimeo.com/123456');
        expect(replay.videoType, VideoType.vimeo);
        expect(replay.duration, const Duration(seconds: 2730));
        expect(replay.createdAt, DateTime(2025, 6, 15, 10, 30));
      });

      test('should parse JSON without optional fields', () {
        final json = {
          'id': 'replay-1',
          'title': 'Replay',
          'video_url': 'https://vimeo.com/123',
          'video_type': 'vimeo',
          'created_at': '2025-06-15T10:30:00.000',
        };

        final replay = Replay.fromJson(json);

        expect(replay.id, 'replay-1');
        expect(replay.description, isNull);
        expect(replay.thumbnailUrl, isNull);
        expect(replay.duration, isNull);
      });

      test('should parse all video type values correctly', () {
        final videoTypes = ['youtube', 'vimeo', 'direct'];
        final expected = [
          VideoType.youtube,
          VideoType.vimeo,
          VideoType.direct,
        ];

        for (var i = 0; i < videoTypes.length; i++) {
          final json = {
            'id': 'replay-1',
            'title': 'Test',
            'video_url': 'https://example.com/video',
            'video_type': videoTypes[i],
            'created_at': '2025-06-15T10:30:00.000',
          };

          final replay = Replay.fromJson(json);
          expect(replay.videoType, expected[i]);
        }
      });

      test('should default to direct for unknown video type', () {
        final json = {
          'id': 'replay-1',
          'title': 'Test',
          'video_url': 'https://example.com/video',
          'video_type': 'unknown_type',
          'created_at': '2025-06-15T10:30:00.000',
        };

        final replay = Replay.fromJson(json);
        expect(replay.videoType, VideoType.direct);
      });

      test('should handle null duration_seconds gracefully', () {
        final json = {
          'id': 'replay-1',
          'title': 'Test',
          'video_url': 'https://vimeo.com/123',
          'video_type': 'vimeo',
          'duration_seconds': null,
          'created_at': '2025-06-15T10:30:00.000',
        };

        final replay = Replay.fromJson(json);
        expect(replay.duration, isNull);
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        final replay = Replay(
          id: 'replay-1',
          title: 'Wedding Ceremony Replay',
          description: 'A beautiful ceremony',
          thumbnailUrl: 'https://example.com/thumbnail.jpg',
          videoUrl: 'https://vimeo.com/123456',
          videoType: VideoType.vimeo,
          duration: testDuration,
          createdAt: testDate,
        );

        final json = replay.toJson();

        expect(json['title'], 'Wedding Ceremony Replay');
        expect(json['description'], 'A beautiful ceremony');
        expect(json['thumbnail_url'], 'https://example.com/thumbnail.jpg');
        expect(json['video_url'], 'https://vimeo.com/123456');
        expect(json['video_type'], 'vimeo');
        expect(json['duration_seconds'], testDuration.inSeconds);
      });

      test('should not include null optional fields', () {
        final replay = Replay(
          id: 'replay-1',
          title: 'Test',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );

        final json = replay.toJson();

        expect(json.containsKey('description'), isFalse);
        expect(json.containsKey('thumbnail_url'), isFalse);
        expect(json.containsKey('duration_seconds'), isFalse);
      });
    });

    group('copyWith', () {
      test('should copy with new title', () {
        final original = Replay(
          id: 'replay-1',
          title: 'Original Title',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );

        final copied = original.copyWith(title: 'New Title');

        expect(copied.title, 'New Title');
        expect(copied.id, 'replay-1');
        expect(copied.videoUrl, 'https://vimeo.com/123');
      });

      test('should copy with new description', () {
        final original = Replay(
          id: 'replay-1',
          title: 'Test',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );

        final copied = original.copyWith(description: 'New Description');

        expect(copied.description, 'New Description');
      });

      test('should copy with new duration', () {
        final original = Replay(
          id: 'replay-1',
          title: 'Test',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );

        final newDuration = const Duration(hours: 2);
        final copied = original.copyWith(duration: newDuration);

        expect(copied.duration, newDuration);
      });

      test('should preserve unchanged values', () {
        final original = Replay(
          id: 'replay-1',
          title: 'Original',
          description: 'Original Description',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          duration: testDuration,
          createdAt: testDate,
        );

        final copied = original.copyWith(title: 'New Title');

        expect(copied.id, 'replay-1');
        expect(copied.description, 'Original Description');
        expect(copied.thumbnailUrl, 'https://example.com/thumb.jpg');
        expect(copied.videoUrl, 'https://vimeo.com/123');
        expect(copied.videoType, VideoType.vimeo);
        expect(copied.duration, testDuration);
        expect(copied.createdAt, testDate);
      });
    });

    group('equality', () {
      test('should be equal with same id', () {
        final replay1 = Replay(
          id: 'replay-1',
          title: 'Title 1',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );
        final replay2 = Replay(
          id: 'replay-1',
          title: 'Different Title',
          videoUrl: 'https://youtube.com/abc',
          videoType: VideoType.youtube,
          createdAt: DateTime(2020, 1, 1),
        );

        expect(replay1, equals(replay2));
        expect(replay1.hashCode, equals(replay2.hashCode));
      });

      test('should not be equal with different id', () {
        final replay1 = Replay(
          id: 'replay-1',
          title: 'Same Title',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );
        final replay2 = Replay(
          id: 'replay-2',
          title: 'Same Title',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );

        expect(replay1, isNot(equals(replay2)));
      });
    });

    group('toString', () {
      test('should return readable string representation', () {
        final replay = Replay(
          id: 'replay-1',
          title: 'Wedding Ceremony Replay',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          createdAt: testDate,
        );

        final str = replay.toString();

        expect(str, contains('replay-1'));
        expect(str, contains('Wedding Ceremony Replay'));
        expect(str, contains('vimeo'));
      });
    });
  });
}
