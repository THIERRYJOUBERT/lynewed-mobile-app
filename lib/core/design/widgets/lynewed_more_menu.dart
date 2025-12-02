import 'package:flutter/material.dart';
import '../design.dart';

/// Menu item for LynewedMoreMenu
class LynewedMenuItem {
  const LynewedMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
}

/// More menu button (3 dots) with tight spacing control
/// 
/// Design System v2:
/// - 22x22 icon size, no padding
/// - Flush with container edge
/// - Custom popup menu
class LynewedMoreMenu extends StatelessWidget {
  const LynewedMoreMenu({
    super.key,
    required this.items,
    this.tooltip = 'More options',
  });

  final List<LynewedMenuItem> items;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        child: const Icon(
          Icons.more_vert,
          color: LynewedColors.textSecondary,
          size: 22,
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    // Get the render box to calculate position
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    // Calculate position: below the button, aligned to right with 30px margin
    final Offset buttonOffset = button.localToGlobal(Offset.zero, ancestor: overlay);
    final double left = buttonOffset.dx + button.size.width - 150; // Menu width ~150px
    final double top = buttonOffset.dy + button.size.height + 8; // 8px below button
    
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        left,
        top,
        overlay.size.width - (buttonOffset.dx + button.size.width) - 30, // 30px right margin
        overlay.size.height - top,
      ),
      items: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return PopupMenuItem<String>(
          value: index.toString(),
          height: 48,
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20,
                color: item.isDestructive 
                    ? LynewedColors.error 
                    : LynewedColors.textPrimary,
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: item.isDestructive 
                      ? LynewedColors.error 
                      : LynewedColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        final index = int.tryParse(value);
        if (index != null && index >= 0 && index < items.length) {
          items[index].onTap();
        }
      }
    });
  }
}
