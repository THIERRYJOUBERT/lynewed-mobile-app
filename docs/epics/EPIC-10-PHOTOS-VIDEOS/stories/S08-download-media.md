# Story S08: Download media (single + multiple)

## Description
En tant que **bride ou guest**, je veux **telecharger mes photos et videos en haute qualite, avec zip automatique pour les selections multiples**, afin de **conserver mes souvenirs sur mon appareil sans perte de qualite**.

## Criteres d'Acceptance (Gherkin)

### Scenario: Download single photo
- [x] Given a user is viewing a photo in full screen When the user taps the download icon Then the original high-quality photo should be downloaded to device And a success toast "Photo downloaded" should appear

### Scenario: Download single video
- [x] Given a user is viewing a video in full screen When the user taps the download icon Then the original video file should be downloaded to device And a success toast "Video downloaded" should appear

### Scenario: Download multiple files (zip)
- [x] Given a bride has selected 5 photos via long-press selection mode When the bride taps "Download Selected" Then a progress dialog should appear with "Downloading files..." And files should be downloaded to a folder And success toast "X files downloaded" should appear

### Scenario: Progress indicator during download
- [x] Given a user downloads a 100MB video When download is in progress Then a circular progress indicator should show percentage (0-100%) And the percentage text should update in real-time

### Scenario: Download failure handling with retry
- [x] Given a download is in progress When the network connection fails Then an error dialog should appear with message "Download failed" And a "Retry" button should be available And tapping "Retry" should restart the download

## Scope Access

| Role | Own Album | Bride Albums | Guest Albums |
|------|-----------|--------------|--------------|
| Bride | Download OK | N/A | Download OK (if shared) |
| Guest | Download OK | N/A | N/A (only own) |

**Note**: Bride can download from her own albums AND from guest albums that are shared with her. Guest can only download from their own album.

## Fichiers Concernes

### A Creer
- `lib/features/my_wedding/domain/usecases/download_media_use_case.dart`
- `lib/features/my_wedding/presentation/widgets/download_button.dart`
- `lib/features/my_wedding/presentation/widgets/download_progress_dialog.dart`
- `lib/core/utils/download_utils.dart`

### A Modifier
- `lib/features/my_wedding/presentation/pages/media_detail_page.dart` - Ajouter bouton download
- `lib/features/my_wedding/presentation/pages/album_detail_page.dart` - Ajouter selection multiple + download
- `lib/features/guest/presentation/pages/guest_album_page.dart` - Ajouter download pour guests

### Edge Function (Optionnelle - recommandee pour gros fichiers)
- `supabase/functions/create-media-zip/index.ts`

## Notes Techniques

### DownloadMediaUseCase
```dart
// lib/features/my_wedding/domain/usecases/download_media_use_case.dart
import 'dart:io';
import 'package:dartz/dartz.dart';

class DownloadMediaUseCase {
  final MediaRepository repository;

  DownloadMediaUseCase(this.repository);

  /// Download a single media file
  Future<Either<Failure, File>> downloadSingle({
    required String storageUrl,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    return repository.downloadFile(
      storageUrl: storageUrl,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  /// Download multiple media as zip
  /// For small batches (< 10 files, < 50MB total): client-side zip
  /// For larger batches: use Edge Function
  Future<Either<Failure, File>> downloadMultiple({
    required List<MediaDownloadInfo> mediaList,
    required String weddingId,
    Function(double)? onProgress,
  }) async {
    // Calculate total size to decide strategy
    final totalSize = mediaList.fold<int>(
      0,
      (sum, media) => sum + (media.fileSizeBytes ?? 0),
    );

    if (mediaList.length <= 10 && totalSize < 50 * 1024 * 1024) {
      // Client-side zip for small batches
      return repository.downloadAndZipClientSide(
        mediaList: mediaList,
        onProgress: onProgress,
      );
    } else {
      // Server-side zip via Edge Function
      return repository.downloadAsZipFromServer(
        mediaIds: mediaList.map((m) => m.mediaId).toList(),
        weddingId: weddingId,
        onProgress: onProgress,
      );
    }
  }
}

/// Data class for download info
class MediaDownloadInfo {
  final String mediaId;
  final String storageUrl;
  final String fileName;
  final int? fileSizeBytes;

  const MediaDownloadInfo({
    required this.mediaId,
    required this.storageUrl,
    required this.fileName,
    this.fileSizeBytes,
  });
}
```

