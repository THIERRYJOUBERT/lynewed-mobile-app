/// Saved Post entity for My Wedding Suite
///
/// Represents a post saved from the feed to an inspiration album.
library;

import 'package:flutter/foundation.dart';

/// Saved Post entity
@immutable
class SavedPost {
  const SavedPost({
    required this.id,
    required this.albumId,
    required this.postId,
    this.postImageUrl,
    this.postAuthorName,
    this.savedAt,
  });

  /// UUID of the saved post entry
  final String id;

  /// UUID of the album
  final String albumId;

  /// UUID of the original post
  final String postId;

  /// Post image URL (for display)
  final String? postImageUrl;

  /// Post author name (for display)
  final String? postAuthorName;

  /// Date when saved
  final DateTime? savedAt;

  /// Factory from Supabase JSON
  factory SavedPost.fromJson(Map<String, dynamic> json) {
    return SavedPost(
      id: json['id'] as String,
      albumId: json['album_id'] as String,
      postId: json['post_id'] as String,
      postImageUrl: json['post_image_url'] as String?,
      postAuthorName: json['post_author_name'] as String?,
      savedAt: json['saved_at'] != null 
          ? DateTime.parse(json['saved_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'album_id': albumId,
      'post_id': postId,
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
  String toString() => 'SavedPost($id, postId: $postId)';
}
