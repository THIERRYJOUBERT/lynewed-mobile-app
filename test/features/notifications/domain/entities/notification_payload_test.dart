import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/notifications/domain/entities/app_notification.dart';
import 'package:lynewed_beta/features/notifications/domain/entities/notification_payload.dart';

void main() {
  // ==============================================================
  // TEST FIXTURES
  // ==============================================================

  const testPayloadMap = {
    'type': 'chatMessage',
    'title': 'New Message',
    'body': 'You have a new message',
    'image_url': 'https://example.com/avatar.png',
    'chat_room_id': 'room-456',
    'sender_id': 'user-789',
    'notification_id': 'notif-123',
  };

  const testVideoCallPayloadMap = {
    'type': 'videoIncoming',
    'title': 'Incoming Call',
    'body': 'John is calling you',
    'session_id': 'session-123',
    'channel_name': 'video-channel-456',
    'caller_id': 'caller-789',
    'caller_name': 'John Doe',
  };

  const testBroadcastPayloadMap = {
    'type': 'wedPublished',
    'title': 'Wedding of the Week',
    'body': 'Check out this amazing wedding!',
    'wedding_id': 'wedding-123',
    'deep_link': 'lynewed://wedding/123',
  };

  // ==============================================================
  // NOTIFICATION PAYLOAD CREATION TESTS
  // ==============================================================

  group('NotificationPayload', () {
    group('creation', () {
      test('should create with required fields', () {
        final payload = NotificationPayload(
          type: NotificationType.chatMessage,
          title: 'New Message',
          body: 'You have a new message',
        );

        expect(payload.type, NotificationType.chatMessage);
        expect(payload.title, 'New Message');
        expect(payload.body, 'You have a new message');
        expect(payload.imageUrl, isNull);
        expect(payload.data, isEmpty);
      });

      test('should create with all fields', () {
        final payload = NotificationPayload(
          type: NotificationType.chatMessage,
          title: 'New Message',
          body: 'You have a new message',
          imageUrl: 'https://example.com/avatar.png',
          data: const {
            'chat_room_id': 'room-456',
            'sender_id': 'user-789',
          },
        );

        expect(payload.imageUrl, 'https://example.com/avatar.png');
        expect(payload.data['chat_room_id'], 'room-456');
        expect(payload.data['sender_id'], 'user-789');
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse chatMessage payload', () {
        final payload = NotificationPayload.fromJson(testPayloadMap);

        expect(payload.type, NotificationType.chatMessage);
        expect(payload.title, 'New Message');
        expect(payload.body, 'You have a new message');
        expect(payload.imageUrl, 'https://example.com/avatar.png');
        expect(payload.data['chat_room_id'], 'room-456');
        expect(payload.data['sender_id'], 'user-789');
        expect(payload.data['notification_id'], 'notif-123');
      });

      test('should parse videoIncoming payload', () {
        final payload = NotificationPayload.fromJson(testVideoCallPayloadMap);

        expect(payload.type, NotificationType.videoIncoming);
        expect(payload.title, 'Incoming Call');
        expect(payload.data['session_id'], 'session-123');
        expect(payload.data['channel_name'], 'video-channel-456');
        expect(payload.data['caller_id'], 'caller-789');
        expect(payload.data['caller_name'], 'John Doe');
      });

      test('should parse broadcast payload with deep_link', () {
        final payload = NotificationPayload.fromJson(testBroadcastPayloadMap);

        expect(payload.type, NotificationType.wedPublished);
        expect(payload.data['wedding_id'], 'wedding-123');
        expect(payload.data['deep_link'], 'lynewed://wedding/123');
      });

      test('should handle minimal payload', () {
        const minimalMap = {
          'type': 'connectionRequest',
          'title': 'Contact Request',
          'body': 'Someone wants to connect',
        };

        final payload = NotificationPayload.fromJson(minimalMap);

        expect(payload.type, NotificationType.connectionRequest);
        expect(payload.title, 'Contact Request');
        expect(payload.imageUrl, isNull);
      });

      test('should handle unknown notification type', () {
        const mapWithUnknownType = {
          'type': 'unknownType',
          'title': 'Title',
          'body': 'Body',
        };

        final payload = NotificationPayload.fromJson(mapWithUnknownType);

        // Should default to chatMessage
        expect(payload.type, NotificationType.chatMessage);
      });

      test('should handle null type', () {
        final mapWithNullType = <String, dynamic>{
          'type': null,
          'title': 'Title',
          'body': 'Body',
        };

        final payload = NotificationPayload.fromJson(mapWithNullType);

        expect(payload.type, NotificationType.chatMessage);
      });

      test('should handle missing fields gracefully', () {
        final emptyMap = <String, dynamic>{};

        final payload = NotificationPayload.fromJson(emptyMap);

        expect(payload.type, NotificationType.chatMessage);
        expect(payload.title, '');
        expect(payload.body, '');
        expect(payload.data, isEmpty);
      });

      test('should extract all extra fields to data', () {
        const mapWithExtraFields = {
          'type': 'chatMessage',
          'title': 'Title',
          'body': 'Body',
          'custom_field_1': 'value1',
          'custom_field_2': 123,
          'nested': {'key': 'value'},
        };

        final payload = NotificationPayload.fromJson(mapWithExtraFields);

        expect(payload.data['custom_field_1'], 'value1');
        expect(payload.data['custom_field_2'], 123);
        expect(payload.data['nested'], {'key': 'value'});
      });
    });

    // ==============================================================
    // TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should serialize with all fields', () {
        final payload = NotificationPayload(
          type: NotificationType.chatMessage,
          title: 'New Message',
          body: 'You have a new message',
          imageUrl: 'https://example.com/avatar.png',
          data: const {'chat_room_id': 'room-456'},
        );

        final json = payload.toJson();

        expect(json['type'], 'chatMessage');
        expect(json['title'], 'New Message');
        expect(json['body'], 'You have a new message');
        expect(json['image_url'], 'https://example.com/avatar.png');
        expect(json['chat_room_id'], 'room-456');
      });

      test('should not include null imageUrl', () {
        final payload = NotificationPayload(
          type: NotificationType.chatMessage,
          title: 'Title',
          body: 'Body',
        );

        final json = payload.toJson();

        expect(json.containsKey('image_url'), false);
      });

      test('should be reversible with fromJson', () {
        final original = NotificationPayload(
          type: NotificationType.connectionRequest,
          title: 'Contact Request',
          body: 'John wants to connect',
          imageUrl: 'https://example.com/avatar.png',
          data: const {'sender_id': 'user-456', 'sender_name': 'John'},
        );

        final json = original.toJson();
        final restored = NotificationPayload.fromJson(json);

        expect(restored.type, original.type);
        expect(restored.title, original.title);
        expect(restored.body, original.body);
        expect(restored.imageUrl, original.imageUrl);
        expect(restored.data['sender_id'], original.data['sender_id']);
        expect(restored.data['sender_name'], original.data['sender_name']);
      });
    });

    // ==============================================================
    // TO APP NOTIFICATION TESTS
    // ==============================================================

    group('toAppNotification', () {
      test('should convert to AppNotification with provided id', () {
        final payload = NotificationPayload(
          type: NotificationType.chatMessage,
          title: 'New Message',
          body: 'You have a new message',
          imageUrl: 'https://example.com/avatar.png',
          data: const {'chat_room_id': 'room-456'},
        );

        final notification = payload.toAppNotification(id: 'notif-123');

        expect(notification.id, 'notif-123');
        expect(notification.type, NotificationType.chatMessage);
        expect(notification.title, 'New Message');
        expect(notification.body, 'You have a new message');
        expect(notification.imageUrl, 'https://example.com/avatar.png');
        expect(notification.data['chat_room_id'], 'room-456');
        expect(notification.isRead, false);
      });

      test('should use notification_id from data if id not provided', () {
        final payload = NotificationPayload(
          type: NotificationType.chatMessage,
          title: 'Title',
          body: 'Body',
          data: const {'notification_id': 'notif-from-data'},
        );

        final notification = payload.toAppNotification();

        expect(notification.id, 'notif-from-data');
      });

      test('should generate UUID-style id if none provided', () {
        final payload = NotificationPayload(
          type: NotificationType.chatMessage,
          title: 'Title',
          body: 'Body',
        );

        final notification = payload.toAppNotification();

        expect(notification.id, isNotEmpty);
        expect(notification.id.length, greaterThan(10));
      });

      test('should set createdAt to now', () {
        final before = DateTime.now();
        final payload = NotificationPayload(
          type: NotificationType.chatMessage,
          title: 'Title',
          body: 'Body',
        );

        final notification = payload.toAppNotification(id: 'notif-123');
        final after = DateTime.now();

        expect(notification.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), true);
        expect(notification.createdAt.isBefore(after.add(const Duration(seconds: 1))), true);
      });

      test('should preserve navigation data', () {
        final payload = NotificationPayload(
          type: NotificationType.videoIncoming,
          title: 'Incoming Call',
          body: 'John is calling',
          data: const {
            'session_id': 'session-123',
            'channel_name': 'channel-456',
          },
        );

        final notification = payload.toAppNotification(id: 'notif-123');
        final nav = notification.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.videoCall);
        expect(nav.params['sessionId'], 'session-123');
        expect(nav.params['channelName'], 'channel-456');
      });
    });

    // ==============================================================
    // NAVIGATION TESTS
    // ==============================================================

    group('navigation', () {
      test('should return navigation for chatMessage', () {
        final payload = NotificationPayload(
          type: NotificationType.chatMessage,
          title: 'Title',
          body: 'Body',
          data: const {'chat_room_id': 'room-456'},
        );

        final nav = payload.navigation;

        expect(nav, isNotNull);
        expect(nav!.route, NotificationRoute.chat);
        expect(nav.params['roomId'], 'room-456');
      });

      test('should return null when data is missing for chatMessage', () {
        final payload = NotificationPayload(
          type: NotificationType.chatMessage,
          title: 'Title',
          body: 'Body',
        );

        final nav = payload.navigation;

        expect(nav, isNull);
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        final payload = NotificationPayload(
          type: NotificationType.chatMessage,
          title: 'New Message',
          body: 'Body',
        );

        final result = payload.toString();

        expect(result, contains('NotificationPayload'));
        expect(result, contains('chatMessage'));
        expect(result, contains('New Message'));
      });
    });
  });
}