### DownloadButton Widget
```dart
// lib/features/my_wedding/presentation/widgets/download_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DownloadButton extends StatelessWidget {
  final String storageUrl;
  final String fileName;
  final VoidCallback? onDownloadComplete;

  const DownloadButton({
    super.key,
    required this.storageUrl,
    required this.fileName,
    this.onDownloadComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DownloadBloc, DownloadState>(
      listener: (context, state) {
        if (state is DownloadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.isVideo ? "Video" : "Photo"} downloaded'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          onDownloadComplete?.call();
        } else if (state is DownloadError) {
          _showRetryDialog(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is DownloadInProgress && state.currentFile == storageUrl) {
          return _buildProgressIndicator(state.progress);
        }

        return IconButton(
          icon: const Icon(Icons.download_rounded),
          tooltip: 'Download',
          onPressed: () => _startDownload(context),
        );
      },
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _startDownload(BuildContext context) {
    context.read<DownloadBloc>().add(
      DownloadSingleMedia(
        storageUrl: storageUrl,
        fileName: fileName,
      ),
    );
  }

  void _showRetryDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startDownload(context);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

### DownloadProgressDialog Widget
```dart
// lib/features/my_wedding/presentation/widgets/download_progress_dialog.dart
import 'package:flutter/material.dart';

class DownloadProgressDialog extends StatelessWidget {
  final double progress;
  final String message;
  final int totalFiles;
  final int currentFile;
  final VoidCallback? onCancel;

  const DownloadProgressDialog({
    super.key,
    required this.progress,
    required this.message,
    this.totalFiles = 1,
    this.currentFile = 1,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(message),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 16),
          Text(
            '${(progress * 100).toInt()}%',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (totalFiles > 1) ...[
            const SizedBox(height: 8),
            Text(
              'File $currentFile of $totalFiles',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
      actions: onCancel != null
          ? [
              TextButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
            ]
          : null,
    );
  }
}
```

### Download Utils
```dart
// lib/core/utils/download_utils.dart
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadUtils {
  /// Get the downloads directory (platform-specific)
  static Future<Directory> getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Request storage permission on Android
      await Permission.storage.request();
      return Directory('/storage/emulated/0/Download');
    } else {
      // iOS: Use documents directory
      return await getApplicationDocumentsDirectory();
    }
  }

  /// Create a zip file from multiple files
  static Future<File> createZipFromFiles({
    required List<File> files,
    required String zipName,
  }) async {
    final archive = Archive();

    for (final file in files) {
      final bytes = await file.readAsBytes();
      archive.addFile(ArchiveFile(
        file.path.split('/').last,
        bytes.length,
        bytes,
      ));
    }

    final zipEncoder = ZipEncoder();
    final zipBytes = zipEncoder.encode(archive);

    if (zipBytes == null) {
      throw Exception('Failed to create zip file');
    }

    final downloadsDir = await getDownloadsDirectory();
    final zipFile = File('${downloadsDir.path}/$zipName');
    await zipFile.writeAsBytes(zipBytes);

    return zipFile;
  }

  /// Generate unique filename to avoid overwriting
  static String generateUniqueFileName(String baseName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = baseName.contains('.')
        ? '.${baseName.split('.').last}'
        : '';
    final nameWithoutExt = baseName.replaceAll(extension, '');
    return '${nameWithoutExt}_$timestamp$extension';
  }
}
```

### Edge Function: create-media-zip (Optionnel)
```typescript
// supabase/functions/create-media-zip/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { ZipWriter, BlobWriter, BlobReader } from 'https://deno.land/x/zipjs@v2.7.30/index.js';

