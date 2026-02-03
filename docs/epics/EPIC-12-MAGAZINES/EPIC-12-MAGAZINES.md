# EPIC-12-MAGAZINES

> Resume : Permettre aux brides de commander des magazines photo imprimes a partir de leur galerie et des photos guests
> Status : ✅ COMPLETE
> Domaine : Features / E-commerce / Media
> Cree le : 2026-01-29
> MAJ : 2026-02-03
> Completed : 2026-02-03

---

## Contexte

### Pourquoi cet Epic

Cet Epic remplace l'ancien EPIC-12-REELS (abandonne). Thierry a decide de pivoter vers un produit physique : les **magazines photo de mariage**. Cette feature permet aux brides de :
1. Trier et selectionner leurs photos preferees
2. Partager une galerie avec les guests
3. Previsualiser un magazine style editorial
4. Commander et payer via Stripe
5. Recevoir un magazine imprime (production manuelle par Thierry)

**Decision business** : Pas d'integration API imprimeur en V1. Thierry gere manuellement la production avec son fournisseur. L'app prepare la commande, Thierry recoit les infos dans l'admin panel et s'occupe du reste.

### Parcours Utilisateur (Thierry's Vision)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PARCOURS BRIDE → MAGAZINE                                 │
│                                                                              │
│  1. GALERIE BRIDE                                                            │
│     ┌─────────────────────────────────────────────────────────────────────┐ │
│     │  [Grid photos] avec checkboxes de selection                         │ │
│     │  Actions sur selection:                                             │ │
│     │  [⭐ Favorite] [👁 Hide] [🗑 Delete] [⬇ Download] [🔗 Share]        │ │
│     │                                                                     │ │
│     │  Filtre: [All] [Favorites] [Hidden]                                 │ │
│     └─────────────────────────────────────────────────────────────────────┘ │
│                              │                                               │
│                              ▼                                               │
│  2. SELECTION MAGAZINE                                                       │
│     ┌─────────────────────────────────────────────────────────────────────┐ │
│     │  "X PHOTOS SELECTED"  [Select all]  [X]                             │ │
│     │  ┌─────┬─────┬─────┐                                                │ │
│     │  │ ✓   │     │ ✓   │  Photos selectionnees avec checkmark orange   │ │
│     │  └─────┴─────┴─────┘                                                │ │
│     │                                                                     │ │
│     │  [📖 Create Magazine] [⬇ Download] [🔗 Share as gallery]           │ │
│     └─────────────────────────────────────────────────────────────────────┘ │
│                              │                                               │
│                              ▼                                               │
│  3. PREVIEW MAGAZINE                                                         │
│     ┌─────────────────────────────────────────────────────────────────────┐ │
│     │  ┌──────────────────┬──────────────────┐                            │ │
│     │  │                  │ DIGITAL EDITION  │                            │ │
│     │  │                  │   LYNEWED        │  ← Couverture              │ │
│     │  │                  │                  │                            │ │
│     │  │                  │ Jessica & Kyle   │                            │ │
│     │  │                  │ June 12, 2025    │                            │ │
│     │  └──────────────────┴──────────────────┘                            │ │
│     │                                                                     │ │
│     │  [← Back] [Edit Layout] [Order Magazine →]                          │ │
│     └─────────────────────────────────────────────────────────────────────┘ │
│                              │                                               │
│                              ▼                                               │
│  4. CHECKOUT STRIPE                                                          │
│     ┌─────────────────────────────────────────────────────────────────────┐ │
│     │  Magazine de mariage - $XX.XX                                       │ │
│     │  Shipping - $XX.XX (via FedEx)                                      │ │
│     │  ─────────────────────────                                          │ │
│     │  Total: $XX.XX                                                      │ │
│     │                                                                     │ │
│     │  Shipping Address:                                                  │ │
│     │  [________________________]                                         │ │
│     │                                                                     │ │
│     │  [☑] J'accepte les CGVU                                             │ │
│     │  [Pay with Stripe →]                                                │ │
│     └─────────────────────────────────────────────────────────────────────┘ │
│                              │                                               │
│                              ▼                                               │
│  5. CONFIRMATION + ADMIN                                                     │
│     ┌─────────────────────────────────────────────────────────────────────┐ │
│     │  BRIDE SIDE:                                                        │ │
│     │  "Your order has been placed! Order #12345"                         │ │
│     │  "You will receive your magazine within 2-3 weeks"                  │ │
│     │                                                                     │ │
│     │  ADMIN SIDE (Thierry):                                              │ │
│     │  - Liste des commandes avec statuts                                 │ │
│     │  - Photos selectionnees + liens storage                             │ │
│     │  - Adresse livraison                                                │ │
│     │  - Actions: [Mark as Production] [Mark as Shipped] [Add Tracking]   │ │
│     └─────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### MCP Stripe - Configuration Autonome

> ⚠️ **IMPORTANT : COMPTE STRIPE PRODUCTION**

Le MCP Stripe est connecté au **compte officiel Lynewed** (mode test activé). Utiliser ce MCP pour créer les produits magazines.

#### ⛔ PRODUITS EXISTANTS - NE PAS MODIFIER

| Produit | ID | Usage |
|---------|-----|-------|
| **EARLY ACCESS** | `prod_TCeouF5WM5cN8Z` | Abonnement pro (CRM) |
| **PREMIUM VISIBILITY** | `prod_TCesp37xX9fPKZ` | Abonnement pro (CRM) |
| **ULTIMATE ACCESS** | `prod_TCeuXHDpPaS7hB` | Abonnement pro (CRM) |

**Ces produits sont pour le CRM - NE PAS TOUCHER.**

