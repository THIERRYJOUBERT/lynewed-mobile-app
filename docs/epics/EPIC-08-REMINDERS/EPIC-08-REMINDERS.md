# EPIC-08-REMINDERS

> Resume : Notifications de rappel RDV pour l'agenda existant (APP-02)
> Status : 🔵 Draft
> Domaine : Backend / Database / Notifications / Flutter
> Cree le : 2026-01-28

---

## Contexte

### Pourquoi cet Epic

L'agenda (wedding_events) existe dans l'application avec des fonctionnalites de base. Les brides peuvent creer des evenements avec date, heure, lieu et description. Cependant, il n'existe **aucun systeme de rappel automatique**.

**Principe fondamental** : **ENRICHIR l'agenda existant, pas le recreer**.

**Etat actuel verifie en production (Supabase MCP - Project hekyovgnovhfhmkpfrna):**

| Element | Etat actuel | Probleme |
|---------|-------------|----------|
| `wedding_events` table | 9 rows | Colonne `reminder_sent` existe (placeholder, non utilisee) |
| `reminder_sent` | Boolean | Placeholder simple, ne supporte pas multi-rappels |
| Colonnes rappel multi | ABSENTES | Pas de reminder_1_week, reminder_1_day, reminder_1_hour |
| `scheduled_notifications` | TABLE ABSENTE | Pas de file d'attente pour rappels programmes |
| `notifications_outbox` | 247 rows | Queue FCM existante et fonctionnelle |
| pg_cron | DISPONIBLE | Extension Supabase pour jobs planifies |

**Systeme existant** :
- FCM (Firebase Cloud Messaging) : Production-ready, fonctionne
- Table `notifications_outbox` : Queue pour push notifications
- Entite `WeddingEvent` en Dart avec `reminderMinutes` (default: [1440, 60] = 1 jour + 1 heure)

### Objectif

Permettre aux brides de configurer des rappels multi-selectionnes (1 semaine, 1 jour, 1 heure avant) pour leurs evenements de mariage, avec envoi automatique via FCM.

### Piliers Techniques Concernes

| Pilier | Implication pour cet Epic |
|--------|---------------------------|
| **Supabase Database** | Nouvelles colonnes wedding_events, table scheduled_notifications |
| **pg_cron** | Job pour traitement des rappels programmes |
| **FCM** | Envoi des notifications (deja en place) |
| **Flutter/Dart** | Mise a jour entite WeddingEvent, UI formulaire |

---

## Architecture Cible

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SYSTEME DE RAPPELS RDV (APP-02)                           │
│                                                                              │
│  TABLE wedding_events (enrichie)                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  ... colonnes existantes (title, event_date, location, etc.)         │   │
│  │  + reminder_1_week BOOLEAN DEFAULT FALSE                             │   │
│  │  + reminder_1_day BOOLEAN DEFAULT FALSE                              │   │
│  │  + reminder_1_hour BOOLEAN DEFAULT FALSE                             │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                           │                                                  │
│                           │ Trigger/Repository                               │
│                           ▼                                                  │
│  TABLE scheduled_notifications (nouvelle)                                    │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  id UUID PRIMARY KEY                                                  │   │
│  │  event_id UUID REFERENCES wedding_events(id) ON DELETE CASCADE       │   │
│  │  user_id UUID REFERENCES profiles(id)                                 │   │
│  │  scheduled_at TIMESTAMP NOT NULL                                      │   │
│  │  notification_type VARCHAR(20) ('1_week', '1_day', '1_hour')         │   │
│  │  sent BOOLEAN DEFAULT FALSE                                           │   │
│  │  sent_at TIMESTAMP                                                    │   │
│  │  created_at TIMESTAMP DEFAULT NOW()                                   │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                           │                                                  │
│                           │ pg_cron (every minute)                           │
│                           ▼                                                  │
│  TABLE notifications_outbox (existante)                                      │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  event_type: 'event_reminder'                                         │   │
│  │  payload: { user_id, event_id, event_title, reminder_type }          │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                           │                                                  │
│                           │ FCM Worker (existant)                            │
│                           ▼                                                  │
│                    📱 Push Notification                                      │
│                    "Rappel : [Titre] dans 1 jour"                           │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Stories

