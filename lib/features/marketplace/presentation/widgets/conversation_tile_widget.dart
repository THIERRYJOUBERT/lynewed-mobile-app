/// Conversation tile widget for marketplace chat list.
///
/// Displays a conversation summary with listing info, other user info,
/// last message preview, time, and unread badge.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/marketplace_conversation.dart';

/// A tile representing a single conversation in the chat list.
///
/// Shows:
/// - Listing cover image (or placeholder)
/// - Listing title + other user name
/// - Last message preview (truncated)
/// - Time of last message
/// - Unread count badge
class ConversationTileWidget extends StatelessWidget {
  /// Creates a conversation tile widget.
  const ConversationTileWidget({
    required this.conversation,
    required this.onTap,
    super.key,
  });

  /// The conversation data to display.
  final MarketplaceConversation conversation;

  /// Callback when the tile is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: LynewedSpacing.xl,
          vertical: LynewedSpacing.md,
        ),
        child: Row(
          children: [
            // Avatar or listing cover placeholder.
            _buildAvatar(),
            SizedBox(width: LynewedSpacing.md),

            // Text content.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Listing title.
                  Text(
                    conversation.listingTitle,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: conversation.hasUnread
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Other user name.
                  Text(
                    conversation.otherUserName,
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (conversation.lastMessage != null) ...[
                    const SizedBox(height: 4),
                    // Last message preview.
                    Text(
                      conversation.lastMessage!,
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: conversation.hasUnread
                            ? LynewedColors.textPrimary
                            : LynewedColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: LynewedSpacing.sm),

            // Time and unread badge column.
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (conversation.lastMessageTime != null)
                  Text(
                    _formatTime(conversation.lastMessageTime!),
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                if (conversation.hasUnread) ...[
                  const SizedBox(height: 4),
                  _buildUnreadBadge(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (conversation.listingCoverUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          conversation.listingCoverUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: LynewedColors.gray200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.storefront_outlined,
        color: LynewedColors.gray300,
        size: 24,
      ),
    );
  }

  Widget _buildUnreadBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: LynewedColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${conversation.unreadCount}',
        style: LynewedTextStyles.labelSmall.copyWith(
          color: LynewedColors.textOnDark,
          fontSize: 11,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 7) {
      return '${time.day}/${time.month}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    }
    return 'Now';
  }
}
