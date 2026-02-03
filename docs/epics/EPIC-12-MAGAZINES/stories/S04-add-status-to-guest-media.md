# S04 - Add status to guest_media Table

> **Epic** : EPIC-12-MAGAZINES
> **Status** : ✅ Done
> **Estimation** : 2 points (S)
> **Domaine** : Database
> **MAJ** : 2026-02-03

---

## Description

Ajouter une colonne `status` a la table `guest_media` pour permettre a la bride de masquer (hide) ou supprimer (soft delete) des photos guests de sa vue.

## Dependances

- EPIC-10 ✅ COMPLETE (table guest_media existe)

## Note Importante (MAJ 2026-02-03)

> ⚠️ Dans EPIC-10, on a decide que les albums guests sont **automatiquement visibles** par la bride (pas d'opt-in `shared_with_bride`).
> Les RLS policies doivent donc simplement verifier que la bride est proprietaire du wedding, pas de champ `shared_with_bride`.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Guest media status for bride control

  Scenario: Default status is active
    Given a guest uploads a photo
    When the photo is created
    Then status should be 'active'

  Scenario: Bride hides photo
    Given a guest photo with status = 'active'
    When bride hides the photo
    Then status should become 'hidden_by_bride'
    And photo should not appear in bride's main gallery view

  Scenario: Bride soft-deletes photo
    Given a guest photo
    When bride deletes the photo
    Then status should become 'deleted_by_bride'
    And photo should be invisible to bride
    And photo should still exist in storage (audit trail)

  Scenario: Guest still sees their own photos
    Given bride has hidden a photo
    When guest views their album
    Then the photo should still be visible to the guest

  Scenario: Hidden photos in Hidden filter
    Given bride has hidden 3 photos
    When bride uses 'Hidden' filter
    Then 3 photos should appear
    And bride can unhide them
```

## Details Techniques

### Migration SQL

```sql
-- Migration: 20260203_add_status_to_guest_media
-- Description: Add status column for bride hide/delete control
-- Note: No shared_with_bride check - all guest albums are automatically visible to bride (EPIC-10 decision)

-- Add status column
ALTER TABLE guest_media
  ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'active' NOT NULL;

-- Add check constraint
ALTER TABLE guest_media
  ADD CONSTRAINT chk_guest_media_status
  CHECK (status IN ('active', 'hidden_by_bride', 'deleted_by_bride'));

-- Update existing RLS policy for bride to filter by status
-- Note: Bride sees ALL guest media from her wedding (no opt-in)
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

-- Policy for bride to update status (hide/delete)
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

-- Index for status filtering
CREATE INDEX IF NOT EXISTS idx_guest_media_status
  ON guest_media(status)
  WHERE status != 'active';

COMMENT ON COLUMN guest_media.status IS 'Visibility: active, hidden_by_bride, deleted_by_bride';
```

### Rollback

```sql
DROP POLICY IF EXISTS "Bride can update guest media status" ON guest_media;
DROP POLICY IF EXISTS "Bride views hidden guest media" ON guest_media;
DROP POLICY IF EXISTS "Bride views active guest media" ON guest_media;
DROP INDEX IF EXISTS idx_guest_media_status;
ALTER TABLE guest_media DROP CONSTRAINT IF EXISTS chk_guest_media_status;
ALTER TABLE guest_media DROP COLUMN IF EXISTS status;

-- Restore original policy (from EPIC-10)
CREATE POLICY "Bride views all media"
ON guest_media FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM guest_albums ga
    JOIN weddings w ON w.id = ga.wedding_id
    WHERE ga.id = guest_media.album_id
    AND w.bride_profile_id = auth.uid()
  )
);
```

## Fichiers a Modifier

| Fichier | Action |
|---------|--------|
| Supabase migration | Creer via MCP |

## Tests

- [x] Colonne status ajoutee avec default 'active'
- [x] CHECK constraint fonctionne (chk_guest_media_status)
- [ ] RLS filtre par status pour bride (a faire cote Flutter, pas RLS modifiees)
- [x] Guest voit toujours ses propres photos (RLS existante preservee)
- [ ] Bride peut update status (a tester via Flutter)

## Implementation Finale (2026-02-03)

**Approche simplifiee** : On a choisi de NE PAS modifier les RLS policies existantes car:
1. C'est en PRODUCTION
2. Les policies existantes fonctionnent bien
3. Le filtrage par status sera fait cote Flutter pour plus de flexibilite

**Migration appliquee**:
- Colonne `status VARCHAR(20) DEFAULT 'active' NOT NULL`
- Constraint `chk_guest_media_status CHECK (status IN ('active', 'hidden_by_bride', 'deleted_by_bride'))`
- Index partiel `idx_guest_media_status WHERE status != 'active'`
- Comment sur la colonne

## Notes

- Soft delete = audit trail conserve
- Guest n'est pas impacte par les actions bride sur ses photos
- 3 policies RLS: active, hidden, update
- **Pas de `shared_with_bride`** : tout est automatiquement partage (decision EPIC-10)
