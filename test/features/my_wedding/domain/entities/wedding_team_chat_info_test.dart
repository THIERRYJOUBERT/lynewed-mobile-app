import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/wedding_team_chat_info.dart';

void main() {
  group('WeddingTeamChatInfo', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create WeddingTeamChatInfo with required fields', () {
        const chatInfo = WeddingTeamChatInfo(
          roomId: 'room-123',
          weddingId: 'wedding-456',
        );

        expect(chatInfo.roomId, 'room-123');
        expect(chatInfo.weddingId, 'wedding-456');
        expect(chatInfo.participantsCount, 0);
        expect(chatInfo.unreadCount, 0);
        expect(chatInfo.participantAvatars, isEmpty);
      });

      test('should create WeddingTeamChatInfo with all optional fields', () {
        const chatInfo = WeddingTeamChatInfo(
          roomId: 'room-123',
          weddingId: 'wedding-456',
          participantsCount: 5,
          unreadCount: 3,
          participantAvatars: [
            'https://example.com/avatar1.jpg',
            'https://example.com/avatar2.jpg',
          ],
        );

        expect(chatInfo.participantsCount, 5);
        expect(chatInfo.unreadCount, 3);
        expect(chatInfo.participantAvatars.length, 2);
        expect(chatInfo.participantAvatars[0], 'https://example.com/avatar1.jpg');
        expect(chatInfo.participantAvatars[1], 'https://example.com/avatar2.jpg');
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse chat info with all fields', () {
        final json = {
          'id': 'room-123',
          'wedding_id': 'wedding-456',
          'unread_count': 3,
          'chat_room_participants': [
            {
              'profiles': {
                'avatar_url': 'https://example.com/avatar1.jpg',
              },
            },
            {
              'profiles': {
                'avatar_url': 'https://example.com/avatar2.jpg',
              },
            },
            {
              'profiles': {
                'avatar_url': 'https://example.com/avatar3.jpg',
              },
            },
          ],
        };

        final chatInfo = WeddingTeamChatInfo.fromJson(json);

        expect(chatInfo.roomId, 'room-123');
        expect(chatInfo.weddingId, 'wedding-456');
        expect(chatInfo.participantsCount, 3);
        expect(chatInfo.unreadCount, 3);
        expect(chatInfo.participantAvatars.length, 3);
      });

      test('should parse chat info with minimal fields', () {
        final json = {
          'id': 'room-123',
          'wedding_id': 'wedding-456',
        };

        final chatInfo = WeddingTeamChatInfo.fromJson(json);

        expect(chatInfo.roomId, 'room-123');
        expect(chatInfo.weddingId, 'wedding-456');
        expect(chatInfo.participantsCount, 0);
        expect(chatInfo.unreadCount, 0);
        expect(chatInfo.participantAvatars, isEmpty);
      });

      test('should limit avatars to maximum 4', () {
        final json = {
          'id': 'room-123',
          'wedding_id': 'wedding-456',
          'chat_room_participants': [
            {'profiles': {'avatar_url': 'https://example.com/avatar1.jpg'}},
            {'profiles': {'avatar_url': 'https://example.com/avatar2.jpg'}},
            {'profiles': {'avatar_url': 'https://example.com/avatar3.jpg'}},
            {'profiles': {'avatar_url': 'https://example.com/avatar4.jpg'}},
            {'profiles': {'avatar_url': 'https://example.com/avatar5.jpg'}},
            {'profiles': {'avatar_url': 'https://example.com/avatar6.jpg'}},
          ],
        };

        final chatInfo = WeddingTeamChatInfo.fromJson(json);

        expect(chatInfo.participantsCount, 6); // All participants counted
        expect(chatInfo.participantAvatars.length, 4); // But only 4 avatars
      });

      test('should handle null unread_count', () {
        final json = {
          'id': 'room-123',
          'wedding_id': 'wedding-456',
          'unread_count': null,
        };

        final chatInfo = WeddingTeamChatInfo.fromJson(json);

        expect(chatInfo.unreadCount, 0);
      });

      test('should handle null chat_room_participants', () {
        final json = {
          'id': 'room-123',
          'wedding_id': 'wedding-456',
          'chat_room_participants': null,
        };

        final chatInfo = WeddingTeamChatInfo.fromJson(json);

        expect(chatInfo.participantsCount, 0);
        expect(chatInfo.participantAvatars, isEmpty);
      });

      test('should handle empty chat_room_participants', () {
        final json = {
          'id': 'room-123',
          'wedding_id': 'wedding-456',
          'chat_room_participants': <dynamic>[],
        };

        final chatInfo = WeddingTeamChatInfo.fromJson(json);

        expect(chatInfo.participantsCount, 0);
        expect(chatInfo.participantAvatars, isEmpty);
      });

      test('should skip participants with null profiles', () {
        final json = {
          'id': 'room-123',
          'wedding_id': 'wedding-456',
          'chat_room_participants': [
            {'profiles': {'avatar_url': 'https://example.com/avatar1.jpg'}},
            {'profiles': null},
            {'profiles': {'avatar_url': 'https://example.com/avatar2.jpg'}},
          ],
        };

        final chatInfo = WeddingTeamChatInfo.fromJson(json);

        expect(chatInfo.participantsCount, 3);
        expect(chatInfo.participantAvatars.length, 2);
      });

      test('should skip participants with null avatar_url', () {
        final json = {
          'id': 'room-123',
          'wedding_id': 'wedding-456',
          'chat_room_participants': [
            {'profiles': {'avatar_url': 'https://example.com/avatar1.jpg'}},
            {'profiles': {'avatar_url': null}},
            {'profiles': {'avatar_url': 'https://example.com/avatar2.jpg'}},
          ],
        };

        final chatInfo = WeddingTeamChatInfo.fromJson(json);

        expect(chatInfo.participantsCount, 3);
        expect(chatInfo.participantAvatars.length, 2);
      });

      test('should skip participants with empty avatar_url', () {
        final json = {
          'id': 'room-123',
          'wedding_id': 'wedding-456',
          'chat_room_participants': [
            {'profiles': {'avatar_url': 'https://example.com/avatar1.jpg'}},
            {'profiles': {'avatar_url': ''}},
            {'profiles': {'avatar_url': 'https://example.com/avatar2.jpg'}},
          ],
        };

        final chatInfo = WeddingTeamChatInfo.fromJson(json);

        expect(chatInfo.participantsCount, 3);
        expect(chatInfo.participantAvatars.length, 2);
      });

      test('should handle participants without profiles key', () {
        final json = {
          'id': 'room-123',
          'wedding_id': 'wedding-456',
          'chat_room_participants': [
            {'profiles': {'avatar_url': 'https://example.com/avatar1.jpg'}},
            {'other_field': 'value'},
            {'profiles': {'avatar_url': 'https://example.com/avatar2.jpg'}},
          ],
        };

        final chatInfo = WeddingTeamChatInfo.fromJson(json);

        expect(chatInfo.participantsCount, 3);
        expect(chatInfo.participantAvatars.length, 2);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when roomId is same', () {
        const chatInfo1 = WeddingTeamChatInfo(
          roomId: 'room-123',
          weddingId: 'wedding-456',
          participantsCount: 3,
        );
        const chatInfo2 = WeddingTeamChatInfo(
          roomId: 'room-123',
          weddingId: 'wedding-789',
          participantsCount: 5,
        );

        expect(chatInfo1, equals(chatInfo2));
        expect(chatInfo1.hashCode, equals(chatInfo2.hashCode));
      });

      test('should not be equal when roomId differs', () {
        const chatInfo1 = WeddingTeamChatInfo(
          roomId: 'room-123',
          weddingId: 'wedding-456',
        );
        const chatInfo2 = WeddingTeamChatInfo(
          roomId: 'room-789',
          weddingId: 'wedding-456',
        );

        expect(chatInfo1, isNot(equals(chatInfo2)));
      });

      test('should return identical for same instance', () {
        const chatInfo = WeddingTeamChatInfo(
          roomId: 'room-123',
          weddingId: 'wedding-456',
        );

        expect(chatInfo == chatInfo, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        const chatInfo = WeddingTeamChatInfo(
          roomId: 'room-123',
          weddingId: 'wedding-456',
          participantsCount: 5,
        );

        final result = chatInfo.toString();

        expect(result, contains('room-123'));
        expect(result, contains('5 participants'));
      });
    });
  });
}
