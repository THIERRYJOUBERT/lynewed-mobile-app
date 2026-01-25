/// Tests for WedContentBlock entity.
///
/// Comprehensive tests covering:
/// - Entity creation with required and optional fields
/// - JSON serialization/deserialization
/// - copyWith functionality
/// - Equality and hashCode
/// - Computed properties
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/content/domain/entities/wed_content_block.dart';

void main() {
  group('ContentBlockType', () {
    test('should have all expected values', () {
      expect(ContentBlockType.values, contains(ContentBlockType.text));
      expect(ContentBlockType.values, contains(ContentBlockType.image));
      expect(ContentBlockType.values, contains(ContentBlockType.video));
      expect(ContentBlockType.values, contains(ContentBlockType.quote));
    });

    test('should have 4 values', () {
      expect(ContentBlockType.values.length, 4);
    });
  });

  group('WedContentBlock', () {
    group('creation', () {
      test('should create text block with content', () {
        const block = WedContentBlock(
          type: ContentBlockType.text,
          content: 'This is a paragraph of text.',
        );

        expect(block.type, ContentBlockType.text);
        expect(block.content, 'This is a paragraph of text.');
        expect(block.imageUrl, isNull);
        expect(block.videoUrl, isNull);
      });

      test('should create image block with imageUrl', () {
        const block = WedContentBlock(
          type: ContentBlockType.image,
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(block.type, ContentBlockType.image);
        expect(block.imageUrl, 'https://example.com/image.jpg');
        expect(block.content, isNull);
        expect(block.videoUrl, isNull);
      });

      test('should create video block with videoUrl', () {
        const block = WedContentBlock(
          type: ContentBlockType.video,
          videoUrl: 'https://vimeo.com/123456',
        );

        expect(block.type, ContentBlockType.video);
        expect(block.videoUrl, 'https://vimeo.com/123456');
        expect(block.content, isNull);
        expect(block.imageUrl, isNull);
      });

      test('should create quote block with content', () {
        const block = WedContentBlock(
          type: ContentBlockType.quote,
          content: 'This is an inspiring quote.',
        );

        expect(block.type, ContentBlockType.quote);
        expect(block.content, 'This is an inspiring quote.');
      });

      test('should create block with all fields', () {
        const block = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Text content',
          imageUrl: 'https://example.com/image.jpg',
          videoUrl: 'https://vimeo.com/123456',
        );

        expect(block.type, ContentBlockType.text);
        expect(block.content, 'Text content');
        expect(block.imageUrl, 'https://example.com/image.jpg');
        expect(block.videoUrl, 'https://vimeo.com/123456');
      });
    });

    group('computed properties', () {
      test('isText should return true for text blocks', () {
        const block = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Text',
        );

        expect(block.isText, isTrue);
        expect(block.isImage, isFalse);
        expect(block.isVideo, isFalse);
        expect(block.isQuote, isFalse);
      });

      test('isImage should return true for image blocks', () {
        const block = WedContentBlock(
          type: ContentBlockType.image,
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(block.isImage, isTrue);
        expect(block.isText, isFalse);
        expect(block.isVideo, isFalse);
        expect(block.isQuote, isFalse);
      });

      test('isVideo should return true for video blocks', () {
        const block = WedContentBlock(
          type: ContentBlockType.video,
          videoUrl: 'https://vimeo.com/123',
        );

        expect(block.isVideo, isTrue);
        expect(block.isText, isFalse);
        expect(block.isImage, isFalse);
        expect(block.isQuote, isFalse);
      });

      test('isQuote should return true for quote blocks', () {
        const block = WedContentBlock(
          type: ContentBlockType.quote,
          content: 'Quote text',
        );

        expect(block.isQuote, isTrue);
        expect(block.isText, isFalse);
        expect(block.isImage, isFalse);
        expect(block.isVideo, isFalse);
      });

      test('hasContent should return true when content is not null', () {
        const blockWithContent = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Some content',
        );
        const blockWithoutContent = WedContentBlock(
          type: ContentBlockType.image,
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(blockWithContent.hasContent, isTrue);
        expect(blockWithoutContent.hasContent, isFalse);
      });

      test('hasImage should return true when imageUrl is not null', () {
        const blockWithImage = WedContentBlock(
          type: ContentBlockType.image,
          imageUrl: 'https://example.com/image.jpg',
        );
        const blockWithoutImage = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Text',
        );

        expect(blockWithImage.hasImage, isTrue);
        expect(blockWithoutImage.hasImage, isFalse);
      });

      test('hasVideo should return true when videoUrl is not null', () {
        const blockWithVideo = WedContentBlock(
          type: ContentBlockType.video,
          videoUrl: 'https://vimeo.com/123',
        );
        const blockWithoutVideo = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Text',
        );

        expect(blockWithVideo.hasVideo, isTrue);
        expect(blockWithoutVideo.hasVideo, isFalse);
      });
    });

    group('fromJson', () {
      test('should parse text block from JSON', () {
        final json = {
          'type': 'text',
          'content': 'Some text content',
        };

        final block = WedContentBlock.fromJson(json);

        expect(block.type, ContentBlockType.text);
        expect(block.content, 'Some text content');
        expect(block.imageUrl, isNull);
        expect(block.videoUrl, isNull);
      });

      test('should parse image block from JSON', () {
        final json = {
          'type': 'image',
          'image_url': 'https://example.com/image.jpg',
        };

        final block = WedContentBlock.fromJson(json);

        expect(block.type, ContentBlockType.image);
        expect(block.imageUrl, 'https://example.com/image.jpg');
      });

      test('should parse video block from JSON', () {
        final json = {
          'type': 'video',
          'video_url': 'https://vimeo.com/123456',
        };

        final block = WedContentBlock.fromJson(json);

        expect(block.type, ContentBlockType.video);
        expect(block.videoUrl, 'https://vimeo.com/123456');
      });

      test('should parse quote block from JSON', () {
        final json = {
          'type': 'quote',
          'content': 'An inspiring quote',
        };

        final block = WedContentBlock.fromJson(json);

        expect(block.type, ContentBlockType.quote);
        expect(block.content, 'An inspiring quote');
      });

      test('should parse block with all fields from JSON', () {
        final json = {
          'type': 'text',
          'content': 'Full content',
          'image_url': 'https://example.com/image.jpg',
          'video_url': 'https://vimeo.com/123456',
        };

        final block = WedContentBlock.fromJson(json);

        expect(block.type, ContentBlockType.text);
        expect(block.content, 'Full content');
        expect(block.imageUrl, 'https://example.com/image.jpg');
        expect(block.videoUrl, 'https://vimeo.com/123456');
      });

      test('should default to text type for unknown type', () {
        final json = {
          'type': 'unknown_type',
          'content': 'Some content',
        };

        final block = WedContentBlock.fromJson(json);

        expect(block.type, ContentBlockType.text);
      });

      test('should handle null type gracefully', () {
        final json = <String, dynamic>{
          'type': null,
          'content': 'Some content',
        };

        final block = WedContentBlock.fromJson(json);

        expect(block.type, ContentBlockType.text);
      });
    });

    group('toJson', () {
      test('should serialize text block to JSON', () {
        const block = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Text content',
        );

        final json = block.toJson();

        expect(json['type'], 'text');
        expect(json['content'], 'Text content');
        expect(json.containsKey('image_url'), isFalse);
        expect(json.containsKey('video_url'), isFalse);
      });

      test('should serialize image block to JSON', () {
        const block = WedContentBlock(
          type: ContentBlockType.image,
          imageUrl: 'https://example.com/image.jpg',
        );

        final json = block.toJson();

        expect(json['type'], 'image');
        expect(json['image_url'], 'https://example.com/image.jpg');
      });

      test('should serialize video block to JSON', () {
        const block = WedContentBlock(
          type: ContentBlockType.video,
          videoUrl: 'https://vimeo.com/123456',
        );

        final json = block.toJson();

        expect(json['type'], 'video');
        expect(json['video_url'], 'https://vimeo.com/123456');
      });

      test('should serialize block with all fields to JSON', () {
        const block = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Full content',
          imageUrl: 'https://example.com/image.jpg',
          videoUrl: 'https://vimeo.com/123456',
        );

        final json = block.toJson();

        expect(json['type'], 'text');
        expect(json['content'], 'Full content');
        expect(json['image_url'], 'https://example.com/image.jpg');
        expect(json['video_url'], 'https://vimeo.com/123456');
      });

      test('should not include null values in JSON', () {
        const block = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Just content',
        );

        final json = block.toJson();

        expect(json.containsKey('image_url'), isFalse);
        expect(json.containsKey('video_url'), isFalse);
      });
    });

    group('copyWith', () {
      test('should copy with new type', () {
        const original = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Original content',
        );

        final copied = original.copyWith(type: ContentBlockType.quote);

        expect(copied.type, ContentBlockType.quote);
        expect(copied.content, 'Original content');
      });

      test('should copy with new content', () {
        const original = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Original content',
        );

        final copied = original.copyWith(content: 'New content');

        expect(copied.type, ContentBlockType.text);
        expect(copied.content, 'New content');
      });

      test('should copy with new imageUrl', () {
        const original = WedContentBlock(
          type: ContentBlockType.image,
          imageUrl: 'https://example.com/original.jpg',
        );

        final copied = original.copyWith(imageUrl: 'https://example.com/new.jpg');

        expect(copied.imageUrl, 'https://example.com/new.jpg');
      });

      test('should copy with new videoUrl', () {
        const original = WedContentBlock(
          type: ContentBlockType.video,
          videoUrl: 'https://vimeo.com/original',
        );

        final copied = original.copyWith(videoUrl: 'https://vimeo.com/new');

        expect(copied.videoUrl, 'https://vimeo.com/new');
      });

      test('should preserve unchanged values', () {
        const original = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Content',
          imageUrl: 'https://example.com/image.jpg',
          videoUrl: 'https://vimeo.com/123',
        );

        final copied = original.copyWith(type: ContentBlockType.quote);

        expect(copied.type, ContentBlockType.quote);
        expect(copied.content, 'Content');
        expect(copied.imageUrl, 'https://example.com/image.jpg');
        expect(copied.videoUrl, 'https://vimeo.com/123');
      });
    });

    group('equality', () {
      test('should be equal with same values', () {
        const block1 = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Same content',
        );
        const block2 = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Same content',
        );

        expect(block1, equals(block2));
        expect(block1.hashCode, equals(block2.hashCode));
      });

      test('should not be equal with different type', () {
        const block1 = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Same content',
        );
        const block2 = WedContentBlock(
          type: ContentBlockType.quote,
          content: 'Same content',
        );

        expect(block1, isNot(equals(block2)));
      });

      test('should not be equal with different content', () {
        const block1 = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Content 1',
        );
        const block2 = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Content 2',
        );

        expect(block1, isNot(equals(block2)));
      });
    });

    group('toString', () {
      test('should return readable string representation', () {
        const block = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Some text content',
        );

        final str = block.toString();

        expect(str, contains('text'));
        expect(str, contains('WedContentBlock'));
      });
    });
  });
}
