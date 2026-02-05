/// Tests for ReceivedOffersPage.
///
/// Verifies loading, empty, error, and data states.
/// Tests accept and reject offer actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_offer.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_offer_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/received_offers_page.dart';

// =============================================================================
// FAKE REPOSITORY
// =============================================================================

class FakeOfferRepository implements MarketplaceOfferRepository {
  List<MarketplaceOffer> offersForListing = [];
  Exception? getOffersException;
  int acceptCallCount = 0;
  int rejectCallCount = 0;
  String? lastAcceptedId;
  String? lastRejectedId;

  @override
  Future<MarketplaceOffer> createOffer({
    required String listingId,
    required int amountCents,
    String? message,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> acceptOffer(String offerId) async {
    acceptCallCount++;
    lastAcceptedId = offerId;
  }

  @override
  Future<void> rejectOffer(String offerId) async {
    rejectCallCount++;
    lastRejectedId = offerId;
  }

  @override
  Future<void> withdrawOffer(String offerId) async {}

  @override
  Future<List<MarketplaceOffer>> getOffersForListing(
      String listingId) async {
    if (getOffersException != null) throw getOffersException!;
    return offersForListing;
  }

  @override
  Future<MarketplaceOffer?> getPendingOfferForListing(
          String listingId) async =>
      null;

  @override
  Future<List<MarketplaceOffer>> getMyOffers() async => [];
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
        MarketplaceOffer(
          id: 'offer-1',
          listingId: 'listing-1',
          buyerId: 'buyer-1',
          amountCents: 20000,
          status: 'pending',
          expiresAt: DateTime.now().add(const Duration(hours: 48)),
          createdAt: DateTime.now(),
        ),
      ];

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('\$200.00'), findsOneWidget);
    });

    testWidgets('should display offers list', (tester) async {
      fakeRepository.offersForListing = [
        MarketplaceOffer(
          id: 'offer-1',
          listingId: 'listing-1',
          buyerId: 'buyer-1',
          amountCents: 20000,
          status: 'pending',
          expiresAt: DateTime.now().add(const Duration(hours: 48)),
          createdAt: DateTime.now(),
        ),
        MarketplaceOffer(
          id: 'offer-2',
          listingId: 'listing-1',
          buyerId: 'buyer-2',
          amountCents: 25000,
          status: 'pending',
          expiresAt: DateTime.now().add(const Duration(hours: 48)),
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('\$200.00'), findsOneWidget);
      expect(find.text('\$250.00'), findsOneWidget);
    });

    testWidgets('should accept offer when Accept tapped', (tester) async {
      fakeRepository.offersForListing = [
        MarketplaceOffer(
          id: 'offer-1',
          listingId: 'listing-1',
          buyerId: 'buyer-1',
          amountCents: 20000,
          status: 'pending',
          expiresAt: DateTime.now().add(const Duration(hours: 48)),
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      expect(fakeRepository.acceptCallCount, 1);
      expect(fakeRepository.lastAcceptedId, 'offer-1');
    });

    testWidgets('should reject offer when Decline tapped', (tester) async {
      fakeRepository.offersForListing = [
        MarketplaceOffer(
          id: 'offer-1',
          listingId: 'listing-1',
          buyerId: 'buyer-1',
          amountCents: 20000,
          status: 'pending',
          expiresAt: DateTime.now().add(const Duration(hours: 48)),
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Decline'));
      await tester.pumpAndSettle();

      expect(fakeRepository.rejectCallCount, 1);
      expect(fakeRepository.lastRejectedId, 'offer-1');
    });
  });
}
