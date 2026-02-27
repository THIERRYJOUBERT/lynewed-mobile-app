/// Checkout page for marketplace purchases.
///
/// Multi-step checkout flow:
/// 1. Enter/confirm shipping address
/// 2. Select shipping rate (FedEx dynamic rates)
/// 3. Review order summary
/// 4. Accept CGVU (if first purchase)
/// 5. Pay via Stripe Checkout (opens URL)
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/marketplace_listing.dart';
import '../../domain/entities/shipping_address.dart';
import '../../domain/entities/shipping_rate.dart';
import '../../domain/repositories/marketplace_transaction_repository.dart';
import '../../domain/usecases/calculate_shipping_rate_use_case.dart';
import '../../domain/usecases/get_seller_shipping_address.dart';
import '../widgets/address_form_widget.dart';
import '../widgets/cgvu_acceptance_widget.dart';
import '../widgets/order_summary_widget.dart';
import '../widgets/shipping_rate_selector.dart';

/// Multi-step checkout page for marketplace purchases.
///
/// Steps: Address -> Shipping -> Review -> Confirm (CGVU + Pay).
/// Shipping rates are fetched dynamically from FedEx API.
/// Uses StatefulWidget with dependency injection for testing.
class CheckoutPage extends StatefulWidget {
  /// Creates a checkout page.
  const CheckoutPage({
    required this.listing,
    this.offerId,
    this.agreedPriceCents,
    this.transactionRepository,
    this.calculateShippingRateUseCase,
    this.getSellerShippingAddress,
    this.currentUserId,
    super.key,
  });

  /// The listing being purchased.
  final MarketplaceListing listing;

  /// Optional offer ID if buying via accepted offer.
  final String? offerId;

  /// Agreed price in cents (from offer), overrides listing price.
  final int? agreedPriceCents;

  /// Optional transaction repository override for testing.
  final MarketplaceTransactionRepository? transactionRepository;

  /// Optional use case override for testing.
  final CalculateShippingRateUseCase? calculateShippingRateUseCase;

  /// Optional use case override for testing.
  final GetSellerShippingAddress? getSellerShippingAddress;

  /// Optional current user ID override for testing.
  final String? currentUserId;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final MarketplaceTransactionRepository _transactionRepo;
  late final CalculateShippingRateUseCase _calculateShippingRate;
  late final GetSellerShippingAddress _getSellerShippingAddress;

  // Step management: Address -> Shipping -> Review -> Confirm
  int _currentStep = 0;
  static const int _totalSteps = 4;

  // Step 1: Address
  ShippingAddress? _shippingAddress;

  // Step 2: Shipping rates (FedEx dynamic)
  List<ShippingRate> _fedexRates = [];
  ShippingRate? _selectedRate;
  bool _isLoadingRates = false;
  String? _ratesError;

  // Step 3: Review
  int get _itemPriceCents => widget.agreedPriceCents ?? widget.listing.priceCents;

  // Step 4: CGVU
  bool _alreadyAcceptedCgvu = false;
  bool _cgvuChecked = false;
  bool _isCheckingCgvu = false;

  // Payment
  bool _isProcessingPayment = false;
  String? _paymentError;

  @override
  void initState() {
    super.initState();
    _transactionRepo = widget.transactionRepository ??
        sl<MarketplaceTransactionRepository>();
    _calculateShippingRate = widget.calculateShippingRateUseCase ??
        sl<CalculateShippingRateUseCase>();
    _getSellerShippingAddress = widget.getSellerShippingAddress ??
        sl<GetSellerShippingAddress>();
    _checkCgvuStatus();
  }

