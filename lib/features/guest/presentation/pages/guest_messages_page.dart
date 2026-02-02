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

      // Use dedicated RPC for guest conversations (wedding groups only)
      final response = await _callRpc('get_guest_conversations');

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

      // Map to Conversation entities (already filtered by RPC)
      final conversations = items
          .map((item) => Conversation.fromMap(item as Map<String, dynamic>))
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
    // For wedding groups, use publicTitle as the room title
    final isWeddingGroup = conversation.roomType.isWeddingGroup;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailsPage(
          roomId: conversation.roomId,
          isPublicRoom: isWeddingGroup, // Wedding groups behave like public rooms
          isWeddingTeamChat: true,
          hideVideoCall: true,
          otherProfileId: conversation.otherProfileId,
          otherFullName: conversation.otherFullName,
          otherAvatarUrl: conversation.otherAvatarUrl,
          otherRole: conversation.otherRole,
          publicRoomTitle: isWeddingGroup ? conversation.publicTitle : null,
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
    // No header here - GuestHomePage provides the "MESSAGES" header
    return _buildBody();
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
      child: CustomScrollView(
        slivers: [
          // Section title - same style as MessagesPage
          // Note: No horizontal padding here - GuestHomePage already provides 20px padding
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 30, bottom: 10),
              child: Text(
                'Conversations',
                style: LynewedTextStyles.sectionTitle,
              ),
            ),
          ),
          // Conversations list - no horizontal padding (provided by parent)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final conversation = _conversations[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ConversationTile(
                    conversation: conversation,
                    onTap: () => _onConversationTap(conversation),
                    onLongPress: () {}, // No long press actions for guest
                  ),
                );
              },
              childCount: _conversations.length,
            ),
          ),
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}
