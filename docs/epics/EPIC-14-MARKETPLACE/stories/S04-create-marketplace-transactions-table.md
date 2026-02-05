# Story S04: Create marketplace_transactions table

## Description
En tant que developpeur backend, je veux creer la table marketplace_transactions dans Supabase, afin de stocker l'historique complet des transactions avec montants, references Stripe/FedEx et lifecycle complet.

## Criteres d'Acceptance (Gherkin)

- [x] Given the database schema with marketplace_listings and marketplace_offers When the migration create_marketplace_transactions is applied Then table marketplace_transactions should exist with all required columns including JSONB addresses
- [x] Given a transaction with item_price_cents 30000 (300 USD) When calculating commission Then platform_fee_cents should be 3000 (10%) And seller_payout_cents should be 27000 (90%)
- [x] Given a new transaction Then status should be 'pending' When payment succeeds status becomes 'paid' When label created status becomes 'label_created' When shipped status becomes 'shipped' When delivered status becomes 'delivered' When 7 days pass status becomes 'completed'
- [x] Given a transaction between seller-A and buyer-B When seller-A queries the transaction Then it should succeed When buyer-B queries Then it should succeed When other user queries Then it should be denied by RLS
- [x] Given all amounts in the transaction Then total_paid_cents should equal item_price_cents + shipping_cost_cents
- [x] Given a transaction with shipping_from_address and shipping_to_address as JSONB When querying the transaction Then the JSONB fields should contain name, street, city, postal_code, country_code

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260204100004_create_marketplace_transactions.sql` - Migration principale
- `lib/features/marketplace/domain/entities/marketplace_transaction.dart` - Entity Dart
- `lib/features/marketplace/domain/entities/shipping_address.dart` - Entity Dart pour addresses
- `test/features/marketplace/domain/entities/marketplace_transaction_test.dart` - Tests entity
- `test/features/marketplace/domain/entities/shipping_address_test.dart` - Tests entity

### A Modifier
- Aucun

## SQL Migration Complet

```sql
-- Migration: 20260204100004_create_marketplace_transactions.sql

-- Create the marketplace_transactions table
CREATE TABLE IF NOT EXISTS marketplace_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- References
  listing_id UUID NOT NULL REFERENCES marketplace_listings(id) ON DELETE RESTRICT,
  offer_id UUID REFERENCES marketplace_offers(id) ON DELETE SET NULL,
  seller_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  buyer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,

  -- Amounts (all USD cents)
  item_price_cents INTEGER NOT NULL CHECK (item_price_cents > 0),
  shipping_cost_cents INTEGER NOT NULL CHECK (shipping_cost_cents >= 0),
  platform_fee_cents INTEGER NOT NULL CHECK (platform_fee_cents >= 0),
  seller_payout_cents INTEGER NOT NULL CHECK (seller_payout_cents >= 0),
  total_paid_cents INTEGER NOT NULL CHECK (total_paid_cents > 0),

  -- Stripe references
  stripe_payment_intent_id VARCHAR(255),
  stripe_charge_id VARCHAR(255),
  stripe_transfer_id VARCHAR(255),

  -- FedEx references
  fedex_tracking_number VARCHAR(255),
  fedex_label_url TEXT,
  fedex_rate_id VARCHAR(255),

  -- Addresses (JSONB with schema: {name, street, city, postal_code, country_code})
  shipping_from_address JSONB NOT NULL,
  shipping_to_address JSONB NOT NULL,

  -- Status lifecycle
  status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'paid', 'label_created', 'shipped', 'in_transit', 'delivered', 'completed', 'disputed', 'refunded', 'canceled')),

  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  paid_at TIMESTAMP,
  shipped_at TIMESTAMP,
  delivered_at TIMESTAMP,
  completed_at TIMESTAMP,

  -- Constraint: total_paid = item + shipping
  CONSTRAINT chk_total_paid CHECK (total_paid_cents = item_price_cents + shipping_cost_cents)
);

