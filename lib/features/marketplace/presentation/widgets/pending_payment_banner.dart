/// Pending payment banner for marketplace.
///
/// Displays a prominent banner when the buyer has accepted offers
/// awaiting payment. Self-loading widget that queries the repository.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/offer_display_model.dart';
import '../../domain/repositories/marketplace_offer_repository.dart';

/// Banner shown when the buyer has offers awaiting payment.
///
/// Loads offers via [MarketplaceOfferRepository.getOffersAwaitingMyPayment]
/// and displays a tappable banner with the count. Renders nothing when
/// there are no pending payments or on error.
class PendingPaymentBanner extends StatefulWidget {
  /// Creates a pending payment banner.
  const PendingPaymentBanner({
    this.repository,
    this.onTap,
    super.key,
  });

  /// Optional repository override (for testing).
  final MarketplaceOfferRepository? repository;

  /// Called when the banner is tapped, with the list of pending offers.
  final void Function(List<OfferDisplayModel> offers)? onTap;

  @override
  State<PendingPaymentBanner> createState() => PendingPaymentBannerState();
}

/// State exposed for external refresh via GlobalKey.
class PendingPaymentBannerState extends State<PendingPaymentBanner> {
  List<OfferDisplayModel> _pendingOffers = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Reload pending offers (callable from parent via GlobalKey).
  Future<void> refresh() => _load();

  Future<void> _load() async {
    try {
      final repository =
          widget.repository ?? sl<MarketplaceOfferRepository>();
      final offers = await repository.getOffersAwaitingMyPayment();
      if (!mounted) return;
      setState(() {
        _pendingOffers = offers;
        _loaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _pendingOffers.isEmpty) return const SizedBox.shrink();

    final count = _pendingOffers.length;
    final text = count == 1
        ? 'You have an accepted offer awaiting payment'
        : 'You have $count accepted offers awaiting payment';

    return GestureDetector(
      onTap: () => widget.onTap?.call(_pendingOffers),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: LynewedColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(LynewedBorders.sm),
          border: Border.all(
            color: LynewedColors.warning.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.payment_rounded,
              color: LynewedColors.warning,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: LynewedColors.warning,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
