# Story S12: Create pg_cron Job for Expired Reels Cleanup

## Description
En tant que **systeme**, je veux **supprimer automatiquement les reels expires apres 7 jours**, afin de **reduire les couts de stockage et respecter la politique de retention**.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Automatic cleanup of expired reels

  Scenario: Daily cron job is scheduled
    Given the pg_cron extension is enabled in Supabase
    When the migration is applied
    Then a cron job named 'cleanup-expired-reels' should exist
    And it should be scheduled to run at 3:00 AM UTC daily

  Scenario: Expired reels are marked for cleanup
    Given a reel with:
      | field       | value               |
      | id          | reel-123            |
      | status      | ready               |
      | expires_at  | 8 days ago          |
    When the cleanup job runs
    Then the reel status should change to 'expired'
    And preview_path should be set to NULL
    And output_path should be set to NULL
    And the reel record should remain (for history)

  Scenario: Storage files are deleted
    Given an expired reel with paths:
      | path                         |
      | reels/reel-123/preview.mp4   |
      | reels/reel-123/output.mp4    |
    When the cleanup Edge Function processes it
    Then both files should be deleted from Storage bucket
    And no orphan files should remain

  Scenario: Non-expired reels are not affected
    Given a reel with expires_at = 3 days from now
    And status = 'ready'
    When the cleanup job runs
    Then the reel should remain unchanged
    And files should remain in Storage

  Scenario: Already expired reels are skipped
    Given a reel with status = 'expired'
    And expires_at = 10 days ago
    When the cleanup job runs
    Then no action should be taken on this reel
    And it should be skipped efficiently

  Scenario: Failed reels cleanup
    Given a reel with:
      | field      | value               |
      | status     | failed              |
      | created_at | 8 days ago          |
    And it has partial files in Storage
    When the cleanup job runs for failed reels
    Then any partial files should be deleted
    And status should remain 'failed'

  Scenario: Downloaded reels cleanup
    Given a reel with:
      | field         | value               |
      | status        | downloaded          |
      | expires_at    | 8 days ago          |
      | downloaded_at | 5 days ago          |
    When the cleanup job runs
    Then the reel should be marked as 'expired'
    And files should be deleted
    And downloaded_at should be preserved

  Scenario: Cleanup logging
    Given 5 reels are expired
    When the cleanup job runs
    Then the function should log:
      | message                               |
      | "Starting expired reels cleanup"      |
      | "Found 5 reels to cleanup"            |
      | "Cleaned up reel: reel-xxx"           |
      | "Cleanup complete: 5 reels processed" |

  Scenario: Error handling during cleanup
    Given an expired reel with files that fail to delete
    When the cleanup attempts to delete Storage files
    And the deletion fails (e.g., permission error)
    Then the error should be logged
    And the reel should NOT be marked as expired
    And cleanup should continue with next reel
```

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260128001212_create_cleanup_reels_cron.sql`
- `supabase/functions/cleanup-reel-files/index.ts` - Edge Function for file deletion

### A Modifier
- None

## Notes Techniques

### Migration SQL - pg_cron Setup
```sql
-- Migration: 20260128001212_create_cleanup_reels_cron
-- Description: Create pg_cron job for expired reels cleanup
-- Epic: EPIC-12-REELS
-- Story: S12

-- Ensure pg_cron is enabled (should already be on Supabase)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Create cleanup function
CREATE OR REPLACE FUNCTION cleanup_expired_reels()
RETURNS TABLE (
  cleaned_count INTEGER,
  failed_count INTEGER
) AS $$
DECLARE
  reel_record RECORD;
  v_cleaned INTEGER := 0;
  v_failed INTEGER := 0;
BEGIN
  RAISE NOTICE 'Starting expired reels cleanup at %', NOW();

  -- Find all reels that should be expired
  FOR reel_record IN
    SELECT id, preview_path, output_path, user_id
    FROM reels
    WHERE expires_at < NOW()
    AND status IN ('ready', 'downloaded')
  LOOP
    BEGIN
      -- Mark as expired and clear paths
      -- Note: Actual file deletion is done by Edge Function
      UPDATE reels
      SET
        status = 'expired',
        preview_path = NULL,
        output_path = NULL
      WHERE id = reel_record.id;

      -- Queue file deletion via Edge Function
      -- This is done by inserting into a cleanup queue
      INSERT INTO storage_cleanup_queue (bucket, paths, created_at)
      VALUES (
        'wedding-media',
        ARRAY[reel_record.preview_path, reel_record.output_path],
        NOW()
      );

      v_cleaned := v_cleaned + 1;
      RAISE NOTICE 'Marked reel % as expired', reel_record.id;

    EXCEPTION WHEN OTHERS THEN
      v_failed := v_failed + 1;
      RAISE WARNING 'Failed to cleanup reel %: %', reel_record.id, SQLERRM;
    END;
  END LOOP;

  RAISE NOTICE 'Cleanup complete: % cleaned, % failed', v_cleaned, v_failed;

  RETURN QUERY SELECT v_cleaned, v_failed;
END;
$$ LANGUAGE plpgsql;

-- Schedule daily at 3 AM UTC
SELECT cron.schedule(
  'cleanup-expired-reels',
  '0 3 * * *',
  'SELECT * FROM cleanup_expired_reels();'
);

-- Also cleanup failed reels older than 7 days
CREATE OR REPLACE FUNCTION cleanup_failed_reels()
RETURNS void AS $$
BEGIN
  UPDATE reels
  SET
    preview_path = NULL,
    output_path = NULL
  WHERE status = 'failed'
  AND created_at < NOW() - INTERVAL '7 days'
  AND (preview_path IS NOT NULL OR output_path IS NOT NULL);
END;
$$ LANGUAGE plpgsql;

-- Schedule failed reels cleanup weekly (Sunday 4 AM UTC)
SELECT cron.schedule(
  'cleanup-failed-reels',
  '0 4 * * 0',
  'SELECT cleanup_failed_reels();'
);

-- Comments
COMMENT ON FUNCTION cleanup_expired_reels IS 'Marks expired reels and queues file deletion';
COMMENT ON FUNCTION cleanup_failed_reels IS 'Cleans up partial files from failed reels';
```