#### Produits à créer pour cet Epic (MAJ 2026-02-03)

> **IMPORTANT** : Pricing confirmé par Thierry le 3 février 2026 - 4 formats magazine

Utiliser le MCP Stripe pour créer **4 produits magazine** (prix TTC hors livraison) :

| Format | Taille | Spreads | Prix TTC | Prix (cents USD) |
|--------|--------|---------|----------|------------------|
| **GUEST EDITION** | 21×30 cm | 20 | $29 | 2900 |
| **ICONIC** | 21×30 cm | 40 | $59 | 5900 |
| **MEMORY** | 21×30 cm | 60 | $69 | 6900 |
| **COLLECTOR** | 25×32 cm | 60 | $89 | 8900 |

> Note: Prix arrondis en USD (source Thierry: 27€, 54€, 64.80€, 85€ - conversion ~1.08)

```
1. Produit Magazine GUEST EDITION:
   mcp__stripe__create_product:
   - name: "Lynewed Magazine - GUEST EDITION"
   - description: "Magazine photo mariage 21x30cm - 20 spreads"

   mcp__stripe__create_price:
   - product: [ID créé]
   - unit_amount: 2900
   - currency: "usd"

2. Produit Magazine ICONIC:
   mcp__stripe__create_product:
   - name: "Lynewed Magazine - ICONIC"
   - description: "Magazine photo mariage 21x30cm - 40 spreads"

   mcp__stripe__create_price:
   - product: [ID créé]
   - unit_amount: 5900
   - currency: "usd"

3. Produit Magazine MEMORY:
   mcp__stripe__create_product:
   - name: "Lynewed Magazine - MEMORY"
   - description: "Magazine photo mariage 21x30cm - 60 spreads"

   mcp__stripe__create_price:
   - product: [ID créé]
   - unit_amount: 6900
   - currency: "usd"

4. Produit Magazine COLLECTOR:
   mcp__stripe__create_product:
   - name: "Lynewed Magazine - COLLECTOR"
   - description: "Magazine photo mariage 25x32cm - 60 spreads (grand format)"

   mcp__stripe__create_price:
   - product: [ID créé]
   - unit_amount: 8900
   - currency: "usd"

5. Prix Shipping (calculé par FedEx au checkout):
   Note: Les frais de port sont calculés dynamiquement via FedEx API
   Pas de prix fixe shipping à créer dans Stripe
```

> **Note** : Les frais de livraison seront calculés par FedEx au checkout (voir API FedEx dans CLAUDE.md)

### Dependances

| Dependance | Epic | Status | Impact si non fait |
|------------|------|--------|-------------------|
| Tables guest_albums, guest_media | EPIC-10-PHOTOS-VIDEOS | ✅ COMPLETE | Photos guests disponibles |
| Stripe Integration | EPIC-11-STRIPE | ✅ COMPLETE | Paiement disponible |
| Table cgvu_acceptances | EPIC-11-STRIPE | ✅ COMPLETE | CGVU tracking disponible |
| Bucket wedding-albums | EPIC-06-PREREQUISITES | ✅ COMPLETE | Stockage photos (structure: {wedding_id}/guests/{user_id}/) |
| API FedEx | - | ✅ Configuré | Calcul frais de port dynamique |

> ✅ **PRÉREQUIS SATISFAITS** : EPIC-10 et EPIC-11 sont complets. EPIC-12 peut démarrer immédiatement.

### Décisions Techniques (MAJ 2026-02-03)

| Decision | Choix | Raison |
|----------|-------|--------|
| **Pas d'opt-in partage guest→bride** | Automatique | Bride voit tous les albums guests automatiquement (EPIC-10) |
| **4 formats magazine** | Pricing différencié | GUEST EDITION ($29), ICONIC ($59), MEMORY ($69), COLLECTOR ($89) |
| **Devise** | USD | Standard e-commerce international |
| **Frais de port** | FedEx dynamique | Calculés au checkout via FedEx API |
| **Bucket storage** | wedding-albums | Réutilisation bucket existant |

### Piliers Techniques Concernes

| Pilier | Implication pour cet Epic |
|--------|---------------------------|
| **Supabase Database** | Tables magazine_orders, magazine_order_items, photo_favorites |
| **Supabase Storage** | Lecture photos depuis wedding-albums bucket |
| **Flutter/Dart** | UI galerie, preview magazine, checkout |
| **Stripe** | Paiement magazine + frais port |
| **Admin Panel** | Gestion commandes (hors scope app - CRM Tom) |

---

## Architecture Cible

