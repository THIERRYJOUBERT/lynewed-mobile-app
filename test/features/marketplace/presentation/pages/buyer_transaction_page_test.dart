/// Tests for BuyerTransactionPage.
///
/// Verifies loading state, transaction details display, tracking timeline
/// when tracking number exists, price summary with buyer perspective,
/// shipping address section, status badge, error and retry states.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_transaction.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_address.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_label.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_rate.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/tracking_event.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/fedex_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_transaction_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/get_tracking_events_use_case.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/request_refund_use_case.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/buyer_transaction_page.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/buyer_tracking_timeline.dart';

// -- Test data --

const _testBuyerAddress = ShippingAddress(
  streetLines: ['456 Oak Ave'],
  city: 'Los Angeles',
  postalCode: '90001',
  countryCode: 'US',
  stateOrProvinceCode: 'CA',
  personName: 'Jane Buyer',
);

const _testSellerAddress = ShippingAddress(
  streetLines: ['123 Main St'],
  city: 'New York',
  postalCode: '10001',
  countryCode: 'US',
  stateOrProvinceCode: 'NY',
  personName: 'Seller Store',
);

MarketplaceTransaction _createTransaction({
  String id = 'txn-buyer-1',
  String status = 'shipped',
  String? fedexTrackingNumber,
  String? fedexLabelUrl,
}) {
  return MarketplaceTransaction(
    id: id,
    listingId: 'listing-1',
    sellerId: 'seller-1',
    buyerId: 'buyer-1',
    itemPriceCents: 15000,
    shippingCostCents: 850,
    platformFeeCents: 1500,
    sellerPayoutCents: 13500,
    totalPaidCents: 15850,
    status: status,
    shippingFromAddress: _testSellerAddress,
    shippingToAddress: _testBuyerAddress,
    fedexTrackingNumber: fedexTrackingNumber,
    fedexLabelUrl: fedexLabelUrl,
    createdAt: DateTime(2026, 2, 1),
    updatedAt: DateTime(2026, 2, 3),
    paidAt: DateTime(2026, 2, 1),
    shippedAt: status == 'shipped' ? DateTime(2026, 2, 2) : null,
  );
}

// -- Mocks --

class _MockTransactionRepository implements MarketplaceTransactionRepository {
  _MockTransactionRepository({
    this.transaction,
    this.error,
  });

  MarketplaceTransaction? transaction;
  Object? error;

  @override
  Future<MarketplaceTransaction?> getTransaction(String transactionId) async {
    if (error != null) throw error!;
    return transaction;
  }

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
  Future<List<MarketplaceTransaction>> getMyPurchases() async {
    throw UnimplementedError();
  }

