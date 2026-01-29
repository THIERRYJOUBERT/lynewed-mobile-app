# S02 - Create magazine_selections Table

> **Epic** : EPIC-12-MAGAZINES
> **Status** : 🔵 Draft
> **Estimation** : 2 points (S)
> **Domaine** : Database

---

## Description

Creer la table `magazine_selections` pour stocker les photos selectionnees pour le magazine avec leur position (ordre d'affichage).

## Dependances

- S01 (photo_favorites - meme pattern)

## Criteres d'Acceptance (Gherkin)

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

  Scenario: One entry per photo per wedding
    Given photo 'img-123' already in selection for wedding 'w-456'
    When trying to add same photo again
    Then unique constraint should prevent duplicate

  Scenario: RLS prevents access to other bride's selections
    Given bride-A has selections
    When bride-B queries magazine_selections
    Then bride-B should see 0 rows
```

## Details Techniques

### Migration SQL

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

  CONSTRAINT uq_magazine_selection UNIQUE (wedding_id, media_type, media_id),
  CONSTRAINT chk_magazine_selection_type CHECK (media_type IN ('album_image', 'guest_media'))
);

CREATE INDEX IF NOT EXISTS idx_magazine_selections_wedding
  ON magazine_selections(wedding_id, position);

ALTER TABLE magazine_selections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Bride manages own selections"
ON magazine_selections FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

COMMENT ON TABLE magazine_selections IS 'Photos selected for magazine with position ordering';
```

### Rollback

```sql
DROP POLICY IF EXISTS "Bride manages own selections" ON magazine_selections;
DROP INDEX IF EXISTS idx_magazine_selections_wedding;
DROP TABLE IF EXISTS magazine_selections;
```

## Fichiers a Modifier

| Fichier | Action |
|---------|--------|
| Supabase migration | Creer via MCP |

## Tests

- [ ] Table creee avec colonnes correctes
- [ ] Position integer fonctionne
- [ ] Contrainte UNIQUE par wedding
- [ ] RLS bloque acces cross-user

## Notes

- position permet drag & drop reordering
- wedding_id lie les selections au mariage
