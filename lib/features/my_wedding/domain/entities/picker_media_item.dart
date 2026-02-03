/// Picker Media Item entity for magazine photo picker.
///
/// Represents a photo or video available for selection in the magazine picker.
/// Combines media from different sources (guest albums, inspiration albums).
library;

import 'package:flutter/foundation.dart';

/// Media item available for selection in the magazine picker.
@immutable
class PickerMediaItem {
  /// Creates a picker media item.
  const PickerMediaItem({
    required this.id,
    required this.mediaType,
    required this.thumbnailUrl,
    required this.sourceName,
    required this.sourceType,
    required this.sourceId,
    required this.createdAt,
    this.isVideo = false,
    this.isAlreadySelected = false,
  });

  /// UUID of the media item (album_images.id or guest_media.id).
  final String id;

  /// Type of media for magazine_selections: 'album_image' or 'guest_media'.
  final String mediaType;

  /// URL for thumbnail display.
  final String thumbnailUrl;

  /// Name of the source (album name or guest name).
  final String sourceName;

  /// Type of source: 'inspiration' or 'guest'.
  final String sourceType;

  /// ID of the source (album_id or guest_album_id).
  final String sourceId;

  /// When this media was created/uploaded.
  final DateTime createdAt;

  /// Whether this is a video (vs photo).
  final bool isVideo;

  /// Whether this item is already selected for the magazine.
  final bool isAlreadySelected;

  /// Factory from guest_media JSON with additional metadata.
  factory PickerMediaItem.fromGuestMedia(
    Map<String, dynamic> json, {
    required String guestName,
    required String albumId,
    required bool isAlreadySelected,
  }) {
    final mediaType = json['media_type'] as String?;
    return PickerMediaItem(
      id: json['id'] as String,
      mediaType: 'guest_media',
      thumbnailUrl: (json['thumbnail_url'] as String?) ??
          (json['media_url'] as String?) ??
          '',
      sourceName: guestName,
      sourceType: 'guest',
      sourceId: albumId,
      createdAt: DateTime.parse(json['created_at'] as String),
      isVideo: mediaType == 'video',
      isAlreadySelected: isAlreadySelected,
    );
  }

  /// Factory from album_images JSON with additional metadata.
  factory PickerMediaItem.fromAlbumImage(
    Map<String, dynamic> json, {
    required String albumName,
    required String albumId,
    required bool isAlreadySelected,
  }) {
    final mediaType = json['media_type'] as String?;
    return PickerMediaItem(
      id: json['id'] as String,
      mediaType: 'album_image',
      thumbnailUrl: (json['thumbnail_url'] as String?) ??
          (json['image_url'] as String?) ??
          '',
      sourceName: albumName,
      sourceType: 'inspiration',
      sourceId: albumId,
      createdAt: DateTime.parse(json['created_at'] as String),
      isVideo: mediaType == 'video',
      isAlreadySelected: isAlreadySelected,
    );
  }

  /// Creates a copy with updated values.
  PickerMediaItem copyWith({
    String? id,
    String? mediaType,
    String? thumbnailUrl,
    String? sourceName,
    String? sourceType,
    String? sourceId,
    DateTime? createdAt,
    bool? isVideo,
    bool? isAlreadySelected,
  }) {
    return PickerMediaItem(
      id: id ?? this.id,
      mediaType: mediaType ?? this.mediaType,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      sourceName: sourceName ?? this.sourceName,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      createdAt: createdAt ?? this.createdAt,
      isVideo: isVideo ?? this.isVideo,
      isAlreadySelected: isAlreadySelected ?? this.isAlreadySelected,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PickerMediaItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          mediaType == other.mediaType;

  @override
  int get hashCode => id.hashCode ^ mediaType.hashCode;
}

/// A group of media items from the same source.
@immutable
class PickerMediaGroup {
  /// Creates a picker media group.
  const PickerMediaGroup({
    required this.id,
    required this.name,
    required this.items,
    this.avatarUrl,
  });

  /// ID of the group (album_id or guest_user_id).
  final String id;

  /// Name of the group (album name or guest name).
  final String name;

  /// Avatar URL for display (guest photo or album cover).
  final String? avatarUrl;

  /// Media items in this group.
  final List<PickerMediaItem> items;

  /// Total count of items.
  int get count => items.length;

  /// Count of items already selected.
  int get selectedCount => items.where((i) => i.isAlreadySelected).length;
}

/// A section of media groups (e.g., "Guest Albums" or "Inspiration Albums").
@immutable
class PickerMediaSection {
  /// Creates a picker media section.
  const PickerMediaSection({
    required this.title,
    required this.groups,
    this.subtitle,
  });

  /// Title of the section (e.g., "Guest Albums").
  final String title;

  /// Subtitle with additional info (e.g., "12 photos from 3 guests").
  final String? subtitle;

  /// Groups of media in this section.
  final List<PickerMediaGroup> groups;

  /// Total count of items across all groups.
  int get totalCount =>
      groups.fold<int>(0, (sum, group) => sum + group.count);

  /// Count of items already selected across all groups.
  int get selectedCount =>
      groups.fold<int>(0, (sum, group) => sum + group.selectedCount);
}
