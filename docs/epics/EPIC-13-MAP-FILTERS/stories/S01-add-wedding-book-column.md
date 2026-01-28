# Story S01: Ajouter colonne offers_free_wedding_book

## Description
En tant que developpeur, je veux ajouter la colonne `offers_free_wedding_book` a la table `professional_details`, afin de pouvoir filtrer les pros offrant un wedding book gratuit.

## Criteres d'Acceptance (Gherkin)
- [ ] Given the professional_details table exists with 51 rows When the migration add_offers_free_wedding_book is applied Then professional_details should have column offers_free_wedding_book of type BOOLEAN
- [ ] Given the migration has been applied When checking existing rows Then all 51 rows should have offers_free_wedding_book = FALSE (default)
- [ ] Given the offers_free_wedding_book column exists When a professional updates their profile Then they can set offers_free_wedding_book to TRUE, FALSE, or NULL
- [ ] Given the migration has been applied When executing rollback Then the offers_free_wedding_book column should be removed without data loss

## Fichiers Concernes
### A Creer
- Migration Supabase: `20260128010001_add_offers_free_wedding_book`

### A Modifier
- Aucun fichier Flutter (migration DB uniquement)

## Notes Techniques

### Migration SQL
```sql
-- Migration: 20260128010001_add_offers_free_wedding_book
-- Description: Add wedding book free filter column to professional_details

ALTER TABLE professional_details
  ADD COLUMN IF NOT EXISTS offers_free_wedding_book BOOLEAN DEFAULT FALSE;

-- Create index for filter queries
CREATE INDEX IF NOT EXISTS idx_pro_details_wedding_book
  ON professional_details(offers_free_wedding_book)
  WHERE offers_free_wedding_book = TRUE;

-- Verification
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'professional_details' AND column_name = 'offers_free_wedding_book'
  ) THEN
    RAISE EXCEPTION 'Migration failed: offers_free_wedding_book column not created';
  END IF;
END $$;

-- Comment
COMMENT ON COLUMN professional_details.offers_free_wedding_book IS 'Professional offers a free wedding book/album (APP-07)';
```

### Rollback SQL
```sql
-- Rollback: 20260128010001_add_offers_free_wedding_book
DROP INDEX IF EXISTS idx_pro_details_wedding_book;
ALTER TABLE professional_details DROP COLUMN IF EXISTS offers_free_wedding_book;
```

### Verification post-migration
```sql
-- Verify column exists and has correct type
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'professional_details' AND column_name = 'offers_free_wedding_book';

-- Verify all rows have default value
SELECT COUNT(*) FROM professional_details WHERE offers_free_wedding_book IS NOT FALSE;
-- Should return 0
```

## Definition of Done
- [ ] Migration appliquee via MCP Supabase
- [ ] Colonne existe avec type BOOLEAN
- [ ] Default FALSE verifie sur toutes les lignes existantes
- [ ] Index cree sur la colonne
- [ ] Rollback teste et documente
- [ ] Aucune modification RLS necessaire (table existante)

## Estimation
**Points** : 1
**Complexite** : Faible
**Risque** : Faible

## Dependances
- Aucune

## Stories Dependantes
- S03 (Etendre MapFilter) - necessite que la colonne existe
- S07 (Mettre a jour query map) - necessite que la colonne existe
