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
- `supabase/migrations/20260128100001_create_marketplace_listings.sql` - Migration principale
- `supabase/migrations/20260128100001_create_marketplace_listings_rollback.sql` - Rollback migration

### A Modifier
- Aucun

## Notes Techniques

### Colonnes requises
```sql
-- Core
id UUID PRIMARY KEY
seller_id UUID REFERENCES profiles(id)

-- Product info
title VARCHAR(255) NOT NULL
description TEXT
category VARCHAR(20) CHECK (category IN ('dress', 'shoes'))
price_cents INTEGER NOT NULL CHECK (price_cents > 0)
display_currency VARCHAR(3) DEFAULT 'USD'

-- Attributes
designer_brand VARCHAR(255)
size VARCHAR(50)
condition VARCHAR(20) CHECK (condition IN ('new', 'excellent', 'good', 'fair'))
sleeve_length VARCHAR(20) -- Required for dresses

-- Location
city VARCHAR(255)
country VARCHAR(100) NOT NULL
country_code VARCHAR(2)
latitude DECIMAL(10, 8)
longitude DECIMAL(11, 8)

-- Status
status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'reserved', 'sold', 'deleted'))

-- Timestamps
created_at, updated_at, sold_at
```

### Index a creer
- `idx_marketplace_listings_status` - Filter by status
- `idx_marketplace_listings_seller` - Seller's listings
- `idx_marketplace_listings_category` - Category + status
- `idx_marketplace_listings_location` - Geospatial queries
- `idx_marketplace_listings_price` - Price range queries

### RLS Policies (5 policies)
1. Active listings visible to brides
2. Seller views own listings
3. Seller creates listings
4. Seller updates own listings
5. Seller deletes own listings

### Trigger
- `trg_marketplace_listings_updated_at` - Auto-update updated_at

## Definition of Done
- [ ] Migration appliquee avec succes sur Supabase
- [ ] Tous les index crees
- [ ] 5 RLS policies actives
- [ ] Trigger updated_at fonctionne
- [ ] Tests unitaires pour contraintes
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances
- EPIC-11 (stripe_accounts table pour verification vendeur lors de publication)
- profiles table doit exister

## Stories Dependantes
- S02 (marketplace_photos)
- S03 (marketplace_offers)
- S04 (marketplace_transactions)
- S05 (marketplace_messages)
- S07 (storage bucket)
- S14 (create listing form)
- S15 (feed)
- S16 (detail page)
- S24 (map markers)
- S25 (seller dashboard)
