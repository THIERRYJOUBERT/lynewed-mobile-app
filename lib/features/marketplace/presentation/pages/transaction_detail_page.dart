/// Transaction detail page for the seller.
///
/// Shows transaction details, shipping info, price breakdown,
/// and shipping label generation/viewing functionality.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/marketplace_transaction.dart';
import '../../domain/entities/shipping_label.dart';
import '../../domain/repositories/marketplace_transaction_repository.dart';
import '../../domain/usecases/generate_shipping_label_use_case.dart';
import '../widgets/generate_label_button.dart';
import '../widgets/shipping_label_widget.dart';

/// Displays transaction details for the seller.
///
/// Shows item info, buyer address, price breakdown, status badge,
/// and the shipping label section (generate or view).
class TransactionDetailPage extends StatefulWidget {
  /// Route name for navigation.
  static const String routeName = 'TransactionDetail';

  /// Route path for GoRouter registration.
  static const String routePath = '/marketplace/transaction';

  /// The transaction ID to display.
  final String transactionId;

  /// Repository for loading transaction data. Injectable for testing.
  final MarketplaceTransactionRepository? transactionRepository;

  /// Use case for generating shipping labels. Injectable for testing.
  final GenerateShippingLabelUseCase? generateLabelUseCase;

  const TransactionDetailPage({
    required this.transactionId,
    this.transactionRepository,
    this.generateLabelUseCase,
    super.key,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late final MarketplaceTransactionRepository _repository;
  late final GenerateShippingLabelUseCase _generateLabelUseCase;

  MarketplaceTransaction? _transaction;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.transactionRepository ??
        sl<MarketplaceTransactionRepository>();
    _generateLabelUseCase =
        widget.generateLabelUseCase ?? sl<GenerateShippingLabelUseCase>();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transaction =
          await _repository.getTransaction(widget.transactionId);
      if (mounted) {
        setState(() {
          _transaction = transaction;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _onLabelGenerated(ShippingLabel label) {
    // Reload the transaction to get updated status and label info.
    _loadTransaction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildBody(),
            ),
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
              'Transaction Details',
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

    if (_transaction == null) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBadge(),
          const SizedBox(height: 30),
          _buildShippingSection(),
          const SizedBox(height: 30),
          _buildShippingAddressSection(),
          const SizedBox(height: 30),
          _buildPriceBreakdown(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final tx = _transaction!;
    final statusLabel = _statusDisplayName(tx.status);
    final statusColor = _statusColor(tx.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _statusIcon(tx.status),
            color: statusColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            statusLabel,
            style: LynewedTextStyles.titleSmall.copyWith(
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingSection() {
    final tx = _transaction!;
    final hasLabel = tx.fedexLabelUrl != null && tx.fedexLabelUrl!.isNotEmpty;

    if (hasLabel) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LynewedSectionTitle('Shipping Label'),
          const SizedBox(height: 10),
          ShippingLabelWidget(
            trackingNumber: tx.fedexTrackingNumber ?? '',
            labelUrl: tx.fedexLabelUrl!,
          ),
        ],
      );
    }

    if (tx.isPaid) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LynewedSectionTitle('Shipping'),
          const SizedBox(height: 10),
          GenerateLabelButton(
            transactionId: tx.id,
            serviceType: tx.shippingServiceType ?? 'FEDEX_GROUND',
            generateLabelUseCase: _generateLabelUseCase,
            onSuccess: _onLabelGenerated,
          ),
        ],
      );
    }

    // For other states (pending, etc.), show nothing.
    return const SizedBox.shrink();
  }

  Widget _buildShippingAddressSection() {
    final tx = _transaction!;
    final addr = tx.shippingToAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Ship To'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: LynewedComponentStyles.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (addr.personName != null)
                Text(
                  addr.personName!,
                  style: LynewedTextStyles.titleSmall,
                ),
              if (addr.personName != null) const SizedBox(height: 4),
              ...addr.streetLines.map(
                (line) => Text(
                  line,
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ),
              Text(
                '${addr.city}, ${addr.stateOrProvinceCode ?? ''} ${addr.postalCode}',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
              Text(
                addr.countryCode,
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    final tx = _transaction!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Price Breakdown'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: LynewedComponentStyles.cardDecoration(),
          child: Column(
            children: [
              _priceRow('Item Price', tx.itemPriceInDollars),
              const SizedBox(height: 8),
              _priceRow('Shipping', tx.shippingCostInDollars),
              const SizedBox(height: 8),
              _priceRow('Platform Fee', tx.platformFeeInDollars,
                  isNegative: true),
              const Divider(height: 20),
              _priceRow('Your Payout', tx.sellerPayoutInDollars,
                  isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, double amount,
      {bool isBold = false, bool isNegative = false}) {
    final formattedAmount =
        '\$${amount.toStringAsFixed(2)}';
    final displayAmount = isNegative ? '-$formattedAmount' : formattedAmount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? LynewedTextStyles.titleSmall
              : LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
        ),
        Text(
          displayAmount,
          style: isBold
              ? LynewedTextStyles.titleSmall
              : LynewedTextStyles.bodySmall.copyWith(
                  color: isNegative
                      ? LynewedColors.error
                      : LynewedColors.textPrimary,
                ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: LynewedColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LynewedButton(
              text: 'Retry',
              type: LynewedButtonType.secondary,
              icon: Icons.refresh,
              onPressed: _loadTransaction,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: LynewedColors.gray300,
          ),
          const SizedBox(height: 16),
          Text(
            'Transaction not found',
            style: LynewedTextStyles.titleSmall.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
        ],
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
        return 'Label Created';
      case 'shipped':
        return 'Shipped';
      case 'in_transit':
        return 'In Transit';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Completed';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return LynewedColors.warning;
      case 'paid':
        return LynewedColors.textPrimary;
      case 'label_created':
      case 'shipped':
      case 'in_transit':
      case 'out_for_delivery':
        return LynewedColors.success;
      case 'delivered':
      case 'completed':
        return LynewedColors.success;
      case 'expired':
        return LynewedColors.error;
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
        return Icons.local_shipping_outlined;
      case 'out_for_delivery':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.inventory_2;
      case 'completed':
        return Icons.check_circle;
      case 'expired':
        return Icons.timer_off;
      default:
        return Icons.info_outline;
    }
  }
}
