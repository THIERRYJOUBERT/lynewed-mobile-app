/// BuyerOfferTile - Conversation-style tile for a buyer's offer.
///
/// Displays buyer avatar, name, latest offer amount, and either
/// a "View Offer" button (pending) or a status badge (resolved).
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/marketplace_offer.dart';

/// Conversation-style tile showing a buyer's latest offer on a listing.
///
/// Used in ReceivedOffersPage to display grouped offers per buyer.
/// Pending offers show a "View Offer" button; resolved offers show
/// a status badge (ACCEPTED, REJECTED, EXPIRED, WITHDRAWN).
class BuyerOfferTile extends StatelessWidget {
  /// Creates a buyer offer tile.
  const BuyerOfferTile({
    required this.latestOffer,
    required this.totalOfferCount,
    required this.onTap,
    this.buyerName,
    this.buyerAvatarUrl,
    super.key,
  });

  /// Buyer display name (fallback: "Buyer").
  final String? buyerName;

  /// Buyer avatar URL.
  final String? buyerAvatarUrl;

  /// The most recent offer from this buyer.
  final MarketplaceOffer latestOffer;

  /// Total number of offers from this buyer on this listing.
  final int totalOfferCount;

  /// Callback when the tile or View Offer button is tapped.
  final VoidCallback onTap;

  bool get _isActionable => latestOffer.isPending && !latestOffer.isExpired;

  String get _displayName => buyerName ?? 'Buyer';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: LynewedSpacing.xl,
          vertical: LynewedSpacing.md,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: LynewedColors.gray200),
          ),
        ),
        child: Row(
          children: [
            _buildAvatar(),
            SizedBox(width: LynewedSpacing.md),
            Expanded(child: _buildContent()),
            SizedBox(width: LynewedSpacing.sm),
            _buildTrailing(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 20,
      backgroundColor: LynewedColors.gray200,
      backgroundImage:
          buyerAvatarUrl != null ? NetworkImage(buyerAvatarUrl!) : null,
      child: buyerAvatarUrl == null
          ? Text(
              _displayName.isNotEmpty
                  ? _displayName[0].toUpperCase()
                  : 'B',
              style: LynewedTextStyles.titleSmall,
            )
          : null,
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _displayName,
          style: LynewedTextStyles.bodyMedium.copyWith(
            fontWeight: _isActionable ? FontWeight.w600 : FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '\$${latestOffer.amountInDollars.toStringAsFixed(2)}',
          style: LynewedTextStyles.bodyMedium.copyWith(
            color: LynewedColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (totalOfferCount > 1) ...[
          const SizedBox(height: 2),
          Text(
            '$totalOfferCount offers',
            style: LynewedTextStyles.labelSmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrailing() {
    if (_isActionable) {
      return LynewedButton(
        text: 'View Offer',
        type: LynewedButtonType.secondary,
        onPressed: onTap,
      );
    }

    final effectiveStatus =
        latestOffer.isExpired ? 'expired' : latestOffer.status;
    return _buildStatusBadge(effectiveStatus);
  }

  Widget _buildStatusBadge(String status) {
    final label = status.toUpperCase();
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: LynewedTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return LynewedColors.success;
      case 'rejected':
      case 'expired':
        return LynewedColors.error;
      case 'withdrawn':
        return LynewedColors.gray100;
      default:
        return LynewedColors.warning;
    }
  }
}
