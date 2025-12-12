/// Supabase Weddings Hub Datasource
///
/// Handles all Supabase operations for the Weddings Hub Pro module.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '/utils/secure_logger.dart';
import '../../domain/entities/wedding_client.dart';

/// Supabase datasource for Weddings Hub Pro operations
class SupabaseWeddingsHubDatasource {
  SupabaseWeddingsHubDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Get current user ID
  String? get _currentUserId => _client.auth.currentUser?.id;

  /// Get all weddings where the pro is an active participant
  Future<List<WeddingClient>> getMyWeddingsAsPro() async {
    final userId = _currentUserId;
    if (userId == null) {
      SecureLogger.warning('getMyWeddingsAsPro: No authenticated user');
      return [];
    }

    SecureLogger.info('getMyWeddingsAsPro: Fetching for userId=$userId');

    try {
      final response = await _client
          .from('wedding_participants')
          .select('''
            id,
            wedding_id,
            is_muted,
            joined_at,
            status,
            weddings(
              id,
              bride_profile_id,
              wedding_name,
              venue_label,
              event_date,
              cover_image_url,
              note_for_pros,
              status,
              profiles!weddings_bride_profile_id_fkey(
                full_name,
                avatar_url
              )
            )
          ''')
          .eq('professional_profile_id', userId);

      SecureLogger.info('getMyWeddingsAsPro: Raw response count=${response.length}');

      final weddings = <WeddingClient>[];
      
      for (final item in response) {
        final participantStatus = item['status'] as String?;
        final wedding = item['weddings'] as Map<String, dynamic>?;
        
        SecureLogger.info('getMyWeddingsAsPro: participant.status=$participantStatus, wedding=${wedding != null}');
        
        // Only include active participants in non-cancelled weddings
        if (participantStatus == 'active' && wedding != null && wedding['status'] != 'cancelled') {
          weddings.add(WeddingClient.fromJson(item));
        }
      }

      SecureLogger.info('getMyWeddingsAsPro: Found ${weddings.length} weddings after filtering');
      return weddings;
    } catch (e) {
      SecureLogger.error('getMyWeddingsAsPro error: $e');
      rethrow;
    }
  }

