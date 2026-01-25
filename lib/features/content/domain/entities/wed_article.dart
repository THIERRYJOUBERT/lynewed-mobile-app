/// WedArticle entity for content feature.
///
/// Represents a wedding article with content blocks, video, and images.
/// Used for "Wedding of the Week" and similar article content.
library;

import 'package:flutter/foundation.dart';

import 'wed_content_block.dart';

/// Status of an article.
enum ArticleStatus {
  /// Article is a draft and not published.
  draft,

  /// Article is published and visible.
  published,

  /// Article is archived and no longer visible.
  archived,
}

/// Type of video for an article.
enum VideoType {
  /// YouTube video.
  youtube,

  /// Vimeo video.
  vimeo,

  /// Direct video URL (MP4, etc.).
  direct,
}

/// Wedding article entity.
///
/// Represents an article in the app such as "Wedding of the Week".
/// Contains a title, optional video, cover image, and content blocks.
@immutable
class WedArticle {
  /// Creates a wedding article.
  const WedArticle({
    required this.id,
    required this.title,
    required this.publishedAt,
    required this.status,
    required this.contentBlocks,
    this.subtitle,
    this.coverImageUrl,
    this.videoUrl,
    this.videoType,
  });

  /// UUID of the article.
  final String id;

  /// Title of the article.
  final String title;

  /// Optional subtitle.
  final String? subtitle;

  /// Cover image URL.
  final String? coverImageUrl;

  /// Video URL if the article has a featured video.
  final String? videoUrl;

  /// Type of video (youtube, vimeo, direct).
  final VideoType? videoType;

  /// When the article was published.
  final DateTime publishedAt;

  /// Current status of the article.
  final ArticleStatus status;

  /// List of content blocks that make up the article body.
  final List<WedContentBlock> contentBlocks;

  /// Whether this article is a draft.
  bool get isDraft => status == ArticleStatus.draft;

  /// Whether this article is published.
  bool get isPublished => status == ArticleStatus.published;

  /// Whether this article is archived.
  bool get isArchived => status == ArticleStatus.archived;

  /// Whether this article has a video.
  bool get hasVideo => videoUrl != null;

  /// Whether this article has a cover image.
  bool get hasCoverImage => coverImageUrl != null;

  /// Whether this article has a subtitle.
  bool get hasSubtitle => subtitle != null;

  /// Whether this article has content blocks.
  bool get hasContentBlocks => contentBlocks.isNotEmpty;

  /// Creates a WedArticle from JSON.
  factory WedArticle.fromJson(Map<String, dynamic> json) {
    final blocksJson = json['content_blocks'] as List<dynamic>?;
    final blocks = blocksJson
            ?.map((b) => WedContentBlock.fromJson(b as Map<String, dynamic>))
            .toList() ??
        <WedContentBlock>[];

    return WedArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      videoType: _parseVideoType(json['video_type'] as String?),
      publishedAt: DateTime.parse(json['published_at'] as String),
      status: _parseStatus(json['status'] as String?),
      contentBlocks: blocks,
    );
  }

  static ArticleStatus _parseStatus(String? value) {
    switch (value) {
      case 'published':
        return ArticleStatus.published;
      case 'archived':
        return ArticleStatus.archived;
      default:
        return ArticleStatus.draft;
    }
  }

  static VideoType? _parseVideoType(String? value) {
    switch (value) {
      case 'youtube':
        return VideoType.youtube;
      case 'vimeo':
        return VideoType.vimeo;
      case 'direct':
        return VideoType.direct;
      default:
        return null;
    }
  }

  /// Converts to JSON for serialization.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'title': title,
      'published_at': publishedAt.toIso8601String(),
      'status': status.name,
      'content_blocks': contentBlocks.map((b) => b.toJson()).toList(),
    };

    if (subtitle != null) {
      json['subtitle'] = subtitle;
    }
    if (coverImageUrl != null) {
      json['cover_image_url'] = coverImageUrl;
    }
    if (videoUrl != null) {
      json['video_url'] = videoUrl;
    }
    if (videoType != null) {
      json['video_type'] = videoType!.name;
    }

    return json;
  }

  /// Creates a copy with updated values.
  WedArticle copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? coverImageUrl,
    String? videoUrl,
    VideoType? videoType,
    DateTime? publishedAt,
    ArticleStatus? status,
    List<WedContentBlock>? contentBlocks,
  }) {
    return WedArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      videoType: videoType ?? this.videoType,
      publishedAt: publishedAt ?? this.publishedAt,
      status: status ?? this.status,
      contentBlocks: contentBlocks ?? this.contentBlocks,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WedArticle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WedArticle($id, $title, ${status.name})';
}
