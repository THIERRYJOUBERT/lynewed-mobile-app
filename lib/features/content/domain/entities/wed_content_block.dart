/// WedContentBlock entity for content feature.
///
/// Represents a content block within an article or page.
/// Supports text, image, video, and quote block types.
library;

import 'package:flutter/foundation.dart';

/// Type of content block.
enum ContentBlockType {
  /// Text content block.
  text,

  /// Image content block.
  image,

  /// Video content block.
  video,

  /// Quote content block.
  quote,
}

/// Content block entity.
///
/// Represents a single block of content that can be rendered
/// as part of an article or page. Each block has a type and
/// can contain text content, an image URL, or a video URL.
@immutable
class WedContentBlock {
  /// Creates a content block.
  const WedContentBlock({
    required this.type,
    this.content,
    this.imageUrl,
    this.videoUrl,
  });

  /// The type of this content block.
  final ContentBlockType type;

  /// Text content for text and quote blocks.
  final String? content;

  /// URL for image blocks.
  final String? imageUrl;

  /// URL for video blocks.
  final String? videoUrl;

  /// Whether this is a text block.
  bool get isText => type == ContentBlockType.text;

  /// Whether this is an image block.
  bool get isImage => type == ContentBlockType.image;

  /// Whether this is a video block.
  bool get isVideo => type == ContentBlockType.video;

  /// Whether this is a quote block.
  bool get isQuote => type == ContentBlockType.quote;

  /// Whether this block has text content.
  bool get hasContent => content != null;

  /// Whether this block has an image.
  bool get hasImage => imageUrl != null;

  /// Whether this block has a video.
  bool get hasVideo => videoUrl != null;

  /// Creates a WedContentBlock from JSON.
  factory WedContentBlock.fromJson(Map<String, dynamic> json) {
    return WedContentBlock(
      type: _parseType(json['type'] as String?),
      content: json['content'] as String?,
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
    );
  }

  static ContentBlockType _parseType(String? value) {
    switch (value) {
      case 'text':
        return ContentBlockType.text;
      case 'image':
        return ContentBlockType.image;
      case 'video':
        return ContentBlockType.video;
      case 'quote':
        return ContentBlockType.quote;
      default:
        return ContentBlockType.text;
    }
  }

  /// Converts to JSON for serialization.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': type.name,
    };

    if (content != null) {
      json['content'] = content;
    }
    if (imageUrl != null) {
      json['image_url'] = imageUrl;
    }
    if (videoUrl != null) {
      json['video_url'] = videoUrl;
    }

    return json;
  }

  /// Creates a copy with updated values.
  WedContentBlock copyWith({
    ContentBlockType? type,
    String? content,
    String? imageUrl,
    String? videoUrl,
  }) {
    return WedContentBlock(
      type: type ?? this.type,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WedContentBlock &&
        other.type == type &&
        other.content == content &&
        other.imageUrl == imageUrl &&
        other.videoUrl == videoUrl;
  }

  @override
  int get hashCode => Object.hash(type, content, imageUrl, videoUrl);

  @override
  String toString() => 'WedContentBlock(${type.name})';
}
