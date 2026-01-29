# S04 - Add status to guest_media Table

> **Epic** : EPIC-12-MAGAZINES
> **Status** : 🔵 Draft
> **Estimation** : 2 points (S)
> **Domaine** : Database

---

## Description

Ajouter une colonne `status` a la table `guest_media` pour permettre a la bride de masquer (hide) ou supprimer (soft delete) des photos guests de sa vue.

## Dependances

- EPIC-10 (table guest_media doit exister)

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Guest media status for bride control

  Scenario: Default status is active
    Given a guest uploads a photo
    When the photo is created
    Then status should be 'active'

  Scenario: Bride hides photo
    Given a shared guest photo with status = 'active'
    When bride hides the photo
    Then status should become 'hidden_by_bride'
    And photo should not appear in bride's main gallery view

  Scenario: Bride soft-deletes photo
    Given a shared guest photo
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
-- Migration: 20260129100004_add_status_to_guest_media
-- Description: Add status column for bride hide/delete control

-- Add status column
ALTER TABLE guest_media
  ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'active' NOT NULL;

-- Add check constraint
ALTER TABLE guest_media
  ADD CONSTRAINT chk_guest_media_status
  CHECK (status IN ('active', 'hidden_by_bride', 'deleted_by_bride'));

-- Update existing RLS policy for bride to filter by status
DROP POLICY IF EXISTS "Bride views shared media" ON guest_media;

CREATE POLICY "Bride views shared media"
ON guest_media FOR SELECT
TO authenticated
USING (
  status = 'active'
  AND EXISTS (
    SELECT 1 FROM guest_albums ga
    JOIN weddings w ON w.id = ga.wedding_id
    WHERE ga.id = guest_media.album_id
    AND ga.shared_with_bride = TRUE
    AND w.bride_profile_id = auth.uid()
  )
);

-- Policy for bride to view hidden/deleted (for management)
CREATE POLICY "Bride views hidden media"
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
    AND ga.shared_with_bride = TRUE
    AND w.bride_profile_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM guest_albums ga
    JOIN weddings w ON w.id = ga.wedding_id
    WHERE ga.id = guest_media.album_id
    AND ga.shared_with_bride = TRUE
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
DROP POLICY IF EXISTS "Bride views hidden media" ON guest_media;
DROP INDEX IF EXISTS idx_guest_media_status;
ALTER TABLE guest_media DROP CONSTRAINT IF EXISTS chk_guest_media_status;
ALTER TABLE guest_media DROP COLUMN IF EXISTS status;

-- Restore original policy
CREATE POLICY "Bride views shared media"
ON guest_media FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM guest_albums ga
    JOIN weddings w ON w.id = ga.wedding_id
    WHERE ga.id = guest_media.album_id
    AND ga.shared_with_bride = TRUE
    AND w.bride_profile_id = auth.uid()
  )
);
```

## Fichiers a Modifier

| Fichier | Action |
|---------|--------|
| Supabase migration | Creer via MCP |

## Tests

- [ ] Colonne status ajoutee avec default 'active'
- [ ] CHECK constraint fonctionne
- [ ] RLS filtre par status pour bride
- [ ] Guest voit toujours ses propres photos (quel que soit status)
- [ ] Bride peut update status

## Notes

- Soft delete = audit trail conserve
- Guest n'est pas impacte par les actions bride sur ses photos
- 3 policies RLS: active, hidden, update
