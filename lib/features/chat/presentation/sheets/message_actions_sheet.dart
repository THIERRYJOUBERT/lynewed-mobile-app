/// Message actions sheet - Clean Architecture
/// 
/// Bottom sheet for message actions (delete, report).
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';
import 'report_message_sheet.dart';

/// Callback for report action
typedef ReportCallback = Future<void> Function(ReportReason reason, String? details);

/// Bottom sheet for message actions
/// 
/// NOTE: Block User action moved to ConversationActionsSheet (long press on conversation)
/// This sheet only handles Report Message for other's messages.
class MessageActionsSheet extends StatelessWidget {
  const MessageActionsSheet({
    super.key,
    required this.message,
    required this.isOwnMessage,
    this.onDelete,
    this.onReport,
  });

  /// The message to act on
  final ChatMessage message;

  /// Whether this is the current user's message
  final bool isOwnMessage;

  /// Callback to delete message (own messages only)
  final VoidCallback? onDelete;

  /// Callback to report message (other's messages only)
  final ReportCallback? onReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LynewedComponentStyles.bottomSheetDecoration(),
      child: SafeArea(
        top: false,
        child: _buildMainOptions(context),
      ),
    );
  }

  Widget _buildMainOptions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          decoration: BoxDecoration(
            color: LynewedColors.gray200,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LynewedSpacing.md,
            vertical: LynewedSpacing.sm,
          ),
          child: Text(
            'Actions',
            style: LynewedTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const Divider(color: LynewedColors.border, height: 1),

        // Options
        if (isOwnMessage) ...[
          // Delete option (own messages)
          _buildOptionTile(
            context: context,
            icon: Icons.delete_outline,
            label: 'Delete Message',
            onTap: onDelete,
            isDestructive: true,
          ),
        ] else ...[
          // Report option (other's messages)
          // NOTE: Block User moved to ConversationActionsSheet
          _buildOptionTile(
            context: context,
            icon: Icons.flag_outlined,
            label: 'Report Message',
            onTap: () {
              Navigator.pop(context);
              // Open ReportMessageSheet with same design as ReportUserSheet
              ReportMessageSheet.show(
                context: context,
                onReport: (reason, details) async {
                  await onReport?.call(reason, details);
                },
              );
            },
          ),
        ],

        // Cancel
        _buildOptionTile(
          context: context,
          icon: Icons.close,
          label: 'Cancel',
          onTap: () => Navigator.pop(context),
        ),

        const SizedBox(height: LynewedSpacing.md),
      ],
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? LynewedColors.error : LynewedColors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LynewedSpacing.md,
          vertical: LynewedSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: LynewedSpacing.md),
            Text(
              label,
              style: LynewedTextStyles.bodyMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
