# Story S10: Implement Download Feature

## Description
En tant que **utilisateur**, je veux **telecharger mon reel en haute qualite**, afin de **le sauvegarder sur mon appareil et le partager sur les reseaux sociaux**.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Download reel in high quality

  Scenario: Download button is visible for ready reels
    Given a reel with status 'ready'
    When user views the reel detail page
    Then "Telecharger" button should be visible and prominent
    And it should indicate "Haute qualite (1080p)"

  Scenario: Download button hidden for non-ready reels
    Given a reel with status 'processing'
    When user views the reel detail page
    Then "Telecharger" button should NOT be visible
    And a processing indicator should be shown instead

  Scenario: Download starts successfully
    Given user taps "Telecharger"
    When download begins
    Then a progress indicator should appear
    And it should show download percentage
    And "Telecharger" button should be disabled during download

  Scenario: Save to device gallery
    Given download completes successfully
    When file is saved
    Then it should appear in device photo gallery/camera roll
    And a toast "Reel enregistre dans la galerie" should appear

  Scenario: Track download timestamp
    Given a successful download
    Then reels.downloaded_at should be updated to current timestamp
    And this should only happen on first download
    And status should optionally change to 'downloaded'

  Scenario: Handle network error gracefully
    Given download is in progress at 50%
    When network connection is lost
    Then download should pause with error message
    And "Reessayer" button should appear
    And retry should resume from where it stopped (if supported)

  Scenario: Handle storage permission (Android)
    Given user taps "Telecharger" on Android
    When storage permission is not granted
    Then permission request dialog should appear
    And download should start after permission granted
    And if denied, show "Permission requise pour sauvegarder"

  Scenario: Handle photo library permission (iOS)
    Given user taps "Telecharger" on iOS
    When photo library permission is not granted
    Then permission request should appear
    And download should proceed after permission granted

  Scenario: Download already completed reel
    Given a reel that was previously downloaded
    When user taps "Telecharger" again
    Then download should proceed normally
    And downloaded_at should NOT be updated again
    And no error should occur

  Scenario: File naming convention
    Given a successful download
    Then the file should be named "lynewed_reel_YYYYMMDD_HHMMSS.mp4"
    And be easily identifiable in gallery
```

## Fichiers Concernes

### A Creer
- `lib/features/reels/presentation/widgets/download_button.dart`
- `lib/features/reels/domain/usecases/download_reel.dart`
- `lib/features/reels/data/services/video_download_service.dart`
- `test/features/reels/domain/usecases/download_reel_test.dart`
- `test/features/reels/presentation/widgets/download_button_test.dart`

### A Modifier
- `lib/features/reels/presentation/pages/reel_detail_page.dart` - Add download button
- `lib/features/reels/data/repositories/reel_repository_impl.dart` - Add download tracking

## Notes Techniques

### Download Button Widget
```dart
// lib/features/reels/presentation/widgets/download_button.dart

class ReelDownloadButton extends ConsumerStatefulWidget {
  final String reelId;
  final String outputPath;

  const ReelDownloadButton({
    required this.reelId,
    required this.outputPath,
    super.key,
  });

  @override
  ConsumerState<ReelDownloadButton> createState() => _ReelDownloadButtonState();
}

class _ReelDownloadButtonState extends ConsumerState<ReelDownloadButton> {
  double _progress = 0;
  bool _isDownloading = false;
  String? _error;

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _error = null;
      _progress = 0;
    });

    try {
      final downloadUseCase = ref.read(downloadReelUseCaseProvider);

      await downloadUseCase.execute(
        reelId: widget.reelId,
        outputPath: widget.outputPath,
        onProgress: (progress) {
          setState(() => _progress = progress);
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reel enregistre dans la galerie')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDownloading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: _progress),
          const SizedBox(height: 8),
          Text('${(_progress * 100).toInt()}%'),
        ],
      );
    }

    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, style: TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _startDownload,
            child: const Text('Reessayer'),
          ),
        ],
      );
    }

    return ElevatedButton.icon(
      onPressed: _startDownload,
      icon: const Icon(Icons.download),
      label: const Text('Telecharger (1080p)'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }
}
```

### Download Use Case
```dart
// lib/features/reels/domain/usecases/download_reel.dart

