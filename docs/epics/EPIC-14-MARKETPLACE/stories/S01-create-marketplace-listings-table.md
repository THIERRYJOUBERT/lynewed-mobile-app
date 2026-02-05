# Story S01: Create marketplace_listings table

## Description
En tant que developpeur backend, je veux creer la table marketplace_listings dans Supabase, afin de stocker les annonces de robes et chaussures de mariage.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the database schema When the migration create_marketplace_listings is applied Then table marketplace_listings should exist with all required columns
- [ ] Given the marketplace_listings table When inserting a listing with status 'invalid' Then the insert should fail with constraint violation (only 'draft', 'active', 'reserved', 'sold', 'deleted' allowed)
- [ ] Given active listings in the marketplace And a bride user authenticated When the bride queries marketplace_listings WHERE status = 'active' Then all active listings should be returned
- [ ] Given a seller with listings When the seller updates their own listing Then the update should succeed And when a different user tries to update Then the update should be denied by RLS
- [ ] Given a listing with price 299.99 USD When stored in database Then price_cents should be 29999 (USD cents)
- [ ] Given a dress listing When inserting without sleeve_length Then the insert should fail (sleeve_length required for dresses)
- [ ] Given a shoes listing When inserting without sleeve_length Then the insert should succeed (sleeve_length NULL allowed for shoes)

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260204100001_create_marketplace_listings.sql` - Migration principale
- `lib/features/marketplace/domain/entities/marketplace_listing.dart` - Entity Dart
- `test/features/marketplace/domain/entities/marketplace_listing_test.dart` - Tests entity

### A Modifier
- Aucun

## SQL Migration Complet

```sql
-- Migration: 20260204100001_create_marketplace_listings.sql

-- Create the marketplace_listings table
CREATE TABLE IF NOT EXISTS marketplace_listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  -- Product info
  title VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(20) NOT NULL CHECK (category IN ('dress', 'shoes')),
  price_cents INTEGER NOT NULL CHECK (price_cents > 0),
  display_currency VARCHAR(3) NOT NULL DEFAULT 'USD',

  -- Attributes
  designer_brand VARCHAR(255),
  size VARCHAR(50),
  condition VARCHAR(20) NOT NULL CHECK (condition IN ('new', 'excellent', 'good', 'fair')),
  sleeve_length VARCHAR(20), -- Required for dresses, NULL for shoes

  -- Location (simple DECIMAL for now, no PostGIS)
  city VARCHAR(255),
  country VARCHAR(100) NOT NULL,
  country_code VARCHAR(2),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),

  -- Status
  status VARCHAR(20) NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'active', 'reserved', 'sold', 'deleted')),

  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  sold_at TIMESTAMP,

  -- Constraint: sleeve_length required for dresses
  CONSTRAINT chk_sleeve_length_for_dress CHECK (
    (category = 'dress' AND sleeve_length IS NOT NULL) OR
    (category = 'shoes')
  )
);

-- Create indexes
CREATE INDEX idx_marketplace_listings_status ON marketplace_listings(status);
CREATE INDEX idx_marketplace_listings_seller ON marketplace_listings(seller_id);
CREATE INDEX idx_marketplace_listings_category ON marketplace_listings(category, status);
CREATE INDEX idx_marketplace_listings_location ON marketplace_listings(latitude, longitude) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
CREATE INDEX idx_marketplace_listings_price ON marketplace_listings(price_cents);

-- Create trigger for updated_at
CREATE TRIGGER trg_marketplace_listings_updated_at
  BEFORE UPDATE ON marketplace_listings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE marketplace_listings ENABLE ROW LEVEL SECURITY;

-- Grant basic access
GRANT SELECT, INSERT, UPDATE, DELETE ON marketplace_listings TO authenticated;
```

## RLS Policies SQL

```sql
-- Policy 1: Active listings visible to all authenticated brides
CREATE POLICY "Active listings visible to all"
ON marketplace_listings FOR SELECT
TO authenticated
USING (status = 'active');

-- Policy 2: Seller views own listings (all statuses)
CREATE POLICY "Seller views own listings"
ON marketplace_listings FOR SELECT
TO authenticated
USING (seller_id = auth.uid());

-- Policy 3: Seller creates listings
CREATE POLICY "Seller creates listings"
ON marketplace_listings FOR INSERT
TO authenticated
WITH CHECK (seller_id = auth.uid());

-- Policy 4: Seller updates own listings
CREATE POLICY "Seller updates own listings"
ON marketplace_listings FOR UPDATE
TO authenticated
USING (seller_id = auth.uid())
WITH CHECK (seller_id = auth.uid());

