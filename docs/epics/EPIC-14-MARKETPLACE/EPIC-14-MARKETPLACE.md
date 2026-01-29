# EPIC-14-MARKETPLACE

> Resume : Marketplace style Vinted pour vendre robes ET chaussures de mariage avec commission 10% Stripe Connect et expedition FedEx mondiale
> Status : 🔵 Draft
> Domaine : Backend / Database / Frontend / Payments / Shipping
> Cree le : 2026-01-28

---

## Contexte

### Pourquoi cet Epic

Cet Epic implemente la **fonctionnalite phare** de la Mission 2026 : une marketplace permettant aux brides de vendre et acheter des robes et chaussures de mariage d'occasion.

**Modele economique** :
- Commission de **10%** prelevee sur chaque vente via Stripe Connect
- Expedition mondiale via **FedEx** (frais payes par l'acheteuse)
- Lynewed agit comme **intermediaire technique** (pas responsable des litiges)

**Placement dans l'app** :
- Nouvel onglet dans la navbar (cote bride uniquement)
- Preview optionnelle sur la home page
- Articles visibles sur la carte (nouveau type de marqueur)

**Valeur business** :
- Nouvelle source de revenus (commission 10%)
- Augmentation de l'engagement (brides reviennent pour vendre/acheter)
- Differenciation concurrentielle (unique dans le secteur wedding apps)

### Piliers Techniques Concernes

| Pilier | Implication pour cet Epic |
|--------|---------------------------|
| **Supabase Database** | 6 nouvelles tables (listings, photos, offers, transactions, messages, fedex_events) |
| **Supabase Storage** | Bucket `marketplace-listings` pour photos annonces |
| **Stripe Connect** | Onboarding Express vendeurs, paiements avec split commission |
| **FedEx APIs** | Address Validation, Rate, Ship, Track, Pickup |
| **Flutter/Dart** | Nouvelle feature marketplace avec Clean Architecture |
| **Edge Functions** | Webhooks Stripe/FedEx, generation etiquettes |

### Dependances Inter-Epics

| Epic | Dependance | Description |
|------|------------|-------------|
| **EPIC-06** | BLOQUANT | Enum `userRole` avec 'guest', `invite_code` sur weddings |
| **EPIC-11** | BLOQUANT | Tables `stripe_accounts`, `purchases`, `stripe_events` |
| **EPIC-13** | OPTIONNEL | Marqueurs marketplace sur la carte |

**Ordre d'execution** : EPIC-06 -> EPIC-11 -> EPIC-14 (cet Epic)

---

## Architecture Cible

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                       MARKETPLACE ARCHITECTURE                                    │
│                                                                                   │
│  SELLER FLOW                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │  1. Create Listing    2. Upload Photos    3. Accept CGVU               │    │
│  │        │                     │                   │                      │    │
│  │        ▼                     ▼                   ▼                      │    │
│  │  marketplace_listings  marketplace_photos  cgvu_acceptances            │    │
│  │        │                                                                │    │
│  │        ▼                                                                │    │
│  │  4. Setup Stripe Connect (if not done)                                 │    │
│  │        │                                                                │    │
│  │        ▼                                                                │    │
│  │  stripe_accounts (onboarding_complete = true)                          │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                   │
│  BUYER FLOW                                                                       │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │  1. Browse/Filter   2. View Details   3. Contact Seller / Make Offer   │    │
│  │        │                   │                    │                       │    │
│  │        ▼                   ▼                    ▼                       │    │
│  │  Feed/Map View      Listing Detail     marketplace_messages/offers     │    │
│  │                                                  │                      │    │
│  │  4. Accept CGVU    5. Calculate Shipping    6. Pay                     │    │
│  │        │                   │                    │                       │    │
│  │        ▼                   ▼                    ▼                       │    │
│  │  cgvu_acceptances   FedEx Rate API      Stripe Payment Intent          │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                   │
│  TRANSACTION FLOW                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │  Payment Confirmed  →  marketplace_transactions (status: 'paid')       │    │
│  │        │                                                                │    │
│  │        ▼                                                                │    │
│  │  Seller generates FedEx label  →  fedex_events (label_created)         │    │
│  │        │                                                                │    │
│  │        ▼                                                                │    │
│  │  Seller ships  →  FedEx Track API  →  fedex_events (in_transit)        │    │
│  │        │                                                                │    │
│  │        ▼                                                                │    │
│  │  Delivered  →  transaction status: 'delivered'                         │    │
│  │        │                                                                │    │
│  │        ▼ (7 days no dispute)                                           │    │
│  │  Completed  →  Stripe Transfer to seller (90%)                         │    │
│  │                 Lynewed keeps 10% commission                           │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                   │
│  DATABASE SCHEMA                                                                  │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐            │
│  │ marketplace_    │───▶│ marketplace_    │◀───│ marketplace_    │            │
│  │ listings        │    │ photos          │    │ offers          │            │
│  │ (seller_id)     │    │ (listing_id)    │    │ (listing_id,    │            │
│  │                 │    │                 │    │  buyer_id)      │            │
│  └────────┬────────┘    └─────────────────┘    └─────────────────┘            │
│           │                                                                      │
│           ▼                                                                      │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐            │
│  │ marketplace_    │───▶│ fedex_events    │    │ marketplace_    │            │
│  │ transactions    │    │ (transaction_   │    │ messages        │            │
│  │ (listing_id,    │    │  id, tracking)  │    │ (listing_id,    │            │
│  │  buyer_id,      │    │                 │    │  sender/receiver)│            │
│  │  seller_id)     │    │                 │    │                 │            │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘            │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Stories

| # | Story | Domaine | Dep. | Criteres cles | Source PRD | Complexite |
|---|-------|---------|------|---------------|------------|------------|
| S01 | Creer table marketplace_listings | DB | EPIC-11 | Table complete avec tous attributs, RLS policies | APP-08 | M |
| S02 | Creer table marketplace_photos | DB | S01 | 5-10 photos par annonce, ordering, RLS | APP-08 | S |
| S03 | Creer table marketplace_offers | DB | S01 | Offres avec expiration 48h, statuts, RLS | APP-08 | S |
| S04 | Creer table marketplace_transactions | DB | S01 | Historique complet, montants cents USD, RLS | APP-08 | M |
| S05 | Creer table marketplace_messages | DB | S01 | Chat buyer/seller par listing, Realtime, RLS | APP-08 | S |
| S06 | Creer table fedex_events | DB | S04 | Audit log tracking FedEx, raw payload | APP-08 | S |
| S07 | Creer bucket marketplace-listings avec RLS | Storage | S01 | Photos annonces, 20MB max, RLS seller | APP-08 | S |
| S08 | Implémenter CGVU marketplace seller | Frontend + DB | - | Scroll + checkbox, logging complet | CGVU | M |
| S09 | Implémenter CGVU marketplace buyer | Frontend + DB | - | Scroll + checkbox, logging complet | CGVU | M |
| S10 | Stripe Connect onboarding Express vendeurs | Backend + Frontend | EPIC-11 | Onboarding simplifie, webhooks account.updated | APP-08 | L |
| S11 | Edge Function FedEx Rate API | Backend | - | Calcul frais port, validation adresse | APP-08 | M |
| S12 | Edge Function FedEx Ship API | Backend | S11 | Generation etiquette, tracking number | APP-08 | M |
| S13 | Edge Function FedEx Track API | Backend | S12 | Polling tracking, mise a jour statuts | APP-08 | M |
| S14 | Formulaire creation annonce vendeur | Frontend | S01, S02, S07 | Upload 5-10 photos, tous champs, validation | US-08.1 to US-08.4 | L |
| S15 | Page liste annonces (feed) | Frontend | S01 | Feed avec cards, filtres, infinite scroll | US-08.10 | M |
| S16 | Page detail annonce | Frontend | S01, S02 | Carousel photos, infos, boutons actions | US-08.10 | M |
| S17 | Systeme de filtres avances | Frontend | S15 | Categorie, taille, marque, etat, prix, localisation | US-08.12 | M |
| S18 | Chat buyer/seller | Frontend | S05 | Conversation Realtime par annonce | US-08.13 | M |
| S19 | Systeme d'offres | Frontend + Backend | S03 | Faire offre, accepter/refuser, expiration 48h | US-08.14, US-08.7 | M |
| S20 | Flow achat complet | Frontend + Backend | S04, S10, S11 | Checkout, paiement, creation transaction | US-08.15 to US-08.17 | L |
| S21 | Generation etiquette FedEx (vendeur) | Frontend + Backend | S12 | Apres paiement, PDF etiquette, email | US-08.8 | M |
| S22 | Tracking colis (acheteur) | Frontend | S06, S13 | Timeline tracking, notifications | US-08.18 | M |
| S23 | Notifications marketplace | Backend | S19, S20 | Offre, message, vente, expedition, livraison | US-08.6 | M |
| S24 | Marqueurs marketplace sur carte | Frontend | S01, EPIC-13 | Icone dress/shoes, tap -> details | US-08.11 | S |
| S25 | Page "Mes ventes" vendeur | Frontend | S01, S04 | Liste annonces, statuts, historique | US-08.9 | M |
| S26 | Navbar integration + Home preview | Frontend | S15 | Nouvel onglet, preview home page | APP-08 | S |

---

## Detail des Stories

### S01 : Creer table marketplace_listings

**Criteres cles** :
- Table `marketplace_listings` creee avec tous les attributs PRD
- Colonnes: seller_id, title, description, category (dress/shoes), price_cents, designer_brand, size, condition, sleeve_length (pour robes), city, country, country_code, latitude, longitude, status
- Tous les montants en USD cents
- RLS: brides voient annonces actives, vendeur gere ses annonces

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (APP-08)

**Complexite** : M (Medium) - Table complexe avec nombreux attributs et RLS

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Marketplace listings table

  Scenario: Creating marketplace_listings table
    Given the database schema
    When the migration create_marketplace_listings is applied
    Then table marketplace_listings should exist
    And it should have column seller_id of type UUID referencing profiles(id)
    And it should have column title of type VARCHAR(255) NOT NULL
    And it should have column description of type TEXT
    And it should have column category of type VARCHAR(20) with CHECK (category IN ('dress', 'shoes'))
    And it should have column price_cents of type INTEGER NOT NULL
    And it should have column designer_brand of type VARCHAR(255)
    And it should have column size of type VARCHAR(50)
    And it should have column condition of type VARCHAR(20) with CHECK (condition IN ('new', 'excellent', 'good', 'fair'))
    And it should have column sleeve_length of type VARCHAR(20) (for dresses only)
    And it should have column city of type VARCHAR(255)
    And it should have column country of type VARCHAR(100) NOT NULL
    And it should have column country_code of type VARCHAR(2)
    And it should have column latitude of type DECIMAL(10,8)
    And it should have column longitude of type DECIMAL(11,8)
    And it should have column status of type VARCHAR(20) with default 'draft'
    And it should have timestamps created_at, updated_at, sold_at

  Scenario: Status values are constrained
    Given the marketplace_listings table
    When inserting a listing with status 'invalid'
    Then the insert should fail with constraint violation
    And only 'draft', 'active', 'reserved', 'sold', 'deleted' should be allowed

  Scenario: Active listings visible to all brides
    Given active listings in the marketplace
    And a bride user authenticated
    When the bride queries marketplace_listings WHERE status = 'active'
    Then all active listings should be returned

  Scenario: Seller can manage own listings
    Given a seller with listings
    When the seller updates their own listing
    Then the update should succeed
    And when a different user tries to update
    Then the update should be denied by RLS

  Scenario: Prices stored in USD cents
    Given a listing with price 299.99 USD
    When stored in database
    Then price_cents should be 29999
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128100001_create_marketplace_listings
-- Description: Create marketplace listings table for dress/shoes marketplace

CREATE TABLE IF NOT EXISTS marketplace_listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id UUID REFERENCES profiles(id) NOT NULL,

  -- Product info
  title VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(20) NOT NULL CHECK (category IN ('dress', 'shoes')),

  -- Price (always in USD cents)
  price_cents INTEGER NOT NULL CHECK (price_cents > 0),
  display_currency VARCHAR(3) DEFAULT 'USD',

  -- Attributes
  designer_brand VARCHAR(255),
  size VARCHAR(50),
  condition VARCHAR(20) NOT NULL CHECK (condition IN ('new', 'excellent', 'good', 'fair')),

  -- Dress-specific attributes
  sleeve_length VARCHAR(20) CHECK (
    sleeve_length IS NULL OR
    sleeve_length IN ('long', '3/4', 'short', 'cap', 'sleeveless', 'strapless')
  ),

  -- Location
  city VARCHAR(255),
  country VARCHAR(100) NOT NULL,
  country_code VARCHAR(2),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),

  -- Status
  status VARCHAR(20) DEFAULT 'draft' NOT NULL CHECK (
    status IN ('draft', 'active', 'reserved', 'sold', 'deleted')
  ),

  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW() NOT NULL,
  sold_at TIMESTAMP,

  -- Constraints
  CONSTRAINT chk_dress_sleeve CHECK (
    category != 'dress' OR sleeve_length IS NOT NULL
  )
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_marketplace_listings_status
  ON marketplace_listings(status) WHERE status = 'active';

