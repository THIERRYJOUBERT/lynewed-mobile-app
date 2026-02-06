/// Buyer transaction/order detail page.
///
/// Shows the buyer's view of a marketplace transaction including
/// status badge, tracking timeline, delivery address, and price summary.
/// Uses constructor injection for repositories and use cases to support
/// testing.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/marketplace_transaction.dart';
import '../../domain/entities/tracking_event.dart';
import '../../domain/repositories/marketplace_transaction_repository.dart';
import '../../domain/usecases/get_tracking_events_use_case.dart';
import '../../domain/usecases/request_refund_use_case.dart';
import '../widgets/buyer_tracking_timeline.dart';

/// Displays order details for the buyer.
///
/// Shows status badge, tracking timeline (when tracking number exists),
/// delivery address, and price summary (item + shipping = total paid).
class BuyerTransactionPage extends StatefulWidget {
  /// Route name for navigation.
  static const String routeName = 'BuyerTransaction';

  /// Route path for GoRouter registration.
  static const String routePath = '/marketplace/purchase';

  /// The transaction ID to display.
  final String transactionId;

  /// Repository for loading transaction data. Injectable for testing.
  final MarketplaceTransactionRepository? transactionRepository;

  /// Use case for fetching tracking events. Injectable for testing.
  final GetTrackingEventsUseCase? getTrackingEventsUseCase;

  /// Use case for requesting a refund. Injectable for testing.
  final RequestRefundUseCase? requestRefundUseCase;

  const BuyerTransactionPage({
    required this.transactionId,
    this.transactionRepository,
    this.getTrackingEventsUseCase,
    this.requestRefundUseCase,
    super.key,
  });

  @override
  State<BuyerTransactionPage> createState() => _BuyerTransactionPageState();
}

class _BuyerTransactionPageState extends State<BuyerTransactionPage> {
  late final MarketplaceTransactionRepository _repository;
  late final GetTrackingEventsUseCase _getTrackingEventsUseCase;
  late final RequestRefundUseCase _requestRefundUseCase;

  MarketplaceTransaction? _transaction;
  List<TrackingEvent> _trackingEvents = [];
  bool _isLoading = true;
  bool _isRequestingRefund = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.transactionRepository ??
        sl<MarketplaceTransactionRepository>();
    _getTrackingEventsUseCase =
        widget.getTrackingEventsUseCase ?? sl<GetTrackingEventsUseCase>();
    _requestRefundUseCase =
        widget.requestRefundUseCase ?? sl<RequestRefundUseCase>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transaction =
          await _repository.getTransaction(widget.transactionId);
      List<TrackingEvent> events = [];

      // Load tracking events if the transaction has a tracking number.
      if (transaction != null &&
          transaction.fedexTrackingNumber != null &&
          transaction.fedexTrackingNumber!.isNotEmpty) {
        try {
          events = await _getTrackingEventsUseCase.call(transaction.id);
        } catch (_) {
          // Tracking events are non-critical; display what we have.
        }
      }

      if (mounted) {
        setState(() {
          _transaction = transaction;
          _trackingEvents = events;
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
              'Order Details',
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

    final tx = _transaction!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBadge(),
          if (tx.isRefunded || tx.isDisputed || tx.isExpired ||
              tx.refundRequestedAt != null) ...[
            const SizedBox(height: 12),
            _buildAlertBanner(),
          ],
          const SizedBox(height: 30),
          if (_hasTrackingNumber()) ...[
            BuyerTrackingTimeline(
              currentStatus: tx.status,
              trackingNumber: tx.fedexTrackingNumber,
              events: _trackingEvents,
            ),
            const SizedBox(height: 30),
          ],
          _buildDeliveryAddressSection(),
          const SizedBox(height: 30),
          _buildPriceSummary(),
          if (_canRequestRefund()) ...[
            const SizedBox(height: 30),
            _buildRefundSection(),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  bool _hasTrackingNumber() {
    return _transaction != null &&
        _transaction!.fedexTrackingNumber != null &&
        _transaction!.fedexTrackingNumber!.isNotEmpty;
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

  Widget _buildDeliveryAddressSection() {
    final addr = _transaction!.shippingToAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Delivery Address'),
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

  Widget _buildPriceSummary() {
    final tx = _transaction!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Price Summary'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: LynewedComponentStyles.cardDecoration(),
          child: Column(
            children: [
              _priceRow('Item Price', tx.itemPriceInDollars),
              const SizedBox(height: 8),
              _priceRow('Shipping', tx.shippingCostInDollars),
              const Divider(height: 20),
              _priceRow('Total Paid', tx.totalPaidInDollars, isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, double amount, {bool isBold = false}) {
    final formattedAmount = '\$${amount.toStringAsFixed(2)}';

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
          formattedAmount,
          style: isBold
              ? LynewedTextStyles.titleSmall
              : LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textPrimary,
                ),
        ),
      ],
    );
  }

  bool _canRequestRefund() {
    final tx = _transaction;
    if (tx == null) return false;
    // Can request refund if not already completed/refunded/disputed/expired
    // and no existing refund request
    final eligibleStatuses = ['paid', 'label_created', 'shipped', 'in_transit',
        'out_for_delivery', 'delivered'];
    return eligibleStatuses.contains(tx.status) &&
        tx.refundRequestedAt == null;
  }

  Widget _buildAlertBanner() {
    final tx = _transaction!;
    String message;
    IconData icon;
    Color color;

    if (tx.isRefunded) {
      message = 'This order has been refunded.';
      icon = Icons.money_off;
      color = LynewedColors.error;
    } else if (tx.isDisputed) {
      message = 'A dispute is open on this order.';
      icon = Icons.gavel;
      color = LynewedColors.warning;
    } else if (tx.isExpired) {
      message = 'This order has expired.';
      icon = Icons.timer_off;
      color = LynewedColors.error;
    } else if (tx.refundRequestedAt != null) {
      message = 'Your refund request is pending seller review.';
      icon = Icons.hourglass_top;
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

  Widget _buildRefundSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Need Help?'),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: LynewedButton(
            text: _isRequestingRefund ? 'Requesting...' : 'Request Refund',
            type: LynewedButtonType.secondary,
            icon: Icons.money_off,
            onPressed: _isRequestingRefund ? null : _showRefundSheet,
          ),
        ),
      ],
    );
  }

  void _showRefundSheet() {
    String? selectedReason;
    final reasons = [
      'Item not received',
      'Item damaged',
      'Not as described',
      'Changed my mind',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request Refund',
                style: LynewedTextStyles.sheetTitle,
              ),
              const SizedBox(height: 20),
              Text(
                'Select a reason:',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              ...reasons.map((reason) => RadioListTile<String>(
                    title: Text(reason, style: LynewedTextStyles.bodySmall),
                    value: reason,
                    groupValue: selectedReason,
                    activeColor: LynewedColors.primary,
                    onChanged: (val) =>
                        setSheetState(() => selectedReason = val),
                  )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: LynewedButton(
                  text: 'Submit Request',
                  onPressed: selectedReason == null
                      ? null
                      : () {
                          Navigator.pop(ctx);
                          _requestRefund(selectedReason!);
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestRefund(String reason) async {
    setState(() => _isRequestingRefund = true);
    try {
      await _requestRefundUseCase.call(
        transactionId: widget.transactionId,
        reason: reason,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refund request submitted')),
        );
        _loadData();
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
      if (mounted) setState(() => _isRequestingRefund = false);
    }
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
              onPressed: _loadData,
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
            'Order not found',
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
      case 'out_for_delivery':
        return 'Out for Delivery';
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
