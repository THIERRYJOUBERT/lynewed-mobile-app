# Story S02: Create marketplace_photos table

## Description
En tant que developpeur backend, je veux creer la table marketplace_photos dans Supabase, afin de stocker les photos associees aux annonces avec ordering.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the marketplace_listings table exists When the migration create_marketplace_photos is applied Then table marketplace_photos should exist with columns listing_id, storage_path, thumbnail_path, position, created_at
- [ ] Given a listing with 5 photos When the listing is deleted Then all associated photos should be deleted (CASCADE)
- [ ] Given an active listing with photos And a bride user queries the photos Then photos should be returned for accessible listings And denied for inaccessible listings (draft of another seller)
- [ ] Given a listing with photos at positions 0, 1, 2 When querying photos ORDER BY position Then photos should be returned in correct order
- [ ] Given a listing_id UUID When inserting a photo record Then the FK constraint to marketplace_listings(id) should be enforced

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260128100002_create_marketplace_photos.sql` - Migration principale
- `supabase/migrations/20260128100002_create_marketplace_photos_rollback.sql` - Rollback migration

### A Modifier
- Aucun

## Notes Techniques

### Schema SQL
```sql
CREATE TABLE marketplace_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID REFERENCES marketplace_listings(id) ON DELETE CASCADE NOT NULL,
  storage_path TEXT NOT NULL,
  thumbnail_path TEXT,
  position INTEGER DEFAULT 0 NOT NULL,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL
);

-- Index for efficient queries
CREATE INDEX idx_marketplace_photos_listing ON marketplace_photos(listing_id, position);
```

### RLS Policies (2 policies)
1. Photos visible with listing - Si listing est active ou si user est seller
2. Seller manages own photos - CRUD pour seller sur ses propres listings

### Validation cote application
- Minimum 5 photos requis
- Maximum 10 photos autorise
- Position 0 = photo de couverture

## Definition of Done
- [ ] Migration appliquee avec succes
- [ ] CASCADE delete fonctionne
- [ ] RLS policies testees
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances
- S01 (marketplace_listings table)

## Stories Dependantes
- S07 (storage bucket - utilise storage_path)
- S14 (create listing form)
- S16 (detail page - photo carousel)
