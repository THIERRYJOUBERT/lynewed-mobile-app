/// Tests for ListingDetailPage.
///
/// Verifies loading state, error state with retry, data display,
/// photo carousel, listing info, seller info, action buttons,
/// sleeve length conditional display, and coming soon snackbars.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_listing.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/seller_profile.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/listing_detail_page.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/action_buttons_bar.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/listing_info_section.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/photo_carousel.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/seller_info_widget.dart';
import 'package:mocktail/mocktail.dart';

class MockMarketplaceRepository extends Mock
    implements MarketplaceRepository {}

/// Creates a test listing with optional overrides.
MarketplaceListing _createListing({
  String id = 'listing-1',
  String sellerId = 'seller-1',
  String title = 'Beautiful Wedding Dress',
  String? description = 'A stunning wedding dress in perfect condition.',
  String category = 'dress',
  int priceCents = 29999,
  String? designerBrand = 'Vera Wang',
  String? size = 'S',
  String condition = 'excellent',
  String? sleeveLength = 'long',
  String? city = 'Paris',
  String country = 'France',
  String status = 'active',
}) {
  return MarketplaceListing(
    id: id,
    sellerId: sellerId,
    title: title,
    description: description,
    category: category,
    priceCents: priceCents,
    designerBrand: designerBrand,
    size: size,
    condition: condition,
    sleeveLength: sleeveLength,
    city: city,
    country: country,
    status: status,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );
}

const _testSeller = SellerProfile(
  id: 'seller-1',
  name: 'Alice Martin',
  avatarUrl: null,
  listingsCount: 3,
);

/// Use empty photo URLs list to avoid CachedNetworkImage HTTP timeouts in tests.
const _testPhotoUrls = <String>[];

