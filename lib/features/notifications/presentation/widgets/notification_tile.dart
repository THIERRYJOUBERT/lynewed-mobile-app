/// NotificationTile widget - Clean Architecture
///
/// A tile widget for displaying individual notifications.
/// Used in the notifications list.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../../domain/entities/app_notification.dart';

/// A tile widget for displaying a notification.
///
/// Shows the notification icon, title, body, timestamp, and read status.
/// Supports tap callbacks for interaction.
///
/// Usage:
/// ```dart
/// NotificationTile(
///   notification: notification,
///   onTap: () => handleNotificationTap(notification),
///   onMarkAsRead: () => markAsRead(notification.id),
/// )
/// ```
class NotificationTile extends StatelessWidget {
  /// Creates a NotificationTile.
  const NotificationTile({
    required this.notification,
    required this.onTap,
    this.onMarkAsRead,
    this.onDismiss,
    super.key,
  });

  /// The notification to display.
  final AppNotification notification;

  /// Callback when the tile is tapped.
  final VoidCallback onTap;

  /// Callback when the read badge is tapped (to mark as read without navigating).
  final VoidCallback? onMarkAsRead;

  /// Callback when the tile is dismissed.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final tile = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title.isNotEmpty
                              ? notification.title
                              : _getDefaultTitle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LynewedTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _buildReadBadge(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body.isNotEmpty
                        ? notification.body
                        : 'Tap to view details',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTimestamp(notification.createdAt),
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.gray100,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Wrap with Dismissible if onDismiss is provided
    if (onDismiss != null) {
      return Dismissible(
        key: Key(notification.id),
        onDismissed: (_) => onDismiss?.call(),
        background: Container(
          color: LynewedColors.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
          ),
        ),
        direction: DismissDirection.endToStart,
        child: tile,
      );
    }

    return tile;
  }

  Widget _buildIcon() {
    final iconData = _getIconForType();
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: notification.isRead ? LynewedColors.gray200 : LynewedColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 18,
        color: notification.isRead
            ? LynewedColors.textSecondary
            : LynewedColors.textOnPrimary,
      ),
    );
  }

  Widget _buildReadBadge() {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: notification.isRead ? LynewedColors.gray200 : LynewedColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        notification.isRead ? 'Read' : 'New',
        style: LynewedTextStyles.labelSmall.copyWith(
          color: notification.isRead
              ? LynewedColors.textSecondary
              : LynewedColors.textOnPrimary,
        ),
      ),
    );

    // If unread and callback provided, make badge tappable
    if (!notification.isRead && onMarkAsRead != null) {
      return GestureDetector(
        onTap: onMarkAsRead,
        behavior: HitTestBehavior.opaque,
        child: badge,
      );
    }

    return badge;
  }

  IconData _getIconForType() {
    switch (notification.type) {
      case NotificationType.chatMessage:
        return Icons.chat_bubble_outline;
      case NotificationType.connectionRequest:
        return Icons.person_add_outlined;
      case NotificationType.connectionRequestAccepted:
        return Icons.check_circle_outline;
      case NotificationType.wishlistAdd:
        return Icons.favorite_outline;
      case NotificationType.videoIncoming:
        return Icons.videocam_outlined;
      case NotificationType.wedPublished:
        return Icons.celebration_outlined;
      case NotificationType.replayPublished:
        return Icons.play_circle_outline;
    }
  }

  String _getDefaultTitle() {
    switch (notification.type) {
      case NotificationType.chatMessage:
        return 'New message';
      case NotificationType.connectionRequest:
        return 'Contact request';
      case NotificationType.connectionRequestAccepted:
        return 'Request accepted';
      case NotificationType.wishlistAdd:
        return 'Added to wishlist';
      case NotificationType.videoIncoming:
        return 'Video call';
      case NotificationType.wedPublished:
        return 'Wedding of the Week';
      case NotificationType.replayPublished:
        return 'New Replay';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return dateTimeFormat('MMMd', timestamp);
    }
  }
}
