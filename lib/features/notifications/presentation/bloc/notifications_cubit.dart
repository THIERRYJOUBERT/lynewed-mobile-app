/// Notifications notifier - Clean Architecture
///
/// Manages state for notifications using ChangeNotifier pattern.
/// Includes realtime subscriptions for new notifications.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';
import 'notifications_state.dart';

/// Notifier for managing notifications list and badge count
///
/// Provides:
/// - Load notifications from repository
/// - Mark notifications as read
/// - Watch for real-time updates
/// - Unread count for badge display
class NotificationsNotifier extends ChangeNotifier {
  /// Creates a NotificationsNotifier with optional repository for testing.
  NotificationsNotifier({
    NotificationRepository? repository,
  }) : _repository = repository ?? NotificationRepositoryImpl();

  final NotificationRepository _repository;

  StreamSubscription<List<AppNotification>>? _subscription;

  NotificationsState _state = const NotificationsInitial();

  /// Current state
  NotificationsState get state => _state;

  /// Convenience getter for unread count
  int get unreadCount {
    final currentState = _state;
    if (currentState is NotificationsLoaded) {
      return currentState.unreadCount;
    }
    return 0;
  }

  /// Convenience getter for checking if there are unread notifications
  bool get hasUnread => unreadCount > 0;

  /// Emits a new state and notifies listeners
  void _emit(NotificationsState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Load notifications from repository
  Future<void> loadNotifications({int limit = 50, int offset = 0}) async {
    _emit(const NotificationsLoading());

    final result = await _repository.getNotifications(
      limit: limit,
      offset: offset,
    );

    result.fold(
      onSuccess: (notifications) {
        _emit(NotificationsLoaded(notifications: notifications));
      },
      onFailure: (failure) {
        _emit(NotificationsError(failure.message));
      },
    );
  }

  /// Refresh notifications (background refresh)
  Future<void> refresh() async {
    final currentState = _state;
    if (currentState is! NotificationsLoaded) {
      await loadNotifications();
      return;
    }

    _emit(currentState.copyWith(isRefreshing: true));

    final result = await _repository.getNotifications();

    result.fold(
      onSuccess: (notifications) {
        _emit(NotificationsLoaded(
          notifications: notifications,
          isRefreshing: false,
        ));
      },
      onFailure: (_) {
        _emit(currentState.copyWith(isRefreshing: false));
      },
    );
  }

  /// Start watching for real-time notification updates
  void startWatching() {
    _subscription?.cancel();
    _subscription = _repository.watchNotifications().listen(
      (notifications) {
        final currentState = _state;
        if (currentState is NotificationsLoaded) {
          _emit(currentState.copyWith(notifications: notifications));
        } else {
          _emit(NotificationsLoaded(notifications: notifications));
        }
      },
      onError: (error) {
        debugPrint('[NotificationsNotifier] Watch error: $error');
      },
    );
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    final currentState = _state;
    if (currentState is! NotificationsLoaded) return;

    // Store original state for potential rollback
    final originalNotifications = currentState.notifications;

    // Optimistic update
    final updatedNotifications = currentState.notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(readAt: DateTime.now());
      }
      return n;
    }).toList();

    _emit(currentState.copyWith(notifications: updatedNotifications));

    // Persist to backend
    final result = await _repository.markAsRead(notificationId);

    // Rollback on failure
    result.fold(
      onSuccess: (_) {
        // Success - keep optimistic update
      },
      onFailure: (failure) {
        // Rollback to original state
        _emit(currentState.copyWith(notifications: originalNotifications));
        debugPrint('[NotificationsNotifier] markAsRead failed: ${failure.message}');
      },
    );
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final currentState = _state;
    if (currentState is! NotificationsLoaded) return;

    // Store original state for potential rollback
    final originalNotifications = currentState.notifications;

    // Optimistic update
    final updatedNotifications = currentState.notifications.map((n) {
      return n.copyWith(readAt: n.readAt ?? DateTime.now());
    }).toList();

    _emit(currentState.copyWith(notifications: updatedNotifications));

    // Persist to backend
    final result = await _repository.markAllAsRead();

    // Rollback on failure
    result.fold(
      onSuccess: (_) {
        // Success - keep optimistic update
      },
      onFailure: (failure) {
        // Rollback to original state
        _emit(currentState.copyWith(notifications: originalNotifications));
        debugPrint('[NotificationsNotifier] markAllAsRead failed: ${failure.message}');
      },
    );
  }

  /// For testing: set state directly
  @visibleForTesting
  void setStateForTesting(NotificationsState newState) {
    _state = newState;
  }

  /// For testing: expose emit method
  @visibleForTesting
  void emit(NotificationsState newState) {
    _emit(newState);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
