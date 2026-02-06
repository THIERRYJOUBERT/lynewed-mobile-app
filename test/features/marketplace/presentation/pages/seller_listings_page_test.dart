/// Tests for SellerListingsPage.
///
/// Verifies loading state, empty state, error state with retry,
/// data display in grid, seller header, and listing tap navigation.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_listing.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/seller_listings_page.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/listing_card.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/listing_skeleton_card.dart';
import 'package:mocktail/mocktail.dart';

class MockMarketplaceRepository extends Mock
    implements MarketplaceRepository {}

/// Creates a test listing with optional overrides.
MarketplaceListing _createListing({
  String id = 'listing-1',
  String sellerId = 'seller-1',
  String title = 'Test Dress',
  int priceCents = 15000,
  String condition = 'good',
  String? city = 'Nice',
  String country = 'France',
}) {
  return MarketplaceListing(
    id: id,
    sellerId: sellerId,
    title: title,
    category: 'dress',
    priceCents: priceCents,
    condition: condition,
    city: city,
    country: country,
    status: 'active',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );
}

void main() {
  late MockMarketplaceRepository mockRepository;

  setUp(() {
    mockRepository = MockMarketplaceRepository();
  });

  Widget buildPage({
    String sellerId = 'seller-1',
    String sellerName = 'Sophie Martin',
    String? sellerAvatarUrl,
    int sellerListingsCount = 5,
    void Function(String)? onListingTap,
  }) {
    return MaterialApp(
      home: SellerListingsPage(
        sellerId: sellerId,
        sellerName: sellerName,
        sellerAvatarUrl: sellerAvatarUrl,
        sellerListingsCount: sellerListingsCount,
        repository: mockRepository,
        onListingTap: onListingTap,
      ),
    );
  }

  group('SellerListingsPage', () {
    group('header', () {
      testWidgets('should display seller name and listings count',
          (tester) async {
        when(() => mockRepository.getSellerListings(
              sellerId: any(named: 'sellerId'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => <MarketplaceListing>[]);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Sophie Martin'), findsOneWidget);
        expect(find.text('5 listings'), findsOneWidget);
      });

      testWidgets('should show singular "listing" for count of 1',
          (tester) async {
        when(() => mockRepository.getSellerListings(
              sellerId: any(named: 'sellerId'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => <MarketplaceListing>[]);

        await tester.pumpWidget(buildPage(sellerListingsCount: 1));
        await tester.pumpAndSettle();

        expect(find.text('1 listing'), findsOneWidget);
      });

      testWidgets('should show first letter as avatar fallback',
          (tester) async {
        when(() => mockRepository.getSellerListings(
              sellerId: any(named: 'sellerId'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => <MarketplaceListing>[]);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // First letter of "Sophie Martin" = "S"
        expect(find.text('S'), findsOneWidget);
      });

      testWidgets('should pop when back button is tapped', (tester) async {
        when(() => mockRepository.getSellerListings(
              sellerId: any(named: 'sellerId'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => <MarketplaceListing>[]);

        // Wrap in a Navigator to verify pop behavior.
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SellerListingsPage(
                        sellerId: 'seller-1',
                        sellerName: 'Sophie Martin',
                        sellerListingsCount: 5,
                        repository: mockRepository,
                      ),
                    ),
                  );
                },
                child: const Text('Go'),
              ),
            ),
          ),
        ));

        // Navigate to seller listings page.
        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();
        expect(find.text('Sophie Martin'), findsOneWidget);

        // Tap back button (chevron_left icon used by LynewedComponentStyles).
        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pumpAndSettle();

        // Should be back on the original page.
        expect(find.text('Go'), findsOneWidget);
        expect(find.text('Sophie Martin'), findsNothing);
      });
    });

    group('loading state', () {
      testWidgets('should show skeleton cards while loading', (tester) async {
        final completer = Completer<List<MarketplaceListing>>();
        when(() => mockRepository.getSellerListings(
              sellerId: any(named: 'sellerId'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) => completer.future);

        await tester.pumpWidget(buildPage());
        await tester.pump();

        // Should show skeleton cards during loading.
        expect(find.byType(ListingSkeletonCard), findsWidgets);
      });
    });

    group('empty state', () {
      testWidgets('should show empty state when no listings', (tester) async {
        when(() => mockRepository.getSellerListings(
              sellerId: any(named: 'sellerId'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => <MarketplaceListing>[]);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('No listings'), findsOneWidget);
        expect(
          find.text('This seller has no active listings at the moment.'),
          findsOneWidget,
        );
      });
    });

    group('error state', () {
      testWidgets('should show error state with retry button', (tester) async {
        when(() => mockRepository.getSellerListings(
              sellerId: any(named: 'sellerId'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenThrow(Exception('Network error'));

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Failed to load listings'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('should reload on retry tap', (tester) async {
        var callCount = 0;
        when(() => mockRepository.getSellerListings(
              sellerId: any(named: 'sellerId'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('Network error');
          }
          return [_createListing()];
        });

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Error state visible.
        expect(find.text('Retry'), findsOneWidget);

        // Tap retry.
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Should now show listing cards.
        expect(find.byType(ListingCard), findsOneWidget);
        expect(find.text('Retry'), findsNothing);
      });
    });

    group('data display', () {
      testWidgets('should display listing cards in a grid', (tester) async {
        final listings = [
          _createListing(id: 'l1', title: 'Dress One', priceCents: 10000),
          _createListing(id: 'l2', title: 'Dress Two', priceCents: 20000),
          _createListing(id: 'l3', title: 'Dress Three', priceCents: 30000),
        ];
        when(() => mockRepository.getSellerListings(
              sellerId: any(named: 'sellerId'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => listings);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(ListingCard), findsNWidgets(3));
        expect(find.text('Dress One'), findsOneWidget);
        expect(find.text('Dress Two'), findsOneWidget);
        expect(find.text('Dress Three'), findsOneWidget);
      });

      testWidgets('should call onListingTap when a card is tapped',
          (tester) async {
        String? tappedId;
        when(() => mockRepository.getSellerListings(
              sellerId: any(named: 'sellerId'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => [_createListing()]);

        await tester.pumpWidget(buildPage(
          onListingTap: (id) => tappedId = id,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ListingCard).first);
        await tester.pump();

        expect(tappedId, 'listing-1');
      });
    });

    group('pagination', () {
      testWidgets('should load more listings on scroll', (tester) async {
        // First page: 20 items.
        final firstPage = List.generate(
          20,
          (i) => _createListing(
            id: 'listing-$i',
            title: 'Listing $i',
            priceCents: 10000 + i * 100,
          ),
        );
        // Second page: 5 items.
        final secondPage = List.generate(
          5,
          (i) => _createListing(
            id: 'listing-${20 + i}',
            title: 'Listing ${20 + i}',
            priceCents: 12000 + i * 100,
          ),
        );

        var pageRequested = -1;
        when(() => mockRepository.getSellerListings(
              sellerId: any(named: 'sellerId'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((invocation) async {
          pageRequested =
              invocation.namedArguments[const Symbol('page')] as int;
          if (pageRequested == 0) return firstPage;
          return secondPage;
        });

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // First page loaded.
        expect(pageRequested, 0);

        // Scroll to the bottom to trigger pagination.
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -5000),
        );
        await tester.pumpAndSettle();

        // Second page should have been requested.
        expect(pageRequested, 1);
      });
    });
  });
}
