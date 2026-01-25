/// Tests for WedArticle entity.
///
/// Comprehensive tests covering:
/// - Entity creation with required and optional fields
/// - JSON serialization/deserialization
/// - copyWith functionality
/// - Equality and hashCode
/// - Computed properties
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/content/domain/entities/wed_article.dart';
import 'package:lynewed_beta/features/content/domain/entities/wed_content_block.dart';

void main() {
  group('ArticleStatus', () {
    test('should have all expected values', () {
      expect(ArticleStatus.values, contains(ArticleStatus.draft));
      expect(ArticleStatus.values, contains(ArticleStatus.published));
      expect(ArticleStatus.values, contains(ArticleStatus.archived));
    });

    test('should have 3 values', () {
      expect(ArticleStatus.values.length, 3);
    });
  });

  group('VideoType', () {
    test('should have all expected values', () {
      expect(VideoType.values, contains(VideoType.youtube));
      expect(VideoType.values, contains(VideoType.vimeo));
      expect(VideoType.values, contains(VideoType.direct));
    });

    test('should have 3 values', () {
      expect(VideoType.values.length, 3);
    });
  });

  group('WedArticle', () {
    final testDate = DateTime(2025, 6, 15, 10, 30);
    const testBlocks = [
      WedContentBlock(
        type: ContentBlockType.text,
        content: 'Introduction paragraph',
      ),
      WedContentBlock(
        type: ContentBlockType.image,
        imageUrl: 'https://example.com/image.jpg',
      ),
    ];

    group('creation', () {
      test('should create with all required fields', () {
        final article = WedArticle(
          id: 'article-1',
          title: 'Wedding of the Week',
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: testBlocks,
        );

        expect(article.id, 'article-1');
        expect(article.title, 'Wedding of the Week');
        expect(article.publishedAt, testDate);
        expect(article.status, ArticleStatus.published);
        expect(article.contentBlocks, testBlocks);
        expect(article.subtitle, isNull);
        expect(article.coverImageUrl, isNull);
        expect(article.videoUrl, isNull);
        expect(article.videoType, isNull);
      });

      test('should create with optional subtitle', () {
        final article = WedArticle(
          id: 'article-1',
          title: 'Wedding of the Week',
          subtitle: 'A beautiful summer ceremony',
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: testBlocks,
        );

        expect(article.subtitle, 'A beautiful summer ceremony');
      });

      test('should create with optional cover image', () {
        final article = WedArticle(
          id: 'article-1',
          title: 'Wedding of the Week',
          coverImageUrl: 'https://example.com/cover.jpg',
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: testBlocks,
        );

        expect(article.coverImageUrl, 'https://example.com/cover.jpg');
      });

      test('should create with optional video', () {
        final article = WedArticle(
          id: 'article-1',
          title: 'Wedding of the Week',
          videoUrl: 'https://vimeo.com/123456',
          videoType: VideoType.vimeo,
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: testBlocks,
        );

        expect(article.videoUrl, 'https://vimeo.com/123456');
        expect(article.videoType, VideoType.vimeo);
      });

      test('should create with empty content blocks', () {
        final article = WedArticle(
          id: 'article-1',
          title: 'Wedding of the Week',
          publishedAt: testDate,
          status: ArticleStatus.draft,
          contentBlocks: const [],
        );

        expect(article.contentBlocks, isEmpty);
      });

      test('should create with all fields', () {
        final article = WedArticle(
          id: 'article-1',
          title: 'Wedding of the Week',
          subtitle: 'A beautiful summer ceremony',
          coverImageUrl: 'https://example.com/cover.jpg',
          videoUrl: 'https://vimeo.com/123456',
          videoType: VideoType.vimeo,
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: testBlocks,
        );

        expect(article.id, 'article-1');
        expect(article.title, 'Wedding of the Week');
        expect(article.subtitle, 'A beautiful summer ceremony');
        expect(article.coverImageUrl, 'https://example.com/cover.jpg');
        expect(article.videoUrl, 'https://vimeo.com/123456');
        expect(article.videoType, VideoType.vimeo);
        expect(article.publishedAt, testDate);
        expect(article.status, ArticleStatus.published);
        expect(article.contentBlocks.length, 2);
      });
    });

    group('computed properties', () {
      test('isDraft should return true when status is draft', () {
        final article = WedArticle(
          id: 'article-1',
          title: 'Test',
          publishedAt: testDate,
          status: ArticleStatus.draft,
          contentBlocks: const [],
        );

        expect(article.isDraft, isTrue);
        expect(article.isPublished, isFalse);
        expect(article.isArchived, isFalse);
      });

      test('isPublished should return true when status is published', () {
        final article = WedArticle(
          id: 'article-1',
          title: 'Test',
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: const [],
        );

        expect(article.isPublished, isTrue);
        expect(article.isDraft, isFalse);
        expect(article.isArchived, isFalse);
      });

      test('isArchived should return true when status is archived', () {
        final article = WedArticle(
          id: 'article-1',
          title: 'Test',
          publishedAt: testDate,
          status: ArticleStatus.archived,
          contentBlocks: const [],
        );

        expect(article.isArchived, isTrue);
        expect(article.isDraft, isFalse);
        expect(article.isPublished, isFalse);
      });

      test('hasVideo should return true when videoUrl is not null', () {
        final articleWithVideo = WedArticle(
          id: 'article-1',
          title: 'Test',
          videoUrl: 'https://vimeo.com/123',
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: const [],
        );
        final articleWithoutVideo = WedArticle(
          id: 'article-2',
          title: 'Test',
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: const [],
        );

        expect(articleWithVideo.hasVideo, isTrue);
        expect(articleWithoutVideo.hasVideo, isFalse);
      });

      test('hasCoverImage should return true when coverImageUrl is not null', () {
        final articleWithCover = WedArticle(
          id: 'article-1',
          title: 'Test',
          coverImageUrl: 'https://example.com/cover.jpg',
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: const [],
        );
        final articleWithoutCover = WedArticle(
          id: 'article-2',
          title: 'Test',
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: const [],
        );

        expect(articleWithCover.hasCoverImage, isTrue);
        expect(articleWithoutCover.hasCoverImage, isFalse);
      });

      test('hasSubtitle should return true when subtitle is not null', () {
        final articleWithSubtitle = WedArticle(
          id: 'article-1',
          title: 'Test',
          subtitle: 'Subtitle here',
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: const [],
        );
        final articleWithoutSubtitle = WedArticle(
          id: 'article-2',
          title: 'Test',
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: const [],
        );

        expect(articleWithSubtitle.hasSubtitle, isTrue);
        expect(articleWithoutSubtitle.hasSubtitle, isFalse);
      });

      test('hasContentBlocks should return true when blocks exist', () {
        final articleWithBlocks = WedArticle(
          id: 'article-1',
          title: 'Test',
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: testBlocks,
        );
        final articleWithoutBlocks = WedArticle(
          id: 'article-2',
          title: 'Test',
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: const [],
        );

        expect(articleWithBlocks.hasContentBlocks, isTrue);
        expect(articleWithoutBlocks.hasContentBlocks, isFalse);
      });
    });

    group('fromJson', () {
      test('should parse valid JSON with all fields', () {
        final json = {
          'id': 'article-1',
          'title': 'Wedding of the Week',
          'subtitle': 'A beautiful ceremony',
          'cover_image_url': 'https://example.com/cover.jpg',
          'video_url': 'https://vimeo.com/123456',
          'video_type': 'vimeo',
          'published_at': '2025-06-15T10:30:00.000',
          'status': 'published',
          'content_blocks': [
            {
              'type': 'text',
              'content': 'Introduction paragraph',
            },
            {
              'type': 'image',
              'image_url': 'https://example.com/image.jpg',
            },
          ],
        };

        final article = WedArticle.fromJson(json);

        expect(article.id, 'article-1');
        expect(article.title, 'Wedding of the Week');
        expect(article.subtitle, 'A beautiful ceremony');
        expect(article.coverImageUrl, 'https://example.com/cover.jpg');
        expect(article.videoUrl, 'https://vimeo.com/123456');
        expect(article.videoType, VideoType.vimeo);
        expect(article.publishedAt, DateTime(2025, 6, 15, 10, 30));
        expect(article.status, ArticleStatus.published);
        expect(article.contentBlocks.length, 2);
      });

      test('should parse JSON without optional fields', () {
        final json = {
          'id': 'article-1',
          'title': 'Wedding of the Week',
          'published_at': '2025-06-15T10:30:00.000',
          'status': 'draft',
          'content_blocks': <Map<String, dynamic>>[],
        };

        final article = WedArticle.fromJson(json);

        expect(article.id, 'article-1');
        expect(article.subtitle, isNull);
        expect(article.coverImageUrl, isNull);
        expect(article.videoUrl, isNull);
        expect(article.videoType, isNull);
        expect(article.status, ArticleStatus.draft);
      });

      test('should parse all status values correctly', () {
        final statuses = ['draft', 'published', 'archived'];
        final expected = [
          ArticleStatus.draft,
          ArticleStatus.published,
          ArticleStatus.archived,
        ];

        for (var i = 0; i < statuses.length; i++) {
          final json = {
            'id': 'article-1',
            'title': 'Test',
            'published_at': '2025-06-15T10:30:00.000',
            'status': statuses[i],
            'content_blocks': <Map<String, dynamic>>[],
          };

          final article = WedArticle.fromJson(json);
          expect(article.status, expected[i]);
        }
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
            'id': 'article-1',
            'title': 'Test',
            'video_url': 'https://example.com/video',
            'video_type': videoTypes[i],
            'published_at': '2025-06-15T10:30:00.000',
            'status': 'published',
            'content_blocks': <Map<String, dynamic>>[],
          };

          final article = WedArticle.fromJson(json);
          expect(article.videoType, expected[i]);
        }
      });

      test('should default to draft for unknown status', () {
        final json = {
          'id': 'article-1',
          'title': 'Test',
          'published_at': '2025-06-15T10:30:00.000',
          'status': 'unknown_status',
          'content_blocks': <Map<String, dynamic>>[],
        };

        final article = WedArticle.fromJson(json);
        expect(article.status, ArticleStatus.draft);
      });

      test('should handle null video_type gracefully', () {
        final json = {
          'id': 'article-1',
          'title': 'Test',
          'video_url': 'https://example.com/video',
          'published_at': '2025-06-15T10:30:00.000',
          'status': 'published',
          'content_blocks': <Map<String, dynamic>>[],
        };

        final article = WedArticle.fromJson(json);
        expect(article.videoType, isNull);
      });

      test('should parse content blocks correctly', () {
        final json = {
          'id': 'article-1',
          'title': 'Test',
          'published_at': '2025-06-15T10:30:00.000',
          'status': 'published',
          'content_blocks': [
            {'type': 'text', 'content': 'Paragraph 1'},
            {'type': 'quote', 'content': 'A quote'},
            {'type': 'image', 'image_url': 'https://example.com/img.jpg'},
          ],
        };

        final article = WedArticle.fromJson(json);

        expect(article.contentBlocks.length, 3);
        expect(article.contentBlocks[0].type, ContentBlockType.text);
        expect(article.contentBlocks[0].content, 'Paragraph 1');
        expect(article.contentBlocks[1].type, ContentBlockType.quote);
        expect(article.contentBlocks[2].type, ContentBlockType.image);
      });

      test('should handle null content_blocks gracefully', () {
        final json = {
          'id': 'article-1',
          'title': 'Test',
          'published_at': '2025-06-15T10:30:00.000',
          'status': 'published',
        };

        final article = WedArticle.fromJson(json);
        expect(article.contentBlocks, isEmpty);
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        final article = WedArticle(
          id: 'article-1',
          title: 'Wedding of the Week',
          subtitle: 'A beautiful ceremony',
          coverImageUrl: 'https://example.com/cover.jpg',
          videoUrl: 'https://vimeo.com/123456',
          videoType: VideoType.vimeo,
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: testBlocks,
        );

        final json = article.toJson();

        expect(json['title'], 'Wedding of the Week');
        expect(json['subtitle'], 'A beautiful ceremony');
        expect(json['cover_image_url'], 'https://example.com/cover.jpg');
        expect(json['video_url'], 'https://vimeo.com/123456');
        expect(json['video_type'], 'vimeo');
        expect(json['status'], 'published');
        expect(json['content_blocks'], isA<List>());
        expect((json['content_blocks'] as List).length, 2);
      });

      test('should not include null optional fields', () {
        final article = WedArticle(
          id: 'article-1',
          title: 'Test',
          publishedAt: testDate,
          status: ArticleStatus.draft,
          contentBlocks: const [],
        );

        final json = article.toJson();

        expect(json.containsKey('subtitle'), isFalse);
        expect(json.containsKey('cover_image_url'), isFalse);
        expect(json.containsKey('video_url'), isFalse);
        expect(json.containsKey('video_type'), isFalse);
      });
    });

    group('copyWith', () {
      test('should copy with new title', () {
        final original = WedArticle(
          id: 'article-1',
          title: 'Original Title',
          publishedAt: testDate,
          status: ArticleStatus.draft,
          contentBlocks: testBlocks,
        );

        final copied = original.copyWith(title: 'New Title');

        expect(copied.title, 'New Title');
        expect(copied.id, 'article-1');
        expect(copied.contentBlocks, testBlocks);
      });

      test('should copy with new status', () {
        final original = WedArticle(
          id: 'article-1',
          title: 'Test',
          publishedAt: testDate,
          status: ArticleStatus.draft,
          contentBlocks: const [],
        );

        final copied = original.copyWith(status: ArticleStatus.published);

        expect(copied.status, ArticleStatus.published);
      });

      test('should copy with new subtitle', () {
        final original = WedArticle(
          id: 'article-1',
          title: 'Test',
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: const [],
        );

        final copied = original.copyWith(subtitle: 'New Subtitle');

        expect(copied.subtitle, 'New Subtitle');
      });

      test('should copy with new content blocks', () {
        final original = WedArticle(
          id: 'article-1',
          title: 'Test',
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: const [],
        );

        final newBlocks = [
          const WedContentBlock(type: ContentBlockType.text, content: 'New'),
        ];
        final copied = original.copyWith(contentBlocks: newBlocks);

        expect(copied.contentBlocks, newBlocks);
        expect(copied.contentBlocks.length, 1);
      });

      test('should preserve unchanged values', () {
        final original = WedArticle(
          id: 'article-1',
          title: 'Original',
          subtitle: 'Original Subtitle',
          coverImageUrl: 'https://example.com/cover.jpg',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: testBlocks,
        );

        final copied = original.copyWith(title: 'New Title');

        expect(copied.id, 'article-1');
        expect(copied.subtitle, 'Original Subtitle');
        expect(copied.coverImageUrl, 'https://example.com/cover.jpg');
        expect(copied.videoUrl, 'https://vimeo.com/123');
        expect(copied.videoType, VideoType.vimeo);
        expect(copied.publishedAt, testDate);
        expect(copied.status, ArticleStatus.published);
        expect(copied.contentBlocks, testBlocks);
      });
    });

    group('equality', () {
      test('should be equal with same id', () {
        final article1 = WedArticle(
          id: 'article-1',
          title: 'Title 1',
          publishedAt: testDate,
          status: ArticleStatus.draft,
          contentBlocks: const [],
        );
        final article2 = WedArticle(
          id: 'article-1',
          title: 'Different Title',
          publishedAt: DateTime(2020, 1, 1),
          status: ArticleStatus.published,
          contentBlocks: testBlocks,
        );

        expect(article1, equals(article2));
        expect(article1.hashCode, equals(article2.hashCode));
      });

      test('should not be equal with different id', () {
        final article1 = WedArticle(
          id: 'article-1',
          title: 'Same Title',
          publishedAt: testDate,
          status: ArticleStatus.draft,
          contentBlocks: const [],
        );
        final article2 = WedArticle(
          id: 'article-2',
          title: 'Same Title',
          publishedAt: testDate,
          status: ArticleStatus.draft,
          contentBlocks: const [],
        );

        expect(article1, isNot(equals(article2)));
      });
    });

    group('toString', () {
      test('should return readable string representation', () {
        final article = WedArticle(
          id: 'article-1',
          title: 'Wedding of the Week',
          publishedAt: testDate,
          status: ArticleStatus.published,
          contentBlocks: testBlocks,
        );

        final str = article.toString();

        expect(str, contains('article-1'));
        expect(str, contains('Wedding of the Week'));
        expect(str, contains('published'));
      });
    });
  });
}