| # | Story | Domaine | Dep. | Criteres cles | Source PRD | Complexite |
|---|-------|---------|------|---------------|------------|------------|
| S01 | Ajouter colonnes reminder a wedding_events | DB | - | 3 colonnes boolean, migration safe | APP-02 | S |
| S02 | Creer table scheduled_notifications | DB | - | CASCADE delete, index performance, RLS | APP-02 | S |
| S03 | Creer pg_cron job pour traitement notifications | DB | S02 | Job toutes les minutes, atomique, idempotent | APP-02 | M |
| S04 | Mettre a jour entite WeddingEvent en Dart | Dart | S01 | 3 nouveaux champs, serialization, tests | APP-02 | S |
| S05 | Ajouter checkboxes rappel dans formulaire event | UI | S04 | Multi-selection, coherence UI, validation | APP-02 | M |
| S06 | Implementer scheduling des rappels dans repository | Dart | S02,S04 | CRUD scheduled_notifications, calcul dates | APP-02 | M |
| S07 | Integrer avec notifications_outbox existante | DB+Dart | S03,S06 | Format payload correct, tests E2E | APP-02 | S |

---

## Detail des Stories

### S01 : Ajouter colonnes reminder a wedding_events

**Criteres cles** :
- Colonne `reminder_1_week` BOOLEAN DEFAULT FALSE ajoutee
- Colonne `reminder_1_day` BOOLEAN DEFAULT FALSE ajoutee
- Colonne `reminder_1_hour` BOOLEAN DEFAULT FALSE ajoutee
- Migration non-destructive (preserve les donnees existantes)
- Les 9 events existants ont les nouvelles colonnes a FALSE

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 4 (APP-02)

**Complexite** : S (Small) - Ajout colonnes simples

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Wedding events reminder columns

  Scenario: Adding reminder_1_week column
    Given the wedding_events table exists with 9 rows
    When the migration add_reminder_columns is applied
    Then wedding_events should have column reminder_1_week of type BOOLEAN
    And reminder_1_week should default to FALSE
    And all existing events should have reminder_1_week = FALSE

  Scenario: Adding reminder_1_day column
    Given the wedding_events table exists
    When the migration add_reminder_columns is applied
    Then wedding_events should have column reminder_1_day of type BOOLEAN
    And reminder_1_day should default to FALSE

  Scenario: Adding reminder_1_hour column
    Given the wedding_events table exists
    When the migration add_reminder_columns is applied
    Then wedding_events should have column reminder_1_hour of type BOOLEAN
    And reminder_1_hour should default to FALSE

  Scenario: Multi-selection of reminders
    Given a wedding event
    When the bride enables all three reminders
    Then reminder_1_week should be TRUE
    And reminder_1_day should be TRUE
    And reminder_1_hour should be TRUE

  Scenario: Existing data is preserved
    Given 9 existing wedding events
    When the migration is applied
    Then all existing event data (title, date, location) should be unchanged
```

**Details techniques** :

**Migration SQL** :
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

**Rollback** :
```sql
-- Rollback: 20260128100001_add_reminder_columns_to_wedding_events

DROP INDEX IF EXISTS idx_wedding_events_reminders;