### Schema de Donnees

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SCHEMA MAGAZINES (APP-06 remplace)                        │
│                                                                              │
│  photo_favorites (NOUVELLE)                                                  │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  id UUID PRIMARY KEY                                                 │   │
│  │  user_id UUID REFERENCES profiles(id)                                │   │
│  │  media_type VARCHAR(20)  ← 'album_image' | 'guest_media'            │   │
│  │  media_id UUID  ← ID de album_images OU guest_media                 │   │
│  │  created_at TIMESTAMP                                                │   │
│  │  UNIQUE(user_id, media_type, media_id)                              │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  magazine_selections (NOUVELLE)                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  id UUID PRIMARY KEY                                                 │   │
│  │  wedding_id UUID REFERENCES weddings(id)                             │   │
│  │  user_id UUID REFERENCES profiles(id)  ← bride                      │   │
│  │  media_type VARCHAR(20)                                              │   │
│  │  media_id UUID                                                       │   │
│  │  position INTEGER  ← ordre dans le magazine                         │   │
│  │  created_at TIMESTAMP                                                │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  magazine_orders (NOUVELLE)                                                  │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  id UUID PRIMARY KEY                                                 │   │
│  │  wedding_id UUID REFERENCES weddings(id)                             │   │
│  │  bride_user_id UUID REFERENCES profiles(id)                          │   │
│  │                                                                      │   │
│  │  -- Stripe                                                           │   │
│  │  stripe_payment_intent_id VARCHAR(255)                               │   │
│  │  stripe_checkout_session_id VARCHAR(255)                             │   │
│  │                                                                      │   │
│  │  -- Montants (centimes)                                              │   │
│  │  magazine_price_cents INTEGER NOT NULL                               │   │
│  │  shipping_cost_cents INTEGER NOT NULL                                │   │
│  │  total_paid_cents INTEGER NOT NULL                                   │   │
│  │  currency VARCHAR(3) DEFAULT 'USD'                                   │   │
│  │                                                                      │   │
│  │  -- Shipping                                                         │   │
│  │  shipping_name VARCHAR(255)                                          │   │
│  │  shipping_address_line1 VARCHAR(255)                                 │   │
│  │  shipping_address_line2 VARCHAR(255)                                 │   │
│  │  shipping_city VARCHAR(255)                                          │   │
│  │  shipping_zip VARCHAR(50)                                            │   │
│  │  shipping_country VARCHAR(100)                                       │   │
│  │  shipping_phone VARCHAR(50)                                          │   │
│  │                                                                      │   │
│  │  -- Magazine details                                                 │   │
│  │  magazine_format VARCHAR(30) NOT NULL ← 'guest_edition'|'iconic'|'memory'|'collector' │
│  │  magazine_title VARCHAR(255)  ← "Jessica & Kyle"                    │   │
│  │  magazine_date DATE                                                  │   │
│  │  photo_count INTEGER                                                 │   │
│  │  cover_photo_id UUID                                                 │   │
│  │                                                                      │   │
│  │  -- Status                                                           │   │
│  │  status VARCHAR(30) DEFAULT 'pending'                                │   │
│  │  -- 'pending', 'paid', 'in_production', 'shipped', 'delivered'      │   │
│  │                                                                      │   │
│  │  -- Tracking                                                         │   │
│  │  tracking_number VARCHAR(255)                                        │   │
│  │  tracking_url TEXT                                                   │   │
│  │                                                                      │   │
│  │  -- Timestamps                                                       │   │
│  │  created_at TIMESTAMP DEFAULT NOW()                                  │   │
│  │  paid_at TIMESTAMP                                                   │   │
│  │  shipped_at TIMESTAMP                                                │   │
│  │  delivered_at TIMESTAMP                                              │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  magazine_order_items (NOUVELLE)                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  id UUID PRIMARY KEY                                                 │   │
│  │  order_id UUID REFERENCES magazine_orders(id) ON DELETE CASCADE      │   │
│  │  media_type VARCHAR(20)                                              │   │
│  │  media_id UUID                                                       │   │
│  │  position INTEGER  ← ordre dans le magazine                         │   │
│  │  storage_url TEXT  ← snapshot URL au moment de la commande          │   │
│  │  caption TEXT  ← caption incluse ou non                             │   │
│  │  created_at TIMESTAMP                                                │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  Modification guest_media (EPIC-10) - Ajout status                           │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  + status VARCHAR(20) DEFAULT 'active'                               │   │
│  │  -- 'active' | 'hidden_by_bride' | 'deleted_by_bride'               │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  cgvu_acceptances (PREREQUIS - créer dans EPIC-11)                          │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  id UUID PRIMARY KEY                                                 │   │
│  │  user_id UUID REFERENCES profiles(id) NOT NULL                       │   │
│  │  cgvu_type VARCHAR(50) NOT NULL  ← 'magazine_purchase'              │   │
│  │  cgvu_version VARCHAR(10) NOT NULL  ← '1.0'                         │   │
│  │  ip_address VARCHAR(50)                                              │   │
│  │  user_agent TEXT                                                     │   │
│  │  device_info JSONB                                                   │   │
│  │  accepted_at TIMESTAMP DEFAULT NOW()                                 │   │
│  │  RLS: user_id = auth.uid() (SELECT + INSERT)                        │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Prix Magazine (Config Admin - MAJ 2026-02-03)

```sql
-- Configuration prix magazine (4 formats - confirmé Thierry 03/02/2026)
INSERT INTO app_config (key, value) VALUES
('magazine_pricing', '{
  "currency": "USD",
  "formats": [
    {
      "id": "guest_edition",
      "name": "GUEST EDITION",
      "size": "21x30cm",
      "spreads": 20,
      "price_cents": 2900,
      "max_photos": 20
    },
    {
      "id": "iconic",
      "name": "ICONIC",
      "size": "21x30cm",
      "spreads": 40,
      "price_cents": 5900,
      "max_photos": 40
    },
    {
      "id": "memory",
      "name": "MEMORY",
      "size": "21x30cm",
      "spreads": 60,
      "price_cents": 6900,
      "max_photos": 60
    },
    {
      "id": "collector",
      "name": "COLLECTOR",
      "size": "25x32cm",
      "spreads": 60,
      "price_cents": 8900,
      "max_photos": 60
    }
  ],
  "shipping_provider": "fedex_dynamic"
}')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
```

**Note** : Les frais de port sont calculés dynamiquement via FedEx API au checkout.

### Pages Layouts (Preview)

Le magazine aura des layouts pre-definis :
1. **Couverture** : Photo plein page + titre + date + "LYNEWED" branding
2. **Page double** : 2-3 photos en layout editorial
3. **Page single** : 1 photo grande + citation/legende
4. **Page mosaic** : 4-6 photos en grille ("Guest Moments")

