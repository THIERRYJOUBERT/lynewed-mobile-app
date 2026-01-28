# Story S07: Integrer avec notifications_outbox existante

## Description
En tant que developpeur backend, je veux m'assurer que le payload insere dans notifications_outbox est correctement formate pour le worker FCM existant, afin que les notifications push soient envoyees avec le bon message.

## Criteres d'Acceptance (Gherkin)
- [ ] Given a scheduled notification is processed When it is inserted into notifications_outbox Then the entry should have event_type = 'event_reminder'
- [ ] Given a notification in outbox When inspecting the payload Then it should contain user_id (UUID string), event_id (UUID string), event_title (string), reminder_type ('1_week', '1_day', or '1_hour')
- [ ] Given a notification in outbox with reminder_type = '1_day' and event_title = 'RDV Photographe' When the FCM worker processes it Then the push notification should have title = "Rappel" and body = "RDV Photographe dans 1 jour"
- [ ] Given a notification with reminder_type = '1_week' and event_title = 'Essayage robe' When processed Then the body should be "Essayage robe dans 1 semaine"
- [ ] Given a notification with reminder_type = '1_hour' and event_title = 'Appel fleuriste' When processed Then the body should be "Appel fleuriste dans 1 heure"

## Fichiers Concernes
### A Creer
- `test/features/notifications/fcm_reminder_integration_test.dart`

### A Modifier
- `supabase/functions/send-notifications/index.ts` (ou Edge Function equivalente si existante)

## Notes Techniques

### Verification du schema notifications_outbox
```sql
-- Check current schema
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'notifications_outbox'
ORDER BY ordinal_position;

-- Example expected columns:
-- id, event_type, payload (jsonb), created_at, processed_at, etc.
```

### Payload Format (deja defini dans S03)
```json
{
  "user_id": "uuid-string",
  "event_id": "uuid-string",
  "event_title": "RDV Photographe",
  "reminder_type": "1_day"
}
```

### FCM Worker Update (si Edge Function)
```typescript
// supabase/functions/send-notifications/index.ts

interface EventReminderPayload {
  user_id: string;
  event_id: string;
  event_title: string;
  reminder_type: '1_week' | '1_day' | '1_hour';
}

const DURATION_MAP: Record<string, string> = {
  '1_week': '1 semaine',
  '1_day': '1 jour',
  '1_hour': '1 heure',
};

function formatReminderMessage(payload: EventReminderPayload): {
  title: string;
  body: string;
} {
  return {
    title: 'Rappel',
    body: `${payload.event_title} dans ${DURATION_MAP[payload.reminder_type]}`,
  };
}

// In main handler
Deno.serve(async (req: Request) => {
  // ... existing code to fetch from notifications_outbox

  for (const notification of notifications) {
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
    // ... other event types
  }
});
```

### Test SQL pour verifier le flow complet
```sql
-- 1. Create a test event
INSERT INTO wedding_events (id, wedding_id, title, event_date, reminder_1_day)
VALUES (
  gen_random_uuid(),
  (SELECT id FROM weddings LIMIT 1),
  'Test RDV Integration',
  NOW() + INTERVAL '25 hours',
  TRUE
);

-- 2. Manually insert a scheduled notification (simulating repository)
INSERT INTO scheduled_notifications (event_id, user_id, scheduled_at, notification_type)
SELECT
  we.id,
  w.owner_id,
  we.event_date - INTERVAL '1 day',
  '1_day'
FROM wedding_events we
JOIN weddings w ON w.id = we.wedding_id
WHERE we.title = 'Test RDV Integration';

-- 3. Update scheduled_at to past (to trigger processing)
UPDATE scheduled_notifications
SET scheduled_at = NOW() - INTERVAL '1 minute'
WHERE notification_type = '1_day'
AND event_id IN (SELECT id FROM wedding_events WHERE title = 'Test RDV Integration');

-- 4. Run the cron function
SELECT process_scheduled_notifications();

-- 5. Check notifications_outbox
SELECT
  event_type,
  payload->>'event_title' as event_title,
  payload->>'reminder_type' as reminder_type,
  created_at
FROM notifications_outbox
WHERE event_type = 'event_reminder'
ORDER BY created_at DESC
LIMIT 5;

-- Expected output:
-- event_type      | event_title           | reminder_type | created_at
-- event_reminder  | Test RDV Integration  | 1_day         | 2026-01-28 ...

-- 6. Cleanup test data
DELETE FROM wedding_events WHERE title = 'Test RDV Integration';
```

### Tests Dart pour verification payload
```dart
// test/features/notifications/fcm_reminder_integration_test.dart

group('FCM Reminder Integration', () {
  test('formatReminderMessage should format 1_day correctly', () {
    final message = formatReminderMessage(
      eventTitle: 'RDV Photographe',
      reminderType: '1_day',
    );

    expect(message.title, 'Rappel');
    expect(message.body, 'RDV Photographe dans 1 jour');
  });

  test('formatReminderMessage should format 1_week correctly', () {
    final message = formatReminderMessage(
      eventTitle: 'Essayage robe',
      reminderType: '1_week',
    );

    expect(message.title, 'Rappel');
    expect(message.body, 'Essayage robe dans 1 semaine');
  });

  test('formatReminderMessage should format 1_hour correctly', () {
    final message = formatReminderMessage(
      eventTitle: 'Appel fleuriste',
      reminderType: '1_hour',
    );

    expect(message.title, 'Rappel');
    expect(message.body, 'Appel fleuriste dans 1 heure');
  });
});

// Helper function (mirror of TypeScript)
({String title, String body}) formatReminderMessage({
  required String eventTitle,
  required String reminderType,
}) {
  const durationMap = {
    '1_week': '1 semaine',
    '1_day': '1 jour',
    '1_hour': '1 heure',
  };

  return (
    title: 'Rappel',
    body: '$eventTitle dans ${durationMap[reminderType]}',
  );
}
```

## Definition of Done
- [ ] Criteres valides
- [ ] Payload format documente et valide
- [ ] FCM worker mis a jour (si necessaire)
- [ ] Test SQL du flow complet reussi
- [ ] Tests Dart pour formatage message
- [ ] Messages push corrects (1 semaine, 1 jour, 1 heure)
- [ ] `flutter analyze --fatal-infos` passe
- [ ] `flutter test` passe

## Estimation
**Points** : 3
**Complexite** : Faible
**Risque** : Moyen (integration avec systeme FCM existant)

## Dependances
- S03: Creer pg_cron job pour traitement notifications (cron job insere dans outbox)
- S06: Implementer scheduling des rappels dans repository (schedule les notifications)

## Stories Dependantes
- S08: Tests E2E du flow complet (depend de l'integration complete)
