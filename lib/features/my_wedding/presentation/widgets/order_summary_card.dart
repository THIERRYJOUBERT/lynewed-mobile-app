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
    this.spreadCount = 0,
    required this.magazinePriceCents,
    this.quantity = 1,
    this.coverPhotoUrl,
    this.weddingTitle,
  });

  /// Selected magazine format.
  final MagazineFormat format;

  /// Number of photos in the magazine.
  final int photoCount;

  /// Actual number of spreads (content pages, excluding cover).
  final int spreadCount;

  /// Magazine price in cents (unit price).
  final int magazinePriceCents;

  /// Number of copies ordered.
  final int quantity;

  /// Cover photo URL for preview (optional).
  final String? coverPhotoUrl;

  /// Wedding title (optional).
  final String? weddingTitle;

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
                      spreadCount > 0
                          ? '${format.size} \u2022 $spreadCount spreads'
                          : format.size,
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
            isTotal: quantity == 1,
          ),
          if (quantity > 1) ...[
            const SizedBox(height: 4),
            _buildPriceRow('Quantity', 'x $quantity'),
            const SizedBox(height: 8),
            const Divider(height: 1, color: LynewedColors.border),
            const SizedBox(height: 8),
            _buildPriceRow(
              'Subtotal',
              _formatCents(magazinePriceCents * quantity),
              isTotal: true,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Shipping calculated at checkout',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
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
