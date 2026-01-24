# Story S10: Notifications - Presentation Layer Completion

## Description

En tant que developpeur, je veux completer la couche presentation du module Notifications afin d'avoir une UI complete pour les notifications in-app et les settings.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `NotificationsPage` existante When je la verifie Then elle utilise le repository Clean Architecture

- [ ] Given `NotificationSettingsPage` existante When je la verifie Then elle est complete et fonctionnelle

- [ ] Given le state management When je cree un Cubit Then les notifications sont gerees de maniere reactive

- [ ] Given le badge de notifications When je l'integre Then il se met a jour en temps reel

- [ ] Given la navigation par notification When je clique Then elle navigue vers le bon ecran

## Fichiers Concernes

### Existants (a verifier/completer)
- `lib/features/notifications/presentation/pages/notifications_page.dart`
- `lib/features/notifications/presentation/pages/notification_settings_page.dart`

### A Creer
- `lib/features/notifications/presentation/bloc/notifications_cubit.dart`
- `lib/features/notifications/presentation/bloc/notifications_state.dart`
- `lib/features/notifications/presentation/widgets/notification_tile.dart`
- `lib/features/notifications/presentation/widgets/notification_badge.dart`

### Integration Globale
- Badge dans AppBar ou BottomNav
- Integration avec le state global de l'app

## Notes Techniques

### Notifications Cubit
```dart
class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository _repository;
  StreamSubscription? _subscription;

  NotificationsCubit({required NotificationRepository repository})
      : _repository = repository,
        super(NotificationsState.initial()) {
    _loadNotifications();
    _watchNotifications();
  }

  Future<void> _loadNotifications() async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getNotifications();
    result.when(
      success: (notifications) {
        emit(state.copyWith(
          isLoading: false,
          notifications: notifications,
        ));
      },
      failure: (failure) {
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ));
      },
    );
  }

  void _watchNotifications() {
    _subscription = _repository.watchNotifications().listen((notifications) {
      emit(state.copyWith(notifications: notifications));
    });
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    // Update local state optimistically
    final updated = state.notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true, readAt: DateTime.now());
      return n;
    }).toList();
    emit(state.copyWith(notifications: updated));
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    final updated = state.notifications.map((n) {
      return n.copyWith(isRead: true, readAt: DateTime.now());
    }).toList();
    emit(state.copyWith(notifications: updated));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

### State
```dart
class NotificationsState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final String? error;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  factory NotificationsState.initial() => const NotificationsState();

  int get unreadCount => notifications.where((n) => n.isUnread).length;

  NotificationsState copyWith({...});
}
```

### Notification Tile Widget
```dart
class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  const NotificationTile({
    required this.notification,
    required this.onTap,
    this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      onDismissed: (_) => onDismiss?.call(),
      background: Container(color: Colors.red),
      child: ListTile(
        leading: _buildIcon(),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(notification.body),
        trailing: Text(_formatTime(notification.createdAt)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildIcon() {
    return CircleAvatar(
      backgroundImage: notification.imageUrl != null
          ? NetworkImage(notification.imageUrl!)
          : null,
      child: notification.imageUrl == null
          ? Icon(_getIconForType(notification.type))
          : null,
    );
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.chatMessage:
        return Icons.message;
      case NotificationType.connectionRequest:
        return Icons.person_add;
      // ... etc
    }
  }
}
```

### Badge Widget
```dart
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;

  const NotificationBadge({
    required this.child,
    required this.count,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text(count > 99 ? '99+' : count.toString()),
      child: child,
    );
  }
}
```

### Navigation Handling
```dart
void handleNotificationTap(BuildContext context, AppNotification notification) {
  // Mark as read
  context.read<NotificationsCubit>().markAsRead(notification.id);

  // Navigate
  final nav = notification.navigation;
  if (nav != null) {
    context.pushNamed(nav.routeName, queryParameters: nav.params);
  }
}
```

## Definition of Done

- [ ] NotificationsCubit implemente
- [ ] NotificationsPage utilise le Cubit
- [ ] NotificationSettingsPage fonctionnelle
- [ ] NotificationTile widget
- [ ] Badge widget avec update temps reel
- [ ] Navigation par notification
- [ ] Tests widgets
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances

- S03 : Design system
- S04 : Navigation
- S08 : Notifications - Domain
- S09 : Notifications - Data

## Stories Dependantes

- Aucune (module complet)
