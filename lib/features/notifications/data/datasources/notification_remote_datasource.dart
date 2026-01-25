/// Notification remote datasource - Clean Architecture.
///
/// Handles all Supabase operations for the notifications module.
/// Integrates the custom code actions into a proper Clean Architecture datasource.
library;

import 'dart:async';
import 'dart:io' show Platform;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/notification_setting.dart';
import '../models/notification_model.dart';

/// Remote datasource for notification operations.
///
/// This datasource integrates with Supabase for:
/// - Fetching notifications (replaces get_notifications_action.dart)
/// - Getting unread count (replaces get_unread_notifications_count.dart)
/// - Marking as read (replaces mark_notification_as_read.dart)
/// - Marking all as read (replaces mark_all_notifications_as_read.dart)
/// - Managing notification settings
/// - Registering/unregistering FCM device tokens
///
/// Push notification handling is done via [firebaseMessagingBackgroundHandler]
/// in lib/custom_code/push_background.dart.
class NotificationRemoteDatasource {
  /// Creates a notification remote datasource.
  ///
  /// [client] - Optional Supabase client for testing. Defaults to singleton.
  NotificationRemoteDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  RealtimeChannel? _notificationsChannel;

  String? get _currentUserId => _client.auth.currentUser?.id;

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  /// Fetches paginated list of notifications.
  ///
  /// Uses the `get_formatted_notifications` RPC function.
  /// Equivalent to: lib/custom_code/actions/get_notifications_action.dart
  ///
  /// [limit] - Maximum number of notifications to return (default: 20)
  /// [offset] - Number of notifications to skip (for pagination)
  ///
  /// Returns list of [NotificationModel] sorted by creation date (newest first).
  Future<List<NotificationModel>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client.rpc(
      'get_formatted_notifications',
      params: {'p_limit': limit + offset},
    );

    if (response == null ||
        response is! Map<String, dynamic> ||
        response['items'] == null ||
        response['items'] is! List) {
      return [];
    }

    final List<dynamic> itemList = response['items'];
    final List<NotificationModel> notifications = [];

    for (var i = offset; i < itemList.length && notifications.length < limit; i++) {
      final itemData = itemList[i];
      if (itemData is Map<String, dynamic>) {
        notifications.add(NotificationModel.fromJson(itemData));
      }
    }

    return notifications;
  }

  /// Gets the count of unread notifications.
  ///
  /// Uses the `get_unread_notifications_count` RPC function.
  /// Equivalent to: lib/custom_code/actions/get_unread_notifications_count.dart
  ///
  /// Returns the count of unread notifications.
  Future<int> getUnreadCount() async {
    final response = await _client.rpc('get_unread_notifications_count');
    return response as int? ?? 0;
  }

  /// Marks a single notification as read.
  ///
  /// Uses the `mark_notification_as_read` RPC function.
  /// Equivalent to: lib/custom_code/actions/mark_notification_as_read.dart
  ///
  /// [notificationId] - The ID of the notification to mark as read
  Future<void> markAsRead(String notificationId) async {
    await _client.rpc(
      'mark_notification_as_read',
      params: {'p_notification_id': notificationId},
    );
  }

  /// Marks all notifications as read.
  ///
  /// Uses the `mark_all_notifications_as_read` RPC function.
  /// Equivalent to: lib/custom_code/actions/mark_all_notifications_as_read.dart
  Future<void> markAllAsRead() async {
    await _client.rpc('mark_all_notifications_as_read');
  }

  /// Stream of notifications for real-time updates.
  ///
  /// Uses Supabase Realtime to listen for changes to the notifications table.
  /// Emits a new list whenever notifications change.
  Stream<List<NotificationModel>> watchNotifications() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    final controller = StreamController<List<NotificationModel>>.broadcast();

    // Clean up existing subscription
    _notificationsChannel?.unsubscribe();

    // Set up realtime subscription
    _notificationsChannel = _client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            // Fetch fresh data on any change
            try {
              final notifications = await getNotifications(limit: 50);
              controller.add(notifications);
            } catch (e) {
              // Silently handle errors - stream continues
            }
          },
        )
        .subscribe();

    // Fetch initial data
    getNotifications(limit: 50).then((notifications) {
      if (!controller.isClosed) {
        controller.add(notifications);
      }
    }).catchError((e) {
      if (!controller.isClosed) {
        controller.add([]);
      }
    });

    controller.onCancel = () {
      _notificationsChannel?.unsubscribe();
      _notificationsChannel = null;
    };

    return controller.stream;
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  /// Gets user's notification settings.
  ///
  /// Fetches all notification settings for the current user.
  Future<List<NotificationSetting>> getSettings() async {
    final userId = _currentUserId;
    if (userId == null) {
      return [];
    }

    final response = await _client
        .from('notification_settings')
        .select()
        .eq('profile_id', userId);

    return (response as List<dynamic>)
        .map((item) => NotificationSetting.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Updates a single notification setting.
  ///
  /// Uses upsert to create or update the setting.
  /// Equivalent to: lib/custom_code/actions/upsert_notification_setting.dart
  Future<void> updateSetting(NotificationSetting setting) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _client.from('notification_settings').upsert(
      {
        'profile_id': userId,
        'notification_type': setting.notificationType,
        'in_app_enabled': setting.inAppEnabled,
        'push_enabled': setting.pushEnabled,
      },
      onConflict: 'profile_id,notification_type',
    );
  }

  /// Updates multiple notification settings at once.
  ///
  /// Uses upsert for each setting.
  Future<void> updateSettings(List<NotificationSetting> settings) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final records = settings.map((s) => {
      'profile_id': userId,
      'notification_type': s.notificationType,
      'in_app_enabled': s.inAppEnabled,
      'push_enabled': s.pushEnabled,
    }).toList();

    await _client.from('notification_settings').upsert(
      records,
      onConflict: 'profile_id,notification_type',
    );
  }

  // ============================================================
  // DEVICE TOKENS
  // ============================================================

  /// Registers a device token for push notifications.
  ///
  /// The token is upserted with the current user's profile ID and platform.
  /// Integration with: lib/custom_code/actions/init_push_notifications.dart
  Future<void> registerDeviceToken(String token) async {
    final userId = _currentUserId;
    if (userId == null || token.isEmpty) {
      throw Exception('User not authenticated or token is empty');
    }

    final platform = Platform.isIOS
        ? 'ios'
        : (Platform.isAndroid ? 'android' : 'web');

    await _client.from('device_tokens').upsert(
      {
        'token': token,
        'profile_id': userId,
        'platform': platform,
        'last_seen_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'token',
    );
  }

  /// Unregisters a device token (e.g., on logout).
  ///
  /// Uses the `delete_current_device_token` RPC function.
  /// Integration with: lib/custom_code/actions/init_push_notifications.dart
  Future<void> unregisterDeviceToken(String token) async {
    if (token.isEmpty) {
      return;
    }

    await _client.rpc(
      'delete_current_device_token',
      params: {'device_token': token},
    );
  }

  /// Disposes realtime subscriptions.
  void dispose() {
    _notificationsChannel?.unsubscribe();
    _notificationsChannel = null;
  }
}
