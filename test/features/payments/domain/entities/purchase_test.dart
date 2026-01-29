import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/payments/domain/entities/product_type.dart';
import 'package:lynewed_beta/features/payments/domain/entities/purchase.dart';
import 'package:lynewed_beta/features/payments/domain/entities/purchase_status.dart';

void main() {
  group('Purchase', () {
    final testJson = {
      'id': 'purchase-123',
      'user_id': 'user-123',
      'product_type': 'marketplace_item',
      'product_id': 'item-456',
      'seller_id': 'seller-789',
      'amount_cents': 10000,
      'currency': 'USD',
      'platform_fee_cents': 1000,
      'seller_amount_cents': 9000,
      'shipping_cents': 500,
      'stripe_payment_intent_id': 'pi_123',
      'stripe_checkout_session_id': 'cs_123',
      'stripe_transfer_id': 'tr_123',
      'stripe_charge_id': 'ch_123',
      'status': 'succeeded',
      'metadata': {'order_note': 'Gift wrap please'},
      'error_message': null,
      'error_code': null,
      'created_at': '2024-01-15T10:30:00Z',
      'updated_at': '2024-01-15T10:35:00Z',
      'paid_at': '2024-01-15T10:35:00Z',
      'refunded_at': null,
      'disputed_at': null,
    };

    group('fromJson', () {
      test('should create Purchase from valid JSON', () {
        final purchase = Purchase.fromJson(testJson);

        expect(purchase.id, 'purchase-123');
        expect(purchase.userId, 'user-123');
        expect(purchase.productType, ProductType.marketplaceItem);
        expect(purchase.productId, 'item-456');
        expect(purchase.sellerId, 'seller-789');
        expect(purchase.amountCents, 10000);
        expect(purchase.currency, 'USD');
        expect(purchase.platformFeeCents, 1000);
        expect(purchase.sellerAmountCents, 9000);
        expect(purchase.shippingCents, 500);
        expect(purchase.stripePaymentIntentId, 'pi_123');
        expect(purchase.stripeCheckoutSessionId, 'cs_123');
        expect(purchase.stripeTransferId, 'tr_123');
        expect(purchase.stripeChargeId, 'ch_123');
        expect(purchase.status, PurchaseStatus.succeeded);
        expect(purchase.metadata, {'order_note': 'Gift wrap please'});
        expect(purchase.errorMessage, isNull);
        expect(purchase.errorCode, isNull);
        expect(purchase.createdAt, DateTime.utc(2024, 1, 15, 10, 30));
        expect(purchase.updatedAt, DateTime.utc(2024, 1, 15, 10, 35));
        expect(purchase.paidAt, DateTime.utc(2024, 1, 15, 10, 35));
        expect(purchase.refundedAt, isNull);
        expect(purchase.disputedAt, isNull);
      });

      test('should handle minimal required fields', () {
        final minimalJson = {
          'id': 'purchase-123',
          'user_id': 'user-123',
          'product_type': 'magazine',
          'amount_cents': 999,
          'created_at': '2024-01-15T10:30:00Z',
          'updated_at': '2024-01-15T10:30:00Z',
        };

        final purchase = Purchase.fromJson(minimalJson);

        expect(purchase.id, 'purchase-123');
        expect(purchase.productType, ProductType.magazine);
        expect(purchase.sellerId, isNull);
        expect(purchase.currency, 'USD');
        expect(purchase.platformFeeCents, 0);
        expect(purchase.shippingCents, 0);
        expect(purchase.status, PurchaseStatus.pending);
        expect(purchase.metadata, isEmpty);
      });

      test('should parse all product types', () {
        for (final type in ['magazine', 'album', 'print', 'subscription']) {
          final json = {...testJson, 'product_type': type};
          final purchase = Purchase.fromJson(json);
          expect(purchase.productType, ProductType.fromString(type));
        }
      });

      test('should parse all statuses', () {
        for (final status in [
          'pending',
          'processing',
          'requires_action',
          'failed',
          'canceled',
          'refunded',
          'partially_refunded',
          'disputed'
        ]) {
          final json = {...testJson, 'status': status};
          final purchase = Purchase.fromJson(json);
          expect(purchase.status, PurchaseStatus.fromString(status));
        }
      });

      test('should parse refunded_at and disputed_at dates', () {
        final json = {
          ...testJson,
          'status': 'refunded',
          'refunded_at': '2024-01-20T12:00:00Z',
        };
        final purchase = Purchase.fromJson(json);
        expect(purchase.refundedAt, DateTime.utc(2024, 1, 20, 12, 0));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = Purchase.fromJson(testJson);
        final updated = original.copyWith(
          status: PurchaseStatus.refunded,
          refundedAt: DateTime.utc(2024, 1, 20, 12, 0),
        );

        expect(updated.id, original.id);
        expect(updated.status, PurchaseStatus.refunded);
        expect(updated.refundedAt, DateTime.utc(2024, 1, 20, 12, 0));
        expect(original.status, PurchaseStatus.succeeded);
        expect(original.refundedAt, isNull);
      });

      test('should preserve all fields when no updates provided', () {
        final original = Purchase.fromJson(testJson);
        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('computed properties', () {
      test('amountInCurrency should convert cents to currency', () {
        final purchase = Purchase.fromJson(testJson);
        expect(purchase.amountInCurrency, 100.0);
      });

      test('platformFeeInCurrency should convert cents to currency', () {
        final purchase = Purchase.fromJson(testJson);
        expect(purchase.platformFeeInCurrency, 10.0);
      });

      test('sellerAmountInCurrency should convert cents to currency', () {
        final purchase = Purchase.fromJson(testJson);
        expect(purchase.sellerAmountInCurrency, 90.0);
      });

      test('sellerAmountInCurrency should return null when no seller amount',
          () {
        final json = {...testJson, 'seller_amount_cents': null};
        final purchase = Purchase.fromJson(json);
        expect(purchase.sellerAmountInCurrency, isNull);
      });

      test('shippingInCurrency should convert cents to currency', () {
        final purchase = Purchase.fromJson(testJson);
        expect(purchase.shippingInCurrency, 5.0);
      });
    });

    group('isMarketplace', () {
      test('should return true when seller_id is present', () {
        final purchase = Purchase.fromJson(testJson);
        expect(purchase.isMarketplace, true);
      });

      test('should return false when seller_id is null', () {
        final json = {...testJson, 'seller_id': null};
        final purchase = Purchase.fromJson(json);
        expect(purchase.isMarketplace, false);
      });
    });

    group('isPaid', () {
      test('should return true when status is succeeded', () {
        final purchase = Purchase.fromJson(testJson);
        expect(purchase.isPaid, true);
      });

      test('should return false when status is not succeeded', () {
        final json = {...testJson, 'status': 'pending'};
        final purchase = Purchase.fromJson(json);
        expect(purchase.isPaid, false);
      });
    });

    group('hasFailed', () {
      test('should return true when status is failed', () {
        final json = {...testJson, 'status': 'failed'};
        final purchase = Purchase.fromJson(json);
        expect(purchase.hasFailed, true);
      });

      test('should return false when status is not failed', () {
        final purchase = Purchase.fromJson(testJson);
        expect(purchase.hasFailed, false);
      });
    });

    group('isRefunded', () {
      test('should return true when status is refunded', () {
        final json = {...testJson, 'status': 'refunded'};
        final purchase = Purchase.fromJson(json);
        expect(purchase.isRefunded, true);
      });

      test('should return true when status is partially_refunded', () {
        final json = {...testJson, 'status': 'partially_refunded'};
        final purchase = Purchase.fromJson(json);
        expect(purchase.isRefunded, true);
      });

      test('should return false for other statuses', () {
        final purchase = Purchase.fromJson(testJson);
        expect(purchase.isRefunded, false);
      });
    });

    group('equality', () {
      test('should be equal for same values', () {
        final purchase1 = Purchase.fromJson(testJson);
        final purchase2 = Purchase.fromJson(testJson);
        expect(purchase1, equals(purchase2));
      });

      test('should not be equal for different values', () {
        final purchase1 = Purchase.fromJson(testJson);
        final purchase2 =
            Purchase.fromJson({...testJson, 'id': 'purchase-456'});
        expect(purchase1, isNot(equals(purchase2)));
      });
    });
  });
}
