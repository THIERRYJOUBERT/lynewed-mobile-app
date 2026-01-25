/// Portfolio Grid Widget
///
/// A grid layout for displaying portfolio images.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/portfolio_item.dart';
import 'portfolio_card.dart';

/// A grid of portfolio items with optional save functionality.
class PortfolioGrid extends StatelessWidget {
  const PortfolioGrid({
    super.key,
    required this.items,
    required this.onItemTap,
    this.onItemSave,
    this.onItemLongPress,
    this.showSaveButtons = false,
    this.savedItemIds = const {},
    this.crossAxisCount = 2,
    this.spacing = 12.0,
    this.childAspectRatio = 1.0,
    this.padding = const EdgeInsets.all(16),
    this.emptyMessage,
    this.shrinkWrap = false,
    this.physics,
  });

  /// The portfolio items to display.
  final List<PortfolioItem> items;

  /// Callback when an item is tapped.
  final void Function(PortfolioItem item) onItemTap;

  /// Callback when an item's save button is tapped.
  final void Function(PortfolioItem item)? onItemSave;

  /// Callback when an item is long pressed.
  final void Function(PortfolioItem item)? onItemLongPress;

  /// Whether to show save buttons on items.
  final bool showSaveButtons;

  /// Set of item IDs that are saved.
  final Set<String> savedItemIds;

  /// Number of columns in the grid.
  final int crossAxisCount;

  /// Spacing between items.
  final double spacing;

  /// Aspect ratio of each item.
  final double childAspectRatio;

  /// Padding around the grid.
  final EdgeInsets padding;

  /// Message to show when the grid is empty.
  final String? emptyMessage;

  /// Whether the grid should shrink-wrap its contents.
  final bool shrinkWrap;

  /// Scroll physics for the grid.
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return PortfolioCard(
          item: item,
          onTap: () => onItemTap(item),
          onLongPress: onItemLongPress != null
              ? () => onItemLongPress!(item)
              : null,
          onSave: onItemSave != null ? () => onItemSave!(item) : null,
          showSaveButton: showSaveButtons,
          isSaved: savedItemIds.contains(item.id),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: LynewedColors.gray300,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'No images',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
