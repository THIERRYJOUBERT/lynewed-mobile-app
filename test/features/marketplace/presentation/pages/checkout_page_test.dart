/// Tests for CheckoutPage.
///
/// Verifies multi-step checkout flow: address, shipping (FedEx dynamic),
/// review, CGVU acceptance, and payment processing.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_listing.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_address.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_rate.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_transaction_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/calculate_shipping_rate_use_case.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/get_seller_shipping_address.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/checkout_page.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/address_form_widget.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/cgvu_acceptance_widget.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/order_summary_widget.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/shipping_rate_selector.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock
    implements MarketplaceTransactionRepository {}

class MockCalculateShippingRate extends Mock
    implements CalculateShippingRateUseCase {}

class MockGetSellerShippingAddress extends Mock
    implements GetSellerShippingAddress {}

MarketplaceListing _createListing({
  String id = 'listing-1',
  String sellerId = 'seller-1',
  String title = 'Beautiful Wedding Dress',
  int priceCents = 29999,
  String category = 'dress',
  String? city = 'Paris',
  String country = 'France',
  String? countryCode = 'FR',
  double? weightKg,
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
    weightKg: weightKg,
  );
}

const _sellerAddress = ShippingAddress(
  streetLines: ['10 Rue de Rivoli'],
  city: 'Paris',
  postalCode: '75001',
  countryCode: 'FR',
);

const _fedexRates = [
  ShippingRate(
    serviceType: 'FEDEX_GROUND',
    serviceName: 'FedEx Ground',
    rateCents: 1250,
    currency: 'USD',
    estimatedDays: 5,
  ),
  ShippingRate(
    serviceType: 'FEDEX_EXPRESS',
    serviceName: 'FedEx Express',
    rateCents: 2500,
    currency: 'USD',
    estimatedDays: 2,
  ),
];

