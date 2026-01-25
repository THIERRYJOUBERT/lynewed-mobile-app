/// Tests for NotificationTile widget
///
/// Verifies the tile displays notification information correctly
/// and handles user interactions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/notifications/domain/entities/app_notification.dart';
import 'package:lynewed_beta/features/notifications/presentation/widgets/notification_tile.dart';

void main() {
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

  Widget buildTestWidget({
    required AppNotification notification,
    VoidCallback? onTap,
    VoidCallback? onMarkAsRead,
    VoidCallback? onDismiss,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: NotificationTile(
          notification: notification,
          onTap: onTap ?? () {},
          onMarkAsRead: onMarkAsRead,
          onDismiss: onDismiss,
        ),
      ),
    );
  }

  group('NotificationTile', () {
    testWidgets('should display notification title and body', (tester) async {
      // Arrange
      final notification = createTestNotification(
        title: 'New Message',
        body: 'Hello, this is a test message.',
      );

      // Act
      await tester.pumpWidget(buildTestWidget(notification: notification));

      // Assert
      expect(find.text('New Message'), findsOneWidget);
      expect(find.text('Hello, this is a test message.'), findsOneWidget);
    });

    testWidgets('should display correct icon for chat message type', (tester) async {
      // Arrange
      final notification = createTestNotification(
        type: NotificationType.chatMessage,
      );

      // Act
      await tester.pumpWidget(buildTestWidget(notification: notification));

      // Assert
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('should display correct icon for connection request type', (tester) async {
      // Arrange
      final notification = createTestNotification(
        type: NotificationType.connectionRequest,
      );

      // Act
      await tester.pumpWidget(buildTestWidget(notification: notification));

      // Assert
      expect(find.byIcon(Icons.person_add_outlined), findsOneWidget);
    });

    testWidgets('should show "New" badge for unread notifications', (tester) async {
      // Arrange
      final notification = createTestNotification(readAt: null);

      // Act
      await tester.pumpWidget(buildTestWidget(notification: notification));

      // Assert
      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('should show "Read" badge for read notifications', (tester) async {
      // Arrange
      final notification = createTestNotification(readAt: DateTime.now());

      // Act
      await tester.pumpWidget(buildTestWidget(notification: notification));

      // Assert
      expect(find.text('Read'), findsOneWidget);
    });

    testWidgets('should call onTap when tile is tapped', (tester) async {
      // Arrange
      var tapped = false;
      final notification = createTestNotification();

      // Act
      await tester.pumpWidget(buildTestWidget(
        notification: notification,
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(NotificationTile));

      // Assert
      expect(tapped, true);
    });

    testWidgets('should call onMarkAsRead when "New" badge is tapped', (tester) async {
      // Arrange
      var markedAsRead = false;
      final notification = createTestNotification(readAt: null);

      // Act
      await tester.pumpWidget(buildTestWidget(
        notification: notification,
        onMarkAsRead: () => markedAsRead = true,
      ));

      // Tap on the "New" badge
      await tester.tap(find.text('New'));
      await tester.pump();

      // Assert
      expect(markedAsRead, true);
    });

    testWidgets('should display relative time for recent notifications', (tester) async {
      // Arrange - notification created 5 minutes ago
      final notification = createTestNotification(
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      // Act
      await tester.pumpWidget(buildTestWidget(notification: notification));

      // Assert - should show minutes ago
      expect(find.textContaining('m ago'), findsOneWidget);
    });

    testWidgets('should display default title when title is empty', (tester) async {
      // Arrange
      final notification = AppNotification(
        id: 'notif-1',
        type: NotificationType.chatMessage,
        title: '', // Empty title
        body: 'Test body',
        data: const {},
        createdAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(buildTestWidget(notification: notification));

      // Assert - should show default title based on type
      expect(find.text('New message'), findsOneWidget);
    });
  });
}