CREATE INDEX IF NOT EXISTS idx_marketplace_listings_seller
  ON marketplace_listings(seller_id);

CREATE INDEX IF NOT EXISTS idx_marketplace_listings_category
  ON marketplace_listings(category, status);

CREATE INDEX IF NOT EXISTS idx_marketplace_listings_location
  ON marketplace_listings(latitude, longitude) WHERE status = 'active';

CREATE INDEX IF NOT EXISTS idx_marketplace_listings_price
  ON marketplace_listings(price_cents) WHERE status = 'active';

-- Enable RLS
ALTER TABLE marketplace_listings ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Policy 1: Active listings visible to all brides
CREATE POLICY "Active listings visible to brides"
ON marketplace_listings FOR SELECT
TO authenticated
USING (
  status = 'active' AND
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'bride')
);

-- Policy 2: Seller can view all their own listings
CREATE POLICY "Seller views own listings"
ON marketplace_listings FOR SELECT
TO authenticated
USING (seller_id = auth.uid());

-- Policy 3: Seller can insert new listings
CREATE POLICY "Seller creates listings"
ON marketplace_listings FOR INSERT
TO authenticated
WITH CHECK (
  seller_id = auth.uid() AND
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'bride')
);

-- Policy 4: Seller can update own listings
CREATE POLICY "Seller updates own listings"
ON marketplace_listings FOR UPDATE
TO authenticated
USING (seller_id = auth.uid())
WITH CHECK (seller_id = auth.uid());

-- Policy 5: Seller can soft-delete own listings (set status to 'deleted')
CREATE POLICY "Seller deletes own listings"
ON marketplace_listings FOR DELETE
TO authenticated
USING (seller_id = auth.uid());

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_marketplace_listings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_marketplace_listings_updated_at
  BEFORE UPDATE ON marketplace_listings
  FOR EACH ROW
  EXECUTE FUNCTION update_marketplace_listings_updated_at();

-- Comments
COMMENT ON TABLE marketplace_listings IS 'Marketplace listings for wedding dresses and shoes (APP-08)';
COMMENT ON COLUMN marketplace_listings.price_cents IS 'Price in USD cents (e.g., 29999 = $299.99)';
COMMENT ON COLUMN marketplace_listings.sleeve_length IS 'Required for dresses, NULL for shoes';
```

**Rollback** :
```sql
-- Rollback: 20260128100001_create_marketplace_listings

DROP TRIGGER IF EXISTS trg_marketplace_listings_updated_at ON marketplace_listings;
DROP FUNCTION IF EXISTS update_marketplace_listings_updated_at;

DROP POLICY IF EXISTS "Seller deletes own listings" ON marketplace_listings;
DROP POLICY IF EXISTS "Seller updates own listings" ON marketplace_listings;
DROP POLICY IF EXISTS "Seller creates listings" ON marketplace_listings;
DROP POLICY IF EXISTS "Seller views own listings" ON marketplace_listings;
DROP POLICY IF EXISTS "Active listings visible to brides" ON marketplace_listings;

DROP INDEX IF EXISTS idx_marketplace_listings_price;
DROP INDEX IF EXISTS idx_marketplace_listings_location;
DROP INDEX IF EXISTS idx_marketplace_listings_category;
DROP INDEX IF EXISTS idx_marketplace_listings_seller;
DROP INDEX IF EXISTS idx_marketplace_listings_status;

DROP TABLE IF EXISTS marketplace_listings;
```

**Dependances** : EPIC-11 (stripe_accounts pour verification vendeur lors de publication)

---

### S02 : Creer table marketplace_photos

**Criteres cles** :
- Table `marketplace_photos` creee avec listing_id, storage_path, position
- 5 a 10 photos obligatoires par annonce (validation cote app)
- Position pour ordering des photos
- RLS suit l'acces au listing parent

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (APP-08)

**Complexite** : S (Small) - Table simple avec FK

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Marketplace photos table

  Scenario: Creating marketplace_photos table
    Given the marketplace_listings table exists
    When the migration create_marketplace_photos is applied
    Then table marketplace_photos should exist
    And it should have column listing_id of type UUID referencing marketplace_listings(id) with CASCADE delete
    And it should have column storage_path of type TEXT NOT NULL
    And it should have column position of type INTEGER with default 0
    And it should have column created_at of type TIMESTAMP

  Scenario: Photos deleted when listing deleted
    Given a listing with 5 photos
    When the listing is deleted
    Then all associated photos should be deleted (CASCADE)

  Scenario: Photos accessible if listing is accessible
    Given an active listing with photos
    And a bride user queries the photos
    Then photos should be returned for accessible listings
    And denied for inaccessible listings (draft of another seller)

  Scenario: Photo ordering is maintained
    Given a listing with photos at positions 0, 1, 2
    When querying photos ORDER BY position
    Then photos should be returned in correct order
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128100002_create_marketplace_photos
-- Description: Create marketplace photos table

CREATE TABLE IF NOT EXISTS marketplace_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID REFERENCES marketplace_listings(id) ON DELETE CASCADE NOT NULL,
  storage_path TEXT NOT NULL,
  thumbnail_path TEXT,
  position INTEGER DEFAULT 0 NOT NULL,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL
);

-- Index for querying photos by listing
CREATE INDEX IF NOT EXISTS idx_marketplace_photos_listing
  ON marketplace_photos(listing_id, position);

-- Enable RLS
ALTER TABLE marketplace_photos ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Photos follow listing access

-- Policy 1: Photos visible if listing is visible
CREATE POLICY "Photos visible with listing"
ON marketplace_photos FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id = marketplace_photos.listing_id
    AND (
      ml.status = 'active' OR
      ml.seller_id = auth.uid()
    )
  )
);

-- Policy 2: Seller can manage photos of own listings
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

-- Comment
COMMENT ON TABLE marketplace_photos IS 'Photos for marketplace listings (5-10 required per listing)';
```

**Rollback** :
```sql
-- Rollback: 20260128100002_create_marketplace_photos

DROP POLICY IF EXISTS "Seller manages own photos" ON marketplace_photos;
DROP POLICY IF EXISTS "Photos visible with listing" ON marketplace_photos;
DROP INDEX IF EXISTS idx_marketplace_photos_listing;
DROP TABLE IF EXISTS marketplace_photos;
```

