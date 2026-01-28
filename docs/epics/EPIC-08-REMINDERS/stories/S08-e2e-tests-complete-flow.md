# Story S08: Tests E2E du flow complet de rappels

## Description
En tant que QA/developpeur, je veux valider le flow complet de rappels de bout en bout, afin de m'assurer que les notifications sont bien envoyees aux utilisateurs au bon moment avec le bon message.

## Criteres d'Acceptance (Gherkin)
- [ ] Given an event created with reminder_1_day = true and event_date = NOW() + 25h When 24h pass and the cron job runs Then a push notification should be sent with message "Rappel: [title] dans 1 jour"
- [ ] Given an event with all three reminders enabled When time passes and cron runs at appropriate intervals Then 3 distinct notifications should be sent (1 week, 1 day, 1 hour before)
- [ ] Given an event reminder notification sent When checking scheduled_notifications Then sent = TRUE and sent_at should be populated
- [ ] Given an event is deleted after notifications scheduled When checking scheduled_notifications Then all related notifications should be deleted (CASCADE verified)
- [ ] Given a bride updates reminder preferences for existing event When checking scheduled_notifications Then old notifications are deleted and new ones created
- [ ] Given the entire system When running for 24h with multiple events and reminders Then no duplicate notifications should be sent and all timings should be accurate

## Fichiers Concernes
### A Creer
- `test/integration/reminders_e2e_test.dart`
- `test/integration/reminders_flow_test.sql` (script SQL pour tests manuels)

### A Modifier
- Aucun (tests seulement)

## Notes Techniques

### Test E2E Strategy

Le test E2E complet necessite:
1. **Preparation** : Creer un event avec rappels
2. **Scheduling** : Verifier que scheduled_notifications contient les bonnes entrees
3. **Processing** : Simuler le passage du temps et execution du cron
4. **Verification** : Verifier que notifications_outbox contient le bon payload
5. **Cleanup** : Supprimer les donnees de test

