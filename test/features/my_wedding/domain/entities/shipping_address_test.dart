/// Tests for ShippingAddress entity.
///
/// Comprehensive tests for shipping address validation and operations.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/shipping_address.dart';

void main() {
  group('ShippingAddress', () {
    group('constructor', () {
      test('should create address with all required fields', () {
        const address = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        expect(address.fullName, 'John Doe');
        expect(address.addressLine1, '123 Main St');
        expect(address.city, 'New York');
        expect(address.zipCode, '10001');
        expect(address.country, 'US');
        expect(address.addressLine2, isNull);
      });

      test('should create address with optional addressLine2', () {
        const address = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          addressLine2: 'Apt 4B',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        expect(address.addressLine2, 'Apt 4B');
      });
    });

    group('isValid', () {
      test('should return true when all required fields are filled', () {
        const address = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        expect(address.isValid, true);
      });

      test('should return false when fullName is empty', () {
        const address = ShippingAddress(
          fullName: '',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        expect(address.isValid, false);
      });

      test('should return false when addressLine1 is empty', () {
        const address = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        expect(address.isValid, false);
      });

      test('should return false when city is empty', () {
        const address = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: '',
          zipCode: '10001',
          country: 'US',
        );

        expect(address.isValid, false);
      });

      test('should return false when zipCode is empty', () {
        const address = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '',
          country: 'US',
        );

        expect(address.isValid, false);
      });

      test('should return false when country is empty', () {
        const address = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: '',
        );

        expect(address.isValid, false);
      });

      test('should return true without addressLine2', () {
        const address = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        expect(address.isValid, true);
      });
    });

    group('toJson', () {
      test('should convert to JSON with all fields', () {
        const address = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          addressLine2: 'Apt 4B',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        final json = address.toJson();

        expect(json['full_name'], 'John Doe');
        expect(json['address_line1'], '123 Main St');
        expect(json['address_line2'], 'Apt 4B');
        expect(json['city'], 'New York');
        expect(json['zip_code'], '10001');
        expect(json['country'], 'US');
      });

      test('should omit addressLine2 when null', () {
        const address = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        final json = address.toJson();

        expect(json.containsKey('address_line2'), false);
      });
    });

    group('fromJson', () {
      test('should create from JSON with all fields', () {
        final json = {
          'full_name': 'John Doe',
          'address_line1': '123 Main St',
          'address_line2': 'Apt 4B',
          'city': 'New York',
          'zip_code': '10001',
          'country': 'US',
        };

        final address = ShippingAddress.fromJson(json);

        expect(address.fullName, 'John Doe');
        expect(address.addressLine1, '123 Main St');
        expect(address.addressLine2, 'Apt 4B');
        expect(address.city, 'New York');
        expect(address.zipCode, '10001');
        expect(address.country, 'US');
      });

      test('should handle missing optional fields', () {
        final json = {
          'full_name': 'John Doe',
          'address_line1': '123 Main St',
          'city': 'New York',
          'zip_code': '10001',
          'country': 'US',
        };

        final address = ShippingAddress.fromJson(json);

        expect(address.addressLine2, isNull);
      });

      test('should handle null values with defaults', () {
        final json = <String, dynamic>{};

        final address = ShippingAddress.fromJson(json);

        expect(address.fullName, '');
        expect(address.addressLine1, '');
        expect(address.city, '');
        expect(address.zipCode, '');
        expect(address.country, '');
      });
    });

    group('empty', () {
      test('should create empty address with default country', () {
        final address = ShippingAddress.empty();

        expect(address.fullName, '');
        expect(address.addressLine1, '');
        expect(address.addressLine2, isNull);
        expect(address.city, '');
        expect(address.zipCode, '');
        expect(address.country, 'US');
      });

      test('should return invalid for empty address', () {
        final address = ShippingAddress.empty();

        expect(address.isValid, false);
      });
    });

    group('copyWith', () {
      test('should copy with updated fullName', () {
        const original = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        final updated = original.copyWith(fullName: 'Jane Doe');

        expect(updated.fullName, 'Jane Doe');
        expect(updated.addressLine1, '123 Main St');
        expect(updated.city, 'New York');
      });

      test('should copy with updated addressLine2', () {
        const original = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        final updated = original.copyWith(addressLine2: 'Apt 5');

        expect(updated.addressLine2, 'Apt 5');
      });

      test('should clear addressLine2 when clearAddressLine2 is true', () {
        const original = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          addressLine2: 'Apt 4B',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        final updated = original.copyWith(clearAddressLine2: true);

        expect(updated.addressLine2, isNull);
      });

      test('should copy with updated country', () {
        const original = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        final updated = original.copyWith(country: 'CA');

        expect(updated.country, 'CA');
      });
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        const address1 = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        const address2 = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        expect(address1, equals(address2));
      });

      test('should not be equal when fields differ', () {
        const address1 = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        const address2 = ShippingAddress(
          fullName: 'Jane Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        expect(address1, isNot(equals(address2)));
      });
    });

    group('hashCode', () {
      test('should be same for equal addresses', () {
        const address1 = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        const address2 = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        expect(address1.hashCode, equals(address2.hashCode));
      });
    });

    group('toString', () {
      test('should include key fields', () {
        const address = ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        );

        expect(address.toString(), contains('John Doe'));
        expect(address.toString(), contains('New York'));
        expect(address.toString(), contains('US'));
      });
    });
  });

  group('ShippingCountries', () {
    test('should have 8 supported countries', () {
      expect(ShippingCountries.all.length, 8);
    });

    test('should include US', () {
      final us = ShippingCountries.all.firstWhere((c) => c.code == 'US');
      expect(us.name, 'United States');
    });

    test('should include European countries', () {
      final codes = ShippingCountries.all.map((c) => c.code).toList();
      expect(codes, contains('GB'));
      expect(codes, contains('FR'));
      expect(codes, contains('DE'));
      expect(codes, contains('IT'));
      expect(codes, contains('ES'));
    });

    group('getDisplayName', () {
      test('should return display name for valid code', () {
        expect(ShippingCountries.getDisplayName('US'), 'United States');
        expect(ShippingCountries.getDisplayName('FR'), 'France');
        expect(ShippingCountries.getDisplayName('GB'), 'United Kingdom');
      });

      test('should return code for unknown country', () {
        expect(ShippingCountries.getDisplayName('XX'), 'XX');
      });
    });

    group('getCode', () {
      test('should return code for valid name', () {
        expect(ShippingCountries.getCode('United States'), 'US');
        expect(ShippingCountries.getCode('France'), 'FR');
      });

      test('should return null for unknown name', () {
        expect(ShippingCountries.getCode('Unknown'), isNull);
      });
    });
  });

  group('ShippingCosts', () {
    group('calculateCents', () {
      test('should return 1500 for US', () {
        expect(ShippingCosts.calculateCents('US'), 1500);
      });

      test('should return 2500 for Canada', () {
        expect(ShippingCosts.calculateCents('CA'), 2500);
      });

      test('should return 2500 for UK', () {
        expect(ShippingCosts.calculateCents('GB'), 2500);
      });

      test('should return 2500 for France', () {
        expect(ShippingCosts.calculateCents('FR'), 2500);
      });

      test('should return 2500 for Germany', () {
        expect(ShippingCosts.calculateCents('DE'), 2500);
      });

      test('should return 2500 for Italy', () {
        expect(ShippingCosts.calculateCents('IT'), 2500);
      });

      test('should return 2500 for Spain', () {
        expect(ShippingCosts.calculateCents('ES'), 2500);
      });

      test('should return 3500 for Australia', () {
        expect(ShippingCosts.calculateCents('AU'), 3500);
      });

      test('should return 3500 for unknown country', () {
        expect(ShippingCosts.calculateCents('XX'), 3500);
      });
    });

    group('format', () {
      test('should format whole dollar amounts', () {
        expect(ShippingCosts.format(1500), r'$15');
        expect(ShippingCosts.format(2500), r'$25');
        expect(ShippingCosts.format(3500), r'$35');
      });

      test('should format amounts with cents', () {
        expect(ShippingCosts.format(1550), r'$15.50');
        expect(ShippingCosts.format(2599), r'$25.99');
      });

      test('should format zero', () {
        expect(ShippingCosts.format(0), r'$0');
      });
    });
  });
}