class DownloadReelUseCase {
  final VideoDownloadService _downloadService;
  final ReelRepository _reelRepository;
  final StorageService _storageService;

  DownloadReelUseCase(
    this._downloadService,
    this._reelRepository,
    this._storageService,
  );

  Future<void> execute({
    required String reelId,
    required String outputPath,
    required void Function(double) onProgress,
  }) async {
    // 1. Request permissions
    final hasPermission = await _downloadService.requestPermissions();
    if (!hasPermission) {
      throw DownloadException('Permission denied');
    }

    // 2. Get signed URL for output file
    final signedUrl = await _storageService.getSignedUrl(
      bucket: 'wedding-media',
      path: outputPath,
      expiresIn: const Duration(hours: 1),
    );

    // 3. Generate filename
    final fileName = _generateFileName();

    // 4. Download file with progress
    final filePath = await _downloadService.downloadToGallery(
      url: signedUrl,
      fileName: fileName,
      onProgress: onProgress,
    );

    // 5. Update downloaded_at (only if not already set)
    await _reelRepository.markAsDownloaded(reelId);
  }

  String _generateFileName() {
    final now = DateTime.now();
    final formatted = '${now.year}${_pad(now.month)}${_pad(now.day)}_'
        '${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
    return 'lynewed_reel_$formatted.mp4';
  }

  String _pad(int value) => value.toString().padLeft(2, '0');
}

class DownloadException implements Exception {
  final String message;
  DownloadException(this.message);

  @override
  String toString() => message;
}
```

### Video Download Service
```dart
// lib/features/reels/data/services/video_download_service.dart

import 'package:permission_handler/permission_handler.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class VideoDownloadService {
  final Dio _dio;

  VideoDownloadService(this._dio);

  /// Request necessary permissions for saving to gallery
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ uses different permissions
      if (await Permission.photos.request().isGranted) {
        return true;
      }
      // Fallback for older Android
      return await Permission.storage.request().isGranted;
    } else if (Platform.isIOS) {
      return await Permission.photos.request().isGranted;
    }
    return false;
  }

  /// Download video and save to device gallery
  Future<String> downloadToGallery({
    required String url,
    required String fileName,
    required void Function(double) onProgress,
  }) async {
    // 1. Get temp directory
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/$fileName';

    // 2. Download to temp
    await _dio.download(
      url,
      tempPath,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress(received / total);
        }
      },
    );

    // 3. Save to gallery
    final success = await GallerySaver.saveVideo(tempPath);
    if (success != true) {
      throw DownloadException('Failed to save to gallery');
    }

    // 4. Clean up temp file
    final tempFile = File(tempPath);
    if (await tempFile.exists()) {
      await tempFile.delete();
    }

    return tempPath;
  }
}
```

### Repository Update Method
```dart
// In lib/features/reels/data/repositories/reel_repository_impl.dart

Future<void> markAsDownloaded(String reelId) async {
  // Only update if not already downloaded
  await _client
    .from('reels')
    .update({
      'downloaded_at': DateTime.now().toIso8601String(),
      'status': 'downloaded',
    })
    .eq('id', reelId)
    .is_('downloaded_at', null); // Only if not already set
}
```

### Dependencies to Add
```yaml
# pubspec.yaml
dependencies:
  dio: ^5.x.x
  gallery_saver: ^2.x.x
  permission_handler: ^11.x.x
  path_provider: ^2.x.x
```

## Definition of Done
- [ ] Criteres d'acceptance valides
- [ ] Tests unitaires DownloadReelUseCase
- [ ] Tests widget ReelDownloadButton
- [ ] Permission handling works (iOS + Android)
- [ ] Progress indicator shows during download
- [ ] File saved to device gallery
- [ ] Toast confirmation shown
- [ ] downloaded_at updated in database
- [ ] Network error handling with retry
- [ ] File naming convention correct
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (platform-specific permissions)

## Dependances
- S08: Output file must be generated and stored
- S07: Preview must be viewable (user sees preview before download)

## Stories Dependantes
- S11: Instagram handles (shown alongside download button for bride)
