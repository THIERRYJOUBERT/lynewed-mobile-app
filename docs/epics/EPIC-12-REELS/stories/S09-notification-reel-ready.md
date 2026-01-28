# Story S09: Send Notification When Reel is Ready

## Description
En tant que **utilisateur**, je veux **recevoir une notification push quand mon reel est pret**, afin de **savoir immediatement que je peux le telecharger**.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Notification when reel is ready

  Scenario: Push notification is sent on completion
    Given a reel has finished processing successfully
    And status has changed to 'ready'
    When the notification trigger fires
    Then a push notification should be sent via FCM
    And the user should receive it even if app is closed

  Scenario: Notification content is correct (French)
    Given a push notification for reel completion
    Then the notification should contain:
      | field   | value                                                      |
      | title   | "Votre reel est pret !"                                    |
      | body    | "Votre montage video est termine. Telechargez-le maintenant." |
      | data    | { reel_id: "xxx", type: "reel_ready" }                     |

  Scenario: Tapping notification opens reel detail
    Given the user receives the notification
    When they tap on it
    Then the app should open
    And navigate directly to the reel detail page
    And the preview should start playing

  Scenario: Notification is logged in outbox
    Given a reel completion event
    Then a record should be inserted into notifications_outbox with:
      | field       | value                    |
      | user_id     | reel creator's user_id   |
      | event_type  | 'reel_ready'             |
      | payload     | JSON with reel details   |
      | status      | 'pending'                |

  Scenario: Notification not sent for failed reels
    Given a reel processing has failed
    And status has changed to 'failed'
    Then no "reel ready" notification should be sent
    And optionally an error notification could be sent

  Scenario: Deep link format
    Given a notification with reel_id 'abc-123'
    When the user taps the notification
    Then the deep link should resolve to "/reels/abc-123"
    And the ReelDetailPage should display

  Scenario: Multiple reels notification handling
    Given a user has 2 reels processing
    When both complete within 1 minute
    Then 2 separate notifications should be sent
    And each should link to the correct reel
```

## Fichiers Concernes

### A Creer
- `lib/features/reels/domain/usecases/handle_reel_ready_notification.dart`

### A Modifier
- `supabase/functions/generate-reel/index.ts` - Add notification trigger after success
- `lib/core/notifications/notification_handler.dart` - Add reel_ready handler
- `lib/core/router/app_router.dart` - Add deep link for reel detail

## Notes Techniques

### Notification Trigger in Edge Function
```typescript
// In supabase/functions/generate-reel/index.ts
// After successful processing

async function sendReelReadyNotification(
  supabase: SupabaseClient,
  reel: Reel,
): Promise<void> {
  // Insert into notifications_outbox (existing pattern)
  const { error } = await supabase
    .from('notifications_outbox')
    .insert({
      user_id: reel.user_id,
      event_type: 'reel_ready',
      payload: {
        reel_id: reel.id,
        wedding_id: reel.wedding_id,
        title: 'Votre reel est pret !',
        body: 'Votre montage video est termine. Telechargez-le maintenant.',
        deep_link: `/reels/${reel.id}`,
      },
      status: 'pending',
    });

  if (error) {
    console.error('Failed to queue notification:', error);
    // Don't throw - notification failure shouldn't fail the reel
  }
}

// Call after successful update
await supabase.from('reels').update({
  status: 'ready',
  // ... other fields
}).eq('id', reel_id);

// Send notification (fire and forget)
await sendReelReadyNotification(supabase, { ...reel, id: reel_id });
```

### SQL for Notification Outbox
```sql
-- Existing table structure (should already exist)
-- notifications_outbox
--   id UUID
--   user_id UUID
--   event_type VARCHAR
--   payload JSONB
--   status VARCHAR (pending, sent, failed)
--   created_at TIMESTAMP

-- Example insert
INSERT INTO notifications_outbox (user_id, event_type, payload, status)
VALUES (
  'user-123',
  'reel_ready',
  '{
    "reel_id": "reel-456",
    "wedding_id": "wedding-789",
    "title": "Votre reel est pret !",
    "body": "Votre montage video est termine. Telechargez-le maintenant.",
    "deep_link": "/reels/reel-456"
  }'::jsonb,
  'pending'
);
```

### FCM Payload Format
```json
{
  "notification": {
    "title": "Votre reel est pret !",
    "body": "Votre montage video est termine. Telechargez-le maintenant."
  },
  "data": {
    "type": "reel_ready",
    "reel_id": "reel-456",
    "deep_link": "/reels/reel-456",
    "click_action": "FLUTTER_NOTIFICATION_CLICK"
  },
  "android": {
    "notification": {
      "channel_id": "reels",
      "icon": "ic_notification"
    }
  },
  "apns": {
    "payload": {
      "aps": {
        "badge": 1,
        "sound": "default"
      }
    }
  }
}
```

### Flutter Notification Handler
```dart
// lib/core/notifications/notification_handler.dart

extension ReelNotificationHandler on NotificationHandler {
  void handleReelReadyNotification(Map<String, dynamic> data) {
    final reelId = data['reel_id'] as String?;
    if (reelId == null) return;

    // Navigate to reel detail page
    router.push('/reels/$reelId');
  }
}

// In notification initialization
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  final data = message.data;
  if (data['type'] == 'reel_ready') {
    handleReelReadyNotification(data);
  }
});
```

### Deep Link Configuration
```dart
// lib/core/router/app_router.dart

GoRoute(
  path: '/reels/:reelId',
  name: 'reelDetail',
  builder: (context, state) => ReelDetailPage(
    reelId: state.pathParameters['reelId']!,
  ),
),
```

### Use Case for Handling Notification
```dart
// lib/features/reels/domain/usecases/handle_reel_ready_notification.dart

class HandleReelReadyNotificationUseCase {
  final AppRouter _router;
  final ReelRepository _reelRepository;

  HandleReelReadyNotificationUseCase(this._router, this._reelRepository);

  Future<void> execute(String reelId) async {
    // Optionally prefetch reel data
    await _reelRepository.getReel(reelId);

    // Navigate to detail page
    _router.push('/reels/$reelId');
  }
}
```

## Definition of Done
- [ ] Criteres d'acceptance valides
- [ ] Notification inserted into outbox after successful processing
- [ ] FCM payload format correct
- [ ] Notification title/body in French
- [ ] Deep link navigates to ReelDetailPage
- [ ] App opens correctly from background/killed state
- [ ] Notification not sent for failed reels
- [ ] Tests for notification handler
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible (uses existing notification infrastructure)

## Dependances
- S06: Edge Function triggers notification after success
- Existing FCM infrastructure must be working

## Stories Dependantes
- None (end of pipeline)
