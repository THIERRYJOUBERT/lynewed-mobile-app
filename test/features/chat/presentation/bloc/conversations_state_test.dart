import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/chat/domain/entities/conversation.dart';
import 'package:lynewed_beta/features/chat/domain/entities/chat_enums.dart';
import 'package:lynewed_beta/features/chat/presentation/bloc/conversations_state.dart';

void main() {
  // Helper to create conversations with minimal fields
  Conversation makeConversation({
    required String roomId,
    RoomType roomType = RoomType.private,
    ConversationStatus status = ConversationStatus.active,
    int unreadCount = 0,
  }) {
    return Conversation(
      roomId: roomId,
      roomType: roomType,
      conversationStatus: status,
      unreadCount: unreadCount,
    );
  }

  group('ConversationsLoaded', () {
    // ==============================================================
    // FILTERED GETTERS
    // ==============================================================

    group('activeConversations', () {
      test('should include active, pending, and reported conversations', () {
        final state = ConversationsLoaded(
          conversations: [
            makeConversation(roomId: '1', status: ConversationStatus.active),
            makeConversation(roomId: '2', status: ConversationStatus.pending),
            makeConversation(roomId: '3', status: ConversationStatus.reportedPending),
            makeConversation(roomId: '4', status: ConversationStatus.archived),
            makeConversation(roomId: '5', status: ConversationStatus.blocked),
          ],
          pendingRequests: [],
          blockedUsers: [],
        );

        expect(state.activeConversations.length, 3);
        expect(state.activeConversations.map((c) => c.roomId), ['1', '2', '3']);
      });

      test('should exclude archived and blocked conversations', () {
        final state = ConversationsLoaded(
          conversations: [
            makeConversation(roomId: '1', status: ConversationStatus.archived),
            makeConversation(roomId: '2', status: ConversationStatus.blocked),
          ],
          pendingRequests: [],
          blockedUsers: [],
        );

        expect(state.activeConversations, isEmpty);
      });
    });

    group('privateConversations', () {
      test('should only return private room type conversations', () {
        final state = ConversationsLoaded(
          conversations: [
            makeConversation(roomId: '1', roomType: RoomType.private),
            makeConversation(roomId: '2', roomType: RoomType.weddingTeam),
            makeConversation(roomId: '3', roomType: RoomType.private),
            makeConversation(roomId: '4', roomType: RoomType.weddingGroupPublic),
          ],
          pendingRequests: [],
          blockedUsers: [],
        );

        expect(state.privateConversations.length, 2);
        expect(state.privateConversations.map((c) => c.roomId), ['1', '3']);
      });

      test('should exclude archived private conversations', () {
        final state = ConversationsLoaded(
          conversations: [
            makeConversation(roomId: '1', roomType: RoomType.private, status: ConversationStatus.active),
            makeConversation(roomId: '2', roomType: RoomType.private, status: ConversationStatus.archived),
          ],
          pendingRequests: [],
          blockedUsers: [],
        );

        expect(state.privateConversations.length, 1);
        expect(state.privateConversations.first.roomId, '1');
      });
    });

    group('weddingConversations', () {
      test('should return all wedding group types', () {
        final state = ConversationsLoaded(
          conversations: [
            makeConversation(roomId: '1', roomType: RoomType.private),
            makeConversation(roomId: '2', roomType: RoomType.weddingTeam),
            makeConversation(roomId: '3', roomType: RoomType.weddingGroupPublic),
            makeConversation(roomId: '4', roomType: RoomType.weddingGroupPrivate),
            makeConversation(roomId: '5', roomType: RoomType.public),
          ],
          pendingRequests: [],
          blockedUsers: [],
        );

        expect(state.weddingConversations.length, 3);
        expect(state.weddingConversations.map((c) => c.roomId), ['2', '3', '4']);
      });

      test('should return empty list when no wedding groups exist', () {
        final state = ConversationsLoaded(
          conversations: [
            makeConversation(roomId: '1', roomType: RoomType.private),
          ],
          pendingRequests: [],
          blockedUsers: [],
        );

        expect(state.weddingConversations, isEmpty);
      });

      test('should exclude archived wedding conversations', () {
        final state = ConversationsLoaded(
          conversations: [
            makeConversation(roomId: '1', roomType: RoomType.weddingTeam, status: ConversationStatus.active),
            makeConversation(roomId: '2', roomType: RoomType.weddingTeam, status: ConversationStatus.archived),
          ],
          pendingRequests: [],
          blockedUsers: [],
        );

        expect(state.weddingConversations.length, 1);
        expect(state.weddingConversations.first.roomId, '1');
      });
    });

    // ==============================================================
    // UNREAD COUNTS
    // ==============================================================

    group('unread counts', () {
      test('privateUnreadCount should sum unread from private conversations only', () {
        final state = ConversationsLoaded(
          conversations: [
            makeConversation(roomId: '1', roomType: RoomType.private, unreadCount: 3),
            makeConversation(roomId: '2', roomType: RoomType.private, unreadCount: 5),
            makeConversation(roomId: '3', roomType: RoomType.weddingTeam, unreadCount: 10),
          ],
          pendingRequests: [],
          blockedUsers: [],
        );

        expect(state.privateUnreadCount, 8);
      });

      test('weddingUnreadCount should sum unread from wedding conversations only', () {
        final state = ConversationsLoaded(
          conversations: [
            makeConversation(roomId: '1', roomType: RoomType.private, unreadCount: 3),
            makeConversation(roomId: '2', roomType: RoomType.weddingTeam, unreadCount: 5),
            makeConversation(roomId: '3', roomType: RoomType.weddingGroupPublic, unreadCount: 2),
            makeConversation(roomId: '4', roomType: RoomType.weddingGroupPrivate, unreadCount: 1),
          ],
          pendingRequests: [],
          blockedUsers: [],
        );

        expect(state.weddingUnreadCount, 8);
      });

      test('totalUnreadCount should sum all active conversations', () {
        final state = ConversationsLoaded(
          conversations: [
            makeConversation(roomId: '1', roomType: RoomType.private, unreadCount: 3),
            makeConversation(roomId: '2', roomType: RoomType.weddingTeam, unreadCount: 5),
            makeConversation(roomId: '3', roomType: RoomType.private, unreadCount: 2, status: ConversationStatus.archived),
          ],
          pendingRequests: [],
          blockedUsers: [],
        );

        // Archived is excluded from activeConversations
        expect(state.totalUnreadCount, 8);
      });

      test('should return 0 when no unread messages', () {
        final state = ConversationsLoaded(
          conversations: [
            makeConversation(roomId: '1', roomType: RoomType.private, unreadCount: 0),
            makeConversation(roomId: '2', roomType: RoomType.weddingTeam, unreadCount: 0),
          ],
          pendingRequests: [],
          blockedUsers: [],
        );

        expect(state.privateUnreadCount, 0);
        expect(state.weddingUnreadCount, 0);
        expect(state.totalUnreadCount, 0);
      });
    });

    // ==============================================================
    // ARCHIVED CONVERSATIONS
    // ==============================================================

    group('archivedConversations', () {
      test('should include archived and blocked conversations', () {
        final state = ConversationsLoaded(
          conversations: [
            makeConversation(roomId: '1', status: ConversationStatus.active),
            makeConversation(roomId: '2', status: ConversationStatus.archived),
            makeConversation(roomId: '3', status: ConversationStatus.blocked),
          ],
          pendingRequests: [],
          blockedUsers: [],
        );

        expect(state.archivedConversations.length, 2);
        expect(state.hasArchivedConversations, true);
      });
    });

    // ==============================================================
    // COPYWITH
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final state = ConversationsLoaded(
          conversations: [makeConversation(roomId: '1')],
          pendingRequests: [],
          blockedUsers: [],
          isRefreshing: true,
        );

        final copied = state.copyWith(isRefreshing: false);

        expect(copied.conversations.length, 1);
        expect(copied.isRefreshing, false);
      });
    });
  });

  // ==============================================================
  // STATE CLASSES
  // ==============================================================

  group('ConversationsState classes', () {
    test('ConversationsInitial should be a ConversationsState', () {
      const state = ConversationsInitial();
      expect(state, isA<ConversationsState>());
    });

    test('ConversationsLoading should be a ConversationsState', () {
      const state = ConversationsLoading();
      expect(state, isA<ConversationsState>());
    });

    test('ConversationsError should contain message', () {
      const state = ConversationsError('Something went wrong');
      expect(state, isA<ConversationsState>());
      expect(state.message, 'Something went wrong');
    });
  });
}
