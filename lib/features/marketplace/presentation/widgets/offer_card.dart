/// OfferCard widget - Displays an individual offer with actions.
///
/// Shows offer amount, buyer info, message, status badge,
/// and appropriate action buttons based on view mode (seller/buyer).
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/offer_display_model.dart';

/// View mode determines which actions are shown on the card.
enum OfferCardViewMode {
  /// Seller view: shows Accept/Decline buttons for pending offers.
  seller,

  /// Buyer view: shows Withdraw button for pending offers.
  buyer,
}

/// Card widget displaying a marketplace offer.
///
/// Adapts its UI based on [viewMode]:
/// - Seller mode: shows buyer info, Accept/Decline for pending
/// - Buyer mode: shows listing title, Withdraw for pending
///
/// Non-pending offers show a status badge instead of action buttons.
class OfferCard extends StatelessWidget {
  /// Creates an offer card.
  const OfferCard({
    required this.model,
    required this.viewMode,
    this.onAccept,
    this.onReject,
    this.onWithdraw,
    this.onTap,
    super.key,
  });

  /// The offer display model.
  final OfferDisplayModel model;

  /// Whether this is a seller or buyer view.
  final OfferCardViewMode viewMode;

  /// Callback when seller accepts this offer.
  final VoidCallback? onAccept;

  /// Callback when seller rejects this offer.
  final VoidCallback? onReject;

  /// Callback when buyer withdraws this offer.
  final VoidCallback? onWithdraw;

  /// Callback when the card is tapped (navigate to conversation).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
      padding: EdgeInsets.all(LynewedSpacing.lg),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        border: const Border(
          bottom: BorderSide(color: LynewedColors.gray200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: buyer info or listing title.
          _buildHeader(),
          SizedBox(height: LynewedSpacing.md),

          // Offer amount.
          Text(
            '\$${model.offer.amountInDollars.toStringAsFixed(2)}',
            style: LynewedTextStyles.headlineMedium.copyWith(
              color: LynewedColors.primary,
            ),
          ),

          // Message if present.
          if (model.offer.message != null) ...[
            SizedBox(height: LynewedSpacing.sm),
            Text(
              model.offer.message!,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],

          SizedBox(height: LynewedSpacing.sm),

          // Expiration or status info.
          if (model.offer.isPending)
            Text(
              'Expires ${_formatExpiration(model.offer.expiresAt)}',
              style: LynewedTextStyles.labelLarge.copyWith(
                color: _isExpiringSoon()
                    ? LynewedColors.warning
                    : LynewedColors.textSecondary,
              ),
            ),

          SizedBox(height: LynewedSpacing.md),

          // Actions or status badge.
          if (model.offer.isPending)
            _buildActions()
          else
            _buildStatusBadge(),
        ],
      ),
      ),
    );
  }

  Widget _buildHeader() {
    if (viewMode == OfferCardViewMode.seller) {
      // Show buyer info.
      final name = model.buyerName ?? 'Buyer';
      return Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: LynewedColors.gray200,
            backgroundImage: model.buyerAvatarUrl != null
                ? NetworkImage(model.buyerAvatarUrl!)
                : null,
            child: model.buyerAvatarUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'B',
                    style: LynewedTextStyles.titleSmall,
                  )
                : null,
          ),
          SizedBox(width: LynewedSpacing.sm),
          Expanded(
            child: Text(
              name,
              style: LynewedTextStyles.titleSmall,
            ),
          ),
        ],
      );
    } else {
      // Show listing title.
      return Text(
        model.listingTitle ?? 'Listing',
        style: LynewedTextStyles.titleSmall,
      );
    }
  }

  Widget _buildActions() {
    if (viewMode == OfferCardViewMode.seller) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: LynewedButton(
              text: 'Decline',
              type: LynewedButtonType.secondary,
              onPressed: onReject,
            ),
          ),
          SizedBox(width: LynewedSpacing.sm),
          Expanded(
            child: LynewedButton(
              text: 'Accept',
              type: LynewedButtonType.primary,
              onPressed: onAccept,
            ),
          ),
        ],
      );
    } else {
      return Align(
        alignment: Alignment.centerRight,
        child: LynewedButton(
          text: 'Withdraw',
          type: LynewedButtonType.destructiveOutlined,
          onPressed: onWithdraw,
        ),
      );
    }
  }

  Widget _buildStatusBadge() {
    final status = model.offer.status.toUpperCase();
    final color = _getStatusColor(model.offer.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: LynewedTextStyles.labelLarge.copyWith(
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

  bool _isExpiringSoon() {
    final diff = model.offer.expiresAt.difference(DateTime.now());
    return diff.inHours < 6;
  }

  String _formatExpiration(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.isNegative) return 'expired';
    if (diff.inDays > 0) return 'in ${diff.inDays}d ${diff.inHours % 24}h';
    return 'in ${diff.inHours}h ${diff.inMinutes % 60}m';
  }
}
