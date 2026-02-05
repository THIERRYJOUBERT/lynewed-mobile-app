/// Marketplace Chat Page - Conversation between buyer and seller.
///
/// Displays messages for a specific listing + other user pair.
/// Supports real-time message delivery via Supabase Realtime.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../../../backend/supabase/supabase.dart';
import '../../domain/entities/marketplace_message.dart';
import '../../domain/repositories/marketplace_chat_repository.dart';
import '../widgets/chat_bubble_widget.dart';
import '../widgets/chat_input_bar.dart';

/// Chat page for marketplace conversations.
///
/// Shows messages between the current user and another user about a listing.
/// Features:
/// - Message list with chronological ordering
/// - Real-time message updates via Supabase Realtime
/// - Mark as read on open
/// - Send new messages
class MarketplaceChatPage extends StatefulWidget {
  /// Creates a marketplace chat page.
  const MarketplaceChatPage({
    required this.listingId,
    required this.otherUserId,
    this.listingTitle,
    this.repository,
    this.currentUserId,
    super.key,
  });

  /// Route name for navigation.
  static const String routeName = 'MarketplaceChat';

  /// The listing this conversation is about.
  final String listingId;

  /// The other user in this conversation.
  final String otherUserId;

  /// Optional listing title for the header.
  final String? listingTitle;

  /// Optional repository override for testing.
  final MarketplaceChatRepository? repository;

  /// Optional current user ID override for testing.
  /// Falls back to SupaFlow.client.auth.currentUser.id in production.
  final String? currentUserId;

  @override
  State<MarketplaceChatPage> createState() => _MarketplaceChatPageState();
}

class _MarketplaceChatPageState extends State<MarketplaceChatPage> {
  late final MarketplaceChatRepository _repository;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  List<MarketplaceMessage> _messages = [];
  StreamSubscription<MarketplaceMessage>? _realtimeSubscription;
  bool _isLoading = true;
  String? _error;

  String? get _currentUserId {
    if (widget.currentUserId != null) return widget.currentUserId;
    try {
      return SupaFlow.client.auth.currentUser?.id;
    } catch (_) {
      // SupaFlow not initialized (e.g. in tests without Supabase setup).
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? sl<MarketplaceChatRepository>();
    _loadMessages();
    _subscribeToNewMessages();
    _markAsRead();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _repository.getMessages(
        listingId: widget.listingId,
        otherUserId: widget.otherUserId,
      );
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
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

  void _subscribeToNewMessages() {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;

    _realtimeSubscription = _repository
        .subscribeToMessages(
          listingId: widget.listingId,
          currentUserId: currentUserId,
        )
        .listen((newMessage) {
      if (mounted) {
        // Avoid duplicate messages (sent by self).
        final isDuplicate = _messages.any((m) => m.id == newMessage.id);
        if (!isDuplicate) {
          setState(() => _messages.add(newMessage));
          _scrollToBottomIfNear();
        }
        _markAsRead();
      }
    });
  }

  Future<void> _markAsRead() async {
    try {
      await _repository.markConversationAsRead(
        listingId: widget.listingId,
        otherUserId: widget.otherUserId,
      );
    } catch (_) {
      // Silently ignore mark-as-read failures (non-critical UX operation).
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _scrollToBottomIfNear() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      // Only auto-scroll if within 150px of bottom.
      if (maxScroll - currentScroll < 150) {
        _scrollToBottom();
      }
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // Save content before clearing for potential restore on failure.
    final savedContent = content;
    _messageController.clear();

    try {
      final sent = await _repository.sendMessage(
        listingId: widget.listingId,
        receiverId: widget.otherUserId,
        content: content,
      );
      if (mounted) {
        setState(() => _messages.add(sent));
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        // Restore the message text so the user can retry.
        _messageController.text = savedContent;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send message',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textOnDark,
              ),
            ),
          ),
        );
      }
    }
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
            Expanded(child: _buildMessageList()),
            ChatInputBar(
              controller: _messageController,
              onSend: _sendMessage,
            ),
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
              widget.listingTitle ?? 'Chat',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: LynewedColors.primary),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    final currentUserId = _currentUserId;

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(LynewedSpacing.md),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return ChatBubbleWidget(
          message: message,
          isMe: message.senderId == currentUserId,
        );
      },
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
            'No messages yet',
            style: LynewedTextStyles.titleSmall.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
          SizedBox(height: LynewedSpacing.sm),
          Text(
            'Send a message to start the conversation',
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
            'Failed to load messages',
            style: LynewedTextStyles.titleSmall.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
          SizedBox(height: LynewedSpacing.sm),
          LynewedButton(
            text: 'Retry',
            type: LynewedButtonType.secondary,
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadMessages();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _realtimeSubscription?.cancel();
    _repository.unsubscribeAll();
    super.dispose();
  }
}
