# Story S02: Creer table scheduled_notifications

## Description
En tant que developpeur backend, je veux creer une table scheduled_notifications, afin de stocker les rappels programmes avec leurs dates d'envoi et leur statut.

## Criteres d'Acceptance (Gherkin)
- [ ] Given the database schema When the migration create_scheduled_notifications is applied Then table scheduled_notifications should exist with all required columns (id, event_id, user_id, scheduled_at, notification_type, sent, sent_at, created_at)
- [ ] Given a scheduled notification for event 'event-123' When the event 'event-123' is deleted Then the scheduled notification should be automatically deleted (CASCADE)
- [ ] Given 1000 scheduled notifications When querying notifications where scheduled_at <= NOW() AND sent = FALSE Then the query should use idx_scheduled_pending and be performant (< 10ms)
- [ ] Given a scheduled notification When inserting with notification_type = 'invalid_type' Then the insert should fail with constraint violation (only '1_week', '1_day', '1_hour' allowed)
- [ ] Given a scheduled notification When inserting a duplicate (same event_id + notification_type) Then the insert should fail with unique constraint violation
- [ ] Given a user with scheduled notifications When they query scheduled_notifications Then they should only see their own notifications (RLS)

## Fichiers Concernes
### A Creer
- Migration SQL via Supabase MCP: `20260128100002_create_scheduled_notifications`

### A Modifier
- Aucun (nouvelle table)

## Notes Techniques

### Migration SQL
```sql
-- Migration: 20260128100002_create_scheduled_notifications
-- Description: Create table for scheduled event reminders
-- Source: APP-02 - Notifications de rappel RDV

CREATE TABLE IF NOT EXISTS scheduled_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES wedding_events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  -- IMPORTANT: Utiliser TIMESTAMPTZ pour gestion correcte des fuseaux horaires
  scheduled_at TIMESTAMPTZ NOT NULL,
  notification_type VARCHAR(20) NOT NULL,
  sent BOOLEAN DEFAULT FALSE NOT NULL,
  sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- Constraint for valid notification types
  CONSTRAINT chk_notification_type
    CHECK (notification_type IN ('1_week', '1_day', '1_hour')),

  -- Prevent duplicate notifications for same event/type
  CONSTRAINT uq_event_notification_type
    UNIQUE (event_id, notification_type)
);

-- Index for finding pending notifications (used by pg_cron job)
CREATE INDEX IF NOT EXISTS idx_scheduled_pending
  ON scheduled_notifications(scheduled_at)
  WHERE sent = FALSE;

-- Index for finding notifications by event
CREATE INDEX IF NOT EXISTS idx_scheduled_by_event
  ON scheduled_notifications(event_id);

-- Index for finding notifications by user
CREATE INDEX IF NOT EXISTS idx_scheduled_by_user
  ON scheduled_notifications(user_id);

-- Enable RLS
ALTER TABLE scheduled_notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policy: User can see their own scheduled notifications
CREATE POLICY "User sees own scheduled notifications"
  ON scheduled_notifications
  FOR SELECT
  USING (user_id = auth.uid());

-- RLS Policy: User can manage their own scheduled notifications
CREATE POLICY "User manages own scheduled notifications"
  ON scheduled_notifications
  FOR ALL
  USING (user_id = auth.uid());

-- Comment for documentation
COMMENT ON TABLE scheduled_notifications IS 'Queue for scheduled event reminders (APP-02). Processed by pg_cron job every 5 minutes.';
COMMENT ON COLUMN scheduled_notifications.notification_type IS 'Type: 1_week, 1_day, or 1_hour';
COMMENT ON COLUMN scheduled_notifications.sent IS 'TRUE when notification has been sent to notifications_outbox';
```

### Rollback SQL
```sql
DROP POLICY IF EXISTS "User manages own scheduled notifications" ON scheduled_notifications;
DROP POLICY IF EXISTS "User sees own scheduled notifications" ON scheduled_notifications;
DROP INDEX IF EXISTS idx_scheduled_by_user;
DROP INDEX IF EXISTS idx_scheduled_by_event;
DROP INDEX IF EXISTS idx_scheduled_pending;
DROP TABLE IF EXISTS scheduled_notifications;
```

### Verification post-migration
```sql
-- Verify table exists
SELECT table_name FROM information_schema.tables WHERE table_name = 'scheduled_notifications';

-- Verify constraints
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'scheduled_notifications';

-- Verify indexes
SELECT indexname FROM pg_indexes WHERE tablename = 'scheduled_notifications';

-- Verify RLS is enabled
SELECT relname, relrowsecurity FROM pg_class WHERE relname = 'scheduled_notifications';
```

## Definition of Done
- [ ] Criteres valides
- [ ] Migration appliquee via Supabase MCP
- [ ] Table creee avec toutes les colonnes
- [ ] Constraints CHECK et UNIQUE fonctionnels
- [ ] 3 index crees (pending, by_event, by_user)
- [ ] RLS activee avec 2 policies
- [ ] CASCADE delete teste
- [ ] Rollback documente

## Estimation
**Points** : 3
**Complexite** : Faible
**Risque** : Faible (nouvelle table, pas de migration de donnees)

## Dependances
- Aucune (peut etre fait en parallele avec S01)

## Stories Dependantes
- S03: Creer pg_cron job pour traitement notifications
- S06: Implementer scheduling des rappels dans repository
