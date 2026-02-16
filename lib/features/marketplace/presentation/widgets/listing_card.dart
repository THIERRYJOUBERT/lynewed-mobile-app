/// ListingCard widget for marketplace feed.
///
/// Displays a listing as a card with cover photo, title, price,
/// condition badge overlay, and location text.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// A card widget for displaying a marketplace listing in a grid.
///
/// Shows a square cover photo with condition badge overlay,
/// followed by title (max 2 lines), price, and location.
class ListingCard extends StatelessWidget {
  /// Creates a listing card.
  const ListingCard({
    required this.title,
    required this.priceCents,
    required this.condition,
    required this.country,
    required this.onTap,
    this.city,
    this.coverPhotoUrl,
    super.key,
  });

  /// Listing title.
  final String title;

  /// Price in cents (e.g., 29999 = $299.99).
  final int priceCents;

  /// Condition: 'new', 'excellent', 'good', or 'fair'.
  final String condition;

  /// City (optional).
  final String? city;

  /// Country.
  final String country;

  /// Cover photo URL (optional, shows placeholder if null).
  final String? coverPhotoUrl;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: LynewedColors.background,
          borderRadius: LynewedBorders.borderRadiusXs,
          boxShadow: [
            BoxShadow(
              color: LynewedColors.primary.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover photo with condition badge overlay
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCoverPhoto(),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildConditionBadge(),
                  ),
                ],
              ),
            ),
            // Info section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title (max 2 lines)
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: LynewedTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    // Price
                    Text(
                      _formatPrice(priceCents),
                      style: LynewedTextStyles.titleSmall.copyWith(
                        color: LynewedColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Location
                    Text(
                      _formatLocation(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPhoto() {
    if (coverPhotoUrl == null || coverPhotoUrl!.isEmpty) {
      return Container(
        color: LynewedColors.gray200,
        child: const Center(
          child: Icon(
            Icons.shopping_bag_outlined,
            color: LynewedColors.gray300,
            size: 48,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: coverPhotoUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: LynewedColors.gray200,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: LynewedColors.gray300,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: LynewedColors.gray200,
        child: const Center(
          child: Icon(
            Icons.broken_image,
            color: LynewedColors.gray300,
            size: 48,
          ),
        ),
      ),
    );
  }

  Widget _buildConditionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getConditionColor(condition),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _capitalizeFirst(condition),
        style: LynewedTextStyles.labelSmall.copyWith(
          color: LynewedColors.textOnDark,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatPrice(int cents) {
    final dollars = cents / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }

  String _formatLocation() {
    if (city != null && city!.isNotEmpty) {
      return '$city, $country';
    }
    return country;
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Returns the color for a condition badge.
  static Color _getConditionColor(String condition) {
    switch (condition) {
      case 'new':
        return LynewedColors.success;
      case 'excellent':
        return LynewedColors.primary;
      case 'good':
        return LynewedColors.warning;
      case 'fair':
        return LynewedColors.gray300;
      default:
        return LynewedColors.gray300;
    }
  }
}
