import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/notifications/domain/entities/app_notification.dart';
import 'package:lynewed_beta/features/notifications/domain/entities/notification_setting.dart';
import 'package:lynewed_beta/features/notifications/domain/repositories/notification_repository.dart';

/// Mock implementation of NotificationRepository for testing.
class MockNotificationRepository implements NotificationRepository {
  final List<AppNotification> _notifications = [];
  final List<NotificationSetting> _settings = [];
  String? _registeredToken;
  bool _shouldFail = false;

  void setShouldFail(bool value) => _shouldFail = value;

  void addNotification(AppNotification notification) {
    _notifications.add(notification);
  }

  void addSetting(NotificationSetting setting) {
    _settings.add(setting);
  }

  @override
  Future<Result<List<AppNotification>>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    if (_shouldFail) {
      return const Failure(ServerFailure('Failed to fetch notifications'));
    }
    final result = _notifications.skip(offset).take(limit).toList();
    return Success(result);
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    if (_shouldFail) {
      return const Failure(ServerFailure('Failed to get unread count'));
    }
    final count = _notifications.where((n) => !n.isRead).length;
    return Success(count);
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    if (_shouldFail) {
      return const Failure(ServerFailure('Failed to mark as read'));
    }
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(
        readAt: DateTime.now(),
      );
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    if (_shouldFail) {
      return const Failure(ServerFailure('Failed to mark all as read'));
    }
    final now = DateTime.now();
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(readAt: now);
      }
    }
    return const Success(null);
  }

  @override
  Stream<List<AppNotification>> watchNotifications() {
    return Stream.value(_notifications);
  }

  @override
  Future<Result<List<NotificationSetting>>> getSettings() async {
    if (_shouldFail) {
      return const Failure(ServerFailure('Failed to get settings'));
    }
    return Success(_settings);
  }

  @override
  Future<Result<void>> updateSetting(NotificationSetting setting) async {
    if (_shouldFail) {
      return const Failure(ServerFailure('Failed to update setting'));
    }
    final index = _settings.indexWhere((s) => s.id == setting.id);
    if (index >= 0) {
      _settings[index] = setting;
    } else {
      _settings.add(setting);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> updateSettings(List<NotificationSetting> settings) async {
    if (_shouldFail) {
      return const Failure(ServerFailure('Failed to update settings'));
    }
    for (final setting in settings) {
      await updateSetting(setting);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> registerDeviceToken(String token) async {
    if (_shouldFail) {
      return const Failure(ServerFailure('Failed to register token'));
    }
    _registeredToken = token;
    return const Success(null);
  }

  @override
  Future<Result<void>> unregisterDeviceToken(String token) async {
    if (_shouldFail) {
      return const Failure(ServerFailure('Failed to unregister token'));
    }
    if (_registeredToken == token) {
      _registeredToken = null;
    }
    return const Success(null);
  }

  String? get registeredToken => _registeredToken;
}

void main() {
  // ==============================================================
  // TEST FIXTURES
  // ==============================================================

  late MockNotificationRepository repository;

  final testNotification = AppNotification(
    id: 'notif-123',
    type: NotificationType.chatMessage,
    title: 'New Message',
    body: 'You have a new message',
    data: const {'chat_room_id': 'room-456'},
    createdAt: DateTime.now(),
  );

  final testNotification2 = AppNotification(
    id: 'notif-456',
    type: NotificationType.connectionRequest,
    title: 'Contact Request',
    body: 'John wants to connect',
    data: const {'sender_id': 'user-789'},
    createdAt: DateTime.now(),
  );

  const testSetting = NotificationSetting(
    id: 'setting-123',
    profileId: 'user-456',
    notificationType: 'chatMessage',
    inAppEnabled: true,
    pushEnabled: true,
  );

  setUp(() {
    repository = MockNotificationRepository();
  });

  // ==============================================================
  // REPOSITORY INTERFACE VERIFICATION
  // ==============================================================

  group('NotificationRepository', () {
    test('should be implementable as an abstract class', () {
      expect(repository, isA<NotificationRepository>());
    });
  });

  // ==============================================================
  // NOTIFICATIONS CRUD TESTS
  // ==============================================================

  group('getNotifications', () {
    test('should return list of notifications', () async {
      repository.addNotification(testNotification);
      repository.addNotification(testNotification2);

      final result = await repository.getNotifications();

      expect(result.isSuccess, true);
      final notifications = (result as Success<List<AppNotification>>).data;
      expect(notifications, hasLength(2));
      expect(notifications[0].id, 'notif-123');
      expect(notifications[1].id, 'notif-456');
    });

    test('should support pagination with limit and offset', () async {
      repository.addNotification(testNotification);
      repository.addNotification(testNotification2);
      final testNotification3 = testNotification.copyWith(id: 'notif-789');
      repository.addNotification(testNotification3);

      final result = await repository.getNotifications(limit: 2, offset: 1);

      expect(result.isSuccess, true);
      final notifications = (result as Success<List<AppNotification>>).data;
      expect(notifications, hasLength(2));
      expect(notifications[0].id, 'notif-456');
      expect(notifications[1].id, 'notif-789');
    });

    test('should return empty list when no notifications', () async {
      final result = await repository.getNotifications();

      expect(result.isSuccess, true);
      final notifications = (result as Success<List<AppNotification>>).data;
      expect(notifications, isEmpty);
    });

    test('should return Failure on error', () async {
      repository.setShouldFail(true);

      final result = await repository.getNotifications();

      expect(result.isFailure, true);
      expect((result as Failure).failure, isA<ServerFailure>());
    });
  });

  group('getUnreadCount', () {
    test('should return count of unread notifications', () async {
      repository.addNotification(testNotification); // unread
      repository.addNotification(testNotification2); // unread

      final result = await repository.getUnreadCount();

      expect(result.isSuccess, true);
      expect((result as Success<int>).data, 2);
    });

    test('should return 0 when all notifications are read', () async {
      final readNotification = testNotification.copyWith(readAt: DateTime.now());
      repository.addNotification(readNotification);

      final result = await repository.getUnreadCount();

      expect(result.isSuccess, true);
      expect((result as Success<int>).data, 0);
    });

    test('should return Failure on error', () async {
      repository.setShouldFail(true);

      final result = await repository.getUnreadCount();

      expect(result.isFailure, true);
    });
  });

  group('markAsRead', () {
    test('should mark notification as read', () async {
      repository.addNotification(testNotification);

      final result = await repository.markAsRead('notif-123');

      expect(result.isSuccess, true);

      // Verify notification is now read
      final notificationsResult = await repository.getNotifications();
      final notifications = (notificationsResult as Success<List<AppNotification>>).data;
      expect(notifications[0].isRead, true);
    });

    test('should return Success even if notification not found', () async {
      final result = await repository.markAsRead('nonexistent');

      expect(result.isSuccess, true);
    });

    test('should return Failure on error', () async {
      repository.setShouldFail(true);

      final result = await repository.markAsRead('notif-123');

      expect(result.isFailure, true);
    });
  });

  group('markAllAsRead', () {
    test('should mark all notifications as read', () async {
      repository.addNotification(testNotification);
      repository.addNotification(testNotification2);

      final result = await repository.markAllAsRead();

      expect(result.isSuccess, true);

      // Verify all notifications are read
      final countResult = await repository.getUnreadCount();
      expect((countResult as Success<int>).data, 0);
    });

    test('should return Failure on error', () async {
      repository.setShouldFail(true);

      final result = await repository.markAllAsRead();

      expect(result.isFailure, true);
    });
  });

  group('watchNotifications', () {
    test('should return stream of notifications', () async {
      repository.addNotification(testNotification);

      final stream = repository.watchNotifications();

      await expectLater(
        stream,
        emits(contains(testNotification)),
      );
    });
  });

  // ==============================================================
  // SETTINGS TESTS
  // ==============================================================

  group('getSettings', () {
    test('should return list of settings', () async {
      repository.addSetting(testSetting);

      final result = await repository.getSettings();

      expect(result.isSuccess, true);
      final settings = (result as Success<List<NotificationSetting>>).data;
      expect(settings, hasLength(1));
      expect(settings[0].id, 'setting-123');
    });

    test('should return empty list when no settings', () async {
      final result = await repository.getSettings();

      expect(result.isSuccess, true);
      final settings = (result as Success<List<NotificationSetting>>).data;
      expect(settings, isEmpty);
    });

    test('should return Failure on error', () async {
      repository.setShouldFail(true);

      final result = await repository.getSettings();

      expect(result.isFailure, true);
    });
  });

  group('updateSetting', () {
    test('should update existing setting', () async {
      repository.addSetting(testSetting);
      final updatedSetting = testSetting.copyWith(pushEnabled: false);

      final result = await repository.updateSetting(updatedSetting);

      expect(result.isSuccess, true);

      final settingsResult = await repository.getSettings();
      final settings = (settingsResult as Success<List<NotificationSetting>>).data;
      expect(settings[0].pushEnabled, false);
    });

    test('should add setting if not exists', () async {
      final result = await repository.updateSetting(testSetting);

      expect(result.isSuccess, true);

      final settingsResult = await repository.getSettings();
      final settings = (settingsResult as Success<List<NotificationSetting>>).data;
      expect(settings, hasLength(1));
    });

    test('should return Failure on error', () async {
      repository.setShouldFail(true);

      final result = await repository.updateSetting(testSetting);

      expect(result.isFailure, true);
    });
  });

  group('updateSettings', () {
    test('should update multiple settings', () async {
      const setting2 = NotificationSetting(
        id: 'setting-456',
        profileId: 'user-456',
        notificationType: 'connectionRequest',
        inAppEnabled: true,
        pushEnabled: false,
      );

      final result = await repository.updateSettings([testSetting, setting2]);

      expect(result.isSuccess, true);

      final settingsResult = await repository.getSettings();
      final settings = (settingsResult as Success<List<NotificationSetting>>).data;
      expect(settings, hasLength(2));
    });

    test('should return Failure on error', () async {
      repository.setShouldFail(true);

      final result = await repository.updateSettings([testSetting]);

      expect(result.isFailure, true);
    });
  });

  // ==============================================================
  // DEVICE TOKEN TESTS
  // ==============================================================

  group('registerDeviceToken', () {
    test('should register device token', () async {
      final result = await repository.registerDeviceToken('fcm-token-123');

      expect(result.isSuccess, true);
      expect(repository.registeredToken, 'fcm-token-123');
    });

    test('should return Failure on error', () async {
      repository.setShouldFail(true);

      final result = await repository.registerDeviceToken('fcm-token-123');

      expect(result.isFailure, true);
    });
  });

  group('unregisterDeviceToken', () {
    test('should unregister device token', () async {
      await repository.registerDeviceToken('fcm-token-123');

      final result = await repository.unregisterDeviceToken('fcm-token-123');

      expect(result.isSuccess, true);
      expect(repository.registeredToken, isNull);
    });

    test('should return Success even if token not registered', () async {
      final result = await repository.unregisterDeviceToken('nonexistent');

      expect(result.isSuccess, true);
    });

    test('should return Failure on error', () async {
      repository.setShouldFail(true);

      final result = await repository.unregisterDeviceToken('fcm-token-123');

      expect(result.isFailure, true);
    });
  });
}
