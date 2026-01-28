# Story S04: Create marketplace_transactions table

## Description
En tant que developpeur backend, je veux creer la table marketplace_transactions dans Supabase, afin de stocker l'historique complet des transactions avec montants, references Stripe/FedEx et lifecycle complet.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the database schema with marketplace_listings and marketplace_offers When the migration create_marketplace_transactions is applied Then table marketplace_transactions should exist with all required columns
- [ ] Given a transaction with item_price_cents 30000 (300 USD) When calculating commission Then platform_fee_cents should be 3000 (10%) And seller_payout_cents should be 27000 (90%)
- [ ] Given a new transaction Then status should be 'pending' When payment succeeds status becomes 'paid' When label created status becomes 'label_created' When shipped status becomes 'shipped' When delivered status becomes 'delivered' When 7 days pass status becomes 'completed'
- [ ] Given a transaction between seller-A and buyer-B When seller-A queries the transaction Then it should succeed When buyer-B queries Then it should succeed When other user queries Then it should be denied by RLS
- [ ] Given all amounts in the transaction Then total_paid_cents should equal item_price_cents + shipping_cost_cents

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260128100004_create_marketplace_transactions.sql` - Migration principale
- `supabase/migrations/20260128100004_create_marketplace_transactions_rollback.sql` - Rollback migration

### A Modifier
- Aucun

## Notes Techniques

### Schema SQL (colonnes principales)
```sql
CREATE TABLE marketplace_transactions (
  id UUID PRIMARY KEY,

  -- References
  listing_id UUID REFERENCES marketplace_listings(id) NOT NULL,
  offer_id UUID REFERENCES marketplace_offers(id),
  seller_id UUID REFERENCES profiles(id) NOT NULL,
  buyer_id UUID REFERENCES profiles(id) NOT NULL,

  -- Amounts (all USD cents)
  item_price_cents INTEGER NOT NULL,
  shipping_cost_cents INTEGER NOT NULL,
  platform_fee_cents INTEGER NOT NULL,  -- 10% commission
  seller_payout_cents INTEGER NOT NULL, -- 90%
  total_paid_cents INTEGER NOT NULL,    -- item + shipping

  -- Stripe references
  stripe_payment_intent_id VARCHAR(255),
  stripe_charge_id VARCHAR(255),
  stripe_transfer_id VARCHAR(255),

  -- FedEx references
  fedex_tracking_number VARCHAR(255),
  fedex_label_url TEXT,
  fedex_rate_id VARCHAR(255),

  -- Addresses (JSONB)
  shipping_from_address JSONB,
  shipping_to_address JSONB,

  -- Status lifecycle
  status VARCHAR(20) DEFAULT 'pending',

  -- Timestamps
  created_at, paid_at, shipped_at, delivered_at, completed_at
);
```

### Status values
- pending, paid, label_created, shipped, in_transit, delivered, completed, disputed, refunded, canceled

### Functions
```sql
-- Calculate 10% commission
CREATE FUNCTION calculate_marketplace_commission(item_price INTEGER)
RETURNS TABLE(platform_fee INTEGER, seller_payout INTEGER);

-- Auto-complete delivered transactions after 7 days
CREATE FUNCTION complete_delivered_transactions() RETURNS INTEGER;
```

### RLS Policies
- Transaction parties view (seller_id OR buyer_id = auth.uid())
- Inserts/updates via service_role (Edge Functions/webhooks)

## Definition of Done
- [ ] Migration appliquee avec succes
- [ ] Functions commission et completion creees
- [ ] RLS policies actives
- [ ] Cron job pour complete_delivered_transactions
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (logique financiere)

## Dependances
- S01 (marketplace_listings)
- S03 (marketplace_offers - optional FK)

## Stories Dependantes
- S06 (fedex_events)
- S20 (flow achat)
- S21 (generation etiquette)
- S22 (tracking)
- S25 (seller dashboard)
