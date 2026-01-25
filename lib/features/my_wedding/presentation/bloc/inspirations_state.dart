/// Inspirations State for InspirationsCubit.
///
/// Defines the state for managing inspiration albums and their content.
library;

import 'package:flutter/foundation.dart';

import '../../domain/entities/album_image.dart';
import '../../domain/entities/inspiration_album.dart';
import '../../domain/entities/saved_post.dart';

/// State for the inspirations Cubit.
///
/// Tracks the albums, selected album, album content (images and saved posts),
/// loading state, and errors.
@immutable
class InspirationsState {
  /// Creates an inspirations state.
  const InspirationsState({
    this.albums = const [],
    this.selectedAlbum,
    this.albumImages = const [],
    this.savedPosts = const [],
    this.isLoading = false,
    this.error,
  });

  /// List of all inspiration albums.
  final List<InspirationAlbum> albums;

  /// Currently selected album for viewing content.
  final InspirationAlbum? selectedAlbum;

  /// Images in the selected album.
  final List<AlbumImage> albumImages;

  /// Saved posts in the selected album.
  final List<SavedPost> savedPosts;

  /// Whether an operation is in progress.
  final bool isLoading;

  /// Error message, if any.
  final String? error;

  /// Returns combined list of all items in the album (images and saved posts).
  List<dynamic> get allItems => [...albumImages, ...savedPosts];

  /// Creates a copy with updated values.
  ///
  /// Use [clearError] to explicitly set error to null.
  /// Use [clearSelectedAlbum] to explicitly set selectedAlbum to null.
  InspirationsState copyWith({
    List<InspirationAlbum>? albums,
    InspirationAlbum? selectedAlbum,
    List<AlbumImage>? albumImages,
    List<SavedPost>? savedPosts,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearSelectedAlbum = false,
  }) {
    return InspirationsState(
      albums: albums ?? this.albums,
      selectedAlbum: clearSelectedAlbum ? null : (selectedAlbum ?? this.selectedAlbum),
      albumImages: albumImages ?? this.albumImages,
      savedPosts: savedPosts ?? this.savedPosts,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InspirationsState &&
        listEquals(other.albums, albums) &&
        other.selectedAlbum == selectedAlbum &&
        listEquals(other.albumImages, albumImages) &&
        listEquals(other.savedPosts, savedPosts) &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(albums),
        selectedAlbum,
        Object.hashAll(albumImages),
        Object.hashAll(savedPosts),
        isLoading,
        error,
      );
}
