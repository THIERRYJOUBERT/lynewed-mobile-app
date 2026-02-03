/// Magazine Selection State for MagazineSelectionCubit.
///
/// Defines the state for managing magazine photo selection and ordering.
library;

import 'package:flutter/foundation.dart';

import '../../domain/entities/magazine_selection.dart';

/// Represents a photo in the magazine with its display info.
@immutable
class MagazinePhoto {
  /// Creates a magazine photo.
  const MagazinePhoto({
    required this.selectionId,
    required this.mediaType,
    required this.mediaId,
    required this.position,
    required this.thumbnailUrl,
  });

  /// The ID of the magazine_selections row.
  final String selectionId;

  /// Type of media: 'album_image' or 'guest_media'.
  final String mediaType;

  /// The ID of the source media.
  final String mediaId;

  /// Position in the magazine (1-indexed).
  final int position;

  /// URL for displaying the thumbnail.
  final String thumbnailUrl;

  /// Creates from a MagazineSelection entity with thumbnail URL.
  factory MagazinePhoto.fromSelection(
    MagazineSelection selection,
    String thumbnailUrl,
  ) {
    return MagazinePhoto(
      selectionId: selection.id,
      mediaType: selection.mediaType,
      mediaId: selection.mediaId,
      position: selection.position,
      thumbnailUrl: thumbnailUrl,
    );
  }

  /// Creates a copy with updated position.
  MagazinePhoto copyWithPosition(int newPosition) {
    return MagazinePhoto(
      selectionId: selectionId,
      mediaType: mediaType,
      mediaId: mediaId,
      position: newPosition,
      thumbnailUrl: thumbnailUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MagazinePhoto && other.selectionId == selectionId;
  }

  @override
  int get hashCode => selectionId.hashCode;
}

/// State for the magazine selection Cubit.
@immutable
class MagazineSelectionState {
  /// Creates a magazine selection state.
  const MagazineSelectionState({
    this.photos = const [],
    this.isLoading = false,
    this.isReordering = false,
    this.errorMessage,
    this.successMessage,
    this.maxPhotos = MagazineSelection.maxPhotosCollector,
  });

  /// List of photos in the magazine, ordered by position.
  final List<MagazinePhoto> photos;

  /// Whether data is currently loading.
  final bool isLoading;

  /// Whether a reorder operation is in progress.
  final bool isReordering;

  /// Error message to display.
  final String? errorMessage;

  /// Success message to display (for toasts).
  final String? successMessage;

  /// Maximum photos allowed in this magazine format.
  final int maxPhotos;

  /// Returns the number of photos in the magazine.
  int get count => photos.length;

  /// Returns whether more photos can be added.
  bool get canAddMore => count < maxPhotos;

  /// Returns the number of photos that can still be added.
  int get availableSlots => maxPhotos - count;

  /// Returns whether the magazine can be previewed (has photos).
  bool get canPreview => count > 0;

  /// Returns whether the magazine is empty.
  bool get isEmpty => photos.isEmpty;

  /// Returns whether the magazine is full.
  bool get isFull => count >= maxPhotos;

  /// Creates a copy with updated values.
  MagazineSelectionState copyWith({
    List<MagazinePhoto>? photos,
    bool? isLoading,
    bool? isReordering,
    String? errorMessage,
    String? successMessage,
    int? maxPhotos,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return MagazineSelectionState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      isReordering: isReordering ?? this.isReordering,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      maxPhotos: maxPhotos ?? this.maxPhotos,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MagazineSelectionState &&
        listEquals(other.photos, photos) &&
        other.isLoading == isLoading &&
        other.isReordering == isReordering &&
        other.errorMessage == errorMessage &&
        other.successMessage == successMessage &&
        other.maxPhotos == maxPhotos;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(photos),
        isLoading,
        isReordering,
        errorMessage,
        successMessage,
        maxPhotos,
      );
}
