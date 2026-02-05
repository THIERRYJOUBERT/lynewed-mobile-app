/// Tests for HomeMarketplacePreview widget.
///
/// Verifies loading, listing display, empty state, error state,
/// "View all" tap, and listing card tap behavior.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_listing.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/home_marketplace_preview.dart';
import 'package:mocktail/mocktail.dart';

class MockMarketplaceRepository extends Mock implements MarketplaceRepository {}

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
  String? coverPhotoStoragePath,
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
    coverPhotoStoragePath: coverPhotoStoragePath,
  );
}

/// Generate a list of N test listings.
List<MarketplaceListing> _generateListings(int count) {
  return List.generate(
    count,
    (i) => _createListing(
      id: 'listing-$i',
      title: 'Listing $i',
      priceCents: 10000 + i * 100,
      coverPhotoStoragePath: 'listing-$i/photo_0.jpg',
    ),
  );
}

void main() {
  late MockMarketplaceRepository mockRepository;

  setUp(() {
    mockRepository = MockMarketplaceRepository();
  });

  Widget buildWidget({
    VoidCallback? onSeeAllTap,
    void Function(String)? onListingTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: HomeMarketplacePreview(
            repository: mockRepository,
            onSeeAllTap: onSeeAllTap,
            onListingTap: onListingTap,
          ),
        ),
      ),
    );
  }

  group('HomeMarketplacePreview', () {
    testWidgets('shows section header and listings when data is available',
        (tester) async {
      final listings = _generateListings(3);
      when(() => mockRepository.getListings(
            page: 0,
            pageSize: 5,
          )).thenAnswer((_) async => listings);

      await tester.pumpWidget(buildWidget());
      // Let the future complete.
      await tester.pumpAndSettle();

      // Should show section title.
      expect(find.text('MARKETPLACE'), findsOneWidget);
      // Should show "View all" link.
      expect(find.text('View all'), findsOneWidget);
      // Should show listing titles.
      expect(find.text('Listing 0'), findsOneWidget);
      expect(find.text('Listing 1'), findsOneWidget);
      expect(find.text('Listing 2'), findsOneWidget);
    });

    testWidgets('shows price for each listing card', (tester) async {
      final listings = [
        _createListing(
          id: 'l-1',
          title: 'Elegant Dress',
          priceCents: 29999,
        ),
      ];
      when(() => mockRepository.getListings(
            page: 0,
            pageSize: 5,
          )).thenAnswer((_) async => listings);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Should show the formatted price.
      expect(find.text('\$299.99'), findsOneWidget);
    });

    testWidgets('returns SizedBox.shrink when no listings', (tester) async {
      when(() => mockRepository.getListings(
            page: 0,
            pageSize: 5,
          )).thenAnswer((_) async => <MarketplaceListing>[]);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Should not show section header.
      expect(find.text('MARKETPLACE'), findsNothing);
      // Should not show "View all".
      expect(find.text('View all'), findsNothing);
    });

    testWidgets('returns SizedBox.shrink on error', (tester) async {
      when(() => mockRepository.getListings(
            page: 0,
            pageSize: 5,
          )).thenThrow(Exception('Network error'));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Should not show section header.
      expect(find.text('MARKETPLACE'), findsNothing);
    });

    testWidgets('calls onSeeAllTap when "View all" is tapped', (tester) async {
      var tapped = false;
      when(() => mockRepository.getListings(
            page: 0,
            pageSize: 5,
          )).thenAnswer((_) async => _generateListings(3));

      await tester.pumpWidget(buildWidget(
        onSeeAllTap: () => tapped = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('View all'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('calls onListingTap with listing id when card is tapped',
        (tester) async {
      String? tappedId;
      final listings = _generateListings(3);
      when(() => mockRepository.getListings(
            page: 0,
            pageSize: 5,
          )).thenAnswer((_) async => listings);

      await tester.pumpWidget(buildWidget(
        onListingTap: (id) => tappedId = id,
      ));
      await tester.pumpAndSettle();

      // Tap on the first listing card.
      await tester.tap(find.text('Listing 0'));
      await tester.pump();

      expect(tappedId, equals('listing-0'));
    });

    testWidgets('shows at most 5 listings', (tester) async {
      final listings = _generateListings(5);
      when(() => mockRepository.getListings(
            page: 0,
            pageSize: 5,
          )).thenAnswer((_) async => listings);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // All 5 should be present in the horizontal scroll.
      for (var i = 0; i < 5; i++) {
        expect(find.text('Listing $i'), findsOneWidget);
      }
    });

    testWidgets('shows subtitle text', (tester) async {
      when(() => mockRepository.getListings(
            page: 0,
            pageSize: 5,
          )).thenAnswer((_) async => _generateListings(2));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Discover pre-loved wedding items'), findsOneWidget);
    });
  });
}
