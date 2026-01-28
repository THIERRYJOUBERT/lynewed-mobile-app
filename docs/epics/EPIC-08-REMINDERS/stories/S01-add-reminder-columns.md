# Story S01: Ajouter colonnes reminder a wedding_events

## Description
En tant que developpeur backend, je veux ajouter les colonnes de rappel a la table wedding_events, afin de permettre le stockage des preferences de rappel multi-selection pour chaque evenement.

## Criteres d'Acceptance (Gherkin)
- [ ] Given the wedding_events table exists with 9 rows When the migration add_reminder_columns is applied Then wedding_events should have column reminder_1_week of type BOOLEAN DEFAULT FALSE
- [ ] Given the wedding_events table exists When the migration is applied Then wedding_events should have column reminder_1_day of type BOOLEAN DEFAULT FALSE
- [ ] Given the wedding_events table exists When the migration is applied Then wedding_events should have column reminder_1_hour of type BOOLEAN DEFAULT FALSE
- [ ] Given 9 existing wedding events When the migration is applied Then all existing event data (title, date, location) should be unchanged and reminder columns should be FALSE
- [ ] Given a wedding event When the bride enables all three reminders Then reminder_1_week, reminder_1_day, and reminder_1_hour can all be TRUE simultaneously (multi-selection)
- [ ] Given the migration is applied When querying events with active reminders Then idx_wedding_events_reminders index should be used for performance

## Fichiers Concernes
### A Creer
- Migration SQL via Supabase MCP: `20260128100001_add_reminder_columns_to_wedding_events`

### A Modifier
- Table `wedding_events` (ajout de 3 colonnes boolean)

## Notes Techniques

### Migration SQL
```sql
-- Migration: 20260128100001_add_reminder_columns_to_wedding_events
-- Description: Add multi-selection reminder columns to wedding_events
-- Source: APP-02 - Notifications de rappel RDV

-- Add reminder columns with safe defaults
ALTER TABLE wedding_events
  ADD COLUMN IF NOT EXISTS reminder_1_week BOOLEAN DEFAULT FALSE NOT NULL;

ALTER TABLE wedding_events
  ADD COLUMN IF NOT EXISTS reminder_1_day BOOLEAN DEFAULT FALSE NOT NULL;

ALTER TABLE wedding_events
  ADD COLUMN IF NOT EXISTS reminder_1_hour BOOLEAN DEFAULT FALSE NOT NULL;

-- Create index for finding events with active reminders
CREATE INDEX IF NOT EXISTS idx_wedding_events_reminders
  ON wedding_events(event_date)
  WHERE reminder_1_week = TRUE OR reminder_1_day = TRUE OR reminder_1_hour = TRUE;

-- Verification
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'wedding_events' AND column_name = 'reminder_1_week'
  ) THEN
    RAISE EXCEPTION 'Migration failed: reminder_1_week column not created';
  END IF;
END $$;

-- Comments for documentation
COMMENT ON COLUMN wedding_events.reminder_1_week IS 'Send reminder 1 week before event (APP-02)';
COMMENT ON COLUMN wedding_events.reminder_1_day IS 'Send reminder 1 day before event (APP-02)';
COMMENT ON COLUMN wedding_events.reminder_1_hour IS 'Send reminder 1 hour before event (APP-02)';
```

### Rollback SQL
```sql
DROP INDEX IF EXISTS idx_wedding_events_reminders;
ALTER TABLE wedding_events DROP COLUMN IF EXISTS reminder_1_hour;
ALTER TABLE wedding_events DROP COLUMN IF EXISTS reminder_1_day;
ALTER TABLE wedding_events DROP COLUMN IF EXISTS reminder_1_week;
```

### Verification post-migration
```sql
-- Verify columns exist
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'wedding_events'
AND column_name IN ('reminder_1_week', 'reminder_1_day', 'reminder_1_hour');

-- Verify existing data preserved
SELECT COUNT(*) FROM wedding_events; -- Should still be 9
```

## Definition of Done
- [ ] Criteres valides
- [ ] Migration appliquee via Supabase MCP
- [ ] Colonnes verifiees en production
- [ ] Index cree et fonctionnel
- [ ] Rollback documente et teste
- [ ] Aucune donnee existante perdue

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible (migration non-destructive avec IF NOT EXISTS)

## Dependances
- Aucune (premiere story de l'Epic)

## Stories Dependantes
- S04: Mettre a jour entite WeddingEvent en Dart (a besoin des colonnes)
- S05: Ajouter checkboxes rappel dans formulaire event (via S04)
- S06: Implementer scheduling des rappels dans repository (via S04)
