/// Notifications state - Clean Architecture
///
/// State classes for NotificationsNotifier.
library;

import 'package:flutter/foundation.dart';
import '../../domain/entities/app_notification.dart';

/// Base state for notifications
@immutable
sealed class NotificationsState {
  const NotificationsState();
}

/// Initial state
class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

/// Loading state
class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

/// Loaded state with notifications
class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded({
    required this.notifications,
    this.isRefreshing = false,
  });

  /// List of notifications
  final List<AppNotification> notifications;

  /// Whether we're refreshing in background
  final bool isRefreshing;

  /// Count of unread notifications
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Whether there are unread notifications
  bool get hasUnread => unreadCount > 0;

  /// Creates a copy with updated fields
  NotificationsLoaded copyWith({
    List<AppNotification>? notifications,
    bool? isRefreshing,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Error state
class NotificationsError extends NotificationsState {
  const NotificationsError(this.message);

  final String message;
}
