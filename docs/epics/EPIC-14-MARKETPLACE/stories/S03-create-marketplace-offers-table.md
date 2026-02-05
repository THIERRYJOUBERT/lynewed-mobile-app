# Story S03: Create marketplace_offers table

## Description
En tant que developpeur backend, je veux creer la table marketplace_offers dans Supabase, afin de gerer les offres d'achat avec expiration automatique apres 48h.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the marketplace_listings table exists When the migration create_marketplace_offers is applied Then table marketplace_offers should exist with all required columns
- [ ] Given an offer created 48 hours ago with status 'pending' When checking offer status Then offer should be considered expired And the expire_marketplace_offers() function should update status to 'expired'
- [ ] Given a buyer with offers on multiple listings When the buyer queries marketplace_offers Then only their own offers should be returned (RLS)
- [ ] Given a seller with listings receiving offers When the seller queries marketplace_offers Then offers on their listings should be returned And offers on other listings should not be visible (RLS)
- [ ] Given a pending offer When buyer tries to withdraw Then status should change to 'withdrawn' only if it was 'pending'
- [ ] Given a pending offer When seller accepts Then status should change to 'accepted' And responded_at should be set
- [ ] Given a buyer trying to create an offer on their own listing Then the insert should be denied by RLS (can't offer on own listing)

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260204100003_create_marketplace_offers.sql` - Migration principale
- `lib/features/marketplace/domain/entities/marketplace_offer.dart` - Entity Dart
- `test/features/marketplace/domain/entities/marketplace_offer_test.dart` - Tests entity

### A Modifier
- Aucun

## SQL Migration Complet

```sql
-- Migration: 20260204100003_create_marketplace_offers.sql

-- Create the marketplace_offers table
CREATE TABLE IF NOT EXISTS marketplace_offers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID NOT NULL REFERENCES marketplace_listings(id) ON DELETE CASCADE,
  buyer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
  message TEXT,

  status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'accepted', 'rejected', 'expired', 'withdrawn')),

  expires_at TIMESTAMP NOT NULL DEFAULT (NOW() + INTERVAL '48 hours'),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  responded_at TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_marketplace_offers_listing ON marketplace_offers(listing_id, created_at DESC);
CREATE INDEX idx_marketplace_offers_buyer ON marketplace_offers(buyer_id, created_at DESC);
CREATE INDEX idx_marketplace_offers_status ON marketplace_offers(status, expires_at);
CREATE INDEX idx_marketplace_offers_expires_at ON marketplace_offers(expires_at) WHERE status = 'pending';

-- Create function to expire old offers
CREATE OR REPLACE FUNCTION expire_marketplace_offers()
RETURNS INTEGER AS $$
DECLARE
  expired_count INTEGER;
BEGIN
  UPDATE marketplace_offers
  SET status = 'expired'
  WHERE status = 'pending' AND expires_at < NOW();

  GET DIAGNOSTICS expired_count = ROW_COUNT;
  RETURN expired_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION expire_marketplace_offers() IS 'Updates pending offers past expires_at to expired. Returns count of expired offers.';

-- Create trigger for responded_at
CREATE OR REPLACE FUNCTION update_marketplace_offer_responded_at()
RETURNS TRIGGER AS $$
BEGIN
  -- Auto-set responded_at when status changes from pending to accepted/rejected
  IF OLD.status = 'pending' AND NEW.status IN ('accepted', 'rejected') AND NEW.responded_at IS NULL THEN
    NEW.responded_at = NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_marketplace_offers_responded_at
  BEFORE UPDATE ON marketplace_offers
  FOR EACH ROW
  EXECUTE FUNCTION update_marketplace_offer_responded_at();

-- Enable RLS
ALTER TABLE marketplace_offers ENABLE ROW LEVEL SECURITY;

-- Grant basic access
GRANT SELECT, INSERT, UPDATE, DELETE ON marketplace_offers TO authenticated;
```

## RLS Policies SQL

```sql
-- Policy 1: Buyer sees own offers
CREATE POLICY "Buyer sees own offers"
ON marketplace_offers FOR SELECT
TO authenticated
USING (buyer_id = auth.uid());

-- Policy 2: Seller sees listing offers
CREATE POLICY "Seller sees listing offers"
ON marketplace_offers FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id = marketplace_offers.listing_id
    AND ml.seller_id = auth.uid()
  )
);

