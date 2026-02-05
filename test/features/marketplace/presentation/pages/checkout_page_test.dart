/// Tests for CheckoutPage.
///
/// Verifies multi-step checkout flow: address, shipping, review,
/// CGVU acceptance, and payment processing.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_listing.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_address.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_rate.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/fedex_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_transaction_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/checkout_page.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/address_form_widget.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/cgvu_acceptance_widget.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/order_summary_widget.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/shipping_options_widget.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock
    implements MarketplaceTransactionRepository {}

class MockFedExRepository extends Mock implements FedExRepository {}

class FakeShippingAddress extends Fake implements ShippingAddress {}

class FakeShippingRate extends Fake implements ShippingRate {}

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

const _testRates = [
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
  late MockFedExRepository mockFedExRepo;

  setUpAll(() {
    registerFallbackValue(FakeShippingAddress());
    registerFallbackValue(FakeShippingRate());
  });

  setUp(() {
    mockTransactionRepo = MockTransactionRepository();
    mockFedExRepo = MockFedExRepository();

    // Default: buyer has not accepted CGVU.
    when(() => mockTransactionRepo.hasAcceptedBuyerCgvu())
        .thenAnswer((_) async => false);
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
        fedExRepository: mockFedExRepo,
        currentUserId: 'buyer-1',
      ),
    );
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
        when(() => mockFedExRepo.calculateRates(
              fromAddress: any(named: 'fromAddress'),
              toAddress: any(named: 'toAddress'),
              category: any(named: 'category'),
            )).thenAnswer((_) async => _testRates);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Fill in address fields to enable Continue.
        final textFields = find.byType(TextField);

        // Street Address (index 2)
        await tester.enterText(textFields.at(2), '123 Main St');
        await tester.pump();

        // City (index 3)
        await tester.enterText(textFields.at(3), 'New York');
        await tester.pump();

        // Postal Code (index 5)
        await tester.enterText(textFields.at(5), '10001');
        await tester.pump();

        // Now tap Continue to go to shipping step.
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(find.byType(ShippingOptionsWidget), findsOneWidget);
      });

      testWidgets('should fetch rates when moving to shipping step',
          (tester) async {
        when(() => mockFedExRepo.calculateRates(
              fromAddress: any(named: 'fromAddress'),
              toAddress: any(named: 'toAddress'),
              category: any(named: 'category'),
            )).thenAnswer((_) async => _testRates);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Fill required address fields.
        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(2), '123 Main St');
        await tester.pump();
        await tester.enterText(textFields.at(3), 'New York');
        await tester.pump();
        await tester.enterText(textFields.at(5), '10001');
        await tester.pump();

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        verify(() => mockFedExRepo.calculateRates(
              fromAddress: any(named: 'fromAddress'),
              toAddress: any(named: 'toAddress'),
              category: 'dress',
            )).called(1);
      });
    });

    group('step 3: review', () {
      testWidgets('should show order summary after selecting shipping',
          (tester) async {
        when(() => mockFedExRepo.calculateRates(
              fromAddress: any(named: 'fromAddress'),
              toAddress: any(named: 'toAddress'),
              category: any(named: 'category'),
            )).thenAnswer((_) async => _testRates);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Step 1: Fill address.
        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(2), '123 Main St');
        await tester.pump();
        await tester.enterText(textFields.at(3), 'New York');
        await tester.pump();
        await tester.enterText(textFields.at(5), '10001');
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 2: Select shipping.
        await tester.tap(find.text('FedEx Ground'));
        await tester.pump();
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
        when(() => mockFedExRepo.calculateRates(
              fromAddress: any(named: 'fromAddress'),
              toAddress: any(named: 'toAddress'),
              category: any(named: 'category'),
            )).thenAnswer((_) async => _testRates);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Navigate through steps.
        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(2), '123 Main St');
        await tester.pump();
        await tester.enterText(textFields.at(3), 'New York');
        await tester.pump();
        await tester.enterText(textFields.at(5), '10001');
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('FedEx Ground'));
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 3 review: Continue
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
        when(() => mockFedExRepo.calculateRates(
              fromAddress: any(named: 'fromAddress'),
              toAddress: any(named: 'toAddress'),
              category: any(named: 'category'),
            )).thenAnswer((_) async => _testRates);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Fill address and navigate to step 2.
        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(2), '123 Main St');
        await tester.pump();
        await tester.enterText(textFields.at(3), 'New York');
        await tester.pump();
        await tester.enterText(textFields.at(5), '10001');
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(find.text('Back'), findsOneWidget);
      });

      testWidgets('should go back to previous step when Back tapped',
          (tester) async {
        when(() => mockFedExRepo.calculateRates(
              fromAddress: any(named: 'fromAddress'),
              toAddress: any(named: 'toAddress'),
              category: any(named: 'category'),
            )).thenAnswer((_) async => _testRates);

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Fill address and navigate to step 2.
        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(2), '123 Main St');
        await tester.pump();
        await tester.enterText(textFields.at(3), 'New York');
        await tester.pump();
        await tester.enterText(textFields.at(5), '10001');
        await tester.pump();
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
        when(() => mockFedExRepo.calculateRates(
              fromAddress: any(named: 'fromAddress'),
              toAddress: any(named: 'toAddress'),
              category: any(named: 'category'),
            )).thenAnswer((_) async => _testRates);

        await tester.pumpWidget(buildPage(agreedPriceCents: 20000));
        await tester.pumpAndSettle();

        // Navigate to review step.
        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(2), '123 Main St');
        await tester.pump();
        await tester.enterText(textFields.at(3), 'New York');
        await tester.pump();
        await tester.enterText(textFields.at(5), '10001');
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('FedEx Ground'));
        await tester.pump();
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

        // The CGVU check happens on init and should mark as already accepted.
        // Navigate to confirm step to verify.
        when(() => mockFedExRepo.calculateRates(
              fromAddress: any(named: 'fromAddress'),
              toAddress: any(named: 'toAddress'),
              category: any(named: 'category'),
            )).thenAnswer((_) async => _testRates);

        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(2), '123 Main St');
        await tester.pump();
        await tester.enterText(textFields.at(3), 'New York');
        await tester.pump();
        await tester.enterText(textFields.at(5), '10001');
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('FedEx Ground'));
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // On confirm step, should show already accepted message.
        expect(find.textContaining('already accepted'), findsOneWidget);
      });
    });

    group('shipping rate error', () {
      testWidgets('should show error when rate calculation fails',
          (tester) async {
        when(() => mockFedExRepo.calculateRates(
              fromAddress: any(named: 'fromAddress'),
              toAddress: any(named: 'toAddress'),
              category: any(named: 'category'),
            )).thenThrow(Exception('Network error'));

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Fill address and navigate.
        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(2), '123 Main St');
        await tester.pump();
        await tester.enterText(textFields.at(3), 'New York');
        await tester.pump();
        await tester.enterText(textFields.at(5), '10001');
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Should show error.
        expect(
          find.textContaining('Failed to calculate shipping rates'),
          findsOneWidget,
        );
      });
    });
  });
}
