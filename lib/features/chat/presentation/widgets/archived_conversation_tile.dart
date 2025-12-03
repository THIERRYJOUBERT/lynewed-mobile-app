/// Archived conversation tile widget - Clean Architecture
/// 
/// Displays an archived or blocked conversation with restore/unblock action.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';

/// Tile widget for an archived conversation
class ArchivedConversationTile extends StatelessWidget {
  const ArchivedConversationTile({
    super.key,
    required this.conversation,
    required this.onAction,
  });

  final Conversation conversation;
  final VoidCallback onAction;

  bool get _isBlocked => conversation.conversationStatus == ConversationStatus.blocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: LynewedColors.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Avatar
          _buildAvatar(),
          
          const SizedBox(width: 12),
          
          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isBlocked ? 'Blocked' : 'Archived',
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: _isBlocked ? LynewedColors.error : LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Action button
          SizedBox(
            height: 32,
            child: TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: _isBlocked ? LynewedColors.error : LynewedColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(_isBlocked ? 'Unblock' : 'Restore'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = conversation.displayAvatarUrl;
    
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: _isBlocked
            ? Border.all(
                color: LynewedColors.error.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? _isBlocked
                ? ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.grey,
                      BlendMode.saturation,
                    ),
                    child: Image.network(
                      avatarUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    ),
                  )
                : Image.network(
                    avatarUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 44,
      height: 44,
      color: LynewedColors.gray200,
      child: Icon(
        _isBlocked ? Icons.person_off : Icons.person,
        color: LynewedColors.gray300,
        size: 22,
      ),
    );
  }
}
