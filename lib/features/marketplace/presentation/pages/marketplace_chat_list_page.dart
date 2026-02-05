/// Marketplace Chat List Page - All conversations for current user.
///
/// Displays a list of conversation summaries grouped by listing,
/// sorted by most recent message, with unread count badges.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/marketplace_conversation.dart';
import '../../domain/repositories/marketplace_chat_repository.dart';
import '../widgets/conversation_tile_widget.dart';
import 'marketplace_chat_page.dart';

/// Chat list page for marketplace conversations.
///
/// Shows all conversations for the current user, sorted by most recent.
/// States:
/// - Loading: circular progress indicator
/// - Empty: illustration with "No conversations yet" text
/// - Error: error message with retry button
/// - Data: list of conversation tiles
class MarketplaceChatListPage extends StatefulWidget {
  /// Creates a marketplace chat list page.
  const MarketplaceChatListPage({
    this.repository,
    super.key,
  });

  /// Route name for navigation.
  static const String routeName = 'MarketplaceChatList';

  /// Optional repository override for testing.
  final MarketplaceChatRepository? repository;

  @override
  State<MarketplaceChatListPage> createState() =>
      _MarketplaceChatListPageState();
}

class _MarketplaceChatListPageState extends State<MarketplaceChatListPage> {
  late final MarketplaceChatRepository _repository;

  List<MarketplaceConversation> _conversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? sl<MarketplaceChatRepository>();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final conversations = await _repository.getConversations();
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _openConversation(MarketplaceConversation conversation) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MarketplaceChatPage(
          listingId: conversation.listingId,
          otherUserId: conversation.otherUserId,
          listingTitle: conversation.listingTitle,
          listingCoverUrl: conversation.listingCoverUrl,
          otherUserName: conversation.otherUserName,
          otherUserAvatarUrl: conversation.otherUserAvatarUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: LynewedColors.gray200),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        8,
        LynewedSpacing.md,
        LynewedSpacing.xl,
        LynewedSpacing.md,
      ),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          SizedBox(width: LynewedSpacing.sm),
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
      return const Center(
        child: CircularProgressIndicator(color: LynewedColors.primary),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_conversations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      color: LynewedColors.primary,
      child: ListView.separated(
        itemCount: _conversations.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          indent: 80,
          color: LynewedColors.gray200,
        ),
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return ConversationTileWidget(
            conversation: conversation,
            onTap: () => _openConversation(conversation),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: LynewedColors.gray300,
          ),
          SizedBox(height: LynewedSpacing.lg),
          Text(
            'No conversations yet',
            style: LynewedTextStyles.titleSmall.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
          SizedBox(height: LynewedSpacing.sm),
          Text(
            'Start a conversation by contacting a seller',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: LynewedColors.error,
          ),
          SizedBox(height: LynewedSpacing.lg),
          Text(
            'Failed to load conversations',
            style: LynewedTextStyles.titleSmall.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
          SizedBox(height: LynewedSpacing.sm),
          LynewedButton(
            text: 'Retry',
            type: LynewedButtonType.secondary,
            onPressed: _loadConversations,
          ),
        ],
      ),
    );
  }
}
