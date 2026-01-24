# Story S08: Notifications - Domain Layer

## Description

En tant que developpeur, je veux creer la couche domain complete pour le module Notifications afin d'avoir une base solide pour les notifications in-app et push.

## Criteres d'Acceptance (Gherkin)

- [ ] Given le module Notifications existant When j'analyse `lib/features/notifications/domain/` Then je liste les entites manquantes

- [ ] Given les types de notifications actifs When je cree les entites Then tous les types sont couverts (chatMessage, connectionRequest, etc.)

- [ ] Given `NotificationRepository` When je cree l'interface Then toutes les operations CRUD sont definies

- [ ] Given les entites When j'ecris les tests Then 100% des tests passent

## Fichiers Concernes

### Existants
- `lib/features/notifications/domain/entities/notification_setting.dart`
- `lib/features/notifications/domain/entities/notification_type_config.dart`

### A Creer
- `lib/features/notifications/domain/entities/app_notification.dart` - Notification in-app
- `lib/features/notifications/domain/entities/notification_payload.dart` - Payload push
- `lib/features/notifications/domain/entities/entities.dart` - Barrel export
- `lib/features/notifications/domain/repositories/notification_repository.dart` - Interface

### Tests
- `test/features/notifications/domain/entities/app_notification_test.dart`

## Notes Techniques

### Types de Notifications (Backend v23)
```dart
enum NotificationType {
  chatMessage,           // Nouveau message prive
  connectionRequest,     // Demande de contact Pro→Bride
  connectionRequestAccepted, // Demande acceptee
  wishlistAdd,           // Bride ajoute Pro en favoris
  videoIncoming,         // Appel video entrant
  wedPublished,          // Wedding of the Week
}
```

### Entity AppNotification
```dart
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic> data; // Payload pour navigation
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.data,
    required this.createdAt,
    this.readAt,
    this.isRead = false,
  });

  bool get isUnread => !isRead;

  AppNotification copyWith({...});

  /// Parse le payload pour determiner la navigation
  NotificationNavigation? get navigation {
    return NotificationNavigation.fromData(type, data);
  }
}
```

### Repository Interface
```dart
abstract class NotificationRepository {
  // Notifications in-app
  Future<Result<List<AppNotification>>> getNotifications({int limit, int offset});
  Future<Result<int>> getUnreadCount();
  Future<Result<void>> markAsRead(String notificationId);
  Future<Result<void>> markAllAsRead();
  Stream<List<AppNotification>> watchNotifications();

  // Settings
  Future<Result<List<NotificationSetting>>> getSettings();
  Future<Result<void>> updateSetting(NotificationSetting setting);
  Future<Result<void>> updateSettings(List<NotificationSetting> settings);

  // Push token
  Future<Result<void>> registerDeviceToken(String token);
  Future<Result<void>> unregisterDeviceToken(String token);
}
```

### Navigation Helper
```dart
class NotificationNavigation {
  final String routeName;
  final Map<String, dynamic> params;

  const NotificationNavigation(this.routeName, this.params);

  static NotificationNavigation? fromData(NotificationType type, Map<String, dynamic> data) {
    switch (type) {
      case NotificationType.chatMessage:
        return NotificationNavigation('/chatDetails', {
          'roomId': data['room_id'],
        });
      case NotificationType.connectionRequest:
        return NotificationNavigation('/messages', {
          'tab': 'requests',
        });
      // ... autres cas
      default:
        return null;
    }
  }
}
```

## Definition of Done

- [ ] Entity AppNotification creee et testee
- [ ] Entity NotificationPayload creee
- [ ] NotificationRepository interface complete
- [ ] NotificationNavigation helper
- [ ] Tests unitaires
- [ ] Documentation des types
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 3
**Complexite** : Faible
**Risque** : Faible

## Dependances

- S01 : Setup infrastructure

## Stories Dependantes

- S09 : Notifications - Data layer
- S10 : Notifications - Presentation
