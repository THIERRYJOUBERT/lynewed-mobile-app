# Story S01: Enrichir album_images pour video + legendes

## Description
En tant que **developpeur**, je veux **enrichir la table album_images existante avec des colonnes pour supporter les videos, legendes et metadonnees**, afin de **permettre aux brides de stocker des videos en plus des photos avec des informations detaillees**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the album_images table exists with 5 rows When the migration enrich_album_images is applied Then album_images should have column media_type of type VARCHAR(10) with CHECK constraint (photo|video)
- [ ] Given the migration is applied Then media_type should default to 'photo' And all existing rows should have media_type = 'photo'
- [ ] Given the album_images table exists When the migration is applied Then album_images should have column caption of type TEXT with CHECK constraint (length <= 500)
- [ ] Given the migration is applied Then album_images should have columns duration_seconds (INTEGER) and file_size_bytes (BIGINT) for video metadata
- [ ] Given the migration is applied Then album_images should have column print_ready of type BOOLEAN defaulting to FALSE
- [ ] Given 5 existing images in album_images When the migration is applied Then all 5 images should remain unchanged with their image_url, thumbnail_url, uploaded_at intact

## Fichiers Concernes

### A Creer
- Migration SQL via Supabase MCP: `20260128100001_enrich_album_images`

### A Modifier
- Aucun fichier Flutter (migration DB uniquement)

## Notes Techniques

### Migration SQL
```sql
-- Migration: 20260128100001_enrich_album_images
-- Description: Add video support, captions, and print_ready flag to album_images

-- Add media_type column with check constraint
ALTER TABLE album_images
  ADD COLUMN IF NOT EXISTS media_type VARCHAR(10) DEFAULT 'photo';

ALTER TABLE album_images
  ADD CONSTRAINT chk_album_images_media_type
  CHECK (media_type IN ('photo', 'video'));

-- Add caption column with length constraint
ALTER TABLE album_images
  ADD COLUMN IF NOT EXISTS caption TEXT;

ALTER TABLE album_images
  ADD CONSTRAINT chk_album_images_caption_length
  CHECK (caption IS NULL OR length(caption) <= 500);

-- Add video-specific columns
ALTER TABLE album_images
  ADD COLUMN IF NOT EXISTS duration_seconds INTEGER;

ALTER TABLE album_images
  ADD COLUMN IF NOT EXISTS file_size_bytes BIGINT;

-- Add print_ready flag (preparation for future print orders)
ALTER TABLE album_images
  ADD COLUMN IF NOT EXISTS print_ready BOOLEAN DEFAULT FALSE;

-- Comments
COMMENT ON COLUMN album_images.media_type IS 'Type of media: photo or video';
COMMENT ON COLUMN album_images.caption IS 'User caption for the media (max 500 chars)';
COMMENT ON COLUMN album_images.duration_seconds IS 'Duration in seconds for video files';
COMMENT ON COLUMN album_images.file_size_bytes IS 'File size in bytes';
COMMENT ON COLUMN album_images.print_ready IS 'Flag for future print order feature';
```

### Rollback SQL
```sql
ALTER TABLE album_images DROP CONSTRAINT IF EXISTS chk_album_images_caption_length;
ALTER TABLE album_images DROP CONSTRAINT IF EXISTS chk_album_images_media_type;
ALTER TABLE album_images DROP COLUMN IF EXISTS print_ready;
ALTER TABLE album_images DROP COLUMN IF EXISTS file_size_bytes;
ALTER TABLE album_images DROP COLUMN IF EXISTS duration_seconds;
ALTER TABLE album_images DROP COLUMN IF EXISTS caption;
ALTER TABLE album_images DROP COLUMN IF EXISTS media_type;
```

### Verification Post-Migration
- Verifier que les 5 rows existantes ont media_type = 'photo'
- Tester insertion d'une video avec media_type = 'video'
- Tester rejet d'un media_type invalide
- Tester rejet d'une caption > 500 caracteres

## Definition of Done
- [ ] Migration appliquee sur branche Supabase
- [ ] Toutes les colonnes creees avec types corrects
- [ ] Contraintes CHECK fonctionnelles (media_type, caption length)
- [ ] Donnees existantes preservees
- [ ] Tests SQL valides
- [ ] `flutter analyze --fatal-infos` passe (pas de changement Flutter)

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances
- Aucune (premiere story de l'Epic)

## Stories Dependantes
- S05 (Upload video avec validation)
- S06 (Saisie legende a l'upload)
- S09 (Telechargement haute qualite)
- S10 (Flag print_ready)
