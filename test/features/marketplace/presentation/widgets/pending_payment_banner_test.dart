import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_offer.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/offer_display_model.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_offer_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/pending_payment_banner.dart';

// =============================================================================
// FAKE REPOSITORY
// =============================================================================

class FakeOfferRepository implements MarketplaceOfferRepository {
  List<OfferDisplayModel> pendingPaymentOffers = [];
  Exception? awaitingPaymentException;

  @override
  Future<List<OfferDisplayModel>> getOffersAwaitingMyPayment() async {
    if (awaitingPaymentException != null) throw awaitingPaymentException!;
    return pendingPaymentOffers;
  }

  @override
  Future<MarketplaceOffer> createOffer({
    required String listingId,
    required int amountCents,
    String? message,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> acceptOffer(String offerId) async {}

  @override
  Future<void> rejectOffer(String offerId) async {}

  @override
  Future<void> withdrawOffer(String offerId) async {}

  @override
  Future<List<OfferDisplayModel>> getOffersForListing(String listingId) async =>
      [];

  @override
  Future<MarketplaceOffer?> getPendingOfferForListing(
          String listingId) async =>
      null;

  @override
  Future<List<OfferDisplayModel>> getMyOffers() async => [];

  @override
  Future<MarketplaceOffer> getOfferById(String offerId) async =>
      throw UnimplementedError();

  @override
  Future<bool> hasAcceptedOfferForListing(String listingId) async => false;
}

// =============================================================================
// HELPERS
// =============================================================================

final _now = DateTime(2026, 2, 6, 12, 0);

OfferDisplayModel _makeOffer({
  String id = 'offer-1',
  String listingId = 'listing-1',
  int amountCents = 20000,
  String sellerId = 'seller-1',
}) {
  return OfferDisplayModel(
    offer: MarketplaceOffer(
      id: id,
      listingId: listingId,
      buyerId: 'buyer-1',
      amountCents: amountCents,
      status: 'accepted',
      expiresAt: _now.add(const Duration(hours: 48)),
      createdAt: _now,
    ),
    listingTitle: 'Test Listing',
    listingPriceCents: 35000,
    sellerId: sellerId,
    sellerName: 'Seller Name',
  );
}

// =============================================================================
// TESTS
// =============================================================================

void main() {
  late FakeOfferRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeOfferRepository();
  });

  Widget buildBanner({
    void Function(List<OfferDisplayModel>)? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PendingPaymentBanner(
          repository: fakeRepository,
          onTap: onTap,
        ),
      ),
    );
  }

  testWidgets('should show nothing when no offers await payment',
      (tester) async {
    fakeRepository.pendingPaymentOffers = [];

    await tester.pumpWidget(buildBanner());
    await tester.pumpAndSettle();

    expect(find.byType(PendingPaymentBanner), findsOneWidget);
    // The banner should render SizedBox.shrink (no visible content).
    expect(find.text('awaiting payment', findRichText: true), findsNothing);
    expect(find.byIcon(Icons.payment_rounded), findsNothing);
  });

  testWidgets('should show banner with singular text for 1 offer',
      (tester) async {
    fakeRepository.pendingPaymentOffers = [_makeOffer()];

    await tester.pumpWidget(buildBanner());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.payment_rounded), findsOneWidget);
    expect(
      find.text('You have an accepted offer awaiting payment'),
      findsOneWidget,
    );
  });

  testWidgets('should show banner with plural text for multiple offers',
      (tester) async {
    fakeRepository.pendingPaymentOffers = [
      _makeOffer(id: 'offer-1'),
      _makeOffer(id: 'offer-2'),
    ];

    await tester.pumpWidget(buildBanner());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.payment_rounded), findsOneWidget);
    expect(
      find.text('You have 2 accepted offers awaiting payment'),
      findsOneWidget,
    );
  });

  testWidgets('should call onTap callback with offers when tapped',
      (tester) async {
    final offers = [_makeOffer()];
    fakeRepository.pendingPaymentOffers = offers;
    List<OfferDisplayModel>? tappedOffers;

    await tester.pumpWidget(buildBanner(
      onTap: (o) => tappedOffers = o,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.payment_rounded));
    await tester.pumpAndSettle();

    expect(tappedOffers, isNotNull);
    expect(tappedOffers!.length, 1);
    expect(tappedOffers!.first.offer.id, 'offer-1');
  });

  testWidgets('should show nothing on error', (tester) async {
    fakeRepository.awaitingPaymentException = Exception('Network error');

    await tester.pumpWidget(buildBanner());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.payment_rounded), findsNothing);
  });
}
