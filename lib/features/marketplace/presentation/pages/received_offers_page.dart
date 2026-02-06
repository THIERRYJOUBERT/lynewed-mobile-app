/// Received Offers Page - Seller view of offers on a listing.
///
/// Displays offers received for a specific listing grouped by buyer
/// in a conversation-style list. Pending offers show "View Offer"
/// to navigate to chat; resolved offers show a status badge.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/offer_display_model.dart';
import '../../domain/repositories/marketplace_offer_repository.dart';
import '../widgets/buyer_offer_tile.dart';
import 'marketplace_chat_page.dart';

/// Page showing all offers received for a specific listing.
///
/// Offers are grouped by buyer - each tile shows the buyer's most
/// recent offer with either a "View Offer" button (pending) or
/// a status badge (accepted/rejected/expired/withdrawn).
///
/// States:
/// - Loading: circular progress indicator
/// - Empty: "No offers yet" message
/// - Error: error message with retry button
/// - Data: grouped list of buyer offer tiles
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

  /// Route path for GoRouter registration.
  static const String routePath = '/marketplace/offers/received';

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

  List<_BuyerOfferGroup> _groupOffersByBuyer() {
    final groups = <String, _BuyerOfferGroup>{};

    for (final model in _offers) {
      final buyerId = model.offer.buyerId;
      if (groups.containsKey(buyerId)) {
        groups[buyerId] = groups[buyerId]!.incrementCount();
      } else {
        groups[buyerId] = _BuyerOfferGroup(
          buyerId: buyerId,
          buyerName: model.buyerName,
          buyerAvatarUrl: model.buyerAvatarUrl,
          latestOffer: model,
          totalCount: 1,
        );
      }
    }

    // Sort: pending first, then resolved, each sub-group by most recent.
    final result = groups.values.toList()
      ..sort((a, b) {
        final aPending =
            a.latestOffer.offer.isPending && !a.latestOffer.offer.isExpired;
        final bPending =
            b.latestOffer.offer.isPending && !b.latestOffer.offer.isExpired;
        if (aPending && !bPending) return -1;
        if (!aPending && bPending) return 1;
        return b.latestOffer.offer.createdAt
            .compareTo(a.latestOffer.offer.createdAt);
      });

    return result;
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

  void _openChat(_BuyerOfferGroup group) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => MarketplaceChatPage(
              listingId: widget.listingId,
              otherUserId: group.buyerId,
              listingTitle: widget.listingTitle,
              otherUserName: group.buyerName,
              otherUserAvatarUrl: group.buyerAvatarUrl,
            ),
          ),
        )
        .then((_) {
      if (mounted) _loadOffers();
    });
  }

  Widget _buildOffersList() {
    final groups = _groupOffersByBuyer();

    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return BuyerOfferTile(
          buyerName: group.buyerName,
          buyerAvatarUrl: group.buyerAvatarUrl,
          latestOffer: group.latestOffer.offer,
          totalOfferCount: group.totalCount,
          onTap: () => _openChat(group),
        );
      },
    );
  }
}

/// Groups offers from the same buyer into a single display unit.
class _BuyerOfferGroup {
  const _BuyerOfferGroup({
    required this.buyerId,
    required this.latestOffer,
    required this.totalCount,
    this.buyerName,
    this.buyerAvatarUrl,
  });

  final String buyerId;
  final String? buyerName;
  final String? buyerAvatarUrl;
  final OfferDisplayModel latestOffer;
  final int totalCount;

  _BuyerOfferGroup incrementCount() {
    return _BuyerOfferGroup(
      buyerId: buyerId,
      buyerName: buyerName,
      buyerAvatarUrl: buyerAvatarUrl,
      latestOffer: latestOffer,
      totalCount: totalCount + 1,
    );
  }
}