V1 : Layouts automatiques, pas d'edition manuelle (simplification).

---

## Stories

| # | Story | Domaine | Dep. | Criteres cles | Source | Complexite |
|---|-------|---------|------|---------------|--------|------------|
| S01 | Creer table photo_favorites | DB | - | Favorite photos bride et guests, RLS | Thierry | S |
| S02 | Creer table magazine_selections | DB | S01 | Selection pour magazine avec position | Thierry | S |
| S03 | Creer tables magazine_orders + items | DB | S02 | Commandes magazine, snapshot photos | Thierry | M |
| S04 | Ajouter status a guest_media (hide/delete) | DB | EPIC-10 | Status active/hidden/deleted | Thierry | S |
| S05 | UI Galerie avec selection multiple | Flutter | S01 | Grid, checkboxes, actions batch | Screenshot | M |
| S06 | UI Actions favorite/hide/delete | Flutter | S04, S05 | Toggle favorite, soft delete | Screenshot | S |
| S07 | UI Share gallery avec guests | Flutter | S05 | Lien partage, toggle visibility | Thierry | M |
| S08 | UI Selection pour magazine | Flutter | S02, S05 | Selection photos, reordering | Screenshot | M |
| S09 | UI Preview Magazine mockup | Flutter | S08 | Couverture, pages, layouts auto | Screenshot | L |
| S10 | Checkout magazine avec Stripe | Flutter | S03, EPIC-11 | Paiement, adresse, CGVU | Thierry | M |
| S11 | Edge Function create-magazine-order | Backend | S03 | Webhook Stripe, creation commande | Thierry | M |
| S12 | CGVU magazine (scroll + checkbox) | Flutter | - | Texte legal, log acceptance | PRD | S |

---

## Detail des Stories

### S01 : Creer table photo_favorites

**Contexte** : Permettre a la bride de marquer ses photos preferees (des albums bride ET des guests partages).

**Criteres cles** :
- Table `photo_favorites` creee avec colonnes specifiees
- Support pour album_images ET guest_media via media_type
- RLS: Bride gere uniquement ses propres favoris
- Index pour requetes rapides
- Contrainte unique pour eviter doublons

**Complexite** : S (Small)

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Photo favorites table for bride

  Scenario: Creating photo_favorites table
    Given the database schema
    When the migration create_photo_favorites is applied
    Then table photo_favorites should exist
    And it should have columns: id, user_id, media_type, media_id, created_at

  Scenario: Favoriting an album image
    Given a bride with user_id 'bride-123'
    When the bride favorites album_image 'img-456'
    Then a row should be inserted with media_type = 'album_image'
    And media_id = 'img-456'

  Scenario: Favoriting a guest media
    Given a bride viewing shared guest photos
    When the bride favorites guest_media 'guest-media-789'
    Then a row should be inserted with media_type = 'guest_media'

  Scenario: Preventing duplicate favorites
    Given bride already favorited media 'img-456'
    When the bride tries to favorite 'img-456' again
    Then the insert should fail with unique constraint violation

  Scenario: RLS prevents cross-user access
    Given bride-A has favorites
    When bride-B queries photo_favorites
    Then bride-B should see only their own favorites
```

**Migration SQL** :

```sql
-- Migration: 20260129100001_create_photo_favorites
-- Description: Create photo_favorites table for bride favorites

CREATE TABLE IF NOT EXISTS photo_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  media_type VARCHAR(20) NOT NULL,
  media_id UUID NOT NULL,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,

  -- Prevent duplicate favorites
  CONSTRAINT uq_photo_favorites UNIQUE (user_id, media_type, media_id),
  -- Valid media types
  CONSTRAINT chk_photo_favorites_type CHECK (media_type IN ('album_image', 'guest_media'))
);

-- Index for user queries
CREATE INDEX IF NOT EXISTS idx_photo_favorites_user
  ON photo_favorites(user_id, created_at DESC);

-- Enable RLS
ALTER TABLE photo_favorites ENABLE ROW LEVEL SECURITY;

-- Policy: User manages own favorites
CREATE POLICY "User manages own favorites"
ON photo_favorites FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

COMMENT ON TABLE photo_favorites IS 'Favorited photos by brides (from album_images or shared guest_media)';
```

---

### S02 : Creer table magazine_selections

**Contexte** : Stocker la selection de photos pour le magazine avec ordre defini.

**Criteres cles** :
- Table `magazine_selections` creee
- Position pour ordonnancement des photos
- RLS: Bride gere uniquement ses selections
- Peut inclure album_images ET guest_media partages

**Complexite** : S (Small)

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Magazine selections table

  Scenario: Adding photo to magazine selection
    Given a bride creating a magazine
    When adding photo 'img-123' at position 1
    Then magazine_selections should contain the photo
    And position should be 1

  Scenario: Reordering photos
    Given photos at positions 1, 2, 3
    When moving photo from position 3 to position 1
    Then positions should update correctly

  Scenario: RLS prevents access to other bride's selections
    Given bride-A has selections
    When bride-B queries magazine_selections
    Then bride-B should see 0 rows
```

**Migration SQL** :

