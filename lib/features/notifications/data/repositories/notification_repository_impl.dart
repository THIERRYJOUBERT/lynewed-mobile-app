/// Notification repository implementation - Clean Architecture.
///
/// Implements [NotificationRepository] using [NotificationRemoteDatasource].
/// Handles error conversion from exceptions to failures.
library;

import 'package:lynewed_beta/core/core.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_setting.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

/// Implementation of [NotificationRepository].
///
/// This class:
/// - Delegates to [NotificationRemoteDatasource] for data operations
/// - Converts data models to domain entities
/// - Wraps results in [Result] type for error handling
class NotificationRepositoryImpl implements NotificationRepository {
  /// Creates a notification repository implementation.
  ///
  /// [datasource] - Optional datasource for testing. Defaults to new instance.
  NotificationRepositoryImpl({NotificationRemoteDatasource? datasource})
      : _datasource = datasource ?? NotificationRemoteDatasource();

  final NotificationRemoteDatasource _datasource;

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  @override
  Future<Result<List<AppNotification>>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final models = await _datasource.getNotifications(
        limit: limit,
        offset: offset,
      );
      final entities = models.map((m) => m.toEntity()).toList();
      return Success(entities);
    } catch (e) {
      return Failure(ServerFailure('Failed to load notifications: $e'));
    }
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    try {
      final count = await _datasource.getUnreadCount();
      return Success(count);
    } catch (e) {
      return Failure(ServerFailure('Failed to get unread count: $e'));
    }
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    try {
      await _datasource.markAsRead(notificationId);
      return const Success(null);
    } catch (e) {
      return Failure(ServerFailure('Failed to mark notification as read: $e'));
    }
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    try {
      await _datasource.markAllAsRead();
      return const Success(null);
    } catch (e) {
      return Failure(ServerFailure('Failed to mark all notifications as read: $e'));
    }
  }

  @override
  Stream<List<AppNotification>> watchNotifications() {
    return _datasource.watchNotifications().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  @override
  Future<Result<List<NotificationSetting>>> getSettings() async {
    try {
      final settings = await _datasource.getSettings();
      return Success(settings);
    } catch (e) {
      return Failure(ServerFailure('Failed to load notification settings: $e'));
    }
  }

  @override
  Future<Result<void>> updateSetting(NotificationSetting setting) async {
    try {
      await _datasource.updateSetting(setting);
      return const Success(null);
    } catch (e) {
      return Failure(ServerFailure('Failed to update notification setting: $e'));
    }
  }

  @override
  Future<Result<void>> updateSettings(List<NotificationSetting> settings) async {
    try {
      await _datasource.updateSettings(settings);
      return const Success(null);
    } catch (e) {
      return Failure(ServerFailure('Failed to update notification settings: $e'));
    }
  }

  // ============================================================
  // DEVICE TOKENS
  // ============================================================

  @override
  Future<Result<void>> registerDeviceToken(String token) async {
    try {
      await _datasource.registerDeviceToken(token);
      return const Success(null);
    } catch (e) {
      return Failure(ServerFailure('Failed to register device token: $e'));
    }
  }

  @override
  Future<Result<void>> unregisterDeviceToken(String token) async {
    try {
      await _datasource.unregisterDeviceToken(token);
      return const Success(null);
    } catch (e) {
      return Failure(ServerFailure('Failed to unregister device token: $e'));
    }
  }
}
