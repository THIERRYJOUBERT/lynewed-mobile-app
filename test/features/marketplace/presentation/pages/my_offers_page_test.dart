/// Tests for MyOffersPage.
///
/// Verifies loading, empty, error, and data states.
/// Tests withdraw offer action.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_offer.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_offer_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/my_offers_page.dart';

// =============================================================================
// FAKE REPOSITORY
// =============================================================================

class FakeOfferRepository implements MarketplaceOfferRepository {
  List<MarketplaceOffer> myOffers = [];
  Exception? getMyOffersException;
  int withdrawCallCount = 0;
  String? lastWithdrawnId;

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
  Future<void> withdrawOffer(String offerId) async {
    withdrawCallCount++;
    lastWithdrawnId = offerId;
  }

  @override
  Future<List<MarketplaceOffer>> getOffersForListing(
      String listingId) async =>
      [];

  @override
  Future<MarketplaceOffer?> getPendingOfferForListing(
      String listingId) async =>
      null;

  @override
  Future<List<MarketplaceOffer>> getMyOffers() async {
    if (getMyOffersException != null) throw getMyOffersException!;
    return myOffers;
  }
}

// =============================================================================
// TESTS
// =============================================================================

void main() {
  late FakeOfferRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeOfferRepository();
  });

  Widget buildPage() {
    return MaterialApp(
      home: MyOffersPage(
        repository: fakeRepository,
      ),
    );
  }

  group('MyOffersPage', () {
    testWidgets('should show title in app bar', (tester) async {
      fakeRepository.myOffers = [];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('My Offers'), findsOneWidget);
    });

    testWidgets('should show empty state when no offers', (tester) async {
      fakeRepository.myOffers = [];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(
        find.text("You haven't made any offers yet"),
        findsOneWidget,
      );
    });

    testWidgets('should show error state on failure', (tester) async {
      fakeRepository.getMyOffersException = Exception('Network error');

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Failed to load offers'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should retry after error', (tester) async {
      fakeRepository.getMyOffersException = Exception('Network error');

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Fix error and retry.
      fakeRepository.getMyOffersException = null;
      fakeRepository.myOffers = [
        MarketplaceOffer(
          id: 'offer-1',
          listingId: 'listing-1',
          buyerId: 'buyer-1',
          amountCents: 15000,
          status: 'pending',
          expiresAt: DateTime.now().add(const Duration(hours: 48)),
          createdAt: DateTime.now(),
        ),
      ];

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('\$150.00'), findsOneWidget);
    });

    testWidgets('should display offers list', (tester) async {
      fakeRepository.myOffers = [
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
          listingId: 'listing-2',
          buyerId: 'buyer-1',
          amountCents: 30000,
          status: 'accepted',
          expiresAt: DateTime.now().add(const Duration(hours: 48)),
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('\$200.00'), findsOneWidget);
      expect(find.text('\$300.00'), findsOneWidget);
    });

    testWidgets('should withdraw offer when Withdraw tapped',
        (tester) async {
      fakeRepository.myOffers = [
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

      await tester.tap(find.text('Withdraw'));
      await tester.pumpAndSettle();

      expect(fakeRepository.withdrawCallCount, 1);
      expect(fakeRepository.lastWithdrawnId, 'offer-1');
    });
  });
}
