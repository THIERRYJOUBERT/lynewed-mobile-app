/// Conversation actions sheet - Clean Architecture
/// 
/// Bottom sheet for conversation actions (archive, etc.)
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';

/// Sheet for conversation actions
class ConversationActionsSheet extends StatelessWidget {
  const ConversationActionsSheet({
    super.key,
    required this.conversation,
    required this.onArchive,
  });

  final Conversation conversation;
  final VoidCallback onArchive;

  /// Show the sheet
  static Future<void> show({
    required BuildContext context,
    required Conversation conversation,
    required VoidCallback onArchive,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ConversationActionsSheet(
        conversation: conversation,
        onArchive: onArchive,
      ),
    );
  }

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
                      conversation.displayName,
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
            _buildActionTile(
              context: context,
              icon: Icons.archive_outlined,
              label: 'Archiver la conversation',
              onTap: () {
                Navigator.of(context).pop();
                onArchive();
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = conversation.displayAvatarUrl;
    
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
}