ALTER TABLE wedding_events DROP COLUMN IF EXISTS reminder_1_hour;
ALTER TABLE wedding_events DROP COLUMN IF EXISTS reminder_1_day;
ALTER TABLE wedding_events DROP COLUMN IF EXISTS reminder_1_week;
```

---

### S02 : Creer table scheduled_notifications

**Criteres cles** :
- Table `scheduled_notifications` creee avec toutes les colonnes requises
- Foreign key vers wedding_events avec ON DELETE CASCADE
- Foreign key vers profiles pour user_id
- Index sur scheduled_at pour requetes performantes (notifications a envoyer)
- RLS activee avec policy pour le user

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 4 (APP-02)

**Complexite** : S (Small) - Table avec FKs et index

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Scheduled notifications table

  Scenario: Creating scheduled_notifications table
    Given the database schema
    When the migration create_scheduled_notifications is applied
    Then table scheduled_notifications should exist
    And it should have column id of type UUID with default gen_random_uuid()
    And it should have column event_id of type UUID referencing wedding_events(id)
    And it should have column user_id of type UUID referencing profiles(id)
    And it should have column scheduled_at of type TIMESTAMP NOT NULL
    And it should have column notification_type of type VARCHAR(20) NOT NULL
    And it should have column sent of type BOOLEAN default FALSE
    And it should have column sent_at of type TIMESTAMP nullable
    And it should have column created_at of type TIMESTAMP default NOW()

  Scenario: CASCADE delete when event is deleted
    Given a scheduled notification for event 'event-123'
    When the event 'event-123' is deleted
    Then the scheduled notification should be automatically deleted
    And no orphan notifications should exist

  Scenario: Index on pending notifications
    Given 1000 scheduled notifications
    When querying notifications where scheduled_at <= NOW() AND sent = FALSE
    Then the query should use idx_scheduled_pending
    And the query should be performant (< 10ms)

  Scenario: Constraint on notification_type
    Given a scheduled notification
    When inserting with notification_type = 'invalid_type'
    Then the insert should fail with constraint violation
    And only '1_week', '1_day', '1_hour' should be allowed

  Scenario: RLS allows user to see own notifications
    Given a user with scheduled notifications
    When they query scheduled_notifications
    Then they should only see their own notifications
    And other users' notifications should not be visible
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128100002_create_scheduled_notifications
-- Description: Create table for scheduled event reminders
-- Source: APP-02 - Notifications de rappel RDV

CREATE TABLE IF NOT EXISTS scheduled_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES wedding_events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  scheduled_at TIMESTAMP NOT NULL,
  notification_type VARCHAR(20) NOT NULL,
  sent BOOLEAN DEFAULT FALSE NOT NULL,
  sent_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,

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
COMMENT ON TABLE scheduled_notifications IS 'Queue for scheduled event reminders (APP-02). Processed by pg_cron job every minute.';
COMMENT ON COLUMN scheduled_notifications.notification_type IS 'Type: 1_week, 1_day, or 1_hour';
COMMENT ON COLUMN scheduled_notifications.sent IS 'TRUE when notification has been sent to notifications_outbox';
```

**Rollback** :
```sql
-- Rollback: 20260128100002_create_scheduled_notifications

DROP POLICY IF EXISTS "User manages own scheduled notifications" ON scheduled_notifications;
DROP POLICY IF EXISTS "User sees own scheduled notifications" ON scheduled_notifications;
DROP INDEX IF EXISTS idx_scheduled_by_user;
DROP INDEX IF EXISTS idx_scheduled_by_event;
DROP INDEX IF EXISTS idx_scheduled_pending;
DROP TABLE IF EXISTS scheduled_notifications;
```

---

### S03 : Creer pg_cron job pour traitement notifications

**Criteres cles** :
- Job pg_cron execute toutes les minutes
- Selectionne les notifications ou scheduled_at <= NOW() et sent = FALSE
- Insere dans notifications_outbox avec payload correct
- Met a jour sent = TRUE et sent_at = NOW() de maniere atomique
- Idempotent (re-execution ne cree pas de doublons)
- Gestion des erreurs (ne bloque pas si notifications_outbox fail)

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 4 (APP-02)

**Complexite** : M (Medium) - Logic pg_cron et atomicite

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: pg_cron job for notification processing

  Scenario: Job is scheduled every minute
    Given pg_cron extension is enabled
    When the migration creates the cron job
    Then job 'send-scheduled-notifications' should exist
    And it should run with schedule '* * * * *'

  Scenario: Processing pending notifications
    Given a scheduled notification with scheduled_at = NOW() - 1 minute
    And sent = FALSE
    When the cron job runs
    Then the notification should be inserted into notifications_outbox
    And the scheduled notification should have sent = TRUE
    And sent_at should be set to current timestamp

  Scenario: Correct payload format
    Given a scheduled notification for event 'Mon RDV Photographe'
    And notification_type = '1_day'
    When the notification is processed
    Then notifications_outbox should contain:
      | event_type | payload |
      | event_reminder | {"user_id": "...", "event_id": "...", "event_title": "Mon RDV Photographe", "reminder_type": "1_day"} |

  Scenario: Idempotency - no duplicate processing
    Given a scheduled notification that has already been sent
    When the cron job runs again
    Then no new entry should be created in notifications_outbox
    And the scheduled notification should remain unchanged

  Scenario: Atomic transaction
    Given multiple pending notifications
    When the cron job runs
    Then either all notifications are processed
    Or none are processed (no partial state)

  Scenario: Future notifications are not processed
    Given a scheduled notification with scheduled_at = NOW() + 1 hour
    When the cron job runs
    Then the notification should NOT be processed
    And sent should remain FALSE
