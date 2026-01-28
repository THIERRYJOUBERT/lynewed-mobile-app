# Story S07: Generate Preview (480p + Watermark)

## Description
En tant que **utilisateur**, je veux **voir une preview basse qualite de mon reel avec watermark**, afin de **verifier le resultat avant de telecharger la version haute qualite**.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Preview generation with watermark

  Scenario: Preview resolution is 480p
    Given a reel is being processed by Shotstack
    When the preview render is submitted
    Then the output resolution should be configured as "sd" (480p)
    And the aspect ratio should be preserved

  Scenario: Watermark is centered
    Given the preview Shotstack edit configuration
    Then it should include a text overlay with:
      | property    | value            |
      | text        | "LYNEWED"        |
      | position    | center           |
      | font_size   | 72               |
      | color       | #FFFFFF          |
      | opacity     | 0.5              |

  Scenario: Preview is stored correctly
    Given preview generation completes
    Then the file should be uploaded to "reels/{reel_id}/preview.mp4"
    And preview_path should be updated in reels table
    And the file should be accessible via signed URL

  Scenario: Preview quality is intentionally lower
    Given both preview and output are generated
    Then preview file size should be smaller than output
    And preview should use lower bitrate settings
    And this encourages download of full quality

  Scenario: Preview is playable in app
    Given a generated preview file
    When user views the reel detail page
    Then the preview should load and play automatically (muted)
    And playback should be smooth
    And watermark should be visible throughout

  Scenario: Preview maintains video content
    Given 3 source videos with total 5 minutes
    When preview is generated
    Then all content should be included
    And fade transitions should be visible
    And total duration should match source videos
```

## Fichiers Concernes

### A Creer
- `lib/features/reels/presentation/widgets/reel_preview_player.dart`
- `lib/features/reels/presentation/pages/reel_detail_page.dart`

### A Modifier
- `supabase/functions/generate-reel/shotstack_render.ts` - Add preview generation config

## Notes Techniques

### Shotstack Preview Configuration
```typescript
// In shotstack_render.ts - preview render configuration

function buildPreviewEdit(videoUrls: string[], options: RenderOptions): ShotstackEdit {
  const clips = buildVideoClips(videoUrls);

  return {
    timeline: {
      tracks: [
        // Video track
        { clips },
        // Watermark track (overlay)
        {
          clips: [{
            asset: {
              type: 'html',
              html: '<p style="font-size:72px;color:white;opacity:0.5;">LYNEWED</p>',
              width: 400,
              height: 100,
            },
            start: 0,
            length: 'end', // Full duration
            position: 'center',
          }],
        },
      ],
    },
    output: {
      format: 'mp4',
      resolution: 'sd', // 480p
      quality: 'low', // Lower quality for preview
      fps: 25,
    },
  };
}

// Alternative: Use Shotstack's built-in watermark
function buildPreviewEditWithShotstackWatermark(videoUrls: string[]): ShotstackEdit {
  return {
    timeline: {
      tracks: [{ clips: buildVideoClips(videoUrls) }],
    },
    output: {
      format: 'mp4',
      resolution: 'sd',
      quality: 'low',
    },
    merge: [{
      find: 'WATERMARK',
      replace: {
        type: 'text',
        text: 'LYNEWED',
        style: 'minimal',
        size: 'large',
        position: 'center',
        offset: { x: 0, y: 0 },
      },
    }],
  };
}
```

### Reel Preview Player Widget
```dart
// lib/features/reels/presentation/widgets/reel_preview_player.dart

import 'package:video_player/video_player.dart';

class ReelPreviewPlayer extends StatefulWidget {
  final String previewUrl;
  final VoidCallback? onPlaybackComplete;

  const ReelPreviewPlayer({
    required this.previewUrl,
    this.onPlaybackComplete,
    super.key,
  });

  @override
  State<ReelPreviewPlayer> createState() => _ReelPreviewPlayerState();
}

class _ReelPreviewPlayerState extends State<ReelPreviewPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.previewUrl),
    );

    await _controller.initialize();
    await _controller.setLooping(true);
    await _controller.setVolume(0); // Muted by default
    await _controller.play();

    setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          // Play/Pause overlay
          GestureDetector(
            onTap: () {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
              setState(() {});
            },
            child: Container(
              color: Colors.transparent,
              child: AnimatedOpacity(
                opacity: _controller.value.isPlaying ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.play_arrow, size: 64, color: Colors.white),
              ),
            ),
          ),
          // Volume toggle
          Positioned(
            bottom: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                _controller.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                color: Colors.white,
              ),
              onPressed: () {
                _controller.setVolume(_controller.value.volume > 0 ? 0 : 1);
                setState(() {});
              },
            ),
          ),
          // Preview badge
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PREVIEW',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Reel Detail Page
```dart
// lib/features/reels/presentation/pages/reel_detail_page.dart

class ReelDetailPage extends ConsumerWidget {
  final String reelId;

  const ReelDetailPage({required this.reelId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reelAsync = ref.watch(reelDetailProvider(reelId));

    return Scaffold(
      appBar: AppBar(title: const Text('Your Reel')),
      body: reelAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (reel) => Column(
          children: [
            // Preview player
            if (reel.previewPath != null)
              ReelPreviewPlayer(
                previewUrl: ref.read(storageServiceProvider).getSignedUrl(reel.previewPath!),
              ),

            const SizedBox(height: 16),

            // Status and info
            _buildStatusSection(reel),

            const Spacer(),

            // Download button (S10)
            if (reel.status == ReelStatus.ready)
              _buildDownloadButton(context, ref, reel),
          ],
        ),
      ),
    );
  }
}
```

## Definition of Done
- [ ] Criteres d'acceptance valides
- [ ] Shotstack preview config uses 480p resolution
- [ ] Watermark "LYNEWED" centered on preview
- [ ] Preview uploaded to correct Storage path
- [ ] ReelPreviewPlayer widget implemented
- [ ] Preview plays in app (muted by default)
- [ ] Volume toggle works
- [ ] Tests widget ReelPreviewPlayer
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 3
**Complexite** : Moyenne
**Risque** : Faible

## Dependances
- S06: Edge Function must generate preview file

## Stories Dependantes
- S10: Download feature (shows preview before download)
