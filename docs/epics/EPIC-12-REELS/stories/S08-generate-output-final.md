# Story S08: Generate Final Output (1080p + Logo)

## Description
En tant que **utilisateur**, je veux **obtenir un reel haute qualite avec logo discret**, afin de **partager un montage professionnel sur les reseaux sociaux**.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Final output generation with logo

  Scenario: Output resolution is 1080p
    Given a reel is being processed by Shotstack
    When the output render is submitted
    Then the resolution should be configured as "hd" (1080p)
    And the aspect ratio should match source videos

  Scenario: Logo placement is discreet
    Given the output Shotstack edit configuration
    Then it should include a logo overlay with:
      | property    | value                    |
      | asset       | Lynewed logo PNG         |
      | position    | bottom-right             |
      | offset      | 20px from edges          |
      | size        | small (not intrusive)    |
      | opacity     | 0.7-0.8 (subtle)         |

  Scenario: Output quality is high
    Given output generation completes
    Then the video should use high quality settings:
      | setting      | value          |
      | resolution   | 1920x1080      |
      | quality      | high           |
      | fps          | 30             |
      | codec        | H.264          |
      | audio        | AAC 192kbps    |

  Scenario: Output is stored correctly
    Given output generation completes
    Then the file should be uploaded to "reels/{reel_id}/output.mp4"
    And output_path should be updated in reels table
    And the file should be accessible via signed URL

  Scenario: Fade transitions are applied
    Given 3 source videos
    When output is generated
    Then there should be 1-second fade transitions between each video
    And transitions should be smooth and professional

  Scenario: Output is shareable on social media
    Given a generated output file
    Then file format should be compatible with:
      | platform    | status      |
      | Instagram   | compatible  |
      | TikTok      | compatible  |
      | Facebook    | compatible  |
      | WhatsApp    | compatible  |
    And file size should be reasonable (< 100MB for 10min)

  Scenario: Audio is preserved
    Given source videos with audio tracks
    When output is generated
    Then audio should be preserved from source videos
    And audio transitions should be smooth (crossfade)
```

## Fichiers Concernes

### A Creer
- `supabase/functions/_shared/assets/lynewed_logo.png` - Logo asset (or URL reference)

### A Modifier
- `supabase/functions/generate-reel/shotstack_render.ts` - Add output generation config

## Notes Techniques

### Shotstack Output Configuration
```typescript
// In shotstack_render.ts - output render configuration

// Logo URL - should be publicly accessible or use Shotstack assets
const LYNEWED_LOGO_URL = 'https://your-cdn.com/assets/lynewed_logo.png';

function buildOutputEdit(videoUrls: string[]): ShotstackEdit {
  const clips = buildVideoClips(videoUrls);

  return {
    timeline: {
      tracks: [
        // Video track with transitions
        {
          clips: clips.map((clip, index) => ({
            ...clip,
            transition: index > 0 ? {
              in: 'fade',
              out: index < clips.length - 1 ? 'fade' : undefined,
            } : undefined,
          })),
        },
        // Logo overlay track
        {
          clips: [{
            asset: {
              type: 'image',
              src: LYNEWED_LOGO_URL,
            },
            start: 0,
            length: 'end', // Full duration
            position: 'bottomRight',
            offset: {
              x: -0.02, // 2% from right edge
              y: 0.02,  // 2% from bottom edge
            },
            scale: 0.1, // 10% of video width
            opacity: 0.8,
          }],
        },
      ],
    },
    output: {
      format: 'mp4',
      resolution: 'hd', // 1080p
      quality: 'high',
      fps: 30,
      size: {
        width: 1920,
        height: 1080,
      },
    },
  };
}

// Build video clips with proper timing and transitions
function buildVideoClips(videoUrls: string[]): ShotstackClip[] {
  let currentStart = 0;
  const FADE_DURATION = 1; // 1 second fade

  return videoUrls.map((url, index) => {
    const clip: ShotstackClip = {
      asset: {
        type: 'video',
        src: url,
        volume: 1,
      },
      start: currentStart,
      // Note: length is auto-detected from video
    };

    // Apply fade transitions
    if (index > 0) {
      clip.transition = {
        in: 'fade',
      };
      // Overlap with previous clip for crossfade
      currentStart -= FADE_DURATION / 2;
    }

    if (index < videoUrls.length - 1) {
      clip.transition = {
        ...clip.transition,
        out: 'fade',
      };
    }

    // Estimate next start (will be refined by actual duration)
    currentStart += 60; // Placeholder, actual calculation needed

    return clip;
  });
}
```

### Audio Handling
```typescript
// Ensure audio crossfade matches video crossfade
function buildAudioTransition(): ShotstackAudioTransition {
  return {
    in: {
      effect: 'fadeIn',
      duration: 1,
    },
    out: {
      effect: 'fadeOut',
      duration: 1,
    },
  };
}
```

### Logo Asset Requirements
- Format: PNG with transparency
- Size: ~200x50 pixels (will be scaled)
- Style: White version for visibility on any background
- Location: Hosted on CDN or Shotstack assets

### Quality Settings Comparison
| Setting | Preview (S07) | Output (S08) |
|---------|---------------|--------------|
| Resolution | 480p (sd) | 1080p (hd) |
| Quality | low | high |
| FPS | 25 | 30 |
| Bitrate | ~1 Mbps | ~5-8 Mbps |
| Watermark | "LYNEWED" center text | Logo bottom-right |
| File size | ~10 MB/min | ~50 MB/min |

### Integration with S06
```typescript
// In generate-reel/index.ts

// Submit both preview and output renders
const [previewRender, outputRender] = await Promise.all([
  submitShotstackRender(shotstack, videoUrls, { type: 'preview' }),
  submitShotstackRender(shotstack, videoUrls, { type: 'output' }),
]);

// Poll both renders
const [previewResult, outputResult] = await Promise.all([
  pollRenderStatus(shotstack, previewRender.renderId),
  pollRenderStatus(shotstack, outputRender.renderId),
]);

// Upload both files
await Promise.all([
  uploadToStorage(supabase, previewResult.url, `reels/${reel_id}/preview.mp4`),
  uploadToStorage(supabase, outputResult.url, `reels/${reel_id}/output.mp4`),
]);
```

## Definition of Done
- [ ] Criteres d'acceptance valides
- [ ] Shotstack output config uses 1080p resolution
- [ ] Logo overlay positioned correctly (bottom-right, discreet)
- [ ] Fade transitions between clips (1 second)
- [ ] Audio preserved with smooth transitions
- [ ] Output uploaded to correct Storage path
- [ ] File compatible with major social platforms
- [ ] Quality visibly higher than preview
- [ ] `flutter analyze --fatal-infos` passe (N/A - backend)

## Estimation
**Points** : 3
**Complexite** : Moyenne
**Risque** : Faible

## Dependances
- S06: Edge Function orchestrates render submission

## Stories Dependantes
- S10: Download feature (downloads the output file)
