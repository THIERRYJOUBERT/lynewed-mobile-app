/// Tests for NotificationsPage
///
/// Verifies the page uses Clean Architecture with NotificationsNotifier
/// and displays notifications correctly.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/notifications/domain/entities/app_notification.dart';
import 'package:lynewed_beta/features/notifications/domain/repositories/notification_repository.dart';
import 'package:lynewed_beta/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:lynewed_beta/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:lynewed_beta/features/notifications/presentation/pages/notifications_page.dart';
import 'package:lynewed_beta/features/notifications/presentation/widgets/notification_tile.dart';

// Mock repository
class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepository;

  setUpAll(() {
    registerFallbackValue('test-id');
  });

  setUp(() {
    mockRepository = MockNotificationRepository();
  });

  // Helper to create test notifications
  AppNotification createTestNotification({
    String id = 'notif-1',
    NotificationType type = NotificationType.chatMessage,
    String title = 'Test Title',
    String body = 'Test body message',
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

  // Helper to build widget with provider
  Widget buildTestWidget({
    required NotificationsNotifier notifier,
  }) {
    return MaterialApp(
      home: ChangeNotifierProvider<NotificationsNotifier>.value(
        value: notifier,
        child: const NotificationsPage(),
      ),
    );
  }

  group('NotificationsPage', () {
    testWidgets('should display loading indicator when loading', (tester) async {
      // Arrange
      when(() => mockRepository.watchNotifications())
          .thenAnswer((_) => const Stream.empty());

      final notifier = NotificationsNotifier(repository: mockRepository);
      notifier.setStateForTesting(const NotificationsLoading());

      // Act
      await tester.pumpWidget(buildTestWidget(notifier: notifier));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Cleanup
      notifier.dispose();
    });

    testWidgets('should display notifications list when loaded', (tester) async {
      // Arrange
      when(() => mockRepository.watchNotifications())
          .thenAnswer((_) => const Stream.empty());

      final notifier = NotificationsNotifier(repository: mockRepository);
      notifier.setStateForTesting(NotificationsLoaded(
        notifications: [
          createTestNotification(id: 'notif-1', title: 'First Notification'),
          createTestNotification(id: 'notif-2', title: 'Second Notification'),
        ],
      ));

      // Act
      await tester.pumpWidget(buildTestWidget(notifier: notifier));

      // Assert
      expect(find.text('First Notification'), findsOneWidget);
      expect(find.text('Second Notification'), findsOneWidget);
      expect(find.byType(NotificationTile), findsNWidgets(2));

      // Cleanup
      notifier.dispose();
    });

    testWidgets('should display empty state when no notifications', (tester) async {
      // Arrange
      when(() => mockRepository.watchNotifications())
          .thenAnswer((_) => const Stream.empty());

      final notifier = NotificationsNotifier(repository: mockRepository);
      notifier.setStateForTesting(const NotificationsLoaded(notifications: []));

      // Act
      await tester.pumpWidget(buildTestWidget(notifier: notifier));

      // Assert
      expect(find.text('No notifications yet.'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);

      // Cleanup
      notifier.dispose();
    });

    testWidgets('should display error state when error occurs', (tester) async {
      // Arrange
      when(() => mockRepository.watchNotifications())
          .thenAnswer((_) => const Stream.empty());

      final notifier = NotificationsNotifier(repository: mockRepository);
      notifier.setStateForTesting(const NotificationsError('Failed to load'));

      // Act
      await tester.pumpWidget(buildTestWidget(notifier: notifier));

      // Assert
      expect(find.text('Failed to load notifications'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Cleanup
      notifier.dispose();
    });

    testWidgets('should show "Mark read" button when there are unread notifications', (tester) async {
      // Arrange
      when(() => mockRepository.watchNotifications())
          .thenAnswer((_) => const Stream.empty());

      final notifier = NotificationsNotifier(repository: mockRepository);
      notifier.setStateForTesting(NotificationsLoaded(
        notifications: [
          createTestNotification(id: 'notif-1', readAt: null), // unread
        ],
      ));

      // Act
      await tester.pumpWidget(buildTestWidget(notifier: notifier));

      // Assert
      expect(find.text('Mark read'), findsOneWidget);

      // Cleanup
      notifier.dispose();
    });

    testWidgets('should hide "Mark read" button when all notifications are read', (tester) async {
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
      await tester.pumpWidget(buildTestWidget(notifier: notifier));

      // Assert
      expect(find.text('Mark read'), findsNothing);

      // Cleanup
      notifier.dispose();
    });

    testWidgets('should call markAllAsRead when "Mark read" is tapped', (tester) async {
      // Arrange
      when(() => mockRepository.watchNotifications())
          .thenAnswer((_) => const Stream.empty());
      when(() => mockRepository.markAllAsRead())
          .thenAnswer((_) async => const Success(null));

      final notifier = NotificationsNotifier(repository: mockRepository);
      notifier.setStateForTesting(NotificationsLoaded(
        notifications: [
          createTestNotification(id: 'notif-1', readAt: null),
        ],
      ));

      // Act
      await tester.pumpWidget(buildTestWidget(notifier: notifier));
      await tester.tap(find.text('Mark read'));
      await tester.pump();

      // Assert
      verify(() => mockRepository.markAllAsRead()).called(1);

      // Cleanup
      notifier.dispose();
    });

    testWidgets('should display NOTIFICATIONS header', (tester) async {
      // Arrange
      when(() => mockRepository.watchNotifications())
          .thenAnswer((_) => const Stream.empty());

      final notifier = NotificationsNotifier(repository: mockRepository);
      notifier.setStateForTesting(const NotificationsLoaded(notifications: []));

      // Act
      await tester.pumpWidget(buildTestWidget(notifier: notifier));

      // Assert
      expect(find.text('NOTIFICATIONS'), findsOneWidget);

      // Cleanup
      notifier.dispose();
    });

    testWidgets('should have back button in header', (tester) async {
      // Arrange
      when(() => mockRepository.watchNotifications())
          .thenAnswer((_) => const Stream.empty());

      final notifier = NotificationsNotifier(repository: mockRepository);
      notifier.setStateForTesting(const NotificationsLoaded(notifications: []));

      // Act
      await tester.pumpWidget(buildTestWidget(notifier: notifier));

      // Assert - verify back button exists
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);

      // Cleanup
      notifier.dispose();
    });
  });
}
