# Story S09: Telechargement haute qualite (zip multiple)

## Description
En tant que **bride**, je veux **telecharger mes photos et videos en haute qualite, avec zip automatique pour les selections multiples**, afin de **conserver mes souvenirs sur mon appareil sans perte de qualite**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a bride viewing a photo When the bride taps "Download" Then the original high-quality photo should be downloaded And gallery_access_logs should record 'download'
- [ ] Given a bride viewing a video When the bride taps "Download" Then the original video file should be downloaded And gallery_access_logs should record 'download'
- [ ] Given a bride selects 5 photos When the bride taps "Download Selected" Then a progress indicator should appear with "Creating zip..." And a zip file containing 5 photos should be downloaded And gallery_access_logs should record 'download_zip'
- [ ] Given a bride selects 3 photos and 2 videos When the bride taps "Download Selected" Then a zip file containing all 5 files should be created And files should retain their original quality
- [ ] Given a bride viewing a shared guest album When the bride taps "Download All" Then all media from that album should be zipped And downloaded to the device
- [ ] Given downloading a 400MB video When download is in progress Then progress percentage should be shown And download speed should be displayed
- [ ] Given a download in progress When the download fails Then error message should be shown And retry option should be available

## Fichiers Concernes

### A Creer
- `lib/features/my_wedding/domain/usecases/download_media_use_case.dart`
- `lib/features/my_wedding/presentation/widgets/download_button.dart`
- `lib/features/my_wedding/presentation/widgets/download_progress_dialog.dart`
- `lib/core/utils/zip_utils.dart` (si zip cote client)
- Edge Function: `create-media-zip` (recommande pour gros fichiers)

### A Modifier
- `lib/features/my_wedding/presentation/pages/media_detail_page.dart` - Ajouter bouton download
- `lib/features/my_wedding/presentation/pages/album_page.dart` - Ajouter selection multiple + download

## Notes Techniques

### DownloadMediaUseCase
```dart
// lib/features/my_wedding/domain/usecases/download_media_use_case.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';

class DownloadMediaUseCase {
  final MediaRepository repository;
  final GalleryAccessLogRepository logRepository;

  DownloadMediaUseCase(this.repository, this.logRepository);

  /// Download a single media file
  Future<Either<Failure, File>> downloadSingle({
    required String mediaId,
    required String storageUrl,
    required String weddingId,
    required String userId,
    Function(double)? onProgress,
  }) async {
    // Log the download
    await logRepository.logAccess(
      weddingId: weddingId,
      accessedBy: userId,
      accessType: 'download',
      mediaId: mediaId,
    );

    // Download the file
    return repository.downloadFile(
      storageUrl: storageUrl,
      onProgress: onProgress,
    );
  }

  /// Download multiple media as zip
  Future<Either<Failure, File>> downloadMultiple({
    required List<String> mediaIds,
    required String weddingId,
    required String userId,
    Function(double)? onProgress,
  }) async {
    // Log the zip download
    await logRepository.logAccess(
      weddingId: weddingId,
      accessedBy: userId,
      accessType: 'download_zip',
    );

    // Call Edge Function to create zip
    // Or create zip client-side for small batches
    return repository.downloadAsZip(
      mediaIds: mediaIds,
      onProgress: onProgress,
    );
  }
}
```

### DownloadButton Widget
```dart
// lib/features/my_wedding/presentation/widgets/download_button.dart
class DownloadButton extends StatelessWidget {
  final String mediaId;
  final String storageUrl;
  final String weddingId;

  const DownloadButton({
    super.key,
    required this.mediaId,
    required this.storageUrl,
    required this.weddingId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DownloadBloc, DownloadState>(
      listener: (context, state) {
        if (state is DownloadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download complete!')),
          );
        } else if (state is DownloadError) {
          _showRetryDialog(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is DownloadInProgress) {
          return _buildProgressButton(state.progress);
        }

        return IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _startDownload(context),
        );
      },
    );
  }

  Widget _buildProgressButton(double progress) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(value: progress),
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  void _startDownload(BuildContext context) {
    context.read<DownloadBloc>().add(
      DownloadSingleMedia(
        mediaId: mediaId,
        storageUrl: storageUrl,
        weddingId: weddingId,
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

### Edge Function: create-media-zip
```typescript
// supabase/functions/create-media-zip/index.ts
import { createClient } from '@supabase/supabase-js';
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { encode } from 'https://deno.land/std@0.168.0/encoding/base64.ts';
import * as zip from 'https://deno.land/x/zipjs@v2.7.30/index.js';

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );

  const { mediaIds, weddingId } = await req.json();

  // Fetch media paths from DB
  const { data: media } = await supabase
    .from('album_images')
    .select('id, image_url, media_type')
    .in('id', mediaIds);

  // Also check guest_media
  const { data: guestMedia } = await supabase
    .from('guest_media')
    .select('id, storage_path, media_type')
    .in('id', mediaIds);

  const allMedia = [...(media || []), ...(guestMedia || [])];

  // Create zip in memory
  const zipWriter = new zip.ZipWriter(new zip.BlobWriter('application/zip'));

  for (const item of allMedia) {
    const path = item.image_url || item.storage_path;
    const { data: fileData } = await supabase.storage
      .from('wedding-media')
      .download(path);

    if (fileData) {
      const fileName = path.split('/').pop();
      await zipWriter.add(fileName, new zip.BlobReader(fileData));
    }
  }

  const zipBlob = await zipWriter.close();

  // Upload zip to temp storage
  const zipFileName = `downloads/${weddingId}/${Date.now()}.zip`;
  await supabase.storage
    .from('wedding-media')
    .upload(zipFileName, zipBlob);

  // Get signed URL
  const { data: signedUrl } = await supabase.storage
    .from('wedding-media')
    .createSignedUrl(zipFileName, 3600); // 1 hour expiry

  return new Response(
    JSON.stringify({ downloadUrl: signedUrl.signedUrl }),
    { headers: { 'Content-Type': 'application/json' } }
  );
});
```

### Selection Multiple UI
```dart
// Dans album_page.dart - mode selection
class AlbumPageState extends State<AlbumPage> {
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

  void _toggleMediaSelection(String mediaId) {
    setState(() {
      if (_selectedMediaIds.contains(mediaId)) {
        _selectedMediaIds.remove(mediaId);
      } else {
        _selectedMediaIds.add(mediaId);
      }
    });
  }

  Widget _buildSelectionFab() {
    if (_selectedMediaIds.isEmpty) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      onPressed: _downloadSelected,
      icon: const Icon(Icons.download),
      label: Text('Download ${_selectedMediaIds.length}'),
    );
  }

  void _downloadSelected() {
    context.read<DownloadBloc>().add(
      DownloadMultipleMedia(
        mediaIds: _selectedMediaIds.toList(),
        weddingId: widget.weddingId,
      ),
    );
  }
}
```

## Definition of Done
- [ ] Download single media fonctionnel
- [ ] Download multiple avec zip fonctionnel
- [ ] Progress indicator pendant download
- [ ] Progress indicator pendant creation zip
- [ ] Retry option en cas d'erreur
- [ ] Logging dans gallery_access_logs
- [ ] Edge Function create-media-zip deployee (si serveur-side)
- [ ] Mode selection dans album page
- [ ] Tests unitaires pour use case
- [ ] `flutter analyze --fatal-infos` passe
- [ ] `flutter test` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (gestion gros fichiers, zip generation)

## Dependances
- S01 (album_images enrichie)
- S02 (guest_albums)
- S03 (guest_media)
- S04 (gallery_access_logs pour logging)

## Stories Dependantes
- Aucune
