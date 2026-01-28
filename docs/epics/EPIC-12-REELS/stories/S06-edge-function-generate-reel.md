# Story S06: Create Edge Function generate-reel (Shotstack)

## Description
En tant que **systeme**, je veux **une Edge Function qui genere les reels via Shotstack API**, afin de **concatener les videos avec des transitions et produire le montage final**.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Edge Function generate-reel

  Scenario: Successful reel generation
    Given a reel with id 'reel-123' and status 'pending'
    And source_media_ids contains 3 valid video UUIDs
    When the Edge Function is invoked with reel_id 'reel-123'
    Then status should change to 'processing'
    And processing_started_at should be set to current timestamp
    And videos should be downloaded from Storage
    And Shotstack render should be submitted with:
      | setting           | value                    |
      | transitions       | 1s fade between clips    |
      | timeline          | videos in order          |
    And function should poll for render completion
    And status should change to 'ready' when complete
    And processing_completed_at should be set
    And expires_at should be set to NOW() + 7 days

  Scenario: Invalid reel ID
    When the Edge Function is invoked with reel_id 'non-existent'
    Then it should return 404 with error "Reel not found"
    And no processing should start

  Scenario: Reel already processing
    Given a reel with status 'processing'
    When the Edge Function is invoked for that reel
    Then it should return 409 with error "Reel already processing"

  Scenario: Ownership validation fails
    Given a reel request with unauthorized video IDs
    When the Edge Function validates ownership
    Then it should return 403 with error "Unauthorized videos"
    And status should change to 'failed'
    And error_message should contain unauthorized video IDs

  Scenario: Video not found in Storage
    Given a reel with source_media_ids containing invalid path
    When the Edge Function tries to download videos
    Then status should change to 'failed'
    And error_message should contain "Video not found: [path]"

  Scenario: Shotstack API error
    Given a valid reel request
    When Shotstack API returns an error
    Then status should change to 'failed'
    And error_message should contain Shotstack error details
    And ffmpeg_log should contain full API response

  Scenario: Shotstack render timeout
    Given a reel submitted to Shotstack
    When render does not complete within 10 minutes
    Then the function should mark status as 'failed'
    And error_message should be "Processing timeout exceeded"

  Scenario: Paths are saved correctly
    Given a successfully generated reel
    Then preview_path should be "reels/{reel_id}/preview.mp4"
    And output_path should be "reels/{reel_id}/output.mp4"
    And both files should be accessible via Storage

  Scenario: JWT validation
    Given an Edge Function request without valid JWT
    When the function is called
    Then it should return 401 Unauthorized
```

## Fichiers Concernes

### A Creer
- `supabase/functions/generate-reel/index.ts` - Main Edge Function
- `supabase/functions/generate-reel/shotstack_render.ts` - Shotstack integration
- `supabase/functions/generate-reel/validate_ownership.ts` - Ownership validation (from S04)
- `supabase/functions/generate-reel/storage_utils.ts` - Storage download/upload helpers
- `supabase/functions/_shared/shotstack_client.ts` - Shared Shotstack client (from S00)

### A Modifier
- None

## Notes Techniques

### Main Edge Function
```typescript
// supabase/functions/generate-reel/index.ts

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { createShotstackClient } from "../_shared/shotstack_client.ts";
import { validateOwnership } from "./validate_ownership.ts";
import { submitShotstackRender, pollRenderStatus } from "./shotstack_render.ts";
import { getVideoUrls, uploadToStorage } from "./storage_utils.ts";

interface GenerateReelRequest {
  reel_id: string;
}

const PROCESSING_TIMEOUT_MS = 10 * 60 * 1000; // 10 minutes

