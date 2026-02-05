/// Tests for ShippingRate entity.
///
/// Verifies creation, fromJson, priceInDollars getter, copyWith, and equality.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_rate.dart';

void main() {
  group('ShippingRate', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create ShippingRate with all fields', () {
        final rate = ShippingRate(
          serviceType: 'FEDEX_GROUND',
          serviceName: 'FedEx Ground',
          rateCents: 1250,
          currency: 'USD',
          estimatedDelivery: DateTime(2026, 2, 10),
          estimatedDays: 5,
        );

        expect(rate.serviceType, 'FEDEX_GROUND');
        expect(rate.serviceName, 'FedEx Ground');
        expect(rate.rateCents, 1250);
        expect(rate.currency, 'USD');
        expect(rate.estimatedDelivery, DateTime(2026, 2, 10));
        expect(rate.estimatedDays, 5);
      });

      test('should create ShippingRate with only required fields', () {
        const rate = ShippingRate(
          serviceType: 'FEDEX_EXPRESS',
          serviceName: 'FedEx Express',
          rateCents: 2500,
          currency: 'USD',
        );

        expect(rate.estimatedDelivery, isNull);
        expect(rate.estimatedDays, isNull);
      });
    });

    // ==============================================================
    // PRICE IN DOLLARS GETTER
    // ==============================================================

    group('priceInDollars', () {
      test('should convert cents to dollars', () {
        const rate = ShippingRate(
          serviceType: 'FEDEX_GROUND',
          serviceName: 'FedEx Ground',
          rateCents: 1250,
          currency: 'USD',
        );

        expect(rate.priceInDollars, 12.50);
      });

      test('should handle zero cents', () {
        const rate = ShippingRate(
          serviceType: 'FREE',
          serviceName: 'Free Shipping',
          rateCents: 0,
          currency: 'USD',
        );

        expect(rate.priceInDollars, 0.0);
      });

      test('should handle large amounts', () {
        const rate = ShippingRate(
          serviceType: 'FEDEX_FREIGHT',
          serviceName: 'FedEx Freight',
          rateCents: 999999,
          currency: 'USD',
        );

        expect(rate.priceInDollars, closeTo(9999.99, 0.001));
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should deserialize from edge function response format', () {
        final json = {
          'service_type': 'FEDEX_GROUND',
          'service_name': 'FedEx Ground',
          'rate_cents': 1250,
          'currency': 'USD',
          'estimated_delivery': '2026-02-10',
          'estimated_days': 5,
        };

        final rate = ShippingRate.fromJson(json);

        expect(rate.serviceType, 'FEDEX_GROUND');
        expect(rate.serviceName, 'FedEx Ground');
        expect(rate.rateCents, 1250);
        expect(rate.currency, 'USD');
        expect(rate.estimatedDelivery, DateTime(2026, 2, 10));
        expect(rate.estimatedDays, 5);
      });

      test('should handle null optional fields', () {
        final json = {
          'service_type': 'FEDEX_EXPRESS',
          'service_name': 'FedEx Express',
          'rate_cents': 2500,
          'currency': 'USD',
        };

        final rate = ShippingRate.fromJson(json);

        expect(rate.estimatedDelivery, isNull);
        expect(rate.estimatedDays, isNull);
      });
    });

    // ==============================================================
    // COPYWIDTH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should create copy with updated fields', () {
        const rate = ShippingRate(
          serviceType: 'FEDEX_GROUND',
          serviceName: 'FedEx Ground',
          rateCents: 1250,
          currency: 'USD',
        );

        final copy = rate.copyWith(rateCents: 1500);

        expect(copy.serviceType, 'FEDEX_GROUND');
        expect(copy.rateCents, 1500);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when all fields match', () {
        const rate1 = ShippingRate(
          serviceType: 'FEDEX_GROUND',
          serviceName: 'FedEx Ground',
          rateCents: 1250,
          currency: 'USD',
        );

        const rate2 = ShippingRate(
          serviceType: 'FEDEX_GROUND',
          serviceName: 'FedEx Ground',
          rateCents: 1250,
          currency: 'USD',
        );

        expect(rate1, equals(rate2));
        expect(rate1.hashCode, equals(rate2.hashCode));
      });

      test('should not be equal when fields differ', () {
        const rate1 = ShippingRate(
          serviceType: 'FEDEX_GROUND',
          serviceName: 'FedEx Ground',
          rateCents: 1250,
          currency: 'USD',
        );

        const rate2 = ShippingRate(
          serviceType: 'FEDEX_EXPRESS',
          serviceName: 'FedEx Express',
          rateCents: 2500,
          currency: 'USD',
        );

        expect(rate1, isNot(equals(rate2)));
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should contain key fields', () {
        const rate = ShippingRate(
          serviceType: 'FEDEX_GROUND',
          serviceName: 'FedEx Ground',
          rateCents: 1250,
          currency: 'USD',
        );

        final str = rate.toString();

        expect(str, contains('FEDEX_GROUND'));
        expect(str, contains('1250'));
      });
    });
  });
}
