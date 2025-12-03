/// Messages page - Clean Architecture
/// 
/// Unified messages page for both Brides and Professionals.
/// Replaces MessagesBridesWidget and MessagesProWidget.
/// 
/// DESIGN SYSTEM v2 APPLIED:
/// - Header: Back button (left) + Title (left-aligned) + Blocked icon (right)
/// - Divider under header
/// - Typography: bodyLarge + w600 for section titles
/// - Spacing: 30px inter-section, 12px label→content
library;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';
import '../bloc/conversations_cubit.dart';
import '../bloc/conversations_state.dart';
import '../widgets/contact_request_avatar.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/empty_state_widget.dart';
import '../sheets/conversation_actions_sheet.dart';
import '../sheets/contact_request_review_sheet.dart';
import '../sheets/blocked_users_sheet.dart';
import 'chat_details_page.dart';

/// Unified Messages page
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  static const String routeName = 'Messages';
  static const String routePath = '/messages';

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late ConversationsNotifier _notifier;
  
  String get _currentUserId => Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _notifier = ConversationsNotifier();
    _notifier.addListener(_onStateChanged);
    _notifier.loadAll();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _notifier.removeListener(_onStateChanged);
    _notifier.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _notifier.refresh();
  }

  void _onConversationTap(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailsPage(
          roomId: conversation.roomId,
          isPublicRoom: conversation.isPublic,
          otherProfileId: conversation.otherProfileId,
          otherFullName: conversation.otherFullName,
          otherAvatarUrl: conversation.otherAvatarUrl,
          otherRole: conversation.otherRole,
          publicRoomTitle: conversation.isPublic ? conversation.otherFullName : null,
        ),
      ),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request accepted from ${request.otherFullName}'),
          backgroundColor: LynewedColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (result == ContactRequestReviewResult.declined) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request declined'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showBlockedUsersSheet() {
    final state = _notifier.state;
    if (state is! ConversationsLoaded) return;

    BlockedUsersSheet.show(
      context: context,
      blockedUsers: state.blockedUsers,
      onUnblock: (user) async {
        final success = await _notifier.unblockUser(user.blockedProfileId);
        return success;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _notifier.state;
    final blockedCount = state is ConversationsLoaded ? state.blockedUsers.length : 0;

    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(blockedCount),
            
            // Divider - same as LynewedSheet
            const Divider(height: 1, color: LynewedColors.gray200),
            
            // Body
            Expanded(
              child: _buildBody(state),
            ),
          ],
        ),
      ),
    );
  }

  /// Header with back button, title, and archive icon (blocked users)
  /// Matches LynewedSheet header style for consistency
  Widget _buildHeader(int blockedCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          // Back button - Standard 24x24 icon with 44px tap target
          LynewedComponentStyles.backButton(context),
          
          const SizedBox(width: 4),
          
          // Title - same style as LynewedSheet
          Expanded(
            child: Text(
              'Messages',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
          
          // Archive icon button (blocked users) - circle 44px
          GestureDetector(
            onTap: _showBlockedUsersSheet,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: LynewedColors.surface,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.archive_outlined,
                    size: 22,
                    color: LynewedColors.textSecondary,
                  ),
                  // Badge for blocked count
                  if (blockedCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: LynewedColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
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
        child: Padding(
          padding: const EdgeInsets.all(32),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _notifier.loadAll(),
                  style: LynewedComponentStyles.primaryButton(),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is ConversationsLoaded) {
      return _buildConversationsContent(state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildConversationsContent(ConversationsLoaded state) {
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

          // Conversations Section Title - 30px top spacing, 10px bottom
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: Text(
                'Conversations',
                style: LynewedTextStyles.sectionTitle, // 16px, w500
              ),
            ),
          ),

          // Conversations List
          if (state.activeConversations.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: ChatEmptyState(
                message: 'No conversations yet',
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

          // Bottom padding for safe area
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
        // Section title - 30px top spacing, 10px bottom
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
          child: Text(
            'Contact Requests',
            style: LynewedTextStyles.sectionTitle, // 16px, w500
          ),
        ),
        
        // Horizontal list of request avatars
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
        
        const SizedBox(height: 30),
      ],
    );
  }
}
