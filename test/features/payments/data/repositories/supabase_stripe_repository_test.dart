import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/payments/data/repositories/supabase_stripe_repository.dart';
import 'package:lynewed_beta/features/payments/domain/entities/product_type.dart';
import 'package:lynewed_beta/features/payments/domain/entities/purchase.dart';
import 'package:lynewed_beta/features/payments/domain/entities/purchase_status.dart';
import 'package:lynewed_beta/features/payments/domain/entities/stripe_account.dart';
import 'package:lynewed_beta/features/payments/domain/repositories/stripe_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {}

void main() {
  group('SupabaseStripeRepository', () {
    late MockSupabaseClient mockSupabase;
    late SupabaseStripeRepository repository;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      repository = SupabaseStripeRepository(mockSupabase);
    });

    test('should implement StripeRepository', () {
      expect(repository, isA<StripeRepository>());
    });

    group('entity parsing', () {
      test('should parse StripeAccount from database row', () {
        final row = {
          'user_id': 'user-123',
          'stripe_account_id': 'acct_123',
          'account_type': 'express',
          'onboarding_complete': true,
          'charges_enabled': true,
          'payouts_enabled': true,
          'details_submitted': true,
          'currently_due': <String>[],
          'past_due': <String>[],
          'disabled_reason': null,
          'country': 'US',
          'default_currency': 'usd',
          'created_at': '2024-01-15T10:30:00Z',
          'updated_at': '2024-01-20T15:45:00Z',
        };

        final account = StripeAccount.fromJson(row);

        expect(account.userId, 'user-123');
        expect(account.stripeAccountId, 'acct_123');
        expect(account.isActive, true);
      });

      test('should parse Purchase from database row', () {
        final row = {
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
          'stripe_checkout_session_id': null,
          'stripe_transfer_id': null,
          'stripe_charge_id': 'ch_123',
          'status': 'succeeded',
          'metadata': <String, dynamic>{},
          'error_message': null,
          'error_code': null,
          'created_at': '2024-01-15T10:30:00Z',
          'updated_at': '2024-01-15T10:35:00Z',
          'paid_at': '2024-01-15T10:35:00Z',
          'refunded_at': null,
          'disputed_at': null,
        };

        final purchase = Purchase.fromJson(row);

        expect(purchase.id, 'purchase-123');
        expect(purchase.productType, ProductType.marketplaceItem);
        expect(purchase.status, PurchaseStatus.succeeded);
        expect(purchase.amountInCurrency, 100.0);
        expect(purchase.platformFeeInCurrency, 10.0);
        expect(purchase.isMarketplace, true);
        expect(purchase.isPaid, true);
      });

      test('should handle all purchase statuses', () {
        final statuses = [
          'pending',
          'processing',
          'requires_action',
          'succeeded',
          'failed',
          'canceled',
          'refunded',
          'partially_refunded',
          'disputed',
        ];

        for (final status in statuses) {
          final parsed = PurchaseStatus.fromString(status);
          expect(parsed.toJson(), status);
        }
      });

      test('should handle all product types', () {
        final types = [
          'marketplace_item',
          'magazine',
          'album',
          'print',
          'subscription',
        ];

        for (final type in types) {
          final parsed = ProductType.fromString(type);
          expect(parsed.toJson(), type);
        }
      });
    });

    group('commission calculation', () {
      test('should correctly calculate 10% platform fee', () {
        final row = {
          'id': 'purchase-123',
          'user_id': 'user-123',
          'product_type': 'marketplace_item',
          'amount_cents': 10000,
          'platform_fee_cents': 1000,
          'seller_amount_cents': 9000,
          'created_at': '2024-01-15T10:30:00Z',
          'updated_at': '2024-01-15T10:30:00Z',
        };

        final purchase = Purchase.fromJson(row);

        expect(purchase.amountCents, 10000);
        expect(purchase.platformFeeCents, 1000);
        expect(purchase.sellerAmountCents, 9000);
        expect(purchase.platformFeeCents / purchase.amountCents, 0.1);
      });

      test('should handle non-marketplace purchases without commission', () {
        final row = {
          'id': 'purchase-123',
          'user_id': 'user-123',
          'product_type': 'magazine',
          'amount_cents': 999,
          'platform_fee_cents': 0,
          'seller_amount_cents': null,
          'created_at': '2024-01-15T10:30:00Z',
          'updated_at': '2024-01-15T10:30:00Z',
        };

        final purchase = Purchase.fromJson(row);

        expect(purchase.platformFeeCents, 0);
        expect(purchase.sellerAmountCents, isNull);
        expect(purchase.isMarketplace, false);
      });
    });
  });
}
