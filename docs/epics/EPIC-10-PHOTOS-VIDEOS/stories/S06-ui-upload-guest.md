# Story S06: UI Upload guest (GuestAlbumPage)

> **Creation 2026-02-03** : Story pour le flow d'upload complet des guests.

## Description
En tant que **guest invite a un mariage**, je veux **uploader des photos et videos dans mon album personnel depuis mon telephone**, afin de **partager mes souvenirs du mariage avec la mariee automatiquement**.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Guest uploads media to personal album

  Background:
    Given I am logged in as a guest
    And I have been invited to wedding "wedding-456"

  Scenario: Uploading first photo auto-creates album
    Given I have no album for wedding "wedding-456"
    When I tap the FAB "+" button on GuestAlbumPage
    And I select a photo from my gallery
    Then my album should be auto-created in guest_albums
    And the photo should be uploaded to guest_media
    And the photo should appear in my album grid
    And a success toast "Photo uploaded" should appear

  Scenario: Uploading photo with caption
    Given I am on the upload preview screen
    When I add a caption "Best moment of the day!"
    And I tap "Upload"
    Then the photo should be uploaded with the caption
    And the caption should be visible when viewing the photo

  Scenario: Uploading video with constraints validation
    Given I select a video from my gallery
    When the video duration is 15 minutes (over 10 min limit)
    Then an error message should appear "Video must be under 10 minutes"
    And the upload should be blocked

  Scenario: Upload progress indicator
    Given I select a large file (50MB photo)
    When the upload is in progress
    Then a progress indicator should show percentage (0-100%)
    And I should be able to see the upload progressing

  Scenario: Viewing my media grid
    Given I have uploaded 3 photos and 1 video
    When I view my GuestAlbumPage
    Then I should see a 3-column grid with 4 items
    And the video should show a play icon overlay
    And photos should show thumbnail previews

  Scenario: Delete my own media
    Given I have a photo in my album
    When I long-press on the photo
    Then I should see a "Delete" option
    And tapping "Delete" should remove the photo from my album
```

## Fichiers Concernes

### A Creer
- `lib/features/guest/domain/usecases/upload_guest_media_use_case.dart`
- `lib/features/guest/domain/usecases/create_guest_album_use_case.dart`
- `lib/features/guest/domain/entities/guest_media.dart`
- `lib/features/guest/data/models/guest_media_model.dart`
- `lib/features/guest/data/repositories/guest_album_repository.dart`
- `lib/features/guest/data/repositories/guest_album_repository_impl.dart`
- `lib/features/guest/presentation/widgets/guest_media_grid.dart`
- `lib/features/guest/presentation/widgets/guest_media_tile.dart`
- `lib/features/guest/presentation/widgets/upload_preview_sheet.dart`
- `test/features/guest/domain/usecases/upload_guest_media_use_case_test.dart`
- `test/features/guest/presentation/pages/guest_album_page_test.dart`

### A Modifier
- `lib/features/guest/presentation/pages/guest_album_page.dart` - Implementer grille + FAB fonctionnel

## Notes Techniques

### GuestMedia Entity
```dart
// lib/features/guest/domain/entities/guest_media.dart
import 'package:equatable/equatable.dart';

/// Represents a media file (photo/video) uploaded by a guest.
class GuestMedia extends Equatable {
  final String id;
  final String albumId;
  final String mediaType; // 'photo' or 'video'
  final String storagePath;
  final String? thumbnailPath;
  final String? caption;
  final int? durationSeconds; // For videos only
  final int? fileSizeBytes;
  final DateTime createdAt;

  const GuestMedia({
    required this.id,
    required this.albumId,
    required this.mediaType,
    required this.storagePath,
    this.thumbnailPath,
    this.caption,
    this.durationSeconds,
    this.fileSizeBytes,
    required this.createdAt,
  });

  bool get isVideo => mediaType == 'video';
  bool get isPhoto => mediaType == 'photo';

  /// Full storage URL (constructed from path)
  String getFullUrl(String bucketBaseUrl) {
    return '$bucketBaseUrl/$storagePath';
  }

  @override
  List<Object?> get props => [id, albumId, mediaType, storagePath];
}
```

### GuestMediaModel
```dart
// lib/features/guest/data/models/guest_media_model.dart
import '../../domain/entities/guest_media.dart';

class GuestMediaModel extends GuestMedia {
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

