/// Messages page - Clean Architecture
///
/// Unified messages page with 3 tabbed views:
/// - Tab 0: Messages (private 1-1 conversations + contact requests)
/// - Tab 1: Wedding (wedding team + group conversations)
/// - Tab 2: Marketplace (buyer/seller conversations with offers)
///
/// Entry points:
/// - Home header chat icon → initialTab: 0
/// - MyWedding header group icon → initialTab: 1
/// - Marketplace offers → initialTab: 2
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '/features/auth/domain/entities/user_role.dart' as auth_entities;
import '/features/auth/presentation/bloc/auth_cubit.dart';
import '/features/auth/presentation/bloc/auth_state.dart';
import '/features/marketplace/domain/entities/marketplace_conversation.dart';
import '/features/marketplace/domain/repositories/marketplace_chat_repository.dart';
import '/features/marketplace/presentation/pages/marketplace_chat_page.dart';
import '/features/marketplace/presentation/widgets/conversation_tile_widget.dart';
import '/features/my_wedding/presentation/pages/wedding_groups_page.dart';
import '../../domain/entities/entities.dart';
import '../bloc/conversations_cubit.dart';
import '../bloc/conversations_state.dart';
import '../widgets/contact_request_avatar.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/empty_state_widget.dart';
import '../sheets/conversation_actions_sheet.dart';
import '../sheets/blocked_users_sheet.dart'; // ArchivedSheet
import 'chat_details_page.dart';

/// Unified Messages page with 3 tabs
class MessagesPage extends StatefulWidget {
  const MessagesPage({
    super.key,
    this.initialTab = 0,
    this.weddingId,
    this.notifier,
  });

  /// Initial tab index (0=Messages, 1=Wedding, 2=Marketplace)
  final int initialTab;

  /// Wedding ID for "Manage Groups" in Wedding tab
  final String? weddingId;

  /// Optional notifier for testing (created internally if null).
  final ConversationsNotifier? notifier;

