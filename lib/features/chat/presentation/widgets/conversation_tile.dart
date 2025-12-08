/// Conversation tile widget - Clean Architecture
/// 
/// Displays a conversation item in the list.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';

/// Tile widget for a conversation in the list
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onLongPress,
  });

  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  /// Whether this conversation is blocked
  bool get _isBlocked => conversation.conversationStatus == ConversationStatus.blocked;

  /// Whether this conversation is reported (pending review)
  bool get _isReported => conversation.conversationStatus == ConversationStatus.reportedPending;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: LynewedColors.surface, // Gris clair pour les items
          borderRadius: BorderRadius.circular(4), // 4px radius
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(),
            
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LynewedTextStyles.bodyMedium.copyWith(
                            fontWeight: conversation.unreadCount > 0 
                                ? FontWeight.w500 
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (conversation.lastMessageAt != null)
                        Text(
                          _formatTime(conversation.lastMessageAt!),
                          style: LynewedTextStyles.labelSmall.copyWith(
                            color: LynewedColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Last message and unread badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessagePreview.isNotEmpty 
                              ? conversation.lastMessagePreview 
                              : 'No messages',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LynewedTextStyles.bodySmall.copyWith(
                            color: LynewedColors.textSecondary,
                          ),
                        ),
                      ),
                      // Status badges
                      if (_isBlocked)
                        _buildStatusChip('Blocked', LynewedColors.error)
                      else if (_isReported)
                        _buildStatusChip('Reported', LynewedColors.warning)
                      else if (conversation.unreadCount > 0)
                        _buildUnreadBadge(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = conversation.displayAvatarUrl;
    
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
              )
            : _buildAvatarPlaceholder(),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      color: LynewedColors.gray200,
      child: const Icon(
        Icons.person,
        color: LynewedColors.gray300,
        size: 28,
      ),
    );
  }

  Widget _buildUnreadBadge() {
    return Container(
      height: 18,
      constraints: const BoxConstraints(minWidth: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: LynewedColors.primary,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Center(
        child: Text(
          conversation.unreadCount > 99 ? '99+' : conversation.unreadCount.toString(),
          style: LynewedTextStyles.labelSmall.copyWith(
            color: LynewedColors.textOnPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: LynewedTextStyles.labelSmall.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