**Dependances** : S01

---

### S03 : Creer table marketplace_offers

**Criteres cles** :
- Table `marketplace_offers` avec listing_id, buyer_id, amount_cents, message, status
- Expiration automatique apres 48h
- Statuts: pending, accepted, rejected, expired, withdrawn
- RLS: buyer voit ses offres, seller voit offres sur ses listings

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (APP-08)

**Complexite** : S (Small) - Table avec logique expiration

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Marketplace offers table

  Scenario: Creating marketplace_offers table
    Given the marketplace_listings table exists
    When the migration create_marketplace_offers is applied
    Then table marketplace_offers should exist
    And it should have column listing_id of type UUID referencing marketplace_listings(id)
    And it should have column buyer_id of type UUID referencing profiles(id)
    And it should have column amount_cents of type INTEGER NOT NULL
    And it should have column message of type TEXT
    And it should have column status of type VARCHAR(20) with default 'pending'
    And it should have column expires_at of type TIMESTAMP defaulting to NOW() + 48 hours
    And it should have timestamps created_at, responded_at

  Scenario: Offer expires after 48 hours
    Given an offer created 48 hours ago with status 'pending'
    When checking offer status
    Then offer should be considered expired
    And a cron job should update status to 'expired'

  Scenario: Buyer sees own offers
    Given a buyer with offers on multiple listings
    When the buyer queries marketplace_offers
    Then only their own offers should be returned

  Scenario: Seller sees offers on own listings
    Given a seller with listings receiving offers
    When the seller queries marketplace_offers
    Then offers on their listings should be returned
    And offers on other listings should not be visible
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128100003_create_marketplace_offers
-- Description: Create marketplace offers table with 48h expiration

CREATE TABLE IF NOT EXISTS marketplace_offers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID REFERENCES marketplace_listings(id) NOT NULL,
  buyer_id UUID REFERENCES profiles(id) NOT NULL,

  -- Offer details
  amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
  message TEXT,

  -- Status
  status VARCHAR(20) DEFAULT 'pending' NOT NULL CHECK (
    status IN ('pending', 'accepted', 'rejected', 'expired', 'withdrawn')
  ),

  -- Expiration (48 hours default)
  expires_at TIMESTAMP DEFAULT (NOW() + INTERVAL '48 hours') NOT NULL,

  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,
  responded_at TIMESTAMP,

  -- Constraints
  CONSTRAINT chk_buyer_not_seller CHECK (
    buyer_id != (SELECT seller_id FROM marketplace_listings WHERE id = listing_id)
  )
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_marketplace_offers_listing
  ON marketplace_offers(listing_id, status);

CREATE INDEX IF NOT EXISTS idx_marketplace_offers_buyer
  ON marketplace_offers(buyer_id, status);

CREATE INDEX IF NOT EXISTS idx_marketplace_offers_expiring
  ON marketplace_offers(expires_at)
  WHERE status = 'pending';

-- Enable RLS
ALTER TABLE marketplace_offers ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Policy 1: Buyer sees own offers
CREATE POLICY "Buyer sees own offers"
ON marketplace_offers FOR SELECT
TO authenticated
USING (buyer_id = auth.uid());

-- Policy 2: Seller sees offers on own listings
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

-- Policy 3: Buyer can create offers
CREATE POLICY "Buyer creates offers"
ON marketplace_offers FOR INSERT
TO authenticated
WITH CHECK (
  buyer_id = auth.uid() AND
  EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id = listing_id
    AND ml.status = 'active'
    AND ml.seller_id != auth.uid()
  )
);

-- Policy 4: Buyer can withdraw own offers
CREATE POLICY "Buyer withdraws offers"
ON marketplace_offers FOR UPDATE
TO authenticated
USING (buyer_id = auth.uid() AND status = 'pending')
WITH CHECK (buyer_id = auth.uid() AND status = 'withdrawn');

-- Policy 5: Seller can respond to offers
CREATE POLICY "Seller responds to offers"
ON marketplace_offers FOR UPDATE
TO authenticated
USING (
  status = 'pending' AND
  EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id = marketplace_offers.listing_id
    AND ml.seller_id = auth.uid()
  )
)
WITH CHECK (
  status IN ('accepted', 'rejected') AND
  EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id = marketplace_offers.listing_id
    AND ml.seller_id = auth.uid()
  )
);

-- Function to expire old offers (called by cron)
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

-- Comment
COMMENT ON TABLE marketplace_offers IS 'Buyer offers on marketplace listings (48h expiration)';
COMMENT ON FUNCTION expire_marketplace_offers IS 'Expires pending offers past their expiration time';
```

**Rollback** :
```sql
-- Rollback: 20260128100003_create_marketplace_offers

DROP FUNCTION IF EXISTS expire_marketplace_offers;

DROP POLICY IF EXISTS "Seller responds to offers" ON marketplace_offers;
DROP POLICY IF EXISTS "Buyer withdraws offers" ON marketplace_offers;
DROP POLICY IF EXISTS "Buyer creates offers" ON marketplace_offers;
DROP POLICY IF EXISTS "Seller sees listing offers" ON marketplace_offers;
DROP POLICY IF EXISTS "Buyer sees own offers" ON marketplace_offers;

DROP INDEX IF EXISTS idx_marketplace_offers_expiring;
DROP INDEX IF EXISTS idx_marketplace_offers_buyer;
DROP INDEX IF EXISTS idx_marketplace_offers_listing;

DROP TABLE IF EXISTS marketplace_offers;
```

**Dependances** : S01

---

### S04 : Creer table marketplace_transactions

**Criteres cles** :
- Table complete avec tous les montants (item, shipping, commission, payout, total)
- References Stripe (payment_intent, transfer, charge)
- References FedEx (tracking_number, label_url, rate_id)
- Adresses JSON (from, to)
- Statuts complets pour tracking lifecycle
- RLS: buyer et seller voient leurs transactions

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (APP-08)

**Complexite** : M (Medium) - Table complexe avec nombreuses colonnes

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Marketplace transactions table

  Scenario: Creating marketplace_transactions table
    Given the database schema with marketplace_listings and marketplace_offers
    When the migration create_marketplace_transactions is applied
    Then table marketplace_transactions should exist
    And it should have all required columns for amounts in USD cents
    And it should have Stripe reference columns
    And it should have FedEx reference columns
    And it should have JSONB columns for shipping addresses
    And it should track full transaction lifecycle

  Scenario: Commission calculation is correct
    Given a transaction with item_price_cents 30000 (300 USD)
    Then platform_fee_cents should be 3000 (10% commission)
    And seller_payout_cents should be 27000 (90%)

  Scenario: Transaction status lifecycle
    Given a new transaction
    Then status should be 'pending'
    When payment succeeds -> status should be 'paid'
    When label created -> status should be 'label_created'
    When shipped -> status should be 'shipped'
    When in transit -> status should be 'in_transit'
    When delivered -> status should be 'delivered'
    When 7 days pass -> status should be 'completed'

  Scenario: Only transaction parties can view
    Given a transaction between seller-A and buyer-B
    When seller-A queries the transaction -> should succeed
    When buyer-B queries the transaction -> should succeed
    When other user queries -> should be denied by RLS
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128100004_create_marketplace_transactions
-- Description: Create marketplace transactions table with full audit trail

CREATE TABLE IF NOT EXISTS marketplace_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- References
  listing_id UUID REFERENCES marketplace_listings(id) NOT NULL,
  offer_id UUID REFERENCES marketplace_offers(id),
  seller_id UUID REFERENCES profiles(id) NOT NULL,
  buyer_id UUID REFERENCES profiles(id) NOT NULL,

  -- Amounts (all in USD cents)
  item_price_cents INTEGER NOT NULL CHECK (item_price_cents > 0),
  shipping_cost_cents INTEGER NOT NULL CHECK (shipping_cost_cents >= 0),
  platform_fee_cents INTEGER NOT NULL CHECK (platform_fee_cents >= 0),
  seller_payout_cents INTEGER NOT NULL CHECK (seller_payout_cents > 0),
  total_paid_cents INTEGER NOT NULL CHECK (total_paid_cents > 0),

  -- Stripe references
  stripe_payment_intent_id VARCHAR(255),
  stripe_charge_id VARCHAR(255),
  stripe_transfer_id VARCHAR(255),

  -- FedEx references
  fedex_tracking_number VARCHAR(255),
  fedex_label_url TEXT,
  fedex_rate_id VARCHAR(255),

  -- Shipping addresses (JSONB)
  shipping_from_address JSONB,
  shipping_to_address JSONB,

  -- Status
  status VARCHAR(20) DEFAULT 'pending' NOT NULL CHECK (
    status IN (
      'pending',           -- Created, awaiting payment
      'paid',              -- Payment received
      'label_created',     -- FedEx label generated
      'shipped',           -- Package handed to FedEx
      'in_transit',        -- FedEx reports in transit
      'delivered',         -- FedEx confirms delivery
      'completed',         -- 7 days after delivery, funds released
      'disputed',          -- Buyer opened dispute
      'refunded',          -- Full refund issued
      'canceled'           -- Transaction canceled
    )
  ),

  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,
  paid_at TIMESTAMP,
  shipped_at TIMESTAMP,
  delivered_at TIMESTAMP,
  completed_at TIMESTAMP,

  -- Constraints
  CONSTRAINT chk_buyer_not_seller CHECK (buyer_id != seller_id),
  -- Note: Commission validation done in application layer, not DB constraint
  -- Reason: ROUND() behavior varies with edge cases (e.g., 333 * 0.10 = 33.3)
  -- The Edge Function calculates and validates commission before insert
  CONSTRAINT chk_total_paid_cents CHECK (
    total_paid_cents = item_price_cents + shipping_cost_cents
  )
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_marketplace_transactions_seller
  ON marketplace_transactions(seller_id, status);

CREATE INDEX IF NOT EXISTS idx_marketplace_transactions_buyer
  ON marketplace_transactions(buyer_id, status);

CREATE INDEX IF NOT EXISTS idx_marketplace_transactions_listing
  ON marketplace_transactions(listing_id);

CREATE INDEX IF NOT EXISTS idx_marketplace_transactions_tracking
  ON marketplace_transactions(fedex_tracking_number)
  WHERE fedex_tracking_number IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_marketplace_transactions_stripe
  ON marketplace_transactions(stripe_payment_intent_id)
  WHERE stripe_payment_intent_id IS NOT NULL;

-- Enable RLS
ALTER TABLE marketplace_transactions ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Policy 1: Transaction parties can view
CREATE POLICY "Transaction parties view"
ON marketplace_transactions FOR SELECT
TO authenticated
USING (seller_id = auth.uid() OR buyer_id = auth.uid());

-- Policy 2: Service role can insert (from Edge Functions/webhooks)
-- Note: Regular users cannot directly insert transactions
-- Transactions are created via Edge Functions after payment

-- Policy 3: Service role can update (from Edge Functions/webhooks)
-- Note: Status updates come from webhooks, not direct user action

-- Function to calculate commission
CREATE OR REPLACE FUNCTION calculate_marketplace_commission(item_price INTEGER)
RETURNS TABLE(
  platform_fee INTEGER,
  seller_payout INTEGER
) AS $$
BEGIN
  RETURN QUERY SELECT
    ROUND(item_price * 0.10)::INTEGER as platform_fee,
    (item_price - ROUND(item_price * 0.10))::INTEGER as seller_payout;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to complete delivered transactions (7 days)
CREATE OR REPLACE FUNCTION complete_delivered_transactions()
RETURNS INTEGER AS $$
DECLARE
  completed_count INTEGER;
BEGIN
  UPDATE marketplace_transactions
  SET status = 'completed', completed_at = NOW()
  WHERE status = 'delivered'
    AND delivered_at < NOW() - INTERVAL '7 days';

  GET DIAGNOSTICS completed_count = ROW_COUNT;
  RETURN completed_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comments
COMMENT ON TABLE marketplace_transactions IS 'Complete transaction history for marketplace sales';
COMMENT ON COLUMN marketplace_transactions.platform_fee_cents IS '10% commission on item price';
COMMENT ON COLUMN marketplace_transactions.seller_payout_cents IS '90% of item price (after commission)';
COMMENT ON FUNCTION calculate_marketplace_commission IS 'Calculates 10% commission and seller payout';
```