  Map<String, dynamic> toJson() {
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
```

### UploadGuestMediaUseCase
```dart
// lib/features/guest/domain/usecases/upload_guest_media_use_case.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '/core/errors/failure.dart';
import '../repositories/guest_album_repository.dart';

/// Use case to upload a media file to the guest's album.
///
/// Handles:
/// - Auto-creating album if first upload
/// - Validating file constraints (size, duration)
/// - Uploading to storage
/// - Creating database record
class UploadGuestMediaUseCase {
  final GuestAlbumRepository repository;

  const UploadGuestMediaUseCase(this.repository);

  /// Uploads a media file to the guest's album.
  ///
  /// - [file]: The local file to upload
  /// - [weddingId]: The wedding this media belongs to
  /// - [mediaType]: 'photo' or 'video'
  /// - [caption]: Optional caption (max 500 chars)
  /// - [durationSeconds]: Video duration (for validation)
  /// - [onProgress]: Upload progress callback (0.0 to 1.0)
  Future<Either<Failure, String>> call({
    required File file,
    required String weddingId,
    required String mediaType,
    String? caption,
    int? durationSeconds,
    Function(double)? onProgress,
  }) async {
    // Validate constraints
    final validationError = _validateConstraints(
      file: file,
      mediaType: mediaType,
      caption: caption,
      durationSeconds: durationSeconds,
    );
    if (validationError != null) {
      return Left(ValidationFailure(message: validationError));
    }

    // Upload to repository (handles album auto-creation)
    return repository.uploadMedia(
      file: file,
      weddingId: weddingId,
      mediaType: mediaType,
      caption: caption,
      durationSeconds: durationSeconds,
      onProgress: onProgress,
    );
  }

  String? _validateConstraints({
    required File file,
    required String mediaType,
    String? caption,
    int? durationSeconds,
  }) {
    final fileSizeBytes = file.lengthSync();

    // Caption max 500 chars
    if (caption != null && caption.length > 500) {
      return 'Caption must be under 500 characters';
    }

    // Video constraints
    if (mediaType == 'video') {
      // Max duration 10 minutes (600 seconds)
      if (durationSeconds != null && durationSeconds > 600) {
        return 'Video must be under 10 minutes';
      }
      // Max size 500MB
      if (fileSizeBytes > 524288000) {
        return 'Video must be under 500MB';
      }
    }

    // Photo constraints
    if (mediaType == 'photo') {
      // Max size 20MB
      if (fileSizeBytes > 20971520) {
        return 'Photo must be under 20MB';
      }
    }

    return null;
  }
}
```

### GuestAlbumPage Implementation
```dart
// lib/features/guest/presentation/pages/guest_album_page.dart
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import '/core/design/design.dart';
import '../../domain/entities/guest_media.dart';
import '../../data/repositories/guest_album_repository_impl.dart';

/// Album page for guests.
///
/// Shows the guest's personal album with photos and videos.
/// Includes FAB for uploading new media.
class GuestAlbumPage extends StatefulWidget {
  const GuestAlbumPage({
    super.key,
    required this.weddingId,
  });

  final String weddingId;

  @override
  State<GuestAlbumPage> createState() => _GuestAlbumPageState();
}

class _GuestAlbumPageState extends State<GuestAlbumPage> {
  final _imagePicker = ImagePicker();

  bool _isLoading = true;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;
  List<GuestMedia> _media = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadMedia();
    });
  }

  Future<void> _loadMedia() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repository = GuestAlbumRepositoryImpl();
    final result = await repository.getMyMedia(weddingId: widget.weddingId);

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _isLoading = false;
      }),
      (media) => setState(() {
        _media = media;
        _isLoading = false;
      }),
    );
  }

  Future<void> _pickAndUploadMedia() async {
    // Show picker options (photo or video)
    final result = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => _MediaPickerSheet(
        onPickPhoto: () => _pickMedia(ImageSource.gallery, isVideo: false),
        onPickVideo: () => _pickMedia(ImageSource.gallery, isVideo: true),
        onTakePhoto: () => _pickMedia(ImageSource.camera, isVideo: false),
        onTakeVideo: () => _pickMedia(ImageSource.camera, isVideo: true),
      ),
    );

    if (result == null) return;

    // Show upload preview with caption input
    final confirmed = await _showUploadPreview(File(result.path));
    if (confirmed != true) return;

    // Upload the file
    await _uploadFile(File(result.path));
  }

  Future<XFile?> _pickMedia(ImageSource source, {required bool isVideo}) async {
    Navigator.pop(context); // Close picker sheet

    if (isVideo) {
      return _imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 10),
      );
    } else {
      return _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
    }
  }

  Future<bool?> _showUploadPreview(File file) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => UploadPreviewSheet(
        file: file,
        onConfirm: (caption) {
          Navigator.pop(context, true);
          // Caption will be used in _uploadFile
        },
        onCancel: () => Navigator.pop(context, false),
      ),
    );
  }

  Future<void> _uploadFile(File file) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    final repository = GuestAlbumRepositoryImpl();
    final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
                    file.path.toLowerCase().endsWith('.mov');

    final result = await repository.uploadMedia(
      file: file,
      weddingId: widget.weddingId,
      mediaType: isVideo ? 'video' : 'photo',
      onProgress: (progress) {
        if (mounted) {
          setState(() => _uploadProgress = progress);
        }
      },
    );

    if (!mounted) return;

    setState(() => _isUploading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: LynewedColors.error,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isVideo ? 'Video uploaded' : 'Photo uploaded'),
            backgroundColor: LynewedColors.success,
          ),
        );
        _loadMedia(); // Refresh the grid
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: LynewedColors.error),
            const SizedBox(height: 16),
            Text(_error!, style: LynewedTextStyles.bodyMedium),
            const SizedBox(height: 24),
            LynewedButton(
              text: 'Retry',
              onPressed: _loadMedia,
              type: LynewedButtonType.secondary,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Content (grid or empty state)
        if (_media.isEmpty)
          _buildEmptyState()
        else
          RefreshIndicator(
            onRefresh: _loadMedia,
            color: LynewedColors.primary,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _media.length,
              itemBuilder: (context, index) {
                return GuestMediaTile(
                  media: _media[index],
                  onTap: () => _viewMedia(_media[index]),
                  onLongPress: () => _showMediaOptions(_media[index]),
                );
              },
            ),
          ),

        // FAB for adding photos
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _isUploading ? null : _pickAndUploadMedia,
            backgroundColor: _isUploading
                ? LynewedColors.gray300
                : LynewedColors.primary,
            child: _isUploading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: _uploadProgress,
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        LynewedColors.background,
                      ),
                    ),
                  )
                : const Icon(Icons.add, color: LynewedColors.background),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: LynewedColors.gray300,
          ),
          SizedBox(height: LynewedSpacing.lg),
          Text(
            'Your Wedding Memories',
            style: LynewedTextStyles.titleSmall.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
          SizedBox(height: LynewedSpacing.sm),
          Text(
            'Tap the + button to add\nphotos and videos',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _viewMedia(GuestMedia media) {
    // Navigate to full screen viewer
    // TODO: Implement in a future iteration
  }

  void _showMediaOptions(GuestMedia media) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: LynewedColors.error),
              title: const Text('Delete', style: TextStyle(color: LynewedColors.error)),
              onTap: () {
                Navigator.pop(context);
                _deleteMedia(media);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMedia(GuestMedia media) async {
    final repository = GuestAlbumRepositoryImpl();
    final result = await repository.deleteMedia(mediaId: media.id);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: LynewedColors.error,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Media deleted'),
            backgroundColor: LynewedColors.success,
          ),
        );
        _loadMedia();
      },
    );
  }
}

