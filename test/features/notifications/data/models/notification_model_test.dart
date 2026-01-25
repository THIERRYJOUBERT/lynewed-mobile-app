import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/notifications/data/models/notification_model.dart';
import 'package:lynewed_beta/features/notifications/domain/entities/app_notification.dart';

void main() {
  // ==============================================================
  // FROM JSON TESTS
  // ==============================================================

  group('NotificationModel.fromJson', () {
    test('should parse RPC format with notificationId and notificationType', () {
      // Arrange - RPC response format from get_formatted_notifications
      final json = {
        'notificationId': 'notif-123',
        'notificationType': 'chatMessage',
        'title': 'New Message',
        'message': 'You have a new message',
        'createdAt': '2024-01-15T10:30:00.000Z',
        'isRead': false,
        'referenceId': 'room-456',
        'senderAvatarUrl': 'https://example.com/avatar.jpg',
      };

      // Act
      final model = NotificationModel.fromJson(json);

      // Assert
      expect(model.id, 'notif-123');
      expect(model.type, 'chatMessage');
      expect(model.title, 'New Message');
      expect(model.body, 'You have a new message');
      expect(model.imageUrl, 'https://example.com/avatar.jpg');
      expect(model.data['chat_room_id'], 'room-456');
      expect(model.createdAt, DateTime.utc(2024, 1, 15, 10, 30));
      expect(model.readAt, isNull);
    });

    test('should parse standard format with id and type', () {
      // Arrange - Standard JSON format
      final json = {
        'id': 'notif-789',
        'type': 'connectionRequest',
        'title': 'Connection Request',
        'body': 'Someone wants to connect',
        'image_url': 'https://example.com/image.jpg',
        'data': {'sender_id': 'user-123'},
        'created_at': '2024-01-15T09:00:00.000Z',
        'read_at': '2024-01-15T09:30:00.000Z',
      };

      // Act
      final model = NotificationModel.fromJson(json);

      // Assert
      expect(model.id, 'notif-789');
      expect(model.type, 'connectionRequest');
      expect(model.title, 'Connection Request');
      expect(model.body, 'Someone wants to connect');
      expect(model.imageUrl, 'https://example.com/image.jpg');
      expect(model.data['sender_id'], 'user-123');
      expect(model.readAt, DateTime.utc(2024, 1, 15, 9, 30));
    });

    test('should handle isRead true without read_at timestamp', () {
      // Arrange
      final json = {
        'notificationId': 'notif-1',
        'notificationType': 'chatMessage',
        'title': 'Test',
        'message': 'Test message',
        'createdAt': '2024-01-15T10:00:00.000Z',
        'isRead': true,
      };

      // Act
      final model = NotificationModel.fromJson(json);

      // Assert
      expect(model.readAt, isNotNull);
      expect(model.readAt, model.createdAt); // Uses createdAt as fallback
    });

    test('should parse all notification types for referenceId mapping', () {
      // Test each notification type maps referenceId to correct key
      final testCases = [
        ('chatMessage', 'chat_room_id'),
        ('connectionRequest', 'sender_id'),
        ('connectionRequestAccepted', 'accepted_by'),
        ('wishlistAdd', 'bride_id'),
        ('videoIncoming', 'session_id'),
        ('wedPublished', 'wedding_id'),
        ('replayPublished', 'replay_id'),
        ('unknownType', 'reference_id'),
      ];

      for (final (notificationType, expectedKey) in testCases) {
        final json = {
          'notificationId': 'notif-1',
          'notificationType': notificationType,
          'title': 'Test',
          'message': 'Test',
          'createdAt': '2024-01-15T10:00:00.000Z',
          'referenceId': 'ref-123',
        };

        final model = NotificationModel.fromJson(json);

        expect(
          model.data.containsKey(expectedKey),
          isTrue,
          reason: '$notificationType should map to $expectedKey',
        );
        expect(model.data[expectedKey], 'ref-123');
      }
    });

    test('should handle missing fields with defaults', () {
      // Arrange - Minimal JSON
      final json = <String, dynamic>{};

      // Act
      final model = NotificationModel.fromJson(json);

      // Assert
      expect(model.id, '');
      expect(model.type, 'chatMessage');
      expect(model.title, 'Notification');
      expect(model.body, '');
      expect(model.imageUrl, isNull);
      expect(model.data, isEmpty);
      expect(model.readAt, isNull);
    });

    test('should merge data field with referenceId', () {
      // Arrange
      final json = {
        'notificationId': 'notif-1',
        'notificationType': 'chatMessage',
        'title': 'Test',
        'message': 'Test',
        'createdAt': '2024-01-15T10:00:00.000Z',
        'referenceId': 'room-123',
        'data': {'extra_field': 'extra_value'},
      };

      // Act
      final model = NotificationModel.fromJson(json);

      // Assert
      expect(model.data['chat_room_id'], 'room-123');
      expect(model.data['extra_field'], 'extra_value');
    });
  });

  // ==============================================================
  // TO JSON TESTS
  // ==============================================================

  group('NotificationModel.toJson', () {
    test('should serialize all fields correctly', () {
      // Arrange
      final model = NotificationModel(
        id: 'notif-1',
        type: 'chatMessage',
        title: 'Test Title',
        body: 'Test body',
        imageUrl: 'https://example.com/image.jpg',
        data: {'key': 'value'},
        createdAt: DateTime.utc(2024, 1, 15, 10, 30),
        readAt: DateTime.utc(2024, 1, 15, 11, 0),
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], 'notif-1');
      expect(json['type'], 'chatMessage');
      expect(json['title'], 'Test Title');
      expect(json['body'], 'Test body');
      expect(json['image_url'], 'https://example.com/image.jpg');
      expect(json['data'], {'key': 'value'});
      expect(json['created_at'], '2024-01-15T10:30:00.000Z');
      expect(json['read_at'], '2024-01-15T11:00:00.000Z');
    });

    test('should not include null optional fields', () {
      // Arrange
      final model = NotificationModel(
        id: 'notif-1',
        type: 'chatMessage',
        title: 'Test',
        body: 'Test',
        data: {},
        createdAt: DateTime.utc(2024, 1, 15, 10, 30),
        imageUrl: null,
        readAt: null,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json.containsKey('image_url'), isFalse);
      expect(json.containsKey('read_at'), isFalse);
    });
  });

  // ==============================================================
  // TO ENTITY TESTS
  // ==============================================================

  group('NotificationModel.toEntity', () {
    test('should convert to AppNotification entity', () {
      // Arrange
      final model = NotificationModel(
        id: 'notif-1',
        type: 'chatMessage',
        title: 'New Message',
        body: 'You have a new message',
        imageUrl: 'https://example.com/avatar.jpg',
        data: {'chat_room_id': 'room-123'},
        createdAt: DateTime.utc(2024, 1, 15, 10, 30),
        readAt: null,
      );

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity, isA<AppNotification>());
      expect(entity.id, 'notif-1');
      expect(entity.type, NotificationType.chatMessage);
      expect(entity.title, 'New Message');
      expect(entity.body, 'You have a new message');
      expect(entity.imageUrl, 'https://example.com/avatar.jpg');
      expect(entity.data['chat_room_id'], 'room-123');
      expect(entity.isRead, isFalse);
    });

    test('should parse all NotificationType values', () {
      // Test all supported notification types
      final types = [
        ('chatMessage', NotificationType.chatMessage),
        ('connectionRequest', NotificationType.connectionRequest),
        ('connectionRequestAccepted', NotificationType.connectionRequestAccepted),
        ('wishlistAdd', NotificationType.wishlistAdd),
        ('videoIncoming', NotificationType.videoIncoming),
        ('wedPublished', NotificationType.wedPublished),
        ('replayPublished', NotificationType.replayPublished),
      ];

      for (final (typeString, expectedType) in types) {
        final model = NotificationModel(
          id: 'notif-1',
          type: typeString,
          title: 'Test',
          body: 'Test',
          data: {},
          createdAt: DateTime.now(),
        );

        final entity = model.toEntity();

        expect(
          entity.type,
          expectedType,
          reason: '$typeString should map to $expectedType',
        );
      }
    });

    test('should use chatMessage as fallback for unknown types', () {
      // Arrange
      final model = NotificationModel(
        id: 'notif-1',
        type: 'unknownType',
        title: 'Test',
        body: 'Test',
        data: {},
        createdAt: DateTime.now(),
      );

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.type, NotificationType.chatMessage);
    });

    test('should handle case insensitive type parsing', () {
      // Arrange
      final model = NotificationModel(
        id: 'notif-1',
        type: 'CHATMESSAGE',
        title: 'Test',
        body: 'Test',
        data: {},
        createdAt: DateTime.now(),
      );

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.type, NotificationType.chatMessage);
    });
  });

  // ==============================================================
  // TOSTRING TEST
  // ==============================================================

  group('NotificationModel.toString', () {
    test('should return formatted string', () {
      // Arrange
      final model = NotificationModel(
        id: 'notif-1',
        type: 'chatMessage',
        title: 'Test Title',
        body: 'Test',
        data: {},
        createdAt: DateTime.now(),
        readAt: null,
      );

      // Act
      final result = model.toString();

      // Assert
      expect(result, contains('notif-1'));
      expect(result, contains('chatMessage'));
      expect(result, contains('Test Title'));
      expect(result, contains('read: false'));
    });
  });
}
