/// Tests for MarketplaceOfferRepository using a Fake implementation.
///
/// Verifies create, accept, reject, withdraw, and query operations
/// using an in-memory fake repository.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_offer.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_offer_repository.dart';

// =============================================================================
// FAKE REPOSITORY
// =============================================================================

/// In-memory fake implementation of [MarketplaceOfferRepository].
///
/// Simulates the behavior of SupabaseMarketplaceOfferRepository
/// without requiring a real database connection.
class FakeMarketplaceOfferRepository implements MarketplaceOfferRepository {
  FakeMarketplaceOfferRepository({this.currentUserId = 'buyer-1'});

  final String currentUserId;
  final List<MarketplaceOffer> _offers = [];
  int _nextId = 1;

  /// Exception to throw on next operation (for error testing).
  Exception? nextException;

  /// Get the stored offers (for test assertions).
  List<MarketplaceOffer> get offers => List.unmodifiable(_offers);

  @override
  Future<MarketplaceOffer> createOffer({
    required String listingId,
    required int amountCents,
    String? message,
  }) async {
    if (nextException != null) {
      final e = nextException!;
      nextException = null;
      throw e;
    }

    // Check for existing pending offer.
    final existing = _offers.where(
      (o) =>
          o.listingId == listingId &&
          o.buyerId == currentUserId &&
          o.status == 'pending',
    );
    if (existing.isNotEmpty) {
      throw StateError('You already have a pending offer on this listing');
    }

    if (amountCents <= 0) {
      throw ArgumentError('Offer amount must be greater than 0');
    }

    final offer = MarketplaceOffer(
      id: 'offer-${_nextId++}',
      listingId: listingId,
      buyerId: currentUserId,
      amountCents: amountCents,
      message: message,
      status: 'pending',
      expiresAt: DateTime.now().add(const Duration(hours: 48)),
      createdAt: DateTime.now(),
    );

    _offers.add(offer);
    return offer;
  }

  @override
  Future<void> acceptOffer(String offerId) async {
    if (nextException != null) {
      final e = nextException!;
      nextException = null;
      throw e;
    }

    final index = _offers.indexWhere((o) => o.id == offerId);
    if (index == -1) throw StateError('Offer not found');

    final offer = _offers[index];
    if (offer.status != 'pending') {
      throw StateError('Offer is not pending');
    }

    // Accept this offer.
    _offers[index] = offer.copyWith(
      status: 'accepted',
      respondedAt: DateTime.now(),
    );

    // Reject all other pending offers on the same listing.
    for (var i = 0; i < _offers.length; i++) {
      if (_offers[i].listingId == offer.listingId &&
          _offers[i].id != offerId &&
          _offers[i].status == 'pending') {
        _offers[i] = _offers[i].copyWith(
          status: 'rejected',
          respondedAt: DateTime.now(),
        );
      }
    }
  }

  @override
  Future<void> rejectOffer(String offerId) async {
    if (nextException != null) {
      final e = nextException!;
      nextException = null;
      throw e;
    }

    final index = _offers.indexWhere((o) => o.id == offerId);
    if (index == -1) throw StateError('Offer not found');

    final offer = _offers[index];
    if (offer.status != 'pending') {
      throw StateError('Offer is not pending');
    }

    _offers[index] = offer.copyWith(
      status: 'rejected',
      respondedAt: DateTime.now(),
    );
  }

  @override
  Future<void> withdrawOffer(String offerId) async {
    if (nextException != null) {
      final e = nextException!;
      nextException = null;
      throw e;
    }

    final index = _offers.indexWhere((o) => o.id == offerId);
    if (index == -1) throw StateError('Offer not found');

    final offer = _offers[index];
    if (offer.buyerId != currentUserId) {
      throw StateError('You can only withdraw your own offers');
    }
    if (offer.status != 'pending') {
      throw StateError('Offer is not pending');
    }

    _offers[index] = offer.copyWith(
      status: 'withdrawn',
      respondedAt: DateTime.now(),
    );
  }

