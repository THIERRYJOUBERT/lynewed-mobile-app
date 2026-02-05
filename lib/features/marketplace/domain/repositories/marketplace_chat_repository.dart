/// Repository interface for marketplace chat operations.
///
/// Provides methods for sending and receiving messages between buyers
/// and sellers in marketplace conversations.
library;

import '../entities/marketplace_conversation.dart';
import '../entities/marketplace_message.dart';

/// Abstract repository for marketplace chat.
///
/// Implementations handle data source communication (e.g., Supabase).
/// All methods involving the current user derive it from the auth session.
abstract class MarketplaceChatRepository {
  /// Sends a message in a conversation.
  ///
  /// Creates a new message from the current user to [receiverId]
  /// about a listing identified by [listingId].
  /// Returns the created message with server-generated fields.
  Future<MarketplaceMessage> sendMessage({
    required String listingId,
    required String receiverId,
    required String content,
  });

  /// Gets messages for a conversation.
  ///
  /// Returns messages between the current user and [otherUserId]
  /// about listing [listingId], ordered by creation date (oldest first).
  /// [limit] defaults to 100 messages.
  Future<List<MarketplaceMessage>> getMessages({
    required String listingId,
    required String otherUserId,
    int limit = 100,
  });

  /// Subscribes to new messages in a conversation via Realtime.
  ///
  /// Returns a stream of new messages as they arrive.
  /// Only emits messages involving [currentUserId].
  Stream<MarketplaceMessage> subscribeToMessages({
    required String listingId,
    required String currentUserId,
  });

  /// Marks all unread messages from [otherUserId] as read.
  ///
  /// Updates is_read=true for messages where the current user is
  /// the receiver and [otherUserId] is the sender.
  Future<void> markConversationAsRead({
    required String listingId,
    required String otherUserId,
  });

  /// Gets all conversations for the current user.
  ///
  /// Returns conversations grouped by listing, sorted by most recent message.
  Future<List<MarketplaceConversation>> getConversations();

  /// Unsubscribes from all Realtime channels.
  ///
  /// Call this in dispose() to clean up subscriptions.
  void unsubscribeAll();
}
