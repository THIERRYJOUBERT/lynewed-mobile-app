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
  final Set<String> _loadingUrls = {}; // Track URLs being loaded

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Pre-load signed URLs for new messages with attachments
    _preloadSignedUrls();
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

  /// Pre-load signed URLs for all messages with attachments
  void _preloadSignedUrls() {
    for (final message in widget.state.messages) {
      if (message.attachmentUrl != null && 
          !_signedUrlCache.containsKey(message.attachmentUrl!) &&
          !_loadingUrls.contains(message.attachmentUrl!)) {
        _loadSignedUrl(message.attachmentUrl!);
      }
    }
  }

  /// Load a signed URL asynchronously and trigger rebuild when done
  Future<void> _loadSignedUrl(String path) async {
    if (_loadingUrls.contains(path)) return;
    _loadingUrls.add(path);

    if (widget.getSignedUrl != null) {
      try {
        final url = await widget.getSignedUrl!(path);
        if (url != null && mounted) {
          setState(() {
            _signedUrlCache[path] = url;
          });
        }
      } catch (e) {
        debugPrint('MessageList._loadSignedUrl: ERROR $e');
      }
    }
    
    _loadingUrls.remove(path);
  }

  /// Get cached signed URL (synchronous)
  String? _getCachedSignedUrl(String? path) {
    if (path == null) return null;
    
    // If not cached yet, trigger async load
    if (!_signedUrlCache.containsKey(path) && !_loadingUrls.contains(path)) {
      _loadSignedUrl(path);
    }
    
    return _signedUrlCache[path];
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

              // Check if we should show avatar (only for last message in a sender group)
              final showAvatar = _shouldShowAvatar(index);

              // Check if this message needs 30px spacing (different sender above)
              final needsLargeSpacing = _needsLargeSpacing(index);

              return Column(
                children: [
                  if (showDateSeparator)
                    _buildDateSeparator(message.createdAt),
                  _buildMessageBubble(message, isOwnMessage, showAvatar, needsLargeSpacing),
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
              'No messages',
              style: LynewedTextStyles.titleMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
            const SizedBox(height: LynewedSpacing.sm),
            Text(
              'Start the conversation!',
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

  bool _shouldShowAvatar(int index) {
    final messages = widget.state.messages;
    
    // Always show for the last message (oldest, which is at bottom of reversed list)
    if (index == messages.length - 1) return true;

    final currentMessage = messages[index];
    final nextMessage = messages[index + 1]; // Next in list = older in time

    // Show avatar if the next older message is from a different sender
    // or if there's a significant time gap (> 2 minutes)
    if (currentMessage.profileId != nextMessage.profileId) {
      return true;
    }

    final timeDiff = currentMessage.createdAt.difference(nextMessage.createdAt).inMinutes;
    return timeDiff.abs() > 2;
  }

  /// Check if this message needs extra spacing (30px) because the NEXT message
  /// visually (which is the message BELOW in the reversed list = index - 1)
  /// is from a different sender.
  /// 
  /// With reverse:true ListView:
  /// - index 0 = newest message (bottom of screen)
  /// - index N = oldest message (top of screen)
  /// - Visually: index 0 is at bottom, index N is at top
  /// - "top" padding pushes the item DOWN (away from older messages)
  /// 
  /// So we need 30px spacing when the message ABOVE us (older = index + 1) 
  /// is from a different sender.
  bool _needsLargeSpacing(int index) {
    final messages = widget.state.messages;
    
    // Last message in list (oldest, at top of screen) - no spacing above it
    if (index == messages.length - 1) return false;
    
    final currentMessage = messages[index];
    final olderMessage = messages[index + 1]; // Older message = visually above

    // Need 30px if the message above is from a different sender
    return currentMessage.profileId != olderMessage.profileId;
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

  Widget _buildMessageBubble(ChatMessage message, bool isOwnMessage, bool showAvatar, bool needsLargeSpacing) {
    // Use cached signed URL (synchronous) - triggers async load if not cached
    final signedUrl = _getCachedSignedUrl(message.attachmentUrl);
    
    return MessageBubble(
      key: ValueKey('message_${message.id}_${signedUrl != null}'),
      message: message,
      isOwnMessage: isOwnMessage,
      senderName: isOwnMessage ? null : widget.otherProfileName,
      senderAvatarUrl: isOwnMessage ? null : widget.otherProfileAvatarUrl,
      showAvatar: showAvatar,
      needsLargeSpacing: needsLargeSpacing,
      signedMediaUrl: signedUrl,
      onLongPress: widget.onMessageLongPress,
      onImageTap: widget.onImageTap != null
          ? () => widget.onImageTap!(message)
          : null,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}
