/// SellerInfoWidget for listing detail pages.
///
/// Displays seller avatar, name, listings count, and a "View Listings" button.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/seller_profile.dart';

/// Widget displaying seller information on a listing detail page.
///
/// Shows:
/// - Avatar with first-letter fallback
/// - Seller name
/// - Number of active listings
/// - "View Listings" ghost button
class SellerInfoWidget extends StatelessWidget {
  /// Creates a seller info widget.
  const SellerInfoWidget({
    required this.seller,
    required this.onViewListings,
    super.key,
  });

  /// The seller profile to display.
  final SellerProfile seller;

  /// Callback when "View Listings" button is tapped.
  final VoidCallback onViewListings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(LynewedSpacing.md),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        border: Border.all(color: LynewedColors.gray200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: LynewedColors.primary,
            backgroundImage: seller.avatarUrl != null
                ? CachedNetworkImageProvider(seller.avatarUrl!)
                : null,
            child: seller.avatarUrl == null
                ? Text(
                    seller.name.isNotEmpty
                        ? seller.name[0].toUpperCase()
                        : '?',
                    style: LynewedTextStyles.titleSmall.copyWith(
                      color: LynewedColors.textOnDark,
                    ),
                  )
                : null,
          ),
          SizedBox(width: LynewedSpacing.md),

          // Name and listings count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.name,
                  style: LynewedTextStyles.titleSmall,
                ),
                SizedBox(height: LynewedSpacing.xxs),
                Text(
                  '${seller.listingsCount} listing${seller.listingsCount == 1 ? '' : 's'}',
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // View Listings button
          LynewedButton(
            text: 'View Listings',
            type: LynewedButtonType.ghost,
            onPressed: onViewListings,
          ),
        ],
      ),
    );
  }
}
