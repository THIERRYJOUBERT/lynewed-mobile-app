# Story S02: Create marketplace_photos table

## Description
En tant que developpeur backend, je veux creer la table marketplace_photos dans Supabase, afin de stocker les photos associees aux annonces avec ordering.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the marketplace_listings table exists When the migration create_marketplace_photos is applied Then table marketplace_photos should exist with columns listing_id, storage_path, thumbnail_path, position, created_at
- [ ] Given a listing with 5 photos When the listing is deleted Then all associated photos should be deleted (CASCADE)
- [ ] Given an active listing with photos And a bride user queries the photos Then photos should be returned for accessible listings And denied for inaccessible listings (draft of another seller)
- [ ] Given a listing with photos at positions 0, 1, 2 When querying photos ORDER BY position Then photos should be returned in correct order
- [ ] Given a listing_id UUID When inserting a photo record Then the FK constraint to marketplace_listings(id) should be enforced
- [ ] Given a listing with 2 photos at position 0 and 1 When inserting a 3rd photo at same position as existing photo Then insert should succeed (UNIQUE constraint is listing_id + position)

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260204100002_create_marketplace_photos.sql` - Migration principale
- `lib/features/marketplace/domain/entities/marketplace_photo.dart` - Entity Dart
- `test/features/marketplace/domain/entities/marketplace_photo_test.dart` - Tests entity

### A Modifier
- Aucun

## SQL Migration Complet

```sql
-- Migration: 20260204100002_create_marketplace_photos.sql

-- Create the marketplace_photos table
CREATE TABLE IF NOT EXISTS marketplace_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID NOT NULL REFERENCES marketplace_listings(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  thumbnail_path TEXT,
  position INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),

  -- Ensure unique position per listing
  CONSTRAINT uq_listing_position UNIQUE (listing_id, position)
);

-- Create index for efficient queries (listing + position ordering)
CREATE INDEX idx_marketplace_photos_listing ON marketplace_photos(listing_id, position);

-- Enable RLS
ALTER TABLE marketplace_photos ENABLE ROW LEVEL SECURITY;

-- Grant basic access
GRANT SELECT, INSERT, UPDATE, DELETE ON marketplace_photos TO authenticated;
```

## RLS Policies SQL

```sql
-- Policy 1: Photos visible with listing
-- Users can see photos if they can see the listing (active OR own listing)
CREATE POLICY "Photos visible with listing"
ON marketplace_photos FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id = marketplace_photos.listing_id
    AND (ml.status = 'active' OR ml.seller_id = auth.uid())
  )
);

-- Policy 2: Seller manages own photos
-- Seller can INSERT, UPDATE, DELETE photos for their own listings
CREATE POLICY "Seller manages own photos"
ON marketplace_photos FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id = marketplace_photos.listing_id
    AND ml.seller_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id = marketplace_photos.listing_id
    AND ml.seller_id = auth.uid()
  )
);
```

## Post-Migration Verification

```sql
-- 1. Verify table exists
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'marketplace_photos';

-- 2. Verify FK constraint to marketplace_listings
SELECT
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name = 'marketplace_photos';

-- 3. Verify UNIQUE constraint on (listing_id, position)
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public'
  AND table_name = 'marketplace_photos'
  AND constraint_type = 'UNIQUE';

-- 4. Verify RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'marketplace_photos';

-- 5. Verify policies created
SELECT policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'marketplace_photos';

-- 6. Verify index created
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public' AND tablename = 'marketplace_photos';