```

**Details techniques** :

**Migration SQL** :
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

-- Schedule the cron job to run every minute
SELECT cron.schedule(
  'send-scheduled-notifications',  -- job name
  '* * * * *',                     -- every minute
  $$SELECT process_scheduled_notifications()$$
);

-- Comment for documentation
COMMENT ON FUNCTION process_scheduled_notifications IS
  'Processes pending scheduled notifications and inserts them into notifications_outbox. Called by pg_cron every minute.';
```

**Rollback** :
```sql
-- Rollback: 20260128100003_create_scheduled_notifications_cron

-- Remove the cron job
SELECT cron.unschedule('send-scheduled-notifications');

-- Drop the function
DROP FUNCTION IF EXISTS process_scheduled_notifications;
```

**Testing the cron job manually** :
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
```

---

### S04 : Mettre a jour entite WeddingEvent en Dart

**Criteres cles** :
- Ajouter `reminder1Week`, `reminder1Day`, `reminder1Hour` (bool) a l'entite
- Mettre a jour `fromJson` et `toJson` pour serialization
- Mettre a jour le model correspondant
- Backward compatible (valeurs par defaut FALSE si absentes)
- Tests unitaires pour serialization

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 4 (APP-02)

**Complexite** : S (Small) - Modification entite simple

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: WeddingEvent entity with reminder fields

  Scenario: Entity has reminder fields
    Given the WeddingEvent entity
    Then it should have field reminder1Week of type bool
    And it should have field reminder1Day of type bool
    And it should have field reminder1Hour of type bool

  Scenario: Default values are FALSE
    Given a new WeddingEvent created without reminder values
    When the entity is instantiated
    Then reminder1Week should be false
    And reminder1Day should be false
    And reminder1Hour should be false

  Scenario: JSON serialization includes reminders
    Given a WeddingEvent with reminder1Week = true and reminder1Day = true
    When toJson is called
    Then the JSON should contain "reminder_1_week": true
    And the JSON should contain "reminder_1_day": true
    And the JSON should contain "reminder_1_hour": false

  Scenario: JSON deserialization handles reminders
    Given a JSON with "reminder_1_week": true, "reminder_1_day": false, "reminder_1_hour": true
    When WeddingEvent.fromJson is called
    Then reminder1Week should be true
    And reminder1Day should be false
    And reminder1Hour should be true

  Scenario: Backward compatibility with old data
    Given a JSON without reminder fields (old format)
    When WeddingEvent.fromJson is called
    Then reminder1Week should default to false
    And reminder1Day should default to false
    And reminder1Hour should default to false
    And no exception should be thrown

  Scenario: CopyWith supports reminder fields
    Given a WeddingEvent with reminder1Week = false
    When copyWith(reminder1Week: true) is called
    Then the new entity should have reminder1Week = true
    And other fields should remain unchanged
```

**Details techniques** :

**Fichiers a modifier** :
- `lib/features/my_wedding/domain/entities/wedding_event.dart`
- `lib/features/my_wedding/data/models/wedding_event_model.dart`

**Code Dart (entity)** :
```dart
// In wedding_event.dart

class WeddingEvent extends Equatable {
  final String id;
  final String weddingId;
  final String title;
  final String? description;
  final DateTime eventDate;
  final DateTime? eventEndDate;
  final String? location;
  // ... existing fields ...

  // NEW: Reminder flags
  final bool reminder1Week;
  final bool reminder1Day;
  final bool reminder1Hour;

  const WeddingEvent({
    required this.id,
    required this.weddingId,
    required this.title,
    this.description,
    required this.eventDate,
    this.eventEndDate,
    this.location,
    // ... existing fields ...
    this.reminder1Week = false,  // NEW
    this.reminder1Day = false,   // NEW
    this.reminder1Hour = false,  // NEW
  });

  WeddingEvent copyWith({
    // ... existing params ...
    bool? reminder1Week,
    bool? reminder1Day,
    bool? reminder1Hour,
  }) {
    return WeddingEvent(
      // ... existing fields ...
      reminder1Week: reminder1Week ?? this.reminder1Week,
      reminder1Day: reminder1Day ?? this.reminder1Day,
      reminder1Hour: reminder1Hour ?? this.reminder1Hour,
    );
  }

  @override
  List<Object?> get props => [
    // ... existing props ...
    reminder1Week,
    reminder1Day,
    reminder1Hour,
  ];
}
```

