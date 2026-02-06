/// Tests for ReceivedOffersPage.
///
/// Verifies loading, empty, error, and data states.
/// Tests buyer grouping, View Offer button, and status badges.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_offer.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/offer_display_model.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_offer_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/received_offers_page.dart';

// =============================================================================
// FAKE REPOSITORY
// =============================================================================

class FakeOfferRepository implements MarketplaceOfferRepository {
  List<OfferDisplayModel> offersForListing = [];
  Exception? getOffersException;

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
  Future<List<OfferDisplayModel>> getOffersForListing(
      String listingId) async {
    if (getOffersException != null) throw getOffersException!;
    return offersForListing;
  }

  @override
  Future<MarketplaceOffer?> getPendingOfferForListing(
          String listingId) async =>
      null;

  @override
  Future<List<OfferDisplayModel>> getMyOffers() async => [];

  @override
  Future<List<OfferDisplayModel>> getOffersAwaitingMyPayment() async => [];

  @override
  Future<MarketplaceOffer> getOfferById(String offerId) async =>
      throw UnimplementedError();
}

// =============================================================================
// HELPERS
// =============================================================================

OfferDisplayModel _createOfferModel({
  String id = 'offer-1',
  String listingId = 'listing-1',
  String buyerId = 'buyer-1',
  int amountCents = 20000,
  String status = 'pending',
  String? buyerName,
  DateTime? expiresAt,
}) {
  return OfferDisplayModel(
    offer: MarketplaceOffer(
      id: id,
      listingId: listingId,
      buyerId: buyerId,
      amountCents: amountCents,
      status: status,
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(hours: 48)),
      createdAt: DateTime.now(),
    ),
    buyerName: buyerName,
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

  Widget buildPage({
    String listingId = 'listing-1',
    String listingTitle = 'Beautiful Dress',
  }) {
    return MaterialApp(
      home: ReceivedOffersPage(
        listingId: listingId,
        listingTitle: listingTitle,
        repository: fakeRepository,
      ),
    );
  }

  group('ReceivedOffersPage', () {
    testWidgets('should show title in app bar', (tester) async {
      fakeRepository.offersForListing = [];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Offers Received'), findsOneWidget);
    });

    testWidgets('should show empty state when no offers', (tester) async {
      fakeRepository.offersForListing = [];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('No offers yet'), findsOneWidget);
    });

    testWidgets('should show error state on failure', (tester) async {
      fakeRepository.getOffersException = Exception('Network error');

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Failed to load offers'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should retry after error', (tester) async {
      fakeRepository.getOffersException = Exception('Network error');

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Fix error and retry.
      fakeRepository.getOffersException = null;
      fakeRepository.offersForListing = [
        _createOfferModel(amountCents: 20000),
      ];

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('\$200.00'), findsOneWidget);
    });

    testWidgets('should display buyer tiles', (tester) async {
      fakeRepository.offersForListing = [
        _createOfferModel(
          id: 'offer-1',
          buyerId: 'buyer-1',
          amountCents: 20000,
          buyerName: 'Alice',
        ),
        _createOfferModel(
          id: 'offer-2',
          buyerId: 'buyer-2',
          amountCents: 25000,
          buyerName: 'Bob',
        ),
      ];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('\$200.00'), findsOneWidget);
      expect(find.text('\$250.00'), findsOneWidget);
    });

    testWidgets('should group multiple offers from same buyer',
        (tester) async {
      fakeRepository.offersForListing = [
        _createOfferModel(
          id: 'offer-1',
          buyerId: 'buyer-1',
          amountCents: 32000,
          buyerName: 'Alice',
        ),
        _createOfferModel(
          id: 'offer-2',
          buyerId: 'buyer-1',
          amountCents: 25000,
          buyerName: 'Alice',
          status: 'rejected',
        ),
      ];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Only one tile for Alice (grouped).
      expect(find.text('Alice'), findsOneWidget);
      // Shows most recent offer amount (first in the list).
      expect(find.text('\$320.00'), findsOneWidget);
      // Shows offer count.
      expect(find.text('2 offers'), findsOneWidget);
    });

    testWidgets('should show View Offer for pending offers',
        (tester) async {
      fakeRepository.offersForListing = [
        _createOfferModel(
          id: 'offer-1',
          buyerId: 'buyer-1',
          amountCents: 20000,
          status: 'pending',
        ),
      ];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('View Offer'), findsOneWidget);
    });

    testWidgets('should show status badge for accepted offers',
        (tester) async {
      fakeRepository.offersForListing = [
        _createOfferModel(
          id: 'offer-1',
          buyerId: 'buyer-1',
          amountCents: 20000,
          status: 'accepted',
        ),
      ];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('ACCEPTED'), findsOneWidget);
      expect(find.text('View Offer'), findsNothing);
    });

    testWidgets('should show status badge for rejected offers',
        (tester) async {
      fakeRepository.offersForListing = [
        _createOfferModel(
          id: 'offer-1',
          buyerId: 'buyer-1',
          amountCents: 20000,
          status: 'rejected',
        ),
      ];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('REJECTED'), findsOneWidget);
      expect(find.text('View Offer'), findsNothing);
    });

    testWidgets('should sort pending offers before resolved',
        (tester) async {
      fakeRepository.offersForListing = [
        _createOfferModel(
          id: 'offer-1',
          buyerId: 'buyer-1',
          amountCents: 20000,
          buyerName: 'Alice',
          status: 'accepted',
        ),
        _createOfferModel(
          id: 'offer-2',
          buyerId: 'buyer-2',
          amountCents: 30000,
          buyerName: 'Bob',
          status: 'pending',
        ),
      ];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Both should appear.
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);

      // Bob (pending) should show View Offer.
      expect(find.text('View Offer'), findsOneWidget);
      // Alice (accepted) should show badge.
      expect(find.text('ACCEPTED'), findsOneWidget);
    });

    testWidgets('should not show Accept or Decline buttons',
        (tester) async {
      fakeRepository.offersForListing = [
        _createOfferModel(
          id: 'offer-1',
          buyerId: 'buyer-1',
          amountCents: 20000,
          status: 'pending',
        ),
      ];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Accept/Decline should NOT be on this page (moved to chat).
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Decline'), findsNothing);
    });
  });
}