### Script SQL pour test manuel complet
```sql
-- test/integration/reminders_flow_test.sql

-- ========================================
-- E2E TEST: Complete Reminders Flow
-- ========================================

BEGIN;

-- 1. SETUP: Create test wedding and event
-- ----------------------------------------

-- Get a test user
DO $$
DECLARE
  v_user_id UUID;
  v_wedding_id UUID;
  v_event_id UUID;
  v_notification_count INTEGER;
BEGIN
  -- Use existing user for test
  SELECT id INTO v_user_id FROM profiles LIMIT 1;
  RAISE NOTICE 'Using user: %', v_user_id;

  -- Get or create wedding
  SELECT id INTO v_wedding_id FROM weddings WHERE owner_id = v_user_id LIMIT 1;
  IF v_wedding_id IS NULL THEN
    INSERT INTO weddings (owner_id, wedding_date)
    VALUES (v_user_id, NOW() + INTERVAL '6 months')
    RETURNING id INTO v_wedding_id;
  END IF;
  RAISE NOTICE 'Using wedding: %', v_wedding_id;

  -- 2. CREATE EVENT with reminders
  -- ----------------------------------------
  INSERT INTO wedding_events (
    wedding_id,
    title,
    event_date,
    reminder_1_week,
    reminder_1_day,
    reminder_1_hour
  ) VALUES (
    v_wedding_id,
    'E2E Test Event - Rappels',
    NOW() + INTERVAL '8 days', -- Far enough for all reminders
    TRUE,
    TRUE,
    TRUE
  ) RETURNING id INTO v_event_id;
  RAISE NOTICE 'Created event: %', v_event_id;

  -- 3. SCHEDULE NOTIFICATIONS (simulate repository)
  -- ----------------------------------------
  -- Normally done by Flutter repository, but we simulate it here

  -- 1 week before
  INSERT INTO scheduled_notifications (event_id, user_id, scheduled_at, notification_type)
  SELECT v_event_id, v_user_id,
    (SELECT event_date FROM wedding_events WHERE id = v_event_id) - INTERVAL '7 days',
    '1_week';

  -- 1 day before
  INSERT INTO scheduled_notifications (event_id, user_id, scheduled_at, notification_type)
  SELECT v_event_id, v_user_id,
    (SELECT event_date FROM wedding_events WHERE id = v_event_id) - INTERVAL '1 day',
    '1_day';

  -- 1 hour before
  INSERT INTO scheduled_notifications (event_id, user_id, scheduled_at, notification_type)
  SELECT v_event_id, v_user_id,
    (SELECT event_date FROM wedding_events WHERE id = v_event_id) - INTERVAL '1 hour',
    '1_hour';

  RAISE NOTICE 'Scheduled 3 notifications';

  -- 4. VERIFY: Check scheduled notifications exist
  -- ----------------------------------------
  SELECT COUNT(*) INTO v_notification_count
  FROM scheduled_notifications
  WHERE event_id = v_event_id;

  ASSERT v_notification_count = 3, 'Expected 3 scheduled notifications, got ' || v_notification_count;
  RAISE NOTICE 'PASS: 3 notifications scheduled';

  -- 5. SIMULATE TIME PASSAGE: Move 1_week notification to past
  -- ----------------------------------------
  UPDATE scheduled_notifications
  SET scheduled_at = NOW() - INTERVAL '1 minute'
  WHERE event_id = v_event_id AND notification_type = '1_week';

  -- 6. RUN CRON: Process notifications
  -- ----------------------------------------
  PERFORM process_scheduled_notifications();
  RAISE NOTICE 'Cron job executed';

  -- 7. VERIFY: Check notification was sent
  -- ----------------------------------------
  -- Check scheduled_notifications
  SELECT COUNT(*) INTO v_notification_count
  FROM scheduled_notifications
  WHERE event_id = v_event_id AND sent = TRUE;

  ASSERT v_notification_count = 1, 'Expected 1 sent notification, got ' || v_notification_count;
  RAISE NOTICE 'PASS: 1 notification marked as sent';

  -- Check notifications_outbox
  SELECT COUNT(*) INTO v_notification_count
  FROM notifications_outbox
  WHERE event_type = 'event_reminder'
    AND payload->>'event_id' = v_event_id::text;

  ASSERT v_notification_count = 1, 'Expected 1 outbox entry, got ' || v_notification_count;
  RAISE NOTICE 'PASS: 1 notification in outbox';

  -- Verify payload format
  PERFORM 1 FROM notifications_outbox
  WHERE event_type = 'event_reminder'
    AND payload->>'event_id' = v_event_id::text
    AND payload->>'reminder_type' = '1_week'
    AND payload->>'event_title' = 'E2E Test Event - Rappels';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Payload format incorrect';
  END IF;
  RAISE NOTICE 'PASS: Payload format correct';

  -- 8. TEST CASCADE DELETE
  -- ----------------------------------------
  DELETE FROM wedding_events WHERE id = v_event_id;

  SELECT COUNT(*) INTO v_notification_count
  FROM scheduled_notifications
  WHERE event_id = v_event_id;

  ASSERT v_notification_count = 0, 'Expected 0 notifications after CASCADE, got ' || v_notification_count;
  RAISE NOTICE 'PASS: CASCADE delete worked';

  RAISE NOTICE '========================================';
  RAISE NOTICE 'ALL E2E TESTS PASSED';
  RAISE NOTICE '========================================';
END $$;

-- Cleanup (delete test notifications from outbox)
DELETE FROM notifications_outbox
WHERE event_type = 'event_reminder'
  AND payload->>'event_title' = 'E2E Test Event - Rappels';

ROLLBACK; -- Don't commit test data
```