**Code Dart (model)** :
```dart
// In wedding_event_model.dart

class WeddingEventModel extends WeddingEvent {
  // Constructor with super...

  factory WeddingEventModel.fromJson(Map<String, dynamic> json) {
    return WeddingEventModel(
      id: json['id'] as String,
      weddingId: json['wedding_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      eventEndDate: json['event_end_date'] != null
        ? DateTime.parse(json['event_end_date'] as String)
        : null,
      location: json['location'] as String?,
      // ... existing fields ...
      // NEW: With backward compatibility
      reminder1Week: json['reminder_1_week'] as bool? ?? false,
      reminder1Day: json['reminder_1_day'] as bool? ?? false,
      reminder1Hour: json['reminder_1_hour'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wedding_id': weddingId,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String(),
      'event_end_date': eventEndDate?.toIso8601String(),
      'location': location,
      // ... existing fields ...
      // NEW
      'reminder_1_week': reminder1Week,
      'reminder_1_day': reminder1Day,
      'reminder_1_hour': reminder1Hour,
    };
  }
}
```

**Tests** :
```dart
// test/features/my_wedding/domain/entities/wedding_event_test.dart

group('WeddingEvent reminder fields', () {
  test('should have default values of false', () {
    final event = WeddingEvent(
      id: '1',
      weddingId: 'w1',
      title: 'Test Event',
      eventDate: DateTime.now(),
    );

    expect(event.reminder1Week, false);
    expect(event.reminder1Day, false);
    expect(event.reminder1Hour, false);
  });

  test('should serialize reminder fields to JSON', () {
    final model = WeddingEventModel(
      id: '1',
      weddingId: 'w1',
      title: 'Test Event',
      eventDate: DateTime.now(),
      reminder1Week: true,
      reminder1Day: true,
      reminder1Hour: false,
    );

    final json = model.toJson();

    expect(json['reminder_1_week'], true);
    expect(json['reminder_1_day'], true);
    expect(json['reminder_1_hour'], false);
  });

  test('should deserialize reminder fields from JSON', () {
    final json = {
      'id': '1',
      'wedding_id': 'w1',
      'title': 'Test Event',
      'event_date': DateTime.now().toIso8601String(),
      'reminder_1_week': true,
      'reminder_1_day': false,
      'reminder_1_hour': true,
    };

    final model = WeddingEventModel.fromJson(json);

    expect(model.reminder1Week, true);
    expect(model.reminder1Day, false);
    expect(model.reminder1Hour, true);
  });

  test('should handle missing reminder fields (backward compatibility)', () {
    final json = {
      'id': '1',
      'wedding_id': 'w1',
      'title': 'Test Event',
      'event_date': DateTime.now().toIso8601String(),
      // No reminder fields
    };

    final model = WeddingEventModel.fromJson(json);

    expect(model.reminder1Week, false);
    expect(model.reminder1Day, false);
    expect(model.reminder1Hour, false);
  });
});
```

---

### S05 : Ajouter checkboxes rappel dans formulaire event

**Criteres cles** :
- 3 checkboxes dans le formulaire creation/edition d'event
- Labels clairs : "1 semaine avant", "1 jour avant", "1 heure avant"
- Multi-selection possible
- Coherence UI avec le design system existant
- State management via cubit/bloc existant
- Validation : au moins un rappel si section ouverte (optionnel)

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 4 (APP-02)

**Complexite** : M (Medium) - UI + state management

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Reminder checkboxes in event form

  Scenario: Checkboxes are displayed in event form
    Given the bride is on the create/edit event page
    When the form is displayed
    Then there should be a "Rappels" section
    And it should contain checkbox "1 semaine avant"
    And it should contain checkbox "1 jour avant"
    And it should contain checkbox "1 heure avant"

  Scenario: Multi-selection of reminders
    Given the bride is creating an event
    When she checks "1 semaine avant"
    And she checks "1 jour avant"
    Then both checkboxes should be checked
    And "1 heure avant" should remain unchecked

  Scenario: Checkboxes reflect existing event values
    Given an existing event with reminder_1_week = true and reminder_1_day = true
    When the bride edits the event
    Then "1 semaine avant" should be pre-checked
    And "1 jour avant" should be pre-checked
    And "1 heure avant" should be unchecked

  Scenario: Saving event with reminders
    Given the bride has checked "1 heure avant"
    When she saves the event
    Then the event should be saved with reminder_1_hour = true
    And reminder_1_week and reminder_1_day should be false

  Scenario: UI consistency with design system
    Given the event form
    When viewing the reminders section
    Then the checkboxes should use the app's standard checkbox style
    And the labels should use the app's standard text style
    And the section should have consistent spacing

  Scenario: Past event reminders disabled
    Given an event with event_date in the past
    When editing the event
    Then the reminder checkboxes should be disabled
    And a message should explain "Rappels non disponibles pour les evenements passes"
