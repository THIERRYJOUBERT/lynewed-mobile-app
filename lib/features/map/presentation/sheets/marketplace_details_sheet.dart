/// Marketplace item details sheet widget (EPIC-13 APP-07)
///
/// Clean, modern sheet for displaying marketplace listing details on map.
/// Will be fully functional when EPIC-14 (Marketplace) is deployed.
///
/// DESIGN SYSTEM v2 APPLIED:
/// - FontWeight max w500 (except CTAs)
/// - Border radius 4px for chips/badges
/// - LynewedColors, LynewedTextStyles tokens
/// - Reusable widgets: LynewedDetailsSheet, LynewedButton, etc.
/// - Spacing: 10px label→content, 30px between sections
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '/core/design/design.dart';
import '/core/design/widgets/widgets.dart';
import '/core/utils/budget_formatter.dart';

/// Marketplace item summary for map marker display
/// Lightweight entity for map display, full details loaded on navigation
@immutable
class MarketplaceItemSummary {
  const MarketplaceItemSummary({
    required this.id,
    required this.title,
    required this.priceCents,
    this.currency = 'USD',
    required this.category,
    this.thumbnailUrl,
    this.sellerName,
    this.sellerAvatarUrl,
    this.condition,
    this.size,
    this.city,
    this.country,
  });

  final String id;
  final String title;
  final int priceCents;
  final String currency;

  /// Category: 'dress' or 'shoes'
  final String category;
  final String? thumbnailUrl;
  final String? sellerName;
  final String? sellerAvatarUrl;

  /// Condition: 'new', 'excellent', 'good', 'fair'
  final String? condition;
  final String? size;
  final String? city;
  final String? country;

  /// Formatted price for display
  String get formattedPrice =>
      BudgetFormatter.formatAmount(priceCents, sourceCurrency: currency);

  /// Category display name
  String get categoryDisplayName => category == 'shoes' ? 'Shoes' : 'Dress';

  /// Condition display name
  String get conditionDisplayName {
    switch (condition) {
      case 'new':
        return 'New with tags';
      case 'excellent':
        return 'Excellent';
      case 'good':
        return 'Good';
      case 'fair':
        return 'Fair';
      default:
        return condition ?? 'Unknown';
    }
  }

  /// Location display
  String? get locationDisplay {
    if (city != null && country != null) {
      return '$city, $country';
    }
    return city ?? country;
  }

  /// Create from map marker metadata
  factory MarketplaceItemSummary.fromMetadata(Map<String, dynamic> metadata) {
    return MarketplaceItemSummary(
      id: metadata['listingId'] as String? ?? '',
      title: metadata['title'] as String? ?? 'Marketplace Item',
      priceCents: (metadata['priceCents'] as num?)?.toInt() ?? 0,
      currency: metadata['currency'] as String? ?? 'USD',
      category: metadata['category'] as String? ?? 'dress',
      thumbnailUrl: metadata['thumbnailUrl'] as String?,
      sellerName: metadata['sellerName'] as String?,
      sellerAvatarUrl: metadata['sellerAvatarUrl'] as String?,
      condition: metadata['condition'] as String?,
      size: metadata['size'] as String?,
      city: metadata['city'] as String?,
      country: metadata['country'] as String?,
    );
  }
}

/// Marketplace item details bottom sheet
///
/// Layout:
/// - Header: Category icon + Title + Price badge
/// - Photo section: Large thumbnail
/// - Details section: Size, Condition, Location
/// - Seller info section
/// - Action button: View listing
class MarketplaceDetailsSheet extends StatelessWidget {
  const MarketplaceDetailsSheet({
    super.key,
    required this.item,
    this.onViewListing,
    this.onContactSeller,
  });

  final MarketplaceItemSummary item;
  final VoidCallback? onViewListing;
  final VoidCallback? onContactSeller;