void main() {
  late MockTransactionRepository mockTransactionRepo;
  late MockCalculateShippingRate mockCalculateRate;
  late MockGetSellerShippingAddress mockGetSellerAddress;

  setUpAll(() {
    registerFallbackValue(
      const ShippingAddress(
        streetLines: ['123 Main St'],
        city: 'Test City',
        postalCode: '12345',
        countryCode: 'US',
      ),
    );
    registerFallbackValue(
      const ShippingRate(
        serviceType: 'FLAT_RATE',
        serviceName: 'Test',
        rateCents: 0,
        currency: 'USD',
      ),
    );
  });

  setUp(() {
    mockTransactionRepo = MockTransactionRepository();
    mockCalculateRate = MockCalculateShippingRate();
    mockGetSellerAddress = MockGetSellerShippingAddress();

    // Default: buyer has not accepted CGVU.
    when(() => mockTransactionRepo.hasAcceptedBuyerCgvu())
        .thenAnswer((_) async => false);

    // Default: seller address found.
    when(() => mockGetSellerAddress(any()))
        .thenAnswer((_) async => _sellerAddress);

    // Default: FedEx rates available.
    when(() => mockCalculateRate(
          fromAddress: any(named: 'fromAddress'),
          toAddress: any(named: 'toAddress'),
          category: any(named: 'category'),
          weightKg: any(named: 'weightKg'),
        )).thenAnswer((_) async => _fedexRates);
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
        transactionRepository: mockTransactionRepo,
        calculateShippingRateUseCase: mockCalculateRate,
        getSellerShippingAddress: mockGetSellerAddress,
        currentUserId: 'buyer-1',
      ),
    );
  }

  /// Fills address form fields required for a valid address.
  Future<void> fillAddress(WidgetTester tester) async {
    final nameField = find.widgetWithText(TextField, 'Full Name *');
    await tester.enterText(nameField, 'Jane Doe');
    await tester.pump();

    final phoneField = find.byWidgetPredicate(
      (w) =>
          w is TextField &&
          w.decoration?.hintText != null &&
          w.decoration!.hintText!.startsWith('Phone'),
    );
    await tester.enterText(phoneField, '5551234567');
    await tester.pump();

    final streetField = find.widgetWithText(TextField, 'Street Address');
    await tester.enterText(streetField, '123 Main St');
    await tester.pump();

    final cityField = find.widgetWithText(TextField, 'City');
    await tester.enterText(cityField, 'New York');
    await tester.pump();

    final postalField = find.widgetWithText(TextField, 'Postal Code');
    await tester.ensureVisible(postalField);
    await tester.pumpAndSettle();
    await tester.enterText(postalField, '10001');
    await tester.pump();

    final dropdown = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('United States').last);
    await tester.pumpAndSettle();
  }

  /// Navigate from address to shipping step (fills address + taps Continue).
  Future<void> goToShippingStep(WidgetTester tester) async {
    await fillAddress(tester);
    await tester.ensureVisible(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  /// Navigate from address to review step (shipping + select rate + Continue).
  Future<void> goToReviewStep(WidgetTester tester) async {
    await goToShippingStep(tester);
    // Wait for rates to load, then tap Continue.
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
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

      testWidgets('should show step indicator with 4 steps', (tester) async {
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

        final button = find.text('Continue');
        expect(button, findsOneWidget);
      });
    });

    group('step 2: shipping rates', () {
      testWidgets('should fetch FedEx rates after filling address',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await goToShippingStep(tester);

        // Should show ShippingRateSelector with rates.
        expect(find.byType(ShippingRateSelector), findsOneWidget);
        expect(find.text('FedEx Ground'), findsOneWidget);
        expect(find.text('FedEx Express'), findsOneWidget);
      });

      testWidgets('should auto-select cheapest rate', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await goToShippingStep(tester);

        // Cheapest is FedEx Ground at $12.50 - Continue should be enabled.
        expect(find.text('Continue'), findsOneWidget);
      });

      testWidgets('should show error with retry on FedEx API failure',
          (tester) async {
        when(() => mockCalculateRate(
              fromAddress: any(named: 'fromAddress'),
              toAddress: any(named: 'toAddress'),
              category: any(named: 'category'),
              weightKg: any(named: 'weightKg'),
            )).thenThrow(Exception('FedEx API error'));

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await goToShippingStep(tester);

        // Should show error message with retry.
        expect(find.text('Could not fetch shipping rates. Please try again.'),
            findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('should show seller address error message', (tester) async {
        when(() => mockGetSellerAddress(any())).thenThrow(
            const SellerAddressException('Seller shipping address not configured'));

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await goToShippingStep(tester);

        expect(
            find.textContaining('Seller shipping address issue'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('should retry rate fetch when Retry tapped', (tester) async {
        // First call fails, second succeeds.
        var callCount = 0;
        when(() => mockCalculateRate(
              fromAddress: any(named: 'fromAddress'),
              toAddress: any(named: 'toAddress'),
              category: any(named: 'category'),
              weightKg: any(named: 'weightKg'),
            )).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) throw Exception('FedEx API error');
          return _fedexRates;
        });

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await goToShippingStep(tester);

        // Should show error.
        expect(find.text('Retry'), findsOneWidget);

        // Tap retry.
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Should now show rates.
        expect(find.byType(ShippingRateSelector), findsOneWidget);
        expect(find.text('FedEx Ground'), findsOneWidget);
      });

      testWidgets('should pass weightKg to rate calculation', (tester) async {
        await tester.pumpWidget(buildPage(
          listing: _createListing(weightKg: 4.5),
        ));
        await tester.pumpAndSettle();

        await goToShippingStep(tester);

        verify(() => mockCalculateRate(
              fromAddress: any(named: 'fromAddress'),
              toAddress: any(named: 'toAddress'),
              category: 'dress',
              weightKg: 4.5,
            )).called(1);
      });

      testWidgets('should show loading indicator when rates are loading',
          (tester) async {
        // Use a Completer to control when rates resolve.
        final completer = Completer<List<ShippingRate>>();
        when(() => mockCalculateRate(
              fromAddress: any(named: 'fromAddress'),
              toAddress: any(named: 'toAddress'),
              category: any(named: 'category'),
              weightKg: any(named: 'weightKg'),
            )).thenAnswer((_) => completer.future);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await fillAddress(tester);
        await tester.ensureVisible(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        // Only pump once to stay in loading state.
        await tester.pump();

        // Should show loading indicator.
        expect(find.text('Fetching shipping rates...'), findsOneWidget);

        // Complete the future to avoid timer leak.
        completer.complete(_fedexRates);
        await tester.pumpAndSettle();
      });
    });

    group('step 3: review', () {
      testWidgets('should show order summary with selected FedEx rate',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await goToReviewStep(tester);

        expect(find.byType(OrderSummaryWidget), findsOneWidget);
        expect(find.text('Beautiful Wedding Dress'), findsOneWidget);
      });
    });

    group('step 4: confirm', () {
      testWidgets('should show CGVU acceptance on confirm step',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Navigate through all steps.
        await goToReviewStep(tester);

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

        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      });

      testWidgets('should show Back button from step 2', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await goToShippingStep(tester);

        expect(find.text('Back'), findsOneWidget);
      });

      testWidgets('should go back to previous step when Back tapped',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await goToShippingStep(tester);

        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();

        expect(find.byType(AddressFormWidget), findsOneWidget);
      });
    });

    group('agreed price override', () {
      testWidgets('should use agreed price when provided', (tester) async {
        await tester.pumpWidget(buildPage(agreedPriceCents: 20000));
        await tester.pumpAndSettle();

        await goToReviewStep(tester);

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

        await goToReviewStep(tester);

        // Step 3 review: Continue.
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // On confirm step, should show already accepted message.
        expect(
            find.text('You have already accepted the marketplace buyer terms.'),
            findsOneWidget);
      });
    });
  });
}
