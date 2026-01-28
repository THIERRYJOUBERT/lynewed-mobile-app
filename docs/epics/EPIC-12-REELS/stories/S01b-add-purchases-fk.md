# Story S01b: Add FK purchase_id to purchases table

## Description
En tant que **developpeur backend**, je veux **ajouter la foreign key purchase_id vers la table purchases**, afin de **lier les reels aux achats futurs quand le feature payant sera active**.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Add purchase_id foreign key

  Scenario: FK is added after EPIC-11 completes
    Given EPIC-11 is complete
    And table purchases exists
    When the migration add_reels_purchase_fk is applied
    Then column purchase_id should have FK constraint to purchases(id)

  Scenario: FK allows NULL values
    Given the FK constraint exists
    When inserting a reel without purchase_id
    Then the insert should succeed
    And purchase_id should be NULL (MVP gratuit)

  Scenario: FK validates on INSERT
    Given a valid purchase with id 'purchase-123'
    When inserting a reel with purchase_id 'purchase-123'
    Then the insert should succeed

  Scenario: FK rejects invalid purchase_id
    Given no purchase with id 'invalid-purchase'
    When inserting a reel with purchase_id 'invalid-purchase'
    Then the insert should fail with FK violation

  Scenario: ON DELETE behavior
    Given a reel linked to purchase 'purchase-456'
    When the purchase is deleted
    Then the reel's purchase_id should be set to NULL (ON DELETE SET NULL)
    And the reel record should remain
```

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260128001201b_add_reels_purchase_fk.sql`

### A Modifier
- None

## Notes Techniques

### Migration SQL
```sql
-- Migration: 20260128001201b_add_reels_purchase_fk
-- Description: Add FK from reels.purchase_id to purchases(id)
-- Depends on: EPIC-11 (purchases table must exist)
-- Epic: EPIC-12-REELS
-- Story: S01b

-- Add FK constraint (column already exists from S01)
ALTER TABLE reels
  ADD CONSTRAINT fk_reels_purchase
  FOREIGN KEY (purchase_id)
  REFERENCES purchases(id)
  ON DELETE SET NULL;

-- Comment
COMMENT ON CONSTRAINT fk_reels_purchase ON reels IS
  'FK to purchases for paid reels (MVP: always NULL)';
```

### Rollback SQL
```sql
-- Rollback: 20260128001201b_add_reels_purchase_fk

ALTER TABLE reels DROP CONSTRAINT IF EXISTS fk_reels_purchase;
```

### Execution Order Note
This migration MUST be applied AFTER:
1. S01 (reels table with purchase_id column)
2. EPIC-11 completion (purchases table exists)

Sequence:
```
EPIC-10 complete
    |
    v
S01 (create reels table with purchase_id column, no FK)
    |
    v
EPIC-11 complete (purchases table created)
    |
    v
S01b (add FK constraint)
```

## Definition of Done
- [ ] Criteres d'acceptance valides
- [ ] EPIC-11 is complete (prerequisite verified)
- [ ] Migration applied successfully
- [ ] FK constraint visible in schema
- [ ] NULL values accepted
- [ ] Invalid purchase_id rejected
- [ ] ON DELETE SET NULL works
- [ ] `flutter analyze --fatal-infos` passe (N/A - DB only)

## Estimation
**Points** : 1
**Complexite** : Faible
**Risque** : Faible

## Dependances
- S01: Reels table must exist
- EPIC-11: Purchases table must exist (BLOCKER)

## Stories Dependantes
- None (enhancement for future paid feature)
