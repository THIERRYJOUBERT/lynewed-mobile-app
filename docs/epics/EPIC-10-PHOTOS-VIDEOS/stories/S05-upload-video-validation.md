# Story S05: Implementer upload video avec validation

## Description
En tant que **bride ou guest**, je veux **uploader des videos depuis mon appareil avec validation de duree et taille**, afin de **conserver mes souvenirs video du mariage sans depasser les limites systeme**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a user on the media upload screen When the user selects a video of 5 minutes and 200MB Then the video should be accepted And a preview should be shown
- [ ] Given a user on the media upload screen When the user selects a video of 15 minutes Then the upload should be rejected And error message "Video must be 10 minutes or less" should be shown
- [ ] Given a user on the media upload screen When the user selects a video of 600MB Then the upload should be rejected And error message "Video must be 500MB or less" should be shown
- [ ] Given a user has selected a valid video When the upload starts Then a progress indicator should be visible And the percentage should update during upload
- [ ] Given a video is successfully uploaded When the upload completes Then a thumbnail should be generated automatically And the thumbnail should be stored in storage
- [ ] Given a user selecting a video file When the file is .mp4, .mov, or .m4v Then the file should be accepted
- [ ] Given a user selecting a video file When the file is .avi or .wmv Then the file should be rejected with format error
- [ ] Given a video upload in progress When network connection is lost Then user should see "Connection lost" message And retry option should be available
- [ ] Given a video file is selected When the app processes the file Then duration_seconds should be calculated And stored in the database

## Fichiers Concernes

### A Creer
- `lib/features/my_wedding/presentation/widgets/video_picker_widget.dart`
- `lib/core/utils/video_utils.dart` (validation, thumbnail generation)

### A Modifier
- `lib/features/my_wedding/domain/usecases/upload_media_use_case.dart` - Enrichir pour video
- `lib/features/my_wedding/presentation/pages/media_upload_page.dart` - Ajouter option video
- `lib/features/my_wedding/data/datasources/media_remote_data_source.dart` - Support video upload

## Notes Techniques

### Dependance Flutter requise
```yaml
# pubspec.yaml
dependencies:
  video_compress: ^3.1.2  # Pour compression et thumbnail
  # Note: image_picker supporte deja video
```

### VideoUtils - Validation et Thumbnail
```dart
// lib/core/utils/video_utils.dart
import 'dart:io';
import 'package:video_compress/video_compress.dart';

class VideoUtils {
  static const int maxDurationSeconds = 600; // 10 minutes
  static const int maxFileSizeBytes = 524288000; // 500MB
  static const List<String> supportedFormats = ['mp4', 'mov', 'm4v'];

  /// Validates video file before upload
  /// Returns null if valid, error message if invalid
  static Future<String?> validateVideo(File videoFile) async {
    // Check file extension
    final extension = videoFile.path.split('.').last.toLowerCase();
    if (!supportedFormats.contains(extension)) {
      return 'Format not supported. Use MP4, MOV, or M4V.';
    }

    // Check file size
    final fileSize = await videoFile.length();
    if (fileSize > maxFileSizeBytes) {
      return 'Video must be 500MB or less';
    }

    // Check duration
    final mediaInfo = await VideoCompress.getMediaInfo(videoFile.path);
    final durationSeconds = (mediaInfo.duration ?? 0) ~/ 1000;
    if (durationSeconds > maxDurationSeconds) {
      return 'Video must be 10 minutes or less';
    }

    return null; // Valid
  }

  /// Extracts duration in seconds from video file
  static Future<int> getDurationSeconds(File videoFile) async {
    final mediaInfo = await VideoCompress.getMediaInfo(videoFile.path);
    return (mediaInfo.duration ?? 0) ~/ 1000;
  }

  /// Generates thumbnail for video
  static Future<File?> generateThumbnail(File videoFile) async {
    final thumbnail = await VideoCompress.getFileThumbnail(
      videoFile.path,
      quality: 80,
      position: 1, // 1 second into video
    );
    return thumbnail;
  }
}
```

### VideoPickerWidget
```dart
// lib/features/my_wedding/presentation/widgets/video_picker_widget.dart
class VideoPickerWidget extends StatefulWidget {
  final Function(File video, File thumbnail, int durationSeconds) onVideoSelected;
  final Function(String error) onError;

  // ... implementation
}
```

### Limites a respecter (PRD Section 6)
| Parametre | Limite |
|-----------|--------|
| Duree max | 10 minutes (600 secondes) |
| Taille max | 500 MB |
| Formats | .mp4, .mov, .m4v |
| Duree max pour reel | 2 minutes par video |

### Flow Upload Video
```
1. User selects video from gallery
2. VideoUtils.validateVideo() checks format, size, duration
3. If invalid → show error message
4. If valid → generate thumbnail
5. Upload video + thumbnail to Supabase Storage
6. Insert record in album_images/guest_media with:
   - media_type = 'video'
   - duration_seconds = extracted duration
   - file_size_bytes = file size
   - thumbnail_path = thumbnail URL
7. Show success feedback
```

## Definition of Done
- [ ] VideoUtils cree avec validation complete
- [ ] VideoPickerWidget fonctionnel
- [ ] Validation duree (max 10 min) testee
- [ ] Validation taille (max 500 MB) testee
- [ ] Validation format (.mp4, .mov, .m4v) testee
- [ ] Thumbnail generation fonctionnelle
- [ ] Progress indicator pendant upload
- [ ] Gestion erreur reseau avec retry
- [ ] Tests unitaires pour VideoUtils
- [ ] `flutter analyze --fatal-infos` passe
- [ ] `flutter test` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (dependance video_compress, gestion fichiers volumineux)

## Dependances
- S01 (album_images enrichie avec media_type, duration_seconds, etc.)
- EPIC-06 (bucket wedding-media)

## Stories Dependantes
- S06 (Legende) - peut ajouter legende a la video uploadee
- S09 (Telechargement) - peut telecharger les videos
