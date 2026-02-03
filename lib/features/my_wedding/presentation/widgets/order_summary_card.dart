/// Order Summary Card widget for magazine checkout.
///
/// Displays magazine preview thumbnail, format details, pricing breakdown.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/core/design/design.dart';

import '../../domain/entities/magazine_format.dart';

/// Card displaying order summary for magazine checkout.
class OrderSummaryCard extends StatelessWidget {
  /// Creates an order summary card.
  const OrderSummaryCard({
    super.key,
    required this.format,
    required this.photoCount,
    required this.magazinePriceCents,
    required this.shippingCostCents,
    this.coverPhotoUrl,
    this.weddingTitle,
  });

  /// Selected magazine format.
  final MagazineFormat format;

  /// Number of photos in the magazine.
  final int photoCount;

  /// Magazine price in cents.
  final int magazinePriceCents;

  /// Shipping cost in cents.
  final int shippingCostCents;

  /// Cover photo URL for preview (optional).
  final String? coverPhotoUrl;

  /// Wedding title (optional).
  final String? weddingTitle;

  /// Returns the total price in cents.
  int get totalCents => magazinePriceCents + shippingCostCents;

  /// Formats cents as dollars.
  String _formatCents(int cents) {
    final dollars = cents ~/ 100;
    final remainder = cents % 100;
    if (remainder == 0) {
      return '\$$dollars.00';
    }
    return '\$$dollars.${remainder.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LynewedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with thumbnail
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover thumbnail
              _buildThumbnail(),
              const SizedBox(width: 16),
              // Format details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${format.name} Wedding Magazine',
                      style: LynewedTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${format.size} - ${format.spreads} spreads',
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$photoCount photos',
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Pricing breakdown
          _buildPriceRow(
            'Magazine (${format.name})',
            _formatCents(magazinePriceCents),
          ),
          const SizedBox(height: 8),
          _buildPriceRow(
            'Shipping',
            _formatCents(shippingCostCents),
          ),
          const SizedBox(height: 12),
          // Divider
          const Divider(color: LynewedColors.border),
          const SizedBox(height: 12),
          // Total
          _buildPriceRow(
            'Total',
            _formatCents(totalCents),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: LynewedColors.gray100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LynewedColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: coverPhotoUrl != null && coverPhotoUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: coverPhotoUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildPlaceholder(),
              errorWidget: (context, url, error) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 32,
            color: LynewedColors.gray300,
          ),
          if (weddingTitle != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                weddingTitle!,
                style: LynewedTextStyles.labelSmall.copyWith(
                  color: LynewedColors.textSecondary,
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? LynewedTextStyles.titleSmall
              : LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
        ),
        Text(
          price,
          style: isTotal
              ? LynewedTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                )
              : LynewedTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
