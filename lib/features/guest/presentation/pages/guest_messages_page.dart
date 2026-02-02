/// Messages page for guest users.
///
/// Displays wedding team conversations for guest users.
/// Uses ChatRepository with filter for weddingTeam rooms.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/design/design.dart';
import '/features/chat/domain/entities/entities.dart';
import '/features/chat/presentation/pages/chat_details_page.dart';
import '/features/chat/presentation/widgets/conversation_tile.dart';
import '/features/chat/presentation/widgets/empty_state_widget.dart';

/// Messages page for guest users.
///
/// Shows wedding team conversations that the guest is part of.
/// Simplified version of MessagesPage without contact requests,
/// archive, or block functionality.
class GuestMessagesPage extends StatefulWidget {
  /// Creates a guest messages page.
  const GuestMessagesPage({super.key});

  @override
  State<GuestMessagesPage> createState() => _GuestMessagesPageState();
}

class _GuestMessagesPageState extends State<GuestMessagesPage> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<dynamic>? _realtimeSubscription;

  /// Get current user ID, returns null if Supabase not initialized
  String? _getCurrentUserId() {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  /// Call Supabase RPC, returns null if Supabase not initialized
  Future<dynamic> _callRpc(String functionName) async {
    try {
      return await Supabase.instance.client.rpc(functionName);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Delay initialization to allow widget to be fully mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadConversations();
        _setupRealtimeListener();
      }
    });
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Not authenticated';
        });
        return;
      }

      // Use the RPC that returns all rooms with unread counts
      final response = await _callRpc('get_rooms_with_unread_counts');

      if (response == null) {
        setState(() {
          _conversations = [];
          _isLoading = false;
        });
        return;
      }

      // RPC returns { items: [...] }, extract the items array
      final Map<String, dynamic> data = response as Map<String, dynamic>;
      final List<dynamic> items = data['items'] as List<dynamic>? ?? [];

      // Filter for wedding team rooms only
      final conversations = items
          .map((item) => Conversation.fromMap(item as Map<String, dynamic>))
          .where((conv) => conv.roomType == RoomType.weddingTeam)
          .toList();

      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading conversations: $e';
        });
      }
    }
  }

  void _setupRealtimeListener() {
    try {
      // Listen for new messages to refresh the list
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      Supabase.instance.client
          .channel('guest_messages_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'chat_messages',
            callback: (payload) {
              // Refresh conversations when a new message arrives
              _loadConversations();
            },
          )
          .subscribe();
    } catch (_) {
      // Supabase not initialized (test environment)
    }
  }

  Future<void> _onRefresh() async {
    await _loadConversations();
  }

  void _onConversationTap(Conversation conversation) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailsPage(
          roomId: conversation.roomId,
          isPublicRoom: false,
          isWeddingTeamChat: true,
          hideVideoCall: true,
          otherProfileId: conversation.otherProfileId,
          otherFullName: conversation.displayName,
          otherAvatarUrl: conversation.displayAvatarUrl,
          conversationStatus: conversation.conversationStatus,
        ),
      ),
    );

    // Refresh when returning from chat (messages were read)
    if (mounted) {
      _loadConversations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Divider
            const Divider(height: 1, color: LynewedColors.gray200),

            // Body
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Messages',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: LynewedColors.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: LynewedColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadConversations,
                  style: LynewedComponentStyles.primaryButton(),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_conversations.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        color: LynewedColors.primary,
        child: ListView(
          children: const [
            SizedBox(height: 100),
            ChatEmptyState(
              message: 'No messages yet',
              icon: Icons.chat_bubble_outline,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: LynewedColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _conversations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return ConversationTile(
            conversation: conversation,
            onTap: () => _onConversationTap(conversation),
            onLongPress: () {}, // No long press actions for guest
          );
        },
      ),
    );
  }
}