```

**Details techniques** :

**Fichiers a modifier** :
- `lib/features/my_wedding/presentation/pages/event_form_page.dart` (ou equivalent)
- `lib/features/my_wedding/presentation/cubit/event_form_cubit.dart` (ou equivalent)
- `lib/features/my_wedding/presentation/cubit/event_form_state.dart`

**Code UI (widget)** :
```dart
// In event_form_page.dart (section rappels)

class _RemindersSection extends StatelessWidget {
  final bool reminder1Week;
  final bool reminder1Day;
  final bool reminder1Hour;
  final bool isEnabled;
  final Function(bool?) onReminder1WeekChanged;
  final Function(bool?) onReminder1DayChanged;
  final Function(bool?) onReminder1HourChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rappels',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (!isEnabled)
          Text(
            'Rappels non disponibles pour les evenements passes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        CheckboxListTile(
          title: const Text('1 semaine avant'),
          value: reminder1Week,
          onChanged: isEnabled ? onReminder1WeekChanged : null,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        ),
        CheckboxListTile(
          title: const Text('1 jour avant'),
          value: reminder1Day,
          onChanged: isEnabled ? onReminder1DayChanged : null,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        ),
        CheckboxListTile(
          title: const Text('1 heure avant'),
          value: reminder1Hour,
          onChanged: isEnabled ? onReminder1HourChanged : null,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        ),
      ],
    );
  }
}
```

---

### S06 : Implementer scheduling des rappels dans repository

**Criteres cles** :
- Lors de creation/update d'event, creer/modifier les scheduled_notifications
- Calcul correct des dates : event_date - 7 jours, - 1 jour, - 1 heure
- Si rappel desactive, supprimer la notification correspondante
- Gestion des updates (ne pas creer de doublons)
- Transaction atomique (event + notifications ensemble)

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 4 (APP-02)

**Complexite** : M (Medium) - Logic metier et transactions

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Reminder scheduling in repository

  Scenario: Creating scheduled notifications for new event
    Given a new event with event_date = "2026-02-15 14:00"
    And reminder_1_week = true, reminder_1_day = true, reminder_1_hour = false
    When the event is created
    Then scheduled_notifications should contain:
      | notification_type | scheduled_at |
      | 1_week | 2026-02-08 14:00 |
      | 1_day | 2026-02-14 14:00 |
    And no notification for 1_hour should exist

  Scenario: Updating reminders for existing event
    Given an existing event with reminder_1_week = true, reminder_1_day = false
    And a scheduled notification for 1_week exists
    When the event is updated with reminder_1_week = false, reminder_1_day = true
    Then the 1_week notification should be deleted
    And a new 1_day notification should be created

  Scenario: No duplicate notifications
    Given an event with reminder_1_week = true
    And a scheduled notification for 1_week already exists
    When the event is saved again with reminder_1_week = true
    Then only one 1_week notification should exist
    And no duplicate should be created

  Scenario: Delete notifications when event is deleted
    Given an event with scheduled notifications
    When the event is deleted
    Then all related scheduled notifications should be deleted (CASCADE)

  Scenario: Updating event date recalculates notification times
    Given an event with event_date = "2026-02-15 14:00"
    And reminder_1_day = true (notification at 2026-02-14 14:00)
    When the event_date is changed to "2026-02-20 10:00"
    Then the 1_day notification scheduled_at should be "2026-02-19 10:00"

  Scenario: Past reminder times are skipped
    Given an event with event_date = NOW() + 6 hours
    And reminder_1_week = true, reminder_1_day = true, reminder_1_hour = true
    When the event is created
    Then only 1_hour notification should be created
    And 1_week and 1_day should be skipped (already past)
```

**Details techniques** :