  Future<void> _checkCgvuStatus() async {
    setState(() => _isCheckingCgvu = true);
    try {
      final accepted = await _transactionRepo.hasAcceptedBuyerCgvu();
      if (!mounted) return;
      setState(() {
        _alreadyAcceptedCgvu = accepted;
        _cgvuChecked = accepted;
        _isCheckingCgvu = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCheckingCgvu = false);
    }
  }

  /// Fetches dynamic shipping rates from FedEx API.
  ///
  /// Retrieves the seller's shipping address, then calls FedEx rate API
  /// with both addresses and the listing's category/weight.
  Future<void> _fetchShippingRates() async {
    if (_shippingAddress == null || _isLoadingRates) return;

    setState(() {
      _isLoadingRates = true;
      _ratesError = null;
      _fedexRates = [];
      _selectedRate = null;
    });

    try {
      final sellerAddress = await _getSellerShippingAddress(
        widget.listing.sellerId,
      );

      final rates = await _calculateShippingRate(
        fromAddress: sellerAddress,
        toAddress: _shippingAddress!,
        category: widget.listing.category,
        weightKg: widget.listing.weightKg,
      );

      if (!mounted) return;

      if (rates.isEmpty) {
        setState(() {
          _isLoadingRates = false;
          _ratesError =
              'No shipping options available for this route. Please try a different address.';
        });
        return;
      }

      setState(() {
        _fedexRates = rates;
        _isLoadingRates = false;
        // Auto-select the cheapest rate for user convenience.
        final sorted = List<ShippingRate>.from(rates)
          ..sort((a, b) => a.rateCents.compareTo(b.rateCents));
        _selectedRate = sorted.first;
      });
    } on SellerAddressException catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingRates = false;
        _ratesError =
            'Unable to calculate shipping for this listing. Please contact the seller.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingRates = false;
        _ratesError = 'Could not fetch shipping rates. Please try again.';
      });
    }
  }

  Future<void> _processPayment() async {
    if (_selectedRate == null || _shippingAddress == null) return;

    setState(() {
      _isProcessingPayment = true;
      _paymentError = null;
    });

    try {
      // Accept CGVU if not already accepted
      if (!_alreadyAcceptedCgvu) {
        await _transactionRepo.acceptBuyerCgvu();
      }

      // Create checkout session
      final session = await _transactionRepo.createCheckoutSession(
        listingId: widget.listing.id,
        offerId: widget.offerId,
        shippingToAddress: _shippingAddress!,
        shippingOption: _selectedRate!,
      );

      final checkoutUrl = session['checkout_url'] as String?;
      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        throw Exception('No checkout URL received');
      }

      // Open Stripe Checkout in external browser
      final uri = Uri.parse(checkoutUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not open payment page');
      }

      if (!mounted) return;
      setState(() => _isProcessingPayment = false);

      // Pop back to listing detail - the deep link will handle
      // navigation to confirmation page after payment.
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessingPayment = false;
        _paymentError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _shippingAddress != null;
      case 1:
        return _selectedRate != null && !_isLoadingRates;
      case 2:
        return true; // Review is informational
      case 3:
        return _cgvuChecked || _alreadyAcceptedCgvu;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep == 0 && _shippingAddress != null) {
      // Moving from address to shipping: fetch FedEx rates
      _fetchShippingRates();
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      // Last step: process payment
      _processPayment();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
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
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildStepContent(),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Checkout',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    const stepLabels = ['Address', 'Shipping', 'Review', 'Confirm'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(stepLabels.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (index > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted || isActive
                              ? LynewedColors.primary
                              : LynewedColors.gray200,
                        ),
                      ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive || isCompleted
                            ? LynewedColors.primary
                            : LynewedColors.gray200,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check,
                                size: 14, color: LynewedColors.background)
                            : Text(
                                '${index + 1}',
                                style: LynewedTextStyles.bodySmall.copyWith(
                                  color: isActive
                                      ? LynewedColors.background
                                      : LynewedColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                    ),
                    if (index < stepLabels.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted
                              ? LynewedColors.primary
                              : LynewedColors.gray200,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  stepLabels[index],
                  style: LynewedTextStyles.bodySmall.copyWith(
                    fontSize: 10,
                    color: isActive || isCompleted
                        ? LynewedColors.textPrimary
                        : LynewedColors.textSecondary,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildAddressStep();
      case 1:
        return _buildShippingStep();
      case 2:
        return _buildReviewStep();
      case 3:
        return _buildConfirmStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAddressStep() {
    return AddressFormWidget(
      initialAddress: _shippingAddress,
      onAddressChanged: (address) {
        setState(() => _shippingAddress = address);
      },
    );
  }

  Widget _buildShippingStep() {
    if (_isLoadingRates) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              CircularProgressIndicator(color: LynewedColors.primary),
              SizedBox(height: 16),
              Text('Fetching shipping rates...'),
            ],
          ),
        ),
      );
    }

    if (_ratesError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.error_outline,
                  color: LynewedColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                _ratesError!,
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              LynewedButton(
                text: 'Retry',
                type: LynewedButtonType.primary,
                onPressed: _fetchShippingRates,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LynewedSectionTitle('Select Shipping'),
        const SizedBox(height: 10),
        ShippingRateSelector(
          rates: _fedexRates,
          selectedRate: _selectedRate,
          onRateSelected: (rate) {
            setState(() => _selectedRate = rate);
          },
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    final shippingCents = _selectedRate?.rateCents ?? 0;
    final platformFeeCents = _itemPriceCents ~/ 10;
    final totalCents = _itemPriceCents + shippingCents;

    return OrderSummaryWidget(
      itemTitle: widget.listing.title,
      itemPriceCents: _itemPriceCents,
      shippingCostCents: shippingCents,
      platformFeeCents: platformFeeCents,
      totalCents: totalCents,
    );
  }

  Widget _buildConfirmStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isCheckingCgvu)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: LynewedColors.primary),
            ),
          )
        else
          CgvuAcceptanceWidget(
            hasAccepted: _cgvuChecked,
            isChecked: _cgvuChecked,
            onCheckedChanged: (value) {
              setState(() => _cgvuChecked = value);
            },
            alreadyAccepted: _alreadyAcceptedCgvu,
          ),

        if (_paymentError != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LynewedColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: LynewedColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _paymentError!,
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomBar() {
    final isLastStep = _currentStep == _totalSteps - 1;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: LynewedColors.background,
          border: Border(top: BorderSide(color: LynewedColors.gray200)),
        ),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: LynewedButton(
                  text: 'Back',
                  type: LynewedButtonType.secondary,
                  onPressed: _isProcessingPayment ? null : _previousStep,
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: _currentStep > 0 ? 2 : 1,
              child: LynewedButton(
                text: isLastStep ? 'Pay Now' : 'Continue',
                type: LynewedButtonType.primary,
                onPressed: _canProceed && !_isProcessingPayment
                    ? _nextStep
                    : null,
                isLoading: _isProcessingPayment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
