/// Blocked user tile widget - Clean Architecture
/// 
/// Displays a blocked user in the list with unblock option.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';

/// Tile widget for a blocked user
class BlockedUserTile extends StatelessWidget {
  const BlockedUserTile({
    super.key,
    required this.blockedUser,
    required this.onUnblock,
    this.isLoading = false,
  });

  final BlockedUser blockedUser;
  final VoidCallback onUnblock;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          // Avatar
          _buildAvatar(),
          
          const SizedBox(width: 12),
          
          // Name and role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blockedUser.fullName ?? 'User',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getRoleLabel(),
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Unblock button
          SizedBox(
            height: 32,
            child: TextButton(
              onPressed: isLoading ? null : onUnblock,
              style: TextButton.styleFrom(
                foregroundColor: LynewedColors.error,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: LynewedColors.error,
                      ),
                    )
                  : const Text('Unblock'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: LynewedColors.error.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: blockedUser.avatarUrl != null && blockedUser.avatarUrl!.isNotEmpty
            ? ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.saturation,
                ),
                child: Image.network(
                  blockedUser.avatarUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                ),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 40,
      height: 40,
      color: LynewedColors.gray200,
      child: const Icon(
        Icons.person_off,
        color: LynewedColors.gray300,
        size: 22,
      ),
    );
  }

  String _getRoleLabel() {
    switch (blockedUser.role) {
      case UserRole.bride:
        return 'Bride';
      case UserRole.professional:
        return 'Professional';
      default:
        return 'User';
    }
  }
}