### Storage Cleanup Queue Table
```sql
-- Create queue table for async file deletion
CREATE TABLE IF NOT EXISTS storage_cleanup_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bucket VARCHAR(100) NOT NULL,
  paths TEXT[] NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  processed_at TIMESTAMPTZ,
  error_message TEXT
);

CREATE INDEX idx_cleanup_queue_status ON storage_cleanup_queue(status)
  WHERE status = 'pending';
```

### Edge Function for File Deletion
```typescript
// supabase/functions/cleanup-reel-files/index.ts

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

Deno.serve(async (req: Request) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  // Process pending cleanup queue items
  const { data: queueItems, error } = await supabase
    .from('storage_cleanup_queue')
    .select('*')
    .eq('status', 'pending')
    .limit(50); // Process in batches

  if (error) {
    console.error('Failed to fetch queue:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
    });
  }

  let processed = 0;
  let failed = 0;

  for (const item of queueItems || []) {
    try {
      // Filter out null paths
      const validPaths = item.paths.filter((p: string | null) => p !== null);

      if (validPaths.length > 0) {
        // Delete files from Storage
        const { error: deleteError } = await supabase.storage
          .from(item.bucket)
          .remove(validPaths);

        if (deleteError) {
          throw deleteError;
        }
      }

      // Mark as processed
      await supabase
        .from('storage_cleanup_queue')
        .update({
          status: 'completed',
          processed_at: new Date().toISOString(),
        })
        .eq('id', item.id);

      processed++;
    } catch (err) {
      // Mark as failed
      await supabase
        .from('storage_cleanup_queue')
        .update({
          status: 'failed',
          error_message: err.message,
        })
        .eq('id', item.id);

      failed++;
      console.error(`Failed to cleanup item ${item.id}:`, err);
    }
  }

  return new Response(JSON.stringify({
    success: true,
    processed,
    failed,
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

### Trigger Edge Function via pg_cron
```sql
-- Alternative: Call Edge Function directly from cron
-- This requires pg_net extension

-- Option 1: Use pg_net to call Edge Function
SELECT cron.schedule(
  'process-storage-cleanup',
  '*/15 * * * *', -- Every 15 minutes
  $$
  SELECT net.http_post(
    url := 'https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/cleanup-reel-files',
    headers := '{"Authorization": "Bearer ' || current_setting('supabase.service_role_key') || '"}'::jsonb
  );
  $$
);

-- Option 2: Just use the queue-based approach (simpler)
-- Edge Function can be triggered by Supabase webhooks or scheduled externally
```

### Rollback SQL
```sql
-- Rollback: 20260128001212_create_cleanup_reels_cron

-- Unschedule cron jobs
SELECT cron.unschedule('cleanup-expired-reels');
SELECT cron.unschedule('cleanup-failed-reels');
SELECT cron.unschedule('process-storage-cleanup');

-- Drop functions
DROP FUNCTION IF EXISTS cleanup_expired_reels();
DROP FUNCTION IF EXISTS cleanup_failed_reels();

-- Drop queue table
DROP TABLE IF EXISTS storage_cleanup_queue;
```

## Definition of Done
- [ ] Criteres d'acceptance valides
- [ ] pg_cron job scheduled (3 AM UTC daily)
- [ ] cleanup_expired_reels function works correctly
- [ ] Expired reels marked with status = 'expired'
- [ ] File paths nullified after marking
- [ ] Edge Function deletes Storage files
- [ ] Already expired reels skipped
- [ ] Failed reels cleaned up separately
- [ ] Logging implemented for debugging
- [ ] Error handling doesn't stop batch processing
- [ ] `flutter analyze --fatal-infos` passe (N/A - backend)

## Estimation
**Points** : 3
**Complexite** : Moyenne
**Risque** : Moyen (data deletion - irreversible)

## Dependances
- S01: Reels table must exist

## Stories Dependantes
- None (end of lifecycle management)
