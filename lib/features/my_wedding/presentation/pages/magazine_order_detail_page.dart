/// Magazine Order Detail Page.
///
/// Displays full order details with magazine preview, status timeline,
/// pricing breakdown, and shipping information.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '/core/design/design.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/magazine_layout_service.dart';
import '../bloc/magazine_selection_state.dart';
import '../widgets/magazine_cover.dart';
import '/pages/shared/support/support_widget.dart';
import 'magazine_full_preview_page.dart';

/// Page showing detailed information about a magazine order.
class MagazineOrderDetailPage extends StatefulWidget {
  /// Creates a magazine order detail page.
  const MagazineOrderDetailPage({
    super.key,
    required this.order,
  });

  /// The order to display.
  final MagazineOrder order;

  @override
  State<MagazineOrderDetailPage> createState() =>
      _MagazineOrderDetailPageState();
}

class _MagazineOrderDetailPageState extends State<MagazineOrderDetailPage> {
  final _repository = MyWeddingRepositoryImpl();
  List<MagazineOrderItem>? _orderItems;
  List<MagazinePage>? _magazinePages;
  bool _isLoadingItems = true;

  MagazineOrder get order => widget.order;

  @override
  void initState() {
    super.initState();
    _loadOrderItems();
  }

  Future<void> _loadOrderItems() async {
    final result = await _repository.getMagazineOrderItems(
      orderId: order.id,
    );

    if (!mounted) return;

    if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
      final items = result.data!;
      final photos = items
          .map((item) => MagazinePhoto(
                selectionId: item.id,
                mediaType: item.mediaType,
                mediaId: item.mediaId,
                position: item.position,
                thumbnailUrl: item.storageUrl,
              ))
          .toList();

      final pages = const MagazineLayoutService().generateLayouts(
        photos: photos,
        weddingTitle: order.magazineTitle,
        weddingDate: order.paidAt ?? order.createdAt,
      );

      setState(() {
        _orderItems = items;
        _magazinePages = pages;
        _isLoadingItems = false;
      });
    } else {
      setState(() => _isLoadingItems = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusHeader(),
                    const SizedBox(height: 30),
                    _buildMagazinePreview(),
                    const SizedBox(height: 30),
                    _buildTimeline(),
                    const SizedBox(height: 30),
                    _buildOrderSummary(),
                    const SizedBox(height: 30),
                    if (order.shippingName != null) ...[
                      _buildShippingInfo(),
                      const SizedBox(height: 30),
                    ],
                    if (order.trackingNumber != null) ...[
                      _buildTrackingInfo(),
                      const SizedBox(height: 30),
                    ],
                    _buildContactSupport(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
      decoration: const BoxDecoration(
        color: LynewedColors.background,
        border: Border(
          bottom: BorderSide(color: LynewedColors.border),
        ),
      ),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Order Details',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: order.statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: order.statusColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: order.statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statusIcon,
              color: order.statusColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            order.statusLabel,
            style: LynewedTextStyles.titleMedium.copyWith(
              color: order.statusColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _statusDescription,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData get _statusIcon {
    switch (order.status) {
      case 'paid':
        return Icons.check_circle_outline;
      case 'in_production':
        return Icons.precision_manufacturing_outlined;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.inventory_2_outlined;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty;
    }
  }

  String get _statusDescription {
    switch (order.status) {
      case 'paid':
        return 'Your order has been confirmed and is awaiting production.';
      case 'in_production':
        return 'Your magazine is being printed. This usually takes 3-5 business days.';
      case 'shipped':
        return 'Your magazine is on its way!';
      case 'delivered':
        return 'Your magazine has been delivered. Enjoy!';
      case 'cancelled':
        return 'This order has been cancelled.';
      default:
        return 'Processing your order...';
    }
  }

  // ── Magazine Preview Section ───────────────────────────────────────────

  Widget _buildMagazinePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MAGAZINE PREVIEW',
          style: LynewedTextStyles.sectionTitle.copyWith(
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _openFullPreview,
          child: Center(
            child: SizedBox(
              height: 280,
              child: AspectRatio(
                aspectRatio: 0.7,
                child: _buildCoverContent(),
              ),
            ),
          ),
        ),
        if (_magazinePages != null && _magazinePages!.length > 1) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Tap to preview all ${_magazinePages!.length} pages',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCoverContent() {
    if (_isLoadingItems) {
      return Container(
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
          ),
        ),
      );
    }

    if (_magazinePages != null &&
        _magazinePages!.isNotEmpty &&
        _magazinePages!.first is CoverPage) {
      return MagazineCover(page: _magazinePages!.first as CoverPage);
    }

    // Fallback: simple cover with first photo or placeholder.
    final coverUrl = _orderItems?.isNotEmpty == true
        ? _orderItems!.first.storageUrl
        : null;

    return Container(
      decoration: BoxDecoration(
        color: LynewedColors.surface,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (coverUrl != null)
              CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: LynewedColors.surface,
                ),
                errorWidget: (_, __, ___) => Container(
                  color: LynewedColors.surface,
                  child: const Icon(
                    Icons.photo_album_outlined,
                    size: 48,
                    color: LynewedColors.gray300,
                  ),
                ),
              )
            else
              const Center(
                child: Icon(
                  Icons.photo_album_outlined,
                  size: 48,
                  color: LynewedColors.gray300,
                ),
              ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
            // Title
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Text(
                order.magazineTitle,
                style: LynewedTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullPreview() {
    if (_magazinePages == null || _magazinePages!.isEmpty) return;

    final format = MagazineFormats.all.firstWhere(
      (f) => f.id == order.magazineFormat,
      orElse: () => MagazineFormats.all.first,
    );

    MagazineFullPreviewPage.show(
      context,
      pages: _magazinePages!,
      aspectRatio: format.aspectRatio,
    );
  }

  // ── Timeline Section ───────────────────────────────────────────────────

  Widget _buildTimeline() {
    final steps = [
      _TimelineStep(
        title: 'Order Confirmed',
        subtitle: order.paidAt != null
            ? DateFormat('MMM d, yyyy').format(order.paidAt!)
            : null,
        isCompleted: order.isPaid,
        isActive: order.status == 'paid',
      ),
      _TimelineStep(
        title: 'In Production',
        subtitle: order.productionStartedAt != null
            ? DateFormat('MMM d, yyyy').format(order.productionStartedAt!)
            : order.isPaid && !order.isInProduction
                ? '3-5 business days'
                : null,
        isCompleted: order.isInProduction,
        isActive: order.status == 'in_production',
      ),
      _TimelineStep(
        title: 'Shipped',
        subtitle: order.shippedAt != null
            ? DateFormat('MMM d, yyyy').format(order.shippedAt!)
            : order.trackingNumber,
        isCompleted: order.isShipped,
        isActive: order.status == 'shipped',
      ),
      _TimelineStep(
        title: 'Delivered',
        subtitle: order.deliveredAt != null
            ? DateFormat('MMM d, yyyy').format(order.deliveredAt!)
            : null,
        isCompleted: order.isDelivered,
        isActive: order.status == 'delivered',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TRACKING',
          style: LynewedTextStyles.sectionTitle.copyWith(
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LynewedColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                _buildTimelineRow(steps[i], isLast: i == steps.length - 1),
                if (i < steps.length - 1)
                  _buildTimelineLine(steps[i].isCompleted),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineRow(_TimelineStep step, {required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: step.isCompleted
                ? LynewedColors.success
                : step.isActive
                    ? LynewedColors.primary
                    : LynewedColors.gray200,
            border: step.isActive
                ? Border.all(color: LynewedColors.primary, width: 2)
                : null,
          ),
          child: step.isCompleted
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  fontWeight: step.isCompleted || step.isActive
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: step.isCompleted || step.isActive
                      ? LynewedColors.textPrimary
                      : LynewedColors.textSecondary,
                ),
              ),
              if (step.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  step.subtitle!,
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine(bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(left: 11),
      child: Container(
        width: 2,
        height: 24,
        color: isCompleted ? LynewedColors.success : LynewedColors.gray200,
      ),
    );
  }

  // ── Order Summary Section ──────────────────────────────────────────────

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORDER SUMMARY',
          style: LynewedTextStyles.sectionTitle.copyWith(
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LynewedColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${order.formatDisplayName} Wedding Magazine',
                style: LynewedTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${order.formatSize} \u2022 ${order.photoCount} photos',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: LynewedColors.border),
              const SizedBox(height: 12),
              _buildPriceRow(
                'Magazine (${order.formatDisplayName})',
                order.formattedMagazinePrice,
              ),
              const SizedBox(height: 8),
              _buildPriceRow('Shipping', order.formattedShippingCost),
              const SizedBox(height: 12),
              const Divider(color: LynewedColors.border),
              const SizedBox(height: 12),
              _buildPriceRow('Total', order.formattedTotal, isTotal: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String price, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? LynewedTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)
              : LynewedTextStyles.bodySmall
                  .copyWith(color: LynewedColors.textSecondary),
        ),
        Text(
          price,
          style: isTotal
              ? LynewedTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)
              : LynewedTextStyles.bodySmall,
        ),
      ],
    );
  }

  // ── Shipping Info Section ──────────────────────────────────────────────

  Widget _buildShippingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SHIPPING ADDRESS',
          style: LynewedTextStyles.sectionTitle.copyWith(
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LynewedColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            order.formattedShippingAddress,
            style: LynewedTextStyles.bodyMedium.copyWith(
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── Tracking Info Section ──────────────────────────────────────────────

  Widget _buildTrackingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TRACKING',
          style: LynewedTextStyles.sectionTitle.copyWith(
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LynewedColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.local_shipping_outlined,
                color: LynewedColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.trackingNumber!,
                      style: LynewedTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (order.trackingUrl != null) ...[
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () => _openTrackingUrl(),
                        child: Text(
                          'Track shipment',
                          style: LynewedTextStyles.bodySmall.copyWith(
                            color: LynewedColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openTrackingUrl() async {
    if (order.trackingUrl == null) return;
    final uri = Uri.parse(order.trackingUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Contact Support Section ────────────────────────────────────────────

  Widget _buildContactSupport(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _openSupport(context),
        icon: const Icon(
          Icons.help_outline,
          size: 18,
          color: LynewedColors.textSecondary,
        ),
        label: Text(
          'Contact Support',
          style: LynewedTextStyles.bodySmall.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _openSupport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SupportWidget(
          prefilledSubject: 'Magazine order issue',
          prefilledMessage: 'Order ID: ${order.id}\n'
              'Format: ${order.formatDisplayName}\n'
              'Status: ${order.statusLabel}\n\n',
        ),
      ),
    );
  }
}

/// Internal model for timeline steps.
class _TimelineStep {
  const _TimelineStep({
    required this.title,
    this.subtitle,
    required this.isCompleted,
    required this.isActive,
  });

  final String title;
  final String? subtitle;
  final bool isCompleted;
  final bool isActive;
}
