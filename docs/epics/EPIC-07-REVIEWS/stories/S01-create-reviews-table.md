# Story S01: Create reviews table with constraints

## Description
En tant que developpeur backend, je veux creer la table `reviews` avec toutes les contraintes necessaires, afin de stocker les avis clients de maniere fiable et performante.

## Criteres d'Acceptance (Gherkin)
- [ ] Given the database schema When the migration create_reviews_table is applied Then table reviews should exist with columns: id (UUID PK), pro_id (UUID FK), bride_id (UUID FK), rating (INTEGER), comment (TEXT), created_at (TIMESTAMP), updated_at (TIMESTAMP)
- [ ] Given the reviews table exists When inserting a review with rating 0 Then the insert should fail with constraint violation (chk_rating_range)
- [ ] Given the reviews table exists When inserting a review with rating 6 Then the insert should fail with constraint violation (chk_rating_range)
- [ ] Given the reviews table exists When inserting a review with rating 3 Then the insert should succeed
- [ ] Given a review exists from bride-A to pro-B When bride-A tries to insert another review for pro-B Then the insert should fail with unique constraint violation (uq_one_review_per_bride_per_pro)
- [ ] Given a review exists from bride-A to pro-B When bride-A inserts a review for pro-C Then the insert should succeed
- [ ] Given the reviews table exists Then index idx_reviews_pro_id should exist on column pro_id
- [ ] Given the reviews table exists Then index idx_reviews_bride_id should exist on column bride_id
- [ ] Given a review is updated Then the updated_at column should automatically update via trigger

## Fichiers Concernes
### A Creer
- Migration SQL via Supabase MCP: `20260128100001_create_reviews_table`

### A Modifier
- Aucun

## Notes Techniques

### Migration SQL
```sql
-- Migration: 20260128100001_create_reviews_table
-- Description: Create reviews table for client ratings of professionals
-- Source: MISSION-01-EVOLUTIONS-2026.md Section 4 (APP-01)

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pro_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  bride_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  rating INTEGER NOT NULL,
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,

  -- Constraints
  CONSTRAINT chk_rating_range CHECK (rating >= 1 AND rating <= 5),
  CONSTRAINT uq_one_review_per_bride_per_pro UNIQUE (pro_id, bride_id)
);

-- Index for fetching reviews by professional (common query)
CREATE INDEX IF NOT EXISTS idx_reviews_pro_id ON reviews(pro_id);

-- Index for fetching reviews by bride (my reviews)
CREATE INDEX IF NOT EXISTS idx_reviews_bride_id ON reviews(bride_id);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_reviews_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_reviews_updated_at
  BEFORE UPDATE ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_reviews_updated_at();

-- Enable RLS (policies added in S03)
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Comments for documentation
COMMENT ON TABLE reviews IS 'Client reviews for professionals (1-5 stars, optional comment)';
COMMENT ON COLUMN reviews.rating IS 'Star rating from 1 to 5';
COMMENT ON COLUMN reviews.comment IS 'Optional text comment from bride';
COMMENT ON CONSTRAINT chk_rating_range ON reviews IS 'Ensures rating is between 1 and 5 inclusive';
COMMENT ON CONSTRAINT uq_one_review_per_bride_per_pro ON reviews IS 'One bride can only leave one review per professional';
```

### Rollback SQL
```sql
DROP TRIGGER IF EXISTS trg_reviews_updated_at ON reviews;
DROP FUNCTION IF EXISTS update_reviews_updated_at;
DROP INDEX IF EXISTS idx_reviews_bride_id;
DROP INDEX IF EXISTS idx_reviews_pro_id;
DROP TABLE IF EXISTS reviews;
```

## Definition of Done
- [ ] Migration appliquee via Supabase MCP
- [ ] Table reviews existe avec toutes les colonnes
- [ ] Contrainte chk_rating_range fonctionne (1-5)
- [ ] Contrainte uq_one_review_per_bride_per_pro fonctionne
- [ ] Index idx_reviews_pro_id existe
- [ ] Index idx_reviews_bride_id existe
- [ ] Trigger trg_reviews_updated_at fonctionne
- [ ] RLS active sur la table
- [ ] Tests manuels SQL passes

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances
- EPIC-06 Prerequisites (Supabase branch setup)
- Table profiles doit exister (254 rows en prod)

## Stories Dependantes
- S02: Create pro_ratings view (depends on reviews table)
- S03: Add RLS policies (depends on reviews table)
- S04: Dart entities (uses table schema)
- S05: Repository implementation (queries this table)
