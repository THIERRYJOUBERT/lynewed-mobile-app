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
    this.initialMessage,
    this.showInitialMessage = false,
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

  /// Initial message from contact request (displayed as first message)
  final String? initialMessage;

  /// Whether to show the initial message (only for pending requests)
  final bool showInitialMessage;

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
    final hasInitialMessage = widget.showInitialMessage && 
        widget.initialMessage != null && 
        widget.initialMessage!.isNotEmpty;

    // Show empty state only if no messages AND no initial message to show
    if (messages.isEmpty && !hasInitialMessage) {
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
            // Add 1 to count if we have an initial message to show
            itemCount: messages.length + (hasInitialMessage ? 1 : 0),
            itemBuilder: (context, index) {
              // If we have an initial message, it's the "oldest" message (last in reversed list)
              if (hasInitialMessage && index == messages.length) {
                return _buildInitialMessageBubble();
              }

              final message = messages[index];
              final isOwnMessage = message.profileId == widget.currentUserId;

              // Check if we need to show date separator
              final showDateSeparator = _shouldShowDateSeparator(index, hasInitialMessage);

              // Check if we should show avatar (only for last message in a sender group)
              final showAvatar = _shouldShowAvatar(index, hasInitialMessage);

              // Check if this message needs 30px spacing (different sender above)
              final needsLargeSpacing = _needsLargeSpacing(index, hasInitialMessage);

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

  /// Build the initial message bubble from contact request
  Widget _buildInitialMessageBubble() {
    return Padding(
      padding: const EdgeInsets.only(
        left: LynewedSpacing.md,
        right: LynewedSpacing.xl * 2, // More space on right for received messages
        bottom: LynewedSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: LynewedSpacing.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LynewedColors.surface,
              border: Border.all(color: LynewedColors.border),
            ),
            child: widget.otherProfileAvatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      widget.otherProfileAvatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 16,
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 16,
                    color: LynewedColors.textSecondary,
                  ),
          ),
          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: LynewedSpacing.md,
                vertical: LynewedSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: LynewedColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: LynewedColors.border),
              ),
              child: Text(
                widget.initialMessage!,
                style: LynewedTextStyles.bodyMedium,
              ),
            ),
          ),
        ],
      ),
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

  bool _shouldShowDateSeparator(int index, bool hasInitialMessage) {
    final messages = widget.state.messages;
    
    // If this is the last real message and there's an initial message after it
    if (index == messages.length - 1 && hasInitialMessage) {
      return true; // Show separator before initial message
    }
    
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

  bool _shouldShowAvatar(int index, bool hasInitialMessage) {
    final messages = widget.state.messages;
    
    // Always show for the last message (oldest, which is at bottom of reversed list)
    // But if there's an initial message, the last real message is not the oldest
    if (index == messages.length - 1 && !hasInitialMessage) return true;

    final currentMessage = messages[index];
    
    // If this is the last real message and there's an initial message after it
    // The initial message is from the "other" person, so check if current is from same sender
    if (index == messages.length - 1 && hasInitialMessage) {
      // Initial message is from other person (not current user)
      return currentMessage.profileId == widget.currentUserId;
    }
    
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
  bool _needsLargeSpacing(int index, bool hasInitialMessage) {
    final messages = widget.state.messages;
    
    // Last message in list (oldest, at top of screen) - no spacing above it
    // Unless there's an initial message, then we need to check
    if (index == messages.length - 1 && !hasInitialMessage) return false;
    
    // If this is the last real message and there's an initial message
    if (index == messages.length - 1 && hasInitialMessage) {
      // Initial message is from other person, so if current is from current user, need spacing
      return messages[index].profileId == widget.currentUserId;
    }
    
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
    
    // For public rooms, get author info from state cache
    String? senderName;
    String? senderAvatarUrl;
    if (!isOwnMessage) {
      if (widget.state.isPublicRoom) {
        // Public room: get author from cache
        final author = widget.state.getAuthor(message.profileId);
        senderName = author?.fullName;
        senderAvatarUrl = author?.avatarUrl;
      } else {
        // Private room: use other participant info
        senderName = widget.otherProfileName;
        senderAvatarUrl = widget.otherProfileAvatarUrl;
      }
    }
    
    return MessageBubble(
      key: ValueKey('message_${message.id}_${signedUrl != null}'),
      message: message,
      isOwnMessage: isOwnMessage,
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
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