**Rollback** :
```sql
-- Rollback: 20260128100004_create_marketplace_transactions

DROP FUNCTION IF EXISTS complete_delivered_transactions;
DROP FUNCTION IF EXISTS calculate_marketplace_commission;

DROP POLICY IF EXISTS "Transaction parties view" ON marketplace_transactions;

DROP INDEX IF EXISTS idx_marketplace_transactions_stripe;
DROP INDEX IF EXISTS idx_marketplace_transactions_tracking;
DROP INDEX IF EXISTS idx_marketplace_transactions_listing;
DROP INDEX IF EXISTS idx_marketplace_transactions_buyer;
DROP INDEX IF EXISTS idx_marketplace_transactions_seller;

DROP TABLE IF EXISTS marketplace_transactions;
```

**Dependances** : S01, S03

---

### S05 : Creer table marketplace_messages

**Criteres cles** :
- Chat entre buyer et seller par listing
- Support Supabase Realtime
- RLS: uniquement sender et receiver
- is_read pour tracking messages non lus

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (APP-08)

**Complexite** : S (Small) - Table simple avec Realtime

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Marketplace messages table

  Scenario: Creating marketplace_messages table
    Given the marketplace_listings table exists
    When the migration create_marketplace_messages is applied
    Then table marketplace_messages should exist
    And it should have columns listing_id, sender_id, receiver_id, content, is_read, created_at

  Scenario: Only conversation participants can view
    Given a message between user-A and user-B about listing-X
    When user-A queries -> should see the message
    When user-B queries -> should see the message
    When user-C queries -> should not see the message

  Scenario: Realtime subscription works
    Given a buyer subscribed to messages for a listing
    When the seller sends a message
    Then the buyer should receive it in realtime

  Scenario: Unread messages tracking
    Given messages between buyer and seller
    When buyer reads a message
    Then is_read should be updated to true
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128100005_create_marketplace_messages
-- Description: Create marketplace messages table for buyer/seller chat

CREATE TABLE IF NOT EXISTS marketplace_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID REFERENCES marketplace_listings(id) NOT NULL,
  sender_id UUID REFERENCES profiles(id) NOT NULL,
  receiver_id UUID REFERENCES profiles(id) NOT NULL,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,

  -- Constraint: sender and receiver must be different
  CONSTRAINT chk_different_users CHECK (sender_id != receiver_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_marketplace_messages_listing
  ON marketplace_messages(listing_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_marketplace_messages_sender
  ON marketplace_messages(sender_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_marketplace_messages_receiver
  ON marketplace_messages(receiver_id, is_read, created_at DESC);

-- Enable RLS
ALTER TABLE marketplace_messages ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Policy 1: Participants can view messages
CREATE POLICY "Message participants view"
ON marketplace_messages FOR SELECT
TO authenticated
USING (sender_id = auth.uid() OR receiver_id = auth.uid());

-- Policy 2: Authenticated users can send messages to listing owner or buyer
CREATE POLICY "Send messages"
ON marketplace_messages FOR INSERT
TO authenticated
WITH CHECK (
  sender_id = auth.uid() AND
  (
    -- Sending to listing seller
    receiver_id = (SELECT seller_id FROM marketplace_listings WHERE id = listing_id)
    OR
    -- Seller responding to a buyer who messaged them
    EXISTS (
      SELECT 1 FROM marketplace_messages mm
      WHERE mm.listing_id = marketplace_messages.listing_id
        AND mm.sender_id = marketplace_messages.receiver_id
        AND mm.receiver_id = auth.uid()
    )
  )
);

-- Policy 3: Receiver can mark as read
CREATE POLICY "Mark as read"
ON marketplace_messages FOR UPDATE
TO authenticated
USING (receiver_id = auth.uid())
WITH CHECK (receiver_id = auth.uid() AND is_read = TRUE);

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE marketplace_messages;

-- Comment
COMMENT ON TABLE marketplace_messages IS 'Chat messages between buyer and seller for marketplace listings';
```

**Rollback** :
```sql
-- Rollback: 20260128100005_create_marketplace_messages

ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS marketplace_messages;

DROP POLICY IF EXISTS "Mark as read" ON marketplace_messages;
DROP POLICY IF EXISTS "Send messages" ON marketplace_messages;
DROP POLICY IF EXISTS "Message participants view" ON marketplace_messages;

DROP INDEX IF EXISTS idx_marketplace_messages_receiver;
DROP INDEX IF EXISTS idx_marketplace_messages_sender;
DROP INDEX IF EXISTS idx_marketplace_messages_listing;

DROP TABLE IF EXISTS marketplace_messages;
```

**Dependances** : S01

---

### S06 : Creer table fedex_events

**Criteres cles** :
- Audit log complet de tous les events FedEx
- Raw payload JSONB pour debugging
- Lien vers transaction
- Timeline tracking avec event_timestamp

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (APP-08)

**Complexite** : S (Small) - Table audit simple

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: FedEx events audit table

  Scenario: Creating fedex_events table
    Given the marketplace_transactions table exists
    When the migration create_fedex_events is applied
    Then table fedex_events should exist
    And it should have columns for tracking_number, event_type, event_description, location, event_timestamp
    And it should store raw_payload as JSONB

  Scenario: All FedEx events are logged
    Given a transaction with tracking
    When FedEx reports: picked_up, in_transit, out_for_delivery, delivered
    Then each event should be logged with full details
    And raw webhook payload should be preserved

  Scenario: Transaction parties can view FedEx events
    Given FedEx events for a transaction
    When the buyer queries -> should see events
    When the seller queries -> should see events
    When other user queries -> should be denied
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128100006_create_fedex_events
-- Description: Create FedEx events audit log table

CREATE TABLE IF NOT EXISTS fedex_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID REFERENCES marketplace_transactions(id),
  tracking_number VARCHAR(255),

  -- Event details
  event_type VARCHAR(100) NOT NULL,
  event_description TEXT,
  event_code VARCHAR(50),
  location TEXT,
  location_city VARCHAR(255),
  location_country VARCHAR(100),

  -- Timestamp when FedEx recorded the event
  event_timestamp TIMESTAMP,

  -- Raw FedEx payload for debugging
  raw_payload JSONB,

  -- When we received/processed this event
  created_at TIMESTAMP DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_fedex_events_transaction
  ON fedex_events(transaction_id, event_timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_fedex_events_tracking
  ON fedex_events(tracking_number, event_timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_fedex_events_type
  ON fedex_events(event_type);

-- Enable RLS
ALTER TABLE fedex_events ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Policy 1: Transaction parties can view FedEx events
CREATE POLICY "Transaction parties view events"
ON fedex_events FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM marketplace_transactions mt
    WHERE mt.id = fedex_events.transaction_id
    AND (mt.seller_id = auth.uid() OR mt.buyer_id = auth.uid())
  )
);

-- Note: Inserts are done via service_role from Edge Functions handling FedEx webhooks

-- Comment
COMMENT ON TABLE fedex_events IS 'Audit log of all FedEx tracking events for marketplace shipments';
COMMENT ON COLUMN fedex_events.raw_payload IS 'Complete FedEx webhook payload for debugging';
```

**Rollback** :
```sql
-- Rollback: 20260128100006_create_fedex_events

DROP POLICY IF EXISTS "Transaction parties view events" ON fedex_events;

DROP INDEX IF EXISTS idx_fedex_events_type;
DROP INDEX IF EXISTS idx_fedex_events_tracking;
DROP INDEX IF EXISTS idx_fedex_events_transaction;

DROP TABLE IF EXISTS fedex_events;
```

**Dependances** : S04

---

### S07 : Creer bucket marketplace-listings avec RLS

**Criteres cles** :
- Bucket `marketplace-listings` prive
- Structure: `{listing_id}/{filename}`
- Max 20MB par photo
- MIME types: jpeg, png, webp, heic
- RLS: seller upload/delete, tous peuvent voir photos d'annonces actives

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (APP-08)

**Complexite** : S (Small) - Bucket avec RLS simple

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Marketplace listings storage bucket

  Scenario: Bucket creation
    Given the Supabase Storage service
    When bucket marketplace-listings is created
    Then the bucket should exist and be private
    And file size limit should be 20MB

  Scenario: Seller can upload photos to own listing
    Given a seller with a listing
    When uploading a photo to {listing_id}/photo1.jpg
    Then upload should succeed

  Scenario: Seller cannot upload to other's listing
    Given seller-A with listing-A and seller-B with listing-B
    When seller-A tries to upload to listing-B folder
    Then upload should be denied

  Scenario: Anyone can view photos of active listings
    Given an active listing with photos
    When any authenticated user requests the photos
    Then photos should be accessible

  Scenario: Draft listing photos only visible to seller
    Given a draft listing with photos
    When the seller requests photos -> should succeed
    When another user requests -> should be denied
```

**Details techniques** :

**Migration SQL (Storage policies)** :
```sql
-- Migration: 20260128100007_create_marketplace_listings_bucket
-- Description: Create storage bucket for marketplace listing photos

-- Note: Bucket creation is done via Supabase Dashboard/API
-- This migration handles the RLS policies

-- Policy 1: Seller can upload to own listing folder
CREATE POLICY "Seller uploads listing photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'marketplace-listings'
  AND EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id::text = (storage.foldername(name))[1]
    AND ml.seller_id = auth.uid()
  )
);

-- Policy 2: Public read for active listings
CREATE POLICY "Read active listing photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'marketplace-listings'
  AND EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id::text = (storage.foldername(name))[1]
    AND ml.status = 'active'
  )
);