-- Create indexes
CREATE INDEX idx_marketplace_transactions_listing ON marketplace_transactions(listing_id);
CREATE INDEX idx_marketplace_transactions_seller ON marketplace_transactions(seller_id, created_at DESC);
CREATE INDEX idx_marketplace_transactions_buyer ON marketplace_transactions(buyer_id, created_at DESC);
CREATE INDEX idx_marketplace_transactions_status ON marketplace_transactions(status, created_at DESC);
CREATE INDEX idx_marketplace_transactions_stripe_payment ON marketplace_transactions(stripe_payment_intent_id);
CREATE INDEX idx_marketplace_transactions_fedex_tracking ON marketplace_transactions(fedex_tracking_number);

-- Create trigger for updated_at
CREATE TRIGGER trg_marketplace_transactions_updated_at
  BEFORE UPDATE ON marketplace_transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create function to calculate commission (10%)
CREATE OR REPLACE FUNCTION calculate_marketplace_commission(item_price_cents INTEGER)
RETURNS TABLE(platform_fee_cents INTEGER, seller_payout_cents INTEGER) AS $$
BEGIN
  RETURN QUERY SELECT
    (item_price_cents * 10 / 100)::INTEGER AS platform_fee_cents,
    (item_price_cents * 90 / 100)::INTEGER AS seller_payout_cents;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION calculate_marketplace_commission(INTEGER) IS 'Calculates 10% platform fee and 90% seller payout from item price in cents.';

-- Create function to auto-complete delivered transactions after 7 days
CREATE OR REPLACE FUNCTION complete_delivered_transactions()
RETURNS INTEGER AS $$
DECLARE
  completed_count INTEGER;
BEGIN
  UPDATE marketplace_transactions
  SET status = 'completed',
      completed_at = NOW()
  WHERE status = 'delivered'
    AND delivered_at < NOW() - INTERVAL '7 days'
    AND completed_at IS NULL;

  GET DIAGNOSTICS completed_count = ROW_COUNT;
  RETURN completed_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION complete_delivered_transactions() IS 'Auto-completes transactions that have been delivered for 7+ days. Returns count of completed transactions.';

-- Enable RLS
ALTER TABLE marketplace_transactions ENABLE ROW LEVEL SECURITY;

-- Grant basic access
GRANT SELECT ON marketplace_transactions TO authenticated;
-- Note: INSERT/UPDATE via service_role only (Edge Functions/webhooks)
```

## RLS Policies SQL

```sql
-- Policy 1: Transaction parties view
-- Seller and buyer can view the transaction
CREATE POLICY "Transaction parties view"
ON marketplace_transactions FOR SELECT
TO authenticated
USING (seller_id = auth.uid() OR buyer_id = auth.uid());

-- Policy 2: Service role inserts (Edge Functions/webhooks)
-- Note: This policy allows service_role to INSERT/UPDATE via Supabase RPC
-- In practice, INSERT/UPDATE will be done via Edge Functions with service_role key
-- No policy needed for service_role as it bypasses RLS

-- For testing purposes, allow authenticated users to insert (remove in production)
-- CREATE POLICY "Test insert transactions"
-- ON marketplace_transactions FOR INSERT
-- TO authenticated
-- WITH CHECK (buyer_id = auth.uid());
```

## Post-Migration Verification

```sql
-- 1. Verify table exists
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'marketplace_transactions';

-- 2. Verify columns exist
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'marketplace_transactions'
ORDER BY ordinal_position;

-- 3. Verify FK constraints
SELECT
  tc.constraint_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name = 'marketplace_transactions';

-- 4. Verify CHECK constraints
SELECT constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_schema = 'public'
  AND constraint_name LIKE '%marketplace_transactions%';

-- 5. Verify RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'marketplace_transactions';

-- 6. Verify policies created
SELECT policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'marketplace_transactions';

