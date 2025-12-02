/// Message list widget - Clean Architecture
/// 
/// Displays a scrollable list of messages with pagination.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';
import '../bloc/chat_room_state.dart';
import 'message_bubble.dart';

/// Widget displaying a list of messages
class MessageList extends StatefulWidget {
  const MessageList({
    super.key,
    required this.state,
    required this.currentUserId,
    this.onLoadMore,
    this.onMessageLongPress,
    this.onImageTap,
    this.getSignedUrl,
    this.otherProfileName,
    this.otherProfileAvatarUrl,
  });

  /// Current state from ChatRoomNotifier
  final ChatRoomLoaded state;

  /// Current user's ID
  final String currentUserId;

  /// Callback to load more (older) messages
  final VoidCallback? onLoadMore;

  /// Callback when a message is long pressed
  final MessageActionCallback? onMessageLongPress;

  /// Callback when an image is tapped
  final void Function(ChatMessage message)? onImageTap;

  /// Function to get signed URL for media
  final Future<String?> Function(String path)? getSignedUrl;

  /// Other participant's name (for private rooms)
  final String? otherProfileName;

  /// Other participant's avatar URL (for private rooms)
  final String? otherProfileAvatarUrl;

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, String> _signedUrlCache = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more when scrolling to top (older messages)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!widget.state.isLoadingMore && widget.state.hasMoreMessages) {
        widget.onLoadMore?.call();
      }
    }
  }

  Future<String?> _getSignedUrl(String path) async {
    if (_signedUrlCache.containsKey(path)) {
      return _signedUrlCache[path];
    }

    if (widget.getSignedUrl != null) {
      final url = await widget.getSignedUrl!(path);
      if (url != null) {
        _signedUrlCache[path] = url;
      }
      return url;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.state.messages;

    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Loading indicator at top (for loading more)
        if (widget.state.isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(LynewedSpacing.sm),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: LynewedColors.primary,
              ),
            ),
          ),

        // Messages list (reversed - newest at bottom)
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true, // Newest messages at bottom
            padding: const EdgeInsets.symmetric(vertical: LynewedSpacing.md),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isOwnMessage = message.profileId == widget.currentUserId;

              // Check if we need to show date separator
              final showDateSeparator = _shouldShowDateSeparator(index);

              return Column(
                children: [
                  if (showDateSeparator)
                    _buildDateSeparator(message.createdAt),
                  _buildMessageBubble(message, isOwnMessage),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LynewedSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: LynewedColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: LynewedSpacing.md),
            Text(
              'Aucun message',
              style: LynewedTextStyles.titleMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
            const SizedBox(height: LynewedSpacing.sm),
            Text(
              'Commencez la conversation !',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowDateSeparator(int index) {
    final messages = widget.state.messages;
    if (index == messages.length - 1) return true; // Always show for oldest

    final currentMessage = messages[index];
    final previousMessage = messages[index + 1]; // Previous in list = newer

    final currentDate = DateTime(
      currentMessage.createdAt.year,
      currentMessage.createdAt.month,
      currentMessage.createdAt.day,
    );
    final previousDate = DateTime(
      previousMessage.createdAt.year,
      previousMessage.createdAt.month,
      previousMessage.createdAt.day,
    );

    return currentDate != previousDate;
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LynewedSpacing.md),
      child: Row(
        children: [
          const Expanded(child: Divider(color: LynewedColors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LynewedSpacing.md),
            child: Text(
              _formatDate(date),
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ),
          const Expanded(child: Divider(color: LynewedColors.border)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isOwnMessage) {
    return FutureBuilder<String?>(
      future: message.attachmentUrl != null
          ? _getSignedUrl(message.attachmentUrl!)
          : Future.value(null),
      builder: (context, snapshot) {
        return MessageBubble(
          message: message,
          isOwnMessage: isOwnMessage,
          senderName: isOwnMessage ? null : widget.otherProfileName,
          senderAvatarUrl: isOwnMessage ? null : widget.otherProfileAvatarUrl,
          signedMediaUrl: snapshot.data,
          onLongPress: widget.onMessageLongPress,
          onImageTap: widget.onImageTap != null
              ? () => widget.onImageTap!(message)
              : null,
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return "Aujourd'hui";
    } else if (messageDate == yesterday) {
      return 'Hier';
    } else {
      final months = [
        'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }
}
