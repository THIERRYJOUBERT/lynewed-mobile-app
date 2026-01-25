/// Video URL Helpers Tests
///
/// Tests for the video URL utility class.
/// Covers: platform detection, YouTube/Vimeo ID extraction, URL validation.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/utils/video_url_helpers.dart';

void main() {
  group('VideoUrlHelpers', () {
    group('detectPlatform', () {
      test('returns unknown for null URL', () {
        expect(VideoUrlHelpers.detectPlatform(null), VideoPlatform.unknown);
      });

      test('returns unknown for empty URL', () {
        expect(VideoUrlHelpers.detectPlatform(''), VideoPlatform.unknown);
      });

      test('detects YouTube from youtube.com', () {
        expect(
          VideoUrlHelpers.detectPlatform('https://www.youtube.com/watch?v=abc123'),
          VideoPlatform.youtube,
        );
      });

      test('detects YouTube from youtu.be', () {
        expect(
          VideoUrlHelpers.detectPlatform('https://youtu.be/abc123'),
          VideoPlatform.youtube,
        );
      });

      test('detects YouTube case-insensitively', () {
        expect(
          VideoUrlHelpers.detectPlatform('https://YOUTUBE.COM/watch?v=abc123'),
          VideoPlatform.youtube,
        );
      });

      test('detects Vimeo from vimeo.com', () {
        expect(
          VideoUrlHelpers.detectPlatform('https://vimeo.com/123456'),
          VideoPlatform.vimeo,
        );
      });

      test('detects Vimeo case-insensitively', () {
        expect(
          VideoUrlHelpers.detectPlatform('https://VIMEO.COM/123456'),
          VideoPlatform.vimeo,
        );
      });

      test('detects direct video files by extension', () {
        expect(VideoUrlHelpers.detectPlatform('https://example.com/video.mp4'), VideoPlatform.directFile);
        expect(VideoUrlHelpers.detectPlatform('https://example.com/video.m4v'), VideoPlatform.directFile);
        expect(VideoUrlHelpers.detectPlatform('https://example.com/video.mov'), VideoPlatform.directFile);
        expect(VideoUrlHelpers.detectPlatform('https://example.com/video.webm'), VideoPlatform.directFile);
        expect(VideoUrlHelpers.detectPlatform('https://example.com/video.avi'), VideoPlatform.directFile);
      });

      test('detects direct video files case-insensitively', () {
        expect(VideoUrlHelpers.detectPlatform('https://example.com/video.MP4'), VideoPlatform.directFile);
      });

      test('returns unknown for unsupported URLs', () {
        expect(VideoUrlHelpers.detectPlatform('https://example.com'), VideoPlatform.unknown);
        expect(VideoUrlHelpers.detectPlatform('https://dailymotion.com/video/123'), VideoPlatform.unknown);
      });
    });

    group('extractYouTubeId', () {
      test('returns null for null URL', () {
        expect(VideoUrlHelpers.extractYouTubeId(null), isNull);
      });

      test('returns null for empty URL', () {
        expect(VideoUrlHelpers.extractYouTubeId(''), isNull);
      });

      test('extracts ID from standard youtube.com/watch?v= URL', () {
        expect(
          VideoUrlHelpers.extractYouTubeId('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
          'dQw4w9WgXcQ',
        );
      });

      test('extracts ID from youtu.be short URL', () {
        expect(
          VideoUrlHelpers.extractYouTubeId('https://youtu.be/dQw4w9WgXcQ'),
          'dQw4w9WgXcQ',
        );
      });

      test('extracts ID from embed URL', () {
        expect(
          VideoUrlHelpers.extractYouTubeId('https://www.youtube.com/embed/dQw4w9WgXcQ'),
          'dQw4w9WgXcQ',
        );
      });

      test('extracts ID from /v/ URL', () {
        expect(
          VideoUrlHelpers.extractYouTubeId('https://www.youtube.com/v/dQw4w9WgXcQ'),
          'dQw4w9WgXcQ',
        );
      });

      test('extracts ID with additional query parameters', () {
        expect(
          VideoUrlHelpers.extractYouTubeId('https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=120'),
          'dQw4w9WgXcQ',
        );
      });

      test('returns null for invalid YouTube URL', () {
        expect(VideoUrlHelpers.extractYouTubeId('https://example.com/video'), isNull);
        expect(VideoUrlHelpers.extractYouTubeId('https://vimeo.com/123456'), isNull);
      });

      test('returns null for malformed YouTube URL', () {
        expect(VideoUrlHelpers.extractYouTubeId('https://youtube.com/watch'), isNull);
        expect(VideoUrlHelpers.extractYouTubeId('https://youtube.com/watch?v='), isNull);
      });
    });

    group('extractVimeoId', () {
      test('returns null for null URL', () {
        expect(VideoUrlHelpers.extractVimeoId(null), isNull);
      });

      test('returns null for empty URL', () {
        expect(VideoUrlHelpers.extractVimeoId(''), isNull);
      });

      test('extracts ID from standard vimeo.com URL', () {
        expect(
          VideoUrlHelpers.extractVimeoId('https://vimeo.com/123456789'),
          '123456789',
        );
      });

      test('extracts ID from player.vimeo.com URL', () {
        expect(
          VideoUrlHelpers.extractVimeoId('https://player.vimeo.com/video/123456789'),
          '123456789',
        );
      });

      test('returns null for invalid Vimeo URL', () {
        expect(VideoUrlHelpers.extractVimeoId('https://example.com/video'), isNull);
        expect(VideoUrlHelpers.extractVimeoId('https://youtube.com/watch?v=abc'), isNull);
      });

      test('returns null for vimeo URL without numeric ID', () {
        expect(VideoUrlHelpers.extractVimeoId('https://vimeo.com/'), isNull);
      });
    });

    group('isYouTubeUrl', () {
      test('returns true for valid YouTube URLs', () {
        expect(VideoUrlHelpers.isYouTubeUrl('https://www.youtube.com/watch?v=abc123'), isTrue);
        expect(VideoUrlHelpers.isYouTubeUrl('https://youtu.be/abc123'), isTrue);
      });

      test('returns false for non-YouTube URLs', () {
        expect(VideoUrlHelpers.isYouTubeUrl('https://vimeo.com/123456'), isFalse);
        expect(VideoUrlHelpers.isYouTubeUrl('https://example.com'), isFalse);
        expect(VideoUrlHelpers.isYouTubeUrl(null), isFalse);
      });
    });

    group('isVimeoUrl', () {
      test('returns true for valid Vimeo URLs', () {
        expect(VideoUrlHelpers.isVimeoUrl('https://vimeo.com/123456'), isTrue);
        expect(VideoUrlHelpers.isVimeoUrl('https://player.vimeo.com/video/123456'), isTrue);
      });

      test('returns false for non-Vimeo URLs', () {
        expect(VideoUrlHelpers.isVimeoUrl('https://youtube.com/watch?v=abc'), isFalse);
        expect(VideoUrlHelpers.isVimeoUrl('https://example.com'), isFalse);
        expect(VideoUrlHelpers.isVimeoUrl(null), isFalse);
      });
    });

    group('isDirectVideoUrl', () {
      test('returns true for direct video file URLs', () {
        expect(VideoUrlHelpers.isDirectVideoUrl('https://example.com/video.mp4'), isTrue);
        expect(VideoUrlHelpers.isDirectVideoUrl('https://cdn.example.com/file.webm'), isTrue);
      });

      test('returns false for non-direct video URLs', () {
        expect(VideoUrlHelpers.isDirectVideoUrl('https://youtube.com/watch?v=abc'), isFalse);
        expect(VideoUrlHelpers.isDirectVideoUrl('https://example.com/page.html'), isFalse);
        expect(VideoUrlHelpers.isDirectVideoUrl(null), isFalse);
      });
    });

    group('isValidVideoUrl', () {
      test('returns true for any supported video platform', () {
        expect(VideoUrlHelpers.isValidVideoUrl('https://youtube.com/watch?v=abc'), isTrue);
        expect(VideoUrlHelpers.isValidVideoUrl('https://vimeo.com/123456'), isTrue);
        expect(VideoUrlHelpers.isValidVideoUrl('https://example.com/video.mp4'), isTrue);
      });

      test('returns false for unsupported URLs', () {
        expect(VideoUrlHelpers.isValidVideoUrl('https://example.com'), isFalse);
        expect(VideoUrlHelpers.isValidVideoUrl('not-a-url'), isFalse);
        expect(VideoUrlHelpers.isValidVideoUrl(null), isFalse);
      });
    });

    group('isStreamableVideoUrl', () {
      test('returns true for YouTube and Vimeo', () {
        expect(VideoUrlHelpers.isStreamableVideoUrl('https://youtube.com/watch?v=abc'), isTrue);
        expect(VideoUrlHelpers.isStreamableVideoUrl('https://vimeo.com/123456'), isTrue);
      });

      test('returns false for direct video files', () {
        expect(VideoUrlHelpers.isStreamableVideoUrl('https://example.com/video.mp4'), isFalse);
      });

      test('returns false for unsupported URLs', () {
        expect(VideoUrlHelpers.isStreamableVideoUrl('https://example.com'), isFalse);
        expect(VideoUrlHelpers.isStreamableVideoUrl(null), isFalse);
      });
    });

    group('getYouTubeThumbnail', () {
      test('returns null for null video ID', () {
        expect(VideoUrlHelpers.getYouTubeThumbnail(null), isNull);
      });

      test('returns null for empty video ID', () {
        expect(VideoUrlHelpers.getYouTubeThumbnail(''), isNull);
      });

      test('returns correct thumbnail URL with default quality', () {
        expect(
          VideoUrlHelpers.getYouTubeThumbnail('dQw4w9WgXcQ'),
          'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
        );
      });

      test('returns correct thumbnail URL with specified quality', () {
        expect(
          VideoUrlHelpers.getYouTubeThumbnail('dQw4w9WgXcQ', quality: 'maxresdefault'),
          'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
        );
      });
    });

    group('getYouTubeEmbedUrl', () {
      test('returns null for null video ID', () {
        expect(VideoUrlHelpers.getYouTubeEmbedUrl(null), isNull);
      });

      test('returns null for empty video ID', () {
        expect(VideoUrlHelpers.getYouTubeEmbedUrl(''), isNull);
      });

      test('returns correct embed URL', () {
        expect(
          VideoUrlHelpers.getYouTubeEmbedUrl('dQw4w9WgXcQ'),
          'https://www.youtube.com/embed/dQw4w9WgXcQ',
        );
      });
    });

    group('getVimeoThumbnailPlaceholder', () {
      test('returns null (requires API call)', () {
        expect(VideoUrlHelpers.getVimeoThumbnailPlaceholder('123456'), isNull);
        expect(VideoUrlHelpers.getVimeoThumbnailPlaceholder(null), isNull);
      });
    });

    group('Edge Cases', () {
      test('handles URLs with special characters', () {
        expect(
          VideoUrlHelpers.extractYouTubeId('https://www.youtube.com/watch?v=abc-123_XYZ'),
          'abc-123_XYZ',
        );
      });

      test('handles URLs without https scheme', () {
        expect(
          VideoUrlHelpers.detectPlatform('http://youtube.com/watch?v=abc'),
          VideoPlatform.youtube,
        );
      });

      test('handles URLs with www and without', () {
        expect(VideoUrlHelpers.isYouTubeUrl('https://youtube.com/watch?v=abc'), isTrue);
        expect(VideoUrlHelpers.isYouTubeUrl('https://www.youtube.com/watch?v=abc'), isTrue);
      });
    });
  });
}
