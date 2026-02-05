/// Tests for SellerDashboardPage.
///
/// Verifies loading state, listings grouped/filtered by status,
/// earnings stats display, empty state, error state with retry,
/// offer count badges, and navigation to listing/transaction detail.
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/listing_filter.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_listing.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_offer.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_photo.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_transaction.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/seller_profile.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_address.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_rate.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_offer_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_transaction_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/seller_dashboard_page.dart';

// -- Test data helpers --

MarketplaceListing _createListing({
  String id = 'listing-1',
  String title = 'Beautiful Dress',
  String status = 'active',
  int priceCents = 29999,
  String category = 'dress',
  String condition = 'excellent',
}) {
  return MarketplaceListing(
    id: id,
    sellerId: 'seller-1',
    title: title,
    category: category,
    priceCents: priceCents,
    condition: condition,
    country: 'US',
    status: status,
    createdAt: DateTime(2025, 6, 1),
    updatedAt: DateTime(2025, 6, 1),
  );
}

const _testAddress = ShippingAddress(
  streetLines: ['123 Main St'],
  city: 'New York',
  postalCode: '10001',
  countryCode: 'US',
  stateOrProvinceCode: 'NY',
  personName: 'Jane Doe',
);

MarketplaceTransaction _createTransaction({
  String id = 'txn-1',
  String listingId = 'listing-sold-1',
  String status = 'completed',
  int itemPriceCents = 20000,
  int platformFeeCents = 2000,
  int sellerPayoutCents = 18000,
}) {
  return MarketplaceTransaction(
    id: id,
    listingId: listingId,
    sellerId: 'seller-1',
    buyerId: 'buyer-1',
    itemPriceCents: itemPriceCents,
    shippingCostCents: 1250,
    platformFeeCents: platformFeeCents,
    sellerPayoutCents: sellerPayoutCents,
    totalPaidCents: itemPriceCents + 1250,
    status: status,
    shippingFromAddress: _testAddress,
    shippingToAddress: _testAddress,
    createdAt: DateTime(2025, 6, 1),
    updatedAt: DateTime(2025, 6, 1),
  );
}

MarketplaceOffer _createOffer({
  String id = 'offer-1',
  String listingId = 'listing-1',
  String status = 'pending',
}) {
  return MarketplaceOffer(
    id: id,
    listingId: listingId,
    buyerId: 'buyer-1',
    amountCents: 25000,
    status: status,
    expiresAt: DateTime.now().add(const Duration(hours: 48)),
    createdAt: DateTime(2025, 6, 1),
  );
}

// -- Fake repositories --

class _FakeMarketplaceRepository implements MarketplaceRepository {
  List<MarketplaceListing> listings = [];
  bool shouldThrow = false;
  String errorMessage = 'Error loading listings';

  @override
  Future<List<MarketplaceListing>> getMyListings() async {
    if (shouldThrow) throw Exception(errorMessage);
    return listings;
  }

  @override
  Future<MarketplaceListing?> getListingById(String id) async => null;

  @override
  Future<List<String>> getPhotoUrls(String listingId) async => [];

  @override
  Future<MarketplaceListing> createListing(MarketplaceListing listing) async {
    throw UnimplementedError();
  }

