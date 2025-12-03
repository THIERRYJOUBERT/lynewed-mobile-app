/// Conversation actions sheet - Clean Architecture
/// 
/// Bottom sheet for conversation actions (archive, report, block).
/// Block User action moved here from MessageActionsSheet for better UX.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';
import 'report_user_sheet.dart';

/// Callback for report action (conversation context)
typedef ConversationReportCallback = Future<void> Function(ReportReason reason, String? details);

/// Sheet for conversation actions
class ConversationActionsSheet extends StatefulWidget {
  const ConversationActionsSheet({
    super.key,
    required this.conversation,
    required this.onArchive,
    this.onBlock,
    this.onReport,
  });

  final Conversation conversation;
  final VoidCallback onArchive;
  final VoidCallback? onBlock;
  final ConversationReportCallback? onReport;

  /// Show the sheet
  static Future<void> show({
    required BuildContext context,
    required Conversation conversation,
    required VoidCallback onArchive,
    VoidCallback? onBlock,
    ConversationReportCallback? onReport,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ConversationActionsSheet(
        conversation: conversation,
        onArchive: onArchive,
        onBlock: onBlock,
        onReport: onReport,
      ),
    );
  }

  @override
  State<ConversationActionsSheet> createState() => _ConversationActionsSheetState();
}

class _ConversationActionsSheetState extends State<ConversationActionsSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LynewedComponentStyles.bottomSheetDecoration(),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: LynewedColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  
                  // Name
                  Expanded(
                    child: Text(
                      widget.conversation.displayName,
                      style: LynewedTextStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Close button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    iconSize: 24,
                    color: LynewedColors.textSecondary,
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1, color: LynewedColors.gray200),
            
            // Actions
            if (widget.onReport != null)
              _buildActionTile(
                context: context,
                icon: Icons.flag_outlined,
                label: 'Report User',
                onTap: () => _showReportUserOptions(context),
              ),
            
            if (widget.onBlock != null)
              _buildActionTile(
                context: context,
                icon: Icons.block_outlined,
                label: 'Block User',
                color: LynewedColors.error,
                onTap: () => _showBlockConfirmation(context),
              ),
            
            _buildActionTile(
              context: context,
              icon: Icons.archive_outlined,
              label: 'Archive Conversation',
              onTap: () {
                Navigator.of(context).pop();
                widget.onArchive();
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = widget.conversation.displayAvatarUrl;
    
    return ClipOval(
      child: avatarUrl != null && avatarUrl.isNotEmpty
          ? Image.network(
              avatarUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 40,
      height: 40,
      color: LynewedColors.gray200,
      child: const Icon(
        Icons.person,
        color: LynewedColors.gray300,
        size: 24,
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: color ?? LynewedColors.textPrimary,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: color ?? LynewedColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportUserOptions(BuildContext sheetContext) {
    Navigator.of(sheetContext).pop();
    
    // Use the existing ReportUserSheet (same as professional_details_sheet)
    ReportUserSheet.show(
      context: context,
      userName: widget.conversation.displayName,
      userAvatarUrl: widget.conversation.displayAvatarUrl,
      onReport: (reason, details) async {
        await widget.onReport?.call(reason, details);
      },
    );
  }

  void _showBlockConfirmation(BuildContext sheetContext) {
    Navigator.of(sheetContext).pop();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Block User'),
        content: Text(
          'Are you sure you want to block ${widget.conversation.displayName}?\n\n'
          'You will no longer receive messages from this user.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.onBlock?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: LynewedColors.error,
              foregroundColor: LynewedColors.textOnPrimary,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}
