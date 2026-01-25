import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/chat/domain/entities/chat_message.dart';
import 'package:lynewed_beta/features/chat/domain/entities/chat_enums.dart';

void main() {
  group('ChatMessage', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create ChatMessage with required fields', () {
        final now = DateTime.now();
        final message = ChatMessage(
          id: 1,
          roomId: 'room-123',
          profileId: 'user-456',
          messageType: MessageType.text,
          createdAt: now,
        );

        expect(message.id, 1);
        expect(message.roomId, 'room-123');
        expect(message.profileId, 'user-456');
        expect(message.messageType, MessageType.text);
        expect(message.createdAt, now);
        expect(message.isDeleted, false);
      });

      test('should create ChatMessage with all optional fields', () {
        final now = DateTime.now();
        final message = ChatMessage(
          id: 2,
          roomId: 'room-789',
          profileId: 'user-abc',
          messageType: MessageType.document,
          createdAt: now,
          content: 'Test content',
          attachmentUrl: 'https://example.com/doc.pdf',
          attachmentName: 'document.pdf',
          attachmentSize: 1024,
          attachmentMimeType: 'application/pdf',
          isDeleted: true,
        );

        expect(message.content, 'Test content');
        expect(message.attachmentUrl, 'https://example.com/doc.pdf');
        expect(message.attachmentName, 'document.pdf');
        expect(message.attachmentSize, 1024);
        expect(message.attachmentMimeType, 'application/pdf');
        expect(message.isDeleted, true);
      });
    });

    // ==============================================================
    // FROMMAP TESTS
    // ==============================================================

    group('fromMap', () {
      test('should parse text message correctly', () {
        final map = {
          'id': 1,
          'room_id': 'room-123',
          'profile_id': 'user-456',
          'content': 'Hello World!',
          'message_type': 'text',
          'attachment_url': null,
          'attachment_name': null,
          'attachment_size': null,
          'attachment_mime_type': null,
          'is_deleted': false,
          'created_at': '2025-01-24T10:00:00Z',
        };

        final message = ChatMessage.fromMap(map);

        expect(message.id, 1);
        expect(message.roomId, 'room-123');
        expect(message.profileId, 'user-456');
        expect(message.content, 'Hello World!');
        expect(message.messageType, MessageType.text);
        expect(message.isDeleted, false);
        expect(message.createdAt.year, 2025);
        expect(message.createdAt.month, 1);
        expect(message.createdAt.day, 24);
      });

      test('should parse image message correctly', () {
        final map = {
          'id': 2,
          'room_id': 'room-123',
          'profile_id': 'user-456',
          'content': null,
          'message_type': 'image',
          'attachment_url': 'https://example.com/image.jpg',
          'is_deleted': false,
          'created_at': '2025-01-24T10:00:00Z',
        };

        final message = ChatMessage.fromMap(map);

        expect(message.messageType, MessageType.image);
        expect(message.attachmentUrl, 'https://example.com/image.jpg');
        expect(message.content, isNull);
      });

      test('should parse audio message correctly', () {
        final map = {
          'id': 3,
          'room_id': 'room-123',
          'profile_id': 'user-456',
          'message_type': 'audio',
          'attachment_url': 'https://example.com/audio.m4a',
          'is_deleted': false,
          'created_at': '2025-01-24T10:00:00Z',
        };

        final message = ChatMessage.fromMap(map);

        expect(message.messageType, MessageType.audio);
        expect(message.attachmentUrl, 'https://example.com/audio.m4a');
      });

      test('should parse document message correctly', () {
        final map = {
          'id': 4,
          'room_id': 'room-123',
          'profile_id': 'user-456',
          'message_type': 'document',
          'attachment_url': 'https://example.com/doc.pdf',
          'attachment_name': 'contract.pdf',
          'attachment_size': 2048,
          'attachment_mime_type': 'application/pdf',
          'is_deleted': false,
          'created_at': '2025-01-24T10:00:00Z',
        };

        final message = ChatMessage.fromMap(map);

        expect(message.messageType, MessageType.document);
        expect(message.attachmentUrl, 'https://example.com/doc.pdf');
        expect(message.attachmentName, 'contract.pdf');
        expect(message.attachmentSize, 2048);
        expect(message.attachmentMimeType, 'application/pdf');
      });

      test('should default to text type for null message_type', () {
        final map = {
          'id': 5,
          'room_id': 'room-123',
          'profile_id': 'user-456',
          'message_type': null,
          'is_deleted': false,
          'created_at': '2025-01-24T10:00:00Z',
        };

        final message = ChatMessage.fromMap(map);

        expect(message.messageType, MessageType.text);
      });

      test('should default to false for null is_deleted', () {
        final map = {
          'id': 6,
          'room_id': 'room-123',
          'profile_id': 'user-456',
          'message_type': 'text',
          'is_deleted': null,
          'created_at': '2025-01-24T10:00:00Z',
        };

        final message = ChatMessage.fromMap(map);

        expect(message.isDeleted, false);
      });

      test('should default to empty string for null profile_id', () {
        final map = {
          'id': 7,
          'room_id': 'room-123',
          'profile_id': null,
          'message_type': 'text',
          'is_deleted': false,
          'created_at': '2025-01-24T10:00:00Z',
        };

        final message = ChatMessage.fromMap(map);

        expect(message.profileId, '');
      });
    });

    // ==============================================================
    // TOINSERTMAP TESTS
    // ==============================================================

    group('toInsertMap', () {
      test('should serialize text message correctly', () {
        final now = DateTime.now();
        final message = ChatMessage(
          id: 1,
          roomId: 'room-123',
          profileId: 'user-456',
          messageType: MessageType.text,
          createdAt: now,
          content: 'Hello World!',
        );

        final map = message.toInsertMap();

        expect(map['room_id'], 'room-123');
        expect(map['profile_id'], 'user-456');
        expect(map['content'], 'Hello World!');
        expect(map['message_type'], 'text');
        expect(map['attachment_url'], isNull);
        expect(map['attachment_name'], isNull);
        expect(map['attachment_size'], isNull);
        expect(map['attachment_mime_type'], isNull);
        // id and created_at are not included (auto-generated by DB)
        expect(map.containsKey('id'), false);
        expect(map.containsKey('created_at'), false);
        expect(map.containsKey('is_deleted'), false);
      });

      test('should serialize image message correctly', () {
        final now = DateTime.now();
        final message = ChatMessage(
          id: 2,
          roomId: 'room-123',
          profileId: 'user-456',
          messageType: MessageType.image,
          createdAt: now,
          attachmentUrl: 'https://example.com/image.jpg',
        );

        final map = message.toInsertMap();

        expect(map['message_type'], 'image');
        expect(map['attachment_url'], 'https://example.com/image.jpg');
        expect(map['content'], isNull);
      });

      test('should serialize document message with all attachment fields', () {
        final now = DateTime.now();
        final message = ChatMessage(
          id: 3,
          roomId: 'room-123',
          profileId: 'user-456',
          messageType: MessageType.document,
          createdAt: now,
          attachmentUrl: 'https://example.com/doc.pdf',
          attachmentName: 'contract.pdf',
          attachmentSize: 2048,
          attachmentMimeType: 'application/pdf',
        );

        final map = message.toInsertMap();

        expect(map['message_type'], 'document');
        expect(map['attachment_url'], 'https://example.com/doc.pdf');
        expect(map['attachment_name'], 'contract.pdf');
        expect(map['attachment_size'], 2048);
        expect(map['attachment_mime_type'], 'application/pdf');
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final now = DateTime.now();
        final original = ChatMessage(
          id: 1,
          roomId: 'room-123',
          profileId: 'user-456',
          messageType: MessageType.text,
          createdAt: now,
          content: 'Original content',
        );

        final copied = original.copyWith(content: 'New content');

        expect(copied.id, 1);
        expect(copied.roomId, 'room-123');
        expect(copied.profileId, 'user-456');
        expect(copied.messageType, MessageType.text);
        expect(copied.createdAt, now);
        expect(copied.content, 'New content');
      });

      test('should update multiple fields at once', () {
        final now = DateTime.now();
        final original = ChatMessage(
          id: 1,
          roomId: 'room-123',
          profileId: 'user-456',
          messageType: MessageType.text,
          createdAt: now,
        );

        final copied = original.copyWith(
          isDeleted: true,
          content: 'Updated content',
        );

        expect(copied.isDeleted, true);
        expect(copied.content, 'Updated content');
      });

      test('should not modify original', () {
        final now = DateTime.now();
        final original = ChatMessage(
          id: 1,
          roomId: 'room-123',
          profileId: 'user-456',
          messageType: MessageType.text,
          createdAt: now,
          content: 'Original',
        );

        original.copyWith(content: 'Modified');

        expect(original.content, 'Original');
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when all fields are same', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final message1 = ChatMessage(
          id: 1,
          roomId: 'room-123',
          profileId: 'user-456',
          messageType: MessageType.text,
          createdAt: now,
          content: 'Hello',
        );
        final message2 = ChatMessage(
          id: 1,
          roomId: 'room-123',
          profileId: 'user-456',
          messageType: MessageType.text,
          createdAt: now,
          content: 'Hello',
        );

        expect(message1, equals(message2));
        expect(message1.hashCode, equals(message2.hashCode));
      });

      test('should not be equal when id differs', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final message1 = ChatMessage(
          id: 1,
          roomId: 'room-123',
          profileId: 'user-456',
          messageType: MessageType.text,
          createdAt: now,
        );
        final message2 = ChatMessage(
          id: 2,
          roomId: 'room-123',
          profileId: 'user-456',
          messageType: MessageType.text,
          createdAt: now,
        );

        expect(message1, isNot(equals(message2)));
      });

      test('should not be equal when content differs', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final message1 = ChatMessage(
          id: 1,
          roomId: 'room-123',
          profileId: 'user-456',
          messageType: MessageType.text,
          createdAt: now,
          content: 'Hello',
        );
        final message2 = ChatMessage(
          id: 1,
          roomId: 'room-123',
          profileId: 'user-456',
          messageType: MessageType.text,
          createdAt: now,
          content: 'Goodbye',
        );

        expect(message1, isNot(equals(message2)));
      });

      test('should return identical for same instance', () {
        final message = ChatMessage(
          id: 1,
          roomId: 'room-123',
          profileId: 'user-456',
          messageType: MessageType.text,
          createdAt: DateTime.now(),
        );

        expect(message == message, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final message = ChatMessage(
          id: 42,
          roomId: 'room-123',
          profileId: 'user-456',
          messageType: MessageType.image,
          createdAt: now,
        );

        final result = message.toString();

        expect(result, contains('42'));
        expect(result, contains('image'));
        expect(result, contains('2025'));
      });
    });
  });
}
