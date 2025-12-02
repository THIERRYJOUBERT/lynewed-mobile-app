/// Messages page - Clean Architecture
/// 
/// Unified messages page for both Brides and Professionals.
/// Replaces MessagesBridesWidget and MessagesProWidget.
library;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';
import '../bloc/conversations_cubit.dart';
import '../bloc/conversations_state.dart';
import '../widgets/contact_request_avatar.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/blocked_user_tile.dart';
import '../widgets/empty_state_widget.dart';
import '../sheets/conversation_actions_sheet.dart';
import '../sheets/contact_request_review_sheet.dart';

/// Unified Messages page
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  static const String routeName = 'Messages';
  static const String routePath = '/messages';

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ConversationsNotifier _notifier;
  
  String get _currentUserId => Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _notifier = ConversationsNotifier();
    _notifier.addListener(_onStateChanged);
    _notifier.loadAll();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notifier.removeListener(_onStateChanged);
    _notifier.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _notifier.refresh();
  }

  void _onConversationTap(Conversation conversation) {
    // TODO: Navigate to ChatDetails page
    // For now, just print
    debugPrint('Navigate to chat: ${conversation.roomId}');
    
    // Navigation will be implemented in Phase 4
    // Navigator.pushNamed(context, '/chatDetails', arguments: {...});
  }

  void _onConversationLongPress(Conversation conversation) {
    ConversationActionsSheet.show(
      context: context,
      conversation: conversation,
      onArchive: () => _notifier.archiveConversation(conversation.roomId),
    );
  }

  void _onRequestTap(ContactRequest request) async {
    // If current user is the initiator, they're waiting - no action
    if (request.initiatorId == _currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waiting for response...'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show review sheet for Bride
    final result = await ContactRequestReviewSheet.show(
      context: context,
      request: request,
      onAccept: () => _notifier.acceptRequest(request.id),
      onDecline: () => _notifier.declineRequest(request.id),
    );

    if (!mounted) return;

    if (result == ContactRequestReviewResult.accepted) {
      // TODO: Navigate to the new chat room
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demande acceptée de ${request.otherFullName}'),
          backgroundColor: LynewedColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (result == ContactRequestReviewResult.declined) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande refusée'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _notifier.state;

    return Scaffold(
      backgroundColor: LynewedColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ConversationsState state) {
    if (state is ConversationsLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: LynewedColors.primary,
        ),
      );
    }

    if (state is ConversationsError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: LynewedColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _notifier.loadAll(),
              style: LynewedComponentStyles.primaryButton(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state is ConversationsLoaded) {
      return TabBarView(
        controller: _tabController,
        children: [
          _buildConversationsTab(state),
          _buildBlockedTab(state),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: LynewedColors.background,
      elevation: 0,
      title: const Text(
        'Messagerie',
        style: LynewedTextStyles.titleMedium,
      ),
      centerTitle: true,
      bottom: TabBar(
        controller: _tabController,
        labelColor: LynewedColors.primary,
        unselectedLabelColor: LynewedColors.textSecondary,
        indicatorColor: LynewedColors.primary,
        indicatorWeight: 2,
        labelStyle: LynewedTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: LynewedTextStyles.labelMedium,
        tabs: const [
          Tab(text: 'Conversations'),
          Tab(text: 'Blocked'),
        ],
      ),
    );
  }

  Widget _buildConversationsTab(ConversationsLoaded state) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: LynewedColors.primary,
      child: CustomScrollView(
        slivers: [
          // Contact Requests Section (if any)
          if (state.hasPendingRequests) ...[
            SliverToBoxAdapter(
              child: _buildRequestsSection(state.pendingRequests),
            ),
            const SliverToBoxAdapter(
              child: Divider(height: 1, color: LynewedColors.gray200),
            ),
          ],

          // Conversations Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Conversations',
                style: LynewedTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Conversations List
          if (state.activeConversations.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: ChatEmptyState(
                message: 'No conversations',
                icon: Icons.chat_bubble_outline,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final conversation = state.activeConversations[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ConversationTile(
                        conversation: conversation,
                        onTap: () => _onConversationTap(conversation),
                        onLongPress: () => _onConversationLongPress(conversation),
                      ),
                    );
                  },
                  childCount: state.activeConversations.length,
                ),
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

  Widget _buildRequestsSection(List<ContactRequest> requests) {
    // Filter out requests where current user is the other profile
    final filteredRequests = requests
        .where((r) => r.proProfileId != _currentUserId || r.brideProfileId != _currentUserId)
        .toList();

    if (filteredRequests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            'Contact Requests',
            style: LynewedTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: filteredRequests.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final request = filteredRequests[index];
              return ContactRequestAvatar(
                request: request,
                currentUserId: _currentUserId,
                onTap: () => _onRequestTap(request),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBlockedTab(ConversationsLoaded state) {
    if (!state.hasBlockedUsers) {
      return const ChatEmptyState(
        message: 'No blocked users',
        icon: Icons.block,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: state.blockedUsers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final blockedUser = state.blockedUsers[index];
        return BlockedUserTile(
          blockedUser: blockedUser,
          onUnblock: () async {
            final confirm = await _showUnblockConfirmation(blockedUser);
            if (confirm == true) {
              await _notifier.unblockUser(blockedUser.blockedProfileId);
            }
          },
        );
      },
    );
  }

  Future<bool?> _showUnblockConfirmation(BlockedUser user) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock'),
        content: Text('Do you want to unblock ${user.fullName ?? 'this user'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: LynewedComponentStyles.primaryButton(),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }
}
