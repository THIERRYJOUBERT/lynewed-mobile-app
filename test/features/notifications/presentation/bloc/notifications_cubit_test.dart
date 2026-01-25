/// Tests for NotificationsNotifier (using ChangeNotifier pattern)
///
/// Verifies reactive state management for notifications using the Clean
/// Architecture repository pattern, following the same approach as
/// ConversationsNotifier.
library;

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/notifications/domain/entities/app_notification.dart';
import 'package:lynewed_beta/features/notifications/domain/repositories/notification_repository.dart';
import 'package:lynewed_beta/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:lynewed_beta/features/notifications/presentation/bloc/notifications_state.dart';

// Mock repository
class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepository;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue('test-id');
  });

  setUp(() {
    mockRepository = MockNotificationRepository();
  });

  // Test data
  AppNotification createTestNotification({
    String id = 'notif-1',
    NotificationType type = NotificationType.chatMessage,
    String title = 'Test Notification',
    String body = 'Test body',
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      data: const {},
      createdAt: createdAt ?? DateTime.now(),
      readAt: readAt,
    );
  }

  group('NotificationsNotifier', () {
    group('initial state', () {
      test('should have initial state', () {
        // Arrange
        when(() => mockRepository.watchNotifications())
            .thenAnswer((_) => const Stream.empty());

        // Act
        final notifier = NotificationsNotifier(repository: mockRepository);

        // Assert
        expect(notifier.state, isA<NotificationsInitial>());

        // Cleanup
        notifier.dispose();
      });
    });

    group('loadNotifications', () {
      test('emits loading then loaded when getNotifications succeeds', () async {
        // Arrange
        final notifications = [
          createTestNotification(id: 'notif-1'),
          createTestNotification(id: 'notif-2'),
        ];
        when(() => mockRepository.getNotifications(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => Success(notifications));
        when(() => mockRepository.watchNotifications())
            .thenAnswer((_) => const Stream.empty());

        final notifier = NotificationsNotifier(repository: mockRepository);
        final states = <NotificationsState>[];
        notifier.addListener(() => states.add(notifier.state));

        // Act
        await notifier.loadNotifications();

        // Assert
        expect(states.length, 2);
        expect(states[0], isA<NotificationsLoading>());
        expect(states[1], isA<NotificationsLoaded>());
        final loadedState = states[1] as NotificationsLoaded;
        expect(loadedState.notifications.length, 2);

        verify(() => mockRepository.getNotifications(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).called(1);

        // Cleanup
        notifier.dispose();
      });

      test('emits loading then error when getNotifications fails', () async {
        // Arrange
        when(() => mockRepository.getNotifications(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer(
            (_) async => Failure(ServerFailure('Server error')));
        when(() => mockRepository.watchNotifications())
            .thenAnswer((_) => const Stream.empty());

        final notifier = NotificationsNotifier(repository: mockRepository);
        final states = <NotificationsState>[];
        notifier.addListener(() => states.add(notifier.state));

        // Act
        await notifier.loadNotifications();

        // Assert
        expect(states.length, 2);
        expect(states[0], isA<NotificationsLoading>());
        expect(states[1], isA<NotificationsError>());
        final errorState = states[1] as NotificationsError;
        expect(errorState.message, contains('Server error'));

        // Cleanup
        notifier.dispose();
      });
    });

    group('markAsRead', () {
      test('updates notification to read when markAsRead succeeds', () async {
        // Arrange
        when(() => mockRepository.markAsRead(any()))
            .thenAnswer((_) async => const Success(null));
        when(() => mockRepository.watchNotifications())
            .thenAnswer((_) => const Stream.empty());

        final notifier = NotificationsNotifier(repository: mockRepository);

        // Set initial loaded state with unread notification
        notifier.setStateForTesting(NotificationsLoaded(
          notifications: [
            createTestNotification(id: 'notif-1', readAt: null),
            createTestNotification(id: 'notif-2', readAt: null),
          ],
        ));

        // Act
        await notifier.markAsRead('notif-1');

        // Assert
        final state = notifier.state as NotificationsLoaded;
        expect(
          state.notifications.firstWhere((n) => n.id == 'notif-1').isRead,
          true,
        );
        verify(() => mockRepository.markAsRead('notif-1')).called(1);

        // Cleanup
        notifier.dispose();
      });

      test('rolls back on failure', () async {
        // Arrange
        when(() => mockRepository.markAsRead(any()))
            .thenAnswer((_) async => Failure(ServerFailure('Failed')));
        when(() => mockRepository.watchNotifications())
            .thenAnswer((_) => const Stream.empty());

        final notifier = NotificationsNotifier(repository: mockRepository);

        // Set initial loaded state with unread notification
        notifier.setStateForTesting(NotificationsLoaded(
          notifications: [
            createTestNotification(id: 'notif-1', readAt: null),
          ],
        ));

        // Act
        await notifier.markAsRead('notif-1');

        // Assert - should be rolled back to unread
        final state = notifier.state as NotificationsLoaded;
        expect(
          state.notifications.firstWhere((n) => n.id == 'notif-1').isRead,
          false,
        );

        // Cleanup
        notifier.dispose();
      });
    });

    group('markAllAsRead', () {
      test('updates all notifications to read when markAllAsRead succeeds', () async {
        // Arrange
        when(() => mockRepository.markAllAsRead())
            .thenAnswer((_) async => const Success(null));
        when(() => mockRepository.watchNotifications())
            .thenAnswer((_) => const Stream.empty());

        final notifier = NotificationsNotifier(repository: mockRepository);

        // Set initial loaded state with unread notifications
        notifier.setStateForTesting(NotificationsLoaded(
          notifications: [
            createTestNotification(id: 'notif-1', readAt: null),
            createTestNotification(id: 'notif-2', readAt: null),
          ],
        ));

        // Act
        await notifier.markAllAsRead();

        // Assert
        final state = notifier.state as NotificationsLoaded;
        expect(state.notifications.every((n) => n.isRead), true);
        verify(() => mockRepository.markAllAsRead()).called(1);

        // Cleanup
        notifier.dispose();
      });

      test('rolls back on failure', () async {
        // Arrange
        when(() => mockRepository.markAllAsRead())
            .thenAnswer((_) async => Failure(ServerFailure('Failed')));
        when(() => mockRepository.watchNotifications())
            .thenAnswer((_) => const Stream.empty());

        final notifier = NotificationsNotifier(repository: mockRepository);

        // Set initial loaded state with unread notifications
        notifier.setStateForTesting(NotificationsLoaded(
          notifications: [
            createTestNotification(id: 'notif-1', readAt: null),
            createTestNotification(id: 'notif-2', readAt: null),
          ],
        ));

        // Act
        await notifier.markAllAsRead();

        // Assert - should be rolled back to unread
        final state = notifier.state as NotificationsLoaded;
        expect(state.notifications.every((n) => !n.isRead), true);

        // Cleanup
        notifier.dispose();
      });
    });

    group('watchNotifications', () {
      test('updates state when stream emits new notifications', () async {
        // Arrange
        final controller = StreamController<List<AppNotification>>();

        when(() => mockRepository.watchNotifications())
            .thenAnswer((_) => controller.stream);

        final notifier = NotificationsNotifier(repository: mockRepository);
        notifier.setStateForTesting(NotificationsLoaded(
          notifications: [createTestNotification(id: 'notif-1')],
        ));

        final states = <NotificationsState>[];
        notifier.addListener(() => states.add(notifier.state));

        // Act
        notifier.startWatching();
        controller.add([
          createTestNotification(id: 'notif-1'),
          createTestNotification(id: 'notif-2'),
          createTestNotification(id: 'notif-3'),
        ]);

        // Give time for stream to process
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(states.isNotEmpty, true);
        final lastState = states.last as NotificationsLoaded;
        expect(lastState.notifications.length, 3);

        // Cleanup
        notifier.dispose();
        await controller.close();
      });
    });

    group('unreadCount', () {
      test('should return correct unread count from loaded state', () {
        // Arrange
        when(() => mockRepository.watchNotifications())
            .thenAnswer((_) => const Stream.empty());

        final notifier = NotificationsNotifier(repository: mockRepository);

        // Set loaded state with mixed read/unread
        notifier.setStateForTesting(NotificationsLoaded(
          notifications: [
            createTestNotification(id: 'notif-1', readAt: null), // unread
            createTestNotification(id: 'notif-2', readAt: DateTime.now()), // read
            createTestNotification(id: 'notif-3', readAt: null), // unread
          ],
        ));

        // Assert
        expect(notifier.unreadCount, 2);

        // Cleanup
        notifier.dispose();
      });

      test('should return 0 when no notifications are loaded', () {
        // Arrange
        when(() => mockRepository.watchNotifications())
            .thenAnswer((_) => const Stream.empty());

        final notifier = NotificationsNotifier(repository: mockRepository);

        // Assert - initial state
        expect(notifier.unreadCount, 0);

        // Cleanup
        notifier.dispose();
      });
    });

    group('dispose', () {
      test('should cancel stream subscription on dispose', () async {
        // Arrange
        final controller = StreamController<List<AppNotification>>();
        when(() => mockRepository.watchNotifications())
            .thenAnswer((_) => controller.stream);

        final notifier = NotificationsNotifier(repository: mockRepository);
        notifier.startWatching();

        // Act
        notifier.dispose();

        // Give time for disposal
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert - no error should occur when adding to closed stream listener
        expect(controller.hasListener, false);

        // Cleanup
        await controller.close();
      });
    });
  });
}