  @override
  Future<MarketplaceListing> updateListing(
    String id,
    Map<String, dynamic> updates,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> uploadListingPhotos({
    required String listingId,
    required List<Uint8List> photoBytes,
    required List<String> fileNames,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> saveListingPhotos({
    required String listingId,
    required List<MarketplacePhoto> photos,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<MarketplacePhoto>> getListingPhotos(String listingId) async => [];

  @override
  Future<List<MarketplaceListing>> getListings({
    String? category,
    int page = 0,
    int pageSize = 20,
  }) async => [];

  @override
  Future<int> getListingsCount({String? category}) async => 0;

  @override
  Future<SellerProfile?> getSellerInfo(String sellerId) async => null;

  @override
  Future<List<MarketplaceListing>> getFilteredListings({
    required ListingFilter filter,
    int page = 0,
    int pageSize = 20,
  }) async => [];

  @override
  Future<int> getFilteredListingsCount(ListingFilter filter) async => 0;
}

class _FakeTransactionRepository implements MarketplaceTransactionRepository {
  List<MarketplaceTransaction> sales = [];
  bool shouldThrow = false;

  @override
  Future<List<MarketplaceTransaction>> getMySales() async {
    if (shouldThrow) throw Exception('Error loading sales');
    return sales;
  }

  @override
  Future<MarketplaceTransaction?> getTransaction(String transactionId) async =>
      null;

  @override
  Future<List<MarketplaceTransaction>> getMyPurchases() async => [];

  @override
  Future<Map<String, dynamic>> createCheckoutSession({
    required String listingId,
    String? offerId,
    required ShippingAddress shippingToAddress,
    required ShippingRate shippingOption,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasAcceptedBuyerCgvu() async => true;

  @override
  Future<void> acceptBuyerCgvu() async {}
}

class _FakeOfferRepository implements MarketplaceOfferRepository {
  Map<String, List<MarketplaceOffer>> offersPerListing = {};
  bool shouldThrow = false;

  @override
  Future<List<MarketplaceOffer>> getOffersForListing(String listingId) async {
    if (shouldThrow) throw Exception('Error loading offers');
    return offersPerListing[listingId] ?? [];
  }

  @override
  Future<MarketplaceOffer> createOffer({
    required String listingId,
    required int amountCents,
    String? message,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> acceptOffer(String offerId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> rejectOffer(String offerId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> withdrawOffer(String offerId) async {
    throw UnimplementedError();
  }

  @override
  Future<MarketplaceOffer?> getPendingOfferForListing(
    String listingId,
  ) async => null;

  @override
  Future<List<MarketplaceOffer>> getMyOffers() async => [];
}

// -- Test helpers --

Widget _buildPage({
  _FakeMarketplaceRepository? repository,
  _FakeTransactionRepository? transactionRepository,
  _FakeOfferRepository? offerRepository,
}) {
  return MaterialApp(
    home: SellerDashboardPage(
      repository: repository ?? _FakeMarketplaceRepository(),
      transactionRepository:
          transactionRepository ?? _FakeTransactionRepository(),
      offerRepository: offerRepository ?? _FakeOfferRepository(),
    ),
  );
}

void main() {
  group('SellerDashboardPage', () {
    // ========================================
    // Loading state
    // ========================================
    group('loading state', () {
      testWidgets('should show loading indicator initially', (tester) async {
        await tester.pumpWidget(_buildPage());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    // ========================================
    // AC-1: Listings grouped/filtered by status
    // ========================================
    group('AC-1: listings display grouped by status', () {
      testWidgets('should display all listings when loaded', (tester) async {
        final repo = _FakeMarketplaceRepository()
          ..listings = [
            _createListing(
                id: 'l1', title: 'Active Dress', status: 'active'),
            _createListing(id: 'l2', title: 'Sold Dress', status: 'sold'),
            _createListing(id: 'l3', title: 'Draft Dress', status: 'draft'),
          ];

        await tester.pumpWidget(_buildPage(repository: repo));
        await tester.pumpAndSettle();

        expect(find.text('Active Dress'), findsOneWidget);
        expect(find.text('Sold Dress'), findsOneWidget);
        expect(find.text('Draft Dress'), findsOneWidget);
      });

      testWidgets('should show status filter chips', (tester) async {
        final repo = _FakeMarketplaceRepository()
          ..listings = [
            _createListing(id: 'l1', status: 'active'),
          ];

        await tester.pumpWidget(_buildPage(repository: repo));
        await tester.pumpAndSettle();

        expect(find.text('All'), findsOneWidget);
        expect(find.text('Active'), findsOneWidget);
        expect(find.text('Sold'), findsOneWidget);
        expect(find.text('Reserved'), findsOneWidget);
        expect(find.text('Draft'), findsOneWidget);
      });

      testWidgets('should filter listings when Active chip is tapped',
          (tester) async {
        final repo = _FakeMarketplaceRepository()
          ..listings = [
            _createListing(
                id: 'l1', title: 'Active Dress', status: 'active'),
            _createListing(id: 'l2', title: 'Sold Dress', status: 'sold'),
            _createListing(id: 'l3', title: 'Draft Dress', status: 'draft'),
          ];

        await tester.pumpWidget(_buildPage(repository: repo));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Active'));
        await tester.pumpAndSettle();

        expect(find.text('Active Dress'), findsOneWidget);
        expect(find.text('Sold Dress'), findsNothing);
        expect(find.text('Draft Dress'), findsNothing);
      });

      testWidgets('should filter listings when Sold chip is tapped',
          (tester) async {
        final repo = _FakeMarketplaceRepository()
          ..listings = [
            _createListing(
                id: 'l1', title: 'Active Dress', status: 'active'),
            _createListing(id: 'l2', title: 'Sold Dress', status: 'sold'),
          ];

        await tester.pumpWidget(_buildPage(repository: repo));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sold'));
        await tester.pumpAndSettle();

        expect(find.text('Active Dress'), findsNothing);
        expect(find.text('Sold Dress'), findsOneWidget);
      });

      testWidgets('should filter listings when Draft chip is tapped',
          (tester) async {
        final repo = _FakeMarketplaceRepository()
          ..listings = [
            _createListing(
                id: 'l1', title: 'Active Dress', status: 'active'),
            _createListing(id: 'l2', title: 'Draft Dress', status: 'draft'),
          ];

        await tester.pumpWidget(_buildPage(repository: repo));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Draft'));
        await tester.pumpAndSettle();

        expect(find.text('Active Dress'), findsNothing);
        expect(find.text('Draft Dress'), findsOneWidget);
      });

      testWidgets('should show all listings when All chip is tapped back',
          (tester) async {
        final repo = _FakeMarketplaceRepository()
          ..listings = [
            _createListing(
                id: 'l1', title: 'Active Dress', status: 'active'),
            _createListing(id: 'l2', title: 'Sold Dress', status: 'sold'),
          ];

        await tester.pumpWidget(_buildPage(repository: repo));
        await tester.pumpAndSettle();

        // Filter by Active first.
        await tester.tap(find.text('Active'));
        await tester.pumpAndSettle();
        expect(find.text('Sold Dress'), findsNothing);

        // Go back to All.
        await tester.tap(find.text('All'));
        await tester.pumpAndSettle();
        expect(find.text('Active Dress'), findsOneWidget);
        expect(find.text('Sold Dress'), findsOneWidget);
      });
    });

    // ========================================
    // AC-2: Earnings stats display
    // ========================================
    group('AC-2: earnings stats display', () {
      testWidgets(
          'should display total sales, commission, and net payout',
          (tester) async {
        final repo = _FakeMarketplaceRepository()
          ..listings = [
            _createListing(id: 'l1', status: 'sold'),
          ];
        final txRepo = _FakeTransactionRepository()
          ..sales = [
            _createTransaction(
              id: 'txn-1',
              status: 'completed',
              itemPriceCents: 20000,
              platformFeeCents: 2000,
              sellerPayoutCents: 18000,
            ),
            _createTransaction(
              id: 'txn-2',
              status: 'completed',
              itemPriceCents: 30000,
              platformFeeCents: 3000,
              sellerPayoutCents: 27000,
            ),
          ];

        await tester.pumpWidget(_buildPage(
          repository: repo,
          transactionRepository: txRepo,
        ));
        await tester.pumpAndSettle();

        // Total sales = $200.00 + $300.00 = $500.00
        expect(find.text('\$500.00'), findsOneWidget);
        // Commission = $20.00 + $30.00 = $50.00
        expect(find.text('\$50.00'), findsOneWidget);
        // Net payout = $180.00 + $270.00 = $450.00
        expect(find.text('\$450.00'), findsOneWidget);
      });

      testWidgets(
          'should display zero earnings when no completed sales exist',
          (tester) async {
        final repo = _FakeMarketplaceRepository()..listings = [];
        final txRepo = _FakeTransactionRepository()..sales = [];

        await tester.pumpWidget(_buildPage(
          repository: repo,
          transactionRepository: txRepo,
        ));
        await tester.pumpAndSettle();

        // All zeros.
        expect(find.text('\$0.00'), findsNWidgets(3));
      });

      testWidgets(
          'should only count completed transactions for earnings',
          (tester) async {
        final repo = _FakeMarketplaceRepository()..listings = [];
        final txRepo = _FakeTransactionRepository()
          ..sales = [
            _createTransaction(
              id: 'txn-1',
              status: 'completed',
              itemPriceCents: 20000,
              platformFeeCents: 2000,
              sellerPayoutCents: 18000,
            ),
            _createTransaction(
              id: 'txn-2',
              status: 'paid', // Not completed - should not count.
              itemPriceCents: 50000,
              platformFeeCents: 5000,
              sellerPayoutCents: 45000,
            ),
          ];

        await tester.pumpWidget(_buildPage(
          repository: repo,
          transactionRepository: txRepo,
        ));
        await tester.pumpAndSettle();

        // Only the completed one: $200.00
        expect(find.text('\$200.00'), findsOneWidget);
      });

      testWidgets('should show earnings section labels', (tester) async {
        final repo = _FakeMarketplaceRepository()..listings = [];
        final txRepo = _FakeTransactionRepository()..sales = [];

        await tester.pumpWidget(_buildPage(
          repository: repo,
          transactionRepository: txRepo,
        ));
        await tester.pumpAndSettle();

        expect(find.text('Total Sales'), findsOneWidget);
        expect(find.text('Commission'), findsOneWidget);
        expect(find.text('Net Payout'), findsOneWidget);
      });
    });

    // ========================================
    // AC-3: Tap on listing for edit/view
    // ========================================
    group('AC-3: listing tap navigation', () {
      testWidgets(
          'should navigate to ListingDetailPage when tapping active listing',
          (tester) async {
        final repo = _FakeMarketplaceRepository()
          ..listings = [
            _createListing(
                id: 'l1', title: 'Active Dress', status: 'active'),
          ];

        String? navigatedListingId;
        await tester.pumpWidget(
          MaterialApp(
            home: SellerDashboardPage(
              repository: repo,
              transactionRepository: _FakeTransactionRepository(),
              offerRepository: _FakeOfferRepository(),
              onListingTap: (id) => navigatedListingId = id,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Active Dress'));
        await tester.pumpAndSettle();

        expect(navigatedListingId, equals('l1'));
      });

      testWidgets(
          'should navigate to ListingDetailPage when tapping draft listing',
          (tester) async {
        final repo = _FakeMarketplaceRepository()
          ..listings = [
            _createListing(
                id: 'l1', title: 'Draft Dress', status: 'draft'),
          ];

        String? navigatedListingId;
        await tester.pumpWidget(
          MaterialApp(
            home: SellerDashboardPage(
              repository: repo,
              transactionRepository: _FakeTransactionRepository(),
              offerRepository: _FakeOfferRepository(),
              onListingTap: (id) => navigatedListingId = id,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Draft Dress'));
        await tester.pumpAndSettle();

        expect(navigatedListingId, equals('l1'));
      });

      testWidgets(
          'should navigate to TransactionDetailPage when tapping reserved listing',
          (tester) async {
        final repo = _FakeMarketplaceRepository()
          ..listings = [
            _createListing(
                id: 'listing-reserved',
                title: 'Reserved Dress',
                status: 'reserved'),
          ];
        final txRepo = _FakeTransactionRepository()
          ..sales = [
            _createTransaction(
              id: 'txn-for-reserved',
              listingId: 'listing-reserved',
              status: 'paid',
            ),
          ];

        String? navigatedTransactionId;
        await tester.pumpWidget(
          MaterialApp(
            home: SellerDashboardPage(
              repository: repo,
              transactionRepository: txRepo,
              offerRepository: _FakeOfferRepository(),
              onTransactionTap: (id) => navigatedTransactionId = id,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reserved Dress'));
        await tester.pumpAndSettle();

        expect(navigatedTransactionId, equals('txn-for-reserved'));
      });
    });

    // ========================================
    // AC-4: Offer count badge
    // ========================================
    group('AC-4: offer count badge', () {
      testWidgets('should show offer count badge when pending offers exist',
          (tester) async {
        final repo = _FakeMarketplaceRepository()
          ..listings = [
            _createListing(id: 'l1', title: 'Active Dress', status: 'active'),
          ];
        final offerRepo = _FakeOfferRepository()
          ..offersPerListing = {
            'l1': [
              _createOffer(id: 'o1', listingId: 'l1', status: 'pending'),
              _createOffer(id: 'o2', listingId: 'l1', status: 'pending'),
            ],
          };

        await tester.pumpWidget(_buildPage(
          repository: repo,
          offerRepository: offerRepo,
        ));
        await tester.pumpAndSettle();

        // Should show badge with count 2.
        expect(find.text('2'), findsOneWidget);
      });

      testWidgets('should not show offer badge when no pending offers',
          (tester) async {
        final repo = _FakeMarketplaceRepository()
          ..listings = [
            _createListing(id: 'l1', title: 'Active Dress', status: 'active'),
          ];
        final offerRepo = _FakeOfferRepository()
          ..offersPerListing = {
            'l1': [
              _createOffer(id: 'o1', listingId: 'l1', status: 'rejected'),
            ],
          };

        await tester.pumpWidget(_buildPage(
          repository: repo,
          offerRepository: offerRepo,
        ));
        await tester.pumpAndSettle();

        // The badge key pattern: we check no offer badge is shown.
        // Only rejected offers - should NOT show a badge.
        expect(find.byKey(const Key('offer-badge-l1')), findsNothing);
      });
    });

    // ========================================
    // AC-5: Generate Label action for reserved
    // ========================================
    group('AC-5: generate label action for reserved transactions', () {
      testWidgets(
          'should show Generate Label badge on reserved listing with paid transaction',
          (tester) async {
        final repo = _FakeMarketplaceRepository()
          ..listings = [
            _createListing(
                id: 'listing-reserved',
                title: 'Reserved Dress',
                status: 'reserved'),
          ];
        final txRepo = _FakeTransactionRepository()
          ..sales = [
            _createTransaction(
              id: 'txn-1',
              listingId: 'listing-reserved',
              status: 'paid',
            ),
          ];

        await tester.pumpWidget(_buildPage(
          repository: repo,
          transactionRepository: txRepo,
        ));
        await tester.pumpAndSettle();

        expect(find.text('Generate Label'), findsOneWidget);
      });
    });

    // ========================================
    // Empty state
    // ========================================
    group('empty state', () {
      testWidgets('should show empty state when no listings', (tester) async {
        final repo = _FakeMarketplaceRepository()..listings = [];

        await tester.pumpWidget(_buildPage(repository: repo));
        await tester.pumpAndSettle();

        expect(find.text('No listings yet'), findsOneWidget);
      });

      testWidgets('should show filtered empty state when filter has no results',
          (tester) async {
        final repo = _FakeMarketplaceRepository()
          ..listings = [
            _createListing(id: 'l1', status: 'active'),
          ];

        await tester.pumpWidget(_buildPage(repository: repo));
        await tester.pumpAndSettle();

        // Filter by Sold - should show no results.
        await tester.tap(find.text('Sold'));
        await tester.pumpAndSettle();

        expect(find.text('No sold listings'), findsOneWidget);
      });
    });

    // ========================================
    // Error state
    // ========================================
    group('error state', () {
      testWidgets('should show error state when loading fails',
          (tester) async {
        final repo = _FakeMarketplaceRepository()..shouldThrow = true;

        await tester.pumpWidget(_buildPage(repository: repo));
        await tester.pumpAndSettle();

        expect(find.text('Failed to load listings'), findsOneWidget);
      });

      testWidgets('should show retry button on error', (tester) async {
        final repo = _FakeMarketplaceRepository()..shouldThrow = true;

        await tester.pumpWidget(_buildPage(repository: repo));
        await tester.pumpAndSettle();

        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('should reload when retry is tapped', (tester) async {
        final repo = _FakeMarketplaceRepository()..shouldThrow = true;

        await tester.pumpWidget(_buildPage(repository: repo));
        await tester.pumpAndSettle();

        // Fix the repo.
        repo.shouldThrow = false;
        repo.listings = [
          _createListing(id: 'l1', title: 'Active Dress', status: 'active'),
        ];

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(find.text('Active Dress'), findsOneWidget);
      });
    });

    // ========================================
    // Header / Create listing action
    // ========================================
    group('header and actions', () {
      testWidgets('should show My Sales header', (tester) async {
        await tester.pumpWidget(_buildPage());
        await tester.pumpAndSettle();

        expect(find.text('My Sales'), findsOneWidget);
      });

      testWidgets('should show create listing button', (tester) async {
        final repo = _FakeMarketplaceRepository()..listings = [];

        await tester.pumpWidget(_buildPage(repository: repo));
        await tester.pumpAndSettle();

        // FAB or header button to create new listing.
        expect(find.byIcon(Icons.add), findsOneWidget);
      });
    });

    // ========================================
    // Listing card details
    // ========================================
    group('listing card details', () {
      testWidgets('should show listing price', (tester) async {
        final repo = _FakeMarketplaceRepository()
          ..listings = [
            _createListing(
                id: 'l1',
                title: 'Dress One',
                priceCents: 15000,
                status: 'active'),
          ];

        await tester.pumpWidget(_buildPage(repository: repo));
        await tester.pumpAndSettle();

        expect(find.text('\$150.00'), findsOneWidget);
      });

      testWidgets('should show listing status badge', (tester) async {
        final repo = _FakeMarketplaceRepository()
          ..listings = [
            _createListing(id: 'l1', status: 'active'),
          ];

        await tester.pumpWidget(_buildPage(repository: repo));
        await tester.pumpAndSettle();

        // The status badge text for active.
        expect(find.text('ACTIVE'), findsOneWidget);
      });
    });
  });
}
