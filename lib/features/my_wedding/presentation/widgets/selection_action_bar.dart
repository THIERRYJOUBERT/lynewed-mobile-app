/// Selection Action Bar Widget - Top bar for selection mode.
///
/// Displays the selected count, select all/clear button, and close button.
/// Also provides action buttons for favorite, hide, share, add to magazine,
/// download, delete.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';

/// A top action bar widget for the gallery selection mode.
///
/// Shows the selected count, select all/clear toggle, and close button
/// in the top row, and action buttons in the bottom row.
class SelectionActionBar extends StatelessWidget {
  /// Creates a selection action bar widget.
  const SelectionActionBar({
    super.key,
    required this.selectedCount,
    required this.totalCount,
    required this.onClose,
    required this.onSelectAll,
    this.onFavorite,
    this.onHide,
    this.onShare,
    this.onAddToMagazine,
    this.onDownload,
    this.onDelete,
  });

  /// The number of selected items.
  final int selectedCount;

  /// The total number of items in the gallery.
  final int totalCount;

  /// Callback when the close button is tapped.
  final VoidCallback onClose;

  /// Callback when select all/clear button is tapped.
  final VoidCallback onSelectAll;

  /// Callback when favorite button is tapped.
  final VoidCallback? onFavorite;

  /// Callback when hide button is tapped.
  final VoidCallback? onHide;

  /// Callback when share button is tapped.
  final VoidCallback? onShare;

  /// Callback when add to magazine button is tapped.
  final VoidCallback? onAddToMagazine;

  /// Callback when download button is tapped.
  final VoidCallback? onDownload;

  /// Callback when delete button is tapped.
  final VoidCallback? onDelete;

  /// Whether all items are selected.
  bool get _allSelected => selectedCount == totalCount && totalCount > 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LynewedColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTopRow(),
            const Divider(height: 1, color: LynewedColors.gray200),
            _buildActionRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: LynewedColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 22,
                color: LynewedColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Selected count
          Expanded(
            child: Text(
              '$selectedCount selected',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18),
            ),
          ),
          // Select all / Clear button
          TextButton(
            onPressed: onSelectAll,
            child: Text(
              _allSelected ? 'Clear' : 'Select all',
              style: LynewedTextStyles.labelLarge.copyWith(
                color: LynewedColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (onFavorite != null)
            _buildActionButton(
              icon: Icons.favorite_outline,
              label: 'Favorite',
              onTap: onFavorite!,
            ),
          if (onHide != null)
            _buildActionButton(
              icon: Icons.visibility_off_outlined,
              label: 'Hide',
              onTap: onHide!,
            ),
          if (onShare != null)
            _buildActionButton(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: onShare!,
            ),
          if (onAddToMagazine != null)
            _buildActionButton(
              icon: Icons.auto_stories_outlined,
              label: 'Magazine',
              onTap: onAddToMagazine!,
            ),
          if (onDownload != null)
            _buildActionButton(
              icon: Icons.download_outlined,
              label: 'Download',
              onTap: onDownload!,
            ),
          if (onDelete != null)
            _buildActionButton(
              icon: Icons.delete_outline,
              label: 'Delete',
              onTap: onDelete!,
              isDestructive: true,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color =
        isDestructive ? LynewedColors.error : LynewedColors.textPrimary;
    return GestureDetector(
      onTap: selectedCount > 0 ? onTap : null,
      child: Opacity(
        opacity: selectedCount > 0 ? 1.0 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: LynewedColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: LynewedTextStyles.labelSmall.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
