/// Offer bubble widget for marketplace chat.
///
/// Displays an offer-type message as a styled card in the conversation.
/// Shows amount, optional message, status badge, and action buttons
/// (Accept/Decline for seller, Proceed to Checkout for buyer).
library;

import 'dart:convert';

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/marketplace_message.dart';

/// A chat bubble specifically for offer-type messages.
///
/// Renders differently based on offer status and whether the viewer
/// is the buyer (sender) or seller (receiver).
class OfferBubbleWidget extends StatelessWidget {
  /// Creates an offer bubble widget.
  const OfferBubbleWidget({
    required this.message,
    required this.isMe,
    this.offerStatus = 'pending',
    this.senderName,
    this.showAvatar = true,
    this.needsLargeSpacing = false,
    this.onAccept,
    this.onDecline,
    this.onProceedToCheckout,
    super.key,
  });

  /// The offer message.
  final MarketplaceMessage message;

  /// Whether this message was sent by the current user (buyer).
  final bool isMe;

  /// Current status of the linked offer.
  final String offerStatus;

  /// Sender name for display.
  final String? senderName;

  /// Whether to show sender info.
  final bool showAvatar;

  /// Whether this message needs 30px spacing.
  final bool needsLargeSpacing;

  /// Called when seller accepts the offer.
  final VoidCallback? onAccept;

  /// Called when seller declines the offer.
  final VoidCallback? onDecline;

  /// Called when buyer proceeds to checkout (after acceptance).
  final VoidCallback? onProceedToCheckout;

  bool get _isPending => offerStatus == 'pending';
  bool get _isAccepted => offerStatus == 'accepted';

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
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            showAvatar
                ? _buildAvatar()
                : const SizedBox(width: 36),
            const SizedBox(width: LynewedSpacing.sm),
          ],
          Flexible(child: _buildCard()),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: LynewedColors.surface,
        border: Border.all(color: LynewedColors.border, width: 1),
      ),
      child: Center(
        child: Text(
          senderName != null && senderName!.isNotEmpty
              ? senderName![0].toUpperCase()
              : '?',
          style: LynewedTextStyles.labelSmall.copyWith(
            color: LynewedColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    // Parse offer data from JSON content.
    final offerData = _parseOfferContent();
    final amountCents = offerData['amount_cents'] as int? ?? 0;
    final offerMessage = offerData['message'] as String?;
    final dollars = (amountCents / 100).toStringAsFixed(2);

    return Container(
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isPending
              ? LynewedColors.primary.withValues(alpha: 0.3)
              : _isAccepted
                  ? LynewedColors.success.withValues(alpha: 0.3)
                  : LynewedColors.gray200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with offer icon.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _isPending
                  ? LynewedColors.primary.withValues(alpha: 0.06)
                  : _isAccepted
                      ? LynewedColors.success.withValues(alpha: 0.06)
                      : LynewedColors.gray100.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 16,
                  color: _isPending
                      ? LynewedColors.primary
                      : _isAccepted
                          ? LynewedColors.success
                          : LynewedColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  isMe ? 'Your Offer' : 'Offer Received',
                  style: LynewedTextStyles.labelLarge.copyWith(
                    color: _isPending
                        ? LynewedColors.primary
                        : _isAccepted
                            ? LynewedColors.success
                            : LynewedColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(),
              ],
            ),
          ),

          // Amount.
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Text(
              '\$$dollars',
              style: LynewedTextStyles.headlineMedium.copyWith(
                color: LynewedColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Optional message.
          if (offerMessage != null && offerMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
              child: Text(
                offerMessage,
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ),

          // Timestamp.
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Text(
              _formatTime(message.createdAt),
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),

          // Action buttons.
          if (_isPending && !isMe) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: LynewedButton(
                      text: 'Decline',
                      type: LynewedButtonType.secondary,
                      onPressed: onDecline,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LynewedButton(
                      text: 'Accept',
                      type: LynewedButtonType.primary,
                      onPressed: onAccept,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_isAccepted && isMe) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: SizedBox(
                width: double.infinity,
                child: LynewedButton(
                  text: 'Proceed to Checkout',
                  type: LynewedButtonType.primary,
                  onPressed: onProceedToCheckout,
                ),
              ),
            ),
          ] else
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final String label;
    final Color color;

    if (_isPending) {
      label = 'Pending';
      color = LynewedColors.warning;
    } else if (_isAccepted) {
      label = 'Accepted';
      color = LynewedColors.success;
    } else {
      label = offerStatus[0].toUpperCase() + offerStatus.substring(1);
      color = LynewedColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: LynewedTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }

  Map<String, dynamic> _parseOfferContent() {
    try {
      return jsonDecode(message.content) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{};
    }
  }

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
