# Story S04: UI Upload Media - Bride (Video Support)

## Description

En tant que **mariee (bride)**, je veux **pouvoir uploader des videos en plus des photos dans mes albums d'inspiration**, afin de **conserver des references visuelles riches pour mon mariage (videos de lieux, ambiances, etc.)**.

## Priorite

**Medium** - Feature essentielle pour enrichir l'experience galerie.

## Estimation

**Points** : 5
**Complexite** : M (Medium)
**Risque** : Moyen (validation video, upload gros fichiers)

## Dependances

| Dependance | Type | Description |
|------------|------|-------------|
| S01 | Prerequis | `album_images` doit avoir les colonnes `media_type`, `caption`, `duration_seconds`, `file_size_bytes` |

## Criteres d'Acceptance (Gherkin)

### Scenario 1: Selecting a valid video

```gherkin
Given I am on the AlbumDetailPage
And I tap the add media button
When I select a video from my gallery
And the video is mp4, mov, or m4v format
And the video duration is <= 10 minutes
And the video file size is <= 500 MB
Then the video should start uploading
And a progress indicator should be displayed
```

- [ ] AC-1.1: Support video selection via ImagePicker (video source)
- [ ] AC-1.2: Accept formats: mp4, mov, m4v
- [ ] AC-1.3: Validate duration <= 600 seconds (10 minutes)
- [ ] AC-1.4: Validate file size <= 500 MB (524,288,000 bytes)

### Scenario 2: Rejecting video too long (>10min)

```gherkin
Given I am on the AlbumDetailPage
When I select a video longer than 10 minutes
Then the upload should be rejected
And I should see an error message "Video must be 10 minutes or less"
And the video should not be uploaded
```

- [ ] AC-2.1: Detect video duration before upload
- [ ] AC-2.2: Display clear error message via SnackBar
- [ ] AC-2.3: No partial upload or storage usage

### Scenario 3: Rejecting video too large (>500MB)

```gherkin
Given I am on the AlbumDetailPage
When I select a video larger than 500 MB
Then the upload should be rejected
And I should see an error message "Video must be 500 MB or less"
And the video should not be uploaded
```

- [ ] AC-3.1: Check file size before upload
- [ ] AC-3.2: Display clear error message via SnackBar
- [ ] AC-3.3: No partial upload

### Scenario 4: Upload with progress indicator

```gherkin
Given I am uploading a valid video
When the upload is in progress
Then I should see a circular progress indicator
And I should see the upload percentage (0-100%)
When the upload completes
Then the video should appear in the grid
And the progress indicator should disappear
```

- [ ] AC-4.1: Progress indicator visible during upload
- [ ] AC-4.2: Upload progress percentage displayed
- [ ] AC-4.3: Grid updates after successful upload

### Scenario 5: Thumbnail generation for video

```gherkin
Given I have successfully uploaded a video
When the video is displayed in the album grid
Then a thumbnail image should be shown
And a video indicator icon should overlay the thumbnail
```

- [ ] AC-5.1: Generate thumbnail from first frame of video
- [ ] AC-5.2: Store thumbnail URL in album_images.thumbnail_url
- [ ] AC-5.3: Display play icon overlay on video thumbnails in grid

### Scenario 6: Media type selection dialog

```gherkin
Given I am on the AlbumDetailPage
When I tap the add media button
Then I should see a choice dialog with "Photo" and "Video" options
When I select "Video"
Then the video picker should open
```

- [ ] AC-6.1: Show LynewedSheet with media type choices
- [ ] AC-6.2: Photo option uses existing ImagePicker.pickImage
- [ ] AC-6.3: Video option uses ImagePicker.pickVideo

## Fichiers Concernes

### A Modifier

| Fichier | Modifications |
|---------|---------------|
| `lib/features/my_wedding/presentation/pages/album_detail_page.dart` | Ajouter support video, progress, validation |
| `lib/features/my_wedding/domain/entities/album_image.dart` | Ajouter `mediaType`, `caption`, `durationSeconds`, `fileSizeBytes` |
| `lib/features/my_wedding/domain/repositories/my_wedding_repository.dart` | Update `uploadAlbumImage` signature |
| `lib/features/my_wedding/data/repositories/my_wedding_repository_impl.dart` | Implementer upload avec nouveaux champs |

### A Creer

