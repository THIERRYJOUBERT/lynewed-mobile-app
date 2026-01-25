import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/chat/domain/entities/chat_entry_context.dart';
import 'package:lynewed_beta/features/chat/domain/entities/chat_enums.dart';

void main() {
  group('ChatEntryContext', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create ChatEntryContext with required fields', () {
        const context = ChatEntryContext(
          status: ChatEntryStatus.roomReady,
        );

        expect(context.status, ChatEntryStatus.roomReady);
        expect(context.roomId, isNull);
        expect(context.requestId, isNull);
        expect(context.isPublic, false);
        expect(context.isRoomEmpty, true);
        expect(context.firstMessageTextOnly, false);
        expect(context.limitToSingleInitialMessage, false);
        expect(context.viewerIsReviewer, false);
      });

      test('should create ChatEntryContext with all optional fields', () {
        const context = ChatEntryContext(
          status: ChatEntryStatus.requestPending,
          roomId: 'room-123',
          requestId: 'req-456',
          otherProfileId: 'user-789',
          otherFullName: 'John Pro',
          otherAvatarUrl: 'https://example.com/avatar.jpg',
          otherRole: UserRole.professional,
          isPublic: true,
          isRoomEmpty: false,
          firstMessageTextOnly: true,
          limitToSingleInitialMessage: true,
          viewerIsReviewer: true,
          conversationStatus: ConversationStatus.pending,
          reason: 'Test reason',
        );

        expect(context.roomId, 'room-123');
        expect(context.requestId, 'req-456');
        expect(context.otherProfileId, 'user-789');
        expect(context.otherFullName, 'John Pro');
        expect(context.otherAvatarUrl, 'https://example.com/avatar.jpg');
        expect(context.otherRole, UserRole.professional);
        expect(context.isPublic, true);
        expect(context.isRoomEmpty, false);
        expect(context.firstMessageTextOnly, true);
        expect(context.limitToSingleInitialMessage, true);
        expect(context.viewerIsReviewer, true);
        expect(context.conversationStatus, ConversationStatus.pending);
        expect(context.reason, 'Test reason');
      });
    });

    // ==============================================================
    // FACTORY CONSTRUCTORS TESTS
    // ==============================================================

    group('factory constructors', () {
      test('error factory should create error context', () {
        final context = ChatEntryContext.error('Something went wrong');

        expect(context.status, ChatEntryStatus.error);
        expect(context.reason, 'Something went wrong');
        expect(context.roomId, isNull);
        expect(context.requestId, isNull);
      });
    });

    // ==============================================================
    // FROMMAP TESTS
    // ==============================================================

    group('fromMap', () {
      test('should parse roomReady context correctly', () {
        final map = {
          'status': 'roomReady',
          'roomId': 'room-123',
          'otherProfileId': 'user-456',
          'otherFullName': 'John Doe',
          'otherAvatarUrl': 'https://example.com/avatar.jpg',
          'otherRole': 'professional',
          'isPublic': false,
          'isRoomEmpty': false,
          'firstMessageTextOnly': false,
          'limitToSingleInitialMessage': false,
          'viewerIsReviewer': false,
          'conversationStatus': 'active',
        };

        final context = ChatEntryContext.fromMap(map);

        expect(context.status, ChatEntryStatus.roomReady);
        expect(context.roomId, 'room-123');
        expect(context.otherProfileId, 'user-456');
        expect(context.otherFullName, 'John Doe');
        expect(context.otherRole, UserRole.professional);
        expect(context.isPublic, false);
        expect(context.isRoomEmpty, false);
        expect(context.conversationStatus, ConversationStatus.active);
      });

      test('should parse requestPending context correctly', () {
        final map = {
          'status': 'requestPending',
          'roomId': 'room-pending',
          'requestId': 'req-123',
          'otherProfileId': 'user-pro',
          'otherRole': 'professional',
          'viewerIsReviewer': true,
          'conversationStatus': 'pending',
        };

        final context = ChatEntryContext.fromMap(map);

        expect(context.status, ChatEntryStatus.requestPending);
        expect(context.requestId, 'req-123');
        expect(context.viewerIsReviewer, true);
        expect(context.conversationStatus, ConversationStatus.pending);
      });

      test('should parse requiresRequest context correctly', () {
        final map = {
          'status': 'requiresRequest',
          'otherProfileId': 'user-bride',
          'otherFullName': 'Jane Bride',
          'otherRole': 'bride',
          'firstMessageTextOnly': true,
        };

        final context = ChatEntryContext.fromMap(map);

        expect(context.status, ChatEntryStatus.requiresRequest);
        expect(context.otherFullName, 'Jane Bride');
        expect(context.otherRole, UserRole.bride);
        expect(context.firstMessageTextOnly, true);
      });

      test('should parse blocked context correctly', () {
        final map = {
          'status': 'blocked',
          'reason': 'User has blocked you',
        };

        final context = ChatEntryContext.fromMap(map);

        expect(context.status, ChatEntryStatus.blocked);
        expect(context.reason, 'User has blocked you');
      });

      test('should parse notAllowed context correctly', () {
        final map = {
          'status': 'notAllowed',
          'reason': 'Tier limit reached',
        };

        final context = ChatEntryContext.fromMap(map);

        expect(context.status, ChatEntryStatus.notAllowed);
        expect(context.reason, 'Tier limit reached');
      });

      test('should default to error for null status', () {
        final map = {
          'status': null,
          'reason': 'Unknown error',
        };

        final context = ChatEntryContext.fromMap(map);

        expect(context.status, ChatEntryStatus.error);
      });

      test('should default to false for null boolean fields', () {
        final map = {
          'status': 'roomReady',
          'isPublic': null,
          'isRoomEmpty': null,
          'firstMessageTextOnly': null,
          'limitToSingleInitialMessage': null,
          'viewerIsReviewer': null,
        };

        final context = ChatEntryContext.fromMap(map);

        expect(context.isPublic, false);
        expect(context.isRoomEmpty, true); // This defaults to true per constructor
        expect(context.firstMessageTextOnly, false);
        expect(context.limitToSingleInitialMessage, false);
        expect(context.viewerIsReviewer, false);
      });
    });

    // ==============================================================
    // DERIVED GETTERS TESTS
    // ==============================================================

    group('derived getters', () {
      group('canNavigateToChat', () {
        test('should return true for roomReady', () {
          const context = ChatEntryContext(status: ChatEntryStatus.roomReady);
          expect(context.canNavigateToChat, true);
        });

        test('should return true for requestPending', () {
          const context = ChatEntryContext(status: ChatEntryStatus.requestPending);
          expect(context.canNavigateToChat, true);
        });

        test('should return false for requiresRequest', () {
          const context = ChatEntryContext(status: ChatEntryStatus.requiresRequest);
          expect(context.canNavigateToChat, false);
        });

        test('should return false for blocked', () {
          const context = ChatEntryContext(status: ChatEntryStatus.blocked);
          expect(context.canNavigateToChat, false);
        });

        test('should return false for error', () {
          const context = ChatEntryContext(status: ChatEntryStatus.error);
          expect(context.canNavigateToChat, false);
        });
      });

      group('requiresContactRequest', () {
        test('should return true for requiresRequest', () {
          const context = ChatEntryContext(status: ChatEntryStatus.requiresRequest);
          expect(context.requiresContactRequest, true);
        });

        test('should return false for roomReady', () {
          const context = ChatEntryContext(status: ChatEntryStatus.roomReady);
          expect(context.requiresContactRequest, false);
        });

        test('should return false for error', () {
          const context = ChatEntryContext(status: ChatEntryStatus.error);
          expect(context.requiresContactRequest, false);
        });
      });

      group('isBlocked', () {
        test('should return true for blocked status', () {
          const context = ChatEntryContext(status: ChatEntryStatus.blocked);
          expect(context.isBlocked, true);
        });

        test('should return false for roomReady', () {
          const context = ChatEntryContext(status: ChatEntryStatus.roomReady);
          expect(context.isBlocked, false);
        });
      });

      group('hasError', () {
        test('should return true for error status', () {
          const context = ChatEntryContext(status: ChatEntryStatus.error);
          expect(context.hasError, true);
        });

        test('should return true for notAllowed status', () {
          const context = ChatEntryContext(status: ChatEntryStatus.notAllowed);
          expect(context.hasError, true);
        });

        test('should return false for roomReady', () {
          const context = ChatEntryContext(status: ChatEntryStatus.roomReady);
          expect(context.hasError, false);
        });

        test('should return false for blocked', () {
          const context = ChatEntryContext(status: ChatEntryStatus.blocked);
          expect(context.hasError, false);
        });
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        const original = ChatEntryContext(
          status: ChatEntryStatus.roomReady,
          roomId: 'room-123',
          otherFullName: 'John Doe',
        );

        final copied = original.copyWith(roomId: 'room-456');

        expect(copied.status, ChatEntryStatus.roomReady);
        expect(copied.roomId, 'room-456');
        expect(copied.otherFullName, 'John Doe');
      });

      test('should update multiple fields at once', () {
        const original = ChatEntryContext(
          status: ChatEntryStatus.requiresRequest,
        );

        final copied = original.copyWith(
          status: ChatEntryStatus.roomReady,
          roomId: 'room-new',
          isRoomEmpty: false,
        );

        expect(copied.status, ChatEntryStatus.roomReady);
        expect(copied.roomId, 'room-new');
        expect(copied.isRoomEmpty, false);
      });

      test('should not modify original', () {
        const original = ChatEntryContext(
          status: ChatEntryStatus.roomReady,
          roomId: 'room-original',
        );

        original.copyWith(roomId: 'room-modified');

        expect(original.roomId, 'room-original');
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when all fields are same', () {
        const context1 = ChatEntryContext(
          status: ChatEntryStatus.roomReady,
          roomId: 'room-123',
          isPublic: false,
        );
        const context2 = ChatEntryContext(
          status: ChatEntryStatus.roomReady,
          roomId: 'room-123',
          isPublic: false,
        );

        expect(context1, equals(context2));
        expect(context1.hashCode, equals(context2.hashCode));
      });

      test('should not be equal when status differs', () {
        const context1 = ChatEntryContext(
          status: ChatEntryStatus.roomReady,
        );
        const context2 = ChatEntryContext(
          status: ChatEntryStatus.requestPending,
        );

        expect(context1, isNot(equals(context2)));
      });

      test('should not be equal when roomId differs', () {
        const context1 = ChatEntryContext(
          status: ChatEntryStatus.roomReady,
          roomId: 'room-123',
        );
        const context2 = ChatEntryContext(
          status: ChatEntryStatus.roomReady,
          roomId: 'room-456',
        );

        expect(context1, isNot(equals(context2)));
      });

      test('should return identical for same instance', () {
        const context = ChatEntryContext(status: ChatEntryStatus.roomReady);
        expect(context == context, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        const context = ChatEntryContext(
          status: ChatEntryStatus.roomReady,
          roomId: 'room-123',
          requestId: 'req-456',
        );

        final result = context.toString();

        expect(result, contains('roomReady'));
        expect(result, contains('room-123'));
        expect(result, contains('req-456'));
      });
    });
  });
}
