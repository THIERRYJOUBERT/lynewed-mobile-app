import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/payments/domain/entities/stripe_account.dart';

void main() {
  group('StripeAccount', () {
    final testJson = {
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

    group('fromJson', () {
      test('should create StripeAccount from valid JSON', () {
        final account = StripeAccount.fromJson(testJson);

        expect(account.userId, 'user-123');
        expect(account.stripeAccountId, 'acct_123');
        expect(account.accountType, 'express');
        expect(account.onboardingComplete, true);
        expect(account.chargesEnabled, true);
        expect(account.payoutsEnabled, true);
        expect(account.detailsSubmitted, true);
        expect(account.currentlyDue, isEmpty);
        expect(account.pastDue, isEmpty);
        expect(account.disabledReason, isNull);
        expect(account.country, 'US');
        expect(account.defaultCurrency, 'usd');
        expect(account.createdAt, DateTime.utc(2024, 1, 15, 10, 30));
        expect(account.updatedAt, DateTime.utc(2024, 1, 20, 15, 45));
      });

      test('should handle missing optional fields', () {
        final minimalJson = {
          'user_id': 'user-123',
          'stripe_account_id': 'acct_123',
          'created_at': '2024-01-15T10:30:00Z',
          'updated_at': '2024-01-20T15:45:00Z',
        };

        final account = StripeAccount.fromJson(minimalJson);

        expect(account.accountType, 'express');
        expect(account.onboardingComplete, false);
        expect(account.chargesEnabled, false);
        expect(account.payoutsEnabled, false);
        expect(account.detailsSubmitted, false);
        expect(account.currentlyDue, isEmpty);
        expect(account.pastDue, isEmpty);
      });

      test('should parse currently_due and past_due lists', () {
        final jsonWithRequirements = {
          ...testJson,
          'currently_due': ['external_account', 'tos_acceptance'],
          'past_due': ['business_profile.url'],
        };

        final account = StripeAccount.fromJson(jsonWithRequirements);

        expect(
            account.currentlyDue, ['external_account', 'tos_acceptance']);
        expect(account.pastDue, ['business_profile.url']);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = StripeAccount.fromJson(testJson);
        final updated = original.copyWith(
          chargesEnabled: false,
          disabledReason: 'under_review',
        );

        expect(updated.userId, original.userId);
        expect(updated.stripeAccountId, original.stripeAccountId);
        expect(updated.chargesEnabled, false);
        expect(updated.disabledReason, 'under_review');
        expect(original.chargesEnabled, true);
        expect(original.disabledReason, isNull);
      });

      test('should preserve all fields when no updates provided', () {
        final original = StripeAccount.fromJson(testJson);
        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('isActive', () {
      test('should return true when charges and payouts enabled', () {
        final account = StripeAccount.fromJson(testJson);
        expect(account.isActive, true);
      });

      test('should return false when charges disabled', () {
        final json = {...testJson, 'charges_enabled': false};
        final account = StripeAccount.fromJson(json);
        expect(account.isActive, false);
      });

      test('should return false when payouts disabled', () {
        final json = {...testJson, 'payouts_enabled': false};
        final account = StripeAccount.fromJson(json);
        expect(account.isActive, false);
      });
    });

    group('hasActionRequired', () {
      test('should return false when no requirements', () {
        final account = StripeAccount.fromJson(testJson);
        expect(account.hasActionRequired, false);
      });

      test('should return true when currently_due not empty', () {
        final json = {
          ...testJson,
          'currently_due': ['external_account'],
        };
        final account = StripeAccount.fromJson(json);
        expect(account.hasActionRequired, true);
      });

      test('should return true when past_due not empty', () {
        final json = {
          ...testJson,
          'past_due': ['business_profile.url'],
        };
        final account = StripeAccount.fromJson(json);
        expect(account.hasActionRequired, true);
      });
    });

    group('isRestricted', () {
      test('should return false when no disabled reason', () {
        final account = StripeAccount.fromJson(testJson);
        expect(account.isRestricted, false);
      });

      test('should return true when disabled reason present', () {
        final json = {...testJson, 'disabled_reason': 'under_review'};
        final account = StripeAccount.fromJson(json);
        expect(account.isRestricted, true);
      });
    });

    group('equality', () {
      test('should be equal for same values', () {
        final account1 = StripeAccount.fromJson(testJson);
        final account2 = StripeAccount.fromJson(testJson);
        expect(account1, equals(account2));
      });

      test('should not be equal for different values', () {
        final account1 = StripeAccount.fromJson(testJson);
        final account2 =
            StripeAccount.fromJson({...testJson, 'user_id': 'user-456'});
        expect(account1, isNot(equals(account2)));
      });
    });
  });
}
