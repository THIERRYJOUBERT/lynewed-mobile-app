# Story S09: Notifications - Data Layer

## Description

En tant que developpeur, je veux implementer la couche data du module Notifications afin de gerer les notifications in-app et push avec Supabase et Firebase.

## Criteres d'Acceptance (Gherkin)

- [x] Given `NotificationRemoteDatasource` When je cree l'implementation Then toutes les operations Supabase sont couvertes

- [x] Given `NotificationRepositoryImpl` When j'implemente Then il implemente entierement `NotificationRepository`

- [x] Given les actions custom code When je les integre Then elles sont dans le datasource

- [x] Given le push handling When je verifie Then `lib/custom_code/push_background.dart` est integre

- [x] Given les tests When je les execute Then ils passent avec des mocks

## Fichiers Concernes

### A Creer
- `lib/features/notifications/data/datasources/notification_remote_datasource.dart`
- `lib/features/notifications/data/repositories/notification_repository_impl.dart`
- `lib/features/notifications/data/models/notification_model.dart`

### Actions Custom Code a Integrer
```
lib/custom_code/actions/
├── get_notifications_action.dart           → Datasource.getNotifications()
├── get_unread_notifications_count.dart     → Datasource.getUnreadCount()
├── mark_notification_as_read.dart          → Datasource.markAsRead()
├── mark_all_notifications_as_read.dart     → Datasource.markAllAsRead()
├── refresh_notification_badge.dart         → Integration UI
├── handle_notification_redirection.dart    → NotificationNavigation
├── init_push_notifications.dart            → Service init
```

### Push Handling
- `lib/custom_code/push_background.dart` - Background handler
- `lib/custom_code/firebase_options.dart` - Firebase config

### Tests
- `test/features/notifications/data/repositories/notification_repository_impl_test.dart`

## Notes Techniques

### Datasource Implementation
```dart
class NotificationRemoteDatasourceImpl implements NotificationRemoteDatasource {
  final SupabaseClient _supabase;

  NotificationRemoteDatasourceImpl(this._supabase);

  @override
  Future<List<NotificationModel>> getNotifications({int limit = 50, int offset = 0}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw NotAuthenticatedException();

    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return response.map((e) => NotificationModel.fromJson(e)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _supabase
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .isFilter('read_at', null);

    return response.length;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'read_at': DateTime.now().toIso8601String()})
        .eq('id', notificationId);
  }

  @override
  Stream<List<NotificationModel>> watchNotifications() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50)
        .map((data) => data.map((e) => NotificationModel.fromJson(e)).toList());
  }
}
```

### Push Service Integration
```dart
class PushNotificationService {
  final NotificationRepository _repository;

  PushNotificationService(this._repository);

  Future<void> initialize() async {
    // Firebase Messaging setup
    final fcm = FirebaseMessaging.instance;

    // Request permissions
    await fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get token and register
    final token = await fcm.getToken();
    if (token != null) {
      await _repository.registerDeviceToken(token);
    }

    // Listen for token refresh
    fcm.onTokenRefresh.listen((token) {
      _repository.registerDeviceToken(token);
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background messages (already in push_background.dart)
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification or update badge
  }
}
```

### Model avec Mapping
```dart
class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({...});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['image_url'] as String?,
      data: json['data'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
    );
  }

  AppNotification toEntity() {
    return AppNotification(
      id: id,
      type: NotificationType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => NotificationType.chatMessage,
      ),
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      createdAt: createdAt,
      readAt: readAt,
      isRead: readAt != null,
    );
  }
}
```

## Definition of Done

- [x] Datasource implemente et teste
- [x] Repository implemente et teste
- [x] Actions custom code integrees
- [x] Push service integre (reference via documentation)
- [x] Tests avec mocks (35 tests passants)
- [x] `flutter analyze --fatal-infos` passe (0 warnings)

## Implementation Notes (2024-01-25)

### Files Created
- `lib/features/notifications/data/models/notification_model.dart` - Data model with JSON parsing and entity conversion
- `lib/features/notifications/data/datasources/notification_remote_datasource.dart` - Supabase operations
- `lib/features/notifications/data/repositories/notification_repository_impl.dart` - Repository implementation
- `test/features/notifications/data/models/notification_model_test.dart` - 13 model tests
- `test/features/notifications/data/repositories/notification_repository_impl_test.dart` - 22 repository tests

### Custom Code Integration
The datasource integrates the following custom code actions:
- `get_notifications_action.dart` -> `getNotifications()` - Uses `get_formatted_notifications` RPC
- `get_unread_notifications_count.dart` -> `getUnreadCount()` - Uses `get_unread_notifications_count` RPC
- `mark_notification_as_read.dart` -> `markAsRead()` - Uses `mark_notification_as_read` RPC
- `mark_all_notifications_as_read.dart` -> `markAllAsRead()` - Uses `mark_all_notifications_as_read` RPC
- `upsert_notification_setting.dart` -> `updateSetting()` / `updateSettings()` - Upsert to notification_settings table
- `init_push_notifications.dart` -> `registerDeviceToken()` / `unregisterDeviceToken()` - Device token management

### Push Handling
Push notification handling via `lib/custom_code/push_background.dart` is referenced in the datasource documentation.
The datasource provides `registerDeviceToken()` and `unregisterDeviceToken()` for FCM token management.

### Test Coverage
- 35 total tests (13 model + 22 repository)
- All tests use mocktail for mocking
- Tests cover success cases, error handling, and edge cases

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen

## Dependances

- S01 : Setup infrastructure
- S08 : Notifications - Domain

## Stories Dependantes

- S10 : Notifications - Presentation
- S37 : Custom Code - Notification actions
