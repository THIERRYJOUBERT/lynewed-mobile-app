import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:lynewed_beta/features/notifications/data/models/notification_model.dart';
import 'package:lynewed_beta/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:lynewed_beta/features/notifications/domain/entities/app_notification.dart';
import 'package:lynewed_beta/features/notifications/domain/entities/notification_setting.dart';

// ==============================================================
// MOCKS
// ==============================================================

class MockNotificationRemoteDatasource extends Mock
    implements NotificationRemoteDatasource {}

void main() {
  late MockNotificationRemoteDatasource mockDatasource;
  late NotificationRepositoryImpl repository;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(
      const NotificationSetting(
        id: 'fallback-id',
        profileId: 'fallback-profile',
        notificationType: 'chatMessage',
        inAppEnabled: true,
        pushEnabled: true,
      ),
    );
    registerFallbackValue(<NotificationSetting>[]);
  });

  setUp(() {
    mockDatasource = MockNotificationRemoteDatasource();
    repository = NotificationRepositoryImpl(datasource: mockDatasource);
  });

  // ==============================================================
  // TEST DATA
  // ==============================================================

  final testNotificationModel = NotificationModel(
    id: 'notif-1',
    type: 'chatMessage',
    title: 'New Message',
    body: 'You have a new message',
    imageUrl: 'https://example.com/avatar.jpg',
    data: {'chat_room_id': 'room-123'},
    createdAt: DateTime(2024, 1, 15, 10, 30),
    readAt: null,
  );

  final testNotificationModel2 = NotificationModel(
    id: 'notif-2',
    type: 'connectionRequest',
    title: 'Connection Request',
    body: 'Someone wants to connect',
    imageUrl: null,
    data: {'sender_id': 'user-456'},
    createdAt: DateTime(2024, 1, 15, 9, 0),
    readAt: DateTime(2024, 1, 15, 9, 30),
  );

  final testSetting = NotificationSetting(
    id: 'setting-1',
    profileId: 'user-123',
    notificationType: 'chatMessage',
    inAppEnabled: true,
    pushEnabled: true,
  );

  // ==============================================================
  // GETNOTIFICATIONS TESTS
  // ==============================================================

  group('getNotifications', () {
    test('should return success with list of notifications', () async {
      // Arrange
      when(() => mockDatasource.getNotifications(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => [testNotificationModel, testNotificationModel2]);

      // Act
      final result = await repository.getNotifications(limit: 20, offset: 0);

      // Assert
      expect(result.isSuccess, true);
      final notifications = result.getOrNull();
      expect(notifications, isNotNull);
      expect(notifications!.length, 2);
      expect(notifications[0].id, 'notif-1');
      expect(notifications[0].type, NotificationType.chatMessage);
      expect(notifications[1].id, 'notif-2');
      expect(notifications[1].isRead, true);
      verify(() => mockDatasource.getNotifications(limit: 20, offset: 0)).called(1);
    });

    test('should return failure when datasource throws', () async {
      // Arrange
      when(() => mockDatasource.getNotifications(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenThrow(Exception('Network error'));

      // Act
      final result = await repository.getNotifications();

      // Assert
      expect(result.isFailure, true);
      expect(result.failureOrNull(), isA<ServerFailure>());
    });

    test('should return empty list when datasource returns empty', () async {
      // Arrange
      when(() => mockDatasource.getNotifications(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => []);

      // Act
      final result = await repository.getNotifications();

      // Assert
      expect(result.isSuccess, true);
      expect(result.getOrNull(), isEmpty);
    });
  });

  // ==============================================================
  // GETUNREADCOUNT TESTS
  // ==============================================================

  group('getUnreadCount', () {
    test('should return success with count', () async {
      // Arrange
      when(() => mockDatasource.getUnreadCount())
          .thenAnswer((_) async => 5);

      // Act
      final result = await repository.getUnreadCount();

      // Assert
      expect(result.isSuccess, true);
      expect(result.getOrNull(), 5);
      verify(() => mockDatasource.getUnreadCount()).called(1);
    });

    test('should return failure when datasource throws', () async {
      // Arrange
      when(() => mockDatasource.getUnreadCount())
          .thenThrow(Exception('Database error'));

      // Act
      final result = await repository.getUnreadCount();

      // Assert
      expect(result.isFailure, true);
      expect(result.failureOrNull(), isA<ServerFailure>());
    });

    test('should return 0 when no unread notifications', () async {
      // Arrange
      when(() => mockDatasource.getUnreadCount())
          .thenAnswer((_) async => 0);

      // Act
      final result = await repository.getUnreadCount();

      // Assert
      expect(result.isSuccess, true);
      expect(result.getOrNull(), 0);
    });
  });

  // ==============================================================
  // MARKASREAD TESTS
  // ==============================================================

  group('markAsRead', () {
    test('should return success when mark as read succeeds', () async {
      // Arrange
      when(() => mockDatasource.markAsRead(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.markAsRead('notif-1');

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockDatasource.markAsRead('notif-1')).called(1);
    });

    test('should return failure when datasource throws', () async {
      // Arrange
      when(() => mockDatasource.markAsRead(any()))
          .thenThrow(Exception('Update failed'));

      // Act
      final result = await repository.markAsRead('notif-1');

      // Assert
      expect(result.isFailure, true);
      expect(result.failureOrNull(), isA<ServerFailure>());
    });
  });

  // ==============================================================
  // MARKALLASREAD TESTS
  // ==============================================================

  group('markAllAsRead', () {
    test('should return success when mark all as read succeeds', () async {
      // Arrange
      when(() => mockDatasource.markAllAsRead())
          .thenAnswer((_) async {});

      // Act
      final result = await repository.markAllAsRead();

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockDatasource.markAllAsRead()).called(1);
    });

    test('should return failure when datasource throws', () async {
      // Arrange
      when(() => mockDatasource.markAllAsRead())
          .thenThrow(Exception('Batch update failed'));

      // Act
      final result = await repository.markAllAsRead();

      // Assert
      expect(result.isFailure, true);
      expect(result.failureOrNull(), isA<ServerFailure>());
    });
  });

  // ==============================================================
  // WATCHNOTIFICATIONS TESTS
  // ==============================================================

  group('watchNotifications', () {
    test('should delegate to datasource and transform to entities', () async {
      // Arrange
      when(() => mockDatasource.watchNotifications())
          .thenAnswer((_) => Stream.value([testNotificationModel]));

      // Act
      final stream = repository.watchNotifications();
      final notifications = await stream.first;

      // Assert
      expect(notifications.length, 1);
      expect(notifications[0].id, 'notif-1');
      expect(notifications[0].type, NotificationType.chatMessage);
      verify(() => mockDatasource.watchNotifications()).called(1);
    });

    test('should emit empty list when datasource returns empty', () async {
      // Arrange
      when(() => mockDatasource.watchNotifications())
          .thenAnswer((_) => Stream.value([]));

      // Act
      final stream = repository.watchNotifications();
      final notifications = await stream.first;

      // Assert
      expect(notifications, isEmpty);
    });
  });

  // ==============================================================
  // GETSETTINGS TESTS
  // ==============================================================

  group('getSettings', () {
    test('should return success with settings list', () async {
      // Arrange
      when(() => mockDatasource.getSettings())
          .thenAnswer((_) async => [testSetting]);

      // Act
      final result = await repository.getSettings();

      // Assert
      expect(result.isSuccess, true);
      final settings = result.getOrNull();
      expect(settings, isNotNull);
      expect(settings!.length, 1);
      expect(settings[0].notificationType, 'chatMessage');
      verify(() => mockDatasource.getSettings()).called(1);
    });

    test('should return failure when datasource throws', () async {
      // Arrange
      when(() => mockDatasource.getSettings())
          .thenThrow(Exception('Fetch failed'));

      // Act
      final result = await repository.getSettings();

      // Assert
      expect(result.isFailure, true);
      expect(result.failureOrNull(), isA<ServerFailure>());
    });
  });

  // ==============================================================
  // UPDATESETTING TESTS
  // ==============================================================

  group('updateSetting', () {
    test('should return success when update succeeds', () async {
      // Arrange
      when(() => mockDatasource.updateSetting(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.updateSetting(testSetting);

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockDatasource.updateSetting(testSetting)).called(1);
    });

    test('should return failure when datasource throws', () async {
      // Arrange
      when(() => mockDatasource.updateSetting(any()))
          .thenThrow(Exception('Update failed'));

      // Act
      final result = await repository.updateSetting(testSetting);

      // Assert
      expect(result.isFailure, true);
      expect(result.failureOrNull(), isA<ServerFailure>());
    });
  });

  // ==============================================================
  // UPDATESETTINGS TESTS
  // ==============================================================

  group('updateSettings', () {
    test('should return success when batch update succeeds', () async {
      // Arrange
      when(() => mockDatasource.updateSettings(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.updateSettings([testSetting]);

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockDatasource.updateSettings([testSetting])).called(1);
    });

    test('should return failure when datasource throws', () async {
      // Arrange
      when(() => mockDatasource.updateSettings(any()))
          .thenThrow(Exception('Batch update failed'));

      // Act
      final result = await repository.updateSettings([testSetting]);

      // Assert
      expect(result.isFailure, true);
      expect(result.failureOrNull(), isA<ServerFailure>());
    });
  });

  // ==============================================================
  // REGISTERDEVICETOKEN TESTS
  // ==============================================================

  group('registerDeviceToken', () {
    test('should return success when registration succeeds', () async {
      // Arrange
      when(() => mockDatasource.registerDeviceToken(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.registerDeviceToken('fcm-token-123');

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockDatasource.registerDeviceToken('fcm-token-123')).called(1);
    });

    test('should return failure when datasource throws', () async {
      // Arrange
      when(() => mockDatasource.registerDeviceToken(any()))
          .thenThrow(Exception('Registration failed'));

      // Act
      final result = await repository.registerDeviceToken('fcm-token-123');

      // Assert
      expect(result.isFailure, true);
      expect(result.failureOrNull(), isA<ServerFailure>());
    });
  });

  // ==============================================================
  // UNREGISTERDEVICETOKEN TESTS
  // ==============================================================

  group('unregisterDeviceToken', () {
    test('should return success when unregistration succeeds', () async {
      // Arrange
      when(() => mockDatasource.unregisterDeviceToken(any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.unregisterDeviceToken('fcm-token-123');

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockDatasource.unregisterDeviceToken('fcm-token-123')).called(1);
    });

    test('should return failure when datasource throws', () async {
      // Arrange
      when(() => mockDatasource.unregisterDeviceToken(any()))
          .thenThrow(Exception('Unregistration failed'));

      // Act
      final result = await repository.unregisterDeviceToken('fcm-token-123');

      // Assert
      expect(result.isFailure, true);
      expect(result.failureOrNull(), isA<ServerFailure>());
    });
  });
}