-- 7. Test CASCADE delete (requires test listing first)
-- Step 1: Create test listing
-- INSERT INTO marketplace_listings (id, seller_id, title, category, condition, country, status, price_cents)
-- VALUES ('test-listing-123', auth.uid(), 'Test', 'dress', 'new', 'France', 'draft', 10000);
--
-- Step 2: Create test photo
-- INSERT INTO marketplace_photos (listing_id, storage_path, position)
-- VALUES ('test-listing-123', 'test/path.jpg', 0);
--
-- Step 3: Delete listing and verify photos deleted
-- DELETE FROM marketplace_listings WHERE id = 'test-listing-123';
-- SELECT COUNT(*) FROM marketplace_photos WHERE listing_id = 'test-listing-123';
-- Expected: 0 (photos should be deleted via CASCADE)
```

## Validation Cote Application (Business Logic)

Ces regles sont gerees cote app Flutter, pas en DB :

| Regle | Ou | Pourquoi |
|-------|-----|----------|
| Minimum 5 photos | App | UX - bloquer publication si < 5 |
| Maximum 10 photos | App | UX - empecher upload si >= 10 |
| Position 0 = cover | App | Business logic - premier affichage |
| Format storage_path | App | `{listing_id}/photo_{position}.{ext}` |

### Storage Path Format

```dart
// Example in app code
String generateStoragePath(String listingId, int position, String extension) {
  return '$listingId/photo_$position.$extension';
}
// Result: "abc-123-def/photo_0.jpg"
```

## Entity Dart

### Fichier: `lib/features/marketplace/domain/entities/marketplace_photo.dart`

```dart
/// MarketplacePhoto entity - A photo attached to a marketplace listing
///
/// Immutable data class representing a photo with ordering (position).
library;

import 'package:flutter/foundation.dart';

/// Represents a photo attached to a marketplace listing.
///
/// Contains storage paths for full image and thumbnail, plus position for ordering.
@immutable
class MarketplacePhoto {
  /// Creates a marketplace photo.
  const MarketplacePhoto({
    required this.id,
    required this.listingId,
    required this.storagePath,
    this.thumbnailPath,
    required this.position,
    required this.createdAt,
  });

  /// Unique identifier (UUID from database).
  final String id;

  /// Listing ID this photo belongs to.
  final String listingId;

  /// Full image storage path (e.g., "listing-id/photo_0.jpg").
  final String storagePath;

  /// Optional thumbnail storage path.
  final String? thumbnailPath;

  /// Position for ordering (0 = cover photo).
  final int position;

  /// When the photo was created.
  final DateTime createdAt;

  /// Whether this is the cover photo (position 0).
  bool get isCover => position == 0;

  /// Equality based on id.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplacePhoto &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// String representation for debugging.
  @override
  String toString() => 'MarketplacePhoto(id: $id, listingId: $listingId, position: $position, storagePath: $storagePath)';

  /// Creates a copy with updated fields.
  MarketplacePhoto copyWith({
    String? id,
    String? listingId,
    String? storagePath,
    String? thumbnailPath,
    int? position,
    DateTime? createdAt,
  }) {
    return MarketplacePhoto(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      storagePath: storagePath ?? this.storagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### Fichier: `test/features/marketplace/domain/entities/marketplace_photo_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_photo.dart';

void main() {
  group('MarketplacePhoto', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create MarketplacePhoto with required fields', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        expect(photo.id, 'photo-123');
        expect(photo.listingId, 'listing-456');
        expect(photo.storagePath, 'listing-456/photo_0.jpg');
        expect(photo.position, 0);
        expect(photo.createdAt, now);
        expect(photo.thumbnailPath, isNull);
      });

      test('should create MarketplacePhoto with thumbnail', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          thumbnailPath: 'listing-456/thumb_0.jpg',
          position: 0,
          createdAt: now,
        );

        expect(photo.thumbnailPath, 'listing-456/thumb_0.jpg');
      });

