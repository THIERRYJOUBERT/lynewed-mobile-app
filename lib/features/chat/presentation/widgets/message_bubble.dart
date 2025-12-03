/// Message bubble widget - Clean Architecture
/// 
/// Displays a single chat message with avatar, content, and actions.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';
import 'audio_player_widget.dart';

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
    this.showAvatar = true,
    this.needsLargeSpacing = false,
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

  /// Whether to show the avatar (false for grouped consecutive messages)
  final bool showAvatar;

  /// Whether this message needs 30px spacing (different sender above)
  final bool needsLargeSpacing;

  /// Callback when message is long pressed (for actions)
  final MessageActionCallback? onLongPress;

  /// Callback when image is tapped (for fullscreen view)
  final VoidCallback? onImageTap;

  /// Pre-signed URL for media attachments
  final String? signedMediaUrl;

  @override
  Widget build(BuildContext context) {
    // Chat spacing rules (with reverse:true ListView, "top" is visually below):
    // - 8px between messages from same user
    // - 30px between messages from different users
    // The spacing is applied as "top" padding which visually separates from the message above
    final double topSpacing = needsLargeSpacing 
        ? LynewedSpacing.chatMessageDifferentUser 
        : LynewedSpacing.chatMessageSameUser;
    
    return Padding(
      padding: EdgeInsets.only(
        left: isOwnMessage ? 48.0 : LynewedSpacing.md,
        right: isOwnMessage ? LynewedSpacing.md : 48.0,
        top: topSpacing,
        bottom: 0.0,
      ),
      child: GestureDetector(
        onLongPress: onLongPress != null ? () => onLongPress!(message) : null,
        child: Row(
          mainAxisAlignment:
              isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isOwnMessage) ...[
              showAvatar ? _buildAvatar() : const SizedBox(width: 36), // Placeholder for alignment
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
    const double avatarSize = 36.0;
    const double imageSize = 32.0; // Slightly smaller to prevent crop

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: LynewedColors.surface,
        border: Border.all(color: LynewedColors.border, width: 1),
      ),
      child: Center(
        child: senderAvatarUrl != null && senderAvatarUrl!.isNotEmpty
            ? ClipOval(
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: CachedNetworkImage(
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
                  ),
                ),
              )
            : const Icon(
                Icons.person,
                size: 16,
                color: LynewedColors.textSecondary,
              ),
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
    // IMPORTANT: Only use signed URL for audio playback
    // The raw attachmentUrl is just a path, not a valid URL
    final mediaUrl = signedMediaUrl;
    
    // Show loading state while waiting for signed URL
    if (mediaUrl == null || mediaUrl.isEmpty) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isOwnMessage 
                    ? LynewedColors.textOnPrimary 
                    : LynewedColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Loading audio...',
              style: LynewedTextStyles.labelSmall.copyWith(
                color: isOwnMessage 
                    ? LynewedColors.textOnPrimary.withValues(alpha: 0.7)
                    : LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: AudioPlayerWidget(
        audioUrl: mediaUrl,
        isOwnMessage: isOwnMessage,
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
      return 'Yesterday $time';
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