  /// Get a single wedding client detail
  Future<WeddingClient?> getWeddingClient({
    required String weddingId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      SecureLogger.warning('getWeddingClient: No authenticated user');
      return null;
    }

    try {
      final response = await _client
          .from('wedding_participants')
          .select('''
            id,
            wedding_id,
            is_muted,
            joined_at,
            weddings(
              id,
              bride_profile_id,
              wedding_name,
              venue_label,
              event_date,
              cover_image_url,
              note_for_pros,
              status,
              profiles!weddings_bride_profile_id_fkey(
                full_name,
                avatar_url
              )
            )
          ''')
          .eq('professional_profile_id', userId)
          .eq('wedding_id', weddingId)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) {
        SecureLogger.info('getWeddingClient: No wedding found');
        return null;
      }

      return WeddingClient.fromJson(response);
    } catch (e) {
      SecureLogger.error('getWeddingClient error: $e');
      rethrow;
    }
  }

  /// Leave a wedding (pro quits)
  Future<void> leaveWedding({
    required String weddingId,
    required String reason,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('No authenticated user');
    }

    try {
      await _client
          .from('wedding_participants')
          .update({
            'status': 'left',
            'left_at': DateTime.now().toIso8601String(),
            'left_reason': reason,
          })
          .eq('wedding_id', weddingId)
          .eq('professional_profile_id', userId);

      SecureLogger.info('leaveWedding: Pro $userId left wedding $weddingId');
    } catch (e) {
      SecureLogger.error('leaveWedding error: $e');
      rethrow;
    }
  }

  /// Toggle mute status for a wedding
  Future<void> toggleMuteWedding({
    required String weddingId,
    required bool isMuted,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('No authenticated user');
    }

    try {
      await _client
          .from('wedding_participants')
          .update({'is_muted': isMuted})
          .eq('wedding_id', weddingId)
          .eq('professional_profile_id', userId);

      SecureLogger.info('toggleMuteWedding: Wedding $weddingId muted=$isMuted');
    } catch (e) {
      SecureLogger.error('toggleMuteWedding error: $e');
      rethrow;
    }
  }

  /// Get wedding team chat room ID
  Future<String?> getWeddingTeamChatId({
    required String weddingId,
  }) async {
    try {
      final response = await _client
          .from('chat_rooms')
          .select('id')
          .eq('wedding_id', weddingId)
          .eq('type', 'wedding_team')
          .maybeSingle();

      return response?['id'] as String?;
    } catch (e) {
      SecureLogger.error('getWeddingTeamChatId error: $e');
      return null;
    }
  }

  /// Get wedding team chat room info with participants and unread count
  Future<Map<String, dynamic>?> getWeddingTeamChatInfo({
    required String weddingId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      SecureLogger.warning('getWeddingTeamChatInfo: No authenticated user');
      return null;
    }

    try {
      // Get the wedding_team chat room for this wedding
      final response = await _client
          .from('chat_rooms')
          .select('''
            id,
            wedding_id,
            chat_room_participants(
              profile_id,
              profiles(
                avatar_url
              )
            )
          ''')
          .eq('wedding_id', weddingId)
          .eq('type', 'wedding_team')
          .maybeSingle();

      if (response == null) {
        SecureLogger.info('getWeddingTeamChatInfo: No wedding team chat found for wedding $weddingId');
        return null;
      }

      // Get unread count for current user
      final roomId = response['id'] as String;
      final unreadCount = await _getUnreadCountForRoom(roomId, userId);

      return {
        'id': roomId,
        'wedding_id': weddingId,
        'chat_room_participants': response['chat_room_participants'],
        'unread_count': unreadCount,
      };
    } catch (e) {
      SecureLogger.error('getWeddingTeamChatInfo error: $e');
      return null;
    }
  }

  /// Get unread message count for a specific room
  Future<int> _getUnreadCountForRoom(String roomId, String userId) async {
    try {
      // Get last_read_at for the user in this room
      final participantResponse = await _client
          .from('chat_room_participants')
          .select('last_read_at')
          .eq('room_id', roomId)
          .eq('profile_id', userId)
          .maybeSingle();

      final lastReadAt = participantResponse?['last_read_at'] as String?;

      // Count messages after last_read_at
      var query = _client
          .from('chat_messages')
          .select('id')
          .eq('room_id', roomId)
          .neq('profile_id', userId)
          .eq('is_deleted', false);

      if (lastReadAt != null) {
        query = query.gt('created_at', lastReadAt);
      }

      final messages = await query;
      return (messages as List).length;
    } catch (e) {
      SecureLogger.error('_getUnreadCountForRoom error: $e');
      return 0;
    }
  }

  /// Ensure pro is added as participant to wedding team chat
  Future<void> ensureProInWeddingTeamChat({
    required String weddingId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      SecureLogger.warning('ensureProInWeddingTeamChat: No authenticated user');
      return;
    }

    try {
      // First get the wedding team chat room
      final chatRoomResponse = await _client
          .from('chat_rooms')
          .select('id')
          .eq('wedding_id', weddingId)
          .eq('type', 'wedding_team')
          .maybeSingle();

      if (chatRoomResponse == null) {
        SecureLogger.info('ensureProInWeddingTeamChat: No wedding team chat found for wedding $weddingId');
        return;
      }

      final roomId = chatRoomResponse['id'] as String;

      // Check if pro is already a participant
      final existingParticipant = await _client
          .from('chat_room_participants')
          .select('profile_id')
          .eq('room_id', roomId)
          .eq('profile_id', userId)
          .maybeSingle();

      if (existingParticipant != null) {
        SecureLogger.info('ensureProInWeddingTeamChat: Pro $userId already in chat room $roomId');
        return;
      }

      // Add pro as participant
      await _client
          .from('chat_room_participants')
          .insert({
            'room_id': roomId,
            'profile_id': userId,
            'joined_at': DateTime.now().toIso8601String(),
            'last_read_at': DateTime.now().toIso8601String(),
          });

      SecureLogger.info('ensureProInWeddingTeamChat: Added pro $userId to chat room $roomId');
    } catch (e) {
      SecureLogger.error('ensureProInWeddingTeamChat error: $e');
      rethrow;
    }
  }
}
