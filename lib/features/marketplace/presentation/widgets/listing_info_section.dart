/// ListingInfoSection widget for listing detail pages.
///
/// Displays all listing details: title, price, category, size, brand,
/// condition, sleeve length (for dresses), description, and location.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/marketplace_listing.dart';
import 'detail_row.dart';

/// Section displaying all details of a marketplace listing.
///
/// Shows:
/// - Title and price
/// - Details (category, size, brand, condition, sleeve length for dresses)
/// - Description (if available)
/// - Location
class ListingInfoSection extends StatelessWidget {
  /// Creates a listing info section.
  const ListingInfoSection({
    required this.listing,
    super.key,
  });

  /// The listing to display details for.
  final MarketplaceListing listing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          listing.title,
          style: LynewedTextStyles.headlineSmall,
        ),
        SizedBox(height: LynewedSpacing.sm),

        // Price
        Text(
          _formatPrice(listing.priceCents),
          style: LynewedTextStyles.headlineMedium.copyWith(
            color: LynewedColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: LynewedSpacing.lg),

        Divider(color: LynewedColors.gray200),
        SizedBox(height: LynewedSpacing.md),

        // Details section
        const LynewedSectionTitle('Details'),
        SizedBox(height: LynewedSpacing.sm),
        DetailRow(
          icon: Icons.category_outlined,
          label: 'Category',
          value: _capitalizeFirst(listing.category),
        ),
        if (listing.size != null)
          DetailRow(
            icon: Icons.straighten,
            label: 'Size',
            value: listing.size!,
          ),
        DetailRow(
          icon: Icons.label_outlined,
          label: 'Brand',
          value: listing.designerBrand ?? 'Not specified',
        ),
        DetailRow(
          icon: Icons.star_outline,
          label: 'Condition',
          value: _capitalizeFirst(listing.condition),
        ),
        if (listing.isDress && listing.sleeveLength != null)
          DetailRow(
            icon: Icons.checkroom,
            label: 'Sleeve Length',
            value: _capitalizeFirst(listing.sleeveLength!),
          ),

        SizedBox(height: LynewedSpacing.lg),
        Divider(color: LynewedColors.gray200),
        SizedBox(height: LynewedSpacing.md),

        // Description section
        if (listing.description != null &&
            listing.description!.isNotEmpty) ...[
          const LynewedSectionTitle('Description'),
          SizedBox(height: LynewedSpacing.sm),
          Text(
            listing.description!,
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
          SizedBox(height: LynewedSpacing.lg),
          Divider(color: LynewedColors.gray200),
          SizedBox(height: LynewedSpacing.md),
        ],

        // Location section
        const LynewedSectionTitle('Location'),
        SizedBox(height: LynewedSpacing.sm),
        Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 18,
              color: LynewedColors.gray300,
            ),
            SizedBox(width: LynewedSpacing.sm),
            Expanded(
              child: Text(
                _formatLocation(),
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatPrice(int cents) {
    final dollars = cents / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatLocation() {
    if (listing.city != null && listing.city!.isNotEmpty) {
      return '${listing.city}, ${listing.country}';
    }
    return listing.country;
  }
}
