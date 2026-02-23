/// Tests for TransactionDetailPage.
///
/// Verifies loading state, transaction details display, generate label button
/// for paid transactions, shipping label widget when label URL exists,
/// error states with retry, and status-based UI changes.
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
import 'package:lynewed_beta/features/marketplace/domain/usecases/approve_refund_use_case.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/cancel_shipment_use_case.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/generate_shipping_label_use_case.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/reject_refund_use_case.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/transaction_detail_page.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/generate_label_button.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/shipping_label_widget.dart';

// -- Test helpers --

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
  String status = 'paid',
  String? fedexLabelUrl,
  String? fedexTrackingNumber,
}) {
  return MarketplaceTransaction(
    id: id,
    listingId: 'listing-1',
    sellerId: 'seller-1',
    buyerId: 'buyer-1',
    itemPriceCents: 29999,
    shippingCostCents: 1250,
    platformFeeCents: 3000,
    sellerPayoutCents: 26999,
    totalPaidCents: 31249,
    status: status,
    shippingFromAddress: _testAddress,
    shippingToAddress: _testAddress.copyWith(
      personName: 'John Buyer',
      streetLines: ['456 Oak Ave'],
      city: 'Los Angeles',
      postalCode: '90001',
      stateOrProvinceCode: 'CA',
    ),
    fedexLabelUrl: fedexLabelUrl,
    fedexTrackingNumber: fedexTrackingNumber,
    createdAt: DateTime(2025, 6, 1),
    updatedAt: DateTime(2025, 6, 1),
    paidAt: DateTime(2025, 6, 1),
  );
}

// -- Mock repository --

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

  @override
  Future<List<MarketplaceTransaction>> getTransactionsAwaitingShipment() async {
    return [];
  }
}

// -- Mock FedEx repository --

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
    double? weightKg,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<TrackingEvent>> getTrackingEvents(String transactionId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> cancelShipment(String transactionId) async {
    throw UnimplementedError();
  }
}

// -- Mock use case --

class _MockGenerateShippingLabelUseCase extends GenerateShippingLabelUseCase {
  _MockGenerateShippingLabelUseCase({this.result})
      : super(_MockFedExRepository());

  ShippingLabel? result;

  @override
  Future<ShippingLabel> call({
    required String transactionId,
    required String serviceType,
  }) async {
    return result!;
  }
}

class _MockCancelShipmentUseCase extends CancelShipmentUseCase {
  _MockCancelShipmentUseCase() : super(_MockFedExRepository());

  @override
  Future<void> call({required String transactionId}) async {}
}

class _MockApproveRefundUseCase extends ApproveRefundUseCase {
  _MockApproveRefundUseCase() : super(_MockTransactionRepository());

  @override
  Future<void> call({required String transactionId}) async {}
}

class _MockRejectRefundUseCase extends RejectRefundUseCase {
  _MockRejectRefundUseCase() : super(_MockTransactionRepository());

  @override
  Future<void> call({required String transactionId}) async {}
}

