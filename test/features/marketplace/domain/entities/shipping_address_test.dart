/// Tests for ShippingAddress entity.
///
/// Verifies creation, serialization, equality, and copyWith
/// for shipping addresses used by FedEx API.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/shipping_address.dart';

void main() {
  group('ShippingAddress', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create ShippingAddress with all fields', () {
        const address = ShippingAddress(
          streetLines: ['123 Main Street', 'Apt 4B'],
          city: 'Paris',
          postalCode: '75001',
          countryCode: 'FR',
          stateOrProvinceCode: 'IDF',
          personName: 'Jane Doe',
          phoneNumber: '+33123456789',
        );

        expect(address.streetLines, ['123 Main Street', 'Apt 4B']);
        expect(address.city, 'Paris');
        expect(address.postalCode, '75001');
        expect(address.countryCode, 'FR');
        expect(address.stateOrProvinceCode, 'IDF');
        expect(address.personName, 'Jane Doe');
        expect(address.phoneNumber, '+33123456789');
      });

      test('should create ShippingAddress with only required fields', () {
        const address = ShippingAddress(
          streetLines: ['456 Elm Avenue'],
          city: 'New York',
          postalCode: '10001',
          countryCode: 'US',
        );

        expect(address.streetLines, ['456 Elm Avenue']);
        expect(address.city, 'New York');
        expect(address.postalCode, '10001');
        expect(address.countryCode, 'US');
        expect(address.stateOrProvinceCode, isNull);
        expect(address.personName, isNull);
        expect(address.phoneNumber, isNull);
      });

      test('should be immutable', () {
        const address = ShippingAddress(
          streetLines: ['123 Main Street'],
          city: 'Paris',
          postalCode: '75001',
          countryCode: 'FR',
        );

        // Verify fields are final (compile-time check)
        expect(address.city, 'Paris');
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should deserialize from valid JSON with all fields', () {
        final json = {
          'street_lines': ['45 Rue de Rivoli', 'Etage 3'],
          'city': 'Lyon',
          'postal_code': '69001',
          'country_code': 'FR',
          'state_or_province_code': 'ARA',
          'person_name': 'Marie Martin',
          'phone_number': '+33678901234',
        };

        final address = ShippingAddress.fromJson(json);

        expect(address.streetLines, ['45 Rue de Rivoli', 'Etage 3']);
        expect(address.city, 'Lyon');
        expect(address.postalCode, '69001');
        expect(address.countryCode, 'FR');
        expect(address.stateOrProvinceCode, 'ARA');
        expect(address.personName, 'Marie Martin');
        expect(address.phoneNumber, '+33678901234');
      });

      test('should deserialize with only required fields', () {
        final json = {
          'street_lines': ['456 Elm Avenue'],
          'city': 'New York',
          'postal_code': '10001',
          'country_code': 'US',
        };

        final address = ShippingAddress.fromJson(json);

        expect(address.streetLines, ['456 Elm Avenue']);
        expect(address.city, 'New York');
        expect(address.postalCode, '10001');
        expect(address.countryCode, 'US');
        expect(address.stateOrProvinceCode, isNull);
        expect(address.personName, isNull);
        expect(address.phoneNumber, isNull);
      });
    });

    // ==============================================================
    // TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should serialize to JSON with snake_case keys', () {
        const address = ShippingAddress(
          streetLines: ['123 Main Street'],
          city: 'Paris',
          postalCode: '75001',
          countryCode: 'FR',
          personName: 'Jane Doe',
        );

        final json = address.toJson();

        expect(json['street_lines'], ['123 Main Street']);
        expect(json['city'], 'Paris');
        expect(json['postal_code'], '75001');
        expect(json['country_code'], 'FR');
        expect(json['person_name'], 'Jane Doe');
      });

      test('should round-trip fromJson/toJson correctly', () {
        final originalJson = {
          'street_lines': ['45 Rue de Rivoli'],
          'city': 'Lyon',
          'postal_code': '69001',
          'country_code': 'FR',
          'state_or_province_code': 'ARA',
          'person_name': 'Marie Martin',
          'phone_number': '+33678901234',
        };

        final address = ShippingAddress.fromJson(originalJson);
        final resultJson = address.toJson();

        expect(resultJson, originalJson);
      });
    });

    // ==============================================================
    // COPYWIDTH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should create copy with updated fields', () {
        const address = ShippingAddress(
          streetLines: ['123 Main Street'],
          city: 'Paris',
          postalCode: '75001',
          countryCode: 'FR',
        );

        final copy = address.copyWith(city: 'Lyon', postalCode: '69001');

        expect(copy.streetLines, ['123 Main Street']);
        expect(copy.city, 'Lyon');
        expect(copy.postalCode, '69001');
        expect(copy.countryCode, 'FR');
      });

      test('should preserve original values when not overridden', () {
        const address = ShippingAddress(
          streetLines: ['123 Main Street'],
          city: 'Paris',
          postalCode: '75001',
          countryCode: 'FR',
          personName: 'Jane Doe',
        );

        final copy = address.copyWith(city: 'Lyon');

        expect(copy.personName, 'Jane Doe');
        expect(copy.streetLines, ['123 Main Street']);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when all fields match', () {
        const address1 = ShippingAddress(
          streetLines: ['123 Main Street'],
          city: 'Paris',
          postalCode: '75001',
          countryCode: 'FR',
        );

        const address2 = ShippingAddress(
          streetLines: ['123 Main Street'],
          city: 'Paris',
          postalCode: '75001',
          countryCode: 'FR',
        );

        expect(address1, equals(address2));
        expect(address1.hashCode, equals(address2.hashCode));
      });

      test('should not be equal when a field differs', () {
        const address1 = ShippingAddress(
          streetLines: ['123 Main Street'],
          city: 'Paris',
          postalCode: '75001',
          countryCode: 'FR',
        );

        const address2 = ShippingAddress(
          streetLines: ['456 Elm Avenue'],
          city: 'Paris',
          postalCode: '75001',
          countryCode: 'FR',
        );

        expect(address1, isNot(equals(address2)));
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should contain key fields', () {
        const address = ShippingAddress(
          streetLines: ['123 Main Street'],
          city: 'Paris',
          postalCode: '75001',
          countryCode: 'FR',
        );

        final str = address.toString();

        expect(str, contains('Paris'));
        expect(str, contains('FR'));
      });
    });
  });
}
