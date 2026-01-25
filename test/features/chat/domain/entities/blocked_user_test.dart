import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/chat/domain/entities/blocked_user.dart';
import 'package:lynewed_beta/features/chat/domain/entities/chat_enums.dart';

void main() {
  group('BlockedUser', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create BlockedUser with required fields', () {
        final now = DateTime.now();
        final blockedUser = BlockedUser(
          blockedProfileId: 'user-456',
          createdAt: now,
        );

        expect(blockedUser.blockedProfileId, 'user-456');
        expect(blockedUser.createdAt, now);
        expect(blockedUser.fullName, isNull);
        expect(blockedUser.avatarUrl, isNull);
        expect(blockedUser.role, isNull);
      });

      test('should create BlockedUser with all optional fields', () {
        final now = DateTime.now();
        final blockedUser = BlockedUser(
          blockedProfileId: 'user-789',
          createdAt: now,
          fullName: 'Blocked Person',
          avatarUrl: 'https://example.com/avatar.jpg',
          role: UserRole.professional,
        );

        expect(blockedUser.fullName, 'Blocked Person');
        expect(blockedUser.avatarUrl, 'https://example.com/avatar.jpg');
        expect(blockedUser.role, UserRole.professional);
      });
    });

    // ==============================================================
    // FROMMAP TESTS
    // ==============================================================

    group('fromMap', () {
      test('should parse data correctly', () {
        final map = {
          'blocked_profile_id': 'user-123',
          'created_at': '2025-01-24T10:00:00Z',
          'full_name': 'John Blocked',
          'avatar_url': 'https://example.com/john.jpg',
          'role': 'professional',
        };

        final blockedUser = BlockedUser.fromMap(map);

        expect(blockedUser.blockedProfileId, 'user-123');
        expect(blockedUser.createdAt.year, 2025);
        expect(blockedUser.createdAt.month, 1);
        expect(blockedUser.createdAt.day, 24);
        expect(blockedUser.fullName, 'John Blocked');
        expect(blockedUser.avatarUrl, 'https://example.com/john.jpg');
        expect(blockedUser.role, UserRole.professional);
      });

      test('should handle null optional fields', () {
        final map = {
          'blocked_profile_id': 'user-456',
          'created_at': '2025-01-24T15:00:00Z',
          'full_name': null,
          'avatar_url': null,
          'role': null,
        };

        final blockedUser = BlockedUser.fromMap(map);

        expect(blockedUser.blockedProfileId, 'user-456');
        expect(blockedUser.fullName, isNull);
        expect(blockedUser.avatarUrl, isNull);
        expect(blockedUser.role, isNull);
      });

      test('should parse bride role correctly', () {
        final map = {
          'blocked_profile_id': 'user-bride',
          'created_at': '2025-01-24T10:00:00Z',
          'role': 'bride',
        };

        final blockedUser = BlockedUser.fromMap(map);

        expect(blockedUser.role, UserRole.bride);
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final now = DateTime.now();
        final original = BlockedUser(
          blockedProfileId: 'user-123',
          createdAt: now,
          fullName: 'Original Name',
        );

        final copied = original.copyWith(fullName: 'New Name');

        expect(copied.blockedProfileId, 'user-123');
        expect(copied.createdAt, now);
        expect(copied.fullName, 'New Name');
      });

      test('should update multiple fields at once', () {
        final now = DateTime.now();
        final original = BlockedUser(
          blockedProfileId: 'user-123',
          createdAt: now,
        );

        final copied = original.copyWith(
          fullName: 'Updated Name',
          avatarUrl: 'https://example.com/new.jpg',
          role: UserRole.bride,
        );

        expect(copied.fullName, 'Updated Name');
        expect(copied.avatarUrl, 'https://example.com/new.jpg');
        expect(copied.role, UserRole.bride);
      });

      test('should not modify original', () {
        final original = BlockedUser(
          blockedProfileId: 'user-123',
          createdAt: DateTime.now(),
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
      test('should be equal when blockedProfileId and createdAt are same', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final user1 = BlockedUser(
          blockedProfileId: 'user-123',
          createdAt: now,
          fullName: 'Name 1',
        );
        final user2 = BlockedUser(
          blockedProfileId: 'user-123',
          createdAt: now,
          fullName: 'Name 2', // Different name, but should still be equal
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when blockedProfileId differs', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final user1 = BlockedUser(
          blockedProfileId: 'user-123',
          createdAt: now,
        );
        final user2 = BlockedUser(
          blockedProfileId: 'user-456',
          createdAt: now,
        );

        expect(user1, isNot(equals(user2)));
      });

      test('should not be equal when createdAt differs', () {
        final user1 = BlockedUser(
          blockedProfileId: 'user-123',
          createdAt: DateTime(2025, 1, 24, 10, 0, 0),
        );
        final user2 = BlockedUser(
          blockedProfileId: 'user-123',
          createdAt: DateTime(2025, 1, 24, 11, 0, 0),
        );

        expect(user1, isNot(equals(user2)));
      });

      test('should return identical for same instance', () {
        final user = BlockedUser(
          blockedProfileId: 'user-123',
          createdAt: DateTime.now(),
        );

        expect(user == user, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string with id and name', () {
        final user = BlockedUser(
          blockedProfileId: 'user-123',
          createdAt: DateTime.now(),
          fullName: 'John Blocked',
        );

        final result = user.toString();

        expect(result, contains('user-123'));
        expect(result, contains('John Blocked'));
      });

      test('should handle null name in toString', () {
        final user = BlockedUser(
          blockedProfileId: 'user-456',
          createdAt: DateTime.now(),
        );

        final result = user.toString();

        expect(result, contains('user-456'));
        expect(result, contains('null'));
      });
    });
  });
}
