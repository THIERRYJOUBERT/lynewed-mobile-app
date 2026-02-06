/// Seller action banner for marketplace.
///
/// Displays a banner when the seller has paid transactions that need
/// shipping labels generated. Self-loading widget that queries the
/// transaction repository.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/marketplace_transaction.dart';
import '../../domain/repositories/marketplace_transaction_repository.dart';

/// Banner shown when the seller has items sold that need to be shipped.
///
/// Loads transactions via
/// [MarketplaceTransactionRepository.getTransactionsAwaitingShipment]
/// and displays a tappable banner with the count. Renders nothing when
/// there are no transactions awaiting shipment or on error.
class SellerActionBanner extends StatefulWidget {
  /// Creates a seller action banner.
  const SellerActionBanner({
    this.repository,
    this.onTap,
    super.key,
  });

  /// Optional repository override (for testing).
  final MarketplaceTransactionRepository? repository;

  /// Called when the banner is tapped, with the list of transactions.
  final void Function(List<MarketplaceTransaction> transactions)? onTap;

  @override
  State<SellerActionBanner> createState() => SellerActionBannerState();
}

/// State exposed for external refresh via GlobalKey.
class SellerActionBannerState extends State<SellerActionBanner> {
  List<MarketplaceTransaction> _transactions = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Reload transactions (callable from parent via GlobalKey).
  Future<void> refresh() => _load();

  Future<void> _load() async {
    try {
      final repository =
          widget.repository ?? sl<MarketplaceTransactionRepository>();
      final transactions = await repository.getTransactionsAwaitingShipment();
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _loaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _transactions.isEmpty) return const SizedBox.shrink();

    final count = _transactions.length;
    final text = count == 1
        ? 'You sold an item — generate shipping label to send it'
        : 'You sold $count items — generate shipping labels to send them';

    return GestureDetector(
      onTap: () => widget.onTap?.call(_transactions),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: LynewedColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(LynewedBorders.sm),
          border: Border.all(
            color: LynewedColors.success.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_shipping_outlined,
              color: LynewedColors.success,
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
              color: LynewedColors.success,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
