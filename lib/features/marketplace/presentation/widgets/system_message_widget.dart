/// System message widget for marketplace chat.
///
/// Displays a centered, subtle status message in the conversation
/// (e.g., "Offer accepted!", "Offer declined").
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/marketplace_message.dart';

/// A centered system message displayed as a divider in the chat.
///
/// Not aligned to left or right - appears centered with subtle styling.
class SystemMessageWidget extends StatelessWidget {
  /// Creates a system message widget.
  const SystemMessageWidget({
    required this.message,
    this.needsLargeSpacing = false,
    super.key,
  });

  /// The system message to display.
  final MarketplaceMessage message;

  /// Whether this message needs 30px spacing.
  final bool needsLargeSpacing;

  @override
  Widget build(BuildContext context) {
    final double topSpacing = needsLargeSpacing
        ? LynewedSpacing.chatMessageDifferentUser
        : LynewedSpacing.chatMessageSameUser;

    return Padding(
      padding: EdgeInsets.only(
        left: 48.0,
        right: 48.0,
        top: topSpacing,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: LynewedColors.gray100.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.content,
            style: LynewedTextStyles.labelSmall.copyWith(
              color: LynewedColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