| Fichier | Description |
|---------|-------------|
| `lib/features/my_wedding/presentation/widgets/media_picker_sheet.dart` | Sheet de selection Photo/Video |
| `lib/features/my_wedding/presentation/widgets/upload_progress_indicator.dart` | Widget progress avec pourcentage |
| `lib/core/utils/video_utils.dart` | Helpers validation/thumbnail video |
| `test/features/my_wedding/presentation/pages/album_detail_page_video_test.dart` | Tests video upload |
| `test/core/utils/video_utils_test.dart` | Tests validation video |

## Implementation Technique

### 1. AlbumImage Entity (mise a jour)

```dart
/// Album Image entity - supports photos and videos
@immutable
class AlbumImage {
  const AlbumImage({
    required this.id,
    required this.albumId,
    required this.imageUrl,
    this.thumbnailUrl,
    this.uploadedAt,
    this.mediaType = 'photo',
    this.caption,
    this.durationSeconds,
    this.fileSizeBytes,
  });

  final String id;
  final String albumId;
  final String imageUrl;
  final String? thumbnailUrl;
  final DateTime? uploadedAt;
  final String mediaType; // 'photo' or 'video'
  final String? caption;
  final int? durationSeconds;
  final int? fileSizeBytes;

  bool get isVideo => mediaType == 'video';
  bool get isPhoto => mediaType == 'photo';

  factory AlbumImage.fromJson(Map<String, dynamic> json) {
    return AlbumImage(
      id: json['id'] as String,
      albumId: json['album_id'] as String,
      imageUrl: json['image_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'] as String)
          : null,
      mediaType: json['media_type'] as String? ?? 'photo',
      caption: json['caption'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      fileSizeBytes: json['file_size_bytes'] as int?,
    );
  }
}
```

### 2. Video Validation Utils

```dart
/// Video validation constants and helpers
class VideoConstants {
  static const int maxDurationSeconds = 600; // 10 minutes
  static const int maxFileSizeBytes = 524288000; // 500 MB
  static const List<String> allowedExtensions = ['mp4', 'mov', 'm4v'];
}

/// Result of video validation
class VideoValidationResult {
  final bool isValid;
  final String? error;
  final int? durationSeconds;
  final int? fileSizeBytes;

  const VideoValidationResult.valid({
    required this.durationSeconds,
    required this.fileSizeBytes,
  }) : isValid = true, error = null;

  const VideoValidationResult.invalid(this.error)
    : isValid = false, durationSeconds = null, fileSizeBytes = null;
}

/// Validate video file before upload
Future<VideoValidationResult> validateVideo(File file) async {
  // Check file size
  final fileSize = await file.length();
  if (fileSize > VideoConstants.maxFileSizeBytes) {
    return const VideoValidationResult.invalid(
      'Video must be 500 MB or less',
    );
  }

  // Check duration (requires video_player or ffmpeg)
  final duration = await _getVideoDuration(file);
  if (duration > VideoConstants.maxDurationSeconds) {
    return const VideoValidationResult.invalid(
      'Video must be 10 minutes or less',
    );
  }

  return VideoValidationResult.valid(
    durationSeconds: duration,
    fileSizeBytes: fileSize,
  );
}
```

### 3. Media Picker Sheet

```dart
/// Sheet for selecting media type (Photo or Video)
class MediaPickerSheet extends StatelessWidget {
  final VoidCallback onPhotoSelected;
  final VoidCallback onVideoSelected;

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: 'Add Media',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            icon: Icons.photo_camera_outlined,
            label: 'Photo',
            subtitle: 'Upload from gallery',
            onTap: () {
              Navigator.pop(context);
              onPhotoSelected();
            },
          ),
          const SizedBox(height: 12),
          _buildOption(
            icon: Icons.videocam_outlined,
            label: 'Video',
            subtitle: 'Max 10 min, 500 MB',
            onTap: () {
              Navigator.pop(context);
              onVideoSelected();
            },
          ),
        ],
      ),
    );
  }
}
```

### 4. Upload Progress Widget

```dart
/// Circular progress indicator with percentage
class UploadProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: progress,
          strokeWidth: 3,
          valueColor: const AlwaysStoppedAnimation<Color>(
            LynewedColors.primary,
          ),
          backgroundColor: LynewedColors.gray200,
        ),
        Text(
          '${(progress * 100).toInt()}%',
          style: LynewedTextStyles.labelSmall.copyWith(
            color: LynewedColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
```

### 5. Video Grid Tile avec Play Icon

```dart
Widget _buildMediaTile(AlbumImage media) {
  return GestureDetector(
    onTap: () => _viewMedia(media),
    child: Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: media.thumbnailUrl ?? media.imageUrl,
          fit: BoxFit.cover,
        ),
        if (media.isVideo)
          Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
      ],
    ),
  );
}
```

