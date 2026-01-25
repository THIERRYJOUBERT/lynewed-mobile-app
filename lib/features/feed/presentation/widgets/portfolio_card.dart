/// Portfolio Card Widget
///
/// Displays a single portfolio image with optional save functionality.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/portfolio_item.dart';

/// A card displaying a portfolio image with optional save button.
class PortfolioCard extends StatelessWidget {
  const PortfolioCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onLongPress,
    this.onSave,
    this.showSaveButton = false,
    this.isSaved = false,
    this.borderRadius = 8.0,
  });

  /// The portfolio item to display.
  final PortfolioItem item;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  /// Callback when the card is long pressed.
  final VoidCallback? onLongPress;

  /// Callback when the save button is tapped.
  final VoidCallback? onSave;

  /// Whether to show the save button.
  final bool showSaveButton;

  /// Whether the item is already saved.
  final bool isSaved;

  /// Border radius for the card.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: LynewedColors.surface,
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: LynewedColors.gray200,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      LynewedColors.primary,
                    ),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: LynewedColors.gray200,
                child: const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: LynewedColors.gray300,
                    size: 32,
                  ),
                ),
              ),
            ),
            // Save button
            if (showSaveButton && onSave != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onSave,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
