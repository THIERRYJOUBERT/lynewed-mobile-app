/// Buyer's purchase history page.
///
/// Displays all transactions where the current user is the buyer,
/// with status badges, item info, and navigation to order details.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/marketplace_transaction.dart';
import '../../domain/repositories/marketplace_transaction_repository.dart';
import 'buyer_transaction_page.dart';

/// Displays the buyer's purchase history with status-based badges.
class MyPurchasesPage extends StatefulWidget {
  /// Route name for navigation.
  static const String routeName = 'MyPurchases';

  /// Route path for GoRouter registration.
  static const String routePath = '/marketplace/my-purchases';

  /// Repository for loading purchase data. Injectable for testing.
  final MarketplaceTransactionRepository? transactionRepository;

  /// Optional callback when a transaction is tapped (for testing).
  final void Function(String transactionId)? onTransactionTap;

  const MyPurchasesPage({
    this.transactionRepository,
    this.onTransactionTap,
    super.key,
  });

  @override
  State<MyPurchasesPage> createState() => _MyPurchasesPageState();
}

class _MyPurchasesPageState extends State<MyPurchasesPage> {
  late final MarketplaceTransactionRepository _repository;

  bool _isLoading = true;
  String? _errorMessage;
  List<MarketplaceTransaction> _purchases = [];

  @override
  void initState() {
    super.initState();
    _repository = widget.transactionRepository ??
        sl<MarketplaceTransactionRepository>();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final purchases = await _repository.getMyPurchases();
      if (mounted) {
        setState(() {
          _purchases = purchases;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load purchases';
        });
      }
    }
  }

  void _onPurchaseTap(MarketplaceTransaction tx) {
    if (widget.onTransactionTap != null) {
      widget.onTransactionTap!(tx.id);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BuyerTransactionPage(transactionId: tx.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'My Purchases',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: LynewedColors.primary),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_purchases.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadPurchases,
      color: LynewedColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _purchases.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) => _buildPurchaseTile(_purchases[index]),
      ),
    );
  }

  Widget _buildPurchaseTile(MarketplaceTransaction tx) {
    return GestureDetector(
      onTap: () => _onPurchaseTap(tx),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LynewedColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LynewedColors.gray200),
        ),
        child: Row(
          children: [
            // Status icon.
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _statusColor(tx.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _statusIcon(tx.status),
                color: _statusColor(tx.status),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Info section.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${tx.id.substring(0, 8)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LynewedTextStyles.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(tx.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${tx.totalPaidInDollars.toStringAsFixed(2)}',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: LynewedColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (tx.refundRequestedAt != null && !tx.isRefunded)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Refund pending',
                        style: LynewedTextStyles.labelSmall.copyWith(
                          color: LynewedColors.warning,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: LynewedColors.gray300,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final label = _statusDisplayName(status);
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: LynewedTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: LynewedColors.gray300,
            ),
            SizedBox(height: LynewedSpacing.lg),
            Text(
              'No purchases yet',
              style: LynewedTextStyles.titleSmall.copyWith(
                color: LynewedColors.textPrimary,
              ),
            ),
            SizedBox(height: LynewedSpacing.sm),
            Text(
              'Items you buy from the marketplace will appear here',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: LynewedColors.error,
            ),
            SizedBox(height: LynewedSpacing.lg),
            Text(
              _errorMessage ?? 'Failed to load purchases',
              style: LynewedTextStyles.titleSmall.copyWith(
                color: LynewedColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: LynewedSpacing.lg),
            LynewedButton(
              text: 'Retry',
              type: LynewedButtonType.secondary,
              onPressed: _loadPurchases,
            ),
          ],
        ),
      ),
    );
  }

  String _statusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'label_created':
        return 'Preparing';
      case 'shipped':
        return 'Shipped';
      case 'in_transit':
        return 'In Transit';
      case 'out_for_delivery':
        return 'Delivering';
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Completed';
      case 'expired':
        return 'Expired';
      case 'refunded':
        return 'Refunded';
      case 'disputed':
        return 'Disputed';
      case 'exception':
        return 'Exception';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return LynewedColors.warning;
      case 'paid':
      case 'label_created':
        return LynewedColors.textPrimary;
      case 'shipped':
      case 'in_transit':
      case 'out_for_delivery':
        return LynewedColors.success;
      case 'delivered':
      case 'completed':
        return LynewedColors.success;
      case 'expired':
      case 'refunded':
        return LynewedColors.error;
      case 'disputed':
      case 'exception':
        return LynewedColors.warning;
      default:
        return LynewedColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'paid':
        return Icons.payment;
      case 'label_created':
        return Icons.label_outline;
      case 'shipped':
        return Icons.local_shipping;
      case 'in_transit':
        return Icons.flight_takeoff;
      case 'out_for_delivery':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.inventory_2;
      case 'completed':
        return Icons.check_circle;
      case 'expired':
        return Icons.timer_off;
      case 'refunded':
        return Icons.money_off;
      case 'disputed':
        return Icons.gavel;
      case 'exception':
        return Icons.warning_amber;
      default:
        return Icons.info_outline;
    }
  }
}