### 6. Repository Update

```dart
/// Upload media (photo or video) to an album
Future<RepositoryResult<AlbumImage>> uploadAlbumMedia({
  required String albumId,
  required String mediaUrl,
  required String mediaType, // 'photo' or 'video'
  String? thumbnailUrl,
  String? caption,
  int? durationSeconds,
  int? fileSizeBytes,
});
```

## Dependencies Package

Ajouter au `pubspec.yaml` si necessaire :

```yaml
dependencies:
  video_thumbnail: ^0.5.3  # Pour generer thumbnails
  # ou
  video_compress: ^3.1.2   # Alternative avec compression
```

**Note**: `image_picker` supporte deja les videos nativement.

## Storage Path Convention

```
wedding-albums/{wedding_id}/bride/{media_type}_{timestamp}.{ext}
```

Exemples:
- `wedding-albums/abc123/bride/photo_1706500000000.jpg`
- `wedding-albums/abc123/bride/video_1706500000000.mp4`

## UI/UX Reference

| Element | Reference |
|---------|-----------|
| Grid layout | `album_detail_page.dart` existant |
| Sheet style | `LynewedSheet` de design.dart |
| Button style | `LynewedButton` de design.dart |
| Progress | `CircularProgressIndicator` avec value |
| Error display | SnackBar avec `LynewedColors.error` |

## Error Messages (English)

| Situation | Message |
|-----------|---------|
| Video too long | "Video must be 10 minutes or less" |
| Video too large | "Video must be 500 MB or less" |
| Invalid format | "Please select an MP4, MOV, or M4V video" |
| Upload failed | "Failed to upload video" |
| Thumbnail failed | "Video uploaded but thumbnail generation failed" |

## Tests a Implementer

### Unit Tests (`video_utils_test.dart`)

```dart
group('VideoValidation', () {
  test('rejects video over 10 minutes');
  test('rejects video over 500MB');
  test('accepts valid video under limits');
  test('validates mp4 extension');
  test('validates mov extension');
  test('validates m4v extension');
  test('rejects invalid extension');
});
```

### Widget Tests (`album_detail_page_video_test.dart`)

```dart
group('AlbumDetailPage Video', () {
  testWidgets('shows media picker sheet on add tap');
  testWidgets('shows progress indicator during upload');
  testWidgets('displays error snackbar for oversized video');
  testWidgets('displays error snackbar for too long video');
  testWidgets('shows play icon on video thumbnails');
  testWidgets('updates grid after successful video upload');
});
```

## Definition of Done

- [ ] Media picker sheet avec choix Photo/Video
- [ ] Validation video: duree <= 10 min
- [ ] Validation video: taille <= 500 MB
- [ ] Formats supportes: mp4, mov, m4v
- [ ] Progress indicator avec pourcentage pendant upload
- [ ] Thumbnail generation pour videos
- [ ] Play icon overlay sur videos dans la grille
- [ ] AlbumImage entity mise a jour avec nouveaux champs
- [ ] Repository uploadAlbumMedia implementee
- [ ] Messages d'erreur clairs en anglais
- [ ] Tests unitaires video validation
- [ ] Tests widget album detail page
- [ ] `flutter analyze --fatal-infos` = 0 warnings
- [ ] `flutter test` tous les tests passent

## Notes Techniques

### Thumbnail Generation

Option 1 - Package `video_thumbnail`:
```dart
final thumbnail = await VideoThumbnail.thumbnailFile(
  video: videoPath,
  imageFormat: ImageFormat.JPEG,
  maxWidth: 512,
  quality: 75,
);
```

Option 2 - Si probleme de performance, utiliser placeholder et generer thumbnail cote serveur (Edge Function).

### Upload Progress avec Supabase

```dart
// Supabase ne supporte pas nativement le progress callback
// Utiliser un chunked upload ou afficher un indicateur indetermine
// Pour V1: utiliser CircularProgressIndicator indetermine
```

### Platform Specifics

- **iOS**: Necessite `NSPhotoLibraryUsageDescription` dans Info.plist (deja present)
- **Android**: Necessite `READ_EXTERNAL_STORAGE` permission (deja present)

## Rollback Plan

En cas de probleme:
1. Revenir a l'upload photo uniquement
2. Les colonnes DB restent (compatibles avec valeurs null)
3. Pas d'impact sur les photos existantes