-- Policy 3: Seller can read own listing photos (even draft)
CREATE POLICY "Seller reads own listing photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'marketplace-listings'
  AND EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id::text = (storage.foldername(name))[1]
    AND ml.seller_id = auth.uid()
  )
);

-- Policy 4: Seller can delete own listing photos
CREATE POLICY "Seller deletes listing photos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'marketplace-listings'
  AND EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id::text = (storage.foldername(name))[1]
    AND ml.seller_id = auth.uid()
  )
);

-- Comments
COMMENT ON POLICY "Seller uploads listing photos" ON storage.objects
  IS 'Sellers can upload photos to their own listing folders';
COMMENT ON POLICY "Read active listing photos" ON storage.objects
  IS 'Anyone can view photos of active marketplace listings';
```

**Bucket Creation (via Supabase API)** :
```typescript
const { data, error } = await supabase.storage.createBucket('marketplace-listings', {
  public: false,
  fileSizeLimit: 20971520, // 20MB max
  allowedMimeTypes: [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic'
  ]
});
```

**Rollback** :
```sql
-- Rollback: 20260128100007_create_marketplace_listings_bucket

DROP POLICY IF EXISTS "Seller deletes listing photos" ON storage.objects;
DROP POLICY IF EXISTS "Seller reads own listing photos" ON storage.objects;
DROP POLICY IF EXISTS "Read active listing photos" ON storage.objects;
DROP POLICY IF EXISTS "Seller uploads listing photos" ON storage.objects;

-- Note: Bucket deletion should be done manually after data backup
```

**Dependances** : S01

---

### S08 : Implementer CGVU marketplace seller

**Criteres cles** :
- Modal avec texte complet CGVU vendeur (scroll obligatoire)
- Checkbox a cocher apres scroll
- Logging complet: user_id, cgvu_type, cgvu_version, IP, user_agent, device_info, timestamp
- Bloque publication annonce si non accepte

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 12 (CGVU)

**Complexite** : M (Medium) - UI + logging complet

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: CGVU marketplace seller acceptance

  Scenario: Seller must accept CGVU before first listing
    Given a seller who has never accepted marketplace CGVU
    When they try to publish a listing
    Then CGVU modal should be displayed
    And checkbox should be disabled until scrolled to bottom
    And publish should be blocked until accepted

  Scenario: CGVU acceptance is logged
    Given a seller accepting CGVU
    When they check the box and confirm
    Then cgvu_acceptances should contain:
      | user_id | seller's UUID |
      | cgvu_type | marketplace_seller |
      | cgvu_version | 1.0 |
      | ip_address | user's IP |
      | user_agent | browser/app info |
      | device_info | OS, app version |
      | accepted_at | current timestamp |

  Scenario: Seller who accepted can publish without modal
    Given a seller who already accepted CGVU
    When they publish a new listing
    Then no CGVU modal should appear
    And listing should be published directly
```

**Details techniques** :

**Table SQL** (si pas deja dans EPIC-11):
```sql
-- Migration: 20260128100008_create_cgvu_acceptances (if not exists)
-- Description: CGVU acceptance logging table

CREATE TABLE IF NOT EXISTS cgvu_acceptances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  cgvu_type VARCHAR(50) NOT NULL,
  cgvu_version VARCHAR(20) NOT NULL,
  ip_address VARCHAR(50),
  user_agent TEXT,
  device_info JSONB,
  accepted_at TIMESTAMP DEFAULT NOW() NOT NULL,

  -- Unique constraint: one acceptance per type per user (can re-accept new versions)
  UNIQUE(user_id, cgvu_type, cgvu_version)
);

-- Index for checking acceptance
CREATE INDEX IF NOT EXISTS idx_cgvu_acceptances_user_type
  ON cgvu_acceptances(user_id, cgvu_type);

-- Enable RLS
ALTER TABLE cgvu_acceptances ENABLE ROW LEVEL SECURITY;

-- Policy: User can view own acceptances
CREATE POLICY "User views own acceptances"
ON cgvu_acceptances FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Policy: User can insert own acceptances
CREATE POLICY "User creates own acceptances"
ON cgvu_acceptances FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- Comment
COMMENT ON TABLE cgvu_acceptances IS 'CGVU acceptance audit log with full device info';
```

**Flutter Implementation Notes** :
- `lib/features/marketplace/presentation/widgets/cgvu_seller_modal.dart`
- Use `ScrollController` to detect scroll to bottom
- Disable checkbox until `_hasScrolledToBottom = true`
- Call Edge Function to log with IP detection
- Store acceptance in local cache to avoid repeated checks

**Dependances** : None (can be developed in parallel)

---

### S09 : Implementer CGVU marketplace buyer

**Criteres cles** :
- Modal avec texte complet CGVU acheteur (scroll obligatoire)
- Affiche avant premier achat
- Meme logging que seller
- Bloque paiement si non accepte

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 12 (CGVU)

**Complexite** : M (Medium) - UI + logging complet

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: CGVU marketplace buyer acceptance

  Scenario: Buyer must accept CGVU before first purchase
    Given a buyer who has never accepted marketplace buyer CGVU
    When they proceed to checkout
    Then CGVU modal should be displayed
    And payment button should be blocked until accepted

  Scenario: Acceptance logged correctly
    Given a buyer accepting CGVU
    Then cgvu_acceptances should have cgvu_type = 'marketplace_buyer'
```

**Details techniques** : Similar to S08, with `cgvu_type = 'marketplace_buyer'`

**Flutter Implementation Notes** :
- `lib/features/marketplace/presentation/widgets/cgvu_buyer_modal.dart`
- Display in checkout flow before payment
- Same scroll-to-enable-checkbox pattern

**Dependances** : S08 (shared table)

---

### S10 : Stripe Connect onboarding Express vendeurs

**Criteres cles** :
- Onboarding Express simplifie (redirection Stripe)
- Webhook `account.updated` pour tracker onboarding_complete, charges_enabled
- Bloquer publication si charges_enabled = false
- UI pour voir statut compte et relancer onboarding si necessaire

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 8 (APP-05) et Section 11 (APP-08)

**Complexite** : L (Large) - Integration Stripe complexe

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Stripe Connect Express onboarding for sellers

  Scenario: Seller initiates Stripe Connect onboarding
    Given a seller without Stripe account
    When they click "Setup payments"
    Then they should be redirected to Stripe Connect onboarding
    And a stripe_accounts record should be created with onboarding_complete = false

  Scenario: Webhook updates account status
    Given a seller completing Stripe onboarding
    When Stripe sends account.updated webhook
    Then stripe_accounts should be updated:
      | onboarding_complete | true |
      | charges_enabled | true |
      | payouts_enabled | true |

  Scenario: Seller cannot publish without Stripe setup
    Given a seller with charges_enabled = false
    When they try to publish a listing
    Then they should be prompted to complete Stripe setup

  Scenario: Seller can retry incomplete onboarding
    Given a seller with incomplete Stripe onboarding
    When they click "Complete setup"
    Then they should be redirected back to Stripe to continue
```

**Details techniques** :

