/// Message bubble widget - Clean Architecture
/// 
/// Displays a single chat message with avatar, content, and actions.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';

/// Callback for message actions
typedef MessageActionCallback = void Function(ChatMessage message);

/// Widget displaying a single message bubble
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isOwnMessage,
    this.senderName,
    this.senderAvatarUrl,
    this.onLongPress,
    this.onImageTap,
    this.signedMediaUrl,
  });

  /// The message to display
  final ChatMessage message;

  /// Whether this message was sent by the current user
  final bool isOwnMessage;

  /// Sender's display name (for other's messages)
  final String? senderName;

  /// Sender's avatar URL (for other's messages)
  final String? senderAvatarUrl;

  /// Callback when message is long pressed (for actions)
  final MessageActionCallback? onLongPress;

  /// Callback when image is tapped (for fullscreen view)
  final VoidCallback? onImageTap;

  /// Pre-signed URL for media attachments
  final String? signedMediaUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isOwnMessage ? 48.0 : LynewedSpacing.md,
        right: isOwnMessage ? LynewedSpacing.md : 48.0,
        bottom: LynewedSpacing.sm,
      ),
      child: GestureDetector(
        onLongPress: onLongPress != null ? () => onLongPress!(message) : null,
        child: Row(
          mainAxisAlignment:
              isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isOwnMessage) ...[
              _buildAvatar(),
              const SizedBox(width: LynewedSpacing.sm),
            ],
            Flexible(
              child: _buildBubble(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: LynewedColors.surface,
        border: Border.all(color: LynewedColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: senderAvatarUrl != null && senderAvatarUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: senderAvatarUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => const Icon(
                Icons.person,
                size: 16,
                color: LynewedColors.textSecondary,
              ),
              errorWidget: (_, __, ___) => const Icon(
                Icons.person,
                size: 16,
                color: LynewedColors.textSecondary,
              ),
            )
          : const Icon(
              Icons.person,
              size: 16,
              color: LynewedColors.textSecondary,
            ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isOwnMessage ? LynewedColors.primary : LynewedColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isOwnMessage ? 16 : 4),
          bottomRight: Radius.circular(isOwnMessage ? 4 : 16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sender name (for other's messages)
          if (!isOwnMessage && senderName != null) ...[
            Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 8,
              ),
              child: Text(
                senderName!,
                style: LynewedTextStyles.labelSmall.copyWith(
                  color: LynewedColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          // Message content
          _buildContent(context),

          // Timestamp
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 8,
            ),
            child: Text(
              _formatTime(message.createdAt),
              style: LynewedTextStyles.labelSmall.copyWith(
                color: isOwnMessage
                    ? LynewedColors.textOnPrimary.withValues(alpha: 0.7)
                    : LynewedColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (message.messageType) {
      case MessageType.text:
        return _buildTextContent();
      case MessageType.image:
        return _buildImageContent();
      case MessageType.audio:
        return _buildAudioContent();
    }
  }

  Widget _buildTextContent() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
      ),
      child: Text(
        message.content ?? '',
        style: LynewedTextStyles.bodyMedium.copyWith(
          color: isOwnMessage
              ? LynewedColors.textOnPrimary
              : LynewedColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    final mediaUrl = signedMediaUrl ?? message.attachmentUrl;

    return GestureDetector(
      onTap: onImageTap,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 240,
          maxHeight: 240,
        ),
        margin: const EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: mediaUrl != null
              ? CachedNetworkImage(
                  imageUrl: mediaUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 200,
                    height: 150,
                    color: LynewedColors.surface,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: LynewedColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 200,
                    height: 150,
                    color: LynewedColors.surface,
                    child: const Icon(
                      Icons.broken_image,
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                )
              : Container(
                  width: 200,
                  height: 150,
                  color: LynewedColors.surface,
                  child: const Icon(
                    Icons.image,
                    color: LynewedColors.textSecondary,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAudioContent() {
    // Simple audio indicator - actual player would need more implementation
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOwnMessage
            ? LynewedColors.textOnPrimary.withValues(alpha: 0.1)
            : LynewedColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_filled,
            color: isOwnMessage
                ? LynewedColors.textOnPrimary
                : LynewedColors.primary,
            size: 32,
          ),
          const SizedBox(width: 8),
          // Waveform placeholder
          Row(
            children: List.generate(
              12,
              (index) => Container(
                width: 3,
                height: 8 + (index % 3) * 6.0,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: isOwnMessage
                      ? LynewedColors.textOnPrimary.withValues(alpha: 0.6)
                      : LynewedColors.primary.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final time = '$hour:$minute';

    if (messageDate == today) {
      return time;
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hier $time';
    } else {
      return '${dateTime.day}/${dateTime.month} $time';
    }
  }
}

/// Helper to check if current user is the message author
extension MessageOwnership on ChatMessage {
  bool get isOwnMessage {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    return profileId == currentUserId;
  }
}
