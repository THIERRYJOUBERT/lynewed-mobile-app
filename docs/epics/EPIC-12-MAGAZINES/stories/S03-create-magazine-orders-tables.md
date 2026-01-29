# S03 - Create magazine_orders and magazine_order_items Tables

> **Epic** : EPIC-12-MAGAZINES
> **Status** : 🔵 Draft
> **Estimation** : 5 points (M)
> **Domaine** : Database

---

## Description

Creer les tables `magazine_orders` et `magazine_order_items` pour stocker les commandes de magazines avec snapshot des photos au moment de la commande.

## Dependances

- S02 (magazine_selections)
- EPIC-11 (Stripe integration conceptuelle)

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Magazine orders tables

  Scenario: Creating order after Stripe payment
    Given a bride with paid checkout session
    When the order is created
    Then magazine_orders should have status = 'paid'
    And stripe_payment_intent_id should be populated
    And magazine_order_items should contain all selected photos

  Scenario: Snapshot preserves photo URLs
    Given photos in magazine_selections
    When order is created
    Then magazine_order_items should have storage_url for each photo
    And even if original is deleted, order still has reference

  Scenario: Status progression
    Given order with status = 'paid'
    When admin marks as 'in_production'
    Then status should update
    And production_started_at timestamp should be set

  Scenario: RLS for bride
    Given bride-A has orders
    When bride-A queries magazine_orders
    Then only bride-A's orders should be visible

  Scenario: Cascade delete
    Given an order with items
    When order is deleted
    Then all magazine_order_items should be deleted
```

## Details Techniques

### Migration SQL

```sql
-- Migration: 20260129100003_create_magazine_orders
-- Description: Create magazine_orders and magazine_order_items tables

-- Main orders table
CREATE TABLE IF NOT EXISTS magazine_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID REFERENCES weddings(id) NOT NULL,
  bride_user_id UUID REFERENCES profiles(id) NOT NULL,

  -- Stripe
  stripe_payment_intent_id VARCHAR(255),
  stripe_checkout_session_id VARCHAR(255),

  -- Amounts (cents)
  magazine_price_cents INTEGER NOT NULL,
  shipping_cost_cents INTEGER NOT NULL,
  total_paid_cents INTEGER NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD' NOT NULL,

  -- Shipping address
  shipping_name VARCHAR(255) NOT NULL,
  shipping_address_line1 VARCHAR(255) NOT NULL,
  shipping_address_line2 VARCHAR(255),
  shipping_city VARCHAR(255) NOT NULL,
  shipping_zip VARCHAR(50) NOT NULL,
  shipping_country VARCHAR(100) NOT NULL,
  shipping_phone VARCHAR(50),

  -- Magazine details
  magazine_title VARCHAR(255) NOT NULL,
  magazine_date DATE,
  photo_count INTEGER NOT NULL,
  cover_photo_id UUID,

  -- Status
  status VARCHAR(30) DEFAULT 'pending' NOT NULL,

  -- Tracking
  tracking_number VARCHAR(255),
  tracking_url TEXT,

  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,
  paid_at TIMESTAMP,
  production_started_at TIMESTAMP,
  shipped_at TIMESTAMP,
  delivered_at TIMESTAMP,

  CONSTRAINT chk_magazine_order_status CHECK (
    status IN ('pending', 'paid', 'in_production', 'shipped', 'delivered', 'cancelled')
  )
);

-- Order items (snapshot of photos at order time)
CREATE TABLE IF NOT EXISTS magazine_order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES magazine_orders(id) ON DELETE CASCADE NOT NULL,
  media_type VARCHAR(20) NOT NULL,
  media_id UUID NOT NULL,
  position INTEGER NOT NULL,
  storage_url TEXT NOT NULL,
  caption TEXT,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,

  CONSTRAINT chk_order_item_type CHECK (media_type IN ('album_image', 'guest_media'))
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_magazine_orders_bride
  ON magazine_orders(bride_user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_magazine_orders_status
  ON magazine_orders(status)
  WHERE status NOT IN ('delivered', 'cancelled');

CREATE INDEX IF NOT EXISTS idx_magazine_order_items_order
  ON magazine_order_items(order_id, position);

-- Enable RLS
ALTER TABLE magazine_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE magazine_order_items ENABLE ROW LEVEL SECURITY;

-- Policies for magazine_orders
CREATE POLICY "Bride views own orders"
ON magazine_orders FOR SELECT
TO authenticated
USING (bride_user_id = auth.uid());

CREATE POLICY "Bride creates own orders"
ON magazine_orders FOR INSERT
TO authenticated
WITH CHECK (bride_user_id = auth.uid());

-- Policies for magazine_order_items
CREATE POLICY "Bride views own order items"
ON magazine_order_items FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM magazine_orders mo
    WHERE mo.id = magazine_order_items.order_id
    AND mo.bride_user_id = auth.uid()
  )
);

COMMENT ON TABLE magazine_orders IS 'Wedding magazine orders (manual fulfillment V1)';
COMMENT ON TABLE magazine_order_items IS 'Snapshot of photos included in magazine order';
COMMENT ON COLUMN magazine_order_items.storage_url IS 'Snapshot URL - preserved even if original deleted';
```

### Rollback

```sql
DROP POLICY IF EXISTS "Bride views own order items" ON magazine_order_items;
DROP POLICY IF EXISTS "Bride creates own orders" ON magazine_orders;
DROP POLICY IF EXISTS "Bride views own orders" ON magazine_orders;
DROP INDEX IF EXISTS idx_magazine_order_items_order;
DROP INDEX IF EXISTS idx_magazine_orders_status;
DROP INDEX IF EXISTS idx_magazine_orders_bride;
DROP TABLE IF EXISTS magazine_order_items;
DROP TABLE IF EXISTS magazine_orders;
```

## Fichiers a Modifier

| Fichier | Action |
|---------|--------|
| Supabase migration | Creer via MCP |

## Tests

- [ ] Tables creees avec colonnes correctes
- [ ] CASCADE delete fonctionne
- [ ] Status CHECK constraint
- [ ] RLS bride-only
- [ ] storage_url preserve snapshot

## Notes

- Admin panel (Tom) utilise service_role pour gerer les commandes
- storage_url = snapshot au moment de la commande, meme si photo supprimee ensuite
- Status progression: pending → paid → in_production → shipped → delivered