// Helper widgets defined inline for now, will be extracted to separate files

class _MediaPickerSheet extends StatelessWidget {
  const _MediaPickerSheet({
    required this.onPickPhoto,
    required this.onPickVideo,
    required this.onTakePhoto,
    required this.onTakeVideo,
  });

  final VoidCallback onPickPhoto;
  final VoidCallback onPickVideo;
  final VoidCallback onTakePhoto;
  final VoidCallback onTakeVideo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose Photo from Gallery'),
            onTap: onPickPhoto,
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('Choose Video from Gallery'),
            onTap: onPickVideo,
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: onTakePhoto,
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Record Video'),
            onTap: onTakeVideo,
          ),
        ],
      ),
    );
  }
}

class UploadPreviewSheet extends StatelessWidget {
  const UploadPreviewSheet({
    super.key,
    required this.file,
    required this.onConfirm,
    required this.onCancel,
  });

  final File file;
  final Function(String?) onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement preview with CaptionInputWidget
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Upload Preview'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => onConfirm(null),
                child: const Text('Upload'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GuestMediaTile extends StatelessWidget {
  const GuestMediaTile({
    super.key,
    required this.media,
    required this.onTap,
    required this.onLongPress,
  });

  final GuestMedia media;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement proper thumbnail display
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color: LynewedColors.gray200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Icon(Icons.image, color: LynewedColors.gray300),
            if (media.isVideo)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

### Storage Path Convention
```
wedding-albums/{wedding_id}/guests/{guest_user_id}/{filename}
```

## Definition of Done
- [ ] GuestMedia entity cree avec tous les champs
- [ ] GuestMediaModel avec fromJson/toJson
- [ ] UploadGuestMediaUseCase avec validation des contraintes
- [ ] GuestAlbumPage implemente avec grille de medias
- [ ] FAB fonctionnel pour upload (photo + video)
- [ ] Media picker sheet (gallery/camera)
- [ ] Upload preview avec caption input (utilise CaptionInputWidget)
- [ ] Progress indicator pendant upload
- [ ] Auto-creation album si premier upload
- [ ] Delete media fonctionnel (long-press)
- [ ] Video play icon overlay sur thumbnails
- [ ] Validation contraintes (10 min video, 500MB, 20MB photo)
- [ ] Empty state pour album vide
- [ ] Tests unitaires pour use case
- [ ] Tests widget pour GuestAlbumPage
- [ ] `flutter analyze --fatal-infos` passe (0 warnings)
- [ ] `flutter test` passe

## Estimation
**Points** : 5
**Complexite** : Medium
**Risque** : Moyen (upload, validation, auto-creation album)

## Dependances
- S02 (table guest_albums)
- S03 (table guest_media)
- S05 (CaptionInputWidget)

## Stories Dependantes
- S07 (Vue bride albums guests - affichera les medias uploades par les guests)
- S08 (Download media - permettra de telecharger ces medias)

---

## Historique des Revisions

| Date | Changement |
|------|------------|
| 2026-02-03 | Creation initiale. Story pour l'upload complet des guests. |
