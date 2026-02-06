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

    // ==========================================================
    // MARKETPLACE NOTIFICATION ICONS
    // ==========================================================

    group('marketplace icons', () {
      testWidgets('should display correct icon for marketplaceNewOffer',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceNewOffer,
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.byIcon(Icons.local_offer_outlined), findsOneWidget);
      });

      testWidgets('should display correct icon for marketplaceOfferAccepted',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceOfferAccepted,
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.byIcon(Icons.thumb_up_outlined), findsOneWidget);
      });

      testWidgets('should display correct icon for marketplaceOfferRejected',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceOfferRejected,
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.byIcon(Icons.thumb_down_outlined), findsOneWidget);
      });

      testWidgets('should display correct icon for marketplaceItemSold',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceItemSold,
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.byIcon(Icons.sell_outlined), findsOneWidget);
      });

      testWidgets('should display correct icon for marketplaceOrderConfirmed',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceOrderConfirmed,
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      });

      testWidgets('should display correct icon for marketplaceOfferWithdrawn',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceOfferWithdrawn,
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.byIcon(Icons.undo_outlined), findsOneWidget);
      });

      testWidgets('should display correct icon for marketplaceOfferExpired',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceOfferExpired,
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.byIcon(Icons.timer_off_outlined), findsOneWidget);
      });

      testWidgets('should display correct icon for marketplacePaymentSucceeded',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplacePaymentSucceeded,
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
      });

      testWidgets('should display correct icon for marketplaceLabelReady',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceLabelReady,
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.byIcon(Icons.label_outlined), findsOneWidget);
      });

      testWidgets('should display correct icon for marketplaceTrackingUpdate',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceTrackingUpdate,
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
      });

      testWidgets(
          'should display correct icon for marketplaceTransactionComplete',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceTransactionComplete,
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      });
    });

    // ==========================================================
    // MARKETPLACE DEFAULT TITLES
    // ==========================================================

    group('marketplace default titles', () {
      testWidgets('should display "New offer received" for marketplaceNewOffer',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceNewOffer,
          title: '',
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.text('New offer received'), findsOneWidget);
      });

      testWidgets(
          'should display "Offer accepted" for marketplaceOfferAccepted',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceOfferAccepted,
          title: '',
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.text('Offer accepted'), findsOneWidget);
      });

      testWidgets(
          'should display "Offer declined" for marketplaceOfferRejected',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceOfferRejected,
          title: '',
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.text('Offer declined'), findsOneWidget);
      });

      testWidgets('should display "Item sold" for marketplaceItemSold',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceItemSold,
          title: '',
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.text('Item sold'), findsOneWidget);
      });

      testWidgets(
          'should display "Order confirmed" for marketplaceOrderConfirmed',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceOrderConfirmed,
          title: '',
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.text('Order confirmed'), findsOneWidget);
      });

      testWidgets(
          'should display "Offer withdrawn" for marketplaceOfferWithdrawn',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceOfferWithdrawn,
          title: '',
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.text('Offer withdrawn'), findsOneWidget);
      });

      testWidgets(
          'should display "Offer expired" for marketplaceOfferExpired',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceOfferExpired,
          title: '',
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.text('Offer expired'), findsOneWidget);
      });

      testWidgets(
          'should display "Payment received" for marketplacePaymentSucceeded',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplacePaymentSucceeded,
          title: '',
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.text('Payment received'), findsOneWidget);
      });

      testWidgets(
          'should display "Shipping label ready" for marketplaceLabelReady',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceLabelReady,
          title: '',
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.text('Shipping label ready'), findsOneWidget);
      });

      testWidgets(
          'should display "Shipping update" for marketplaceTrackingUpdate',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceTrackingUpdate,
          title: '',
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.text('Shipping update'), findsOneWidget);
      });

      testWidgets(
          'should display "Transaction complete" for marketplaceTransactionComplete',
          (tester) async {
        final notification = createTestNotification(
          type: NotificationType.marketplaceTransactionComplete,
          title: '',
        );
        await tester.pumpWidget(buildTestWidget(notification: notification));
        expect(find.text('Transaction complete'), findsOneWidget);
      });
    });
  });
}
