/// My Offers Page - Buyer view of all offers made.
///
/// Displays all offers made by the current user across all listings
/// with Withdraw action for pending offers.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/offer_display_model.dart';
import '../../domain/repositories/marketplace_offer_repository.dart';
import '../widgets/offer_card.dart';
import '../widgets/pending_payment_banner.dart';
import 'marketplace_chat_page.dart';

/// Page showing all offers made by the current user.
///
/// States:
/// - Loading: circular progress indicator
/// - Empty: "You haven't made any offers yet" message
/// - Error: error message with retry button
/// - Data: list of offer cards with withdraw action
class MyOffersPage extends StatefulWidget {
  /// Creates a my offers page.
  const MyOffersPage({
    this.repository,
    super.key,
  });

  /// Route name for navigation.
  static const String routeName = 'MyOffers';

  /// Route path for navigation.
  static const String routePath = '/myOffers';

  /// Optional repository override for testing.
  final MarketplaceOfferRepository? repository;

  @override
  State<MyOffersPage> createState() => _MyOffersPageState();
}

class _MyOffersPageState extends State<MyOffersPage> {
  late final MarketplaceOfferRepository _repository;

  bool _isLoading = true;
  String? _errorMessage;
  List<OfferDisplayModel> _offers = [];

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
      final offers = await _repository.getMyOffers();

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

  Future<void> _withdrawOffer(String offerId) async {
    try {
      await _repository.withdrawOffer(offerId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Offer withdrawn',
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
            'Failed to withdraw offer',
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
          'My Offers',
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
            "You haven't made any offers yet",
            style: LynewedTextStyles.titleSmall.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
          SizedBox(height: LynewedSpacing.sm),
          Text(
            'Browse listings to make an offer',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openChat(OfferDisplayModel model) {
    final sellerId = model.sellerId;
    if (sellerId == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MarketplaceChatPage(
          listingId: model.offer.listingId,
          otherUserId: sellerId,
          listingTitle: model.listingTitle,
          otherUserName: model.sellerName,
          otherUserAvatarUrl: model.sellerAvatarUrl,
        ),
      ),
    );
  }

  Widget _buildOffersList() {
    return Column(
      children: [
        PendingPaymentBanner(
          repository: _repository,
          onTap: (offers) {
            if (offers.length == 1) {
              _openChat(offers.first);
            }
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _offers.length,
            itemBuilder: (context, index) {
              final model = _offers[index];
              return OfferCard(
                model: model,
                viewMode: OfferCardViewMode.buyer,
                onWithdraw: model.offer.isPending
                    ? () => _withdrawOffer(model.offer.id)
                    : null,
                onTap: () => _openChat(model),
              );
            },
          ),
        ),
      ],
    );
  }
}
