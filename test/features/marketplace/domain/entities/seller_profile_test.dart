/// Tests for SellerProfile entity.
///
/// Verifies JSON parsing, equality, hashCode, toString, and copyWith.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/seller_profile.dart';

void main() {
  group('SellerProfile', () {
    group('fromJson', () {
      test('should parse all fields correctly from JSON', () {
        final json = {
          'id': 'seller-123',
          'name': 'Alice',
          'avatar_url': 'https://example.com/avatar.jpg',
          'listings_count': 5,
        };

        final profile = SellerProfile.fromJson(json);

        expect(profile.id, 'seller-123');
        expect(profile.name, 'Alice');
        expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
        expect(profile.listingsCount, 5);
      });

      test('should handle null optional fields', () {
        final json = {
          'id': 'seller-456',
          'name': 'Bob',
          'avatar_url': null,
          'listings_count': 0,
        };

        final profile = SellerProfile.fromJson(json);

        expect(profile.id, 'seller-456');
        expect(profile.name, 'Bob');
        expect(profile.avatarUrl, isNull);
        expect(profile.listingsCount, 0);
      });

      test('should default listings_count to 0 when missing', () {
        final json = {
          'id': 'seller-789',
          'name': 'Charlie',
        };

        final profile = SellerProfile.fromJson(json);

        expect(profile.listingsCount, 0);
      });
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        const a = SellerProfile(
          id: 'seller-1',
          name: 'Alice',
          avatarUrl: 'https://example.com/a.jpg',
          listingsCount: 3,
        );
        const b = SellerProfile(
          id: 'seller-1',
          name: 'Alice',
          avatarUrl: 'https://example.com/a.jpg',
          listingsCount: 3,
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not be equal when fields differ', () {
        const a = SellerProfile(
          id: 'seller-1',
          name: 'Alice',
          listingsCount: 3,
        );
        const b = SellerProfile(
          id: 'seller-2',
          name: 'Bob',
          listingsCount: 1,
        );

        expect(a, isNot(equals(b)));
      });
    });

    group('toString', () {
      test('should return descriptive string', () {
        const profile = SellerProfile(
          id: 'seller-1',
          name: 'Alice',
          listingsCount: 3,
        );

        expect(profile.toString(), contains('seller-1'));
        expect(profile.toString(), contains('Alice'));
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        const original = SellerProfile(
          id: 'seller-1',
          name: 'Alice',
          avatarUrl: 'https://example.com/a.jpg',
          listingsCount: 3,
        );

        final copy = original.copyWith(name: 'Updated Alice', listingsCount: 5);

        expect(copy.id, 'seller-1');
        expect(copy.name, 'Updated Alice');
        expect(copy.avatarUrl, 'https://example.com/a.jpg');
        expect(copy.listingsCount, 5);
      });

      test('should keep original values when no updates provided', () {
        const original = SellerProfile(
          id: 'seller-1',
          name: 'Alice',
          listingsCount: 3,
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });
  });
}
