import 'package:flutter/material.dart';
import '../design.dart';

/// Professional tile for wedding team list
/// 
/// Design System V4:
/// - Photo, name, profession
/// - Chat icon for 1-1 access
/// - Tap → ProDetails, Long press → Modal
class LynewedProTile extends StatelessWidget {
  const LynewedProTile({
    super.key,
    required this.name,
    this.profession,
    this.avatarUrl,
    this.onTap,
    this.onLongPress,
    this.onChatTap,
    this.showChatIcon = true,
  });

  /// Professional's display name
  final String name;
  
  /// Profession label (e.g., "Photographer")
  final String? profession;
  
  /// Avatar URL
  final String? avatarUrl;
  
  /// Callback when tile is tapped
  final VoidCallback? onTap;
  
  /// Callback when tile is long pressed
  final VoidCallback? onLongPress;
  
  /// Callback when chat icon is tapped
  final VoidCallback? onChatTap;
  
  /// Whether to show the chat icon
  final bool showChatIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: LynewedSpacing.listItemVerticalPadding,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48.0,
              height: 48.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: LynewedColors.surface,
              ),
              clipBehavior: Clip.antiAlias,
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildAvatarPlaceholder(),
                    )
                  : _buildAvatarPlaceholder(),
            ),
            
            const SizedBox(width: LynewedSpacing.md),
            
            // Name and profession
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: LynewedTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (profession != null && profession!.isNotEmpty) ...[
                    const SizedBox(height: 2.0),
                    Text(
                      profession!,
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
            
            // Chat icon
            if (showChatIcon && onChatTap != null) ...[
              const SizedBox(width: LynewedSpacing.sm),
              GestureDetector(
                onTap: onChatTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: LynewedColors.textSecondary,
                    size: 20.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: LynewedColors.gray200,
      child: const Center(
        child: Icon(
          Icons.person,
          color: LynewedColors.textSecondary,
          size: 24.0,
        ),
      ),
    );
  }
}