```sql
-- Migration: 20260129100002_create_magazine_selections
-- Description: Create magazine_selections table for magazine photo ordering

CREATE TABLE IF NOT EXISTS magazine_selections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID REFERENCES weddings(id) NOT NULL,
  user_id UUID REFERENCES profiles(id) NOT NULL,
  media_type VARCHAR(20) NOT NULL,
  media_id UUID NOT NULL,
  position INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,

  -- One entry per photo per wedding
  CONSTRAINT uq_magazine_selection UNIQUE (wedding_id, media_type, media_id),
  -- Valid media types
  CONSTRAINT chk_magazine_selection_type CHECK (media_type IN ('album_image', 'guest_media'))
);

-- Index for wedding queries with ordering
CREATE INDEX IF NOT EXISTS idx_magazine_selections_wedding
  ON magazine_selections(wedding_id, position);

-- Enable RLS
ALTER TABLE magazine_selections ENABLE ROW LEVEL SECURITY;

-- Policy: Bride manages own selections
CREATE POLICY "Bride manages own selections"
ON magazine_selections FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

COMMENT ON TABLE magazine_selections IS 'Photos selected for magazine with position ordering';
```

---

### S03 : Creer tables magazine_orders + items

**Contexte** : Tables pour stocker les commandes de magazines avec snapshot des photos au moment de la commande.

**Criteres cles** :
- Table `magazine_orders` avec toutes les infos commande et shipping
- Table `magazine_order_items` avec snapshot des photos (URLs au moment commande)
- Status tracking: pending → paid → in_production → shipped → delivered
- RLS: Bride voit ses propres commandes, Admin voit tout (service_role)

**Complexite** : M (Medium)

**Criteres d'acceptance (Gherkin)** :

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
    And timestamp should be recorded

  Scenario: RLS for bride
    Given bride-A has orders
    When bride-A queries magazine_orders
    Then only bride-A's orders should be visible
```

**Migration SQL** :

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

COMMENT ON TABLE magazine_orders IS 'Wedding magazine orders (manual fulfillment by Thierry V1)';
COMMENT ON TABLE magazine_order_items IS 'Snapshot of photos included in magazine order';
COMMENT ON COLUMN magazine_order_items.storage_url IS 'Snapshot URL at order time - preserved even if original deleted';
```

---

### S04 : Ajouter status a guest_media (hide/delete)

**Contexte** : Permettre a la bride de masquer ou supprimer (soft) des photos guests de sa vue.

**Criteres cles** :
- Colonne `status` ajoutee a guest_media
- Valeurs: 'active', 'hidden_by_bride', 'deleted_by_bride'
- Default 'active' pour retrocompatibilite
- Soft delete (pas de suppression physique)
- RLS mise a jour pour filtrer par status

**Complexite** : S (Small)

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Guest media status for bride control

  Scenario: Default status is active
    Given a guest uploads a photo
    When the photo is created
    Then status should be 'active'

  Scenario: Bride hides photo
    Given a shared guest photo
    When bride hides the photo
    Then status should become 'hidden_by_bride'
    And photo should not appear in bride's main gallery view

  Scenario: Bride deletes photo (soft)
    Given a shared guest photo
    When bride deletes the photo
    Then status should become 'deleted_by_bride'
    And photo should be invisible to bride
    And photo should still exist in storage (audit trail)

  Scenario: Guest still sees their own photos
    Given bride has hidden a photo
    When guest views their album
    Then the photo should still be visible to the guest
```

**Note (MAJ 2026-02-03)** : Pas de `shared_with_bride` - tout est automatiquement visible (decision EPIC-10).

**Migration SQL** :

```sql
-- Migration: 20260203_add_status_to_guest_media
-- Description: Add status column for bride hide/delete control
-- Note: No shared_with_bride - all guest albums are automatically visible (EPIC-10)

ALTER TABLE guest_media
  ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'active' NOT NULL;

ALTER TABLE guest_media
  ADD CONSTRAINT chk_guest_media_status
  CHECK (status IN ('active', 'hidden_by_bride', 'deleted_by_bride'));

-- Update RLS policy for bride to filter by status
DROP POLICY IF EXISTS "Bride views all media" ON guest_media;

CREATE POLICY "Bride views active guest media"
ON guest_media FOR SELECT
TO authenticated
USING (
  status = 'active'
  AND EXISTS (
    SELECT 1 FROM guest_albums ga
    JOIN weddings w ON w.id = ga.wedding_id
    WHERE ga.id = guest_media.album_id
    AND w.bride_profile_id = auth.uid()
  )
);

-- Policy for bride to view hidden/deleted (for management)
CREATE POLICY "Bride views hidden guest media"
ON guest_media FOR SELECT
TO authenticated
USING (
  status IN ('hidden_by_bride', 'deleted_by_bride')
  AND EXISTS (
    SELECT 1 FROM guest_albums ga
    JOIN weddings w ON w.id = ga.wedding_id
    WHERE ga.id = guest_media.album_id
    AND w.bride_profile_id = auth.uid()
  )
);

-- New policy: Bride can update status (hide/delete)
CREATE POLICY "Bride can update guest media status"
ON guest_media FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM guest_albums ga
    JOIN weddings w ON w.id = ga.wedding_id
    WHERE ga.id = guest_media.album_id
    AND w.bride_profile_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM guest_albums ga
    JOIN weddings w ON w.id = ga.wedding_id
    WHERE ga.id = guest_media.album_id
    AND w.bride_profile_id = auth.uid()
  )
);

