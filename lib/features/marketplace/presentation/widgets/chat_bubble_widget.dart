/// Chat bubble widget for marketplace messages.
///
/// Displays a single message with sender alignment, pointed corners,
/// avatar, and timestamp. Supports text, image, audio, and document types.
/// Inspired by the main chat MessageBubble for visual consistency.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/features/chat/presentation/widgets/audio_player_widget.dart';
import '../../domain/entities/marketplace_message.dart';

/// Callback for message actions (long press).
typedef MarketplaceMessageCallback = void Function(MarketplaceMessage message);

/// A message bubble in the marketplace chat.
///
/// Features:
/// - Pointed corners (4px on sender side, 16px elsewhere)
/// - Avatar for received messages (36px circle)
/// - Sender name above received messages
/// - Smart spacing (8px same sender, 30px different sender)
/// - Multi-type: text, image, audio, document
class ChatBubbleWidget extends StatelessWidget {
  /// Creates a chat bubble widget.
  const ChatBubbleWidget({
    required this.message,
    required this.isMe,
    this.senderName,
    this.senderAvatarUrl,
    this.showAvatar = true,
    this.needsLargeSpacing = false,
    this.onLongPress,
    this.onImageTap,
    this.signedMediaUrl,
    super.key,
  });

  /// The message to display.
  final MarketplaceMessage message;

  /// Whether this message was sent by the current user.
  final bool isMe;

  /// Sender's display name (for other's messages).
  final String? senderName;

  /// Sender's avatar URL (for other's messages).
  final String? senderAvatarUrl;

  /// Whether to show the avatar (false for grouped consecutive messages).
  final bool showAvatar;

  /// Whether this message needs 30px spacing (different sender above).
  final bool needsLargeSpacing;

  /// Callback when message is long pressed (for actions).
  final MarketplaceMessageCallback? onLongPress;

  /// Callback when image or document is tapped.
  final VoidCallback? onImageTap;

  /// Pre-signed URL for media attachments.
  final String? signedMediaUrl;

  @override
  Widget build(BuildContext context) {
    final double topSpacing = needsLargeSpacing
        ? LynewedSpacing.chatMessageDifferentUser
        : LynewedSpacing.chatMessageSameUser;

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 48.0 : LynewedSpacing.md,
        right: isMe ? LynewedSpacing.md : 48.0,
        top: topSpacing,
      ),
      child: GestureDetector(
        onLongPress:
            onLongPress != null ? () => onLongPress!(message) : null,
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              showAvatar
                  ? _buildAvatar()
                  : const SizedBox(width: 36), // Placeholder for alignment
              const SizedBox(width: LynewedSpacing.sm),
            ],
            Flexible(child: _buildBubble(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    const double avatarSize = 36.0;
    const double imageSize = 32.0;

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
        color: isMe ? LynewedColors.primary : LynewedColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sender name (for other's messages, first in group)
          if (!isMe && senderName != null && showAvatar) ...[
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
              child: Text(
                senderName!,
                style: LynewedTextStyles.labelSmall.copyWith(
                  color: LynewedColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          // Message content
          _buildContent(context),

          // Timestamp
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
            child: Text(
              _formatTime(message.createdAt),
              style: LynewedTextStyles.labelSmall.copyWith(
                color: isMe
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
    if (message.isImage) return _buildImageContent();
    if (message.isAudio) return _buildAudioContent();
    if (message.isDocument) return _buildDocumentContent();
    return _buildTextContent();
  }

  Widget _buildTextContent() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
      child: Text(
        message.content,
        style: LynewedTextStyles.bodyMedium.copyWith(
          color:
              isMe ? LynewedColors.textOnPrimary : LynewedColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    final mediaUrl = signedMediaUrl ?? message.attachmentUrl;

    return GestureDetector(
      onTap: onImageTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240, maxHeight: 240),
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
    final mediaUrl = signedMediaUrl;

    // Show loading state while waiting for signed URL.
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
                color: isMe
                    ? LynewedColors.textOnPrimary
                    : LynewedColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Loading audio...',
              style: LynewedTextStyles.labelSmall.copyWith(
                color: isMe
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
        isOwnMessage: isMe,
      ),
    );
  }

  Widget _buildDocumentContent() {
    final fileName = message.attachmentName ?? 'Document.pdf';
    final fileSize = message.attachmentSize;

    return GestureDetector(
      onTap: onImageTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.white.withValues(alpha: 0.15)
              : LynewedColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // PDF icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.white.withValues(alpha: 0.2)
                    : LynewedColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                color:
                    isMe ? LynewedColors.textOnPrimary : LynewedColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            // File info
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fileName,
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: isMe
                          ? LynewedColors.textOnPrimary
                          : LynewedColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (fileSize != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatFileSize(fileSize),
                      style: LynewedTextStyles.labelSmall.copyWith(
                        color: isMe
                            ? LynewedColors.textOnPrimary
                                .withValues(alpha: 0.7)
                            : LynewedColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.download_outlined,
              color: isMe
                  ? LynewedColors.textOnPrimary.withValues(alpha: 0.7)
                  : LynewedColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Formats a DateTime into a human-readable time string.
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(dateTime.year, dateTime.month, dateTime.day);

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
