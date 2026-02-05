import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_listing.dart';

void main() {
  group('MarketplaceListing', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create MarketplaceListing with required fields', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Beautiful Wedding Dress',
          category: 'dress',
          priceCents: 29999,
          condition: 'excellent',
          country: 'France',
          status: 'active',
          createdAt: now,
          updatedAt: now,
        );

        expect(listing.id, 'listing-123');
        expect(listing.sellerId, 'seller-456');
        expect(listing.title, 'Beautiful Wedding Dress');
        expect(listing.category, 'dress');
        expect(listing.priceCents, 29999);
        expect(listing.condition, 'excellent');
        expect(listing.country, 'France');
        expect(listing.status, 'active');
        expect(listing.createdAt, now);
        expect(listing.updatedAt, now);
        expect(listing.displayCurrency, 'USD');
      });

      test('should create MarketplaceListing with all optional fields', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Designer Dress',
          description: 'Beautiful silk dress',
          category: 'dress',
          priceCents: 50000,
          displayCurrency: 'EUR',
          designerBrand: 'Vera Wang',
          size: '38',
          condition: 'new',
          sleeveLength: 'long',
          city: 'Paris',
          country: 'France',
          countryCode: 'FR',
          latitude: 48.8566,
          longitude: 2.3522,
          status: 'draft',
          createdAt: now,
          updatedAt: now,
          soldAt: now,
        );

        expect(listing.description, 'Beautiful silk dress');
        expect(listing.displayCurrency, 'EUR');
        expect(listing.designerBrand, 'Vera Wang');
        expect(listing.size, '38');
        expect(listing.sleeveLength, 'long');
        expect(listing.city, 'Paris');
        expect(listing.countryCode, 'FR');
        expect(listing.latitude, 48.8566);
        expect(listing.longitude, 2.3522);
        expect(listing.soldAt, now);
      });

      test('should be immutable', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test',
          category: 'dress',
          priceCents: 10000,
          condition: 'new',
          country: 'France',
          status: 'draft',
          createdAt: now,
          updatedAt: now,
        );

        // Verify fields are final (compile-time check)
        expect(listing.title, 'Test');
      });

      test('should default displayCurrency to USD', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test',
          category: 'dress',
          priceCents: 10000,
          condition: 'new',
          country: 'France',
          status: 'draft',
          createdAt: now,
          updatedAt: now,
        );

        expect(listing.displayCurrency, 'USD');
      });

      test('should allow null optional fields', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test Shoes',
          category: 'shoes',
          priceCents: 5000,
          condition: 'new',
          country: 'France',
          status: 'draft',
          createdAt: now,
          updatedAt: now,
        );

        expect(listing.description, isNull);
        expect(listing.designerBrand, isNull);
        expect(listing.size, isNull);
        expect(listing.sleeveLength, isNull);
        expect(listing.city, isNull);
        expect(listing.countryCode, isNull);
        expect(listing.latitude, isNull);
        expect(listing.longitude, isNull);
        expect(listing.soldAt, isNull);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is the same', () {
        final now = DateTime(2026, 2, 4);
        final listing1 = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Dress A',
          category: 'dress',
          priceCents: 10000,
          condition: 'new',
          country: 'France',
          status: 'active',
          createdAt: now,
          updatedAt: now,
        );

        final listing2 = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-999',
          title: 'Dress B',
          category: 'shoes',
          priceCents: 20000,
          condition: 'good',
          country: 'Spain',
          status: 'sold',
          createdAt: now,
          updatedAt: now,
        );

        expect(listing1, equals(listing2));
        expect(listing1.hashCode, equals(listing2.hashCode));
      });

      test('should not be equal when id differs', () {
        final now = DateTime(2026, 2, 4);
        final listing1 = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Dress A',
          category: 'dress',
          priceCents: 10000,
          condition: 'new',
          country: 'France',
          status: 'active',
          createdAt: now,
          updatedAt: now,
        );

        final listing2 = MarketplaceListing(
          id: 'listing-999',
          sellerId: 'seller-456',
          title: 'Dress A',
          category: 'dress',
          priceCents: 10000,
          condition: 'new',
          country: 'France',
          status: 'active',
          createdAt: now,
          updatedAt: now,
        );

        expect(listing1, isNot(equals(listing2)));
        expect(listing1.hashCode, isNot(equals(listing2.hashCode)));
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should create copy with updated title', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Original Title',
          category: 'dress',
          priceCents: 10000,
          condition: 'new',
          country: 'France',
          status: 'draft',
          createdAt: now,
          updatedAt: now,
        );

        final updated = listing.copyWith(title: 'New Title');

        expect(updated.title, 'New Title');
        expect(updated.id, listing.id);
        expect(updated.sellerId, listing.sellerId);
      });

      test('should create copy with updated status', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test',
          category: 'dress',
          priceCents: 10000,
          condition: 'new',
          country: 'France',
          status: 'draft',
          createdAt: now,
          updatedAt: now,
        );

        final updated = listing.copyWith(status: 'active');

        expect(updated.status, 'active');
        expect(updated.id, listing.id);
      });

      test('should preserve all fields when no parameter provided', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test',
          description: 'Desc',
          category: 'dress',
          priceCents: 10000,
          displayCurrency: 'EUR',
          designerBrand: 'Vera Wang',
          size: '38',
          condition: 'new',
          sleeveLength: 'long',
          city: 'Paris',
          country: 'France',
          countryCode: 'FR',
          latitude: 48.8566,
          longitude: 2.3522,
          status: 'draft',
          createdAt: now,
          updatedAt: now,
          soldAt: now,
        );

        final copied = listing.copyWith();

        expect(copied.id, listing.id);
        expect(copied.sellerId, listing.sellerId);
        expect(copied.title, listing.title);
        expect(copied.description, listing.description);
        expect(copied.category, listing.category);
        expect(copied.priceCents, listing.priceCents);
        expect(copied.displayCurrency, listing.displayCurrency);
        expect(copied.designerBrand, listing.designerBrand);
        expect(copied.size, listing.size);
        expect(copied.condition, listing.condition);
        expect(copied.sleeveLength, listing.sleeveLength);
        expect(copied.city, listing.city);
        expect(copied.country, listing.country);
        expect(copied.countryCode, listing.countryCode);
        expect(copied.latitude, listing.latitude);
        expect(copied.longitude, listing.longitude);
        expect(copied.status, listing.status);
        expect(copied.createdAt, listing.createdAt);
        expect(copied.updatedAt, listing.updatedAt);
        expect(copied.soldAt, listing.soldAt);
      });
    });

    // ==============================================================
    // PRICE TESTS
    // ==============================================================

    group('price validation', () {
      test('should store price 299.99 USD as 29999 cents', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test',
          category: 'dress',
          priceCents: 29999,
          condition: 'new',
          country: 'France',
          status: 'draft',
          createdAt: now,
          updatedAt: now,
        );

        expect(listing.priceCents, 29999);
        expect(listing.priceCents / 100, 299.99);
      });

      test('priceInDollars should return correct value', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test',
          category: 'dress',
          priceCents: 29999,
          condition: 'new',
          country: 'France',
          status: 'draft',
          createdAt: now,
          updatedAt: now,
        );

        expect(listing.priceInDollars, 299.99);
      });

      test('priceInDollars for exact dollar amount', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test',
          category: 'dress',
          priceCents: 10000,
          condition: 'new',
          country: 'France',
          status: 'draft',
          createdAt: now,
          updatedAt: now,
        );

        expect(listing.priceInDollars, 100.0);
      });
    });

    // ==============================================================
    // CATEGORY TESTS
    // ==============================================================

    group('category', () {
      test('should accept dress category', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test Dress',
          category: 'dress',
          priceCents: 10000,
          condition: 'new',
          country: 'France',
          status: 'draft',
          createdAt: now,
          updatedAt: now,
        );

        expect(listing.category, 'dress');
      });

      test('should accept shoes category', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test Shoes',
          category: 'shoes',
          priceCents: 5000,
          condition: 'new',
          country: 'France',
          status: 'draft',
          createdAt: now,
          updatedAt: now,
        );

        expect(listing.category, 'shoes');
      });

      test('dress should allow sleeve_length', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test Dress',
          category: 'dress',
          priceCents: 10000,
          condition: 'new',
          sleeveLength: 'long',
          country: 'France',
          status: 'draft',
          createdAt: now,
          updatedAt: now,
        );

        expect(listing.sleeveLength, 'long');
      });

      test('shoes should allow null sleeve_length', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test Shoes',
          category: 'shoes',
          priceCents: 5000,
          condition: 'new',
          sleeveLength: null,
          country: 'France',
          status: 'draft',
          createdAt: now,
          updatedAt: now,
        );

        expect(listing.sleeveLength, isNull);
      });

      test('isDress returns true for dress category', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test Dress',
          category: 'dress',
          priceCents: 10000,
          condition: 'new',
          country: 'France',
          status: 'draft',
          createdAt: now,
          updatedAt: now,
        );

        expect(listing.isDress, isTrue);
        expect(listing.isShoes, isFalse);
      });

      test('isShoes returns true for shoes category', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test Shoes',
          category: 'shoes',
          priceCents: 5000,
          condition: 'new',
          country: 'France',
          status: 'draft',
          createdAt: now,
          updatedAt: now,
        );

        expect(listing.isShoes, isTrue);
        expect(listing.isDress, isFalse);
      });
    });

    // ==============================================================
    // STATUS GETTERS
    // ==============================================================

    group('status getters', () {
      test('isActive returns true for active status', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test',
          category: 'dress',
          priceCents: 10000,
          condition: 'new',
          country: 'France',
          status: 'active',
          createdAt: now,
          updatedAt: now,
        );

        expect(listing.isActive, isTrue);
      });

      test('isActive returns false for non-active status', () {
        final now = DateTime(2026, 2, 4);
        for (final status in ['draft', 'reserved', 'sold', 'deleted']) {
          final listing = MarketplaceListing(
            id: 'listing-123',
            sellerId: 'seller-456',
            title: 'Test',
            category: 'shoes',
            priceCents: 10000,
            condition: 'new',
            country: 'France',
            status: status,
            createdAt: now,
            updatedAt: now,
          );

          expect(listing.isActive, isFalse,
              reason: 'status "$status" should not be active');
        }
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse valid JSON with all fields', () {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'seller_id': '660e8400-e29b-41d4-a716-446655440001',
          'title': 'Gorgeous Wedding Dress',
          'description': 'A stunning silk wedding dress',
          'category': 'dress',
          'price_cents': 45000,
          'display_currency': 'EUR',
          'designer_brand': 'Vera Wang',
          'size': '36',
          'condition': 'new',
          'sleeve_length': 'long',
          'city': 'Paris',
          'country': 'France',
          'country_code': 'FR',
          'latitude': '48.85660000',
          'longitude': '2.35220000',
          'status': 'active',
          'created_at': '2026-02-04T10:00:00.000Z',
          'updated_at': '2026-02-04T12:00:00.000Z',
          'sold_at': '2026-02-05T08:00:00.000Z',
        };

        final listing = MarketplaceListing.fromJson(json);

        expect(listing.id, '550e8400-e29b-41d4-a716-446655440000');
        expect(listing.sellerId, '660e8400-e29b-41d4-a716-446655440001');
        expect(listing.title, 'Gorgeous Wedding Dress');
        expect(listing.description, 'A stunning silk wedding dress');
        expect(listing.category, 'dress');
        expect(listing.priceCents, 45000);
        expect(listing.displayCurrency, 'EUR');
        expect(listing.designerBrand, 'Vera Wang');
        expect(listing.size, '36');
        expect(listing.condition, 'new');
        expect(listing.sleeveLength, 'long');
        expect(listing.city, 'Paris');
        expect(listing.country, 'France');
        expect(listing.countryCode, 'FR');
        expect(listing.latitude, closeTo(48.8566, 0.0001));
        expect(listing.longitude, closeTo(2.3522, 0.0001));
        expect(listing.status, 'active');
        expect(listing.createdAt, DateTime.parse('2026-02-04T10:00:00.000Z'));
        expect(listing.updatedAt, DateTime.parse('2026-02-04T12:00:00.000Z'));
        expect(listing.soldAt, DateTime.parse('2026-02-05T08:00:00.000Z'));
      });

      test('should handle null optional fields', () {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'seller_id': '660e8400-e29b-41d4-a716-446655440001',
          'title': 'Simple Shoes',
          'description': null,
          'category': 'shoes',
          'price_cents': 8000,
          'display_currency': 'USD',
          'designer_brand': null,
          'size': null,
          'condition': 'good',
          'sleeve_length': null,
          'city': null,
          'country': 'USA',
          'country_code': null,
          'latitude': null,
          'longitude': null,
          'status': 'draft',
          'created_at': '2026-02-04T10:00:00.000Z',
          'updated_at': '2026-02-04T10:00:00.000Z',
          'sold_at': null,
        };

        final listing = MarketplaceListing.fromJson(json);

        expect(listing.description, isNull);
        expect(listing.designerBrand, isNull);
        expect(listing.size, isNull);
        expect(listing.sleeveLength, isNull);
        expect(listing.city, isNull);
        expect(listing.countryCode, isNull);
        expect(listing.latitude, isNull);
        expect(listing.longitude, isNull);
        expect(listing.soldAt, isNull);
      });

      test('should parse latitude/longitude from string (Supabase DECIMAL)',
          () {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'seller_id': '660e8400-e29b-41d4-a716-446655440001',
          'title': 'Test',
          'category': 'shoes',
          'price_cents': 5000,
          'display_currency': 'USD',
          'condition': 'new',
          'country': 'France',
          'latitude': '48.85660000',
          'longitude': '2.35220000',
          'status': 'active',
          'created_at': '2026-02-04T10:00:00.000Z',
          'updated_at': '2026-02-04T10:00:00.000Z',
        };

        final listing = MarketplaceListing.fromJson(json);

        expect(listing.latitude, closeTo(48.8566, 0.0001));
        expect(listing.longitude, closeTo(2.3522, 0.0001));
      });

      test('should parse latitude/longitude from numeric values', () {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'seller_id': '660e8400-e29b-41d4-a716-446655440001',
          'title': 'Test',
          'category': 'shoes',
          'price_cents': 5000,
          'display_currency': 'USD',
          'condition': 'new',
          'country': 'France',
          'latitude': 48.8566,
          'longitude': 2.3522,
          'status': 'active',
          'created_at': '2026-02-04T10:00:00.000Z',
          'updated_at': '2026-02-04T10:00:00.000Z',
        };

        final listing = MarketplaceListing.fromJson(json);

        expect(listing.latitude, closeTo(48.8566, 0.0001));
        expect(listing.longitude, closeTo(2.3522, 0.0001));
      });

      test('should default displayCurrency to USD when null in JSON', () {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'seller_id': '660e8400-e29b-41d4-a716-446655440001',
          'title': 'Test',
          'category': 'shoes',
          'price_cents': 5000,
          'display_currency': null,
          'condition': 'new',
          'country': 'France',
          'status': 'draft',
          'created_at': '2026-02-04T10:00:00.000Z',
          'updated_at': '2026-02-04T10:00:00.000Z',
        };

        final listing = MarketplaceListing.fromJson(json);

        expect(listing.displayCurrency, 'USD');
      });

      test('should extract cover photo from joined marketplace_photos', () {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'seller_id': '660e8400-e29b-41d4-a716-446655440001',
          'title': 'Test',
          'category': 'dress',
          'price_cents': 5000,
          'condition': 'new',
          'country': 'France',
          'status': 'active',
          'created_at': '2026-02-04T10:00:00.000Z',
          'updated_at': '2026-02-04T10:00:00.000Z',
          'marketplace_photos': [
            {'storage_path': 'listing-1/photo_0.jpg', 'position': 0},
            {'storage_path': 'listing-1/photo_1.jpg', 'position': 1},
          ],
        };

        final listing = MarketplaceListing.fromJson(json);

        expect(listing.coverPhotoStoragePath, 'listing-1/photo_0.jpg');
      });

      test('should use first photo when no position 0 exists', () {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'seller_id': '660e8400-e29b-41d4-a716-446655440001',
          'title': 'Test',
          'category': 'dress',
          'price_cents': 5000,
          'condition': 'new',
          'country': 'France',
          'status': 'active',
          'created_at': '2026-02-04T10:00:00.000Z',
          'updated_at': '2026-02-04T10:00:00.000Z',
          'marketplace_photos': [
            {'storage_path': 'listing-1/photo_2.jpg', 'position': 2},
          ],
        };

        final listing = MarketplaceListing.fromJson(json);

        expect(listing.coverPhotoStoragePath, 'listing-1/photo_2.jpg');
      });

      test('should have null coverPhotoStoragePath when no photos', () {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'seller_id': '660e8400-e29b-41d4-a716-446655440001',
          'title': 'Test',
          'category': 'dress',
          'price_cents': 5000,
          'condition': 'new',
          'country': 'France',
          'status': 'active',
          'created_at': '2026-02-04T10:00:00.000Z',
          'updated_at': '2026-02-04T10:00:00.000Z',
          'marketplace_photos': [],
        };

        final listing = MarketplaceListing.fromJson(json);

        expect(listing.coverPhotoStoragePath, isNull);
      });

      test('should have null coverPhotoStoragePath when no join data', () {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'seller_id': '660e8400-e29b-41d4-a716-446655440001',
          'title': 'Test',
          'category': 'dress',
          'price_cents': 5000,
          'condition': 'new',
          'country': 'France',
          'status': 'active',
          'created_at': '2026-02-04T10:00:00.000Z',
          'updated_at': '2026-02-04T10:00:00.000Z',
        };

        final listing = MarketplaceListing.fromJson(json);

        expect(listing.coverPhotoStoragePath, isNull);
      });
    });

    // ==============================================================
    // TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should produce correct snake_case keys', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Beautiful Dress',
          description: 'Silk dress',
          category: 'dress',
          priceCents: 29999,
          displayCurrency: 'EUR',
          designerBrand: 'Vera Wang',
          size: '38',
          condition: 'new',
          sleeveLength: 'long',
          city: 'Paris',
          country: 'France',
          countryCode: 'FR',
          latitude: 48.8566,
          longitude: 2.3522,
          status: 'active',
          createdAt: now,
          updatedAt: now,
        );

        final json = listing.toJson();

        expect(json['seller_id'], 'seller-456');
        expect(json['title'], 'Beautiful Dress');
        expect(json['description'], 'Silk dress');
        expect(json['category'], 'dress');
        expect(json['price_cents'], 29999);
        expect(json['display_currency'], 'EUR');
        expect(json['designer_brand'], 'Vera Wang');
        expect(json['size'], '38');
        expect(json['condition'], 'new');
        expect(json['sleeve_length'], 'long');
        expect(json['city'], 'Paris');
        expect(json['country'], 'France');
        expect(json['country_code'], 'FR');
        expect(json['latitude'], 48.8566);
        expect(json['longitude'], 2.3522);
        expect(json['status'], 'active');
      });

      test('should exclude auto-generated fields (id, created_at, updated_at, sold_at)', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test',
          category: 'dress',
          priceCents: 10000,
          condition: 'new',
          country: 'France',
          status: 'draft',
          createdAt: now,
          updatedAt: now,
          soldAt: now,
        );

        final json = listing.toJson();

        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('created_at'), isFalse);
        expect(json.containsKey('updated_at'), isFalse);
        expect(json.containsKey('sold_at'), isFalse);
      });

      test('should include null optional fields', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test Shoes',
          category: 'shoes',
          priceCents: 5000,
          condition: 'new',
          country: 'France',
          status: 'draft',
          createdAt: now,
          updatedAt: now,
        );

        final json = listing.toJson();

        expect(json.containsKey('description'), isTrue);
        expect(json['description'], isNull);
        expect(json.containsKey('designer_brand'), isTrue);
        expect(json['designer_brand'], isNull);
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should provide readable string representation', () {
        final now = DateTime(2026, 2, 4);
        final listing = MarketplaceListing(
          id: 'listing-123',
          sellerId: 'seller-456',
          title: 'Test Dress',
          category: 'dress',
          priceCents: 29999,
          condition: 'new',
          country: 'France',
          status: 'active',
          createdAt: now,
          updatedAt: now,
        );

        final str = listing.toString();

        expect(str, contains('listing-123'));
        expect(str, contains('Test Dress'));
        expect(str, contains('dress'));
        expect(str, contains('29999'));
        expect(str, contains('active'));
      });
    });
  });
}