**Edge Function: create-stripe-connect-account**
```typescript
import Stripe from 'stripe';

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!);

Deno.serve(async (req) => {
  const { user_id, return_url, refresh_url } = await req.json();

  // Create Express account
  const account = await stripe.accounts.create({
    type: 'express',
    capabilities: {
      card_payments: { requested: true },
      transfers: { requested: true },
    },
  });

  // Store in database
  await supabase.from('stripe_accounts').upsert({
    user_id,
    stripe_account_id: account.id,
    account_type: 'express',
    onboarding_complete: false,
    charges_enabled: false,
    payouts_enabled: false,
  });

  // Create onboarding link
  const accountLink = await stripe.accountLinks.create({
    account: account.id,
    refresh_url,
    return_url,
    type: 'account_onboarding',
  });

  return new Response(JSON.stringify({ url: accountLink.url }));
});
```

**Webhook Handler (in stripe-webhook Edge Function)**:
```typescript
case 'account.updated':
  const account = event.data.object as Stripe.Account;
  await supabase.from('stripe_accounts')
    .update({
      onboarding_complete: account.details_submitted,
      charges_enabled: account.charges_enabled,
      payouts_enabled: account.payouts_enabled,
      updated_at: new Date(),
    })
    .eq('stripe_account_id', account.id);
  break;
```

**Dependances** : EPIC-11 (stripe_accounts table)

---

### S11 : Edge Function FedEx Rate API

**Criteres cles** :
- Calcul frais de port en temps reel
- Validation adresses (from et to)
- Support multi-pays
- Retourne tarifs pour differents services (Economy, Priority, etc.)

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (APP-08)

**Complexite** : M (Medium) - Integration API externe

#### Configuration FedEx (IMPORTANT - À faire AVANT S11)

**Étape 1: Créer un compte FedEx Developer**
1. Aller sur https://developer.fedex.com/
2. Créer un compte ou se connecter
3. Créer une "Organization" pour Lynewed

**Étape 2: Créer une Application API**
1. Dashboard → Create API Project
2. Sélectionner les APIs requises:
   - **Address Validation API** (gratuit)
   - **Rate API** (gratuit)
   - **Ship API** (coût par étiquette ~$0.10)
   - **Track API** (gratuit)
3. Choisir "Server" comme type d'application
4. Obtenir les credentials:
   - `Client ID`
   - `Client Secret`
   - `Account Number` (depuis votre compte FedEx business)

**Étape 3: Variables d'environnement Supabase**
```bash
# Dans Supabase Dashboard > Edge Functions > Secrets
FEDEX_CLIENT_ID=your_client_id_here
FEDEX_CLIENT_SECRET=your_client_secret_here
FEDEX_ACCOUNT_NUMBER=your_account_number_here
FEDEX_ENV=sandbox  # 'sandbox' pour tests, 'production' pour prod
```

**Étape 4: Tester en mode Sandbox**
```bash
# URL Sandbox: https://apis-sandbox.fedex.com
# URL Production: https://apis.fedex.com

# Test rapide avec curl
curl -X POST "https://apis-sandbox.fedex.com/oauth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=YOUR_ID&client_secret=YOUR_SECRET"
```

**Coûts estimés FedEx API**:
| API | Coût |
|-----|------|
| Address Validation | Gratuit |
| Rate | Gratuit |
| Ship (étiquette) | ~$0.10/étiquette |
| Track | Gratuit |

**Note**: Le compte FedEx business doit être activé pour l'expédition internationale si nécessaire.

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: FedEx Rate API integration

  Scenario: Calculate shipping rate for domestic shipment
    Given a listing in New York
    And a buyer address in Los Angeles
    When calculating shipping rate
    Then response should include:
      | service_type | rate_cents | estimated_days |
      | FedEx Ground | 1500 | 5-7 |
      | FedEx Express | 3500 | 2-3 |

  Scenario: Calculate shipping rate for international
    Given a listing in Paris, France
    And a buyer address in New York, USA
    When calculating shipping rate
    Then response should include international options
    And customs fees should be indicated

  Scenario: Address validation fails
    Given an invalid destination address
    When calculating shipping rate
    Then error should indicate invalid address
    And suggest corrections if available
```

**Details techniques** :

**Edge Function: fedex-calculate-rate**
```typescript
// Edge Function: fedex-calculate-rate
import { FedExClient } from './fedex-client.ts';

const fedex = new FedExClient({
  clientId: Deno.env.get('FEDEX_CLIENT_ID')!,
  clientSecret: Deno.env.get('FEDEX_CLIENT_SECRET')!,
  accountNumber: Deno.env.get('FEDEX_ACCOUNT_NUMBER')!,
  environment: 'production', // or 'sandbox'
});