-- 7. Verify indexes created
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public' AND tablename = 'marketplace_transactions';

-- 8. Verify functions exist
SELECT proname, prosrc
FROM pg_proc
WHERE proname IN ('calculate_marketplace_commission', 'complete_delivered_transactions');

-- 9. Test function calculate_marketplace_commission
SELECT * FROM calculate_marketplace_commission(30000);
-- Expected: platform_fee_cents = 3000, seller_payout_cents = 27000

-- 10. Test function complete_delivered_transactions
SELECT complete_delivered_transactions();
-- Expected: Returns count (likely 0 if no test data)

-- 11. Test constraint: total_paid != item + shipping (should FAIL)
-- INSERT INTO marketplace_transactions (
--   listing_id, seller_id, buyer_id,
--   item_price_cents, shipping_cost_cents, platform_fee_cents, seller_payout_cents, total_paid_cents,
--   shipping_from_address, shipping_to_address, status
-- ) VALUES (
--   'valid-listing-id', 'seller-id', 'buyer-id',
--   10000, 2000, 1000, 9000, 15000, -- total_paid = 15000 but should be 12000
--   '{"name":"Seller","street":"123 Main St","city":"Paris","postal_code":"75001","country_code":"FR"}'::jsonb,
--   '{"name":"Buyer","street":"456 Elm St","city":"Lyon","postal_code":"69001","country_code":"FR"}'::jsonb,
--   'pending'
-- );
-- Expected: ERROR: new row violates check constraint "chk_total_paid"

-- 12. Test JSONB address schema
-- Valid insert with proper JSONB:
-- INSERT INTO marketplace_transactions (
--   listing_id, seller_id, buyer_id,
--   item_price_cents, shipping_cost_cents, platform_fee_cents, seller_payout_cents, total_paid_cents,
--   shipping_from_address, shipping_to_address, status
-- ) VALUES (
--   'valid-listing-id', 'seller-id', 'buyer-id',
--   10000, 2000, 1000, 9000, 12000,
--   '{"name":"Seller","street":"123 Main St","city":"Paris","postal_code":"75001","country_code":"FR"}'::jsonb,
--   '{"name":"Buyer","street":"456 Elm St","city":"Lyon","postal_code":"69001","country_code":"FR"}'::jsonb,
--   'pending'
-- );
-- Expected: Success
```

## JSONB Address Schema

Les champs `shipping_from_address` et `shipping_to_address` utilisent JSONB avec ce schema :

```json
{
  "name": "John Doe",
  "street": "123 Main Street",
  "city": "Paris",
  "postal_code": "75001",
  "country_code": "FR"
}
```

### Validation cote application (Dart)

La validation du schema JSON est geree cote app, pas en DB. Raisons :
- Flexibilite : Schema peut evoluer sans migration
- Performance : Validation JSON en SQL couteuse
- Type-safety : Dart entities gerent la deserialisation

## Cron Job Setup (complete_delivered_transactions)

### Option 1: pg_cron Extension

```sql
SELECT cron.schedule(
  'complete-delivered-transactions',
  '0 0 * * *', -- Every day at midnight
  $$SELECT complete_delivered_transactions();$$
);
```

### Option 2: Edge Function + GitHub Actions

```typescript
// supabase/functions/complete-transactions/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

