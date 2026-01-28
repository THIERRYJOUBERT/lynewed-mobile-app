# Story S03: Add RLS policies for reviews table

## Description
En tant que developpeur backend, je veux configurer les Row Level Security policies pour la table reviews, afin de controler qui peut lire, creer et modifier les avis de maniere securisee.

## Criteres d'Acceptance (Gherkin)
- [ ] Given a user authenticated as bride When selecting from reviews Then all reviews should be visible
- [ ] Given a user authenticated as professional When selecting from reviews Then all reviews should be visible
- [ ] Given a user authenticated as bride-A When inserting a review with bride_id = bride-A Then the insert should succeed
- [ ] Given a user authenticated as bride-A When inserting a review with bride_id = bride-B Then the insert should fail with RLS violation
- [ ] Given a user authenticated as professional When inserting a review Then the insert should fail with RLS violation
- [ ] Given bride-A has a review for pro-X When bride-A updates that review Then the update should succeed
- [ ] Given bride-B has a review for pro-X When bride-A tries to update that review Then the update should fail with RLS violation
- [ ] Given a review exists When any user tries to delete it Then the delete should fail (no DELETE policy)

## Fichiers Concernes
### A Creer
- Migration SQL via Supabase MCP: `20260128100003_add_reviews_rls_policies`

### A Modifier
- Aucun

## Notes Techniques

### Migration SQL
```sql
-- Migration: 20260128100003_add_reviews_rls_policies
-- Description: Add RLS policies for reviews table
-- Source: MISSION-01-EVOLUTIONS-2026.md Annexe D.1

-- Ensure RLS is enabled (should already be from S01)
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Policy 1: Brides and professionals can read all reviews
-- Note: Guests are excluded to prevent data exposure via guest accounts
CREATE POLICY "Reviews readable by brides and professionals"
ON reviews FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role IN ('bride', 'professional')
  )
);

-- Policy 2: Bride can create review (only for herself)
CREATE POLICY "Bride can create review"
ON reviews FOR INSERT
TO authenticated
WITH CHECK (
  bride_id = auth.uid()
  AND EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'bride'
  )
);

-- Policy 3: Bride can update own review
CREATE POLICY "Bride can update own review"
ON reviews FOR UPDATE
TO authenticated
USING (bride_id = auth.uid())
WITH CHECK (bride_id = auth.uid());

-- Note: No DELETE policy - reviews cannot be deleted
-- This is intentional for data integrity and trust

-- Comments for documentation
COMMENT ON POLICY "Reviews readable by brides and professionals" ON reviews IS 'Brides and professionals can read reviews (guests excluded)';
COMMENT ON POLICY "Bride can create review" ON reviews IS 'Only brides can create reviews, and only for themselves';
COMMENT ON POLICY "Bride can update own review" ON reviews IS 'Brides can only update their own reviews';
```

### Rollback SQL
```sql
DROP POLICY IF EXISTS "Bride can update own review" ON reviews;
DROP POLICY IF EXISTS "Bride can create review" ON reviews;
DROP POLICY IF EXISTS "Reviews readable by brides and professionals" ON reviews;
```

### RLS Summary Table
| Operation | Bride | Professional | Guest |
|-----------|-------|--------------|-------|
| SELECT | All reviews | All reviews | None |
| INSERT | Own reviews only | None | None |
| UPDATE | Own reviews only | None | None |
| DELETE | None | None | None |

## Definition of Done
- [ ] Migration appliquee via Supabase MCP
- [ ] Policy "Reviews readable by brides and professionals" active
- [ ] Policy "Bride can create review" active
- [ ] Policy "Bride can update own review" active
- [ ] Aucune policy DELETE (intentionnel)
- [ ] Tests manuels RLS passes avec differents roles
- [ ] Security advisor Supabase passe sans warning

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Moyen (RLS mal configure = faille securite)

## Dependances
- S01: Table reviews must exist with RLS enabled

## Stories Dependantes
- S05: Repository implementation (relies on RLS for security)
- S06: UI submission (INSERT must work for brides)