-- Policy 3: Buyer creates offers (can't offer on own listing)
CREATE POLICY "Buyer creates offers"
ON marketplace_offers FOR INSERT
TO authenticated
WITH CHECK (
  buyer_id = auth.uid()
  AND NOT EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id = marketplace_offers.listing_id
    AND ml.seller_id = auth.uid()
  )
);

-- Policy 4: Buyer withdraws own offers
CREATE POLICY "Buyer withdraws offers"
ON marketplace_offers FOR UPDATE
TO authenticated
USING (buyer_id = auth.uid() AND status = 'pending')
WITH CHECK (buyer_id = auth.uid() AND status = 'withdrawn');

-- Policy 5: Seller responds to offers
CREATE POLICY "Seller responds to offers"
ON marketplace_offers FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id = marketplace_offers.listing_id
    AND ml.seller_id = auth.uid()
  )
  AND status = 'pending'
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id = marketplace_offers.listing_id
    AND ml.seller_id = auth.uid()
  )
  AND status IN ('accepted', 'rejected')
);
```

## Post-Migration Verification

```sql
-- 1. Verify table exists
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'marketplace_offers';

-- 2. Verify FK constraints
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
  AND tc.table_name = 'marketplace_offers';

-- 3. Verify CHECK constraints
SELECT constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_schema = 'public'
  AND constraint_name LIKE '%marketplace_offers%';

-- 4. Verify RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'marketplace_offers';

-- 5. Verify policies created
SELECT policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'marketplace_offers';

-- 6. Verify indexes created
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public' AND tablename = 'marketplace_offers';

-- 7. Verify function exists
SELECT proname, prosrc
FROM pg_proc
WHERE proname = 'expire_marketplace_offers';

-- 8. Verify trigger exists
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE event_object_schema = 'public'
  AND event_object_table = 'marketplace_offers';

-- 9. Test function expire_marketplace_offers()
-- SELECT expire_marketplace_offers();
-- Expected: Returns count of expired offers (likely 0 if no test data)

-- 10. Test constraint: amount_cents <= 0 (should FAIL)
-- INSERT INTO marketplace_offers (listing_id, buyer_id, amount_cents, status)
-- VALUES ('valid-listing-id', auth.uid(), 0, 'pending');
-- Expected: ERROR:  new row violates check constraint "marketplace_offers_amount_cents_check"

-- 11. Test constraint: invalid status (should FAIL)
-- INSERT INTO marketplace_offers (listing_id, buyer_id, amount_cents, status)
-- VALUES ('valid-listing-id', auth.uid(), 10000, 'invalid_status');
-- Expected: ERROR:  new row violates check constraint "marketplace_offers_status_check"
```

## Cron Job Setup (Edge Function)

### Option 1: pg_cron Extension (Supabase Pro)

```sql
-- If pg_cron is available (Supabase Pro plan)
SELECT cron.schedule(
  'expire-marketplace-offers',
  '0 * * * *', -- Every hour
  $$SELECT expire_marketplace_offers();$$
);
```

### Option 2: Edge Function + GitHub Actions (Recommended)

Creer Edge Function `expire-offers`:

```typescript
// supabase/functions/expire-offers/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