Deno.serve(async (req) => {
  const {
    from_address,
    to_address,
    package_weight_kg,
    package_dimensions_cm
  } = await req.json();

  try {
    // 1. Validate addresses
    const [fromValidation, toValidation] = await Promise.all([
      fedex.validateAddress(from_address),
      fedex.validateAddress(to_address),
    ]);

    if (!fromValidation.valid || !toValidation.valid) {
      return new Response(JSON.stringify({
        error: 'invalid_address',
        from_suggestions: fromValidation.suggestions,
        to_suggestions: toValidation.suggestions,
      }), { status: 400 });
    }

    // 2. Get rates
    const rates = await fedex.getRates({
      shipper: from_address,
      recipient: to_address,
      packageDetails: {
        weight: { units: 'KG', value: package_weight_kg },
        dimensions: {
          units: 'CM',
          length: package_dimensions_cm.length,
          width: package_dimensions_cm.width,
          height: package_dimensions_cm.height,
        },
      },
    });

    // 3. Format response
    const formattedRates = rates.map(rate => ({
      service_type: rate.serviceType,
      service_name: rate.serviceName,
      rate_cents: Math.round(rate.totalCharges * 100),
      currency: 'USD',
      estimated_delivery: rate.deliveryTimestamp,
      estimated_days: rate.transitTime,
    }));

    return new Response(JSON.stringify({ rates: formattedRates }));

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});
```

**Dependances** : None (can be developed early)

---

### S12 : Edge Function FedEx Ship API

**Criteres cles** :
- Generation etiquette d'expedition
- Retourne tracking number et PDF label
- Enregistre dans fedex_events
- Email PDF au vendeur

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (APP-08)

**Complexite** : M (Medium) - Integration API + PDF

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: FedEx Ship API integration

  Scenario: Generate shipping label
    Given a paid transaction with validated addresses
    When seller requests label generation
    Then FedEx Ship API should return:
      | tracking_number | valid FedEx tracking |
      | label_url | URL to PDF label |
    And transaction should be updated with tracking info
    And fedex_events should log 'label_created' event
    And email should be sent to seller with PDF

  Scenario: Ship API fails
    Given a network error with FedEx
    When label generation is attempted
    Then error should be logged
    And seller should see retry option
```

**Dependances** : S04, S06, S11

---

### S13 : Edge Function FedEx Track API

**Criteres cles** :
- Polling tracking updates (ou webhook si disponible)
- Mise a jour transaction status
- Log tous events dans fedex_events
- Notifications aux users a chaque changement important

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (APP-08)

**Complexite** : M (Medium) - Polling/webhook + notifications

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: FedEx Track API integration

  Scenario: Track package status updates
    Given a shipped transaction with tracking number
    When FedEx reports package is in transit
    Then transaction status should update to 'in_transit'
    And fedex_events should log the event
    And buyer should receive notification

  Scenario: Package delivered
    Given a package out for delivery
    When FedEx confirms delivery
    Then transaction status should be 'delivered'
    And both buyer and seller should be notified
    And 7-day countdown for completion starts
```

**Dependances** : S04, S06, S12

---

### S14 : Formulaire creation annonce vendeur

**Criteres cles** :
- Upload 5-10 photos (reorderable)
- Tous champs: titre, description, categorie, prix, taille, marque, etat, longueur manches (robes), localisation
- Validation complete avant publication
- CGVU check (S08)
- Stripe check (S10)

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (US-08.1 to US-08.4)

**Complexite** : L (Large) - UI complexe avec validation

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Create listing form

  Scenario: Upload photos
    Given a seller creating a listing
    When they upload photos
    Then minimum 5 photos required
    And maximum 10 photos allowed
    And photos should be reorderable via drag-and-drop
    And first photo is the cover

  Scenario: Fill all required fields
    Given the listing form
    Then these fields should be required:
      | title | max 255 chars |
      | category | dress or shoes |
      | price | > 0 |
      | condition | new/excellent/good/fair |
      | country | required |
    And for dresses, sleeve_length should be required

  Scenario: Publish listing flow
    Given a completed listing form
    When seller clicks "Publish"
    Then if CGVU not accepted -> show CGVU modal
    Then if Stripe not setup -> show Stripe setup prompt
    Then listing status should change to 'active'
    And listing should appear in marketplace feed
```

**Flutter Implementation Notes** :
- `lib/features/marketplace/presentation/pages/create_listing_page.dart`
- Use `ReorderableListView` for photo ordering
- Use `image_picker` for photo selection
- Implement form validation with `Form` and `FormField` widgets
- Show loading state during photo upload

**Dependances** : S01, S02, S07, S08, S10

---

### S15 : Page liste annonces (feed)

**Criteres cles** :
- Feed avec cards d'annonces
- Infinite scroll (pagination)
- Quick filters (categorie)
- Link vers filtres avances (S17)
- Pull to refresh

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (US-08.10)

**Complexite** : M (Medium) - UI feed standard

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Marketplace feed

  Scenario: Display listings feed
    Given active listings in the marketplace
    When user opens marketplace tab
    Then listings should display as cards with:
      | cover photo | first photo |
      | title | listing title |
      | price | formatted price |
      | condition | badge |
      | location | city, country |

  Scenario: Infinite scroll pagination
    Given more than 20 listings
    When user scrolls to bottom
    Then next page of listings should load
    And loading indicator should show

  Scenario: Quick category filter
    Given listings of both dresses and shoes
    When user taps "Dresses" chip
    Then only dress listings should show
```

**Dependances** : S01

---

### S16 : Page detail annonce

**Criteres cles** :
- Carousel photos (swipeable)
- Toutes infos de l'annonce
- Boutons: Contacter, Faire une offre, Acheter
- Infos vendeur (profil, autres annonces)

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (US-08.10)

**Complexite** : M (Medium) - UI detail page

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Listing detail page

  Scenario: Display listing details
    Given an active listing
    When user taps on it from feed
    Then detail page should show:
      | photo carousel | all photos swipeable |
      | title | full title |
      | price | formatted with currency |
      | description | full text |
      | size | size value |
      | brand | designer brand |
      | condition | with description |
      | location | city, country |

  Scenario: Action buttons
    Given a listing detail page
    Then these buttons should be visible:
      | Contact Seller | opens chat |
      | Make Offer | opens offer modal |
      | Buy Now | proceeds to checkout |
```

**Dependances** : S01, S02

---

### S17 : Systeme de filtres avances

**Criteres cles** :
- Filter sheet avec tous criteres
- Categorie (dress/shoes)
- Taille (avec guide tailles) - voir section Guide des Tailles ci-dessous
- Marque (autocomplete) - voir section Autocomplete Marques ci-dessous
- Etat (checkboxes)
- Prix (range slider)
- Localisation (pays, rayon km)

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (US-08.12)

**Complexite** : M (Medium) - UI filter sheet

#### Guide des Tailles (Robes)

Référence pour le champ `size` dans les filtres et la création d'annonce :

| Size | EU | US | UK | Bust (cm) | Waist (cm) |
|------|----|----|----|-----------:|----------:|
| XS | 32-34 | 0-2 | 4-6 | 76-84 | 58-64 |
| S | 36-38 | 4-6 | 8-10 | 84-92 | 64-72 |
| M | 40-42 | 8-10 | 12-14 | 92-100 | 72-80 |
| L | 44-46 | 12-14 | 16-18 | 100-108 | 80-88 |
| XL | 48-50 | 16-18 | 20-22 | 108-116 | 88-96 |

**Implémentation** : Dropdown avec labels "XS (EU 32-34 / US 0-2)" etc.

#### Guide des Tailles (Chaussures)

| Size | EU | US | UK |
|------|----|----|----|
| 35 | 35 | 4 | 2.5 |
| 36 | 36 | 5 | 3.5 |
| 37 | 37 | 6 | 4.5 |
| 38 | 38 | 7 | 5.5 |
| 39 | 39 | 8 | 6.5 |
| 40 | 40 | 9 | 7.5 |
| 41 | 41 | 10 | 8.5 |
| 42 | 42 | 11 | 9.5 |

**Implémentation** : Dropdown avec labels "37 (US 6 / UK 4.5)" etc.

#### Autocomplete Marques

**Source de données** : Liste statique de marques populaires de robes de mariée

```dart
// lib/features/marketplace/data/brands_data.dart

const List<String> popularWeddingDressBrands = [
  // Haute Couture
  'Vera Wang',
  'Monique Lhuillier',
  'Oscar de la Renta',
  'Carolina Herrera',
  'Marchesa',
  'Elie Saab',
  'Zuhair Murad',
  'Pronovias',
  'Rosa Clará',

  // Mid-range
  'Maggie Sottero',
  'Sottero and Midgley',
  'Rebecca Ingram',
  'Allure Bridals',
  'Mori Lee',
  'Justin Alexander',
  'Stella York',
  'Essense of Australia',
  'Morilee',

  // Accessible
  'David\'s Bridal',
  'BHLDN',
  'Lulus',
  'Reformation',
  'ASOS',

  // French
  'Delphine Manivet',
  'Laure de Sagazan',
  'Rime Arodaky',
  'Cymbeline',
  'Suzanne Neville',

  // Other
  'Other / Unknown',
];

const List<String> popularBridalShoeBrands = [
  'Jimmy Choo',
  'Manolo Blahnik',
  'Badgley Mischka',
  'Bella Belle',
  'Rachel Simpson',
  'Charlotte Mills',
  'Emmy London',
  'Freya Rose',
  'Stuart Weitzman',
  'Louboutin',
  'Aquazzura',
  'Other / Unknown',
];
```

**Widget Autocomplete** :
- Utiliser `Autocomplete<String>` de Flutter
- Filtrer la liste pendant la frappe
- Permettre entrée libre (marque non listée)
- Option "Other / Unknown" si marque non trouvée

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Advanced filters

  Scenario: Filter by category
    Given mixed listings
    When filtering by category = 'dress'
    Then only dresses should show

  Scenario: Filter by price range
    Given listings with various prices
    When setting price range 100-500 USD
    Then only listings in that range should show

  Scenario: Filter by location
    Given listings worldwide
    When filtering by country = 'France' and radius = 50km
    Then only French listings within radius should show

  Scenario: Combined filters
    Given many listings
    When applying multiple filters
    Then results should match ALL criteria
```

**Dependances** : S15

---

### S18 : Chat buyer/seller

**Criteres cles** :
- Conversation Realtime par annonce
- Liste conversations
- Indicateur messages non lus
- Notifications push nouveau message

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (US-08.13)

**Complexite** : M (Medium) - Chat Realtime

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Marketplace chat

  Scenario: Start conversation
    Given a listing detail page
    When buyer clicks "Contact Seller"
    Then chat screen should open
    And buyer can send message

  Scenario: Realtime messages
    Given an active conversation
    When seller sends a message
    Then buyer should see it instantly (Realtime)

  Scenario: Unread indicator
    Given unread messages
    Then chat icon should show unread count
    And conversation should be marked unread
```

**Dependances** : S05

---

### S19 : Systeme d'offres

**Criteres cles** :
- Modal pour faire une offre (montant + message optionnel)
- Liste offres recues (vendeur)
- Accepter/refuser offres
- Expiration 48h avec notification

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (US-08.7, US-08.14)

**Complexite** : M (Medium) - Logique offres

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Offer system

  Scenario: Make an offer
    Given a listing detail page
    When buyer clicks "Make Offer"
    Then offer modal should appear
    And buyer enters amount and optional message
    And offer is created with 48h expiration

  Scenario: Seller responds to offer
    Given a pending offer
    When seller views offers
    Then they can Accept or Reject
    And buyer is notified of decision

  Scenario: Offer expires
    Given a pending offer older than 48h
    When expiration check runs
    Then offer status should be 'expired'
    And buyer should be notified
```

**Dependances** : S03

---

### S20 : Flow achat complet

**Criteres cles** :
- Checkout avec resume (article, prix, frais port)
- CGVU buyer check (S09)
- Calcul frais port FedEx (S11)
- Paiement Stripe
- Creation transaction (S04)

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (US-08.15 to US-08.17)

**Complexite** : L (Large) - Flow complet multi-etapes

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Complete purchase flow

  Scenario: Checkout flow
    Given a buyer clicking "Buy Now"
    Step 1: Enter/confirm shipping address
    Step 2: View shipping options (from FedEx Rate API)
    Step 3: Review order summary:
      | Item price | from listing |
      | Shipping | from FedEx |
      | Total | sum |
    Step 4: Accept CGVU (if first purchase)
    Step 5: Payment via Stripe
    Step 6: Confirmation screen with tracking setup

  Scenario: Payment succeeds
    Given successful Stripe payment
    Then transaction should be created with status 'paid'
    And listing status should be 'reserved'
    And seller should be notified
```

**Dependances** : S04, S09, S10, S11

---

### S21 : Generation etiquette FedEx (vendeur)

**Criteres cles** :
- Bouton "Generer etiquette" apres paiement
- Appel FedEx Ship API (S12)
- Affichage PDF inline
- Envoi email avec PDF
- Mise a jour statut transaction

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (US-08.8)

**Complexite** : M (Medium) - UI + integration

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Generate FedEx label

  Scenario: Seller generates label
    Given a paid transaction
    When seller clicks "Generate Shipping Label"
    Then FedEx Ship API is called
    And label PDF is displayed
    And email with PDF is sent to seller
    And transaction status becomes 'label_created'
```

**Dependances** : S12

---

### S22 : Tracking colis (acheteur)

**Criteres cles** :
- Timeline tracking avec etapes
- Mise a jour automatique (polling S13)
- Notifications a chaque etape
- Link vers site FedEx pour details

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (US-08.18)

**Complexite** : M (Medium) - UI timeline

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Package tracking

  Scenario: View tracking timeline
    Given a shipped transaction
    When buyer views transaction
    Then tracking timeline should show:
      | Order placed | with date |
      | Label created | with date |
      | Shipped | with date |
      | In transit | current status |
      | Delivered | pending |

  Scenario: Tracking updates
    Given FedEx reports new status
    Then timeline should update
    And buyer receives push notification
```

**Dependances** : S06, S13

---

### S23 : Notifications marketplace

**Criteres cles** :
- Push notifications pour: nouvelle offre, message, offre acceptee, vente, expedition, livraison
- In-app notifications
- Deep links vers ecrans pertinents

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (US-08.6)

**Complexite** : M (Medium) - Integration FCM

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Marketplace notifications

  Scenario: New offer notification
    Given a seller with active listing
    When buyer makes an offer
    Then seller receives push notification
    And tapping opens offer screen

  Scenario: Sale notification
    Given a seller
    When their item is purchased
    Then they receive push: "Your [item] sold for $X!"
```

**Dependances** : S19, S20

---

### S24 : Marqueurs marketplace sur carte

**Criteres cles** :
- Nouveau type de marqueur (dress/shoes icons)
- Tap ouvre detail annonce
- Integration avec filtres map existants
- Toggle pour afficher/masquer marketplace

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (US-08.11), Section 10 (APP-07)

**Complexite** : S (Small) - Integration map existante

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Marketplace markers on map

  Scenario: Display marketplace markers
    Given active listings with location
    When user views map with marketplace toggle ON
    Then dress listings show dress icon
    And shoe listings show shoe icon

  Scenario: Tap marker opens detail
    Given a marketplace marker
    When user taps it
    Then listing detail page opens
```

**Dependances** : S01, EPIC-13

---

### S25 : Page "Mes ventes" vendeur

**Criteres cles** :
- Liste annonces du vendeur (tous statuts)
- Statistiques: vues, offres, ventes
- Actions: editer, supprimer, voir offres
- Historique transactions

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (US-08.9)

**Complexite** : M (Medium) - Dashboard vendeur

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Seller dashboard

  Scenario: View my listings
    Given a seller with listings
    When they open "My Sales"
    Then all their listings should display
    And grouped by status: active, reserved, sold, draft

  Scenario: View earnings
    Given a seller with completed sales
    Then total earnings should display
    And 10% commission should be shown
    And net payout should be calculated
```

**Dependances** : S01, S04

---

### S26 : Navbar integration + Home preview

**Criteres cles** :
- Nouvel onglet Marketplace dans navbar (bride only)
- Section "Articles recents" sur home page
- Preview avec 3-5 articles recents

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (APP-08)

**Complexite** : S (Small) - Integration UI

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Navbar and home integration

  Scenario: Marketplace tab in navbar
    Given a bride user
    When viewing navbar
    Then marketplace tab should be visible (shopping bag icon)

  Scenario: Home page preview
    Given active marketplace listings
    When bride views home page
    Then "Marketplace" section should show
    And 3-5 recent listings as cards
    And "See all" button navigates to full feed
```

**Dependances** : S15

---

## Risques et Mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| FedEx API downtime | HAUT - Achats bloques | Afficher message maintenance, retry automatique |
| Stripe Connect rejection | HAUT - Vendeurs bloques | Support onboarding, documentation claire |
| Litiges acheteur/vendeur | MOYEN - Reputation | CGVU clairs, logs complets, pas de garantie Lynewed |
| Commission contestee | MOYEN - Legal | CGVU explicites, acceptance loggee |
| Photos inappropriees | FAIBLE - Moderation | Reporting system, review manuelle |
| Fraude vendeur | MOYEN - Confiance | Verification identite via Stripe, reviews |
| Colis perdu | MOYEN - Dispute | Assurance FedEx, logs tracking complets |
| Performances feed | FAIBLE - UX | Pagination, indexes optimises, CDN photos |

---

## RLS Policies Summary (Decision D-16)

Toutes les tables de cet Epic ont des RLS policies obligatoires:

| Table | Policies | Access |
|-------|----------|--------|
| `marketplace_listings` | 5 policies | Active visible to brides, seller manages own |
| `marketplace_photos` | 2 policies | Follows listing access |
| `marketplace_offers` | 5 policies | Buyer own offers, seller listing offers |
| `marketplace_transactions` | 1 policy | Seller + buyer only |
| `marketplace_messages` | 3 policies | Sender + receiver only |
| `fedex_events` | 1 policy | Transaction parties only |
| `storage.objects` | 4 policies | Seller upload, public read active |
| `cgvu_acceptances` | 2 policies | User own acceptances |

---

## Ordre d'Execution Recommande

```
Phase 1: Database Foundation (S01-S07)
├── S01 (listings) ──┬── S02 (photos) ── S07 (storage bucket)
│                    ├── S03 (offers)
│                    ├── S05 (messages)
│                    └── S04 (transactions) ── S06 (fedex_events)

Phase 2: CGVU & Stripe (S08-S10)
├── S08 (CGVU seller)
├── S09 (CGVU buyer)
└── S10 (Stripe Connect) -- Depends on EPIC-11

Phase 3: FedEx Integration (S11-S13)
├── S11 (Rate API)
├── S12 (Ship API) -- Depends on S11
└── S13 (Track API) -- Depends on S12

Phase 4: Frontend Core (S14-S18)
├── S14 (Create listing form)
├── S15 (Feed) ── S17 (Filters)
├── S16 (Detail page)
└── S18 (Chat)

Phase 5: Transactions (S19-S22)
├── S19 (Offers)
├── S20 (Purchase flow)
├── S21 (Label generation)
└── S22 (Tracking)

Phase 6: Polish (S23-S26)
├── S23 (Notifications)
├── S24 (Map markers)
├── S25 (Seller dashboard)
└── S26 (Navbar + Home)
```

---

## Cross-Epic Dependencies

### Required Before Starting EPIC-14

| Epic | Why Required | Critical Stories |
|------|--------------|------------------|
| **EPIC-06** | Enum userRole, invite_code | All stories validated |
| **EPIC-11** | stripe_accounts, purchases, stripe_events tables | S01-S06 completed |

### Optional Enhancement

| Epic | Enhancement | Affected Stories |
|------|-------------|------------------|
| **EPIC-13** | Map filters for marketplace | S24 (markers) |

---

## Configuration FedEx API

> ⚠️ **IMPORTANT** : Les credentials ci-dessous sont en mode **SANDBOX (test)**. Ne PAS utiliser en production sans basculer vers les endpoints production.

### Credentials Disponibles

Les credentials FedEx sont stockés dans `.env.fedex` (gitignored) :

```bash
# Credentials de connexion
FEDEX_CLIENT_ID=l7915167202dbc400c9c338d7bbf591bc0
FEDEX_CLIENT_SECRET=3be7c39d9ab1402eba0a867430edfcf6

# Compte FedEx
FEDEX_ACCOUNT_NUMBER=740561073

# Environnement
FEDEX_API_URL=https://apis-sandbox.fedex.com
# Production: https://apis.fedex.com
```

### APIs Activées

| API | Usage dans Lynewed | Stories |
|-----|-------------------|---------|
| **Address Validation API** | Valider adresses vendeur/acheteur avant expédition | S11 |
| **Rates and Transit Times API** | Calculer frais de port en temps réel | S11 |
| **Ship API** | Générer étiquettes, obtenir tracking number | S12, S21 |

### Authentification OAuth2

```typescript
// Obtenir un token d'accès (valide 1 heure)
const response = await fetch('https://apis-sandbox.fedex.com/oauth/token', {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  body: `grant_type=client_credentials&client_id=${FEDEX_CLIENT_ID}&client_secret=${FEDEX_CLIENT_SECRET}`
});
const { access_token } = await response.json();

// Utiliser le token dans les requêtes
const rateResponse = await fetch('https://apis-sandbox.fedex.com/rate/v1/rates/quotes', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${access_token}`,
    'Content-Type': 'application/json',
    'X-locale': 'en_US'
  },
  body: JSON.stringify(rateRequest)
});
```

### Documentation Context7

Pour la documentation complète des APIs FedEx, utiliser Context7 :

```
Library ID: /websites/developer_fedex_api_en-us
```

Queries utiles :
- "How to calculate shipping rates"
- "How to create shipment and generate label"
- "How to validate address"
- "OAuth2 authentication flow"

### Variables Supabase Edge Functions

Configurer dans **Supabase Dashboard > Edge Functions > Secrets** :

```
FEDEX_CLIENT_ID=l7915167202dbc400c9c338d7bbf591bc0
FEDEX_CLIENT_SECRET=3be7c39d9ab1402eba0a867430edfcf6
FEDEX_ACCOUNT_NUMBER=740561073
FEDEX_API_URL=https://apis-sandbox.fedex.com
```

### Passage en Production

Quand prêt pour la production :

1. **Basculer l'URL** : `https://apis.fedex.com` (au lieu de sandbox)
2. **Vérifier le compte FedEx** : S'assurer que le compte business est activé pour l'international
3. **Tester** : Faire une expédition test avec vrai colis
4. **Mettre à jour les secrets Supabase** : Changer `FEDEX_API_URL`

