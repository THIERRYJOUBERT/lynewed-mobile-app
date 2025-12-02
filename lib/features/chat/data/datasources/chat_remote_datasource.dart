/// Chat remote datasource - Clean Architecture
/// 
/// Handles all Supabase operations for chat module.
library;

import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/entities.dart';

/// Remote datasource for chat operations
class ChatRemoteDatasource {
  ChatRemoteDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final Map<String, RealtimeChannel> _subscriptions = {};

  String get _currentUserId => _client.auth.currentUser?.id ?? '';

  // ============================================================
  // CONVERSATIONS
  // ============================================================

  /// Get all conversations for current user
  Future<List<Conversation>> getConversations() async {
    final response = await _client.rpc('get_rooms_with_unread_counts');
    
    if (response == null) return [];
    
    final List<dynamic> data = response as List<dynamic>;
    return data
        .map((item) => Conversation.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Get public chat rooms for brides
  Future<List<Conversation>> getPublicChatRooms() async {
    final response = await _client.rpc('get_public_chat_rooms_for_brides');
    
    if (response == null) return [];
    
    final List<dynamic> data = response as List<dynamic>;
    return data
        .map((item) => Conversation.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Archive a conversation
  Future<void> archiveConversation(String roomId) async {
    await _client
        .from('chat_room_participants')
        .update({'conversation_status': 'archived'})
        .eq('room_id', roomId)
        .eq('profile_id', _currentUserId);
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  /// Get messages for a room with pagination
  Future<List<ChatMessage>> getMessages({
    required String roomId,
    int limit = 50,
    int? beforeId,
  }) async {
    var query = _client
        .from('chat_messages')
        .select()
        .eq('room_id', roomId)
        .eq('is_deleted', false);

    if (beforeId != null) {
      query = query.lt('id', beforeId);
    }

    final response = await query
        .order('id', ascending: false)
        .limit(limit);
    
    return (response as List<dynamic>)
        .map((item) => ChatMessage.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Send a message
  Future<ChatMessage> sendMessage({
    required String roomId,
    required MessageType type,
    String? content,
    String? attachmentUrl,
  }) async {
    final response = await _client
        .from('chat_messages')
        .insert({
          'room_id': roomId,
          'profile_id': _currentUserId,
          'content': content,
          'message_type': type.name,
          'attachment_url': attachmentUrl,
        })
        .select()
        .single();

    return ChatMessage.fromMap(response);
  }

  /// Delete own message (soft delete)
  Future<void> deleteMessage(int messageId) async {
    await _client
        .from('chat_messages')
        .update({'is_deleted': true})
        .eq('id', messageId)
        .eq('profile_id', _currentUserId);
  }

  /// Update last_read_at for current user in room
  Future<void> markRoomAsRead(String roomId) async {
    await _client
        .from('chat_room_participants')
        .update({'last_read_at': DateTime.now().toIso8601String()})
        .eq('room_id', roomId)
        .eq('profile_id', _currentUserId);
  }

  // ============================================================
  // REALTIME
  // ============================================================

  /// Subscribe to new messages in a room
  Stream<ChatMessage> subscribeToMessages(String roomId) {
    final controller = StreamController<ChatMessage>.broadcast();

    // Unsubscribe from previous subscription if exists
    _subscriptions[roomId]?.unsubscribe();

    final channel = _client
        .channel('chat_messages:$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            final message = ChatMessage.fromMap(payload.newRecord);
            controller.add(message);
          },
        )
        .subscribe();

    _subscriptions[roomId] = channel;

    controller.onCancel = () {
      channel.unsubscribe();
      _subscriptions.remove(roomId);
    };

    return controller.stream;
  }

  /// Dispose all subscriptions
  void disposeSubscriptions() {
    for (final channel in _subscriptions.values) {
      channel.unsubscribe();
    }
    _subscriptions.clear();
  }

  // ============================================================
  // CONTACT CONTEXT
  // ============================================================

  /// Prepare contact context
  Future<ChatEntryContext> prepareContactContext(String targetProfileId) async {
    final response = await _client.rpc(
      'open_or_prepare_contact_context',
      params: {'p_target': targetProfileId},
    );

    if (response == null) {
      return ChatEntryContext.error('No response from server');
    }

    return ChatEntryContext.fromMap(response as Map<String, dynamic>);
  }

  // ============================================================
  // CONTACT REQUESTS
  // ============================================================

  /// Create a contact request (Pro → Bride)
  Future<String> createContactRequest({
    required String targetId,
    required ContactRequestSource source,
    required String message,
  }) async {
    final response = await _client.rpc(
      'create_contact_request',
      params: {
        'p_target_id': targetId,
        'p_source': source.name,
        'p_message': message,
      },
    );

    final result = response as Map<String, dynamic>;
    if (result['status'] != 'ok') {
      throw Exception(result['reason'] ?? 'Unknown error');
    }

    return result['requestId'] as String;
  }

  /// Get pending contact requests for current user
  Future<List<ContactRequest>> getPendingContactRequests() async {
    final response = await _client.rpc('get_pending_contact_requests');
    
    if (response == null) return [];
    
    final List<dynamic> data = response as List<dynamic>;
    return data
        .map((item) => ContactRequest.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Accept a contact request
  Future<String> acceptContactRequest(String requestId) async {
    final response = await _client.rpc(
      'accept_connection_request',
      params: {'p_request_id': requestId},
    );

    final result = response as Map<String, dynamic>;
    if (result['status'] != 'ok') {
      throw Exception(result['reason'] ?? 'Unknown error');
    }

    return result['roomId'] as String;
  }

  /// Decline a contact request
  Future<void> declineContactRequest(String requestId) async {
    final response = await _client.rpc(
      'decline_connection_request',
      params: {'p_request_id': requestId},
    );

    final result = response as Map<String, dynamic>;
    if (result['status'] != 'ok') {
      throw Exception(result['reason'] ?? 'Unknown error');
    }
  }

  // ============================================================
  // BLOCKING
  // ============================================================

  /// Block a user
  Future<void> blockUser(String profileId) async {
    await _client.from('user_blocks').upsert({
      'blocker_profile_id': _currentUserId,
      'blocked_profile_id': profileId,
    });

    // Create support ticket for CRM tracking (audit section 5.2)
    await _client.from('support_tickets').insert({
      'profile_id': _currentUserId,
      'subject': '[BLOCK] Utilisateur bloqué',
      'message': 'Blocker: $_currentUserId\nBlocked: $profileId',
      'status': 'pending',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Unblock a user
  Future<void> unblockUser(String profileId) async {
    await _client
        .from('user_blocks')
        .delete()
        .eq('blocker_profile_id', _currentUserId)
        .eq('blocked_profile_id', profileId);
  }

  /// Get list of blocked users with profile info
  Future<List<BlockedUser>> getBlockedUsers() async {
    final response = await _client
        .from('user_blocks')
        .select('''
          blocked_profile_id,
          created_at,
          profiles!user_blocks_blocked_profile_id_fkey (
            full_name,
            avatar_url,
            role
          )
        ''')
        .eq('blocker_profile_id', _currentUserId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((item) {
      final map = item as Map<String, dynamic>;
      final profile = map['profiles'] as Map<String, dynamic>?;
      return BlockedUser(
        blockedProfileId: map['blocked_profile_id'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        fullName: profile?['full_name'] as String?,
        avatarUrl: profile?['avatar_url'] as String?,
        role: UserRole.fromString(profile?['role'] as String?),
      );
    }).toList();
  }

  /// Check if a user is blocked
  Future<bool> isUserBlocked(String profileId) async {
    final response = await _client
        .from('user_blocks')
        .select('blocked_profile_id')
        .eq('blocker_profile_id', _currentUserId)
        .eq('blocked_profile_id', profileId)
        .maybeSingle();

    return response != null;
  }

  // ============================================================
  // REPORTING
  // ============================================================

  /// Report a message
  Future<void> reportMessage({
    required int messageId,
    required ReportReason reason,
    String? details,
  }) async {
    // Insert report (trigger will mark message as deleted)
    await _client.from('reports').insert({
      'reporter_profile_id': _currentUserId,
      'reported_message_id': messageId,
      'reason': '${reason.toBackendValue()}${details != null ? ': $details' : ''}',
    });

    // Create support ticket
    await _client.from('support_tickets').insert({
      'profile_id': _currentUserId,
      'subject': '[REPORT] Message signalé',
      'message': 'Raison: ${reason.displayLabel}\n${details ?? ''}\nMessage ID: $messageId',
      'status': 'pending',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ============================================================
  // MEDIA
  // ============================================================

  /// Upload image to chat storage
  Future<String> uploadImage({
    required String roomId,
    required String filePath,
    required String fileName,
  }) async {
    final file = File(filePath);
    final path = '$roomId/$fileName';
    
    await _client.storage.from('chat_images').upload(path, file);
    
    return path;
  }

  /// Upload audio to chat storage
  Future<String> uploadAudio({
    required String roomId,
    required String filePath,
    required String fileName,
  }) async {
    final file = File(filePath);
    final path = '$roomId/$fileName';
    
    await _client.storage.from('chat_audio').upload(path, file);
    
    return path;
  }

  /// Get signed URL for media
  Future<String> getSignedUrl(String path, {String bucket = 'chat_images'}) async {
    final response = await _client.storage
        .from(bucket)
        .createSignedUrl(path, 3600); // 1 hour
    
    return response;
  }
}
