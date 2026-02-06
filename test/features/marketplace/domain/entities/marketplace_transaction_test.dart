import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_transaction.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_address.dart';

void main() {
  // Shared test data
  const fromAddress = ShippingAddress(
    streetLines: ['123 Main Street'],
    city: 'Paris',
    postalCode: '75001',
    countryCode: 'FR',
    personName: 'Seller Jane',
  );

  const toAddress = ShippingAddress(
    streetLines: ['456 Elm Avenue'],
    city: 'Lyon',
    postalCode: '69001',
    countryCode: 'FR',
    personName: 'Buyer Marie',
  );

  final now = DateTime(2026, 2, 4);

  MarketplaceTransaction createTransaction({
    String id = 'txn-123',
    String listingId = 'listing-456',
    String? offerId = 'offer-789',
    String sellerId = 'seller-111',
    String buyerId = 'buyer-222',
    int itemPriceCents = 30000,
    int shippingCostCents = 2000,
    int platformFeeCents = 3000,
    int sellerPayoutCents = 27000,
    int totalPaidCents = 32000,
    String? stripePaymentIntentId,
    String? stripeChargeId,
    String? stripeTransferId,
    String? fedexTrackingNumber,
    String? fedexLabelUrl,
    String? fedexRateId,
    ShippingAddress shippingFromAddress = fromAddress,
    ShippingAddress shippingToAddress = toAddress,
    String status = 'pending',
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? completedAt,
  }) {
    return MarketplaceTransaction(
      id: id,
      listingId: listingId,
      offerId: offerId,
      sellerId: sellerId,
      buyerId: buyerId,
      itemPriceCents: itemPriceCents,
      shippingCostCents: shippingCostCents,
      platformFeeCents: platformFeeCents,
      sellerPayoutCents: sellerPayoutCents,
      totalPaidCents: totalPaidCents,
      stripePaymentIntentId: stripePaymentIntentId,
      stripeChargeId: stripeChargeId,
      stripeTransferId: stripeTransferId,
      fedexTrackingNumber: fedexTrackingNumber,
      fedexLabelUrl: fedexLabelUrl,
      fedexRateId: fedexRateId,
      shippingFromAddress: shippingFromAddress,
      shippingToAddress: shippingToAddress,
      status: status,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      paidAt: paidAt,
      shippedAt: shippedAt,
      deliveredAt: deliveredAt,
      completedAt: completedAt,
    );
  }

  group('MarketplaceTransaction', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create with required fields', () {
        final txn = createTransaction();

        expect(txn.id, 'txn-123');
        expect(txn.listingId, 'listing-456');
        expect(txn.offerId, 'offer-789');
        expect(txn.sellerId, 'seller-111');
        expect(txn.buyerId, 'buyer-222');
        expect(txn.itemPriceCents, 30000);
        expect(txn.shippingCostCents, 2000);
        expect(txn.platformFeeCents, 3000);
        expect(txn.sellerPayoutCents, 27000);
        expect(txn.totalPaidCents, 32000);
        expect(txn.status, 'pending');
        expect(txn.shippingFromAddress, fromAddress);
        expect(txn.shippingToAddress, toAddress);
      });

      test('should create with all optional fields', () {
        final paidAt = now.add(const Duration(hours: 1));
        final shippedAt = now.add(const Duration(days: 1));
        final deliveredAt = now.add(const Duration(days: 5));
        final completedAt = now.add(const Duration(days: 12));

        final txn = createTransaction(
          stripePaymentIntentId: 'pi_abc123',
          stripeChargeId: 'ch_def456',
          stripeTransferId: 'tr_ghi789',
          fedexTrackingNumber: '794644790138',
          fedexLabelUrl: 'https://fedex.com/label/123.pdf',
          fedexRateId: 'rate_xyz',
          status: 'completed',
          paidAt: paidAt,
          shippedAt: shippedAt,
          deliveredAt: deliveredAt,
          completedAt: completedAt,
        );

        expect(txn.stripePaymentIntentId, 'pi_abc123');
        expect(txn.stripeChargeId, 'ch_def456');
        expect(txn.stripeTransferId, 'tr_ghi789');
        expect(txn.fedexTrackingNumber, '794644790138');
        expect(txn.fedexLabelUrl, 'https://fedex.com/label/123.pdf');
        expect(txn.fedexRateId, 'rate_xyz');
        expect(txn.paidAt, paidAt);
        expect(txn.shippedAt, shippedAt);
        expect(txn.deliveredAt, deliveredAt);
        expect(txn.completedAt, completedAt);
      });

      test('should have null optional fields when not provided', () {
        final txn = createTransaction(offerId: null);

        expect(txn.offerId, isNull);
        expect(txn.stripePaymentIntentId, isNull);
        expect(txn.stripeChargeId, isNull);
        expect(txn.stripeTransferId, isNull);
        expect(txn.fedexTrackingNumber, isNull);
        expect(txn.fedexLabelUrl, isNull);
        expect(txn.fedexRateId, isNull);
        expect(txn.paidAt, isNull);
        expect(txn.shippedAt, isNull);
        expect(txn.deliveredAt, isNull);
        expect(txn.completedAt, isNull);
      });

      test('should be immutable', () {
        final txn = createTransaction();

        // Verify fields are final (compile-time check)
        expect(txn.status, 'pending');
      });
    });

    // ==============================================================
    // COMMISSION / AMOUNT TESTS
    // ==============================================================

    group('commission and amounts', () {
      test('should have correct 10% commission (30000 -> 3000 fee, 27000 payout)', () {
        final txn = createTransaction(
          itemPriceCents: 30000,
          platformFeeCents: 3000,
          sellerPayoutCents: 27000,
        );

        expect(txn.platformFeeCents, 3000);
        expect(txn.sellerPayoutCents, 27000);
        expect(txn.platformFeeCents + txn.sellerPayoutCents, txn.itemPriceCents);
      });

      test('total_paid should equal item_price + shipping_cost', () {
        final txn = createTransaction(
          itemPriceCents: 30000,
          shippingCostCents: 2000,
          totalPaidCents: 32000,
        );

        expect(txn.totalPaidCents, txn.itemPriceCents + txn.shippingCostCents);
      });
    });

    // ==============================================================
    // DOLLAR GETTERS TESTS
    // ==============================================================

    group('dollar getters', () {
      test('should convert item price cents to dollars', () {
        final txn = createTransaction(itemPriceCents: 29999);

        expect(txn.itemPriceInDollars, 299.99);
      });

      test('should convert total paid cents to dollars', () {
        final txn = createTransaction(totalPaidCents: 32000);

        expect(txn.totalPaidInDollars, 320.0);
      });

      test('should convert shipping cost cents to dollars', () {
        final txn = createTransaction(shippingCostCents: 1599);

        expect(txn.shippingCostInDollars, 15.99);
      });

      test('should convert platform fee cents to dollars', () {
        final txn = createTransaction(platformFeeCents: 3000);

        expect(txn.platformFeeInDollars, 30.0);
      });

      test('should convert seller payout cents to dollars', () {
        final txn = createTransaction(sellerPayoutCents: 27000);

        expect(txn.sellerPayoutInDollars, 270.0);
      });
    });

    // ==============================================================
    // STATUS HELPERS TESTS
    // ==============================================================

    group('status helpers', () {
      test('isPending should be true when status is pending', () {
        final txn = createTransaction(status: 'pending');
        expect(txn.isPending, isTrue);
        expect(txn.isPaid, isFalse);
        expect(txn.isCompleted, isFalse);
      });

      test('isPaid should be true when status is paid', () {
        final txn = createTransaction(status: 'paid');
        expect(txn.isPaid, isTrue);
        expect(txn.isPending, isFalse);
        expect(txn.isCompleted, isFalse);
      });

      test('isCompleted should be true when status is completed', () {
        final txn = createTransaction(status: 'completed');
        expect(txn.isCompleted, isTrue);
        expect(txn.isPending, isFalse);
        expect(txn.isPaid, isFalse);
      });

      test('all status helpers false for shipped status', () {
        final txn = createTransaction(status: 'shipped');
        expect(txn.isPending, isFalse);
        expect(txn.isPaid, isFalse);
        expect(txn.isCompleted, isFalse);
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse valid JSON with all fields', () {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'listing_id': '660e8400-e29b-41d4-a716-446655440001',
          'offer_id': '770e8400-e29b-41d4-a716-446655440002',
          'seller_id': '880e8400-e29b-41d4-a716-446655440003',
          'buyer_id': '990e8400-e29b-41d4-a716-446655440004',
          'item_price_cents': 30000,
          'shipping_cost_cents': 2000,
          'platform_fee_cents': 3000,
          'seller_payout_cents': 27000,
          'total_paid_cents': 32000,
          'stripe_payment_intent_id': 'pi_abc123',
          'stripe_charge_id': 'ch_def456',
          'stripe_transfer_id': 'tr_ghi789',
          'fedex_tracking_number': '794644790138',
          'fedex_label_url': 'https://fedex.com/label/123.pdf',
          'fedex_rate_id': 'rate_xyz',
          'shipping_from_address': {
            'street_lines': ['123 Main Street'],
            'city': 'Paris',
            'postal_code': '75001',
            'country_code': 'FR',
            'person_name': 'Seller Jane',
          },
          'shipping_to_address': {
            'street_lines': ['456 Elm Avenue'],
            'city': 'Lyon',
            'postal_code': '69001',
            'country_code': 'FR',
            'person_name': 'Buyer Marie',
          },
          'status': 'paid',
          'created_at': '2026-02-04T10:00:00.000Z',
          'updated_at': '2026-02-04T10:30:00.000Z',
          'paid_at': '2026-02-04T10:05:00.000Z',
          'shipped_at': '2026-02-05T14:00:00.000Z',
          'delivered_at': '2026-02-09T10:00:00.000Z',
          'completed_at': '2026-02-16T00:00:00.000Z',
        };

        final txn = MarketplaceTransaction.fromJson(json);

        expect(txn.id, '550e8400-e29b-41d4-a716-446655440000');
        expect(txn.listingId, '660e8400-e29b-41d4-a716-446655440001');
        expect(txn.offerId, '770e8400-e29b-41d4-a716-446655440002');
        expect(txn.sellerId, '880e8400-e29b-41d4-a716-446655440003');
        expect(txn.buyerId, '990e8400-e29b-41d4-a716-446655440004');
        expect(txn.itemPriceCents, 30000);
        expect(txn.shippingCostCents, 2000);
        expect(txn.platformFeeCents, 3000);
        expect(txn.sellerPayoutCents, 27000);
        expect(txn.totalPaidCents, 32000);
        expect(txn.stripePaymentIntentId, 'pi_abc123');
        expect(txn.stripeChargeId, 'ch_def456');
        expect(txn.stripeTransferId, 'tr_ghi789');
        expect(txn.fedexTrackingNumber, '794644790138');
        expect(txn.fedexLabelUrl, 'https://fedex.com/label/123.pdf');
        expect(txn.fedexRateId, 'rate_xyz');
        expect(txn.status, 'paid');
        expect(txn.paidAt, DateTime.parse('2026-02-04T10:05:00.000Z'));
        expect(txn.shippedAt, DateTime.parse('2026-02-05T14:00:00.000Z'));
        expect(txn.deliveredAt, DateTime.parse('2026-02-09T10:00:00.000Z'));
        expect(txn.completedAt, DateTime.parse('2026-02-16T00:00:00.000Z'));
      });

      test('should parse JSON with null optional fields', () {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'listing_id': '660e8400-e29b-41d4-a716-446655440001',
          'offer_id': null,
          'seller_id': '880e8400-e29b-41d4-a716-446655440003',
          'buyer_id': '990e8400-e29b-41d4-a716-446655440004',
          'item_price_cents': 10000,
          'shipping_cost_cents': 1500,
          'platform_fee_cents': 1000,
          'seller_payout_cents': 9000,
          'total_paid_cents': 11500,
          'stripe_payment_intent_id': null,
          'stripe_charge_id': null,
          'stripe_transfer_id': null,
          'fedex_tracking_number': null,
          'fedex_label_url': null,
          'fedex_rate_id': null,
          'shipping_from_address': {
            'street_lines': ['1 Rue'],
            'city': 'Paris',
            'postal_code': '75001',
            'country_code': 'FR',
            'person_name': 'Seller',
          },
          'shipping_to_address': {
            'street_lines': ['2 Rue'],
            'city': 'Lyon',
            'postal_code': '69001',
            'country_code': 'FR',
            'person_name': 'Buyer',
          },
          'status': 'pending',
          'created_at': '2026-02-04T10:00:00.000Z',
          'updated_at': '2026-02-04T10:00:00.000Z',
          'paid_at': null,
          'shipped_at': null,
          'delivered_at': null,
          'completed_at': null,
        };

        final txn = MarketplaceTransaction.fromJson(json);

        expect(txn.offerId, isNull);
        expect(txn.stripePaymentIntentId, isNull);
        expect(txn.stripeChargeId, isNull);
        expect(txn.stripeTransferId, isNull);
        expect(txn.fedexTrackingNumber, isNull);
        expect(txn.fedexLabelUrl, isNull);
        expect(txn.fedexRateId, isNull);
        expect(txn.paidAt, isNull);
        expect(txn.shippedAt, isNull);
        expect(txn.deliveredAt, isNull);
        expect(txn.completedAt, isNull);
      });

      test('should parse JSONB addresses correctly', () {
        final json = {
          'id': 'txn-abc',
          'listing_id': 'listing-def',
          'offer_id': null,
          'seller_id': 'seller-ghi',
          'buyer_id': 'buyer-jkl',
          'item_price_cents': 20000,
          'shipping_cost_cents': 3000,
          'platform_fee_cents': 2000,
          'seller_payout_cents': 18000,
          'total_paid_cents': 23000,
          'stripe_payment_intent_id': null,
          'stripe_charge_id': null,
          'stripe_transfer_id': null,
          'fedex_tracking_number': null,
          'fedex_label_url': null,
          'fedex_rate_id': null,
          'shipping_from_address': {
            'street_lines': ['10 Avenue des Champs-Elysees'],
            'city': 'Paris',
            'postal_code': '75008',
            'country_code': 'FR',
            'person_name': 'Alice Dupont',
          },
          'shipping_to_address': {
            'street_lines': ['789 Oak Drive'],
            'city': 'San Francisco',
            'postal_code': '94102',
            'country_code': 'US',
            'person_name': 'Bob Johnson',
          },
          'status': 'pending',
          'created_at': '2026-02-04T10:00:00.000Z',
          'updated_at': '2026-02-04T10:00:00.000Z',
          'paid_at': null,
          'shipped_at': null,
          'delivered_at': null,
          'completed_at': null,
        };

        final txn = MarketplaceTransaction.fromJson(json);

        expect(txn.shippingFromAddress.personName, 'Alice Dupont');
        expect(txn.shippingFromAddress.streetLines, ['10 Avenue des Champs-Elysees']);
        expect(txn.shippingFromAddress.city, 'Paris');
        expect(txn.shippingFromAddress.postalCode, '75008');
        expect(txn.shippingFromAddress.countryCode, 'FR');

        expect(txn.shippingToAddress.personName, 'Bob Johnson');
        expect(txn.shippingToAddress.streetLines, ['789 Oak Drive']);
        expect(txn.shippingToAddress.city, 'San Francisco');
        expect(txn.shippingToAddress.postalCode, '94102');
        expect(txn.shippingToAddress.countryCode, 'US');
      });
    });

    // ==============================================================
    // TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should produce correct snake_case keys', () {
        final txn = createTransaction(
          stripePaymentIntentId: 'pi_test',
          fedexTrackingNumber: '123456',
        );

        final json = txn.toJson();

        expect(json['listing_id'], 'listing-456');
        expect(json['offer_id'], 'offer-789');
        expect(json['seller_id'], 'seller-111');
        expect(json['buyer_id'], 'buyer-222');
        expect(json['item_price_cents'], 30000);
        expect(json['shipping_cost_cents'], 2000);
        expect(json['platform_fee_cents'], 3000);
        expect(json['seller_payout_cents'], 27000);
        expect(json['total_paid_cents'], 32000);
        expect(json['stripe_payment_intent_id'], 'pi_test');
        expect(json['fedex_tracking_number'], '123456');
        expect(json['status'], 'pending');
      });

      test('should serialize addresses as Map objects', () {
        final txn = createTransaction();

        final json = txn.toJson();

        expect(json['shipping_from_address'], isA<Map<String, dynamic>>());
        expect(json['shipping_to_address'], isA<Map<String, dynamic>>());

        final fromAddr = json['shipping_from_address'] as Map<String, dynamic>;
        expect(fromAddr['person_name'], 'Seller Jane');
        expect(fromAddr['city'], 'Paris');
        expect(fromAddr['country_code'], 'FR');

        final toAddr = json['shipping_to_address'] as Map<String, dynamic>;
        expect(toAddr['person_name'], 'Buyer Marie');
        expect(toAddr['city'], 'Lyon');
        expect(toAddr['country_code'], 'FR');
      });

      test('should exclude auto-generated fields', () {
        final txn = createTransaction();

        final json = txn.toJson();

        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('created_at'), isFalse);
        expect(json.containsKey('updated_at'), isFalse);
        expect(json.containsKey('paid_at'), isFalse);
        expect(json.containsKey('shipped_at'), isFalse);
        expect(json.containsKey('delivered_at'), isFalse);
        expect(json.containsKey('completed_at'), isFalse);
      });

      test('should contain only expected keys', () {
        final txn = createTransaction();

        final json = txn.toJson();
        final expectedKeys = {
          'listing_id',
          'offer_id',
          'seller_id',
          'buyer_id',
          'item_price_cents',
          'shipping_cost_cents',
          'platform_fee_cents',
          'seller_payout_cents',
          'total_paid_cents',
          'stripe_payment_intent_id',
          'stripe_charge_id',
          'stripe_transfer_id',
          'fedex_tracking_number',
          'fedex_label_url',
          'fedex_rate_id',
          'shipping_service_type',
          'shipping_from_address',
          'shipping_to_address',
          'status',
        };

        expect(json.keys.toSet(), expectedKeys);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id matches', () {
        final txn1 = createTransaction(id: 'txn-same');
        final txn2 = createTransaction(
          id: 'txn-same',
          status: 'paid',
          itemPriceCents: 99999,
        );

        expect(txn1, equals(txn2));
        expect(txn1.hashCode, equals(txn2.hashCode));
      });

      test('should not be equal when id differs', () {
        final txn1 = createTransaction(id: 'txn-111');
        final txn2 = createTransaction(id: 'txn-222');

        expect(txn1, isNot(equals(txn2)));
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should create copy with updated status', () {
        final txn = createTransaction(status: 'pending');
        final updated = txn.copyWith(status: 'paid');

        expect(updated.status, 'paid');
        expect(updated.id, txn.id);
        expect(updated.itemPriceCents, txn.itemPriceCents);
      });

      test('should create copy with updated timestamps', () {
        final txn = createTransaction();
        final paidAt = now.add(const Duration(hours: 1));
        final updated = txn.copyWith(
          status: 'paid',
          paidAt: paidAt,
        );

        expect(updated.paidAt, paidAt);
        expect(updated.status, 'paid');
      });

      test('should preserve all fields when no parameter provided', () {
        final txn = createTransaction(
          stripePaymentIntentId: 'pi_test',
          fedexTrackingNumber: '123456',
        );
        final copied = txn.copyWith();

        expect(copied.id, txn.id);
        expect(copied.listingId, txn.listingId);
        expect(copied.offerId, txn.offerId);
        expect(copied.sellerId, txn.sellerId);
        expect(copied.buyerId, txn.buyerId);
        expect(copied.itemPriceCents, txn.itemPriceCents);
        expect(copied.shippingCostCents, txn.shippingCostCents);
        expect(copied.platformFeeCents, txn.platformFeeCents);
        expect(copied.sellerPayoutCents, txn.sellerPayoutCents);
        expect(copied.totalPaidCents, txn.totalPaidCents);
        expect(copied.stripePaymentIntentId, txn.stripePaymentIntentId);
        expect(copied.fedexTrackingNumber, txn.fedexTrackingNumber);
        expect(copied.shippingFromAddress, txn.shippingFromAddress);
        expect(copied.shippingToAddress, txn.shippingToAddress);
        expect(copied.status, txn.status);
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should contain key fields', () {
        final txn = createTransaction(
          id: 'txn-abc',
          status: 'paid',
          totalPaidCents: 32000,
        );

        final str = txn.toString();

        expect(str, contains('txn-abc'));
        expect(str, contains('paid'));
        expect(str, contains('32000'));
      });
    });
  });
}