COMMENT ON COLUMN guest_media.status IS 'Visibility status: active, hidden_by_bride, deleted_by_bride';
```

---

### S05 : UI Galerie avec selection multiple

**Contexte** : Interface de galerie avec selection multiple pour actions batch (comme Vinted/Photos iOS).

**Criteres cles** :
- Grid de photos/videos
- Mode selection avec checkboxes
- Compteur "X PHOTOS SELECTED"
- Bouton "Select all"
- Actions batch: Download, Share, Create Magazine
- Filtres: All, Favorites, Hidden

**Complexite** : M (Medium)

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Gallery with multi-select

  Scenario: Entering selection mode
    Given bride viewing gallery
    When bride long-presses on a photo
    Then selection mode should activate
    And checkboxes should appear on all photos
    And action bar should appear at top

  Scenario: Selecting multiple photos
    Given selection mode is active
    When bride taps on photos
    Then checkmark should appear on selected photos
    And counter should update "X PHOTOS SELECTED"

  Scenario: Select all
    Given selection mode active with some photos selected
    When bride taps "Select all"
    Then all photos should be selected
    And counter should show total count

  Scenario: Deselecting
    Given photo is selected
    When bride taps selected photo
    Then checkmark should disappear
    And counter should decrement

  Scenario: Exiting selection mode
    Given selection mode is active
    When bride taps X button
    Then selection should clear
    And normal gallery view should return
```

**UI Reference** : Screenshot "4 Selected - Select all" avec grille et checkmarks orange

---

### S06 : UI Actions favorite/hide/delete

**Contexte** : Actions sur photos selectionnees ou individuelles.

**Criteres cles** :
- Bouton favorite (coeur)
- Bouton hide (oeil)
- Bouton delete (poubelle)
- Confirmation pour delete
- Toast de confirmation

**Complexite** : S (Small)

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Photo actions (favorite, hide, delete)

  Scenario: Favoriting a photo
    Given a photo in gallery
    When bride taps heart icon
    Then photo should be marked as favorite
    And heart should fill in
    And photo should appear in Favorites filter

  Scenario: Hiding a photo
    Given a shared guest photo
    When bride taps hide icon
    Then photo should disappear from main view
    And photo should appear in Hidden filter
    And status should be 'hidden_by_bride'

  Scenario: Deleting a photo (with confirmation)
    Given a photo selected
    When bride taps delete icon
    Then confirmation dialog should appear
    And "This photo will be removed from your gallery"

    When bride confirms
    Then photo should be soft deleted
    And status should be 'deleted_by_bride'

  Scenario: Batch actions
    Given 5 photos selected
    When bride taps favorite
    Then all 5 should be favorited
    And toast "5 photos added to favorites"
```

---

### S07 : UI Share gallery avec guests

**Contexte** : Permettre a la bride de partager une selection de photos avec les guests du mariage.

**Criteres cles** :
- Bouton "Share as gallery" sur selection
- Generation lien partage
- Les guests du mariage peuvent voir les photos partagees
- Toggle pour activer/desactiver le partage
- Log dans gallery_access_logs

**Complexite** : M (Medium)

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Share gallery with wedding guests

  Scenario: Sharing selection with guests
    Given bride has selected photos
    When bride taps "Share as gallery"
    Then photos should be marked as shared
    And guests should see shared photos in their app

  Scenario: Guest viewing shared gallery
    Given bride has shared photos
    When guest opens gallery section
    Then guest should see the shared photos
    And guest can download but not delete

  Scenario: Bride toggles off sharing
    Given photos are shared
    When bride disables sharing
    Then guests should no longer see those photos
    And gallery_access_logs should record 'share_disabled'
```

---

### S08 : UI Selection pour magazine

**Contexte** : Interface pour selectionner et ordonner les photos du magazine.

**Criteres cles** :
- Selection depuis la galerie
- Indicateur "X photos selected for magazine"
- Drag & drop pour reordonner
- Maximum 50 photos
- Bouton "Create Magazine" → Preview

**Complexite** : M (Medium)

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Magazine photo selection

  Scenario: Adding photos to magazine
    Given bride in gallery
    When bride selects photos and taps "Add to magazine"
    Then photos should be added to magazine_selections
    And positions should be assigned

  Scenario: Maximum photos limit
    Given 50 photos in selection
    When bride tries to add more
    Then error should appear "Maximum 50 photos per magazine"

  Scenario: Reordering photos
    Given photos in magazine selection
    When bride drags photo to new position
    Then positions should update in database

  Scenario: Navigating to preview
    Given photos selected for magazine
    When bride taps "Create Magazine"
    Then preview screen should open
```

---

### S09 : UI Preview Magazine mockup

**Contexte** : Affichage preview du magazine avec layouts automatiques.

**Criteres cles** :
- Couverture avec photo, titre (nom maries), date, branding LYNEWED
- Pages interieures avec layouts varies
- Navigation flip-book ou scroll
- Bouton "Order Magazine"

**Complexite** : L (Large) - UI complexe avec layouts

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Magazine preview mockup

  Scenario: Displaying cover
    Given bride on preview screen
    When preview loads
    Then cover should show:
      - "DIGITAL EDITION" label
      - "LYNEWED" branding
      - Wedding title (e.g., "Jessica & Kyle")
      - Wedding date
      - Cover photo (first selected or chosen)

  Scenario: Interior pages layout
    Given 20 photos selected
    When preview generates
    Then pages should have varied layouts:
      - Some with 1 large photo
      - Some with 2-3 photos grid
      - Some with 4-6 mosaic ("Guest Moments")

  Scenario: Navigation between pages
    Given magazine preview open
    When bride swipes left
    Then next page should appear
    And page number should update

  Scenario: Proceeding to checkout
    Given preview showing
    When bride taps "Order Magazine"
    Then checkout screen should open
    And selected photos should be confirmed
```

**UI Reference** : Screenshots mockup magazine avec couverture et pages interieures

---

### S10 : Checkout magazine avec Stripe

**Contexte** : Formulaire de commande avec paiement Stripe integre.

**Criteres cles** :
- Affichage prix magazine + frais port
- Formulaire adresse livraison
- Checkbox CGVU obligatoire
- Integration Stripe Checkout
- Webhook pour confirmer paiement

