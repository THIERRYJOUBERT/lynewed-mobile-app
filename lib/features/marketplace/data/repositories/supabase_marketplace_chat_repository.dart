/// Supabase implementation of MarketplaceChatRepository.
///
/// Handles messaging between buyers and sellers using Supabase Database
/// and Realtime for live updates.
library;

import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/marketplace_conversation.dart';
import '../../domain/entities/marketplace_message.dart';
import '../../domain/repositories/marketplace_chat_repository.dart';

/// Supabase-backed implementation of [MarketplaceChatRepository].
///
/// Uses the `marketplace_messages` table and Supabase Realtime for
/// live message delivery. Conversations are derived client-side by
/// grouping messages by (listing_id, other_user_id).
class SupabaseMarketplaceChatRepository implements MarketplaceChatRepository {
  /// Creates a repository with the given Supabase client.
  SupabaseMarketplaceChatRepository(this._client);

  final SupabaseClient _client;

  RealtimeChannel? _channel;
  StreamController<MarketplaceMessage>? _streamController;

  @override
  Future<MarketplaceMessage> sendMessage({
    required String listingId,
    required String receiverId,
    required String content,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw StateError('User must be authenticated to send messages');
    }

    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw ArgumentError('Message content cannot be empty');
    }

    final response = await _client
        .from('marketplace_messages')
        .insert({
          'listing_id': listingId,
          'sender_id': currentUserId,
          'receiver_id': receiverId,
          'content': trimmedContent,
          'is_read': false,
        })
        .select()
        .single();

    return MarketplaceMessage.fromJson(response);
  }

  @override
  Future<List<MarketplaceMessage>> getMessages({
    required String listingId,
    required String otherUserId,
    int limit = 100,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw StateError('User must be authenticated to get messages');
    }

    // Get messages where (sender=me AND receiver=other) OR
    // (sender=other AND receiver=me) for this listing.
    final response = await _client
        .from('marketplace_messages')
        .select()
        .eq('listing_id', listingId)
        .or('and(sender_id.eq.$currentUserId,receiver_id.eq.$otherUserId),'
            'and(sender_id.eq.$otherUserId,receiver_id.eq.$currentUserId)')
        .order('created_at', ascending: true)
        .limit(limit);

    return (response as List)
        .map((json) => MarketplaceMessage.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Stream<MarketplaceMessage> subscribeToMessages({
    required String listingId,
    required String currentUserId,
  }) {
    // Clean up previous subscription if any.
    _streamController?.close();
    _channel?.unsubscribe();

    _streamController = StreamController<MarketplaceMessage>.broadcast();

    _channel = _client
        .channel('marketplace-chat-$listingId-$currentUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'marketplace_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'listing_id',
            value: listingId,
          ),
          callback: (payload) {
            try {
              final message =
                  MarketplaceMessage.fromJson(payload.newRecord);
              // Only emit if message involves the current user.
              if (message.senderId == currentUserId ||
                  message.receiverId == currentUserId) {
                _streamController?.add(message);
              }
            } catch (e) {
              _streamController?.addError(e);
            }
          },
        )
        .subscribe();

    return _streamController!.stream;
  }

  @override
  Future<void> markConversationAsRead({
    required String listingId,
    required String otherUserId,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return;

    await _client
        .from('marketplace_messages')
        .update({'is_read': true})
        .eq('listing_id', listingId)
        .eq('receiver_id', currentUserId)
        .eq('sender_id', otherUserId)
        .eq('is_read', false);
  }

  @override
  Future<List<MarketplaceConversation>> getConversations() async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw StateError('User must be authenticated to get conversations');
    }

    // Fetch all messages involving the current user, most recent first.
    final response = await _client
        .from('marketplace_messages')
        .select('*, marketplace_listings!inner(title, id)')
        .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
        .order('created_at', ascending: false);

    final messages = (response as List)
        .map((json) => json as Map<String, dynamic>)
        .toList();

    if (messages.isEmpty) return [];

    // Group messages by (listing_id, other_user_id).
    final conversationMap = <String, _ConversationData>{};

    for (final msg in messages) {
      final listingId = msg['listing_id'] as String;
      final senderId = msg['sender_id'] as String;
      final receiverId = msg['receiver_id'] as String;
      final otherUserId =
          senderId == currentUserId ? receiverId : senderId;
      final key = '$listingId|$otherUserId';

      if (!conversationMap.containsKey(key)) {
        // Extract listing title from join.
        final listingData =
            msg['marketplace_listings'] as Map<String, dynamic>?;
        final listingTitle = listingData?['title'] as String? ?? 'Listing';

        conversationMap[key] = _ConversationData(
          listingId: listingId,
          listingTitle: listingTitle,
          otherUserId: otherUserId,
          lastMessage: msg['content'] as String?,
          lastMessageTime: msg['created_at'] != null
              ? DateTime.parse(msg['created_at'] as String)
              : null,
          unreadCount: 0,
        );
      }

      // Count unread messages (where current user is receiver and not read).
      if (msg['receiver_id'] == currentUserId &&
          msg['is_read'] == false) {
        conversationMap[key]!.unreadCount++;
      }
    }

    // Batch-fetch profile names for all other users.
    final otherUserIds = conversationMap.values
        .map((c) => c.otherUserId)
        .toSet()
        .toList();

    final profilesResponse = await _client
        .from('profiles')
        .select('id, display_name, photo_url')
        .inFilter('id', otherUserIds);

    final profilesMap = <String, Map<String, dynamic>>{};
    for (final profile in profilesResponse as List) {
      final p = profile as Map<String, dynamic>;
      profilesMap[p['id'] as String] = p;
    }

    // Build conversation list sorted by most recent message.
    final conversations = conversationMap.values.map((data) {
      final profile = profilesMap[data.otherUserId];
      return MarketplaceConversation(
        listingId: data.listingId,
        listingTitle: data.listingTitle,
        otherUserId: data.otherUserId,
        otherUserName:
            profile?['display_name'] as String? ?? 'Unknown',
        otherUserAvatarUrl: profile?['photo_url'] as String?,
        lastMessage: data.lastMessage,
        lastMessageTime: data.lastMessageTime,
        unreadCount: data.unreadCount,
      );
    }).toList();

    // Sort by most recent message time (descending).
    conversations.sort((a, b) {
      if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
      if (a.lastMessageTime == null) return 1;
      if (b.lastMessageTime == null) return -1;
      return b.lastMessageTime!.compareTo(a.lastMessageTime!);
    });

    return conversations;
  }

  @override
  void unsubscribeAll() {
    _channel?.unsubscribe();
    _channel = null;
    _streamController?.close();
    _streamController = null;
  }
}

/// Internal helper for grouping conversation data before building entities.
class _ConversationData {
  _ConversationData({
    required this.listingId,
    required this.listingTitle,
    required this.otherUserId,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
  });

  final String listingId;
  final String listingTitle;
  final String otherUserId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  int unreadCount;
}