  @override
  Widget build(BuildContext context) {
    return LynewedDetailsSheet(
      headerIcon:
          item.category == 'shoes' ? Icons.shopping_bag_outlined : Icons.checkroom_outlined,
      headerIconColor: const Color(0xFF7B1FA2), // Purple 700
      titleWidget: _buildTitleWidget(),
      subtitle: _buildHeaderSubtitle(),
      badge: _buildPriceBadge(),
      actions: _buildActionButtons(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo section
          _buildPhotoSection(),

          // Details section
          _buildDetailsSection(),

          // Seller info section
          _buildSellerSection(),
        ],
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Text(
      item.title,
      style: LynewedTextStyles.sheetTitle.copyWith(
        color: LynewedColors.textPrimary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildHeaderSubtitle() {
    return Text(
      item.categoryDisplayName,
      style: LynewedTextStyles.bodyMedium.copyWith(
        color: LynewedColors.textSecondary,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildPriceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF7B1FA2), // Purple 700
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        item.formattedPrice,
        style: LynewedTextStyles.labelMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Photo section with large thumbnail
  Widget _buildPhotoSection() {
    if (item.thumbnailUrl == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: item.thumbnailUrl!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: LynewedColors.gray200,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: LynewedColors.gray200,
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: LynewedColors.textSecondary,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Details section: Size, Condition, Location
  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Details', style: LynewedTextStyles.sectionTitle),
          const SizedBox(height: 10),

          // Size
          if (item.size != null) ...[
            LynewedInfoRow(
              icon: Icons.straighten_outlined,
              text: 'Size ${item.size}',
            ),
            const SizedBox(height: 10),
          ],

          // Condition
          if (item.condition != null) ...[
            Row(
              children: [
                LynewedInfoRow(
                  icon: Icons.verified_outlined,
                  text: item.conditionDisplayName,
                ),
                const SizedBox(width: 10),
                _buildConditionBadge(),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Location
          if (item.locationDisplay != null)
            LynewedInfoRow(
              icon: Icons.location_on_outlined,
              text: item.locationDisplay!,
            ),
        ],
      ),
    );
  }

  Widget _buildConditionBadge() {
    final Color badgeColor;
    switch (item.condition) {
      case 'new':
        badgeColor = LynewedColors.success;
        break;
      case 'excellent':
        badgeColor = LynewedColors.primary;
        break;
      case 'good':
        badgeColor = LynewedColors.warning;
        break;
      default:
        badgeColor = LynewedColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        item.conditionDisplayName,
        style: LynewedTextStyles.labelSmall.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Seller info section
  Widget _buildSellerSection() {
    if (item.sellerName == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Seller', style: LynewedTextStyles.sectionTitle),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: LynewedColors.gray200),
            ),
            child: Row(
              children: [
                // Seller avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      const Color(0xFF7B1FA2).withValues(alpha: 0.1),
                  backgroundImage: item.sellerAvatarUrl != null
                      ? CachedNetworkImageProvider(item.sellerAvatarUrl!)
                      : null,
                  child: item.sellerAvatarUrl == null
                      ? Text(
                          _getInitials(item.sellerName ?? 'S'),
                          style: LynewedTextStyles.labelMedium.copyWith(
                            color: const Color(0xFF7B1FA2),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Seller info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.sellerName!,
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Marketplace seller',
                        style: LynewedTextStyles.bodySmall.copyWith(
                          color: LynewedColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Contact icon
                if (onContactSeller != null)
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    color: const Color(0xFF7B1FA2),
                    onPressed: onContactSeller,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    // Using ElevatedButton directly for custom purple color
    // (LynewedButton.primary is black by design system)
    return SizedBox(
      width: double.infinity,
      height: LynewedSpacing.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onViewListing,
        icon: const Icon(Icons.open_in_new, size: 18),
        label: Text(
          'View Listing',
          style: LynewedTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B1FA2), // Purple 700 - marketplace theme
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Square buttons per design system
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}