### Coûts Estimés

| API | Coût |
|-----|------|
| Address Validation | Gratuit |
| Rates and Transit Times | Gratuit |
| Ship (génération étiquette) | ~$0.10/étiquette |

> **Note** : Les frais d'expédition réels (payés par l'acheteur) sont distincts des frais API.

---

## References PRD

| Section PRD | Contenu utilise |
|-------------|-----------------|
| Section 11 | APP-08 Marketplace Robes & Chaussures (complete) |
| Section 8 | APP-05 Integration Stripe Complete |
| Section 12 | CGVU & Conformite juridique |
| Section 14 | Decisions de conception (D-07 USD, D-08 webhooks, D-09 navbar) |
| Section 15.A | Tables Supabase a creer |
| Section 15.B | Edge Functions a creer |
| Section 15.D.5 | RLS Policies Marketplace |

---

## Metriques de Succes

| Metrique | Cible | Mesure |
|----------|-------|--------|
| Annonces creees | 50+ premier mois | COUNT marketplace_listings |
| Transactions completees | 10+ premier mois | COUNT marketplace_transactions WHERE status='completed' |
| Commission generee | 500+ USD premier mois | SUM platform_fee_cents / 100 |
| Temps moyen achat | < 5 minutes | Analytics |
| Taux abandon checkout | < 30% | Analytics |
| Satisfaction vendeurs | > 4/5 | Survey |

---

## Prochaine Etape

Apres validation de cet Epic:
1. Verifier EPIC-06 et EPIC-11 sont completes
2. Executer `/create-story EPIC-14` pour decomposer en stories individuelles
3. Configurer environnement FedEx (sandbox puis production)
4. Configurer Stripe Connect (test mode puis live)
5. Commencer par Phase 1 (Database Foundation)