Deno.serve(async (req: Request) => {
  // Verify secret to prevent unauthorized calls
  const authHeader = req.headers.get('Authorization');
  if (authHeader !== `Bearer ${Deno.env.get('CRON_SECRET')}`) {
    return new Response('Unauthorized', { status: 401 });
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  );

  const { data, error } = await supabase.rpc('expire_marketplace_offers');

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  return new Response(JSON.stringify({ expired_count: data }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

GitHub Actions workflow:

```yaml
# .github/workflows/expire-offers-cron.yml
name: Expire Marketplace Offers

on:
  schedule:
    - cron: '0 * * * *' # Every hour

jobs:
  expire-offers:
    runs-on: ubuntu-latest
    steps:
      - name: Call Supabase Edge Function
        run: |
          curl -X POST \
            -H "Authorization: Bearer ${{ secrets.SUPABASE_CRON_SECRET }}" \
            https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/expire-offers
```

## Entity Dart

### Fichier: `lib/features/marketplace/domain/entities/marketplace_offer.dart`

```dart
/// MarketplaceOffer entity - An offer made by a buyer on a listing
///
/// Immutable data class representing an offer with expiration (48h).
library;

import 'package:flutter/foundation.dart';

/// Represents an offer made by a buyer on a marketplace listing.
///
/// Contains amount, optional message, status, and expiration timestamp.
@immutable
class MarketplaceOffer {
  /// Creates a marketplace offer.
  const MarketplaceOffer({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.amountCents,
    this.message,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.respondedAt,
  });

  /// Unique identifier (UUID from database).
  final String id;

  /// Listing ID this offer is for.
  final String listingId;

  /// Buyer ID who made this offer.
  final String buyerId;

  /// Offer amount in cents (e.g., 20000 = $200.00).
  final int amountCents;

  /// Optional message from buyer to seller.
  final String? message;

  /// Status: 'pending', 'accepted', 'rejected', 'expired', 'withdrawn'.
  final String status;

  /// When this offer expires (default 48h from creation).
  final DateTime expiresAt;

  /// When the offer was created.
  final DateTime createdAt;

  /// When the seller responded (accepted/rejected).
  final DateTime? respondedAt;

  /// Whether this offer is still pending.
  bool get isPending => status == 'pending';

  /// Whether this offer was accepted.
  bool get isAccepted => status == 'accepted';

  /// Whether this offer is expired.
  bool get isExpired => status == 'expired' || (isPending && DateTime.now().isAfter(expiresAt));

  /// Equality based on id.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplaceOffer &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// String representation for debugging.
  @override
  String toString() => 'MarketplaceOffer(id: $id, listingId: $listingId, amountCents: $amountCents, status: $status)';

  /// Creates a copy with updated fields.
  MarketplaceOffer copyWith({
    String? id,
    String? listingId,
    String? buyerId,
    int? amountCents,
    String? message,
    String? status,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return MarketplaceOffer(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      buyerId: buyerId ?? this.buyerId,
      amountCents: amountCents ?? this.amountCents,
      message: message ?? this.message,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
```

### Fichier: `test/features/marketplace/domain/entities/marketplace_offer_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_offer.dart';

void main() {
  group('MarketplaceOffer', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create MarketplaceOffer with required fields', () {
        final now = DateTime.now();
        final expiresAt = now.add(const Duration(hours: 48));
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: expiresAt,
          createdAt: now,
        );

        expect(offer.id, 'offer-123');
        expect(offer.listingId, 'listing-456');
        expect(offer.buyerId, 'buyer-789');
        expect(offer.amountCents, 25000);
        expect(offer.status, 'pending');
        expect(offer.expiresAt, expiresAt);
        expect(offer.createdAt, now);
        expect(offer.message, isNull);
        expect(offer.respondedAt, isNull);
      });

      test('should create MarketplaceOffer with optional fields', () {
        final now = DateTime.now();
        final expiresAt = now.add(const Duration(hours: 48));
        final respondedAt = now.add(const Duration(hours: 2));
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          message: 'Interested in this dress',
          status: 'accepted',
          expiresAt: expiresAt,
          createdAt: now,
          respondedAt: respondedAt,
        );

        expect(offer.message, 'Interested in this dress');
        expect(offer.respondedAt, respondedAt);
      });

      test('should be immutable', () {
        final now = DateTime.now();
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        // Verify fields are final (compile-time check)
        // Cannot reassign: offer.status = 'accepted'; // Would not compile
        expect(offer.status, 'pending');
      });
    });

    // ==============================================================
    // STATUS TESTS
    // ==============================================================

    group('status helpers', () {
      test('isPending should be true when status is pending', () {
        final now = DateTime.now();
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        expect(offer.isPending, isTrue);
      });

      test('isPending should be false when status is not pending', () {
        final now = DateTime.now();
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'accepted',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        expect(offer.isPending, isFalse);
      });

      test('isAccepted should be true when status is accepted', () {
        final now = DateTime.now();
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'accepted',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        expect(offer.isAccepted, isTrue);
      });

      test('isExpired should be true when status is expired', () {
        final now = DateTime.now();
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'expired',
          expiresAt: now.subtract(const Duration(hours: 1)),
          createdAt: now,
        );

        expect(offer.isExpired, isTrue);
      });

      test('isExpired should be true when pending and past expires_at', () {
        final now = DateTime.now();
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.subtract(const Duration(hours: 1)), // Expired
          createdAt: now,
        );

        expect(offer.isExpired, isTrue);
      });

      test('isExpired should be false when pending and before expires_at', () {
        final now = DateTime.now();
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)), // Not expired
          createdAt: now,
        );

        expect(offer.isExpired, isFalse);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is the same', () {
        final now = DateTime.now();
        final offer1 = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        final offer2 = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-999',
          buyerId: 'buyer-999',
          amountCents: 50000,
          status: 'accepted',
          expiresAt: now,
          createdAt: now,
        );

        expect(offer1, equals(offer2));
        expect(offer1.hashCode, equals(offer2.hashCode));
      });

      test('should not be equal when id differs', () {
        final now = DateTime.now();
        final offer1 = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        final offer2 = MarketplaceOffer(
          id: 'offer-999',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        expect(offer1, isNot(equals(offer2)));
        expect(offer1.hashCode, isNot(equals(offer2.hashCode)));
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should create copy with updated status', () {
        final now = DateTime.now();
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        final updated = offer.copyWith(status: 'accepted');

        expect(updated.status, 'accepted');
        expect(updated.id, offer.id);
        expect(updated.amountCents, offer.amountCents);
      });

      test('should create copy with updated responded_at', () {
        final now = DateTime.now();
        final respondedAt = now.add(const Duration(hours: 2));
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        final updated = offer.copyWith(respondedAt: respondedAt);

        expect(updated.respondedAt, respondedAt);
        expect(updated.id, offer.id);
      });

      test('should preserve all fields when no parameter provided', () {
        final now = DateTime.now();
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        final copied = offer.copyWith();

        expect(copied.id, offer.id);
        expect(copied.status, offer.status);
        expect(copied.amountCents, offer.amountCents);
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should provide readable string representation', () {
        final now = DateTime.now();
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        final str = offer.toString();

        expect(str, contains('offer-123'));
        expect(str, contains('listing-456'));
        expect(str, contains('25000'));
        expect(str, contains('pending'));
      });
    });
  });
}
```

## Tests Requis

### Tests base de donnees (via migration verification):
- Test 1: FK constraints enforced (invalid listing_id or buyer_id should fail)
- Test 2: CHECK constraint amount_cents > 0
- Test 3: CHECK constraint status valid values
- Test 4: Default expires_at is NOW() + 48 hours
- Test 5: Function expire_marketplace_offers() updates pending offers past expires_at
- Test 6: RLS policy - buyer sees own offers
- Test 7: RLS policy - seller sees offers on their listings
- Test 8: RLS policy - buyer cannot offer on own listing (INSERT denied)
- Test 9: RLS policy - buyer can withdraw own pending offers
- Test 10: RLS policy - seller can respond (accept/reject) to offers
- Test 11: Trigger auto-sets responded_at when status changes to accepted/rejected

### Tests entity Dart:
- Test 1: Create offer with required fields only
- Test 2: Create offer with optional fields (message, respondedAt)
- Test 3: Immutability verification
- Test 4: isPending helper when status is pending
- Test 5: isAccepted helper when status is accepted
- Test 6: isExpired helper when status is expired
- Test 7: isExpired helper when pending and past expires_at
- Test 8: Equality based on id
- Test 9: CopyWith updates status
- Test 10: CopyWith updates responded_at
- Test 11: ToString contains key fields

## Definition of Done
- [ ] Migration appliquee avec succes sur Supabase (MCP apply_migration)
- [ ] Post-migration verification complete (FK, CHECK, indexes, function, trigger)
- [ ] Function expire_marketplace_offers() creee et testee
- [ ] Cron job configure (pg_cron OU Edge Function + GitHub Actions)
- [ ] 4 indexes crees (listing, buyer, status, expires_at)
- [ ] 5 RLS policies actives
- [ ] Trigger responded_at fonctionne
- [ ] Entity Dart creee avec helpers isPending/isAccepted/isExpired
- [ ] Tests entity Dart passes (11 test groups, ~20 tests)
- [ ] `flutter analyze --fatal-infos` passe (0 warnings)

## Estimation
**Points** : 3
**Complexite** : Faible
**Risque** : Faible

## Dependances

### Requires (BLOQUANTS):
- S01: `marketplace_listings` table doit exister (FK listing_id)
- Database: `profiles` table doit exister (FK buyer_id)

### Order:
- S01 (marketplace_listings) → **S03 (marketplace_offers)**

## Stories Dependantes (BLOQUEES si S03 incomplete)
- S04 (marketplace_transactions) - optional FK offer_id vers marketplace_offers
- S19 (systeme d'offres frontend) - utilise entity MarketplaceOffer
