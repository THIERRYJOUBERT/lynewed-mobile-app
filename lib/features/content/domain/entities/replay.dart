/// Replay entity for content feature.
///
/// Represents a video replay that users can watch.
/// Used for wedding ceremony replays and other video content.
library;

import 'package:flutter/foundation.dart';

import 'wed_article.dart';

/// Replay entity.
///
/// Represents a video replay with metadata including title,
/// description, thumbnail, and duration information.
@immutable
class Replay {
  /// Creates a replay.
  const Replay({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.videoType,
    required this.createdAt,
    this.description,
    this.thumbnailUrl,
    this.duration,
  });

  /// UUID of the replay.
  final String id;

  /// Title of the replay.
  final String title;

  /// Optional description.
  final String? description;

  /// Thumbnail image URL.
  final String? thumbnailUrl;

  /// Video URL.
  final String videoUrl;

  /// Type of video (youtube, vimeo, direct).
  final VideoType videoType;

  /// Duration of the video.
  final Duration? duration;

  /// When the replay was created.
  final DateTime createdAt;

  /// Whether this replay has a thumbnail.
  bool get hasThumbnail => thumbnailUrl != null;

  /// Whether this replay has a description.
  bool get hasDescription => description != null;

  /// Whether this replay has duration information.
  bool get hasDuration => duration != null;

  /// Whether this is a YouTube video.
  bool get isYouTube => videoType == VideoType.youtube;

  /// Whether this is a Vimeo video.
  bool get isVimeo => videoType == VideoType.vimeo;

  /// Whether this is a direct video.
  bool get isDirect => videoType == VideoType.direct;

  /// Formatted duration string (e.g., "1:23:45" or "5:30").
  String? get formattedDuration {
    if (duration == null) return null;

    final hours = duration!.inHours;
    final minutes = duration!.inMinutes.remainder(60);
    final seconds = duration!.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Creates a Replay from JSON.
  factory Replay.fromJson(Map<String, dynamic> json) {
    final durationSeconds = json['duration_seconds'] as int?;

    return Replay(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      videoUrl: json['video_url'] as String,
      videoType: _parseVideoType(json['video_type'] as String?),
      duration:
          durationSeconds != null ? Duration(seconds: durationSeconds) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static VideoType _parseVideoType(String? value) {
    switch (value) {
      case 'youtube':
        return VideoType.youtube;
      case 'vimeo':
        return VideoType.vimeo;
      default:
        return VideoType.direct;
    }
  }

  /// Converts to JSON for serialization.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'title': title,
      'video_url': videoUrl,
      'video_type': videoType.name,
      'created_at': createdAt.toIso8601String(),
    };

    if (description != null) {
      json['description'] = description;
    }
    if (thumbnailUrl != null) {
      json['thumbnail_url'] = thumbnailUrl;
    }
    if (duration != null) {
      json['duration_seconds'] = duration!.inSeconds;
    }

    return json;
  }

  /// Creates a copy with updated values.
  Replay copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? videoUrl,
    VideoType? videoType,
    Duration? duration,
    DateTime? createdAt,
  }) {
    return Replay(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      videoType: videoType ?? this.videoType,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Replay && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Replay($id, $title, ${videoType.name})';
}
