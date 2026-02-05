/// Tests for MarketplaceConversation entity.
///
/// Verifies creation, fromJson, equality, hasUnread, copyWith, and toString.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_conversation.dart';

void main() {
  // Shared test data
  final now = DateTime(2026, 2, 4, 10, 0);

  MarketplaceConversation createConversation({
    String listingId = 'listing-1',
    String listingTitle = 'Beautiful Dress',
    String? listingCoverUrl = 'https://example.com/cover.jpg',
    String otherUserId = 'user-2',
    String otherUserName = 'Alice',
    String? otherUserAvatarUrl,
    String? lastMessage = 'Is this still available?',
    DateTime? lastMessageTime,
    int unreadCount = 0,
  }) {
    return MarketplaceConversation(
      listingId: listingId,
      listingTitle: listingTitle,
      listingCoverUrl: listingCoverUrl,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserAvatarUrl: otherUserAvatarUrl,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime ?? now,
      unreadCount: unreadCount,
    );
  }

  group('MarketplaceConversation', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create with required fields', () {
        final conversation = createConversation();

        expect(conversation.listingId, 'listing-1');
        expect(conversation.listingTitle, 'Beautiful Dress');
        expect(conversation.listingCoverUrl, 'https://example.com/cover.jpg');
        expect(conversation.otherUserId, 'user-2');
        expect(conversation.otherUserName, 'Alice');
        expect(conversation.otherUserAvatarUrl, isNull);
        expect(conversation.lastMessage, 'Is this still available?');
        expect(conversation.lastMessageTime, now);
        expect(conversation.unreadCount, 0);
      });

      test('should allow null optional fields', () {
        final conversation = MarketplaceConversation(
          listingId: 'listing-1',
          listingTitle: 'Dress',
          otherUserId: 'user-2',
          otherUserName: 'Alice',
        );

        expect(conversation.listingCoverUrl, isNull);
        expect(conversation.otherUserAvatarUrl, isNull);
        expect(conversation.lastMessage, isNull);
        expect(conversation.lastMessageTime, isNull);
        expect(conversation.unreadCount, 0);
      });
    });

    // ==============================================================
    // HASUNREAD TESTS
    // ==============================================================

    group('hasUnread', () {
      test('should return false when unreadCount is 0', () {
        final conversation = createConversation(unreadCount: 0);
        expect(conversation.hasUnread, isFalse);
      });

      test('should return true when unreadCount is greater than 0', () {
        final conversation = createConversation(unreadCount: 3);
        expect(conversation.hasUnread, isTrue);
      });

      test('should return true when unreadCount is 1', () {
        final conversation = createConversation(unreadCount: 1);
        expect(conversation.hasUnread, isTrue);
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse valid JSON with all fields', () {
        final json = {
          'listing_id': 'listing-abc',
          'listing_title': 'Wedding Shoes',
          'listing_cover_url': 'https://example.com/shoes.jpg',
          'other_user_id': 'user-xyz',
          'other_user_name': 'Bob',
          'other_user_avatar_url': 'https://example.com/avatar.jpg',
          'last_message': 'Sounds good!',
          'last_message_time': '2026-02-04T10:00:00.000Z',
          'unread_count': 5,
        };

        final conversation = MarketplaceConversation.fromJson(json);

        expect(conversation.listingId, 'listing-abc');
        expect(conversation.listingTitle, 'Wedding Shoes');
        expect(conversation.listingCoverUrl, 'https://example.com/shoes.jpg');
        expect(conversation.otherUserId, 'user-xyz');
        expect(conversation.otherUserName, 'Bob');
        expect(
          conversation.otherUserAvatarUrl,
          'https://example.com/avatar.jpg',
        );
        expect(conversation.lastMessage, 'Sounds good!');
        expect(
          conversation.lastMessageTime,
          DateTime.parse('2026-02-04T10:00:00.000Z'),
        );
        expect(conversation.unreadCount, 5);
      });

      test('should handle null optional fields', () {
        final json = {
          'listing_id': 'listing-abc',
          'listing_title': 'Dress',
          'listing_cover_url': null,
          'other_user_id': 'user-xyz',
          'other_user_name': 'Carol',
          'other_user_avatar_url': null,
          'last_message': null,
          'last_message_time': null,
          'unread_count': null,
        };

        final conversation = MarketplaceConversation.fromJson(json);

        expect(conversation.listingCoverUrl, isNull);
        expect(conversation.otherUserAvatarUrl, isNull);
        expect(conversation.lastMessage, isNull);
        expect(conversation.lastMessageTime, isNull);
        expect(conversation.unreadCount, 0);
      });

      test('should default unreadCount to 0 when missing', () {
        final json = {
          'listing_id': 'listing-1',
          'listing_title': 'Dress',
          'other_user_id': 'user-1',
          'other_user_name': 'Dan',
        };

        final conversation = MarketplaceConversation.fromJson(json);

        expect(conversation.unreadCount, 0);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when listingId and otherUserId are the same', () {
        final c1 = createConversation(
          listingId: 'listing-1',
          otherUserId: 'user-2',
        );
        final c2 = createConversation(
          listingId: 'listing-1',
          otherUserId: 'user-2',
          lastMessage: 'Different message',
          unreadCount: 5,
        );

        expect(c1, equals(c2));
      });

      test('should have consistent hashCode', () {
        final c1 = createConversation(
          listingId: 'listing-1',
          otherUserId: 'user-2',
        );
        final c2 = createConversation(
          listingId: 'listing-1',
          otherUserId: 'user-2',
          unreadCount: 10,
        );

        expect(c1.hashCode, equals(c2.hashCode));
      });

      test('should not be equal when listingId differs', () {
        final c1 = createConversation(listingId: 'listing-1');
        final c2 = createConversation(listingId: 'listing-2');

        expect(c1, isNot(equals(c2)));
      });

      test('should not be equal when otherUserId differs', () {
        final c1 = createConversation(otherUserId: 'user-1');
        final c2 = createConversation(otherUserId: 'user-2');

        expect(c1, isNot(equals(c2)));
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should create copy with updated unreadCount', () {
        final original = createConversation(unreadCount: 3);
        final updated = original.copyWith(unreadCount: 0);

        expect(updated.unreadCount, 0);
        expect(updated.listingId, original.listingId);
        expect(updated.otherUserId, original.otherUserId);
      });

      test('should preserve all fields when no parameter provided', () {
        final original = createConversation();
        final copied = original.copyWith();

        expect(copied.listingId, original.listingId);
        expect(copied.listingTitle, original.listingTitle);
        expect(copied.listingCoverUrl, original.listingCoverUrl);
        expect(copied.otherUserId, original.otherUserId);
        expect(copied.otherUserName, original.otherUserName);
        expect(copied.lastMessage, original.lastMessage);
        expect(copied.lastMessageTime, original.lastMessageTime);
        expect(copied.unreadCount, original.unreadCount);
      });

      test('should update lastMessage', () {
        final original = createConversation(lastMessage: 'Old');
        final updated = original.copyWith(lastMessage: 'New');

        expect(updated.lastMessage, 'New');
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should contain listing and user info', () {
        final conversation = createConversation(
          listingId: 'listing-abc',
          otherUserId: 'user-xyz',
        );

        final str = conversation.toString();

        expect(str, contains('listing-abc'));
        expect(str, contains('user-xyz'));
      });
    });
  });
}
