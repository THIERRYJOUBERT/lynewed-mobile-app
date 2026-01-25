/// Inspirations Cubit for managing inspiration albums state.
///
/// Handles loading albums, creating albums, selecting albums,
/// managing album content (images and saved posts).
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/inspiration_album.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import 'inspirations_state.dart';

/// Cubit for managing inspiration albums state.
///
/// Provides methods for loading albums, creating/deleting albums,
/// selecting albums, and managing album content.
class InspirationsCubit extends Cubit<InspirationsState> {
  /// Creates an InspirationsCubit with the given repository and wedding ID.
  InspirationsCubit({
    required MyWeddingRepository repository,
    required this.weddingId,
  })  : _repository = repository,
        super(const InspirationsState());

  /// The repository for wedding operations.
  final MyWeddingRepository _repository;

  /// The wedding ID for this cubit instance.
  final String weddingId;

  /// Loads all inspiration albums for this wedding.
  ///
  /// Emits loading state first, then the loaded albums or error.
  Future<void> loadAlbums() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.getInspirationAlbums(weddingId: weddingId);

    if (result.isSuccess) {
      emit(state.copyWith(
        isLoading: false,
        albums: result.data ?? [],
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to load albums',
      ));
    }
  }

  /// Creates a new inspiration album.
  ///
  /// On success, adds the new album to the list.
  /// On failure, emits an error state.
  Future<void> createAlbum({
    required String name,
    String? category,
    bool isPrivate = false,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.createInspirationAlbum(
      weddingId: weddingId,
      name: name,
      category: category,
      isPrivate: isPrivate,
    );

    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        isLoading: false,
        albums: [...state.albums, result.data!],
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to create album',
      ));
    }
  }

  /// Selects an album and loads its content.
  ///
  /// Loads both album images and saved posts in parallel.
  Future<void> selectAlbum(InspirationAlbum album) async {
    emit(state.copyWith(
      selectedAlbum: album,
      isLoading: true,
      clearError: true,
      albumImages: const [],
      savedPosts: const [],
    ));

    // Fetch images and saved posts in parallel
    final imagesResultFuture = _repository.getAlbumImages(albumId: album.id);
    final postsResultFuture = _repository.getSavedPosts(albumId: album.id);

    final imagesResult = await imagesResultFuture;
    final postsResult = await postsResultFuture;

    emit(state.copyWith(
      isLoading: false,
      albumImages: imagesResult.isSuccess ? imagesResult.data ?? [] : [],
      savedPosts: postsResult.isSuccess ? postsResult.data ?? [] : [],
    ));
  }

  /// Deletes an album.
  ///
  /// On success, removes the album from the list.
  /// If the deleted album was selected, clears the selection.
  /// On failure, emits an error state.
  Future<void> deleteAlbum(String albumId) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.deleteInspirationAlbum(albumId: albumId);

    if (result.isSuccess) {
      final updatedAlbums = state.albums.where((a) => a.id != albumId).toList();
      final wasSelected = state.selectedAlbum?.id == albumId;

      emit(state.copyWith(
        isLoading: false,
        albums: updatedAlbums,
        clearSelectedAlbum: wasSelected,
        albumImages: wasSelected ? const [] : null,
        savedPosts: wasSelected ? const [] : null,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to delete album',
      ));
    }
  }

  /// Saves an image to an album.
  ///
  /// On success, refreshes the album content if the album is selected.
  /// On failure, emits an error state.
  Future<void> saveImageToAlbum({
    required String albumId,
    required String imageUrl,
    String? sourceProfileId,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.saveImageToAlbum(
      albumId: albumId,
      imageUrl: imageUrl,
      sourceProfileId: sourceProfileId,
    );

    if (result.isSuccess) {
      // Refresh the album content if this album is selected
      if (state.selectedAlbum?.id == albumId) {
        await _refreshAlbumContent(albumId);
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to save image',
      ));
    }
  }

  /// Removes a saved post.
  ///
  /// On success, refreshes the album content if an album is selected.
  /// On failure, emits an error state.
  Future<void> removeSavedPost(String savedPostId) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.removeSavedPost(savedPostId: savedPostId);

    if (result.isSuccess) {
      // Refresh the album content if an album is selected
      if (state.selectedAlbum != null) {
        await _refreshAlbumContent(state.selectedAlbum!.id);
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to remove saved post',
      ));
    }
  }

  /// Refreshes the content of the specified album.
  Future<void> _refreshAlbumContent(String albumId) async {
    final imagesResultFuture = _repository.getAlbumImages(albumId: albumId);
    final postsResultFuture = _repository.getSavedPosts(albumId: albumId);

    final imagesResult = await imagesResultFuture;
    final postsResult = await postsResultFuture;

    emit(state.copyWith(
      isLoading: false,
      albumImages: imagesResult.isSuccess
          ? imagesResult.data ?? state.albumImages
          : state.albumImages,
      savedPosts: postsResult.isSuccess
          ? postsResult.data ?? state.savedPosts
          : state.savedPosts,
    ));
  }

  /// Clears the current error state.
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Clears the current album selection.
  void clearSelection() {
    emit(state.copyWith(
      clearSelectedAlbum: true,
      albumImages: const [],
      savedPosts: const [],
    ));
  }
}