  @override
  Future<List<MarketplaceTransaction>> getMySales() async {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasAcceptedBuyerCgvu() async {
    throw UnimplementedError();
  }

  @override
  Future<void> acceptBuyerCgvu() async {
    throw UnimplementedError();
  }

  @override
  Future<void> requestRefund({required String transactionId, String? reason}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> approveRefund({required String transactionId}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> rejectRefund({required String transactionId}) async {
    throw UnimplementedError();
  }
}

class _MockFedExRepository implements FedExRepository {
  @override
  Future<ShippingLabel> createShipment({
    required String transactionId,
    required String serviceType,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<ShippingRate>> calculateRates({
    required ShippingAddress fromAddress,
    required ShippingAddress toAddress,
    required String category,
  }) async {
    return [];
  }

  @override
  Future<List<TrackingEvent>> getTrackingEvents(String transactionId) async {
    return [];
  }

  @override
  Future<void> cancelShipment(String transactionId) async {
    throw UnimplementedError();
  }
}

class _MockRequestRefundUseCase extends RequestRefundUseCase {
  _MockRequestRefundUseCase() : super(_MockTransactionRepository());

  @override
  Future<void> call({required String transactionId, String? reason}) async {}
}

class _MockGetTrackingEventsUseCase extends GetTrackingEventsUseCase {
  _MockGetTrackingEventsUseCase({
    this.eventsToReturn = const [],
  }) : super(_MockFedExRepository());

  List<TrackingEvent> eventsToReturn;

  @override
  Future<List<TrackingEvent>> call(String transactionId) async {
    return eventsToReturn;
  }
}

void main() {
  group('BuyerTransactionPage', () {
    Widget buildPage({
      String transactionId = 'txn-buyer-1',
      _MockTransactionRepository? repository,
      _MockGetTrackingEventsUseCase? trackingUseCase,
    }) {
      return MaterialApp(
        home: BuyerTransactionPage(
          transactionId: transactionId,
          transactionRepository: repository ??
              _MockTransactionRepository(
                transaction: _createTransaction(
                  fedexTrackingNumber: '794644790138',
                  fedexLabelUrl: 'https://example.com/label.pdf',
                ),
              ),
          getTrackingEventsUseCase: trackingUseCase ??
              _MockGetTrackingEventsUseCase(
                eventsToReturn: [
                  TrackingEvent(
                    eventType: 'shipped',
                    description: 'Package shipped',
                    timestamp: DateTime(2026, 2, 2, 14, 0),
                    location: 'New York, NY',
                  ),
                ],
              ),
          requestRefundUseCase: _MockRequestRefundUseCase(),
        ),
      );
    }

    group('loading state', () {
      testWidgets('should show loading indicator initially', (tester) async {
        await tester.pumpWidget(buildPage());

        // On first pump, the page is loading data.
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('transaction details', () {
      testWidgets('should show transaction details when loaded',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Should show the header title.
        expect(find.text('Order Details'), findsOneWidget);
      });

      testWidgets('should show status badge', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Should show the status text for 'shipped'.
        expect(find.text('Shipped'), findsAtLeast(1));
      });
    });

    group('AC-1: tracking timeline with all status steps', () {
      testWidgets(
          'should show tracking timeline when tracking number exists',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(BuyerTrackingTimeline), findsOneWidget);
      });

      testWidgets('should show all step labels in timeline', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Order Placed'), findsOneWidget);
        expect(find.text('Payment Confirmed'), findsOneWidget);
        expect(find.text('Label Created'), findsOneWidget);
        expect(find.text('Shipped'), findsAtLeast(1));
        expect(find.text('In Transit'), findsOneWidget);
        expect(find.text('Delivered'), findsOneWidget);
        expect(find.text('Completed'), findsAtLeast(1));
      });

      testWidgets(
          'should not show tracking timeline when no tracking number',
          (tester) async {
        final repo = _MockTransactionRepository(
          transaction: _createTransaction(status: 'paid'),
        );

        await tester.pumpWidget(buildPage(repository: repo));
        await tester.pumpAndSettle();

        // No tracking number means no timeline.
        expect(find.byType(BuyerTrackingTimeline), findsNothing);
      });
    });

    group('AC-2: tracking events from FedEx', () {
      testWidgets('should pass tracking events to timeline', (tester) async {
        final trackingUseCase = _MockGetTrackingEventsUseCase(
          eventsToReturn: [
            TrackingEvent(
              eventType: 'shipped',
              description: 'Package shipped',
              timestamp: DateTime(2026, 2, 2, 14, 0),
              location: 'New York, NY',
            ),
          ],
        );

        await tester.pumpWidget(buildPage(trackingUseCase: trackingUseCase));
        await tester.pumpAndSettle();

        // The timeline should show the event location.
        expect(find.text('New York, NY'), findsOneWidget);
      });
    });

    group('AC-3: tracking number opens FedEx', () {
      testWidgets('should display tracking number', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('794644790138'), findsOneWidget);
      });

      testWidgets('should show Track on FedEx link', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Track on FedEx'), findsOneWidget);
      });
    });

    group('AC-4: completed status display', () {
      testWidgets('should show completed status in badge', (tester) async {
        final repo = _MockTransactionRepository(
          transaction: _createTransaction(
            status: 'completed',
            fedexTrackingNumber: '794644790138',
            fedexLabelUrl: 'https://example.com/label.pdf',
          ),
        );

        await tester.pumpWidget(buildPage(repository: repo));
        await tester.pumpAndSettle();

        // Should show 'Completed' at least in the status badge.
        expect(find.text('Completed'), findsAtLeast(1));
      });
    });

    group('shipping address', () {
      testWidgets('should show delivery address', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Jane Buyer'), findsOneWidget);
        expect(find.text('456 Oak Ave'), findsOneWidget);
      });
    });

    group('price summary', () {
      testWidgets('should show item price', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Item price: 15000 cents = $150.00
        expect(find.text('\$150.00'), findsOneWidget);
      });

      testWidgets('should show shipping cost', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Shipping: 850 cents = $8.50
        expect(find.text('\$8.50'), findsOneWidget);
      });

      testWidgets('should show total paid', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Total paid: 15850 cents = $158.50
        expect(find.text('\$158.50'), findsOneWidget);
      });

      testWidgets('should not show platform fee or seller payout',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Buyer should NOT see platform fee or seller payout.
        expect(find.text('Platform Fee'), findsNothing);
        expect(find.text('Your Payout'), findsNothing);
      });
    });

    group('error state', () {
      testWidgets('should show error state on load failure', (tester) async {
        final repo = _MockTransactionRepository(
          error: Exception('Network error'),
        );

        await tester.pumpWidget(buildPage(repository: repo));
        await tester.pumpAndSettle();

        expect(find.textContaining('Network error'), findsOneWidget);
      });

      testWidgets('should show retry button on error', (tester) async {
        final repo = _MockTransactionRepository(
          error: Exception('Connection timeout'),
        );

        await tester.pumpWidget(buildPage(repository: repo));
        await tester.pumpAndSettle();

        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('should retry loading on retry button tap', (tester) async {
        final repo = _MockTransactionRepository(
          error: Exception('Temp error'),
        );

        await tester.pumpWidget(buildPage(repository: repo));
        await tester.pumpAndSettle();

        // Fix the repo to return data.
        repo.error = null;
        repo.transaction = _createTransaction(
          fedexTrackingNumber: '794644790138',
          fedexLabelUrl: 'https://example.com/label.pdf',
        );

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Should now show transaction data.
        expect(find.text('Order Details'), findsOneWidget);
      });
    });

    group('navigation', () {
      testWidgets('should have back button', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      });
    });
  });
}
