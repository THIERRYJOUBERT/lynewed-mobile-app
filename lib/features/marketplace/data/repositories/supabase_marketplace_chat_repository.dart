/// Supabase implementation of MarketplaceChatRepository.
///
/// Handles messaging between buyers and sellers using Supabase Database,
/// Storage, and Realtime for live updates.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  /// Storage bucket for marketplace chat attachments.
  static const _storageBucket = 'marketplace-chat';

  RealtimeChannel? _channel;
  StreamController<MarketplaceMessage>? _streamController;

  @override
  Future<MarketplaceMessage> sendMessage({
    required String listingId,
    required String receiverId,
    required String content,
    String messageType = 'text',
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    String? attachmentMimeType,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw StateError('User must be authenticated to send messages');
    }

    final trimmedContent = content.trim();
    // Allow empty content for attachment-only messages.
    if (trimmedContent.isEmpty && messageType == 'text') {
      throw ArgumentError('Message content cannot be empty');
    }

    final data = <String, dynamic>{
      'listing_id': listingId,
      'sender_id': currentUserId,
      'receiver_id': receiverId,
      'content': trimmedContent,
      'is_read': false,
      'message_type': messageType,
    };

    if (attachmentUrl != null) data['attachment_url'] = attachmentUrl;
    if (attachmentName != null) data['attachment_name'] = attachmentName;
    if (attachmentSize != null) data['attachment_size'] = attachmentSize;
    if (attachmentMimeType != null) {
      data['attachment_mime_type'] = attachmentMimeType;
    }

    final response = await _client
        .from('marketplace_messages')
        .insert(data)
        .select()
        .single();

    return MarketplaceMessage.fromJson(response);
  }

  @override
  Future<String> uploadAttachment({
    required String filePath,
    required String fileName,
    required String listingId,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw StateError('User must be authenticated to upload attachments');
    }

    final file = File(filePath);
    if (!file.existsSync()) {
      throw ArgumentError('File does not exist: $filePath');
    }

    // Storage path: {listingId}/{userId}/{timestamp}_{fileName}
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = '$listingId/$currentUserId/${timestamp}_$fileName';

    await _client.storage.from(_storageBucket).upload(storagePath, file);

    return storagePath;
  }

  @override
  Future<String?> getSignedUrl(String storagePath) async {
    try {
      final url = await _client.storage
          .from(_storageBucket)
          .createSignedUrl(storagePath, 3600); // 1 hour
      return url;
    } catch (e) {
      return null;
    }
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
        .map(
            (json) => MarketplaceMessage.fromJson(json as Map<String, dynamic>))
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
              final message = MarketplaceMessage.fromJson(payload.newRecord);
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
      final otherUserId = senderId == currentUserId ? receiverId : senderId;
      final key = '$listingId|$otherUserId';

      if (!conversationMap.containsKey(key)) {
        // Extract listing title from join.
        final listingData =
            msg['marketplace_listings'] as Map<String, dynamic>?;
        final listingTitle = listingData?['title'] as String? ?? 'Listing';

        // Generate appropriate preview text based on message type.
        final messageType = msg['message_type'] as String? ?? 'text';
        String? preview;
        if (messageType == 'offer') {
          preview = _offerPreview(msg['content'] as String?);
        } else if (messageType == 'system') {
          preview = msg['content'] as String?;
        } else {
          preview = msg['content'] as String?;
        }

        conversationMap[key] = _ConversationData(
          listingId: listingId,
          listingTitle: listingTitle,
          otherUserId: otherUserId,
          lastMessage: preview,
          lastMessageTime: msg['created_at'] != null
              ? DateTime.parse(msg['created_at'] as String)
              : null,
          unreadCount: 0,
        );
      }

      // Count unread messages (where current user is receiver and not read).
      if (msg['receiver_id'] == currentUserId && msg['is_read'] == false) {
        conversationMap[key]!.unreadCount++;
      }
    }

    // Batch-fetch profile names for all other users.
    final otherUserIds =
        conversationMap.values.map((c) => c.otherUserId).toSet().toList();

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
        otherUserName: profile?['display_name'] as String? ?? 'Unknown',
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
  Future<MarketplaceMessage> sendOfferMessage({
    required String listingId,
    required String receiverId,
    required String offerId,
    required int amountCents,
    String? message,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw StateError('User must be authenticated to send messages');
    }

    final contentJson = jsonEncode({
      'amount_cents': amountCents,
      if (message != null && message.isNotEmpty) 'message': message,
    });

    final response = await _client
        .from('marketplace_messages')
        .insert({
          'listing_id': listingId,
          'sender_id': currentUserId,
          'receiver_id': receiverId,
          'content': contentJson,
          'is_read': false,
          'message_type': 'offer',
          'offer_id': offerId,
        })
        .select()
        .single();

    return MarketplaceMessage.fromJson(response);
  }

  @override
  Future<MarketplaceMessage> sendSystemMessage({
    required String listingId,
    required String receiverId,
    required String content,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw StateError('User must be authenticated to send messages');
    }

    final response = await _client
        .from('marketplace_messages')
        .insert({
          'listing_id': listingId,
          'sender_id': currentUserId,
          'receiver_id': receiverId,
          'content': content,
          'is_read': false,
          'message_type': 'system',
        })
        .select()
        .single();

    return MarketplaceMessage.fromJson(response);
  }

  @override
  void unsubscribeAll() {
    _channel?.unsubscribe();
    _channel = null;
    _streamController?.close();
    _streamController = null;
  }

  /// Extracts a human-readable preview from offer message JSON content.
  String _offerPreview(String? content) {
    if (content == null || content.isEmpty) return 'Offer';
    try {
      final data = jsonDecode(content) as Map<String, dynamic>;
      final cents = data['amount_cents'] as int? ?? 0;
      final dollars = (cents / 100).toStringAsFixed(2);
      return 'Offer: \$$dollars';
    } catch (_) {
      return 'Offer';
    }
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
