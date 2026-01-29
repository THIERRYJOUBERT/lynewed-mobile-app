# S01 - Create photo_favorites Table

> **Epic** : EPIC-12-MAGAZINES
> **Status** : 🔵 Draft
> **Estimation** : 2 points (S)
> **Domaine** : Database

---

## Description

Creer la table `photo_favorites` pour permettre aux brides de marquer leurs photos preferees. Cette table supporte les photos des albums bride ET les photos guests partagees.

## Dependances

- Aucune (premiere story)

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Photo favorites table for bride

  Scenario: Creating photo_favorites table
    Given the database schema
    When the migration create_photo_favorites is applied
    Then table photo_favorites should exist
    And it should have columns: id, user_id, media_type, media_id, created_at
    And UNIQUE constraint on (user_id, media_type, media_id)

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

## Details Techniques

### Migration SQL

```sql
-- Migration: 20260129100001_create_photo_favorites
-- Description: Create photo_favorites table for bride favorites

CREATE TABLE IF NOT EXISTS photo_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  media_type VARCHAR(20) NOT NULL,
  media_id UUID NOT NULL,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,

  CONSTRAINT uq_photo_favorites UNIQUE (user_id, media_type, media_id),
  CONSTRAINT chk_photo_favorites_type CHECK (media_type IN ('album_image', 'guest_media'))
);

CREATE INDEX IF NOT EXISTS idx_photo_favorites_user
  ON photo_favorites(user_id, created_at DESC);

ALTER TABLE photo_favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "User manages own favorites"
ON photo_favorites FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

COMMENT ON TABLE photo_favorites IS 'Favorited photos by brides (from album_images or shared guest_media)';
```

### Rollback

```sql
DROP POLICY IF EXISTS "User manages own favorites" ON photo_favorites;
DROP INDEX IF EXISTS idx_photo_favorites_user;
DROP TABLE IF EXISTS photo_favorites;
```

## Fichiers a Modifier

| Fichier | Action |
|---------|--------|
| Supabase migration | Creer via MCP |

## Tests

- [ ] Table creee avec colonnes correctes
- [ ] Contrainte UNIQUE fonctionne
- [ ] RLS bloque acces cross-user
- [ ] Index performant sur user_id

## Notes

- media_type permet de supporter album_images ET guest_media
- media_id est un UUID generique (pas de FK pour flexibilite)
