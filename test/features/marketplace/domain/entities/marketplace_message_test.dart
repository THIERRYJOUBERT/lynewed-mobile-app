import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_message.dart';

void main() {
  // Shared test data
  final now = DateTime(2026, 2, 4, 10, 0);

  MarketplaceMessage createMessage({
    String id = 'msg-123',
    String listingId = 'listing-456',
    String senderId = 'sender-789',
    String receiverId = 'receiver-012',
    String content = 'Hello, is this still available?',
    bool isRead = false,
    DateTime? createdAt,
  }) {
    return MarketplaceMessage(
      id: id,
      listingId: listingId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      isRead: isRead,
      createdAt: createdAt ?? now,
    );
  }

  group('MarketplaceMessage', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create MarketplaceMessage with required fields', () {
        final message = createMessage();

        expect(message.id, 'msg-123');
        expect(message.listingId, 'listing-456');
        expect(message.senderId, 'sender-789');
        expect(message.receiverId, 'receiver-012');
        expect(message.content, 'Hello, is this still available?');
        expect(message.isRead, isFalse);
        expect(message.createdAt, now);
      });

      test('should be immutable', () {
        final message = createMessage();

        // Verify fields are final (compile-time check)
        // Cannot reassign: message.isRead = true; // Would not compile
        expect(message.isRead, isFalse);
        expect(message.content, 'Hello, is this still available?');
      });
    });

    // ==============================================================
    // READ STATUS TESTS
    // ==============================================================

    group('read status', () {
      test('isUnread should be true when isRead is false', () {
        final message = createMessage(isRead: false);

        expect(message.isUnread, isTrue);
      });

      test('isUnread should be false when isRead is true', () {
        final message = createMessage(isRead: true);

        expect(message.isUnread, isFalse);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is the same', () {
        final message1 = createMessage(id: 'msg-same');
        final message2 = createMessage(
          id: 'msg-same',
          listingId: 'listing-999',
          senderId: 'sender-999',
          receiverId: 'receiver-999',
          content: 'Different content',
          isRead: true,
          createdAt: now.add(const Duration(days: 1)),
        );

        expect(message1, equals(message2));
      });

      test('should have consistent hashCode when id is the same', () {
        final message1 = createMessage(id: 'msg-same');
        final message2 = createMessage(
          id: 'msg-same',
          content: 'Other text',
          isRead: true,
        );

        expect(message1.hashCode, equals(message2.hashCode));
      });

      test('should not be equal when id differs', () {
        final message1 = createMessage(id: 'msg-111');
        final message2 = createMessage(id: 'msg-222');

        expect(message1, isNot(equals(message2)));
      });

      test('should have different hashCode when id differs', () {
        final message1 = createMessage(id: 'msg-111');
        final message2 = createMessage(id: 'msg-222');

        expect(message1.hashCode, isNot(equals(message2.hashCode)));
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should create copy with updated isRead', () {
        final message = createMessage(isRead: false);
        final updated = message.copyWith(isRead: true);

        expect(updated.isRead, isTrue);
        expect(updated.id, message.id);
        expect(updated.listingId, message.listingId);
        expect(updated.senderId, message.senderId);
        expect(updated.receiverId, message.receiverId);
        expect(updated.content, message.content);
        expect(updated.createdAt, message.createdAt);
      });

      test('should preserve all fields when no parameter provided', () {
        final message = createMessage();
        final copied = message.copyWith();

        expect(copied.id, message.id);
        expect(copied.listingId, message.listingId);
        expect(copied.senderId, message.senderId);
        expect(copied.receiverId, message.receiverId);
        expect(copied.content, message.content);
        expect(copied.isRead, message.isRead);
        expect(copied.createdAt, message.createdAt);
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should contain key fields', () {
        final message = createMessage(
          id: 'msg-abc',
          senderId: 'sender-xyz',
          isRead: false,
          content: 'Hello world!',
        );

        final str = message.toString();

        expect(str, contains('msg-abc'));
        expect(str, contains('sender-xyz'));
        expect(str, contains('false'));
        expect(str, contains('Hello'));
      });

      test('should truncate long content', () {
        final longContent = 'A' * 100;
        final message = createMessage(content: longContent);

        final str = message.toString();

        // Should truncate to 20 chars + "..."
        expect(str.length, lessThan(200));
        expect(str, contains('...'));
      });

      test('should not truncate short content', () {
        final message = createMessage(content: 'Short');

        final str = message.toString();

        expect(str, contains('Short'));
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse valid Supabase JSON row', () {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'listing_id': '660e8400-e29b-41d4-a716-446655440001',
          'sender_id': '770e8400-e29b-41d4-a716-446655440002',
          'receiver_id': '880e8400-e29b-41d4-a716-446655440003',
          'content': 'Is this still available?',
          'is_read': false,
          'created_at': '2026-02-04T10:00:00.000Z',
        };

        final message = MarketplaceMessage.fromJson(json);

        expect(message.id, '550e8400-e29b-41d4-a716-446655440000');
        expect(message.listingId, '660e8400-e29b-41d4-a716-446655440001');
        expect(message.senderId, '770e8400-e29b-41d4-a716-446655440002');
        expect(message.receiverId, '880e8400-e29b-41d4-a716-446655440003');
        expect(message.content, 'Is this still available?');
        expect(message.isRead, isFalse);
        expect(message.createdAt, DateTime.parse('2026-02-04T10:00:00.000Z'));
      });

      test('should map snake_case to camelCase correctly', () {
        final json = {
          'id': 'uuid-1',
          'listing_id': 'listing-abc',
          'sender_id': 'sender-def',
          'receiver_id': 'receiver-ghi',
          'content': 'Test mapping',
          'is_read': true,
          'created_at': '2026-01-15T08:30:00.000Z',
        };

        final message = MarketplaceMessage.fromJson(json);

        // Verify camelCase mapping
        expect(message.listingId, 'listing-abc');
        expect(message.senderId, 'sender-def');
        expect(message.receiverId, 'receiver-ghi');
        expect(message.isRead, isTrue);
        expect(message.createdAt, DateTime.parse('2026-01-15T08:30:00.000Z'));
      });

      test('should parse is_read true correctly', () {
        final json = {
          'id': 'uuid-1',
          'listing_id': 'listing-1',
          'sender_id': 'sender-1',
          'receiver_id': 'receiver-1',
          'content': 'Read message',
          'is_read': true,
          'created_at': '2026-02-04T10:00:00.000Z',
        };

        final message = MarketplaceMessage.fromJson(json);

        expect(message.isRead, isTrue);
        expect(message.isUnread, isFalse);
      });
    });

    // ==============================================================
    // TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should exclude auto-generated fields (id, created_at)', () {
        final message = createMessage();
        final json = message.toJson();

        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('created_at'), isFalse);
      });

      test('should include all insert-relevant fields', () {
        final message = createMessage();
        final json = message.toJson();

        // Must include base fields + message_type (always present).
        final expectedKeys = {
          'listing_id',
          'sender_id',
          'receiver_id',
          'content',
          'is_read',
          'message_type',
        };

        expect(json.keys.toSet(), expectedKeys);
      });

      test('should produce correct snake_case keys and values', () {
        final message = createMessage(
          listingId: 'listing-abc',
          senderId: 'sender-def',
          receiverId: 'receiver-ghi',
          content: 'Hello seller!',
          isRead: false,
        );
        final json = message.toJson();

        expect(json['listing_id'], 'listing-abc');
        expect(json['sender_id'], 'sender-def');
        expect(json['receiver_id'], 'receiver-ghi');
        expect(json['content'], 'Hello seller!');
        expect(json['is_read'], isFalse);
      });
    });

    // ==============================================================
    // ROUNDTRIP TEST
    // ==============================================================

    group('fromJson/toJson roundtrip', () {
      test('should maintain consistency between fromJson and toJson', () {
        final originalJson = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'listing_id': '660e8400-e29b-41d4-a716-446655440001',
          'sender_id': '770e8400-e29b-41d4-a716-446655440002',
          'receiver_id': '880e8400-e29b-41d4-a716-446655440003',
          'content': 'Roundtrip test message',
          'is_read': false,
          'created_at': '2026-02-04T10:00:00.000Z',
        };

        final message = MarketplaceMessage.fromJson(originalJson);
        final outputJson = message.toJson();

        // toJson excludes id and created_at (auto-generated)
        // So we check the common insert fields match
        expect(outputJson['listing_id'], originalJson['listing_id']);
        expect(outputJson['sender_id'], originalJson['sender_id']);
        expect(outputJson['receiver_id'], originalJson['receiver_id']);
        expect(outputJson['content'], originalJson['content']);
        expect(outputJson['is_read'], originalJson['is_read']);

        // Re-parse with original id and created_at to verify full roundtrip
        final reconstituted = MarketplaceMessage.fromJson({
          ...outputJson,
          'id': originalJson['id'],
          'created_at': originalJson['created_at'],
        });

        expect(reconstituted, equals(message));
        expect(reconstituted.listingId, message.listingId);
        expect(reconstituted.content, message.content);
        expect(reconstituted.isRead, message.isRead);
      });
    });
  });
}
