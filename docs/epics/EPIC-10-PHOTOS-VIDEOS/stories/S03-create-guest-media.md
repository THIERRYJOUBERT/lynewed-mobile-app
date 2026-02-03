# Story S03: Creer table guest_media avec RLS

> **Revision 2026-02-03**: Suppression de `print_ready` et `shared_with_bride` - La bride voit AUTOMATIQUEMENT tous les medias de son mariage.

## Description
En tant que **guest invite a un mariage**, je veux **uploader mes photos et videos dans mon album personnel**, afin de **conserver mes souvenirs du mariage que la mariee pourra voir automatiquement**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the guest_albums table exists When the migration create_guest_media is applied Then table guest_media should exist with all required columns (id, album_id, media_type, storage_path, thumbnail_path, caption, duration_seconds, file_size_bytes, created_at)
- [ ] Given guest 'guest-123' has an album 'album-A' When the guest inserts a photo into album 'album-A' Then the insert should succeed And the media should be visible to the guest
- [ ] Given guest-A has album 'album-A' When guest-B tries to insert media into 'album-A' Then the insert should fail (RLS policy violation)
- [ ] Given guest album 'album-A' with 5 media files When album 'album-A' is deleted Then all 5 media files should be deleted automatically (CASCADE)
- [ ] Given a guest uploading media When media_type is set to 'invalid' Then the insert should fail with check constraint violation And only 'photo' or 'video' should be allowed
- [ ] Given a guest uploading media with a caption When caption length is 501 characters Then the insert should fail with check constraint violation
- [ ] Given guest-A and guest-B each have albums for the same wedding When the bride queries guest_media for her wedding Then the bride should see ALL media from ALL guests (automatic visibility)

## Fichiers Concernes

### A Creer
- Migration SQL via Supabase MCP: `20260128100003_create_guest_media`

### A Modifier
- Aucun fichier Flutter (migration DB uniquement)

## Notes Techniques

### Migration SQL
```sql
-- Migration: 20260128100003_create_guest_media
-- Description: Create guest_media table with strict RLS (D.3)
-- Revision 2026-02-03: Removed print_ready, bride sees ALL media automatically

CREATE TABLE IF NOT EXISTS guest_media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  album_id UUID REFERENCES guest_albums(id) ON DELETE CASCADE NOT NULL,
  media_type VARCHAR(10) NOT NULL,
  storage_path TEXT NOT NULL,
  thumbnail_path TEXT,
  caption TEXT,
  duration_seconds INTEGER,
  file_size_bytes BIGINT,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,

  -- Constraints
  CONSTRAINT chk_guest_media_type CHECK (media_type IN ('photo', 'video')),
  CONSTRAINT chk_guest_media_caption_length CHECK (caption IS NULL OR length(caption) <= 500),
  -- Server-side video duration validation (max 10 minutes = 600 seconds)
  CONSTRAINT chk_guest_media_video_duration CHECK (
    media_type != 'video' OR duration_seconds IS NULL OR duration_seconds <= 600
  ),
  -- Server-side file size validation (max 500MB for video, 20MB for photo)
  CONSTRAINT chk_guest_media_file_size CHECK (
    file_size_bytes IS NULL OR
    (media_type = 'video' AND file_size_bytes <= 524288000) OR
    (media_type = 'photo' AND file_size_bytes <= 20971520)
  )
);

-- Index for queries by album
CREATE INDEX IF NOT EXISTS idx_guest_media_album
  ON guest_media(album_id);

-- Index for queries by creation date
CREATE INDEX IF NOT EXISTS idx_guest_media_created
  ON guest_media(created_at DESC);

-- Enable RLS
ALTER TABLE guest_media ENABLE ROW LEVEL SECURITY;

-- Policy 1: Guest manages own media (via album ownership)
CREATE POLICY "Guest manages own media"
ON guest_media FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM guest_albums ga
    WHERE ga.id = guest_media.album_id
    AND ga.guest_user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM guest_albums ga
    WHERE ga.id = guest_media.album_id
    AND ga.guest_user_id = auth.uid()
  )
);

-- Policy 2: Bride views ALL media from her wedding (automatic visibility)
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

-- Comments
COMMENT ON TABLE guest_media IS 'Media files (photos/videos) uploaded by wedding guests - bride sees all automatically';
COMMENT ON COLUMN guest_media.storage_path IS 'Path in wedding-media bucket: {wedding_id}/guests/{guest_id}/{filename}';
```

### Rollback SQL
```sql
DROP POLICY IF EXISTS "Bride views all media" ON guest_media;
DROP POLICY IF EXISTS "Guest manages own media" ON guest_media;
DROP INDEX IF EXISTS idx_guest_media_created;
DROP INDEX IF EXISTS idx_guest_media_album;
DROP TABLE IF EXISTS guest_media;
```

### Contraintes serveur importantes
- **media_type**: Seuls 'photo' et 'video' acceptes
- **caption**: Maximum 500 caracteres
- **duration_seconds**: Maximum 600 (10 minutes) pour videos
- **file_size_bytes**: Max 500MB (524288000 bytes) pour video, Max 20MB (20971520 bytes) pour photo

### Storage Path Convention
```
wedding-media/{wedding_id}/guests/{guest_user_id}/{filename}
```

### Decisions de Design (2026-02-03)
- **Pas de `print_ready`** : Simplification - toutes les photos haute resolution sont disponibles
- **Pas de `shared_with_bride`** : La bride voit AUTOMATIQUEMENT tous les medias de son mariage
- **Visibilite automatique** : Quand un guest uploade, la bride voit immediatement

## Definition of Done
- [ ] Table guest_media creee avec toutes les colonnes (sans print_ready)
- [ ] FK vers guest_albums avec ON DELETE CASCADE
- [ ] Contraintes CHECK fonctionnelles (media_type, caption, duration, file_size)
- [ ] RLS activee avec 2 policies
- [ ] Policy "Guest manages own media" testee
- [ ] Policy "Bride views all media" testee (bride voit TOUT)
- [ ] Cascade delete teste
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 3
**Complexite** : Faible
**Risque** : Moyen (RLS critique pour la privacy)

## Dependances
- S02 (table guest_albums doit exister)

## Stories Dependantes
- S08 (Vue bride albums guests)
- S09 (Telechargement haute qualite)