-- Policy 5: Seller deletes own listings (soft delete via status)
CREATE POLICY "Seller deletes own listings"
ON marketplace_listings FOR UPDATE
TO authenticated
USING (seller_id = auth.uid() AND status = 'deleted')
WITH CHECK (seller_id = auth.uid() AND status = 'deleted');
```

## Post-Migration Verification

```sql
-- 1. Verify table exists
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'marketplace_listings';

-- 2. Verify RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'marketplace_listings';

-- 3. Verify policies created
SELECT policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'marketplace_listings';

-- 4. Verify indexes created
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public' AND tablename = 'marketplace_listings';

-- 5. Verify trigger exists
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE event_object_schema = 'public' AND event_object_table = 'marketplace_listings';

-- 6. Test constraint: status invalid (should FAIL)
-- INSERT INTO marketplace_listings (seller_id, title, category, condition, country, status, price_cents)
-- VALUES (auth.uid(), 'Test', 'dress', 'new', 'France', 'invalid', 10000);
-- Expected: ERROR:  new row for relation "marketplace_listings" violates check constraint

-- 7. Test constraint: dress without sleeve_length (should FAIL)
-- INSERT INTO marketplace_listings (seller_id, title, category, condition, country, status, price_cents)
-- VALUES (auth.uid(), 'Test Dress', 'dress', 'new', 'France', 'draft', 10000);
-- Expected: ERROR:  new row violates check constraint "chk_sleeve_length_for_dress"

-- 8. Test valid insert: shoes without sleeve_length (should SUCCEED)
-- INSERT INTO marketplace_listings (seller_id, title, category, condition, country, status, price_cents, sleeve_length)
-- VALUES (auth.uid(), 'Test Shoes', 'shoes', 'new', 'France', 'draft', 5000, NULL);
-- Expected: Success

-- 9. Test price_cents constraint (should FAIL if <= 0)
-- INSERT INTO marketplace_listings (seller_id, title, category, condition, country, status, price_cents)
-- VALUES (auth.uid(), 'Test', 'shoes', 'new', 'France', 'draft', 0);
-- Expected: ERROR:  new row violates check constraint "marketplace_listings_price_cents_check"
```

## Entity Dart

### Fichier: `lib/features/marketplace/domain/entities/marketplace_listing.dart`

```dart
/// MarketplaceListing entity - A wedding dress or shoes listing
///
/// Immutable data class representing a marketplace item (dress or shoes)
/// listed for sale by a bride.
library;

import 'package:flutter/foundation.dart';

/// Represents a marketplace listing for wedding dress or shoes.
///
/// Contains product details, pricing, location, and status.
@immutable
class MarketplaceListing {
  /// Creates a marketplace listing.
  const MarketplaceListing({
    required this.id,
    required this.sellerId,
    required this.title,
    this.description,
    required this.category,
    required this.priceCents,
    this.displayCurrency = 'USD',
    this.designerBrand,
    this.size,
    required this.condition,
    this.sleeveLength,
    this.city,
    required this.country,
    this.countryCode,
    this.latitude,
    this.longitude,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.soldAt,
  });

  /// Unique identifier (UUID from database).
  final String id;

  /// Seller ID (profile UUID).
  final String sellerId;

  /// Listing title (max 255 chars).
  final String title;

  /// Optional description.
  final String? description;

  /// Category: 'dress' or 'shoes'.
  final String category;

  /// Price in cents (e.g., 29999 = $299.99).
  final int priceCents;

  /// Display currency (default USD).
  final String displayCurrency;

  /// Optional designer/brand.
  final String? designerBrand;

  /// Optional size.
  final String? size;

  /// Condition: 'new', 'excellent', 'good', or 'fair'.
  final String condition;

  /// Sleeve length (required for dresses, null for shoes).
  final String? sleeveLength;

  /// City (optional).
  final String? city;

  /// Country (required).
  final String country;

  /// Country code (2 chars).
  final String? countryCode;

  /// Latitude (for geospatial queries).
  final double? latitude;

  /// Longitude (for geospatial queries).
  final double? longitude;

  /// Status: 'draft', 'active', 'reserved', 'sold', 'deleted'.
  final String status;

  /// When the listing was created.
  final DateTime createdAt;

  /// When the listing was last updated.
  final DateTime updatedAt;

  /// When the listing was sold (if applicable).
  final DateTime? soldAt;

  /// Equality based on id.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplaceListing &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// String representation for debugging.
  @override
  String toString() => 'MarketplaceListing(id: $id, title: $title, category: $category, priceCents: $priceCents, status: $status)';

