import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/chat/domain/entities/conversation.dart';
import 'package:lynewed_beta/features/chat/domain/entities/chat_enums.dart';

void main() {
  group('Conversation', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create Conversation with required fields', () {
        final conversation = Conversation(
          roomId: 'room-123',
          roomType: RoomType.private,
          conversationStatus: ConversationStatus.active,
          unreadCount: 5,
        );

        expect(conversation.roomId, 'room-123');
        expect(conversation.roomType, RoomType.private);
        expect(conversation.conversationStatus, ConversationStatus.active);
        expect(conversation.unreadCount, 5);
      });

      test('should create Conversation with all optional fields', () {
        final now = DateTime.now();
        final conversation = Conversation(
          roomId: 'room-456',
          roomType: RoomType.public,
          conversationStatus: ConversationStatus.archived,
          unreadCount: 0,
          lastMessageType: MessageType.text,
          lastMessageText: 'Hello!',
          lastMessageAt: now,
          otherProfileId: 'user-789',
          otherFullName: 'John Doe',
          otherAvatarUrl: 'https://example.com/avatar.jpg',
          otherRole: UserRole.professional,
          publicTitle: 'Wedding Planning',
          publicCoverUrl: 'https://example.com/cover.jpg',
          audienceRole: UserRole.bride,
        );

        expect(conversation.lastMessageType, MessageType.text);
        expect(conversation.lastMessageText, 'Hello!');
        expect(conversation.lastMessageAt, now);
        expect(conversation.otherProfileId, 'user-789');
        expect(conversation.otherFullName, 'John Doe');
        expect(conversation.otherAvatarUrl, 'https://example.com/avatar.jpg');
        expect(conversation.otherRole, UserRole.professional);
        expect(conversation.publicTitle, 'Wedding Planning');
        expect(conversation.publicCoverUrl, 'https://example.com/cover.jpg');
        expect(conversation.audienceRole, UserRole.bride);
      });
    });

    // ==============================================================
    // FROMMAP TESTS
    // ==============================================================

    group('fromMap', () {
      test('should parse snake_case data correctly', () {
        final map = {
          'room_id': 'room-123',
          'room_type': 'private',
          'conversation_status': 'active',
          'unread_count': 5,
          'last_message_type': 'text',
          'last_message_text': 'Hello!',
          'last_message_at': '2025-01-24T10:00:00Z',
          'other_profile_id': 'user-456',
          'other_full_name': 'Jane Doe',
          'other_avatar_url': 'https://example.com/avatar.jpg',
          'other_role': 'bride',
          'public_title': 'Public Room',
          'public_cover_url': 'https://example.com/cover.jpg',
          'audience_role': 'professional',
        };

        final conversation = Conversation.fromMap(map);

        expect(conversation.roomId, 'room-123');
        expect(conversation.roomType, RoomType.private);
        expect(conversation.conversationStatus, ConversationStatus.active);
        expect(conversation.unreadCount, 5);
        expect(conversation.lastMessageType, MessageType.text);
        expect(conversation.lastMessageText, 'Hello!');
        expect(conversation.lastMessageAt, isNotNull);
        expect(conversation.otherProfileId, 'user-456');
        expect(conversation.otherFullName, 'Jane Doe');
        expect(conversation.otherAvatarUrl, 'https://example.com/avatar.jpg');
        expect(conversation.otherRole, UserRole.bride);
        expect(conversation.publicTitle, 'Public Room');
        expect(conversation.publicCoverUrl, 'https://example.com/cover.jpg');
        expect(conversation.audienceRole, UserRole.professional);
      });

      test('should parse camelCase data correctly', () {
        final map = {
          'roomId': 'room-789',
          'roomType': 'public',
          'conversationStatus': 'pending',
          'unreadCount': 10,
          'lastMessageType': 'image',
          'lastMessageText': null,
          'lastMessageAt': '2025-01-24T15:00:00Z',
          'otherProfileId': 'user-abc',
          'otherFullName': 'Pro User',
          'otherAvatarUrl': 'https://example.com/pro.jpg',
          'otherRole': 'professional',
          'publicTitle': 'Pro Group',
          'publicCoverUrl': 'https://example.com/group.jpg',
          'audienceRole': 'bride',
        };

        final conversation = Conversation.fromMap(map);

        expect(conversation.roomId, 'room-789');
        expect(conversation.roomType, RoomType.public);
        expect(conversation.conversationStatus, ConversationStatus.pending);
        expect(conversation.unreadCount, 10);
        expect(conversation.lastMessageType, MessageType.image);
        expect(conversation.otherProfileId, 'user-abc');
        expect(conversation.otherRole, UserRole.professional);
      });

      test('should handle null optional fields', () {
        final map = {
          'room_id': 'room-min',
          'room_type': 'private',
          'conversation_status': 'active',
          'unread_count': 0,
        };

        final conversation = Conversation.fromMap(map);

        expect(conversation.roomId, 'room-min');
        expect(conversation.lastMessageType, isNull);
        expect(conversation.lastMessageText, isNull);
        expect(conversation.lastMessageAt, isNull);
        expect(conversation.otherProfileId, isNull);
        expect(conversation.otherFullName, isNull);
      });

      test('should handle DateTime object for lastMessageAt', () {
        final dateTime = DateTime(2025, 1, 24, 12, 0, 0);
        final map = {
          'room_id': 'room-dt',
          'room_type': 'private',
          'conversation_status': 'active',
          'unread_count': 0,
          'last_message_at': dateTime,
        };

        final conversation = Conversation.fromMap(map);

        expect(conversation.lastMessageAt, dateTime);
      });

      test('should default to active status when conversation_status is null', () {
        final map = {
          'room_id': 'room-null-status',
          'room_type': 'private',
          'unread_count': 0,
        };

        final conversation = Conversation.fromMap(map);

        expect(conversation.conversationStatus, ConversationStatus.active);
      });

      test('should default to private room type when room_type is null', () {
        final map = {
          'room_id': 'room-null-type',
          'conversation_status': 'active',
          'unread_count': 0,
        };

        final conversation = Conversation.fromMap(map);

        expect(conversation.roomType, RoomType.private);
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final original = Conversation(
          roomId: 'room-123',
          roomType: RoomType.private,
          conversationStatus: ConversationStatus.active,
          unreadCount: 5,
          otherFullName: 'John Doe',
        );

        final copied = original.copyWith(unreadCount: 10);

        expect(copied.roomId, 'room-123');
        expect(copied.roomType, RoomType.private);
        expect(copied.conversationStatus, ConversationStatus.active);
        expect(copied.unreadCount, 10);
        expect(copied.otherFullName, 'John Doe');
      });

      test('should update multiple fields at once', () {
        final original = Conversation(
          roomId: 'room-123',
          roomType: RoomType.private,
          conversationStatus: ConversationStatus.active,
          unreadCount: 5,
        );

        final copied = original.copyWith(
          conversationStatus: ConversationStatus.archived,
          unreadCount: 0,
          lastMessageText: 'New message',
        );

        expect(copied.conversationStatus, ConversationStatus.archived);
        expect(copied.unreadCount, 0);
        expect(copied.lastMessageText, 'New message');
      });

      test('should not modify original', () {
        final original = Conversation(
          roomId: 'room-123',
          roomType: RoomType.private,
          conversationStatus: ConversationStatus.active,
          unreadCount: 5,
        );

        original.copyWith(unreadCount: 10);

        expect(original.unreadCount, 5);
      });
    });

    // ==============================================================
    // DERIVED GETTERS TESTS
    // ==============================================================

    group('derived getters', () {
      group('isPublic', () {
        test('should return true for public room', () {
          final conversation = Conversation(
            roomId: 'room-123',
            roomType: RoomType.public,
            conversationStatus: ConversationStatus.active,
            unreadCount: 0,
          );

          expect(conversation.isPublic, true);
        });

        test('should return false for private room', () {
          final conversation = Conversation(
            roomId: 'room-123',
            roomType: RoomType.private,
            conversationStatus: ConversationStatus.active,
            unreadCount: 0,
          );

          expect(conversation.isPublic, false);
        });
      });

      group('displayName', () {
        test('should return publicTitle for public room', () {
          final conversation = Conversation(
            roomId: 'room-123',
            roomType: RoomType.public,
            conversationStatus: ConversationStatus.active,
            unreadCount: 0,
            publicTitle: 'Wedding Group',
          );

          expect(conversation.displayName, 'Wedding Group');
        });

        test('should return default for public room without title', () {
          final conversation = Conversation(
            roomId: 'room-123',
            roomType: RoomType.public,
            conversationStatus: ConversationStatus.active,
            unreadCount: 0,
          );

          expect(conversation.displayName, 'Salon public');
        });

        test('should return otherFullName for private room', () {
          final conversation = Conversation(
            roomId: 'room-123',
            roomType: RoomType.private,
            conversationStatus: ConversationStatus.active,
            unreadCount: 0,
            otherFullName: 'Jane Doe',
          );

          expect(conversation.displayName, 'Jane Doe');
        });

        test('should return default for private room without name', () {
          final conversation = Conversation(
            roomId: 'room-123',
            roomType: RoomType.private,
            conversationStatus: ConversationStatus.active,
            unreadCount: 0,
          );

          expect(conversation.displayName, 'Conversation');
        });
      });

      group('displayAvatarUrl', () {
        test('should return publicCoverUrl for public room', () {
          final conversation = Conversation(
            roomId: 'room-123',
            roomType: RoomType.public,
            conversationStatus: ConversationStatus.active,
            unreadCount: 0,
            publicCoverUrl: 'https://example.com/cover.jpg',
          );

          expect(conversation.displayAvatarUrl, 'https://example.com/cover.jpg');
        });

        test('should return otherAvatarUrl for private room', () {
          final conversation = Conversation(
            roomId: 'room-123',
            roomType: RoomType.private,
            conversationStatus: ConversationStatus.active,
            unreadCount: 0,
            otherAvatarUrl: 'https://example.com/avatar.jpg',
          );

          expect(conversation.displayAvatarUrl, 'https://example.com/avatar.jpg');
        });

        test('should return null when no avatar available', () {
          final conversation = Conversation(
            roomId: 'room-123',
            roomType: RoomType.private,
            conversationStatus: ConversationStatus.active,
            unreadCount: 0,
          );

          expect(conversation.displayAvatarUrl, isNull);
        });
      });

      group('lastMessagePreview', () {
        test('should return text when available', () {
          final conversation = Conversation(
            roomId: 'room-123',
            roomType: RoomType.private,
            conversationStatus: ConversationStatus.active,
            unreadCount: 0,
            lastMessageText: 'Hello there!',
          );

          expect(conversation.lastMessagePreview, 'Hello there!');
        });

        test('should return image emoji for image type', () {
          final conversation = Conversation(
            roomId: 'room-123',
            roomType: RoomType.private,
            conversationStatus: ConversationStatus.active,
            unreadCount: 0,
            lastMessageType: MessageType.image,
          );

          expect(conversation.lastMessagePreview, contains('Image'));
        });

        test('should return audio emoji for audio type', () {
          final conversation = Conversation(
            roomId: 'room-123',
            roomType: RoomType.private,
            conversationStatus: ConversationStatus.active,
            unreadCount: 0,
            lastMessageType: MessageType.audio,
          );

          expect(conversation.lastMessagePreview, contains('Audio'));
        });

        test('should return empty for no message', () {
          final conversation = Conversation(
            roomId: 'room-123',
            roomType: RoomType.private,
            conversationStatus: ConversationStatus.active,
            unreadCount: 0,
          );

          expect(conversation.lastMessagePreview, '');
        });

        test('should return empty string for empty text', () {
          final conversation = Conversation(
            roomId: 'room-123',
            roomType: RoomType.private,
            conversationStatus: ConversationStatus.active,
            unreadCount: 0,
            lastMessageText: '',
          );

          expect(conversation.lastMessagePreview, '');
        });
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when all fields are same', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final conversation1 = Conversation(
          roomId: 'room-123',
          roomType: RoomType.private,
          conversationStatus: ConversationStatus.active,
          unreadCount: 5,
          lastMessageAt: now,
        );
        final conversation2 = Conversation(
          roomId: 'room-123',
          roomType: RoomType.private,
          conversationStatus: ConversationStatus.active,
          unreadCount: 5,
          lastMessageAt: now,
        );

        expect(conversation1, equals(conversation2));
        expect(conversation1.hashCode, equals(conversation2.hashCode));
      });

      test('should not be equal when roomId differs', () {
        final conversation1 = Conversation(
          roomId: 'room-123',
          roomType: RoomType.private,
          conversationStatus: ConversationStatus.active,
          unreadCount: 5,
        );
        final conversation2 = Conversation(
          roomId: 'room-456',
          roomType: RoomType.private,
          conversationStatus: ConversationStatus.active,
          unreadCount: 5,
        );

        expect(conversation1, isNot(equals(conversation2)));
      });

      test('should not be equal when unreadCount differs', () {
        final conversation1 = Conversation(
          roomId: 'room-123',
          roomType: RoomType.private,
          conversationStatus: ConversationStatus.active,
          unreadCount: 5,
        );
        final conversation2 = Conversation(
          roomId: 'room-123',
          roomType: RoomType.private,
          conversationStatus: ConversationStatus.active,
          unreadCount: 10,
        );

        expect(conversation1, isNot(equals(conversation2)));
      });

      test('should return identical for same instance', () {
        final conversation = Conversation(
          roomId: 'room-123',
          roomType: RoomType.private,
          conversationStatus: ConversationStatus.active,
          unreadCount: 5,
        );

        expect(conversation == conversation, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        final conversation = Conversation(
          roomId: 'room-123',
          roomType: RoomType.private,
          conversationStatus: ConversationStatus.active,
          unreadCount: 5,
          otherFullName: 'John Doe',
        );

        final result = conversation.toString();

        expect(result, contains('room-123'));
        expect(result, contains('John Doe'));
        expect(result, contains('5'));
      });
    });
  });
}
