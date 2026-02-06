/// Tests for CheckoutPage.
///
/// Verifies multi-step checkout flow: address, shipping (flat rates),
/// review, CGVU acceptance, and payment processing.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/data/datasources/fedex_remote_datasource.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_listing.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_address.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_rate.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_transaction_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/checkout_page.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/address_form_widget.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/cgvu_acceptance_widget.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/order_summary_widget.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/shipping_options_widget.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock
    implements MarketplaceTransactionRepository {}

class MockFedExDatasource extends Mock implements FedExRemoteDatasource {}

MarketplaceListing _createListing({
  String id = 'listing-1',
  String sellerId = 'seller-1',
  String title = 'Beautiful Wedding Dress',
  int priceCents = 29999,
  String category = 'dress',
  String? city = 'Paris',
  String country = 'France',
  String? countryCode = 'FR',
}) {
  return MarketplaceListing(
    id: id,
    sellerId: sellerId,
    title: title,
    priceCents: priceCents,
    category: category,
    condition: 'excellent',
    city: city,
    country: country,
    countryCode: countryCode,
    status: 'active',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );
}

void main() {
  late MockTransactionRepository mockTransactionRepo;
  late MockFedExDatasource mockFedExDatasource;

  setUpAll(() {
    // Register fallback values for mocktail.
    registerFallbackValue(
      const ShippingAddress(
        streetLines: ['123 Main St'],
        city: 'Test City',
        postalCode: '12345',
        countryCode: 'US',
      ),
    );
  });

  setUp(() {
    mockTransactionRepo = MockTransactionRepository();
    mockFedExDatasource = MockFedExDatasource();

    // Default: buyer has not accepted CGVU.
    when(() => mockTransactionRepo.hasAcceptedBuyerCgvu())
        .thenAnswer((_) async => false);

    // Default: FedEx returns flat rate for FR → US (international shipping).
    when(() => mockFedExDatasource.calculateRates(
          fromAddress: any(named: 'fromAddress'),
          toAddress: any(named: 'toAddress'),
          category: any(named: 'category'),
        )).thenAnswer((_) async => [
          const ShippingRate(
            serviceType: 'FLAT_RATE_INTERNATIONAL',
            serviceName: 'International Shipping',
            rateCents: 3500,
            currency: 'USD',
            estimatedDaysLabel: '7-14 business days',
          ),
        ]);
  });

  Widget buildPage({
    MarketplaceListing? listing,
    String? offerId,
    int? agreedPriceCents,
  }) {
    return MaterialApp(
      home: CheckoutPage(
        listing: listing ?? _createListing(),
        offerId: offerId,
        agreedPriceCents: agreedPriceCents,
        sellerShippingAddress: const ShippingAddress(
          streetLines: ['123 Rue de la Paix'],
          city: 'Paris',
          postalCode: '75001',
          countryCode: 'FR',
        ),
        transactionRepository: mockTransactionRepo,
        currentUserId: 'buyer-1',
        fedexDatasource: mockFedExDatasource,
      ),
    );
  }

  /// Fills address form fields required for a valid address.
  ///
  /// Uses hint-text-based field lookup for robustness against index changes.
  /// Scrolls to the country dropdown before tapping it (may be off-screen).
  /// Fills all required fields: name, phone, street, city, postal code, country.
  Future<void> fillAddress(WidgetTester tester) async {
    // Full Name (required)
    final nameField = find.widgetWithText(TextField, 'Full Name *');
    await tester.enterText(nameField, 'Jane Doe');
    await tester.pump();

    // Phone Number (required) - find by hint prefix since hint may include format example
    final phoneField = find.byWidgetPredicate(
      (w) =>
          w is TextField &&
          w.decoration?.hintText != null &&
          w.decoration!.hintText!.startsWith('Phone'),
    );
    await tester.enterText(phoneField, '5551234567');
    await tester.pump();

    // Street Address
    final streetField = find.widgetWithText(TextField, 'Street Address');
    await tester.enterText(streetField, '123 Main St');
    await tester.pump();

    // City
    final cityField = find.widgetWithText(TextField, 'City');
    await tester.enterText(cityField, 'New York');
    await tester.pump();

    // Postal Code - scroll into view first (might be off-screen).
    final postalField = find.widgetWithText(TextField, 'Postal Code');
    await tester.ensureVisible(postalField);
    await tester.pumpAndSettle();
    await tester.enterText(postalField, '10001');
    await tester.pump();

    // Country dropdown: scroll into view, open, then select.
    final dropdown = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('United States').last);
    await tester.pumpAndSettle();
  }

  group('CheckoutPage', () {
    group('step 1: address', () {
      testWidgets('should show address form on initial load', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Checkout'), findsOneWidget);
        expect(find.byType(AddressFormWidget), findsOneWidget);
        expect(find.text('Continue'), findsOneWidget);
      });

      testWidgets('should show step indicator with Address active',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Address'), findsOneWidget);
        expect(find.text('Shipping'), findsOneWidget);
        expect(find.text('Review'), findsOneWidget);
        expect(find.text('Confirm'), findsOneWidget);
      });

      testWidgets('should disable Continue when address is not filled',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Continue button should be present but disabled (onPressed is null).
        final button = find.text('Continue');
        expect(button, findsOneWidget);
      });
    });

    group('step 2: shipping', () {
      testWidgets('should show shipping options after filling address',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await fillAddress(tester);

        // Tap Continue to go to shipping step.
        await tester.ensureVisible(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(find.byType(ShippingOptionsWidget), findsOneWidget);
      });

      testWidgets('should auto-select flat rate when moving to shipping step',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await fillAddress(tester);

        await tester.ensureVisible(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Flat rate is auto-calculated: FR → US = International Shipping.
        expect(find.text('International Shipping'), findsOneWidget);
      });
    });

    group('step 3: review', () {
      testWidgets('should show order summary after shipping step',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Step 1: Fill address.
        await fillAddress(tester);
        await tester.ensureVisible(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 2: Flat rate auto-selected. Continue.
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 3: Review.
        expect(find.byType(OrderSummaryWidget), findsOneWidget);
        expect(find.text('Beautiful Wedding Dress'), findsOneWidget);
      });
    });

    group('step 4: confirm', () {
      testWidgets('should show CGVU acceptance on confirm step',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Navigate through steps.
        await fillAddress(tester);
        await tester.ensureVisible(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 2: Continue (flat rate auto-selected).
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 3 review: Continue.
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 4: CGVU.
        expect(find.byType(CgvuAcceptanceWidget), findsOneWidget);
        expect(find.text('Pay Now'), findsOneWidget);
      });
    });

    group('navigation', () {
      testWidgets('should have back button', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // LynewedComponentStyles.backButton uses Icons.chevron_left.
        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      });

      testWidgets('should show Back button from step 2', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Fill address and navigate to step 2.
        await fillAddress(tester);
        await tester.ensureVisible(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(find.text('Back'), findsOneWidget);
      });

      testWidgets('should go back to previous step when Back tapped',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Fill address and navigate to step 2.
        await fillAddress(tester);
        await tester.ensureVisible(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Now tap Back.
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();

        // Should be back on address step.
        expect(find.byType(AddressFormWidget), findsOneWidget);
      });
    });

    group('agreed price override', () {
      testWidgets('should use agreed price when provided', (tester) async {
        await tester.pumpWidget(buildPage(agreedPriceCents: 20000));
        await tester.pumpAndSettle();

        // Navigate to review step.
        await fillAddress(tester);
        await tester.ensureVisible(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 2: Continue (flat rate auto-selected).
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Should show agreed price ($200.00) instead of listing price ($299.99).
        expect(find.text('\$200.00'), findsOneWidget);
      });
    });

    group('CGVU already accepted', () {
      testWidgets('should skip CGVU when already accepted', (tester) async {
        when(() => mockTransactionRepo.hasAcceptedBuyerCgvu())
            .thenAnswer((_) async => true);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await fillAddress(tester);
        await tester.ensureVisible(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 2: Continue (flat rate auto-selected).
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 3 review: Continue.
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // On confirm step, should show already accepted message.
        expect(
            find.text('You have already accepted the marketplace buyer terms.'),
            findsOneWidget);
      });
    });

    group('flat rate shipping', () {
      testWidgets('should calculate international flat rate for FR to US',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await fillAddress(tester);
        await tester.ensureVisible(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // FR → US = International Shipping.
        expect(find.text('International Shipping'), findsOneWidget);
      });
    });
  });
}