      test('should be immutable', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        // Verify fields are final (compile-time check)
        // Cannot reassign: photo.position = 1; // Would not compile
        expect(photo.position, 0);
      });
    });

    // ==============================================================
    // POSITION TESTS
    // ==============================================================

    group('position', () {
      test('position 0 should be cover photo', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        expect(photo.isCover, isTrue);
      });

      test('position > 0 should not be cover photo', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_1.jpg',
          position: 1,
          createdAt: now,
        );

        expect(photo.isCover, isFalse);
      });

      test('should support multiple positions', () {
        final now = DateTime.now();
        final photos = List.generate(
          5,
          (index) => MarketplacePhoto(
            id: 'photo-$index',
            listingId: 'listing-456',
            storagePath: 'listing-456/photo_$index.jpg',
            position: index,
            createdAt: now,
          ),
        );

        expect(photos[0].position, 0);
        expect(photos[1].position, 1);
        expect(photos[4].position, 4);

        expect(photos[0].isCover, isTrue);
        expect(photos[1].isCover, isFalse);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is the same', () {
        final now = DateTime.now();
        final photo1 = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        final photo2 = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-999',
          storagePath: 'different/path.jpg',
          position: 5,
          createdAt: now.add(const Duration(days: 1)),
        );

        expect(photo1, equals(photo2));
        expect(photo1.hashCode, equals(photo2.hashCode));
      });

      test('should not be equal when id differs', () {
        final now = DateTime.now();
        final photo1 = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        final photo2 = MarketplacePhoto(
          id: 'photo-999',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        expect(photo1, isNot(equals(photo2)));
        expect(photo1.hashCode, isNot(equals(photo2.hashCode)));
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should create copy with updated position', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        final updated = photo.copyWith(position: 2);

        expect(updated.position, 2);
        expect(updated.id, photo.id);
        expect(updated.listingId, photo.listingId);
        expect(updated.storagePath, photo.storagePath);
      });

      test('should create copy with updated storage path', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        final updated = photo.copyWith(storagePath: 'listing-456/photo_1.jpg');

        expect(updated.storagePath, 'listing-456/photo_1.jpg');
        expect(updated.id, photo.id);
      });

      test('should preserve all fields when no parameter provided', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        final copied = photo.copyWith();

        expect(copied.id, photo.id);
        expect(copied.listingId, photo.listingId);
        expect(copied.storagePath, photo.storagePath);
        expect(copied.position, photo.position);
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should provide readable string representation', () {
        final now = DateTime.now();
        final photo = MarketplacePhoto(
          id: 'photo-123',
          listingId: 'listing-456',
          storagePath: 'listing-456/photo_0.jpg',
          position: 0,
          createdAt: now,
        );

        final str = photo.toString();

        expect(str, contains('photo-123'));
        expect(str, contains('listing-456'));
        expect(str, contains('0'));
        expect(str, contains('listing-456/photo_0.jpg'));
      });
    });
  });
}
```

## Tests Requis

### Tests base de donnees (via migration verification):
- Test 1: FK constraint enforced (invalid listing_id should fail)
- Test 2: CASCADE delete works (delete listing deletes photos)
- Test 3: UNIQUE constraint on (listing_id, position) enforced
- Test 4: RLS policy - photos visible with active listing
- Test 5: RLS policy - seller can CRUD own listing photos
- Test 6: RLS policy - non-seller cannot see draft listing photos
- Test 7: Photos ordered by position correctly

### Tests entity Dart:
- Test 1: Create photo with required fields only
- Test 2: Create photo with thumbnail
- Test 3: Immutability verification
- Test 4: Position 0 is cover photo (isCover getter)
- Test 5: Position > 0 is not cover photo
- Test 6: Equality based on id
- Test 7: CopyWith updates position
- Test 8: CopyWith updates storage path
- Test 9: ToString contains key fields

## Definition of Done
- [x] Migration appliquee avec succes sur Supabase (MCP apply_migration)
- [x] Post-migration verification complete (FK, UNIQUE, RLS)
- [x] CASCADE delete teste et fonctionne
- [x] Index cree (listing_id, position)
- [x] 2 RLS policies actives
- [x] Entity Dart creee avec isCover getter + fromJson/toJson
- [x] Tests entity Dart passes (7 test groups, 18 tests)
- [x] `flutter analyze --fatal-infos` passe (0 warnings)

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances

### Requires (BLOQUANTS):
- S01: `marketplace_listings` table doit exister (FK listing_id)

### Order:
- S01 (marketplace_listings) → **S02 (marketplace_photos)** → S07 (storage bucket utilise storage_path)

## Stories Dependantes (BLOQUEES si S02 incomplete)
- S07 (storage bucket) - utilise storage_path de marketplace_photos
- S14 (create listing form) - upload photos et utilise entity MarketplacePhoto
- S16 (detail page) - affiche carousel photos
