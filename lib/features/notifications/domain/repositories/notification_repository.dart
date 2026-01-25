/// Notification repository interface for Clean Architecture.
///
/// Defines the contract for notification data operations.
/// Implementation is in the data layer.
library;

import 'package:lynewed_beta/core/core.dart';
import '../entities/app_notification.dart';
import '../entities/notification_setting.dart';

/// Repository interface for notification operations.
///
/// This abstract class defines all operations for managing notifications,
/// including fetching, marking as read, managing settings, and device tokens.
///
/// ## Notifications
/// - [getNotifications] - Fetch paginated list of notifications
/// - [getUnreadCount] - Get count of unread notifications
/// - [markAsRead] - Mark a single notification as read
/// - [markAllAsRead] - Mark all notifications as read
/// - [watchNotifications] - Stream of real-time notification updates
///
/// ## Settings
/// - [getSettings] - Get user's notification preferences
/// - [updateSetting] - Update a single notification setting
/// - [updateSettings] - Update multiple notification settings
///
/// ## Device Tokens
/// - [registerDeviceToken] - Register FCM token for push notifications
/// - [unregisterDeviceToken] - Unregister FCM token (e.g., on logout)
abstract class NotificationRepository {
  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  /// Fetches paginated list of notifications.
  ///
  /// [limit] - Maximum number of notifications to return (default: 20)
  /// [offset] - Number of notifications to skip (for pagination)
  ///
  /// Returns [Success] with list of notifications, or [Failure] on error.
  Future<Result<List<AppNotification>>> getNotifications({
    int limit = 20,
    int offset = 0,
  });

  /// Gets the count of unread notifications.
  ///
  /// Returns [Success] with count, or [Failure] on error.
  Future<Result<int>> getUnreadCount();

  /// Marks a single notification as read.
  ///
  /// [notificationId] - The ID of the notification to mark as read
  ///
  /// Returns [Success] on success, or [Failure] on error.
  Future<Result<void>> markAsRead(String notificationId);

  /// Marks all notifications as read.
  ///
  /// Returns [Success] on success, or [Failure] on error.
  Future<Result<void>> markAllAsRead();

  /// Stream of notifications for real-time updates.
  ///
  /// Emits a new list whenever notifications change (new notification,
  /// read status change, etc.).
  Stream<List<AppNotification>> watchNotifications();

  // ============================================================
  // SETTINGS
  // ============================================================

  /// Gets user's notification settings.
  ///
  /// Returns [Success] with list of settings, or [Failure] on error.
  Future<Result<List<NotificationSetting>>> getSettings();

  /// Updates a single notification setting.
  ///
  /// [setting] - The setting to update
  ///
  /// Returns [Success] on success, or [Failure] on error.
  Future<Result<void>> updateSetting(NotificationSetting setting);

  /// Updates multiple notification settings at once.
  ///
  /// [settings] - List of settings to update
  ///
  /// Returns [Success] on success, or [Failure] on error.
  Future<Result<void>> updateSettings(List<NotificationSetting> settings);

  // ============================================================
  // DEVICE TOKENS
  // ============================================================

  /// Registers a device token for push notifications.
  ///
  /// [token] - The FCM device token to register
  ///
  /// Returns [Success] on success, or [Failure] on error.
  Future<Result<void>> registerDeviceToken(String token);

  /// Unregisters a device token (e.g., on logout).
  ///
  /// [token] - The FCM device token to unregister
  ///
  /// Returns [Success] on success, or [Failure] on error.
  Future<Result<void>> unregisterDeviceToken(String token);
}
