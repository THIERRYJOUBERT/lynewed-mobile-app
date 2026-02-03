/// Magazine Checkout Page - Order magazine with Stripe payment.
///
/// Displays order summary, shipping address form, CGVU acceptance,
/// and initiates Stripe Checkout payment.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '/core/design/design.dart';

import '../../domain/entities/magazine_format.dart';
import '../bloc/magazine_checkout_cubit.dart';
import '../bloc/magazine_checkout_state.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/shipping_address_form.dart';

/// Page for magazine checkout with Stripe payment.
class MagazineCheckoutPage extends StatefulWidget {
  /// Creates a magazine checkout page.
  const MagazineCheckoutPage({
    super.key,
    required this.weddingId,
    required this.brideUserId,
    required this.format,
    required this.photoCount,
    required this.weddingTitle,
    this.weddingDate,
    this.coverPhotoId,
    this.coverPhotoUrl,
    this.onNavigateBack,
    this.onNavigateToConfirmation,
  });

  /// Wedding ID for the order.
  final String weddingId;

  /// Bride user ID for the order.
  final String brideUserId;

  /// Selected magazine format.
  final MagazineFormat format;

  /// Number of photos in the magazine.
  final int photoCount;

  /// Wedding title for the cover.
  final String weddingTitle;

  /// Wedding date (optional).
  final DateTime? weddingDate;

  /// Cover photo ID (optional).
  final String? coverPhotoId;

  /// Cover photo URL for preview (optional).
  final String? coverPhotoUrl;

  /// Callback to navigate back.
  final VoidCallback? onNavigateBack;

  /// Callback to navigate to confirmation page after success.
  final void Function(String sessionId, String? orderId)?
      onNavigateToConfirmation;

  @override
  State<MagazineCheckoutPage> createState() => _MagazineCheckoutPageState();
}

class _MagazineCheckoutPageState extends State<MagazineCheckoutPage> {
  late MagazineCheckoutCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = MagazineCheckoutCubit(
      weddingId: widget.weddingId,
      brideUserId: widget.brideUserId,
      format: widget.format,
      photoCount: widget.photoCount,
      weddingTitle: widget.weddingTitle,
      weddingDate: widget.weddingDate,
      coverPhotoId: widget.coverPhotoId,
      coverPhotoUrl: widget.coverPhotoUrl,
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _openTermsOfPurchase() async {
    const url = 'https://lynewed.com/terms-of-purchase';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<MagazineCheckoutCubit, MagazineCheckoutState>(
        listener: (context, state) {
          // Handle navigation to confirmation on success
          if (state.isSuccess && widget.onNavigateToConfirmation != null) {
            widget.onNavigateToConfirmation!(
              state.checkoutSessionId ?? '',
              state.orderId,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: LynewedColors.surface,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: state.isProcessing
                        ? _buildProcessing()
                        : state.isFailed
                            ? _buildError(state)
                            : _buildContent(state),
                  ),
                  if (!state.isProcessing && !state.isFailed)
                    _buildBottomBar(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
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
          LynewedComponentStyles.backButton(
            context,
            onTap: widget.onNavigateBack,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Order Magazine',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessing() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'Processing your order...',
            style: LynewedTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Please complete the payment in your browser',
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => _cubit.onPaymentCancelled(),
            child: Text(
              'Cancel',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(MagazineCheckoutState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LynewedColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: LynewedColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Failed',
              style: LynewedTextStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'An error occurred during payment',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            LynewedButton(
              text: 'Try Again',
              onPressed: () => _cubit.retryCheckout(),
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(MagazineCheckoutState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary Section
          Text(
            'ORDER SUMMARY',
            style: LynewedTextStyles.sectionTitle.copyWith(
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          OrderSummaryCard(
            format: state.format,
            photoCount: state.photoCount,
            magazinePriceCents: state.magazinePriceCents,
            shippingCostCents: state.shippingCostCents,
            coverPhotoUrl: state.coverPhotoUrl,
            weddingTitle: state.weddingTitle,
          ),
          const SizedBox(height: 30),

          // Shipping Address Section
          Text(
            'SHIPPING ADDRESS',
            style: LynewedTextStyles.sectionTitle.copyWith(
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: LynewedColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LynewedColors.border),
            ),
            child: ShippingAddressForm(
              address: state.address!,
              onAddressChanged: (address) => _cubit.updateAddress(address),
            ),
          ),
          const SizedBox(height: 30),

          // CGVU Acceptance
          _buildCgvuCheckbox(state),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCgvuCheckbox(MagazineCheckoutState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LynewedColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _cubit.toggleCgvuAccepted(),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: state.cgvuAccepted
                    ? LynewedColors.primary
                    : LynewedColors.background,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: state.cgvuAccepted
                      ? LynewedColors.primary
                      : LynewedColors.border,
                  width: 2,
                ),
              ),
              child: state.cgvuAccepted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textPrimary,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'I have read and accept the '),
                  TextSpan(
                    text: 'Terms of Purchase',
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = _openTermsOfPurchase,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(MagazineCheckoutState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: LynewedButton(
        text: 'Pay ${state.totalFormatted} with Stripe',
        onPressed: state.canProceed ? () => _cubit.initiateCheckout() : null,
        width: double.infinity,
        icon: Icons.lock_outline,
      ),
    );
  }
}
