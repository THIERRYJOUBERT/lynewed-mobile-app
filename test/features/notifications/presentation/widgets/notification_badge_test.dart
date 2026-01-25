/// Tests for NotificationBadge widget
///
/// Verifies the badge displays correct count and updates in real-time
/// when the unread count changes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lynewed_beta/features/notifications/domain/entities/app_notification.dart';
import 'package:lynewed_beta/features/notifications/domain/repositories/notification_repository.dart';
import 'package:lynewed_beta/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:lynewed_beta/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:lynewed_beta/features/notifications/presentation/widgets/notification_badge.dart';

// Mock repository
class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
  });

  // Helper to create test notifications
  AppNotification createTestNotification({
    String id = 'notif-1',
    NotificationType type = NotificationType.chatMessage,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id,
      type: type,
      title: 'Test',
      body: 'Test body',
      data: const {},
      createdAt: DateTime.now(),
      readAt: readAt,
    );
  }

  // Helper to build widget with provider
  Widget buildTestWidget({
    required NotificationsNotifier notifier,
    required Widget child,
  }) {
    return MaterialApp(
      home: ChangeNotifierProvider<NotificationsNotifier>.value(
        value: notifier,
        child: child,
      ),
    );
  }

  group('NotificationBadge', () {
    testWidgets('should display count when there are unread notifications', (tester) async {
      // Arrange
      when(() => mockRepository.watchNotifications())
          .thenAnswer((_) => const Stream.empty());

      final notifier = NotificationsNotifier(repository: mockRepository);
      notifier.setStateForTesting(NotificationsLoaded(
        notifications: [
          createTestNotification(id: 'notif-1', readAt: null), // unread
          createTestNotification(id: 'notif-2', readAt: null), // unread
          createTestNotification(id: 'notif-3', readAt: DateTime.now()), // read
        ],
      ));

      // Act
      await tester.pumpWidget(buildTestWidget(
        notifier: notifier,
        child: const Scaffold(
          body: NotificationBadge(
            child: Icon(Icons.notifications),
          ),
        ),
      ));

      // Assert
      expect(find.text('2'), findsOneWidget);

      // Cleanup
      notifier.dispose();
    });

    testWidgets('should hide badge when count is 0', (tester) async {
      // Arrange
      when(() => mockRepository.watchNotifications())
          .thenAnswer((_) => const Stream.empty());

      final notifier = NotificationsNotifier(repository: mockRepository);
      notifier.setStateForTesting(NotificationsLoaded(
        notifications: [
          createTestNotification(id: 'notif-1', readAt: DateTime.now()), // read
        ],
      ));

      // Act
      await tester.pumpWidget(buildTestWidget(
        notifier: notifier,
        child: const Scaffold(
          body: NotificationBadge(
            child: Icon(Icons.notifications),
          ),
        ),
      ));

      // Assert - Badge should not show count when 0
      expect(find.byType(Badge), findsOneWidget);
      // The badge label should not be visible when count is 0
      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, false);

      // Cleanup
      notifier.dispose();
    });

    testWidgets('should display 99+ when count exceeds 99', (tester) async {
      // Arrange
      when(() => mockRepository.watchNotifications())
          .thenAnswer((_) => const Stream.empty());

      final notifier = NotificationsNotifier(repository: mockRepository);

      // Create 100 unread notifications
      final notifications = List.generate(
        100,
        (i) => createTestNotification(id: 'notif-$i', readAt: null),
      );

      notifier.setStateForTesting(NotificationsLoaded(
        notifications: notifications,
      ));

      // Act
      await tester.pumpWidget(buildTestWidget(
        notifier: notifier,
        child: const Scaffold(
          body: NotificationBadge(
            child: Icon(Icons.notifications),
          ),
        ),
      ));

      // Assert
      expect(find.text('99+'), findsOneWidget);

      // Cleanup
      notifier.dispose();
    });

    testWidgets('should update when unread count changes', (tester) async {
      // Arrange
      when(() => mockRepository.watchNotifications())
          .thenAnswer((_) => const Stream.empty());

      final notifier = NotificationsNotifier(repository: mockRepository);
      notifier.setStateForTesting(NotificationsLoaded(
        notifications: [
          createTestNotification(id: 'notif-1', readAt: null),
          createTestNotification(id: 'notif-2', readAt: null),
        ],
      ));

      // Act - initial render
      await tester.pumpWidget(buildTestWidget(
        notifier: notifier,
        child: const Scaffold(
          body: NotificationBadge(
            child: Icon(Icons.notifications),
          ),
        ),
      ));

      expect(find.text('2'), findsOneWidget);

      // Update state to 5 unread
      notifier.setStateForTesting(NotificationsLoaded(
        notifications: [
          createTestNotification(id: 'notif-1', readAt: null),
          createTestNotification(id: 'notif-2', readAt: null),
          createTestNotification(id: 'notif-3', readAt: null),
          createTestNotification(id: 'notif-4', readAt: null),
          createTestNotification(id: 'notif-5', readAt: null),
        ],
      ));
      notifier.notifyListeners();
      await tester.pump();

      // Assert - count should update
      expect(find.text('5'), findsOneWidget);

      // Cleanup
      notifier.dispose();
    });

    testWidgets('should render child widget', (tester) async {
      // Arrange
      when(() => mockRepository.watchNotifications())
          .thenAnswer((_) => const Stream.empty());

      final notifier = NotificationsNotifier(repository: mockRepository);
      notifier.setStateForTesting(const NotificationsLoaded(notifications: []));

      // Act
      await tester.pumpWidget(buildTestWidget(
        notifier: notifier,
        child: const Scaffold(
          body: NotificationBadge(
            child: Icon(Icons.notifications, key: Key('test-icon')),
          ),
        ),
      ));

      // Assert - child should be rendered
      expect(find.byKey(const Key('test-icon')), findsOneWidget);

      // Cleanup
      notifier.dispose();
    });

    testWidgets('should handle initial state (not loaded)', (tester) async {
      // Arrange
      when(() => mockRepository.watchNotifications())
          .thenAnswer((_) => const Stream.empty());

      final notifier = NotificationsNotifier(repository: mockRepository);
      // Leave in initial state (not loaded)

      // Act
      await tester.pumpWidget(buildTestWidget(
        notifier: notifier,
        child: const Scaffold(
          body: NotificationBadge(
            child: Icon(Icons.notifications),
          ),
        ),
      ));

      // Assert - badge should not be visible
      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, false);

      // Cleanup
      notifier.dispose();
    });
  });
}