void main() {
  group('TransactionDetailPage', () {
    Widget buildPage({
      String transactionId = 'txn-1',
      _MockTransactionRepository? repository,
      GenerateShippingLabelUseCase? generateLabelUseCase,
      CancelShipmentUseCase? cancelShipmentUseCase,
    }) {
      return MaterialApp(
        home: TransactionDetailPage(
          transactionId: transactionId,
          transactionRepository: repository ??
              _MockTransactionRepository(
                transaction: _createTransaction(),
              ),
          generateLabelUseCase: generateLabelUseCase ??
              _MockGenerateShippingLabelUseCase(
                result: const ShippingLabel(
                  trackingNumber: '794644790138',
                  labelUrl: 'https://example.com/label.pdf',
                  serviceType: 'FEDEX_GROUND',
                ),
              ),
          cancelShipmentUseCase:
              cancelShipmentUseCase ?? _MockCancelShipmentUseCase(),
          approveRefundUseCase: _MockApproveRefundUseCase(),
          rejectRefundUseCase: _MockRejectRefundUseCase(),
        ),
      );
    }

    group('loading state', () {
      testWidgets('should show loading indicator initially', (tester) async {
        await tester.pumpWidget(buildPage());

        // On the first pump, the page is loading data.
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('transaction details', () {
      testWidgets('should show transaction details when loaded',
          (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Should show price breakdown info.
        expect(find.textContaining('\$299.99'), findsOneWidget);
        expect(find.textContaining('\$12.50'), findsOneWidget);
      });

      testWidgets('should show buyer shipping address', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.textContaining('John Buyer'), findsOneWidget);
        expect(find.textContaining('456 Oak Ave'), findsOneWidget);
        expect(find.textContaining('Los Angeles'), findsOneWidget);
      });

      testWidgets('should show transaction status badge', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Status should be displayed (paid).
        expect(find.textContaining('Paid'), findsWidgets);
      });
    });

    group('AC-1: generate label button for paid transactions', () {
      testWidgets(
          'should show generate label button when status is paid and no label',
          (tester) async {
        final repo = _MockTransactionRepository(
          transaction: _createTransaction(status: 'paid'),
        );

        await tester.pumpWidget(buildPage(repository: repo));
        await tester.pumpAndSettle();

        expect(find.byType(GenerateLabelButton), findsOneWidget);
        expect(find.text('Generate Shipping Label'), findsOneWidget);
      });

      testWidgets(
          'should not show generate label button when status is pending',
          (tester) async {
        final repo = _MockTransactionRepository(
          transaction: _createTransaction(status: 'pending'),
        );

        await tester.pumpWidget(buildPage(repository: repo));
        await tester.pumpAndSettle();

        expect(find.byType(GenerateLabelButton), findsNothing);
      });
    });

    group('AC-3 & AC-5: shipping label widget when label exists', () {
      testWidgets('should show shipping label widget when label URL exists',
          (tester) async {
        final repo = _MockTransactionRepository(
          transaction: _createTransaction(
            status: 'label_created',
            fedexLabelUrl: 'https://example.com/label.pdf',
            fedexTrackingNumber: '794644790138',
          ),
        );

        await tester.pumpWidget(buildPage(repository: repo));
        await tester.pumpAndSettle();

        expect(find.byType(ShippingLabelWidget), findsOneWidget);
        // Tracking number appears in both ShippingLabelWidget and tracking link section.
        expect(find.text('794644790138'), findsWidgets);
      });

      testWidgets(
          'should not show generate button when label already generated',
          (tester) async {
        final repo = _MockTransactionRepository(
          transaction: _createTransaction(
            status: 'label_created',
            fedexLabelUrl: 'https://example.com/label.pdf',
            fedexTrackingNumber: '794644790138',
          ),
        );

        await tester.pumpWidget(buildPage(repository: repo));
        await tester.pumpAndSettle();

        expect(find.byType(GenerateLabelButton), findsNothing);
        expect(find.text('Generate Shipping Label'), findsNothing);
      });

      testWidgets('should show View Label button when label exists',
          (tester) async {
        final repo = _MockTransactionRepository(
          transaction: _createTransaction(
            status: 'label_created',
            fedexLabelUrl: 'https://example.com/label.pdf',
            fedexTrackingNumber: '794644790138',
          ),
        );

        await tester.pumpWidget(buildPage(repository: repo));
        await tester.pumpAndSettle();

        expect(find.text('View Label'), findsOneWidget);
        expect(find.text('Download Label'), findsOneWidget);
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
        repo.transaction = _createTransaction();

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Should now show transaction data.
        expect(find.textContaining('\$299.99'), findsOneWidget);
      });
    });

    group('price breakdown', () {
      testWidgets('should show seller payout', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.textContaining('\$269.99'), findsOneWidget);
      });

      testWidgets('should show platform fee', (tester) async {
        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.textContaining('\$30.00'), findsOneWidget);
      });
    });

    group('S07: FedEx tracking link (seller)', () {
      testWidgets('should show tracking section when tracking number exists',
          (tester) async {
        final repo = _MockTransactionRepository(
          transaction: _createTransaction(
            status: 'label_created',
            fedexLabelUrl: 'https://example.com/label.pdf',
            fedexTrackingNumber: '794644790138',
          ),
        );

        await tester.pumpWidget(buildPage(repository: repo));
        await tester.pumpAndSettle();

        expect(find.text('Package Tracking'), findsOneWidget);
        expect(find.text('794644790138'), findsWidgets);
        expect(find.text('Track on FedEx'), findsOneWidget);
      });

      testWidgets('should hide tracking section when tracking number is null',
          (tester) async {
        final repo = _MockTransactionRepository(
          transaction: _createTransaction(
            status: 'label_created',
            fedexLabelUrl: 'https://example.com/label.pdf',
            fedexTrackingNumber: null,
          ),
        );

        await tester.pumpWidget(buildPage(repository: repo));
        await tester.pumpAndSettle();

        expect(find.text('Package Tracking'), findsNothing);
        expect(find.text('Track on FedEx'), findsNothing);
      });

      testWidgets('should hide tracking section for paid status without tracking',
          (tester) async {
        final repo = _MockTransactionRepository(
          transaction: _createTransaction(status: 'paid'),
        );

        await tester.pumpWidget(buildPage(repository: repo));
        await tester.pumpAndSettle();

        expect(find.text('Package Tracking'), findsNothing);
        expect(find.text('Track on FedEx'), findsNothing);
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