Deno.serve(async (req: Request) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  };

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    const { mediaIds, weddingId, source } = await req.json();

    // Determine table based on source
    const table = source === 'guest' ? 'guest_media' : 'album_images';
    const pathColumn = source === 'guest' ? 'storage_path' : 'image_url';

    // Fetch media paths
    const { data: media, error } = await supabase
      .from(table)
      .select(`id, ${pathColumn}, media_type`)
      .in('id', mediaIds);

    if (error) throw error;
    if (!media || media.length === 0) {
      return new Response(
        JSON.stringify({ error: 'No media found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Create zip
    const zipWriter = new ZipWriter(new BlobWriter('application/zip'));

    for (const item of media) {
      const path = item[pathColumn];
      const { data: fileData, error: downloadError } = await supabase.storage
        .from('wedding-albums')
        .download(path);

      if (downloadError || !fileData) {
        console.error(`Failed to download ${path}:`, downloadError);
        continue;
      }

      const fileName = path.split('/').pop() || `file_${item.id}`;
      await zipWriter.add(fileName, new BlobReader(fileData));
    }

    const zipBlob = await zipWriter.close();

    // Upload zip to temp storage
    const zipFileName = `downloads/${weddingId}/${Date.now()}_media.zip`;
    const { error: uploadError } = await supabase.storage
      .from('wedding-albums')
      .upload(zipFileName, zipBlob, {
        contentType: 'application/zip',
      });

    if (uploadError) throw uploadError;

    // Get signed URL (1 hour expiry)
    const { data: signedUrl } = await supabase.storage
      .from('wedding-albums')
      .createSignedUrl(zipFileName, 3600);

    return new Response(
      JSON.stringify({
        downloadUrl: signedUrl?.signedUrl,
        fileCount: media.length,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    console.error('Error creating zip:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
```

### Selection Mode UI (pour album_detail_page.dart)
```dart
// Integration dans album_detail_page.dart - mode selection multiple
class _AlbumDetailPageState extends State<AlbumDetailPage> {
  bool _isSelectionMode = false;
  final Set<String> _selectedMediaIds = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedMediaIds.clear();
      }
    });
  }

  void _onMediaLongPress(String mediaId) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedMediaIds.add(mediaId);
      });
    }
  }

  void _toggleMediaSelection(String mediaId) {
    setState(() {
      if (_selectedMediaIds.contains(mediaId)) {
        _selectedMediaIds.remove(mediaId);
        if (_selectedMediaIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMediaIds.add(mediaId);
      }
    });
  }

  Widget _buildSelectionFab() {
    if (!_isSelectionMode || _selectedMediaIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: _downloadSelected,
      icon: const Icon(Icons.download),
      label: Text('Download ${_selectedMediaIds.length}'),
    );
  }

  void _downloadSelected() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocBuilder<DownloadBloc, DownloadState>(
        builder: (context, state) {
          if (state is DownloadInProgress) {
            return DownloadProgressDialog(
              progress: state.progress,
              message: 'Creating zip...',
              totalFiles: _selectedMediaIds.length,
              currentFile: state.currentFileIndex,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );

    context.read<DownloadBloc>().add(
      DownloadMultipleMedia(
        mediaIds: _selectedMediaIds.toList(),
        weddingId: widget.weddingId,
      ),
    );
  }
}
```

### Dependencies (pubspec.yaml)
```yaml
dependencies:
  archive: ^3.4.10  # For client-side zip creation
  permission_handler: ^11.0.0  # For storage permissions
  path_provider: ^2.1.1  # Already in project
```

## Definition of Done
- [ ] DownloadMediaUseCase cree et fonctionnel
- [ ] DownloadButton widget avec progress indicator
- [ ] DownloadProgressDialog pour downloads multiples
- [ ] Download single photo fonctionnel (bride + guest)
- [ ] Download single video fonctionnel (bride + guest)
- [ ] Download multiple avec zip fonctionnel
- [ ] Progress indicator pendant download (0-100%)
- [ ] Retry option en cas d'erreur
- [ ] Mode selection dans album pages (long-press)
- [ ] Bride peut download depuis guest albums (si partages)
- [ ] Guest peut download depuis son propre album
- [ ] Edge Function create-media-zip deployee (optionnel)
- [ ] Tests unitaires pour use case
- [ ] Tests widget pour DownloadButton
- [ ] `flutter analyze --fatal-infos` passe
- [ ] `flutter test` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (gestion gros fichiers, permissions, zip generation)

## Dependances
- S01 (album_images enrichie avec file_size_bytes)
- S02 (guest_albums)
- S03 (guest_media)

## Stories Dependantes
- Aucune (derniere story de l'Epic)
