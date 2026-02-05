/// Tests for MarketplaceFeedPage.
///
/// Verifies feed rendering, loading states, category filtering,
/// infinite scroll, pull-to-refresh, and navigation to detail.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/listing_filter.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_listing.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/marketplace_feed_page.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/category_chips.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/listing_card.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/listing_skeleton_card.dart';
import 'package:mocktail/mocktail.dart';

class MockMarketplaceRepository extends Mock implements MarketplaceRepository {}

class FakeListingFilter extends Fake implements ListingFilter {}

/// Creates a test listing with optional overrides.
MarketplaceListing _createListing({
  String id = 'listing-1',
  String title = 'Wedding Dress',
  int priceCents = 29999,
  String category = 'dress',
  String condition = 'excellent',
  String? city = 'Paris',
  String country = 'France',
  String status = 'active',
}) {
  return MarketplaceListing(
    id: id,
    sellerId: 'seller-1',
    title: title,
    category: category,
    priceCents: priceCents,
    condition: condition,
    city: city,
    country: country,
    status: status,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );
}

/// Generate a list of N test listings.
List<MarketplaceListing> _generateListings(int count, {String category = 'dress'}) {
  return List.generate(
    count,
    (i) => _createListing(
      id: 'listing-$i',
      title: 'Listing $i',
      priceCents: 10000 + i * 100,
      category: category,
    ),
  );
}

void main() {
  late MockMarketplaceRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeListingFilter());
  });

  setUp(() {
    mockRepository = MockMarketplaceRepository();

    // Default stubs for filtered listings (used when category chips are tapped).
    when(() => mockRepository.getFilteredListings(
          filter: any(named: 'filter'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((_) async => <MarketplaceListing>[]);
    when(() => mockRepository.getFilteredListingsCount(any()))
        .thenAnswer((_) async => 0);
  });

  Widget buildPage() {
    return MaterialApp(
      home: MarketplaceFeedPage(
        repository: mockRepository,
      ),
    );
  }

  group('MarketplaceFeedPage', () {
    group('initial loading state', () {
      testWidgets('should show skeleton cards while loading', (tester) async {
        // Use a Completer to block the future (no pending timers)
        final completer = Completer<List<MarketplaceListing>>();
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) => completer.future);

        await tester.pumpWidget(buildPage());
        // Initial frame shows loading
        await tester.pump();

        expect(find.byType(ListingSkeletonCard), findsWidgets);

        // Complete the future to avoid leaks
        completer.complete([]);
        await tester.pumpAndSettle();
      });
    });

    group('data display', () {
      testWidgets('should render grid of listing cards when data available',
          (tester) async {
        final listings = _generateListings(4);
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => listings);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(ListingCard), findsWidgets);
      });

      testWidgets('should show empty state when no listings', (tester) async {
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => []);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('No listings yet'), findsOneWidget);
        expect(
          find.text('Be the first to list your wedding dress or shoes!'),
          findsOneWidget,
        );
      });

      testWidgets('should show error state on fetch failure', (tester) async {
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenThrow(Exception('Network error'));

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Failed to load listings'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });
    });

    group('category filter', () {
      testWidgets('should show category chips', (tester) async {
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => []);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(CategoryChips), findsOneWidget);
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Dresses'), findsOneWidget);
        expect(find.text('Shoes'), findsOneWidget);
      });

      testWidgets('should reload with category filter when chip tapped',
          (tester) async {
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => []);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Tap "Dresses" chip
        await tester.tap(find.text('Dresses'));
        await tester.pumpAndSettle();

        // Verify getFilteredListings was called with category 'dress'
        // (category chip selection now goes through filtered path).
        verify(() => mockRepository.getFilteredListings(
              filter: any(named: 'filter'),
              page: 0,
              pageSize: 20,
            )).called(1);
      });

      testWidgets('should reload without filter when All chip tapped',
          (tester) async {
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => []);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // First tap Dresses, then tap All
        await tester.tap(find.text('Dresses'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('All'));
        await tester.pumpAndSettle();

        // Verify last call to getListings was with category null
        verify(() => mockRepository.getListings(
              category: null,
              page: 0,
              pageSize: 20,
            )).called(2); // initial + after tapping All
      });
    });

    group('infinite scroll', () {
      testWidgets('should load more listings when scrolled near bottom',
          (tester) async {
        // First page: 20 items (full page = hasMore is true)
        final firstPage = _generateListings(20);
        // Second page: 5 items (less than 20 = no more pages)
        final secondPage = _generateListings(5);

        var callCount = 0;
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? firstPage : secondPage;
        });

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Verify first page loaded - grid only renders visible items,
        // so we check that at least some ListingCards are shown
        expect(find.byType(ListingCard), findsWidgets);

        // Scroll to bottom repeatedly to trigger load more
        for (var i = 0; i < 10; i++) {
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -500),
          );
          await tester.pump();
        }
        await tester.pumpAndSettle();

        // Verify getListings was called with page 1 (load more triggered)
        verify(() => mockRepository.getListings(
              category: null,
              page: 1,
              pageSize: 20,
            )).called(1);
      });

      testWidgets('should not load more when hasMore is false',
          (tester) async {
        // Return less than 20 items = hasMore false
        final listings = _generateListings(5);
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => listings);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Scroll to bottom
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -1000),
        );
        await tester.pumpAndSettle();

        // Should only have been called once (initial load, no load more)
        verify(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).called(1);
      });
    });

    group('pull to refresh', () {
      testWidgets('should refresh listings on pull down', (tester) async {
        final listings = _generateListings(4);
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => listings);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Pull to refresh
        await tester.fling(
          find.byType(CustomScrollView),
          const Offset(0, 300),
          1000,
        );
        await tester.pumpAndSettle();

        // Verify getListings was called again (initial + refresh)
        verify(() => mockRepository.getListings(
              category: null,
              page: 0,
              pageSize: 20,
            )).called(2);
      });
    });

    group('navigation', () {
      testWidgets('should navigate to detail when card is tapped',
          (tester) async {
        final listings = [_createListing()];
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => listings);

        // Track navigation by intercepting Navigator push
        var navigatedToId = '';
        await tester.pumpWidget(
          MaterialApp(
            home: MarketplaceFeedPage(
              repository: mockRepository,
              onListingTap: (id) => navigatedToId = id,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ListingCard));
        await tester.pumpAndSettle();

        expect(navigatedToId, 'listing-1');
      });
    });

    group('page title', () {
      testWidgets('should display Marketplace as title', (tester) async {
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => []);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Marketplace'), findsOneWidget);
      });
    });

    group('sell FAB', () {
      testWidgets('should show a FAB to create a new listing', (tester) async {
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => _generateListings(3));

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('should show FAB even when listings are empty',
          (tester) async {
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => []);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    group('My Sales button', () {
      testWidgets('should show My Sales icon in header', (tester) async {
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => []);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);
      });
    });

    group('My Offers button', () {
      testWidgets('should show My Offers icon in header', (tester) async {
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => []);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.local_offer_outlined), findsOneWidget);
      });
    });

    group('retry on error', () {
      testWidgets('should retry loading when Retry button is tapped',
          (tester) async {
        var callCount = 0;
        when(() => mockRepository.getListings(
              category: any(named: 'category'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('Network error');
          }
          return _generateListings(3);
        });

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Should show error state
        expect(find.text('Failed to load listings'), findsOneWidget);

        // Tap Retry
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Should now show listings
        expect(find.byType(ListingCard), findsNWidgets(3));
      });
    });
  });
}
