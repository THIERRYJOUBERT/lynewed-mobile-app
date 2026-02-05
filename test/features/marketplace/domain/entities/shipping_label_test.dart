/// Tests for ShippingLabel entity.
///
/// Verifies creation, fromJson, copyWith, and equality.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_label.dart';

void main() {
  group('ShippingLabel', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create ShippingLabel with all fields', () {
        const label = ShippingLabel(
          trackingNumber: '123456789012',
          labelUrl: 'https://storage.example.com/labels/label.pdf',
          serviceType: 'FEDEX_GROUND',
        );

        expect(label.trackingNumber, '123456789012');
        expect(label.labelUrl, 'https://storage.example.com/labels/label.pdf');
        expect(label.serviceType, 'FEDEX_GROUND');
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should deserialize from edge function response', () {
        final json = {
          'tracking_number': '123456789',
          'label_url': 'https://storage.example.com/labels/label.pdf',
          'service_type': 'FEDEX_GROUND',
        };

        final label = ShippingLabel.fromJson(json);

        expect(label.trackingNumber, '123456789');
        expect(label.labelUrl, 'https://storage.example.com/labels/label.pdf');
        expect(label.serviceType, 'FEDEX_GROUND');
      });
    });

    // ==============================================================
    // COPYWIDTH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should create copy with updated fields', () {
        const label = ShippingLabel(
          trackingNumber: '123456789',
          labelUrl: 'https://example.com/old.pdf',
          serviceType: 'FEDEX_GROUND',
        );

        final copy = label.copyWith(
          labelUrl: 'https://example.com/new.pdf',
        );

        expect(copy.trackingNumber, '123456789');
        expect(copy.labelUrl, 'https://example.com/new.pdf');
        expect(copy.serviceType, 'FEDEX_GROUND');
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when all fields match', () {
        const label1 = ShippingLabel(
          trackingNumber: '123456789',
          labelUrl: 'https://example.com/label.pdf',
          serviceType: 'FEDEX_GROUND',
        );

        const label2 = ShippingLabel(
          trackingNumber: '123456789',
          labelUrl: 'https://example.com/label.pdf',
          serviceType: 'FEDEX_GROUND',
        );

        expect(label1, equals(label2));
        expect(label1.hashCode, equals(label2.hashCode));
      });

      test('should not be equal when tracking number differs', () {
        const label1 = ShippingLabel(
          trackingNumber: '123456789',
          labelUrl: 'https://example.com/label.pdf',
          serviceType: 'FEDEX_GROUND',
        );

        const label2 = ShippingLabel(
          trackingNumber: '987654321',
          labelUrl: 'https://example.com/label.pdf',
          serviceType: 'FEDEX_GROUND',
        );

        expect(label1, isNot(equals(label2)));
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should contain key fields', () {
        const label = ShippingLabel(
          trackingNumber: '123456789',
          labelUrl: 'https://example.com/label.pdf',
          serviceType: 'FEDEX_GROUND',
        );

        final str = label.toString();

        expect(str, contains('123456789'));
        expect(str, contains('FEDEX_GROUND'));
      });
    });
  });
}
