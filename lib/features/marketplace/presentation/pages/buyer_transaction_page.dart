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

  const BuyerTransactionPage({
    required this.transactionId,
    this.transactionRepository,
    this.getTrackingEventsUseCase,
    super.key,
  });

  @override
  State<BuyerTransactionPage> createState() => _BuyerTransactionPageState();
}

class _BuyerTransactionPageState extends State<BuyerTransactionPage> {
  late final MarketplaceTransactionRepository _repository;
  late final GetTrackingEventsUseCase _getTrackingEventsUseCase;

  MarketplaceTransaction? _transaction;
  List<TrackingEvent> _trackingEvents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.transactionRepository ??
        sl<MarketplaceTransactionRepository>();
    _getTrackingEventsUseCase =
        widget.getTrackingEventsUseCase ?? sl<GetTrackingEventsUseCase>();
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBadge(),
          const SizedBox(height: 30),
          if (_hasTrackingNumber()) ...[
            BuyerTrackingTimeline(
              currentStatus: _transaction!.status,
              trackingNumber: _transaction!.fedexTrackingNumber,
              events: _trackingEvents,
            ),
            const SizedBox(height: 30),
          ],
          _buildDeliveryAddressSection(),
          const SizedBox(height: 30),
          _buildPriceSummary(),
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
        return LynewedColors.success;
      case 'delivered':
      case 'completed':
        return LynewedColors.success;
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
      case 'delivered':
        return Icons.inventory_2;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.info_outline;
    }
  }
}
