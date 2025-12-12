/// Saved Post entity for My Wedding Suite
///
/// Represents an image saved from the feed to an inspiration album.
/// DB schema: saved_posts(id, album_id, image_url, source_profile_id, saved_at)
library;

import 'package:flutter/foundation.dart';

/// Saved Post entity
@immutable
class SavedPost {
  const SavedPost({
    required this.id,
    required this.albumId,
    required this.imageUrl,
    this.sourceProfileId,
    this.sourceProfileName,
    this.savedAt,
  });

  /// UUID of the saved post entry
  final String id;

  /// UUID of the album
  final String albumId;

  /// Image URL saved from the feed
  final String imageUrl;

  /// Profile ID of the pro who posted the image (optional)
  final String? sourceProfileId;

  /// Display name of the source pro (joined from profiles)
  final String? sourceProfileName;

  /// Date when saved
  final DateTime? savedAt;

  /// Factory from Supabase JSON
  factory SavedPost.fromJson(Map<String, dynamic> json) {
    // Handle joined profile data if present
    final profiles = json['profiles'] as Map<String, dynamic>?;
    
    return SavedPost(
      id: json['id'] as String,
      albumId: json['album_id'] as String,
      imageUrl: json['image_url'] as String,
      sourceProfileId: json['source_profile_id'] as String?,
      sourceProfileName: profiles?['full_name'] as String? ??
          profiles?['business_name'] as String?,
      savedAt: json['saved_at'] != null 
          ? DateTime.parse(json['saved_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'album_id': albumId,
      'image_url': imageUrl,
      if (sourceProfileId != null) 'source_profile_id': sourceProfileId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedPost && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SavedPost($id, imageUrl: $imageUrl)';
}
