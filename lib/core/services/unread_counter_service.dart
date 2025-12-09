/// Unread Counter Service - Global realtime counter management
/// 
/// Singleton service that listens to chat_messages changes via Supabase Realtime
/// and updates FFAppState.unreadMessagesCount automatically.
/// 
/// Usage:
/// - Initialize once at app startup: UnreadCounterService.instance.initialize()
/// - Dispose on logout: UnreadCounterService.instance.dispose()
library;

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import 'app_badge_service.dart';

/// Global service for managing unread message counts
class UnreadCounterService {
  UnreadCounterService._();
  
  static final UnreadCounterService instance = UnreadCounterService._();
  
  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _channel;
  bool _isInitialized = false;
  Timer? _debounceTimer;
  
  String get _currentUserId => _client.auth.currentUser?.id ?? '';

  /// Initialize the service and start listening to realtime updates
  Future<void> initialize() async {
    if (_isInitialized || _currentUserId.isEmpty) return;
    
    // Initial fetch
    await refresh();
    
    // Setup realtime subscription
    _setupRealtimeSubscription();
    
    _isInitialized = true;
  }

  /// Setup realtime subscription for chat_messages
  void _setupRealtimeSubscription() {
    _channel?.unsubscribe();
    
    _channel = _client
        .channel('unread_counter_global')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          callback: (payload) {
            // Only refresh if message is from someone else
            final senderId = payload.newRecord['profile_id'] as String?;
            if (senderId != _currentUserId) {
              _debouncedRefresh();
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'chat_room_participants',
          callback: (payload) {
            // Refresh when last_read_at is updated (user read messages)
            final profileId = payload.newRecord['profile_id'] as String?;
            if (profileId == _currentUserId) {
              _debouncedRefresh();
            }
          },
        )
        .subscribe();
  }

  /// Debounced refresh to avoid too many API calls
  void _debouncedRefresh() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      refresh();
    });
  }

  /// Refresh the unread count from server
  Future<void> refresh() async {
    try {
      final count = await actions.getUnreadMessagesCountAction();
      FFAppState().unreadMessagesCount = count ?? 0;
      // Sync iOS app icon badge
      await AppBadgeService.instance.updateBadge();
    } catch (e) {
      // Silently fail - don't break the app for counter issues
    }
  }

  /// Force immediate refresh (call after reading messages)
  Future<void> forceRefresh() async {
    _debounceTimer?.cancel();
    await refresh();
  }

  /// Dispose the service
  Future<void> dispose() async {
    _debounceTimer?.cancel();
    _channel?.unsubscribe();
    _channel = null;
    _isInitialized = false;
    // Clear iOS badge on logout
    await AppBadgeService.instance.clearBadge();
  }
}
