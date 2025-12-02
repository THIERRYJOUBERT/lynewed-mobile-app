/// Blocked users sheet - Clean Architecture
/// 
/// Modal sheet displaying blocked users list.
/// Design System v2 applied.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';
import '../widgets/blocked_user_tile.dart';

/// Sheet displaying blocked users with unblock action
class BlockedUsersSheet extends StatelessWidget {
  const BlockedUsersSheet({
    super.key,
    required this.blockedUsers,
    required this.onUnblock,
  });

  final List<BlockedUser> blockedUsers;
  final Future<bool> Function(BlockedUser user) onUnblock;

  /// Show the sheet as a modal bottom sheet
  static Future<void> show({
    required BuildContext context,
    required List<BlockedUser> blockedUsers,
    required Future<bool> Function(BlockedUser user) onUnblock,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlockedUsersSheet(
        blockedUsers: blockedUsers,
        onUnblock: onUnblock,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: LynewedColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(LynewedBorders.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: LynewedColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header - same style as LynewedSheet (title left, close right)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                // Title
                Expanded(
                  child: Text(
                    'Archived',
                    style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
                  ),
                ),
                // Close button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: LynewedColors.gray300,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider - same as LynewedSheet
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Divider(height: 1, color: LynewedColors.gray200),
          ),
          
          // Content
          Flexible(
            child: blockedUsers.isEmpty
                ? _buildEmptyState()
                : _buildBlockedList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.block_outlined,
              size: 48,
              color: LynewedColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No blocked users',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      itemCount: blockedUsers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = blockedUsers[index];
        return BlockedUserTile(
          blockedUser: user,
          onUnblock: () async {
            final success = await onUnblock(user);
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.fullName ?? 'User'} unblocked'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );
      },
    );
  }
}
