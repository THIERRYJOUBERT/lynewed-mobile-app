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
import '../sheets/blocked_users_sheet.dart'; // ArchivedSheet
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

  void _onConversationTap(Conversation conversation) async {
    await Navigator.push(
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
          conversationStatus: conversation.conversationStatus,
          onUnblock: conversation.otherProfileId != null
              ? () => _notifier.unblockUser(conversation.otherProfileId!)
              : null,
        ),
      ),
    );
    // Refresh conversations when returning from chat (messages were read)
    if (mounted) {
      _notifier.refresh();
    }
  }

  void _onConversationLongPress(Conversation conversation) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    ConversationActionsSheet.show(
      context: context,
      conversation: conversation,
      onArchive: () => _notifier.archiveConversation(conversation.roomId),
      onBlock: conversation.otherProfileId != null
          ? () async {
              final success = await _notifier.blockUser(conversation.otherProfileId!);
              if (success && mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('User blocked'),
                    backgroundColor: LynewedColors.success,
                  ),
                );
              } else if (mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Error blocking user'),
                    backgroundColor: LynewedColors.error,
                  ),
                );
              }
            }
          : null,
      onReport: conversation.otherProfileId != null
          ? (reason, details) async {
              final success = await _notifier.reportUser(
                profileId: conversation.otherProfileId!,
                reason: reason,
                details: details,
              );
              if (success && mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('User reported'),
                    backgroundColor: LynewedColors.success,
                  ),
                );
              } else if (mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Error reporting user'),
                    backgroundColor: LynewedColors.error,
                  ),
                );
              }
            }
          : null,
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

    // Navigate to ChatDetailsPage for Bride to review the request
    // The page will show the initial message and Accept/Decline buttons in the chatbar
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailsPage(
          roomId: request.id, // Use request ID as temporary room ID
          isPublicRoom: false,
          pendingRequestId: request.id,
          initialMessage: request.initialMessage,
          otherProfileId: request.proProfileId,
          otherFullName: request.otherFullName,
          otherAvatarUrl: request.otherAvatarUrl,
          otherRole: request.otherRole,
          viewerIsReviewer: true,
          onRequestAccepted: () {
            // Refresh conversations when returning
            _notifier.refresh();
          },
          onRequestDeclined: () {
            // Refresh conversations when returning
            _notifier.refresh();
          },
        ),
      ),
    );
    
    // Refresh when returning from chat details
    if (mounted) {
      _notifier.refresh();
    }
  }

  void _showArchivedSheet() {
    final state = _notifier.state;
    if (state is! ConversationsLoaded) return;

    ArchivedSheet.show(
      context: context,
      archivedConversations: state.archivedConversations,
      blockedUsers: state.blockedUsers,
      onUnarchive: (conversation) async {
        await _notifier.unarchiveConversation(conversation.roomId);
      },
      onUnblock: (user) async {
        final success = await _notifier.unblockUser(user.blockedProfileId);
        return success;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _notifier.state;
    final archivedCount = state is ConversationsLoaded 
        ? state.archivedConversations.length + state.blockedUsers.length 
        : 0;

    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(archivedCount),
            
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

  /// Header with back button, title, and archive icon (archived/blocked)
  /// Matches LynewedSheet header style for consistency
  Widget _buildHeader(int archivedCount) {
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
          
          // Archive icon button (archived/blocked) - circle 44px
          GestureDetector(
            onTap: _showArchivedSheet,
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
                  // Badge for archived count
                  if (archivedCount > 0)
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
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
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
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
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
