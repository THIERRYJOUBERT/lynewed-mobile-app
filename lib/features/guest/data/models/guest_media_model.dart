/// Guest Media Model for data layer.
///
/// Extends GuestMedia entity with JSON serialization for Supabase.
library;

import '../../domain/entities/guest_media.dart';

/// Data model for GuestMedia with Supabase serialization.
///
/// This model can be used interchangeably with the domain entity
/// since GuestMedia already has fromJson/toJson methods.
class GuestMediaModel extends GuestMedia {
  /// Creates a GuestMediaModel.
  const GuestMediaModel({
    required super.id,
    required super.albumId,
    required super.mediaType,
    required super.storagePath,
    super.thumbnailPath,
    super.caption,
    super.durationSeconds,
    super.fileSizeBytes,
    required super.createdAt,
  });

  /// Creates a GuestMediaModel from Supabase JSON.
  factory GuestMediaModel.fromJson(Map<String, dynamic> json) {
    return GuestMediaModel(
      id: json['id'] as String,
      albumId: json['album_id'] as String,
      mediaType: json['media_type'] as String,
      storagePath: json['storage_path'] as String,
      thumbnailPath: json['thumbnail_path'] as String?,
      caption: json['caption'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      fileSizeBytes: json['file_size_bytes'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Creates a GuestMediaModel from a GuestMedia entity.
  factory GuestMediaModel.fromEntity(GuestMedia entity) {
    return GuestMediaModel(
      id: entity.id,
      albumId: entity.albumId,
      mediaType: entity.mediaType,
      storagePath: entity.storagePath,
      thumbnailPath: entity.thumbnailPath,
      caption: entity.caption,
      durationSeconds: entity.durationSeconds,
      fileSizeBytes: entity.fileSizeBytes,
      createdAt: entity.createdAt,
    );
  }

  /// Converts to JSON for Supabase insert (excludes id, created_at).
  @override
  Map<String, dynamic> toJson() {
    return {
      'album_id': albumId,
      'media_type': mediaType,
      'storage_path': storagePath,
      'thumbnail_path': thumbnailPath,
      'caption': caption,
      'duration_seconds': durationSeconds,
      'file_size_bytes': fileSizeBytes,
    };
  }

  /// Converts to full JSON including all fields.
  Map<String, dynamic> toFullJson() {
    return {
      'id': id,
      'album_id': albumId,
      'media_type': mediaType,
      'storage_path': storagePath,
      'thumbnail_path': thumbnailPath,
      'caption': caption,
      'duration_seconds': durationSeconds,
      'file_size_bytes': fileSizeBytes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
