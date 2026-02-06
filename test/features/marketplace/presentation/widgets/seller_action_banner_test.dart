/// Tests for SellerActionBanner widget.
///
/// Verifies loading behavior, empty state, display with transactions,
/// tap callback, and singular/plural text.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_transaction.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_address.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_transaction_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/seller_action_banner.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock
    implements MarketplaceTransactionRepository {}

const _testAddress = ShippingAddress(
  streetLines: ['123 Main St'],
  city: 'Paris',
  postalCode: '75001',
  countryCode: 'FR',
);

MarketplaceTransaction _createTransaction({String id = 'tx-1'}) {
  return MarketplaceTransaction(
    id: id,
    listingId: 'listing-1',
    buyerId: 'buyer-1',
    sellerId: 'seller-1',
    itemPriceCents: 29999,
    shippingCostCents: 1500,
    platformFeeCents: 3000,
    sellerPayoutCents: 28499,
    totalPaidCents: 31499,
    shippingFromAddress: _testAddress,
    shippingToAddress: _testAddress,
    status: 'paid',
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );
}

void main() {
  late MockTransactionRepository mockRepo;

  setUp(() {
    mockRepo = MockTransactionRepository();
  });

  Widget buildWidget({
    void Function(List<MarketplaceTransaction>)? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SellerActionBanner(
          repository: mockRepo,
          onTap: onTap,
        ),
      ),
    );
  }

  group('SellerActionBanner', () {
    testWidgets('should render nothing when no transactions awaiting shipment',
        (tester) async {
      when(() => mockRepo.getTransactionsAwaitingShipment())
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // SizedBox.shrink = nothing visible.
      expect(find.byType(GestureDetector), findsNothing);
      expect(find.byIcon(Icons.local_shipping_outlined), findsNothing);
    });

    testWidgets('should render nothing on error', (tester) async {
      when(() => mockRepo.getTransactionsAwaitingShipment())
          .thenThrow(Exception('Not authenticated'));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_shipping_outlined), findsNothing);
    });

    testWidgets('should show singular text for 1 transaction', (tester) async {
      when(() => mockRepo.getTransactionsAwaitingShipment())
          .thenAnswer((_) async => [_createTransaction()]);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('You sold an item — generate shipping label to send it'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    });

    testWidgets('should show plural text for multiple transactions',
        (tester) async {
      when(() => mockRepo.getTransactionsAwaitingShipment())
          .thenAnswer((_) async => [
                _createTransaction(id: 'tx-1'),
                _createTransaction(id: 'tx-2'),
                _createTransaction(id: 'tx-3'),
              ]);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.text(
            'You sold 3 items — generate shipping labels to send them'),
        findsOneWidget,
      );
    });

    testWidgets('should call onTap with transactions when tapped',
        (tester) async {
      final transactions = [_createTransaction()];
      when(() => mockRepo.getTransactionsAwaitingShipment())
          .thenAnswer((_) async => transactions);

      List<MarketplaceTransaction>? tappedTransactions;
      await tester.pumpWidget(buildWidget(
        onTap: (txs) => tappedTransactions = txs,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(tappedTransactions, isNotNull);
      expect(tappedTransactions!.length, 1);
      expect(tappedTransactions!.first.id, 'tx-1');
    });

    testWidgets('should show shipping icon and arrow', (tester) async {
      when(() => mockRepo.getTransactionsAwaitingShipment())
          .thenAnswer((_) async => [_createTransaction()]);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });
  });
}
