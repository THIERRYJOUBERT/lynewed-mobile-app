# Story S37: Custom Code - Notification Actions Migration

## Description

En tant que developpeur, je veux migrer les actions notifications de custom_code vers le module Notifications afin d'eliminer le code legacy.

## Criteres d'Acceptance (Gherkin)

- [ ] Given les actions notifications dans custom_code When je les migre Then elles sont dans le module Notifications

- [ ] Given les imports des actions When je les supprime Then aucune erreur de compilation

- [ ] Given les fonctionnalites When je les teste Then tout fonctionne identiquement

## Fichiers Concernes

### Actions a Migrer
```
lib/custom_code/actions/
├── get_notifications_action.dart
├── get_unread_notifications_count.dart
├── mark_notification_as_read.dart
├── mark_all_notifications_as_read.dart
├── refresh_notification_badge.dart
├── handle_notification_redirection.dart
├── init_push_notifications.dart
├── upsert_notification_setting.dart
├── upsert_notification_settings_batch.dart
```

### Fichiers Firebase
```
lib/custom_code/
├── push_background.dart
├── firebase_options.dart
```

### Destination
- `lib/features/notifications/data/datasources/notification_remote_datasource.dart`
- `lib/features/notifications/data/repositories/notification_repository_impl.dart`
- `lib/features/notifications/services/push_notification_service.dart`

## Notes Techniques

### Push Notifications Service
```dart
class PushNotificationService {
  final NotificationRepository _repository;
  static final _instance = PushNotificationService._();

  PushNotificationService._() : _repository = getIt<NotificationRepository>();

  static PushNotificationService get instance => _instance;

  Future<void> initialize() async {
    // Request permissions
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get and register token
    final token = await messaging.getToken();
    if (token != null) {
      await _repository.registerDeviceToken(token);
    }

    // Token refresh listener
    messaging.onTokenRefresh.listen((token) {
      _repository.registerDeviceToken(token);
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background message handler is set in main.dart
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification
    _showLocalNotification(message);
  }

  void _showLocalNotification(RemoteMessage message) {
    // Use flutter_local_notifications
  }

  Future<void> handleNotificationTap(RemoteMessage message) async {
    final data = message.data;
    final navigation = NotificationNavigation.fromData(
      NotificationType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => NotificationType.chatMessage,
      ),
      data,
    );

    if (navigation != null) {
      // Navigate - will need router reference
    }
  }
}

// In main.dart:
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Handle background message
}
```

### Migration Checklist
- [ ] `get_notifications_action` -> `NotificationRemoteDatasource.getNotifications()`
- [ ] `get_unread_notifications_count` -> `NotificationRemoteDatasource.getUnreadCount()`
- [ ] `mark_notification_as_read` -> `NotificationRemoteDatasource.markAsRead()`
- [ ] `mark_all_notifications_as_read` -> `NotificationRemoteDatasource.markAllAsRead()`
- [ ] `init_push_notifications` -> `PushNotificationService.initialize()`
- [ ] `upsert_notification_setting` -> `NotificationRemoteDatasource.updateSetting()`
- [ ] `handle_notification_redirection` -> `NotificationNavigation` class

## Definition of Done

- [ ] Toutes les actions notifications migrees
- [ ] PushNotificationService implemente
- [ ] Firebase integration preservee
- [ ] Fichiers actions supprimes
- [ ] Tests passent
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen

## Dependances

- S08-S10 : Notifications module

## Stories Dependantes

- S41 : FlutterFlow cleanup
