# Story S03: Creer pg_cron job pour traitement notifications

## Description
En tant que developpeur backend, je veux creer un job pg_cron qui traite les notifications programmees, afin d'envoyer automatiquement les rappels via notifications_outbox a la bonne heure.

## Criteres d'Acceptance (Gherkin)
- [ ] Given pg_cron extension is enabled When the migration creates the cron job Then job 'send-scheduled-notifications' should exist with schedule '*/5 * * * *' (every 5 minutes)
- [ ] Given a scheduled notification with scheduled_at <= NOW() and sent = FALSE When the cron job runs Then the notification should be inserted into notifications_outbox with correct payload
- [ ] Given a scheduled notification processed by cron When checking the record Then sent should be TRUE and sent_at should be set to current timestamp
- [ ] Given a notification in scheduled_notifications When inserted into notifications_outbox Then payload should contain: user_id, event_id, event_title, reminder_type
- [ ] Given a scheduled notification that has already been sent (sent = TRUE) When the cron job runs again Then no new entry should be created in notifications_outbox (idempotent)
- [ ] Given a scheduled notification with scheduled_at in the future When the cron job runs Then the notification should NOT be processed and sent should remain FALSE
- [ ] Given multiple pending notifications When the cron job runs Then the transaction should be atomic (all or nothing)

## Fichiers Concernes
### A Creer
- Migration SQL via Supabase MCP: `20260128100003_create_scheduled_notifications_cron`
- Function: `process_scheduled_notifications()`

### A Modifier
- Aucun (nouvelle fonction et job)

## Notes Techniques

### Migration SQL
```sql
-- Migration: 20260128100003_create_scheduled_notifications_cron
-- Description: Create pg_cron job to process scheduled notifications
-- Source: APP-02 - Notifications de rappel RDV

-- Enable pg_cron extension if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Function to process scheduled notifications (called by cron)
CREATE OR REPLACE FUNCTION process_scheduled_notifications()
RETURNS INTEGER AS $$
DECLARE
  processed_count INTEGER;
BEGIN
  -- Use a CTE to atomically select and mark notifications
  WITH notifications_to_send AS (
    SELECT
      sn.id,
      sn.user_id,
      sn.event_id,
      we.title AS event_title,
      sn.notification_type
    FROM scheduled_notifications sn
    JOIN wedding_events we ON we.id = sn.event_id
    WHERE sn.scheduled_at <= NOW()
      AND sn.sent = FALSE
    FOR UPDATE SKIP LOCKED  -- Prevent race conditions
  ),
  inserted AS (
    INSERT INTO notifications_outbox (event_type, payload, created_at)
    SELECT
      'event_reminder',
      jsonb_build_object(
        'user_id', nts.user_id,
        'event_id', nts.event_id,
        'event_title', nts.event_title,
        'reminder_type', nts.notification_type
      ),
      NOW()
    FROM notifications_to_send nts
    RETURNING 1
  ),
  updated AS (
    UPDATE scheduled_notifications sn
    SET
      sent = TRUE,
      sent_at = NOW()
    FROM notifications_to_send nts
    WHERE sn.id = nts.id
    RETURNING 1
  )
  SELECT COUNT(*) INTO processed_count FROM updated;

  RETURN processed_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Schedule the cron job to run every 5 minutes
SELECT cron.schedule(
  'send-scheduled-notifications',  -- job name
  '*/5 * * * *',                   -- every 5 minutes
  $$SELECT process_scheduled_notifications()$$
);

-- Comment for documentation
COMMENT ON FUNCTION process_scheduled_notifications IS
  'Processes pending scheduled notifications and inserts them into notifications_outbox. Called by pg_cron every 5 minutes.';
```

### Rollback SQL
```sql
-- Remove the cron job
SELECT cron.unschedule('send-scheduled-notifications');

-- Drop the function
DROP FUNCTION IF EXISTS process_scheduled_notifications;
```

### Testing Manually
```sql
-- To test the function manually:
SELECT process_scheduled_notifications();

-- To check the cron job status:
SELECT * FROM cron.job WHERE jobname = 'send-scheduled-notifications';

-- To see recent job executions:
SELECT * FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'send-scheduled-notifications')
ORDER BY start_time DESC
LIMIT 10;

-- Insert test notification
INSERT INTO scheduled_notifications (event_id, user_id, scheduled_at, notification_type)
VALUES (
  (SELECT id FROM wedding_events LIMIT 1),
  (SELECT id FROM profiles LIMIT 1),
  NOW() - INTERVAL '1 minute',
  '1_day'
);

-- Run function and check result
SELECT process_scheduled_notifications();

-- Verify in outbox
SELECT * FROM notifications_outbox
WHERE event_type = 'event_reminder'
ORDER BY created_at DESC
LIMIT 5;
```

### Considerations
- **FOR UPDATE SKIP LOCKED** : Prevents race conditions if multiple cron executions overlap
- **SECURITY DEFINER** : Function runs with owner privileges (needed for cross-table operations)
- **Every 5 minutes** : Good balance between precision and performance for 248 users
- **Atomic transaction** : INSERT + UPDATE in same CTE ensures consistency

## Definition of Done
- [ ] Criteres valides
- [ ] pg_cron extension activee
- [ ] Function process_scheduled_notifications creee
- [ ] Job cron schedule toutes les 5 minutes
- [ ] Test manuel reussi
- [ ] Idempotence verifiee (re-execution sans doublons)
- [ ] Payload correct dans notifications_outbox
- [ ] Rollback documente et teste

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (logique pg_cron et atomicite a valider)

## Dependances
- S02: Creer table scheduled_notifications (table doit exister)

## Stories Dependantes
- S07: Integrer avec notifications_outbox existante (depend du payload format)
- S08: Tests E2E du flow complet (depend du cron job)