**Code Repository** :
```dart
// In wedding_event_repository_impl.dart

class WeddingEventRepositoryImpl implements WeddingEventRepository {
  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, WeddingEvent>> createEvent(WeddingEvent event) async {
    try {
      // Create event
      final response = await _supabase
          .from('wedding_events')
          .insert(WeddingEventModel.fromEntity(event).toJson())
          .select()
          .single();

      final createdEvent = WeddingEventModel.fromJson(response);

      // Schedule notifications
      await _scheduleReminders(createdEvent);

      return Right(createdEvent);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, WeddingEvent>> updateEvent(WeddingEvent event) async {
    try {
      // Update event
      final response = await _supabase
          .from('wedding_events')
          .update(WeddingEventModel.fromEntity(event).toJson())
          .eq('id', event.id)
          .select()
          .single();

      final updatedEvent = WeddingEventModel.fromJson(response);

      // Re-schedule notifications (delete old, create new)
      await _scheduleReminders(updatedEvent);

      return Right(updatedEvent);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  Future<void> _scheduleReminders(WeddingEvent event) async {
    final userId = _supabase.auth.currentUser!.id;
    final eventDate = event.eventDate;

    // Delete existing notifications for this event
    await _supabase
        .from('scheduled_notifications')
        .delete()
        .eq('event_id', event.id);

    // Calculate and insert new notifications
    final notifications = <Map<String, dynamic>>[];

    if (event.reminder1Week) {
      final scheduledAt = eventDate.subtract(const Duration(days: 7));
      if (scheduledAt.isAfter(DateTime.now())) {
        notifications.add({
          'event_id': event.id,
          'user_id': userId,
          'scheduled_at': scheduledAt.toIso8601String(),
          'notification_type': '1_week',
        });
      }
    }

    if (event.reminder1Day) {
      final scheduledAt = eventDate.subtract(const Duration(days: 1));
      if (scheduledAt.isAfter(DateTime.now())) {
        notifications.add({
          'event_id': event.id,
          'user_id': userId,
          'scheduled_at': scheduledAt.toIso8601String(),
          'notification_type': '1_day',
        });
      }
    }

    if (event.reminder1Hour) {
      final scheduledAt = eventDate.subtract(const Duration(hours: 1));
      if (scheduledAt.isAfter(DateTime.now())) {
        notifications.add({
          'event_id': event.id,
          'user_id': userId,
          'scheduled_at': scheduledAt.toIso8601String(),
          'notification_type': '1_hour',
        });
      }
    }

    if (notifications.isNotEmpty) {
      await _supabase.from('scheduled_notifications').insert(notifications);
    }
  }
}
```

---

### S07 : Integrer avec notifications_outbox existante

**Criteres cles** :
- Le payload insere dans notifications_outbox est correct pour le worker FCM
- Format : `event_type: 'event_reminder'`, payload avec user_id, event_id, event_title, reminder_type
- Le worker FCM existant peut parser ce format
- Message push format : "Rappel : [Titre] dans [duree]"
- Tests E2E du flow complet (scheduled -> outbox -> FCM mock)

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 4 (APP-02)

**Complexite** : S (Small) - Integration avec systeme existant

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Integration with notifications_outbox

  Scenario: Correct payload format for FCM worker
    Given a scheduled notification is processed
    When it is inserted into notifications_outbox
    Then the entry should have event_type = 'event_reminder'
    And payload should contain 'user_id' as UUID string
    And payload should contain 'event_id' as UUID string
    And payload should contain 'event_title' as string
    And payload should contain 'reminder_type' as '1_week', '1_day', or '1_hour'

  Scenario: FCM worker generates correct push message
    Given a notification in outbox with reminder_type = '1_day' and event_title = 'RDV Photographe'
    When the FCM worker processes it
    Then the push notification title should be "Rappel"
    And the body should be "RDV Photographe dans 1 jour"

  Scenario: FCM worker generates message for 1 week
    Given a notification with reminder_type = '1_week' and event_title = 'Essayage robe'
    When the FCM worker processes it
    Then the body should be "Essayage robe dans 1 semaine"

  Scenario: FCM worker generates message for 1 hour
    Given a notification with reminder_type = '1_hour' and event_title = 'Appel fleuriste'
    When the FCM worker processes it
    Then the body should be "Appel fleuriste dans 1 heure"

  Scenario: End-to-end flow test
    Given an event with reminder_1_day = true and event_date = NOW() + 1 day + 1 minute
    When 1 day passes and the cron job runs
    Then a push notification should be sent to the user
    And the notification should say "Rappel : [event title] dans 1 jour"
```

**Details techniques** :

**Verification du format notifications_outbox existant** :
```sql
-- Check current notifications_outbox schema
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'notifications_outbox';
```

**FCM Worker update (si necessaire)** :
```typescript
// In the FCM worker/Edge Function processing notifications_outbox

