/// Widget for displaying a wedding group in a list.
///
/// Shows group name, member count, visibility badge (public/private),
/// and provides tap actions for navigation and management.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/wedding_group.dart';

/// Tile widget for displaying a wedding group.
///
/// Used in WeddingGroupsPage to show group details.
class WeddingGroupTile extends StatelessWidget {
  const WeddingGroupTile({
    super.key,
    required this.group,
    required this.onTap,
    this.onLongPress,
    this.onManageMembers,
    this.onEdit,
    this.onDelete,
  });

  /// The wedding group to display.
  final WeddingGroup group;

  /// Callback when the tile is tapped (navigate to chat).
  final VoidCallback onTap;

  /// Callback when the tile is long-pressed (show options).
  final VoidCallback? onLongPress;

  /// Callback to manage members.
  final VoidCallback? onManageMembers;

  /// Callback to edit the group.
  final VoidCallback? onEdit;

  /// Callback to delete the group.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: LynewedColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress ?? (group.canEdit ? () => _showOptionsSheet(context) : null),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Group icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getGroupColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getGroupIcon(),
                  color: _getGroupColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Group info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name with badges
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            group.name,
                            style: LynewedTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (group.isDefault)
                          _buildBadge('Default', LynewedColors.textSecondary)
                        else if (group.isPublic)
                          _buildBadge('Public', LynewedColors.textSecondary)
                        else
                          _buildBadge('Private', LynewedColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Member count
                    Text(
                      '${group.memberCount} member${group.memberCount > 1 ? 's' : ''}',
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              if (group.canEdit) ...[
                IconButton(
                  icon: const Icon(Icons.people_outline),
                  iconSize: 20,
                  color: LynewedColors.textSecondary,
                  tooltip: 'Manage members',
                  onPressed: onManageMembers,
                ),
              ],

              const Icon(
                Icons.chevron_right,
                color: LynewedColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: LynewedTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getGroupColor() {
    if (group.isDefault) return LynewedColors.primary;
    if (group.isPublic) return LynewedColors.primary;
    return LynewedColors.textSecondary;
  }

  IconData _getGroupIcon() {
    if (group.isDefault) return Icons.groups;
    if (group.isPublic) return Icons.public;
    return Icons.lock_outline;
  }

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: LynewedColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: LynewedColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Group name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                group.name,
                style: LynewedTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Options
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Open chat'),
              onTap: () {
                Navigator.pop(context);
                onTap();
              },
            ),
            if (onManageMembers != null)
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Manage members'),
                onTap: () {
                  Navigator.pop(context);
                  onManageMembers!();
                },
              ),
            if (onEdit != null)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit!();
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: LynewedColors.error),
                title: Text(
                  'Delete',
                  style: TextStyle(color: LynewedColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text(
          'Are you sure you want to delete the group "${group.name}"?\n\n'
          'Messages will be kept but the group will no longer be accessible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: LynewedColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Compact version of group tile for preview in MyWeddingPage.
class WeddingGroupCompactTile extends StatelessWidget {
  const WeddingGroupCompactTile({
    super.key,
    required this.group,
    required this.onTap,
  });

  final WeddingGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (group.isPublic ? LynewedColors.primary : LynewedColors.textSecondary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                group.isPublic ? Icons.public : Icons.lock_outline,
                size: 18,
                color: group.isPublic ? LynewedColors.primary : LynewedColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),

            // Name and count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${group.memberCount} member${group.memberCount > 1 ? 's' : ''}',
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              size: 20,
              color: LynewedColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