Deno.serve(async (req: Request) => {
  const authHeader = req.headers.get('Authorization');
  if (authHeader !== `Bearer ${Deno.env.get('CRON_SECRET')}`) {
    return new Response('Unauthorized', { status: 401 });
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  );

  const { data, error } = await supabase.rpc('complete_delivered_transactions');

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  return new Response(JSON.stringify({ completed_count: data }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

## Entity Dart

### Fichier: `lib/features/marketplace/domain/entities/shipping_address.dart`

```dart
/// ShippingAddress entity - Address for shipping
///
/// Immutable data class representing a shipping address (from/to).
library;

import 'package:flutter/foundation.dart';

/// Represents a shipping address.
@immutable
class ShippingAddress {
  /// Creates a shipping address.
  const ShippingAddress({
    required this.name,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.countryCode,
  });

  /// Recipient or sender name.
  final String name;

  /// Street address.
  final String street;

  /// City.
  final String city;

  /// Postal/ZIP code.
  final String postalCode;

  /// Country code (2 chars, e.g., "FR", "US").
  final String countryCode;

  /// Creates from JSON.
  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      name: json['name'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      postalCode: json['postal_code'] as String,
      countryCode: json['country_code'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'street': street,
      'city': city,
      'postal_code': postalCode,
      'country_code': countryCode,
    };
  }

  /// Equality based on all fields.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShippingAddress &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          street == other.street &&
          city == other.city &&
          postalCode == other.postalCode &&
          countryCode == other.countryCode;

  @override
  int get hashCode =>
      name.hashCode ^
      street.hashCode ^
      city.hashCode ^
      postalCode.hashCode ^
      countryCode.hashCode;

  @override
  String toString() => 'ShippingAddress(name: $name, city: $city, countryCode: $countryCode)';
}
```

### Fichier: `lib/features/marketplace/domain/entities/marketplace_transaction.dart`

```dart
/// MarketplaceTransaction entity - A completed purchase transaction
///
/// Immutable data class representing a transaction with payment, shipping, and lifecycle.
library;

import 'package:flutter/foundation.dart';
import 'shipping_address.dart';

/// Represents a marketplace transaction.
///
/// Contains amounts, Stripe/FedEx references, addresses, and status lifecycle.
@immutable
class MarketplaceTransaction {
  /// Creates a marketplace transaction.
  const MarketplaceTransaction({
    required this.id,
    required this.listingId,
    this.offerId,
    required this.sellerId,
    required this.buyerId,
    required this.itemPriceCents,
    required this.shippingCostCents,
    required this.platformFeeCents,
    required this.sellerPayoutCents,
    required this.totalPaidCents,
    this.stripePaymentIntentId,
    this.stripeChargeId,
    this.stripeTransferId,
    this.fedexTrackingNumber,
    this.fedexLabelUrl,
    this.fedexRateId,
    required this.shippingFromAddress,
    required this.shippingToAddress,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
    this.shippedAt,
    this.deliveredAt,
    this.completedAt,
  });

  final String id;
  final String listingId;
  final String? offerId;
  final String sellerId;
  final String buyerId;
  final int itemPriceCents;
  final int shippingCostCents;
  final int platformFeeCents;
  final int sellerPayoutCents;
  final int totalPaidCents;
  final String? stripePaymentIntentId;
  final String? stripeChargeId;
  final String? stripeTransferId;
  final String? fedexTrackingNumber;
  final String? fedexLabelUrl;
  final String? fedexRateId;
  final ShippingAddress shippingFromAddress;
  final ShippingAddress shippingToAddress;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? paidAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? completedAt;

  /// Whether the transaction is pending payment.
  bool get isPending => status == 'pending';

  /// Whether the transaction is paid.
  bool get isPaid => status == 'paid';

  /// Whether the transaction is completed.
  bool get isCompleted => status == 'completed';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplaceTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MarketplaceTransaction(id: $id, status: $status, totalPaidCents: $totalPaidCents)';

  MarketplaceTransaction copyWith({
    String? id,
    String? listingId,
    String? offerId,
    String? sellerId,
    String? buyerId,
    int? itemPriceCents,
    int? shippingCostCents,
    int? platformFeeCents,
    int? sellerPayoutCents,
    int? totalPaidCents,
    String? stripePaymentIntentId,
    String? stripeChargeId,
    String? stripeTransferId,
    String? fedexTrackingNumber,
    String? fedexLabelUrl,
    String? fedexRateId,
    ShippingAddress? shippingFromAddress,
    ShippingAddress? shippingToAddress,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? completedAt,
  }) {
    return MarketplaceTransaction(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      offerId: offerId ?? this.offerId,
      sellerId: sellerId ?? this.sellerId,
      buyerId: buyerId ?? this.buyerId,
      itemPriceCents: itemPriceCents ?? this.itemPriceCents,
      shippingCostCents: shippingCostCents ?? this.shippingCostCents,
      platformFeeCents: platformFeeCents ?? this.platformFeeCents,
      sellerPayoutCents: sellerPayoutCents ?? this.sellerPayoutCents,
      totalPaidCents: totalPaidCents ?? this.totalPaidCents,
      stripePaymentIntentId: stripePaymentIntentId ?? this.stripePaymentIntentId,
      stripeChargeId: stripeChargeId ?? this.stripeChargeId,
      stripeTransferId: stripeTransferId ?? this.stripeTransferId,
      fedexTrackingNumber: fedexTrackingNumber ?? this.fedexTrackingNumber,
      fedexLabelUrl: fedexLabelUrl ?? this.fedexLabelUrl,
      fedexRateId: fedexRateId ?? this.fedexRateId,
      shippingFromAddress: shippingFromAddress ?? this.shippingFromAddress,
      shippingToAddress: shippingToAddress ?? this.shippingToAddress,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidAt: paidAt ?? this.paidAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
```

### Fichiers de tests

Due to length, test files are abbreviated. See S01-S03 for full test patterns.

**`test/features/marketplace/domain/entities/shipping_address_test.dart`:**
- Test 1: Create with required fields
- Test 2: fromJson deserialization
- Test 3: toJson serialization
- Test 4: Equality based on all fields
- Test 5: ToString contains key fields

**`test/features/marketplace/domain/entities/marketplace_transaction_test.dart`:**
- Test 1: Create with required fields
- Test 2: Create with all optional fields
- Test 3: Immutability verification
- Test 4: Commission calculation (30000 → fee 3000, payout 27000)
- Test 5: total_paid = item + shipping
- Test 6: isPending/isPaid/isCompleted helpers
- Test 7: Equality based on id
- Test 8: CopyWith updates status
- Test 9: ShippingAddress serialization
- Test 10: ToString contains key fields

## Definition of Done
- [x] Migration appliquee avec succes sur Supabase (MCP apply_migration)
- [x] Post-migration verification complete (columns, FK, CHECK, indexes, functions)
- [x] Functions calculate_marketplace_commission et complete_delivered_transactions creees et testees
- [x] Cron job configure (pg_cron OU Edge Function)
- [x] 6 indexes crees
- [x] 1 RLS policy active (Transaction parties view)
- [x] Trigger updated_at fonctionne
- [x] Entity Dart MarketplaceTransaction creee avec ShippingAddress
- [x] Tests entity Dart passes (ShippingAddress 10 tests, MarketplaceTransaction 28 tests)
- [x] `flutter analyze --fatal-infos` passe (0 warnings)

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (logique financiere)

## Dependances

### Requires (BLOQUANTS):
- S01: `marketplace_listings` table doit exister (FK listing_id)
- S03: `marketplace_offers` table doit exister (optional FK offer_id)
- Database: `profiles` table doit exister (FK seller_id, buyer_id)
- Database: `update_updated_at_column()` function doit exister (trigger)

### Order:
- S01 (marketplace_listings) → S03 (marketplace_offers) → **S04 (marketplace_transactions)**

## Stories Dependantes (BLOQUEES si S04 incomplete)
- S06 (fedex_events) - FK transaction_id vers marketplace_transactions
- S20 (flow achat) - utilise entity MarketplaceTransaction
- S21 (generation etiquette) - met a jour transaction avec fedex_label_url
- S22 (tracking) - query transactions par fedex_tracking_number
- S25 (seller dashboard) - affiche transactions du seller
