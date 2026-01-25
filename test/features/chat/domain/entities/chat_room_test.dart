import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/chat/domain/entities/chat_room.dart';
import 'package:lynewed_beta/features/chat/domain/entities/chat_enums.dart';

void main() {
  group('ChatRoom', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create ChatRoom with required fields', () {
        final now = DateTime.now();
        final room = ChatRoom(
          id: 'room-123',
          type: RoomType.private,
          isActive: true,
          createdAt: now,
        );

        expect(room.id, 'room-123');
        expect(room.type, RoomType.private);
        expect(room.isActive, true);
        expect(room.createdAt, now);
        expect(room.name, isNull);
      });

      test('should create ChatRoom with name', () {
        final now = DateTime.now();
        final room = ChatRoom(
          id: 'room-456',
          type: RoomType.public,
          isActive: true,
          createdAt: now,
          name: 'Wedding Planning Group',
        );

        expect(room.name, 'Wedding Planning Group');
        expect(room.type, RoomType.public);
      });
    });

    // ==============================================================
    // FROMMAP TESTS
    // ==============================================================

    group('fromMap', () {
      test('should parse private room correctly', () {
        final map = {
          'id': 'room-123',
          'type': 'private',
          'name': null,
          'is_active': true,
          'created_at': '2025-01-24T10:00:00Z',
        };

        final room = ChatRoom.fromMap(map);

        expect(room.id, 'room-123');
        expect(room.type, RoomType.private);
        expect(room.name, isNull);
        expect(room.isActive, true);
        expect(room.createdAt.year, 2025);
        expect(room.createdAt.month, 1);
        expect(room.createdAt.day, 24);
      });

      test('should parse public room correctly', () {
        final map = {
          'id': 'room-456',
          'type': 'public',
          'name': 'Brides Chat',
          'is_active': true,
          'created_at': '2025-01-24T15:00:00Z',
        };

        final room = ChatRoom.fromMap(map);

        expect(room.id, 'room-456');
        expect(room.type, RoomType.public);
        expect(room.name, 'Brides Chat');
      });

      test('should default to true for null is_active', () {
        final map = {
          'id': 'room-789',
          'type': 'private',
          'is_active': null,
          'created_at': '2025-01-24T10:00:00Z',
        };

        final room = ChatRoom.fromMap(map);

        expect(room.isActive, true);
      });

      test('should handle inactive room', () {
        final map = {
          'id': 'room-inactive',
          'type': 'private',
          'is_active': false,
          'created_at': '2025-01-24T10:00:00Z',
        };

        final room = ChatRoom.fromMap(map);

        expect(room.isActive, false);
      });

      test('should default to private for non-public type', () {
        final map = {
          'id': 'room-test',
          'type': 'unknown_type',
          'is_active': true,
          'created_at': '2025-01-24T10:00:00Z',
        };

        final room = ChatRoom.fromMap(map);

        expect(room.type, RoomType.private);
      });
    });

    // ==============================================================
    // DERIVED GETTERS TESTS
    // ==============================================================

    group('derived getters', () {
      test('isPublic should return true for public room', () {
        final room = ChatRoom(
          id: 'room-123',
          type: RoomType.public,
          isActive: true,
          createdAt: DateTime.now(),
        );

        expect(room.isPublic, true);
        expect(room.isPrivate, false);
      });

      test('isPrivate should return true for private room', () {
        final room = ChatRoom(
          id: 'room-123',
          type: RoomType.private,
          isActive: true,
          createdAt: DateTime.now(),
        );

        expect(room.isPrivate, true);
        expect(room.isPublic, false);
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final now = DateTime.now();
        final original = ChatRoom(
          id: 'room-123',
          type: RoomType.private,
          isActive: true,
          createdAt: now,
          name: 'Original Name',
        );

        final copied = original.copyWith(name: 'New Name');

        expect(copied.id, 'room-123');
        expect(copied.type, RoomType.private);
        expect(copied.isActive, true);
        expect(copied.createdAt, now);
        expect(copied.name, 'New Name');
      });

      test('should update isActive', () {
        final original = ChatRoom(
          id: 'room-123',
          type: RoomType.private,
          isActive: true,
          createdAt: DateTime.now(),
        );

        final copied = original.copyWith(isActive: false);

        expect(copied.isActive, false);
        expect(original.isActive, true); // Original unchanged
      });

      test('should not modify original', () {
        final original = ChatRoom(
          id: 'room-123',
          type: RoomType.private,
          isActive: true,
          createdAt: DateTime.now(),
        );

        original.copyWith(isActive: false);

        expect(original.isActive, true);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when all fields are same', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final room1 = ChatRoom(
          id: 'room-123',
          type: RoomType.private,
          isActive: true,
          createdAt: now,
        );
        final room2 = ChatRoom(
          id: 'room-123',
          type: RoomType.private,
          isActive: true,
          createdAt: now,
        );

        expect(room1, equals(room2));
        expect(room1.hashCode, equals(room2.hashCode));
      });

      test('should not be equal when id differs', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final room1 = ChatRoom(
          id: 'room-123',
          type: RoomType.private,
          isActive: true,
          createdAt: now,
        );
        final room2 = ChatRoom(
          id: 'room-456',
          type: RoomType.private,
          isActive: true,
          createdAt: now,
        );

        expect(room1, isNot(equals(room2)));
      });

      test('should not be equal when type differs', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final room1 = ChatRoom(
          id: 'room-123',
          type: RoomType.private,
          isActive: true,
          createdAt: now,
        );
        final room2 = ChatRoom(
          id: 'room-123',
          type: RoomType.public,
          isActive: true,
          createdAt: now,
        );

        expect(room1, isNot(equals(room2)));
      });

      test('should return identical for same instance', () {
        final room = ChatRoom(
          id: 'room-123',
          type: RoomType.private,
          isActive: true,
          createdAt: DateTime.now(),
        );

        expect(room == room, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        final room = ChatRoom(
          id: 'room-123',
          type: RoomType.private,
          isActive: true,
          createdAt: DateTime.now(),
        );

        final result = room.toString();

        expect(result, contains('room-123'));
        expect(result, contains('private'));
      });
    });
  });
}
