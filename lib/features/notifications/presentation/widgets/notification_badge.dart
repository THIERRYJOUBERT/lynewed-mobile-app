/// NotificationBadge widget - Clean Architecture
///
/// A badge widget that displays the unread notification count.
/// Listens to NotificationsNotifier for real-time updates.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/design/design.dart';
import '../bloc/notifications_cubit.dart';

/// A badge widget that displays the unread notification count.
///
/// Wraps a child widget (typically an icon) and shows a badge with the
/// unread count. The badge updates in real-time as notifications are
/// read or new ones arrive.
///
/// Usage:
/// ```dart
/// NotificationBadge(
///   child: Icon(Icons.notifications),
/// )
/// ```
class NotificationBadge extends StatelessWidget {
  /// Creates a NotificationBadge.
  ///
  /// [child] is the widget to wrap with the badge (typically an icon).
  const NotificationBadge({
    required this.child,
    super.key,
  });

  /// The widget to display under the badge.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsNotifier>(
      builder: (context, notifier, _) {
        final count = notifier.unreadCount;
        final displayCount = count > 99 ? '99+' : count.toString();

        return Badge(
          isLabelVisible: count > 0,
          label: Text(
            displayCount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: LynewedColors.primary,
          child: child,
        );
      },
    );
  }
}

/// A standalone badge widget for use outside of Provider context.
///
/// Use this when you have the count directly available (e.g., from a cubit
/// that's already in scope).
class NotificationCountBadge extends StatelessWidget {
  /// Creates a NotificationCountBadge.
  ///
  /// [count] is the number to display in the badge.
  /// [child] is the widget to wrap with the badge.
  const NotificationCountBadge({
    required this.count,
    required this.child,
    super.key,
  });

  /// The unread count to display.
  final int count;

  /// The widget to display under the badge.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final displayCount = count > 99 ? '99+' : count.toString();

    return Badge(
      isLabelVisible: count > 0,
      label: Text(
        displayCount,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: LynewedColors.primary,
      child: child,
    );
  }
}