  /// Creates a copy with updated fields.
  MarketplaceListing copyWith({
    String? id,
    String? sellerId,
    String? title,
    String? description,
    String? category,
    int? priceCents,
    String? displayCurrency,
    String? designerBrand,
    String? size,
    String? condition,
    String? sleeveLength,
    String? city,
    String? country,
    String? countryCode,
    double? latitude,
    double? longitude,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? soldAt,
  }) {
    return MarketplaceListing(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priceCents: priceCents ?? this.priceCents,
      displayCurrency: displayCurrency ?? this.displayCurrency,
      designerBrand: designerBrand ?? this.designerBrand,
      size: size ?? this.size,
      condition: condition ?? this.condition,
      sleeveLength: sleeveLength ?? this.sleeveLength,
      city: city ?? this.city,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      soldAt: soldAt ?? this.soldAt,
    );
  }
}
```

### Fichier: `test/features/marketplace/domain/entities/marketplace_listing_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_listing.dart';

void main() {
  group('MarketplaceListing', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create MarketplaceListing with required fields', () {
        final now = DateTime.now();
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
        expect(listing.displayCurrency, 'USD'); // default
      });

      test('should create MarketplaceListing with all optional fields', () {
        final now = DateTime.now();
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
        final now = DateTime.now();
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
        // Cannot reassign: listing.title = 'New Title'; // Would not compile
        expect(listing.title, 'Test');
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is the same', () {
        final now = DateTime.now();
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
        final now = DateTime.now();
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
        final now = DateTime.now();
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
        final now = DateTime.now();
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
        final now = DateTime.now();
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

        final copied = listing.copyWith();

        expect(copied.id, listing.id);
        expect(copied.title, listing.title);
        expect(copied.status, listing.status);
      });
    });

    // ==============================================================
    // PRICE TESTS
    // ==============================================================

    group('price validation', () {
      test('should store price 299.99 USD as 29999 cents', () {
        final now = DateTime.now();
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
    });

    // ==============================================================
    // CATEGORY TESTS
    // ==============================================================

    group('category', () {
      test('should accept dress category', () {
        final now = DateTime.now();
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
        final now = DateTime.now();
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
        final now = DateTime.now();
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
        final now = DateTime.now();
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
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should provide readable string representation', () {
        final now = DateTime.now();
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
```

## Tests Requis

### Tests base de donnees (via migration verification):
- Test 1: Insert with invalid status should fail (constraint violation)
- Test 2: Dress without sleeve_length should fail (CHECK constraint)
- Test 3: Shoes without sleeve_length should succeed
- Test 4: Price_cents <= 0 should fail (CHECK constraint)
- Test 5: RLS policy - active listings visible to all authenticated users
- Test 6: RLS policy - seller can update own listings
- Test 7: RLS policy - non-seller cannot update listing
- Test 8: Trigger - updated_at auto-updates on UPDATE

### Tests entity Dart:
- Test 1: Create listing with required fields only
- Test 2: Create listing with all optional fields
- Test 3: Immutability verification
- Test 4: Equality based on id
- Test 5: CopyWith updates specific field
- Test 6: Price conversion cents to dollars
- Test 7: Category validation (dress/shoes)
- Test 8: Sleeve length for dress vs shoes
- Test 9: ToString contains key fields

## Definition of Done
- [ ] Migration appliquee avec succes sur Supabase (MCP apply_migration)
- [ ] Post-migration verification complete (tous les SELECT retournent resultat attendu)
- [ ] Tous les index crees (5 indexes)
- [ ] 5 RLS policies actives
- [ ] Trigger updated_at fonctionne
- [ ] Entity Dart creee avec tous les champs
- [ ] Tests entity Dart passes (9 test groups, ~20 tests)
- [ ] `flutter analyze --fatal-infos` passe (0 warnings)

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances

### Requires (BLOQUANTS):
- EPIC-11: `stripe_accounts` table doit exister (pour verification vendeur lors de publication)
- Database: `profiles` table doit exister (FK seller_id)
- Database: `update_updated_at_column()` function doit exister (trigger)

### Order:
- Doit etre executee EN PREMIER dans EPIC-14 (toutes les autres stories DB dependent de celle-ci)

## Stories Dependantes (BLOQUEES si S01 incomplete)
- S02 (marketplace_photos) - FK vers marketplace_listings
- S03 (marketplace_offers) - FK vers marketplace_listings
- S04 (marketplace_transactions) - FK vers marketplace_listings
- S05 (marketplace_messages) - FK vers marketplace_listings
- S07 (storage bucket) - RLS JOIN sur marketplace_listings
- S14 (create listing form) - utilise entity MarketplaceListing
- S15 (feed) - query marketplace_listings
- S16 (detail page) - affiche MarketplaceListing
- S24 (map markers) - utilise latitude/longitude
- S25 (seller dashboard) - query seller's listings