interface EventReminderPayload {
  user_id: string;
  event_id: string;
  event_title: string;
  reminder_type: '1_week' | '1_day' | '1_hour';
}

function formatReminderMessage(payload: EventReminderPayload): { title: string; body: string } {
  const durationMap = {
    '1_week': '1 semaine',
    '1_day': '1 jour',
    '1_hour': '1 heure',
  };

  return {
    title: 'Rappel',
    body: `${payload.event_title} dans ${durationMap[payload.reminder_type]}`,
  };
}

// In the main processing function
if (notification.event_type === 'event_reminder') {
  const payload = notification.payload as EventReminderPayload;
  const { title, body } = formatReminderMessage(payload);

  await sendFCMNotification({
    userId: payload.user_id,
    title,
    body,
    data: {
      type: 'event_reminder',
      event_id: payload.event_id,
    },
  });
}
```

**Test SQL pour verifier le flow** :
```sql
-- Simulate a scheduled notification being processed
INSERT INTO scheduled_notifications (event_id, user_id, scheduled_at, notification_type)
VALUES (
  '00000000-0000-0000-0000-000000000001',  -- test event
  '00000000-0000-0000-0000-000000000002',  -- test user
  NOW() - INTERVAL '1 minute',              -- in the past
  '1_day'
);

-- Run the processing function
SELECT process_scheduled_notifications();

-- Check notifications_outbox
SELECT * FROM notifications_outbox
WHERE event_type = 'event_reminder'
ORDER BY created_at DESC
LIMIT 1;
```

---

## Risques et Mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| pg_cron ne s'execute pas | HAUT - Notifications jamais envoyees | Monitoring du job, alerting si 0 executions en 5 min |
| Doublons de notifications | MOYEN - UX degradee | Constraint UNIQUE sur (event_id, notification_type) |
| Timezone incorrecte | HAUT - Rappels decales | Stocker en UTC, convertir a l'affichage |
| Notification pour event supprime | FAIBLE - Notification orpheline | CASCADE delete resout ce probleme |
| Performance avec beaucoup de notifications | MOYEN - Cron lent | Index sur scheduled_at WHERE sent=FALSE |
| Worker FCM ne reconnait pas event_reminder | MOYEN - Notifications ignorees | Tester integration avant merge |

---

## RLS Policies Summary

| Table | Policy | Access |
|-------|--------|--------|
| `wedding_events` (modified) | Existing policies | Bride can CRUD own wedding events |
| `scheduled_notifications` (new) | User sees own | User can read/manage own notifications |
| `notifications_outbox` (existing) | Service role | Worker only (no user access) |

---

## Ordre d'Execution Recommande

```
S01 (reminder columns) ──┬── S04 (Dart entity) ── S05 (UI checkboxes)
                         │
S02 (scheduled table) ───┴── S03 (pg_cron) ── S07 (integration)
                         │
                         └── S06 (repository)
```

**Ordre sequentiel recommande:**
1. S01 - Colonnes reminder (prerequis pour Dart)
2. S02 - Table scheduled_notifications (prerequis pour cron)
3. S03 - pg_cron job (peut etre fait apres S02)
4. S04 - Entite Dart WeddingEvent (apres S01)
5. S05 - UI checkboxes (apres S04)
6. S06 - Repository scheduling (apres S02 et S04)
7. S07 - Integration outbox (apres S03 et S06)

---

## References PRD

| Section PRD | Contenu utilise |
|-------------|-----------------|
| Section 4 (APP-02) | Description complete des rappels RDV |
| Section 4 - Contexte existant | Etat de wedding_events et notifications_outbox |
| Section 4 - User Stories | US-02.1 a US-02.4 |
| Section 4 - Specifications techniques | SQL pour colonnes et scheduled_notifications |
| Section 4 - Edge Function (pg_cron) | Job de traitement |
| Section 4 - Integration UI | Checkboxes multi-selection |
| Section 4 - Criteres d'acceptation | Multi-selection, CASCADE, format message |

---

## Prochaine Etape

Apres validation de cet Epic:
1. Executer `/create-story EPIC-08` pour creer les fichiers story individuels
2. Appliquer les migrations S01, S02, S03 sur branche Supabase de dev
3. Implementer S04, S05, S06 en Dart avec TDD
4. Tester le flow complet S07
5. Valider avec flutter analyze --fatal-infos
6. Merger en production