Deno.serve(async (req: Request) => {
  try {
    // 1. Validate JWT
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // 2. Parse request
    const { reel_id } = await req.json() as GenerateReelRequest;

    if (!reel_id) {
      return new Response(JSON.stringify({ error: 'reel_id required' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // 3. Initialize Supabase client with service role
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // 4. Fetch reel record
    const { data: reel, error: fetchError } = await supabase
      .from('reels')
      .select('*')
      .eq('id', reel_id)
      .single();

    if (fetchError || !reel) {
      return new Response(JSON.stringify({ error: 'Reel not found' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // 5. Check if already processing
    if (reel.status === 'processing') {
      return new Response(JSON.stringify({ error: 'Reel already processing' }), {
        status: 409,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // 6. Validate ownership
    const ownershipResult = await validateOwnership(
      supabase,
      reel.user_id,
      reel.creator_type,
      reel.wedding_id,
      reel.source_media_ids,
    );

    if (!ownershipResult.isValid) {
      await supabase.from('reels').update({
        status: 'failed',
        error_message: ownershipResult.error,
      }).eq('id', reel_id);

      return new Response(JSON.stringify({
        error: 'Unauthorized videos',
        details: ownershipResult.unauthorizedIds,
      }), {
        status: 403,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // 7. Update status to processing
    await supabase.from('reels').update({
      status: 'processing',
      processing_started_at: new Date().toISOString(),
    }).eq('id', reel_id);

    // 8. Get signed URLs for videos
    const videoUrls = await getVideoUrls(supabase, reel.source_media_ids);

    // 9. Initialize Shotstack client
    const shotstack = createShotstackClient({
      apiKey: Deno.env.get('SHOTSTACK_API_KEY')!,
      environment: Deno.env.get('SHOTSTACK_ENV') as 'stage' | 'v1',
    });

    // 10. Submit render to Shotstack
    const { renderId } = await submitShotstackRender(shotstack, videoUrls, {
      fadeDuration: 1,
      previewWatermark: 'LYNEWED',
    });

    // 11. Poll for completion with timeout
    const startTime = Date.now();
    let renderResult;

    while (Date.now() - startTime < PROCESSING_TIMEOUT_MS) {
      renderResult = await pollRenderStatus(shotstack, renderId);

      if (renderResult.status === 'done') break;
      if (renderResult.status === 'failed') {
        throw new Error(`Shotstack render failed: ${renderResult.error}`);
      }

      // Wait 5 seconds before polling again
      await new Promise(resolve => setTimeout(resolve, 5000));
    }

    if (!renderResult || renderResult.status !== 'done') {
      throw new Error('Processing timeout exceeded');
    }

    // 12. Download rendered files from Shotstack
    const previewPath = `reels/${reel_id}/preview.mp4`;
    const outputPath = `reels/${reel_id}/output.mp4`;

    await uploadToStorage(supabase, renderResult.previewUrl, previewPath);
    await uploadToStorage(supabase, renderResult.outputUrl, outputPath);

    // 13. Update reel record with success
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days

    await supabase.from('reels').update({
      status: 'ready',
      preview_path: previewPath,
      output_path: outputPath,
      total_duration_seconds: renderResult.duration,
      processing_completed_at: new Date().toISOString(),
      expires_at: expiresAt.toISOString(),
    }).eq('id', reel_id);

    return new Response(JSON.stringify({
      success: true,
      reel_id,
      preview_path: previewPath,
      output_path: outputPath,
    }), {
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    // Handle errors
    console.error('Generate reel error:', error);

    // Try to update reel status if we have the ID
    try {
      const { reel_id } = await req.json();
      if (reel_id) {
        const supabase = createClient(
          Deno.env.get('SUPABASE_URL')!,
          Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
        );
        await supabase.from('reels').update({
          status: 'failed',
          error_message: error.message,
          ffmpeg_log: JSON.stringify(error),
        }).eq('id', reel_id);
      }
    } catch {}

    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});
```

### Shotstack Render Module
```typescript
// supabase/functions/generate-reel/shotstack_render.ts

interface RenderOptions {
  fadeDuration: number;
  previewWatermark: string;
}

export async function submitShotstackRender(
  client: ShotstackClient,
  videoUrls: string[],
  options: RenderOptions,
): Promise<{ renderId: string }> {
  // Build timeline with videos and transitions
  let currentTime = 0;
  const clips = videoUrls.map((url, index) => {
    const clip = {
      asset: { type: 'video', src: url },
      start: currentTime,
      // Duration will be determined by video length
      transition: index > 0 ? { in: 'fade', out: 'fade' } : undefined,
    };
    currentTime += /* video duration - fade overlap */;
    return clip;
  });

  const edit = {
    timeline: {
      tracks: [{ clips }],
    },
    output: {
      format: 'mp4',
      resolution: 'hd', // 1080p for output
    },
    // For preview, we'll do a second render at sd with watermark
  };

  const response = await client.submitRender(edit);
  return { renderId: response.id };
}

export async function pollRenderStatus(
  client: ShotstackClient,
  renderId: string,
): Promise<RenderStatus> {
  const status = await client.getRenderStatus(renderId);
  return {
    status: status.status, // 'queued', 'rendering', 'done', 'failed'
    previewUrl: status.previewUrl,
    outputUrl: status.url,
    duration: status.duration,
    error: status.error,
  };
}
```

### Storage Utilities
```typescript
// supabase/functions/generate-reel/storage_utils.ts

export async function getVideoUrls(
  supabase: SupabaseClient,
  mediaIds: string[],
): Promise<string[]> {
  // Get storage paths for each media ID
  const { data: media } = await supabase
    .from('guest_media')
    .select('id, storage_path')
    .in('id', mediaIds);

  // Generate signed URLs (valid for 1 hour)
  const urls = await Promise.all(
    media.map(async (m) => {
      const { data } = await supabase.storage
        .from('wedding-media')
        .createSignedUrl(m.storage_path, 3600);
      return data.signedUrl;
    })
  );

  return urls;
}

export async function uploadToStorage(
  supabase: SupabaseClient,
  sourceUrl: string,
  destPath: string,
): Promise<void> {
  // Download from Shotstack
  const response = await fetch(sourceUrl);
  const blob = await response.blob();

  // Upload to Supabase Storage
  const { error } = await supabase.storage
    .from('wedding-media')
    .upload(destPath, blob, {
      contentType: 'video/mp4',
      upsert: true,
    });

  if (error) throw new Error(`Upload failed: ${error.message}`);
}
```

## Definition of Done
- [ ] Criteres d'acceptance valides
- [ ] Edge Function deployed to Supabase
- [ ] JWT validation works
- [ ] Ownership validation integrated
- [ ] Shotstack render submission works
- [ ] Polling for completion works
- [ ] Timeout handling works (10 min)
- [ ] Files uploaded to correct Storage paths
- [ ] Status transitions correct (pending -> processing -> ready/failed)
- [ ] Error handling comprehensive
- [ ] `flutter analyze --fatal-infos` passe (N/A - backend)

## Estimation
**Points** : 8
**Complexite** : Haute
**Risque** : Haut (external API, async processing)

## Dependances
- S00: Shotstack infrastructure validated
- S01: Reels table exists
- S04: Ownership validation logic

## Stories Dependantes
- S07: Preview generation (uses Shotstack output)
- S08: Final output generation (uses Shotstack output)
- S09: Notification (triggered after status = ready)
