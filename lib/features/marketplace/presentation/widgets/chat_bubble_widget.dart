/// Chat bubble widget for marketplace messages.
///
/// Displays a single message with sender alignment, colors, and timestamp.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/marketplace_message.dart';

/// A message bubble in the marketplace chat.
///
/// Aligns to the right for current user messages (primary color),
/// and to the left for other user messages (gray background).
class ChatBubbleWidget extends StatelessWidget {
  /// Creates a chat bubble widget.
  const ChatBubbleWidget({
    required this.message,
    required this.isMe,
    super.key,
  });

  /// The message to display.
  final MarketplaceMessage message;

  /// Whether this message was sent by the current user.
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: LynewedSpacing.md,
          vertical: LynewedSpacing.xs,
        ),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? LynewedColors.primary : LynewedColors.gray200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color:
                    isMe ? LynewedColors.textOnDark : LynewedColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: LynewedTextStyles.labelSmall.copyWith(
                color: isMe
                    ? LynewedColors.textOnDark.withValues(alpha: 0.7)
                    : LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats a DateTime into a human-readable time string.
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    final timeStr =
        '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

    if (diff.inDays > 0) {
      return '$timeStr - ${time.day}/${time.month}';
    }
    return timeStr;
  }
}