  static const String routeName = 'Messages';
  static const String routePath = '/messages';

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late ConversationsNotifier _notifier;
  late int _selectedTab;
  List<MarketplaceConversation> _marketplaceConversations = [];

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  int get _marketplaceUnreadCount =>
      _marketplaceConversations.fold(0, (sum, c) => sum + c.unreadCount);

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab.clamp(0, 2);
    _notifier = widget.notifier ?? ConversationsNotifier();
    _notifier.addListener(_onStateChanged);
    if (widget.notifier == null) {
      _notifier.loadAll();
      _loadMarketplaceConversations();
    }
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _notifier.removeListener(_onStateChanged);
    if (widget.notifier == null) {
      _notifier.dispose();
    }
    super.dispose();
  }

  Future<void> _loadMarketplaceConversations() async {
    try {
      final repo = sl<MarketplaceChatRepository>();
      final conversations = await repo.getConversations();
      if (mounted) {
        setState(() => _marketplaceConversations = conversations);
      }
    } catch (_) {
      // Silently handle marketplace conversation loading errors.
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      _notifier.refresh(),
      _loadMarketplaceConversations(),
    ]);
  }

  // ============================================================
  // NAVIGATION HANDLERS
  // ============================================================

  void _onConversationTap(Conversation conversation) async {
    final isWeddingGroup = conversation.roomType.isWeddingGroup;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailsPage(
          roomId: conversation.roomId,
          isPublicRoom: conversation.isPublic || isWeddingGroup,
          isWeddingTeamChat: isWeddingGroup,
          hideVideoCall: isWeddingGroup,
          otherProfileId: conversation.otherProfileId,
          otherFullName: conversation.otherFullName,
          otherAvatarUrl: conversation.otherAvatarUrl,
          otherRole: conversation.otherRole,
          publicRoomTitle: isWeddingGroup
              ? conversation.displayName
              : (conversation.isPublic ? conversation.otherFullName : null),
          conversationStatus: conversation.conversationStatus,
          onUnblock: conversation.otherProfileId != null
              ? () => _notifier.unblockUser(conversation.otherProfileId!)
              : null,
        ),
      ),
    );
    if (mounted) _notifier.refresh();
  }

  void _onConversationLongPress(Conversation conversation) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    ConversationActionsSheet.show(
      context: context,
      conversation: conversation,
      onArchive: () => _notifier.archiveConversation(conversation.roomId),
      onBlock: conversation.otherProfileId != null
          ? () async {
              final success =
                  await _notifier.blockUser(conversation.otherProfileId!);
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
    if (request.initiatorId == _currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waiting for response...'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailsPage(
          roomId: request.id,
          isPublicRoom: false,
          pendingRequestId: request.id,
          initialMessage: request.initialMessage,
          otherProfileId: request.proProfileId,
          otherFullName: request.otherFullName,
          otherAvatarUrl: request.otherAvatarUrl,
          otherRole: request.otherRole,
          viewerIsReviewer: true,
          onRequestAccepted: () => _notifier.refresh(),
          onRequestDeclined: () => _notifier.refresh(),
        ),
      ),
    );
    if (mounted) _notifier.refresh();
  }

  void _onMarketplaceConversationTap(MarketplaceConversation conv) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MarketplaceChatPage(
          listingId: conv.listingId,
          otherUserId: conv.otherUserId,
          listingTitle: conv.listingTitle,
          listingCoverUrl: conv.listingCoverUrl,
          otherUserName: conv.otherUserName,
          otherUserAvatarUrl: conv.otherUserAvatarUrl,
        ),
      ),
    );
    if (mounted) _loadMarketplaceConversations();
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final state = _notifier.state;
    final archivedCount = state is ConversationsLoaded
        ? state.archivedConversations.length + state.blockedUsers.length
        : 0;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final isProfessional = authState is Authenticated &&
            authState.profile?.role == auth_entities.UserRole.professional;

        return Scaffold(
          backgroundColor: LynewedColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(archivedCount),
                const Divider(height: 1, color: LynewedColors.gray200),
                // Tab selector
                if (state is ConversationsLoaded)
                  _buildTabSelector(state, isProfessional: isProfessional),
                // Body
                Expanded(child: _buildBody(state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(int archivedCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Messages',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
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

  Widget _buildTabSelector(
    ConversationsLoaded state, {
    bool isProfessional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          LynewedChip(
            label: 'Messages',
            selected: _selectedTab == 0,
            onSelected: (_) => setState(() => _selectedTab = 0),
            count: state.privateUnreadCount > 0
                ? state.privateUnreadCount
                : null,
          ),
          const SizedBox(width: 8),
          LynewedChip(
            label: 'Wedding',
            selected: _selectedTab == 1,
            onSelected: (_) => setState(() => _selectedTab = 1),
            count: state.weddingUnreadCount > 0
                ? state.weddingUnreadCount
                : null,
          ),
          if (!isProfessional) ...[
            const SizedBox(width: 8),
            LynewedChip(
              label: 'Marketplace',
              selected: _selectedTab == 2,
              onSelected: (_) => setState(() => _selectedTab = 2),
              count:
                  _marketplaceUnreadCount > 0 ? _marketplaceUnreadCount : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(ConversationsState state) {
    if (state is ConversationsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: LynewedColors.primary),
      );
    }

    if (state is ConversationsError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: LynewedColors.error),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: LynewedTextStyles.bodyMedium
                    .copyWith(color: LynewedColors.textSecondary),
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
      return switch (_selectedTab) {
        0 => _buildMessagesTab(state),
        1 => _buildWeddingTab(state),
        2 => _buildMarketplaceTab(),
        _ => _buildMessagesTab(state),
      };
    }

    return const SizedBox.shrink();
  }

  // ============================================================
  // TAB 0: MESSAGES (Private 1-1 conversations)
  // ============================================================

  Widget _buildMessagesTab(ConversationsLoaded state) {
    final conversations = state.privateConversations;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: LynewedColors.primary,
      child: CustomScrollView(
        slivers: [
          // Contact Requests Section
          if (state.hasPendingRequests) ...[
            SliverToBoxAdapter(
              child: _buildRequestsSection(state.pendingRequests),
            ),
            const SliverToBoxAdapter(
              child: Divider(height: 1, color: LynewedColors.gray200),
            ),
          ],

          // Conversations list
          if (conversations.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: ChatEmptyState(
                message: 'No conversations yet',
                icon: Icons.chat_bubble_outline,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final conversation = conversations[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ConversationTile(
                        conversation: conversation,
                        onTap: () => _onConversationTap(conversation),
                        onLongPress: () =>
                            _onConversationLongPress(conversation),
                      ),
                    );
                  },
                  childCount: conversations.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 1: WEDDING (Wedding group conversations)
  // ============================================================

  Widget _buildWeddingTab(ConversationsLoaded state) {
    final conversations = state.weddingConversations;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: LynewedColors.primary,
      child: CustomScrollView(
        slivers: [
          // Manage Groups button
          if (widget.weddingId != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WeddingGroupsPage(weddingId: widget.weddingId!),
                      ),
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: LynewedColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.settings_outlined,
                            size: 16,
                            color: LynewedColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Manage Groups',
                            style: LynewedTextStyles.labelSmall.copyWith(
                              color: LynewedColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Wedding conversations list
          if (conversations.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: ChatEmptyState(
                message: 'No wedding conversations yet',
                icon: Icons.groups_outlined,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final conversation = conversations[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ConversationTile(
                        conversation: conversation,
                        onTap: () => _onConversationTap(conversation),
                        onLongPress: () {},
                      ),
                    );
                  },
                  childCount: conversations.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 2: MARKETPLACE (Buyer/Seller conversations)
  // ============================================================

  Widget _buildMarketplaceTab() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: LynewedColors.primary,
      child: _marketplaceConversations.isEmpty
          ? const CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ChatEmptyState(
                    message: 'No marketplace conversations yet',
                    icon: Icons.shopping_bag_outlined,
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 100),
              itemCount: _marketplaceConversations.length,
              itemBuilder: (context, index) {
                final conv = _marketplaceConversations[index];
                return ConversationTileWidget(
                  conversation: conv,
                  onTap: () => _onMarketplaceConversationTap(conv),
                );
              },
            ),
    );
  }

  // ============================================================
  // SHARED WIDGETS
  // ============================================================

  Widget _buildRequestsSection(List<ContactRequest> requests) {
    final filteredRequests = requests
        .where((r) =>
            r.proProfileId != _currentUserId ||
            r.brideProfileId != _currentUserId)
        .toList();

    if (filteredRequests.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Text(
            'Contact Requests',
            style: LynewedTextStyles.sectionTitle,
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
}