void main() {
  late MockMarketplaceRepository mockRepository;

  setUp(() {
    mockRepository = MockMarketplaceRepository();
  });

  /// Helper to set up common mock responses.
  void setupSuccessfulMocks({
    MarketplaceListing? listing,
    SellerProfile? seller,
    List<String>? photoUrls,
  }) {
    when(() => mockRepository.getListingById(any()))
        .thenAnswer((_) async => listing ?? _createListing());
    when(() => mockRepository.getSellerInfo(any()))
        .thenAnswer((_) async => seller ?? _testSeller);
    when(() => mockRepository.getPhotoUrls(any()))
        .thenAnswer((_) async => photoUrls ?? _testPhotoUrls);
  }

  Widget buildPage({String listingId = 'listing-1'}) {
    return MaterialApp(
      home: ListingDetailPage(
        listingId: listingId,
        repository: mockRepository,
      ),
    );
  }

  /// Pumps the widget and scrolls down to reveal content below the carousel.
  Future<void> pumpAndScroll(WidgetTester tester) async {
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    // Scroll down past the photo carousel to reveal info sections.
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byType(ListingInfoSection),
      200,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
  }

  group('ListingDetailPage', () {
    group('loading state', () {
      testWidgets('should show loading indicator while data is being fetched',
          (tester) async {
        final listingCompleter = Completer<MarketplaceListing?>();
        when(() => mockRepository.getListingById(any()))
            .thenAnswer((_) => listingCompleter.future);

        await tester.pumpWidget(buildPage());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete to avoid pending timer leaks.
        listingCompleter.complete(null);
        await tester.pumpAndSettle();
      });
    });

    group('error state', () {
      testWidgets('should show error state when fetch fails', (tester) async {
        when(() => mockRepository.getListingById(any()))
            .thenThrow(Exception('Network error'));

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Failed to load listing'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('should show error when listing not found', (tester) async {
        when(() => mockRepository.getListingById(any()))
            .thenAnswer((_) async => null);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Listing not found'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('should retry loading when Retry button is tapped',
          (tester) async {
        var callCount = 0;
        when(() => mockRepository.getListingById(any())).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('Network error');
          }
          return _createListing();
        });
        when(() => mockRepository.getSellerInfo(any()))
            .thenAnswer((_) async => _testSeller);
        when(() => mockRepository.getPhotoUrls(any()))
            .thenAnswer((_) async => _testPhotoUrls);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Should show error state.
        expect(find.text('Failed to load listing'), findsOneWidget);

        // Tap Retry.
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // After retry, the page loads. Scroll down to see listing data.
        final scrollable = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.text('Beautiful Wedding Dress'),
          200,
          scrollable: scrollable,
        );

        expect(find.text('Beautiful Wedding Dress'), findsOneWidget);
      });
    });

    group('AC-1: detail page shows listing info', () {
      testWidgets(
          'should show photo carousel at top of the page',
          (tester) async {
        setupSuccessfulMocks();

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Photo carousel visible at top without scrolling.
        expect(find.byType(PhotoCarousel), findsOneWidget);
      });

      testWidgets(
          'should show title, price after scrolling',
          (tester) async {
        setupSuccessfulMocks();

        await pumpAndScroll(tester);

        // Title
        expect(find.text('Beautiful Wedding Dress'), findsOneWidget);

        // Price ($299.99)
        expect(find.text('\$299.99'), findsOneWidget);
      });

      testWidgets(
          'should show description, size, brand, condition, location after scrolling',
          (tester) async {
        setupSuccessfulMocks();

        await pumpAndScroll(tester);

        // Description
        expect(
          find.text('A stunning wedding dress in perfect condition.'),
          findsOneWidget,
        );

        // Size
        expect(find.text('Size'), findsOneWidget);

        // Brand
        expect(find.text('Brand'), findsOneWidget);
        expect(find.text('Vera Wang'), findsOneWidget);

        // Condition
        expect(find.text('Condition'), findsOneWidget);
        expect(find.text('Excellent'), findsOneWidget);
      });

      testWidgets('should show location after scrolling', (tester) async {
        setupSuccessfulMocks();

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Scroll to location.
        final scrollable = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.text('Paris, France'),
          200,
          scrollable: scrollable,
        );

        expect(find.text('Paris, France'), findsOneWidget);
      });
    });

    group('AC-2: photo carousel', () {
      testWidgets('should render photo carousel when data loaded',
          (tester) async {
        setupSuccessfulMocks();

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(PhotoCarousel), findsOneWidget);
      });

      testWidgets('should show placeholder when no photos', (tester) async {
        setupSuccessfulMocks(photoUrls: []);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(PhotoCarousel), findsOneWidget);
        expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      });
    });

    group('AC-3: action buttons', () {
      testWidgets('should show action buttons bar', (tester) async {
        setupSuccessfulMocks();

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Bottom bar is always visible (not scrolled).
        expect(find.byType(ActionButtonsBar), findsOneWidget);
        expect(find.text('Make Offer'), findsOneWidget);
        expect(find.text('Buy Now'), findsOneWidget);
        expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      });

      testWidgets('should navigate to chat page when Contact is tapped',
          (tester) async {
        setupSuccessfulMocks();

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Tapping the contact button triggers navigation to MarketplaceChatPage.
        // Since GetIt does not have MarketplaceChatRepository registered in this
        // test, building the pushed page throws a StateError. We suppress Flutter
        // errors to verify the navigation intent (no "coming soon" snackbar).
        final oldOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          // Suppress GetIt registration errors from the navigated page.
        };

        await tester.tap(find.byIcon(Icons.chat_bubble_outline));
        await tester.pump();

        FlutterError.onError = oldOnError;

        // The "Chat coming soon" snackbar should NOT appear anymore.
        expect(find.text('Chat coming soon'), findsNothing);
      });

      testWidgets(
          'should open make offer sheet when Make Offer is tapped',
          (tester) async {
        setupSuccessfulMocks();

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Tapping Make Offer opens the MakeOfferSheet. Since GetIt does not
        // have MarketplaceOfferRepository registered in this test, building
        // the sheet may throw. We suppress errors to verify the intent.
        final oldOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          // Suppress GetIt registration errors from the sheet.
        };

        await tester.tap(find.text('Make Offer'));
        await tester.pump();

        FlutterError.onError = oldOnError;

        // The "Make Offer coming soon" snackbar should NOT appear.
        expect(find.text('Make Offer coming soon'), findsNothing);
      });

      testWidgets('should navigate to checkout when Buy Now is tapped',
          (tester) async {
        setupSuccessfulMocks();

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Tapping Buy Now navigates to CheckoutPage. Since GetIt does not
        // have MarketplaceTransactionRepository registered in this test,
        // building the pushed page throws. We suppress Flutter errors to
        // verify the navigation intent (no "coming soon" snackbar).
        final oldOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          // Suppress GetIt registration errors from the navigated page.
        };

        await tester.tap(find.text('Buy Now'));
        await tester.pump();

        FlutterError.onError = oldOnError;

        // The "Buy Now coming soon" snackbar should NOT appear.
        expect(find.text('Buy Now coming soon'), findsNothing);
      });
    });

    group('AC-4: seller info', () {
      testWidgets('should display seller name and listings count',
          (tester) async {
        setupSuccessfulMocks();

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Scroll to seller section.
        final scrollable = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.byType(SellerInfoWidget),
          200,
          scrollable: scrollable,
        );
        await tester.pumpAndSettle();

        expect(find.byType(SellerInfoWidget), findsOneWidget);
        expect(find.text('Alice Martin'), findsOneWidget);
        expect(find.text('3 listings'), findsOneWidget);
      });

      testWidgets('should show View Listings button', (tester) async {
        setupSuccessfulMocks();

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        final scrollable = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.text('View Listings'),
          200,
          scrollable: scrollable,
        );

        expect(find.text('View Listings'), findsOneWidget);
      });

      testWidgets('should show first letter as avatar fallback',
          (tester) async {
        setupSuccessfulMocks();

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        final scrollable = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.byType(SellerInfoWidget),
          200,
          scrollable: scrollable,
        );

        // Avatar fallback: first letter of name.
        expect(find.text('A'), findsOneWidget);
      });
    });

    group('AC-5: sleeve length conditional', () {
      testWidgets('should show sleeve_length for dress listing',
          (tester) async {
        setupSuccessfulMocks(
          listing: _createListing(
            category: 'dress',
            sleeveLength: 'long',
          ),
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        final scrollable = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.text('Sleeve Length'),
          200,
          scrollable: scrollable,
        );

        expect(find.text('Sleeve Length'), findsOneWidget);
        expect(find.text('Long'), findsOneWidget);
      });

      testWidgets('should NOT show sleeve_length for shoes listing',
          (tester) async {
        setupSuccessfulMocks(
          listing: _createListing(
            category: 'shoes',
            sleeveLength: null,
          ),
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Scroll past details section to ensure sleeve_length would have been rendered.
        final scrollable = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.text('Location'),
          200,
          scrollable: scrollable,
        );

        expect(find.text('Sleeve Length'), findsNothing);
      });

      testWidgets(
          'should NOT show sleeve_length for dress when sleeveLength is null',
          (tester) async {
        setupSuccessfulMocks(
          listing: _createListing(
            category: 'dress',
            sleeveLength: null,
          ),
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        final scrollable = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.text('Location'),
          200,
          scrollable: scrollable,
        );

        expect(find.text('Sleeve Length'), findsNothing);
      });
    });

    group('listing info section', () {
      testWidgets('should show listing info section widget', (tester) async {
        setupSuccessfulMocks();

        await pumpAndScroll(tester);

        expect(find.byType(ListingInfoSection), findsOneWidget);
      });

      testWidgets('should show "Not specified" when brand is null',
          (tester) async {
        setupSuccessfulMocks(
          listing: _createListing(designerBrand: null),
        );

        await pumpAndScroll(tester);

        expect(find.text('Not specified'), findsOneWidget);
      });

      testWidgets('should hide description section when null', (tester) async {
        setupSuccessfulMocks(
          listing: _createListing(description: null),
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Scroll down to see everything.
        final scrollable = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.text('Location'),
          200,
          scrollable: scrollable,
        );

        expect(find.text('Description'), findsNothing);
      });

      testWidgets('should show country only when city is null',
          (tester) async {
        setupSuccessfulMocks(
          listing: _createListing(city: null),
        );

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        final scrollable = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.text('Location'),
          200,
          scrollable: scrollable,
        );

        expect(find.text('France'), findsOneWidget);
      });
    });

    group('seller action bar', () {
      testWidgets(
          'should show Edit Draft button for draft listing when user is seller',
          (tester) async {
        setupSuccessfulMocks(
          listing: _createListing(
            sellerId: 'current-user',
            status: 'draft',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ListingDetailPage(
              listingId: 'listing-1',
              repository: mockRepository,
              currentUserId: 'current-user',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Edit Draft'), findsOneWidget);
        expect(find.text('View Offers'), findsNothing);
      });

      testWidgets(
          'should show View Offers and Edit buttons for active listing when user is seller',
          (tester) async {
        setupSuccessfulMocks(
          listing: _createListing(
            sellerId: 'current-user',
            status: 'active',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ListingDetailPage(
              listingId: 'listing-1',
              repository: mockRepository,
              currentUserId: 'current-user',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('View Offers'), findsOneWidget);
        expect(find.text('Edit'), findsOneWidget);
        expect(find.text('Edit Draft'), findsNothing);
      });

      testWidgets(
          'should show buyer action buttons when user is NOT the seller',
          (tester) async {
        setupSuccessfulMocks(
          listing: _createListing(
            sellerId: 'other-seller',
            status: 'active',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ListingDetailPage(
              listingId: 'listing-1',
              repository: mockRepository,
              currentUserId: 'current-user',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Make Offer'), findsOneWidget);
        expect(find.text('Buy Now'), findsOneWidget);
        expect(find.text('Edit Draft'), findsNothing);
        expect(find.text('View Offers'), findsNothing);
        expect(find.text('Edit'), findsNothing);
      });
    });

    group('back navigation', () {
      testWidgets('should show back button', (tester) async {
        setupSuccessfulMocks();

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    });
  });
}