### Test Integration Dart
```dart
// test/integration/reminders_e2e_test.dart

@TestOn('vm')
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Note: Ces tests necessitent une connexion Supabase de test

void main() {
  group('Reminders E2E Flow', () {
    late SupabaseClient supabase;
    String? testEventId;

    setUpAll(() async {
      // Initialize with test credentials
      supabase = SupabaseClient(
        'YOUR_SUPABASE_URL',
        'YOUR_SERVICE_ROLE_KEY', // For test only
      );
    });

    tearDownAll(() async {
      // Cleanup test data
      if (testEventId != null) {
        await supabase
            .from('wedding_events')
            .delete()
            .eq('id', testEventId!);
      }
    });

    test('complete reminder flow', () async {
      // 1. Create event with reminders
      final eventResponse = await supabase.from('wedding_events').insert({
        'wedding_id': 'test-wedding-id',
        'title': 'Integration Test Event',
        'event_date': DateTime.now().add(const Duration(days: 8)).toIso8601String(),
        'reminder_1_week': true,
        'reminder_1_day': true,
        'reminder_1_hour': true,
      }).select().single();

      testEventId = eventResponse['id'];
      expect(testEventId, isNotNull);

      // 2. Schedule notifications (simulate repository)
      final userId = supabase.auth.currentUser!.id;
      final eventDate = DateTime.parse(eventResponse['event_date']);

      await supabase.from('scheduled_notifications').insert([
        {
          'event_id': testEventId,
          'user_id': userId,
          'scheduled_at': eventDate.subtract(const Duration(days: 7)).toIso8601String(),
          'notification_type': '1_week',
        },
        {
          'event_id': testEventId,
          'user_id': userId,
          'scheduled_at': eventDate.subtract(const Duration(days: 1)).toIso8601String(),
          'notification_type': '1_day',
        },
      ]);

      // 3. Verify scheduled
      final scheduled = await supabase
          .from('scheduled_notifications')
          .select()
          .eq('event_id', testEventId!);

      expect(scheduled.length, 2);

      // 4. Simulate past time for 1_week notification
      await supabase
          .from('scheduled_notifications')
          .update({'scheduled_at': DateTime.now().subtract(const Duration(minutes: 1)).toIso8601String()})
          .eq('event_id', testEventId!)
          .eq('notification_type', '1_week');

      // 5. Run cron function
      await supabase.rpc('process_scheduled_notifications');

      // 6. Verify sent
      final sentNotification = await supabase
          .from('scheduled_notifications')
          .select()
          .eq('event_id', testEventId!)
          .eq('notification_type', '1_week')
          .single();

      expect(sentNotification['sent'], true);
      expect(sentNotification['sent_at'], isNotNull);

      // 7. Verify in outbox
      final outbox = await supabase
          .from('notifications_outbox')
          .select()
          .eq('event_type', 'event_reminder')
          .filter('payload->>event_id', 'eq', testEventId!);

      expect(outbox.length, 1);
      expect(outbox[0]['payload']['reminder_type'], '1_week');
      expect(outbox[0]['payload']['event_title'], 'Integration Test Event');
    });

    test('cascade delete removes notifications', () async {
      // Create event
      final response = await supabase.from('wedding_events').insert({
        'wedding_id': 'test-wedding-id',
        'title': 'Cascade Test Event',
        'event_date': DateTime.now().add(const Duration(days: 8)).toIso8601String(),
      }).select().single();

      final eventId = response['id'];

      // Create notification
      await supabase.from('scheduled_notifications').insert({
        'event_id': eventId,
        'user_id': supabase.auth.currentUser!.id,
        'scheduled_at': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'notification_type': '1_day',
      });

      // Delete event
      await supabase.from('wedding_events').delete().eq('id', eventId);

      // Verify cascade
      final notifications = await supabase
          .from('scheduled_notifications')
          .select()
          .eq('event_id', eventId);

      expect(notifications.length, 0);
    });
  });
}
```

### Checklist de validation manuelle
```markdown
## Manual E2E Test Checklist

### Setup
- [ ] Create test event with all 3 reminders enabled
- [ ] Event date set to 8 days in the future

### Scheduling Verification
- [ ] 3 entries in scheduled_notifications
- [ ] Correct scheduled_at times (7 days, 1 day, 1 hour before)
- [ ] All sent = FALSE

### Processing Verification
- [ ] Manually update 1_week scheduled_at to past
- [ ] Run SELECT process_scheduled_notifications()
- [ ] Returns 1 (one processed)
- [ ] 1_week notification has sent = TRUE, sent_at populated
- [ ] notifications_outbox has entry with correct payload

### Payload Verification
- [ ] event_type = 'event_reminder'
- [ ] payload.user_id is valid UUID
- [ ] payload.event_id matches test event
- [ ] payload.event_title matches
- [ ] payload.reminder_type = '1_week'

### Cascade Verification
- [ ] Delete test event
- [ ] All scheduled_notifications for event are gone

### Idempotency Verification
- [ ] Run process_scheduled_notifications() again
- [ ] Returns 0 (nothing new to process)
- [ ] No duplicate in outbox

### Cleanup
- [ ] Delete test outbox entries
- [ ] Verify no test data remains
```

## Definition of Done
- [ ] Criteres valides
- [ ] Script SQL de test E2E cree et documente
- [ ] Tests integration Dart crees (si applicable)
- [ ] Checklist de validation manuelle completee
- [ ] Flow complet valide: create -> schedule -> process -> outbox
- [ ] CASCADE delete verifie
- [ ] Idempotence verifiee
- [ ] Pas de doublons
- [ ] `flutter analyze --fatal-infos` passe
- [ ] `flutter test` passe

## Estimation
**Points** : 3
**Complexite** : Moyenne
**Risque** : Faible (tests seulement, pas de code de production)

## Dependances
- S01: Colonnes reminder (prerequis DB)
- S02: Table scheduled_notifications (prerequis DB)
- S03: pg_cron job (pour processing)
- S04: Entity WeddingEvent (pour tests Dart)
- S06: Repository scheduling (pour flow complet)
- S07: Integration outbox (pour payload)

## Stories Dependantes
- Aucune (story finale de l'Epic)
