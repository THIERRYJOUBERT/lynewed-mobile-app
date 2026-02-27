/// Transaction detail page for the seller.
///
/// Shows transaction details, shipping info, price breakdown,
/// and shipping label generation/viewing functionality.
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/marketplace_transaction.dart';
import '../../domain/entities/shipping_label.dart';
import '../../domain/repositories/marketplace_transaction_repository.dart';
import '../../domain/usecases/approve_refund_use_case.dart';
import '../../domain/usecases/cancel_shipment_use_case.dart';
import '../../domain/usecases/generate_shipping_label_use_case.dart';
import '../../domain/usecases/reject_refund_use_case.dart';
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

  /// Use case for cancelling shipments. Injectable for testing.
  final CancelShipmentUseCase? cancelShipmentUseCase;

  /// Use case for approving refunds. Injectable for testing.
  final ApproveRefundUseCase? approveRefundUseCase;

  /// Use case for rejecting refunds. Injectable for testing.
  final RejectRefundUseCase? rejectRefundUseCase;

  const TransactionDetailPage({
    required this.transactionId,
    this.transactionRepository,
    this.generateLabelUseCase,
    this.cancelShipmentUseCase,
    this.approveRefundUseCase,
    this.rejectRefundUseCase,
    super.key,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late final MarketplaceTransactionRepository _repository;
  late final GenerateShippingLabelUseCase _generateLabelUseCase;
  late final CancelShipmentUseCase _cancelShipmentUseCase;
  late final ApproveRefundUseCase _approveRefundUseCase;
  late final RejectRefundUseCase _rejectRefundUseCase;

  MarketplaceTransaction? _transaction;
  bool _isLoading = true;
  bool _isCancelling = false;
  bool _isProcessingRefund = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.transactionRepository ??
        sl<MarketplaceTransactionRepository>();
    _generateLabelUseCase =
        widget.generateLabelUseCase ?? sl<GenerateShippingLabelUseCase>();
    _cancelShipmentUseCase =
        widget.cancelShipmentUseCase ?? sl<CancelShipmentUseCase>();
    _approveRefundUseCase =
        widget.approveRefundUseCase ?? sl<ApproveRefundUseCase>();
    _rejectRefundUseCase =
        widget.rejectRefundUseCase ?? sl<RejectRefundUseCase>();
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

  Future<void> _cancelShipment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Void Shipping Label'),
        content: const Text(
          'Are you sure you want to void this shipping label? '
          'The transaction will revert to "Paid" status and you can '
          'generate a new label.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Void Label',
              style: TextStyle(color: LynewedColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);
    try {
      await _cancelShipmentUseCase.call(
        transactionId: widget.transactionId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shipping label voided successfully')),
        );
        _loadTransaction();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  Future<void> _approveRefund() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Refund'),
        content: const Text(
          'This will issue a full refund to the buyer via Stripe. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Approve Refund',
              style: TextStyle(color: LynewedColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessingRefund = true);
    try {
      await _approveRefundUseCase.call(
        transactionId: widget.transactionId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refund approved and processed')),
        );
        _loadTransaction();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingRefund = false);
    }
  }

  Future<void> _rejectRefund() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline Refund'),
        content: const Text(
          'The buyer will be notified that their refund request '
          'was declined.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Decline'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessingRefund = true);
    try {
      await _rejectRefundUseCase.call(
        transactionId: widget.transactionId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refund request declined')),
        );
        _loadTransaction();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingRefund = false);
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
          if (_transaction!.isRefunded || _transaction!.isDisputed ||
              _transaction!.isExpired ||
              _transaction!.refundRequestedAt != null) ...[
            const SizedBox(height: 12),
            _buildAlertBanner(),
          ],
          const SizedBox(height: 30),
          _buildShippingSection(),
          if (_transaction!.fedexTrackingNumber != null &&
              _transaction!.fedexTrackingNumber!.isNotEmpty) ...[
            const SizedBox(height: 30),
            _buildTrackingLinkSection(),
          ],
          const SizedBox(height: 30),
          _buildShippingAddressSection(),
          const SizedBox(height: 30),
          _buildPriceBreakdown(),
          if (_transaction!.refundRequestedAt != null &&
              !_transaction!.isRefunded) ...[
            const SizedBox(height: 30),
            _buildRefundActions(),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildRefundActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Refund Request'),
        const SizedBox(height: 10),
        if (_transaction!.refundReason != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Reason: ${_transaction!.refundReason}',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: LynewedButton(
                text: _isProcessingRefund ? 'Processing...' : 'Approve Refund',
                icon: Icons.check,
                onPressed: _isProcessingRefund ? null : _approveRefund,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LynewedButton(
                text: 'Decline',
                type: LynewedButtonType.secondary,
                icon: Icons.close,
                onPressed: _isProcessingRefund ? null : _rejectRefund,
              ),
            ),
          ],
        ),
      ],
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
          if (tx.isLabelCreated) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: LynewedButton(
                text: _isCancelling ? 'Voiding...' : 'Void Shipping Label',
                type: LynewedButtonType.secondary,
                icon: Icons.cancel_outlined,
                onPressed: _isCancelling ? null : _cancelShipment,
              ),
            ),
          ],
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

  Future<void> _openFedExTracking() async {
    final trackingNumber = _transaction?.fedexTrackingNumber;
    if (trackingNumber == null) return;
    final url = Uri.parse(
      'https://www.fedex.com/fedextrack/?trknbr=$trackingNumber',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildTrackingLinkSection() {
    final trackingNumber = _transaction!.fedexTrackingNumber!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Package Tracking'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: LynewedComponentStyles.cardDecoration(),
          child: Row(
            children: [
              const Icon(
                Icons.local_shipping,
                size: 18,
                color: LynewedColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trackingNumber,
                  style: LynewedTextStyles.titleSmall.copyWith(fontSize: 14),
                ),
              ),
              GestureDetector(
                onTap: _openFedExTracking,
                child: Text(
                  'Track on FedEx',
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

  Widget _buildAlertBanner() {
    final tx = _transaction!;
    String message;
    IconData icon;
    Color color;

    if (tx.isRefunded) {
      message = 'This transaction has been refunded.';
      icon = Icons.money_off;
      color = LynewedColors.error;
    } else if (tx.isDisputed) {
      message = 'A dispute has been opened on this transaction.';
      icon = Icons.gavel;
      color = LynewedColors.warning;
    } else if (tx.isExpired) {
      message = 'This transaction has expired because the item was not shipped in time.';
      icon = Icons.timer_off;
      color = LynewedColors.error;
    } else if (tx.refundRequestedAt != null) {
      message = 'The buyer has requested a refund.${tx.refundReason != null ? ' Reason: ${tx.refundReason}' : ''}';
      icon = Icons.warning_amber;
      color = LynewedColors.warning;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: LynewedTextStyles.bodySmall.copyWith(color: color),
            ),
          ),
        ],
      ),
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
      case 'refunded':
        return 'Refunded';
      case 'disputed':
        return 'Disputed';
      case 'exception':
        return 'Delivery Exception';
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
        return Icons.local_shipping_outlined;
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
