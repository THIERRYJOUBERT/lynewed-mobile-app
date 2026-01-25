import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/chat/domain/entities/chat_participant.dart';
import 'package:lynewed_beta/features/chat/domain/entities/chat_enums.dart';

void main() {
  group('ChatParticipant', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create ChatParticipant with required fields', () {
        final now = DateTime.now();
        final participant = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: now,
        );

        expect(participant.profileId, 'user-123');
        expect(participant.roomId, 'room-456');
        expect(participant.status, ConversationStatus.active);
        expect(participant.joinedAt, now);
        expect(participant.fullName, isNull);
        expect(participant.avatarUrl, isNull);
        expect(participant.role, isNull);
        expect(participant.lastReadAt, isNull);
      });

      test('should create ChatParticipant with all optional fields', () {
        final now = DateTime.now();
        final lastRead = now.subtract(const Duration(hours: 1));
        final participant = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: now,
          fullName: 'John Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          role: UserRole.bride,
          lastReadAt: lastRead,
        );

        expect(participant.fullName, 'John Doe');
        expect(participant.avatarUrl, 'https://example.com/avatar.jpg');
        expect(participant.role, UserRole.bride);
        expect(participant.lastReadAt, lastRead);
      });
    });

    // ==============================================================
    // FROMMAP TESTS
    // ==============================================================

    group('fromMap', () {
      test('should parse participant correctly from snake_case', () {
        final map = {
          'profile_id': 'user-123',
          'room_id': 'room-456',
          'status': 'active',
          'joined_at': '2025-01-24T10:00:00Z',
          'full_name': 'Jane Doe',
          'avatar_url': 'https://example.com/avatar.jpg',
          'role': 'bride',
          'last_read_at': '2025-01-24T11:00:00Z',
        };

        final participant = ChatParticipant.fromMap(map);

        expect(participant.profileId, 'user-123');
        expect(participant.roomId, 'room-456');
        expect(participant.status, ConversationStatus.active);
        expect(participant.joinedAt.year, 2025);
        expect(participant.joinedAt.month, 1);
        expect(participant.joinedAt.day, 24);
        expect(participant.fullName, 'Jane Doe');
        expect(participant.avatarUrl, 'https://example.com/avatar.jpg');
        expect(participant.role, UserRole.bride);
        expect(participant.lastReadAt, isNotNull);
      });

      test('should parse participant correctly from camelCase', () {
        final map = {
          'profileId': 'user-789',
          'roomId': 'room-abc',
          'status': 'pending',
          'joinedAt': '2025-01-24T10:00:00Z',
          'fullName': 'Pro User',
          'avatarUrl': 'https://example.com/pro.jpg',
          'role': 'professional',
          'lastReadAt': null,
        };

        final participant = ChatParticipant.fromMap(map);

        expect(participant.profileId, 'user-789');
        expect(participant.roomId, 'room-abc');
        expect(participant.status, ConversationStatus.pending);
        expect(participant.fullName, 'Pro User');
        expect(participant.role, UserRole.professional);
        expect(participant.lastReadAt, isNull);
      });

      test('should handle null optional fields', () {
        final map = {
          'profile_id': 'user-123',
          'room_id': 'room-456',
          'status': 'active',
          'joined_at': '2025-01-24T10:00:00Z',
          'full_name': null,
          'avatar_url': null,
          'role': null,
          'last_read_at': null,
        };

        final participant = ChatParticipant.fromMap(map);

        expect(participant.fullName, isNull);
        expect(participant.avatarUrl, isNull);
        expect(participant.role, isNull);
        expect(participant.lastReadAt, isNull);
      });

      test('should default to active for null status', () {
        final map = {
          'profile_id': 'user-123',
          'room_id': 'room-456',
          'status': null,
          'joined_at': '2025-01-24T10:00:00Z',
        };

        final participant = ChatParticipant.fromMap(map);

        expect(participant.status, ConversationStatus.active);
      });
    });

    // ==============================================================
    // DERIVED GETTERS TESTS
    // ==============================================================

    group('derived getters', () {
      test('isActive should return true for active status', () {
        final participant = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: DateTime.now(),
        );

        expect(participant.isActive, true);
        expect(participant.isPending, false);
        expect(participant.isArchived, false);
      });

      test('isPending should return true for pending status', () {
        final participant = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.pending,
          joinedAt: DateTime.now(),
        );

        expect(participant.isPending, true);
        expect(participant.isActive, false);
      });

      test('isArchived should return true for archived status', () {
        final participant = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.archived,
          joinedAt: DateTime.now(),
        );

        expect(participant.isArchived, true);
        expect(participant.isActive, false);
      });

      test('displayName should return fullName if available', () {
        final participant = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: DateTime.now(),
          fullName: 'Jane Doe',
        );

        expect(participant.displayName, 'Jane Doe');
      });

      test('displayName should return Participant if fullName is null', () {
        final participant = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: DateTime.now(),
        );

        expect(participant.displayName, 'Participant');
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final now = DateTime.now();
        final original = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: now,
          fullName: 'Original Name',
        );

        final copied = original.copyWith(fullName: 'New Name');

        expect(copied.profileId, 'user-123');
        expect(copied.roomId, 'room-456');
        expect(copied.status, ConversationStatus.active);
        expect(copied.joinedAt, now);
        expect(copied.fullName, 'New Name');
      });

      test('should update status correctly', () {
        final original = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: DateTime.now(),
        );

        final copied = original.copyWith(status: ConversationStatus.archived);

        expect(copied.status, ConversationStatus.archived);
        expect(original.status, ConversationStatus.active);
      });

      test('should update lastReadAt correctly', () {
        final original = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: DateTime.now(),
        );

        final lastRead = DateTime.now();
        final copied = original.copyWith(lastReadAt: lastRead);

        expect(copied.lastReadAt, lastRead);
        expect(original.lastReadAt, isNull);
      });

      test('should not modify original', () {
        final original = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: DateTime.now(),
          fullName: 'Original',
        );

        original.copyWith(fullName: 'Modified');

        expect(original.fullName, 'Original');
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when profileId and roomId are same', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final participant1 = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: now,
        );
        final participant2 = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: now,
        );

        expect(participant1, equals(participant2));
        expect(participant1.hashCode, equals(participant2.hashCode));
      });

      test('should not be equal when profileId differs', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final participant1 = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: now,
        );
        final participant2 = ChatParticipant(
          profileId: 'user-789',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: now,
        );

        expect(participant1, isNot(equals(participant2)));
      });

      test('should not be equal when roomId differs', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final participant1 = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: now,
        );
        final participant2 = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-789',
          status: ConversationStatus.active,
          joinedAt: now,
        );

        expect(participant1, isNot(equals(participant2)));
      });

      test('should return identical for same instance', () {
        final participant = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: DateTime.now(),
        );

        expect(participant == participant, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        final participant = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: DateTime.now(),
          fullName: 'Jane Doe',
        );

        final result = participant.toString();

        expect(result, contains('user-123'));
        expect(result, contains('Jane Doe'));
        expect(result, contains('active'));
      });

      test('should handle null fullName in toString', () {
        final participant = ChatParticipant(
          profileId: 'user-123',
          roomId: 'room-456',
          status: ConversationStatus.active,
          joinedAt: DateTime.now(),
        );

        final result = participant.toString();

        expect(result, contains('user-123'));
        expect(result, contains('active'));
      });
    });
  });
}