  @override
  Future<List<MarketplaceOffer>> getOffersForListing(
      String listingId) async {
    if (nextException != null) {
      final e = nextException!;
      nextException = null;
      throw e;
    }

    return _offers
        .where((o) => o.listingId == listingId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<MarketplaceOffer?> getPendingOfferForListing(
      String listingId) async {
    if (nextException != null) {
      final e = nextException!;
      nextException = null;
      throw e;
    }

    try {
      return _offers.firstWhere(
        (o) =>
            o.listingId == listingId &&
            o.buyerId == currentUserId &&
            o.status == 'pending',
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<MarketplaceOffer>> getMyOffers() async {
    if (nextException != null) {
      final e = nextException!;
      nextException = null;
      throw e;
    }

    return _offers
        .where((o) => o.buyerId == currentUserId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}

// =============================================================================
// TESTS
// =============================================================================

void main() {
  late FakeMarketplaceOfferRepository repository;

  setUp(() {
    repository = FakeMarketplaceOfferRepository();
  });

  group('MarketplaceOfferRepository', () {
    // ===================================================================
    // CREATE OFFER
    // ===================================================================

    group('createOffer', () {
      test('should create an offer successfully', () async {
        final offer = await repository.createOffer(
          listingId: 'listing-1',
          amountCents: 20000,
          message: 'Great dress!',
        );

        expect(offer.listingId, 'listing-1');
        expect(offer.buyerId, 'buyer-1');
        expect(offer.amountCents, 20000);
        expect(offer.message, 'Great dress!');
        expect(offer.status, 'pending');
        expect(offer.isPending, isTrue);
      });

      test('should create an offer without message', () async {
        final offer = await repository.createOffer(
          listingId: 'listing-1',
          amountCents: 15000,
        );

        expect(offer.message, isNull);
        expect(offer.amountCents, 15000);
      });

      test('should throw when duplicate pending offer exists', () async {
        await repository.createOffer(
          listingId: 'listing-1',
          amountCents: 20000,
        );

        expect(
          () => repository.createOffer(
            listingId: 'listing-1',
            amountCents: 25000,
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('should allow new offer after previous was withdrawn', () async {
        final firstOffer = await repository.createOffer(
          listingId: 'listing-1',
          amountCents: 20000,
        );

        await repository.withdrawOffer(firstOffer.id);

        // Should not throw.
        final secondOffer = await repository.createOffer(
          listingId: 'listing-1',
          amountCents: 25000,
        );

        expect(secondOffer.amountCents, 25000);
        expect(secondOffer.status, 'pending');
      });

      test('should throw for zero amount', () async {
        expect(
          () => repository.createOffer(
            listingId: 'listing-1',
            amountCents: 0,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    // ===================================================================
    // ACCEPT OFFER
    // ===================================================================

    group('acceptOffer', () {
      test('should accept a pending offer', () async {
        final offer = await repository.createOffer(
          listingId: 'listing-1',
          amountCents: 20000,
        );

        await repository.acceptOffer(offer.id);

        final offers = await repository.getOffersForListing('listing-1');
        expect(offers.first.status, 'accepted');
        expect(offers.first.respondedAt, isNotNull);
      });

      test('should reject other pending offers when accepting', () async {
        // Create offers from different buyers.
        final repo1 = FakeMarketplaceOfferRepository(currentUserId: 'buyer-1');
        final offer1 = await repo1.createOffer(
          listingId: 'listing-1',
          amountCents: 20000,
        );

        // Simulate another buyer by directly inserting.
        repo1._offers.add(
          MarketplaceOffer(
            id: 'offer-other',
            listingId: 'listing-1',
            buyerId: 'buyer-2',
            amountCents: 25000,
            status: 'pending',
            expiresAt: DateTime.now().add(const Duration(hours: 48)),
            createdAt: DateTime.now(),
          ),
        );

        await repo1.acceptOffer(offer1.id);

        final offers = await repo1.getOffersForListing('listing-1');
        final accepted = offers.where((o) => o.status == 'accepted');
        final rejected = offers.where((o) => o.status == 'rejected');

        expect(accepted.length, 1);
        expect(accepted.first.id, offer1.id);
        expect(rejected.length, 1);
        expect(rejected.first.id, 'offer-other');
      });

      test('should throw for non-existent offer', () async {
        expect(
          () => repository.acceptOffer('non-existent'),
          throwsA(isA<StateError>()),
        );
      });
    });

    // ===================================================================
    // REJECT OFFER
    // ===================================================================

    group('rejectOffer', () {
      test('should reject a pending offer', () async {
        final offer = await repository.createOffer(
          listingId: 'listing-1',
          amountCents: 20000,
        );

        await repository.rejectOffer(offer.id);

        final offers = await repository.getOffersForListing('listing-1');
        expect(offers.first.status, 'rejected');
        expect(offers.first.respondedAt, isNotNull);
      });

      test('should throw for already rejected offer', () async {
        final offer = await repository.createOffer(
          listingId: 'listing-1',
          amountCents: 20000,
        );

        await repository.rejectOffer(offer.id);

        expect(
          () => repository.rejectOffer(offer.id),
          throwsA(isA<StateError>()),
        );
      });
    });

    // ===================================================================
    // WITHDRAW OFFER
    // ===================================================================

    group('withdrawOffer', () {
      test('should withdraw a pending offer', () async {
        final offer = await repository.createOffer(
          listingId: 'listing-1',
          amountCents: 20000,
        );

        await repository.withdrawOffer(offer.id);

        final offers = await repository.getOffersForListing('listing-1');
        expect(offers.first.status, 'withdrawn');
      });

      test('should throw when withdrawing non-owned offer', () async {
        final repo1 = FakeMarketplaceOfferRepository(currentUserId: 'buyer-1');
        repo1._offers.add(
          MarketplaceOffer(
            id: 'other-offer',
            listingId: 'listing-1',
            buyerId: 'buyer-2',
            amountCents: 20000,
            status: 'pending',
            expiresAt: DateTime.now().add(const Duration(hours: 48)),
            createdAt: DateTime.now(),
          ),
        );

        expect(
          () => repo1.withdrawOffer('other-offer'),
          throwsA(isA<StateError>()),
        );
      });

      test('should throw when withdrawing non-pending offer', () async {
        final offer = await repository.createOffer(
          listingId: 'listing-1',
          amountCents: 20000,
        );

        await repository.withdrawOffer(offer.id);

        expect(
          () => repository.withdrawOffer(offer.id),
          throwsA(isA<StateError>()),
        );
      });
    });

    // ===================================================================
    // GET OFFERS
    // ===================================================================

    group('getOffersForListing', () {
      test('should return offers for a listing', () async {
        await repository.createOffer(
          listingId: 'listing-1',
          amountCents: 20000,
        );

        final offers = await repository.getOffersForListing('listing-1');
        expect(offers.length, 1);
        expect(offers.first.listingId, 'listing-1');
      });

      test('should return empty list for listing with no offers', () async {
        final offers =
            await repository.getOffersForListing('non-existent');
        expect(offers, isEmpty);
      });
    });

    group('getPendingOfferForListing', () {
      test('should return pending offer when exists', () async {
        await repository.createOffer(
          listingId: 'listing-1',
          amountCents: 20000,
        );

        final pending =
            await repository.getPendingOfferForListing('listing-1');
        expect(pending, isNotNull);
        expect(pending!.listingId, 'listing-1');
        expect(pending.status, 'pending');
      });

      test('should return null when no pending offer exists', () async {
        final pending =
            await repository.getPendingOfferForListing('listing-1');
        expect(pending, isNull);
      });

      test('should return null after offer is withdrawn', () async {
        final offer = await repository.createOffer(
          listingId: 'listing-1',
          amountCents: 20000,
        );

        await repository.withdrawOffer(offer.id);

        final pending =
            await repository.getPendingOfferForListing('listing-1');
        expect(pending, isNull);
      });
    });

    group('getMyOffers', () {
      test('should return all offers by current user', () async {
        await repository.createOffer(
          listingId: 'listing-1',
          amountCents: 20000,
        );
        await repository.createOffer(
          listingId: 'listing-2',
          amountCents: 30000,
        );

        final myOffers = await repository.getMyOffers();
        expect(myOffers.length, 2);
      });

      test('should return empty list when user has no offers', () async {
        final myOffers = await repository.getMyOffers();
        expect(myOffers, isEmpty);
      });
    });
  });
}
