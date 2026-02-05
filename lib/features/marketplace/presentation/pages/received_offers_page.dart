/// Received Offers Page - Seller view of offers on a listing.
///
/// Displays all offers received for a specific listing with
/// Accept/Decline actions for pending offers.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/marketplace_offer.dart';
import '../../domain/entities/offer_display_model.dart';
import '../../domain/repositories/marketplace_offer_repository.dart';
import '../widgets/offer_card.dart';

/// Page showing all offers received for a specific listing.
///
/// States:
/// - Loading: circular progress indicator
/// - Empty: "No offers yet" message
/// - Error: error message with retry button
/// - Data: list of offer cards with accept/decline actions
class ReceivedOffersPage extends StatefulWidget {
  /// Creates a received offers page.
  const ReceivedOffersPage({
    required this.listingId,
    this.listingTitle,
    this.repository,
    super.key,
  });

  /// Route name for navigation.
  static const String routeName = 'ReceivedOffers';

  /// The listing ID to show offers for.
  final String listingId;

  /// Optional listing title for display.
  final String? listingTitle;

  /// Optional repository override for testing.
  final MarketplaceOfferRepository? repository;

  @override
  State<ReceivedOffersPage> createState() => _ReceivedOffersPageState();
}

class _ReceivedOffersPageState extends State<ReceivedOffersPage> {
  late final MarketplaceOfferRepository _repository;

  bool _isLoading = true;
  String? _errorMessage;
  List<MarketplaceOffer> _offers = [];

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ?? sl<MarketplaceOfferRepository>();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final offers =
          await _repository.getOffersForListing(widget.listingId);

      if (!mounted) return;
      setState(() {
        _offers = offers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load offers';
      });
    }
  }

  Future<void> _acceptOffer(String offerId) async {
    try {
      await _repository.acceptOffer(offerId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Offer accepted!',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textOnDark,
            ),
          ),
        ),
      );
      await _loadOffers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to accept offer',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textOnDark,
            ),
          ),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
  }

  Future<void> _rejectOffer(String offerId) async {
    try {
      await _repository.rejectOffer(offerId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Offer declined',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textOnDark,
            ),
          ),
        ),
      );
      await _loadOffers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to decline offer',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textOnDark,
            ),
          ),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      appBar: AppBar(
        backgroundColor: LynewedColors.background,
        elevation: 0,
        leading: LynewedIconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: LynewedColors.textPrimary,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
          buttonSize: 40,
        ),
        title: Text(
          'Offers Received',
          style: LynewedTextStyles.headlineSmall,
        ),
        centerTitle: false,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: LynewedColors.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_offers.isEmpty) {
      return _buildEmptyState();
    }

    return _buildOffersList();
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
              _errorMessage ?? 'Failed to load offers',
              style: LynewedTextStyles.titleSmall.copyWith(
                color: LynewedColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: LynewedSpacing.lg),
            LynewedButton(
              text: 'Retry',
              type: LynewedButtonType.secondary,
              onPressed: _loadOffers,
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
          Icon(
            Icons.local_offer_outlined,
            size: 64,
            color: LynewedColors.gray300,
          ),
          SizedBox(height: LynewedSpacing.lg),
          Text(
            'No offers yet',
            style: LynewedTextStyles.titleSmall.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
          SizedBox(height: LynewedSpacing.sm),
          Text(
            'Offers from buyers will appear here',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOffersList() {
    return ListView.builder(
      itemCount: _offers.length,
      itemBuilder: (context, index) {
        final offer = _offers[index];
        return OfferCard(
          model: OfferDisplayModel(
            offer: offer,
          ),
          viewMode: OfferCardViewMode.seller,
          onAccept: offer.isPending
              ? () => _acceptOffer(offer.id)
              : null,
          onReject: offer.isPending
              ? () => _rejectOffer(offer.id)
              : null,
        );
      },
    );
  }
}
