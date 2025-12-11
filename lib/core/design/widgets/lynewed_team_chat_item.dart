import 'package:flutter/material.dart';
import '../design.dart';

/// Wedding team chat item with avatars and unread badge
/// 
/// Design System V4:
/// - Similar style to existing chat room items
/// - Shows up to 4 avatar circles overlapping
/// - Unread count badge
class LynewedTeamChatItem extends StatelessWidget {
  const LynewedTeamChatItem({
    super.key,
    required this.avatarUrls,
    this.unreadCount = 0,
    this.participantsCount = 0,
    this.lastMessage,
    this.onTap,
  });

  /// List of avatar URLs (shows up to 4)
  final List<String> avatarUrls;
  
  /// Number of unread messages
  final int unreadCount;
  
  /// Total number of participants
  final int participantsCount;
  
  /// Last message preview
  final String? lastMessage;
  
  /// Callback when item is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(LynewedSpacing.lg),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          children: [
            // Stacked avatars
            _buildAvatarStack(),
            
            const SizedBox(width: LynewedSpacing.md),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Wedding Team',
                        style: LynewedTextStyles.titleSmall,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        '$participantsCount members',
                        style: LynewedTextStyles.labelLarge,
                      ),
                    ],
                  ),
                  if (lastMessage != null && lastMessage!.isNotEmpty) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      lastMessage!,
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Unread badge
            if (unreadCount > 0) ...[
              const SizedBox(width: LynewedSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: LynewedColors.primary,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: LynewedTextStyles.labelMedium.copyWith(
                    color: LynewedColors.textOnPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            
            // Chevron
            const SizedBox(width: LynewedSpacing.sm),
            const Icon(
              Icons.chevron_right,
              color: LynewedColors.textSecondary,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack() {
    const double avatarSize = 36.0;
    const double overlap = 12.0;
    final displayAvatars = avatarUrls.take(4).toList();
    final extraCount = avatarUrls.length - 4;
    
    if (displayAvatars.isEmpty) {
      return Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          color: LynewedColors.gray200,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.group_outlined,
          color: LynewedColors.textSecondary,
          size: 20.0,
        ),
      );
    }
    
    final stackWidth = avatarSize + (displayAvatars.length - 1) * (avatarSize - overlap);
    
    return SizedBox(
      width: stackWidth,
      height: avatarSize,
      child: Stack(
        children: [
          for (int i = 0; i < displayAvatars.length; i++)
            Positioned(
              left: i * (avatarSize - overlap),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: LynewedColors.background,
                    width: 2.0,
                  ),
                ),
                child: ClipOval(
                  child: displayAvatars[i].isNotEmpty
                      ? Image.network(
                          displayAvatars[i],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildAvatarPlaceholder(),
                        )
                      : _buildAvatarPlaceholder(),
                ),
              ),
            ),
          if (extraCount > 0)
            Positioned(
              left: displayAvatars.length * (avatarSize - overlap),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: LynewedColors.gray200,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: LynewedColors.background,
                    width: 2.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$extraCount',
                    style: LynewedTextStyles.labelMedium.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: LynewedColors.gray200,
      child: const Icon(
        Icons.person,
        color: LynewedColors.textSecondary,
        size: 20.0,
      ),
    );
  }
}
