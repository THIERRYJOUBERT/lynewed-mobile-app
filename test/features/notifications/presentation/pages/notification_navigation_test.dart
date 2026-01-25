/// Tests for notification navigation
///
/// Verifies that clicking a notification navigates to the correct screen
/// based on the notification type and data.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/notifications/domain/entities/app_notification.dart';

void main() {
  group('NotificationNavigation', () {
    group('chatMessage', () {
      test('should return chat navigation with roomId', () {
        // Arrange
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.chatMessage,
          title: 'New message',
          body: 'Hello!',
          data: {'chat_room_id': 'room-123'},
          createdAt: DateTime.now(),
        );

        // Act
        final nav = notification.navigation;

        // Assert
        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.chat);
        expect(nav.params['roomId'], 'room-123');
      });

      test('should return null when chat_room_id is missing', () {
        // Arrange
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.chatMessage,
          title: 'New message',
          body: 'Hello!',
          data: const {},
          createdAt: DateTime.now(),
        );

        // Act
        final nav = notification.navigation;

        // Assert
        expect(nav, isNull);
      });
    });

    group('connectionRequest', () {
      test('should return profile navigation with senderId', () {
        // Arrange
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.connectionRequest,
          title: 'Contact request',
          body: 'Someone wants to connect',
          data: {'sender_id': 'user-456'},
          createdAt: DateTime.now(),
        );

        // Act
        final nav = notification.navigation;

        // Assert
        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.profile);
        expect(nav.params['profileId'], 'user-456');
      });
    });

    group('connectionRequestAccepted', () {
      test('should return profile navigation with acceptedBy', () {
        // Arrange
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.connectionRequestAccepted,
          title: 'Request accepted',
          body: 'Your request was accepted',
          data: {'accepted_by': 'user-789'},
          createdAt: DateTime.now(),
        );

        // Act
        final nav = notification.navigation;

        // Assert
        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.profile);
        expect(nav.params['profileId'], 'user-789');
      });
    });

    group('wishlistAdd', () {
      test('should return profile navigation with brideId', () {
        // Arrange
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.wishlistAdd,
          title: 'Added to wishlist',
          body: 'Someone added you',
          data: {'bride_id': 'bride-123'},
          createdAt: DateTime.now(),
        );

        // Act
        final nav = notification.navigation;

        // Assert
        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.profile);
        expect(nav.params['profileId'], 'bride-123');
      });
    });

    group('videoIncoming', () {
      test('should return videoCall navigation with sessionId and channelName', () {
        // Arrange
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.videoIncoming,
          title: 'Incoming call',
          body: 'Video call',
          data: {
            'session_id': 'session-123',
            'channel_name': 'channel-abc',
          },
          createdAt: DateTime.now(),
        );

        // Act
        final nav = notification.navigation;

        // Assert
        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.videoCall);
        expect(nav.params['sessionId'], 'session-123');
        expect(nav.params['channelName'], 'channel-abc');
      });

      test('should return null when session_id is missing', () {
        // Arrange
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.videoIncoming,
          title: 'Incoming call',
          body: 'Video call',
          data: const {},
          createdAt: DateTime.now(),
        );

        // Act
        final nav = notification.navigation;

        // Assert
        expect(nav, isNull);
      });
    });

    group('wedPublished', () {
      test('should return weddingOfTheWeek navigation', () {
        // Arrange
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.wedPublished,
          title: 'Wedding of the Week',
          body: 'Check it out!',
          data: {'wedding_id': 'wedding-123'},
          createdAt: DateTime.now(),
        );

        // Act
        final nav = notification.navigation;

        // Assert
        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.weddingOfTheWeek);
        expect(nav.params['weddingId'], 'wedding-123');
      });
    });

    group('replayPublished', () {
      test('should return replays navigation', () {
        // Arrange
        final notification = AppNotification(
          id: 'notif-1',
          type: NotificationType.replayPublished,
          title: 'New Replay',
          body: 'Watch now',
          data: {'replay_id': 'replay-123'},
          createdAt: DateTime.now(),
        );

        // Act
        final nav = notification.navigation;

        // Assert
        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.replays);
        expect(nav.params['replayId'], 'replay-123');
      });
    });
  });
}