**Complexite** : M (Medium) - Integration Stripe existante

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Magazine checkout with Stripe

  Scenario: Displaying order summary
    Given bride on checkout screen
    When screen loads
    Then should display:
      - Magazine price ($49.00)
      - Shipping cost ($15.00 or $35.00 international)
      - Total
      - Photo count

  Scenario: Entering shipping address
    Given checkout screen
    When bride enters address
    Then all required fields must be filled:
      - Name
      - Address line 1
      - City
      - ZIP
      - Country

  Scenario: CGVU acceptance required
    Given address filled
    When bride tries to pay without checking CGVU
    Then payment button should be disabled
    And error "Please accept terms" should show

  Scenario: Stripe payment flow
    Given CGVU accepted
    When bride taps "Pay with Stripe"
    Then Stripe Checkout should open
    And upon success, order should be created
    And confirmation screen should show

  Scenario: Payment failure handling
    Given Stripe payment fails
    When error occurs
    Then error message should display
    And bride should be able to retry
```

---

### S11 : Edge Function create-magazine-order

**Contexte** : Webhook Stripe pour creer la commande apres paiement reussi.

**Criteres cles** :
- Recevoir webhook checkout.session.completed
- Creer magazine_orders avec status 'paid'
- Creer magazine_order_items avec snapshot URLs
- Envoyer notification push a la bride
- Logger dans stripe_events

**Complexite** : M (Medium)

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Magazine order creation webhook

  Scenario: Successful payment creates order
    Given checkout.session.completed webhook
    When webhook is processed
    Then magazine_orders should have new row with status = 'paid'
    And magazine_order_items should contain photo snapshots
    And stripe_events should log the event

  Scenario: Photo snapshots preserve URLs
    Given photos in magazine_selections
    When order is created
    Then each magazine_order_item should have storage_url
    And URL should be absolute path to file

  Scenario: Notification sent to bride
    Given order created successfully
    When webhook completes
    Then push notification should be sent
    And message "Your magazine order is confirmed!"

  Scenario: Duplicate webhook handling
    Given webhook already processed
    When same webhook arrives again
    Then it should be idempotent
    And no duplicate order created
```

**Edge Function** :

```typescript
// supabase/functions/create-magazine-order/index.ts
import Stripe from 'stripe';

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!);

Deno.serve(async (req) => {
  // Verify Stripe signature
  const signature = req.headers.get('stripe-signature')!;
  const body = await req.text();

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      Deno.env.get('STRIPE_MAGAZINE_WEBHOOK_SECRET')!
    );
  } catch (err) {
    return new Response('Invalid signature', { status: 400 });
  }

  if (event.type !== 'checkout.session.completed') {
    return new Response('Ignored', { status: 200 });
  }

  const session = event.data.object as Stripe.Checkout.Session;
  const metadata = session.metadata!;

  // Create order
  const { data: order, error: orderError } = await supabase
    .from('magazine_orders')
    .insert({
      wedding_id: metadata.wedding_id,
      bride_user_id: metadata.bride_user_id,
      stripe_checkout_session_id: session.id,
      stripe_payment_intent_id: session.payment_intent,
      magazine_price_cents: parseInt(metadata.magazine_price_cents),
      shipping_cost_cents: parseInt(metadata.shipping_cost_cents),
      total_paid_cents: session.amount_total,
      currency: session.currency?.toUpperCase(),
      shipping_name: session.shipping_details?.name,
      shipping_address_line1: session.shipping_details?.address?.line1,
      shipping_address_line2: session.shipping_details?.address?.line2,
      shipping_city: session.shipping_details?.address?.city,
      shipping_zip: session.shipping_details?.address?.postal_code,
      shipping_country: session.shipping_details?.address?.country,
      magazine_title: metadata.magazine_title,
      magazine_date: metadata.magazine_date,
      photo_count: parseInt(metadata.photo_count),
      status: 'paid',
      paid_at: new Date().toISOString(),
    })
    .select()
    .single();

  // Create order items from selections
  const { data: selections } = await supabase
    .from('magazine_selections')
    .select('*')
    .eq('wedding_id', metadata.wedding_id)
    .eq('user_id', metadata.bride_user_id)
    .order('position');

  for (const sel of selections || []) {
    // Get storage URL based on media type
    let storageUrl = '';
    if (sel.media_type === 'album_image') {
      const { data: img } = await supabase
        .from('album_images')
        .select('image_url')
        .eq('id', sel.media_id)
        .single();
      storageUrl = img?.image_url || '';
    } else {
      const { data: media } = await supabase
        .from('guest_media')
        .select('storage_path')
        .eq('id', sel.media_id)
        .single();
      storageUrl = media?.storage_path || '';
    }

    await supabase.from('magazine_order_items').insert({
      order_id: order.id,
      media_type: sel.media_type,
      media_id: sel.media_id,
      position: sel.position,
      storage_url: storageUrl,
    });
  }

  // Clear selections after order
  await supabase
    .from('magazine_selections')
    .delete()
    .eq('wedding_id', metadata.wedding_id)
    .eq('user_id', metadata.bride_user_id);

  // Send push notification
  await supabase.from('notifications_outbox').insert({
    event_type: 'magazine_order_confirmed',
    payload: {
      user_id: metadata.bride_user_id,
      order_id: order.id,
      title: 'Magazine Order Confirmed!',
      body: 'Your wedding magazine is being prepared.',
    },
  });

  return new Response('OK', { status: 200 });
});
```

---

### S12 : CGVU magazine (scroll + checkbox)

