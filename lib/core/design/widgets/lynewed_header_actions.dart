import 'package:flutter/material.dart';
import '../design.dart';
import 'lynewed_more_menu.dart';

/// Header actions widget with favorite + more menu
/// 
/// Design System v2:
/// - Favorite icon on left
/// - More icon (3 dots) on right - flush with edge
/// - 10px spacing between icons
class LynewedHeaderActions extends StatelessWidget {
  const LynewedHeaderActions({
    super.key,
    this.isFavorited = false,
    this.onFavoriteToggle,
    this.showFavorite = true,
    this.menuItems = const [],
  });

  /// Whether the item is favorited
  final bool isFavorited;
  
  /// Callback when favorite is toggled
  final VoidCallback? onFavoriteToggle;
  
  /// Whether to show the favorite button
  final bool showFavorite;
  
  /// Menu items for the more button
  final List<LynewedMenuItem> menuItems;

  @override
  Widget build(BuildContext context) {
    final hasMenu = menuItems.isNotEmpty;
    
    if (!hasMenu && !showFavorite) return const SizedBox.shrink();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Favorite button (first, on left)
        if (showFavorite)
          GestureDetector(
            onTap: onFavoriteToggle,
            child: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? LynewedColors.error : LynewedColors.textSecondary,
              size: 22,
            ),
          ),
        
        // 10px spacing between icons
        if (showFavorite && hasMenu) const SizedBox(width: 10),
        
        // More menu button (second, on right - flush with edge)
        if (hasMenu)
          LynewedMoreMenu(
            items: menuItems,
          ),
      ],
    );
  }
}