**Contexte** : Les CGVU specifiques aux commandes de magazines doivent etre acceptees avant paiement.

**Criteres cles** :
- Texte CGVU avec scroll obligatoire
- Checkbox activable uniquement apres scroll complet
- Log dans cgvu_acceptances
- Version trackee pour audit

**Complexite** : S (Small)

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Magazine CGVU acceptance

  Scenario: CGVU modal display
    Given bride on checkout
    When bride taps CGVU link
    Then modal should open with full CGVU text
    And checkbox should be disabled initially

  Scenario: Scroll requirement
    Given CGVU modal open
    When bride scrolls to bottom
    Then checkbox should become enabled

  Scenario: Accepting CGVU
    Given checkbox enabled
    When bride checks the box
    Then acceptance should be logged in cgvu_acceptances
    And payment button should be enabled

  Scenario: CGVU text content
    Given CGVU modal
    Then text should include:
      - Platform role (Lynewed = intermediary)
      - Manual fulfillment disclaimer
      - Shipping responsibility
      - No refund policy on custom products
```

**CGVU Text (Magazine)** :

```
LYNEWED MAGAZINE — TERMS OF PURCHASE

Please read these terms carefully before ordering your magazine.

1. PRODUCT DESCRIPTION
The Lynewed Wedding Magazine is a custom-printed photo book featuring photos you have selected from your wedding gallery. Each magazine is uniquely created based on your selections.

2. PRODUCTION & DELIVERY
- Magazines are produced manually by our partner printing service
- Production typically takes 5-10 business days
- Shipping time varies by location (7-21 days)
- You will receive tracking information once shipped

3. CUSTOM PRODUCT POLICY
As each magazine is custom-made with your personal photos:
- Orders cannot be cancelled once production begins
- Refunds are not available for delivered products
- Exchanges are only possible for production defects

4. PHOTO QUALITY
- Final print quality depends on original photo resolution
- We recommend high-resolution photos for best results
- Lynewed is not responsible for print quality issues caused by low-resolution source images

5. INTELLECTUAL PROPERTY
- You confirm you have rights to all photos included
- By ordering, you grant Lynewed permission to print your photos
- Photos are not shared or used for any other purpose

6. SHIPPING
- Shipping costs are calculated at checkout
- Risk of loss transfers upon delivery to carrier
- Lynewed is not responsible for shipping delays or damage by carriers

7. LIMITATION OF LIABILITY
Lynewed's liability is limited to the order value. We are not liable for indirect damages or delays beyond our control.

By scrolling to the bottom and checking the box below, you confirm you have read and accept these terms.

[ ] I have read and accept the Lynewed Magazine Terms of Purchase
```

---

## RLS Policies Summary

| Table | Policy | Access |
|-------|--------|--------|
| `photo_favorites` | "User manages own favorites" | User CRUD own |
| `magazine_selections` | "Bride manages own selections" | Bride CRUD own |
| `magazine_orders` | "Bride views own orders" | Bride SELECT own |
| `magazine_orders` | "Bride creates own orders" | Bride INSERT own |
| `magazine_order_items` | "Bride views own order items" | Bride SELECT via order |
| `guest_media` | Updated with status filter | Bride sees active only |

**Admin Access** : L'admin panel utilise service_role pour voir toutes les commandes.

---

## Risques et Mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Photos supprimees apres commande | MOYEN - Magazine incomplet | Snapshot URLs dans order_items |
| Paiement Stripe echoue | FAIBLE - UX retry | Gestion erreur + retry flow |
| Preview magazine lent (beaucoup photos) | MOYEN - UX degradee | Pagination, lazy loading |
| Admin panel pas pret (Tom) | BLOQUANT pour fulfillment | Alternative: Email notification |
| Photos basse resolution | FAIBLE - Qualite impression | Avertissement dans CGVU |

---

## Ordre d'Execution Recommande

```
S01 (photo_favorites) ─┬── S05 (UI galerie) ── S06 (actions)
                         │
S02 (magazine_selections) ├── S08 (UI selection magazine) ── S09 (preview)
                         │
S03 (magazine_orders) ──┴── S10 (checkout) ── S11 (webhook)

S04 (status guest_media) ── Depend EPIC-10

S07 (share gallery) ── Depend S05

S12 (CGVU) ── Depend S10
```

**Ordre sequentiel recommande:**
1. S01 - Table photo_favorites
2. S02 - Table magazine_selections
3. S03 - Tables magazine_orders + items
4. S04 - Status guest_media (si EPIC-10 fait)
5. S05 - UI Galerie multi-select
6. S06 - UI Actions favorite/hide/delete
7. S07 - UI Share gallery
8. S08 - UI Selection magazine
9. S09 - UI Preview magazine (plus complexe)
10. S10 - Checkout Stripe
11. S11 - Edge Function webhook
12. S12 - CGVU magazine

---

## References

| Source | Contenu utilise |
|--------|-----------------|
| Conversation WhatsApp 28/01 | Decision abandon reels, pivot magazine |
| Screenshots Thierry | UI galerie selection, preview magazine |
| Mail Thierry | Parcours utilisateur, fulfillment manuel |
| EPIC-10-PHOTOS-VIDEOS | Tables guest_albums, guest_media |
| EPIC-11-STRIPE | Integration Stripe, webhooks |

---

## Prochaine Etape

1. Valider cet Epic avec l'utilisateur
2. Creer les stories detaillees dans le dossier stories/
3. Mettre a jour le PRD (remplacer APP-06 Reels par Magazines)
4. Mettre a jour CROSS-EPIC.md
5. Executer les migrations sur branche dev Supabase
6. Implementer les stories Flutter
