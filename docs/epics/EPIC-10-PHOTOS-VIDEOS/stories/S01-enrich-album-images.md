# Story S01: Enrichir album_images pour video + legendes

> **Revision 2026-02-03** : Suppression de `print_ready` (reporte au futur). Colonnes finales : media_type, caption, duration_seconds, file_size_bytes.

## Description
En tant que **developpeur**, je veux **enrichir la table album_images existante avec des colonnes pour supporter les videos, legendes et metadonnees**, afin de **permettre aux brides de stocker des videos en plus des photos avec des informations detaillees**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the album_images table exists with 5 rows When the migration enrich_album_images is applied Then album_images should have column media_type of type VARCHAR(10) with CHECK constraint (photo|video)
- [ ] Given the migration is applied Then media_type should default to 'photo' And all existing rows should have media_type = 'photo'
- [ ] Given the album_images table exists When the migration is applied Then album_images should have column caption of type TEXT with CHECK constraint (length <= 500)
- [ ] Given the migration is applied Then album_images should have columns duration_seconds (INTEGER) and file_size_bytes (BIGINT) for media metadata
- [ ] Given 5 existing images in album_images When the migration is applied Then all 5 images should remain unchanged with their image_url, thumbnail_url, uploaded_at intact

## Fichiers Concernes

### A Creer
- Migration SQL via Supabase MCP: `20260203100001_enrich_album_images`

### A Modifier
- Aucun fichier Flutter (migration DB uniquement)

## Notes Techniques

### Contraintes Business
- **Caption** : max 500 caracteres
- **Video** : max 10 minutes (600 secondes), max 500MB (524288000 bytes)
- **Photo** : max 20MB (20971520 bytes)
- **Bucket** : `wedding-albums` (existant, sera reutilise)

### Migration SQL
```sql
-- Migration: 20260203100001_enrich_album_images
-- Description: Add video support, captions, and metadata to album_images
-- Revision: 2026-02-03 - Removed print_ready (deferred to future)

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

-- Add metadata columns for both photos and videos
ALTER TABLE album_images
  ADD COLUMN IF NOT EXISTS duration_seconds INTEGER;

ALTER TABLE album_images
  ADD COLUMN IF NOT EXISTS file_size_bytes BIGINT;

-- Comments
COMMENT ON COLUMN album_images.media_type IS 'Type of media: photo or video';
COMMENT ON COLUMN album_images.caption IS 'User caption for the media (max 500 chars)';
COMMENT ON COLUMN album_images.duration_seconds IS 'Duration in seconds for video files (NULL for photos)';
COMMENT ON COLUMN album_images.file_size_bytes IS 'File size in bytes';
```

### Rollback SQL
```sql
-- Rollback: 20260203100001_enrich_album_images
ALTER TABLE album_images DROP CONSTRAINT IF EXISTS chk_album_images_caption_length;
ALTER TABLE album_images DROP CONSTRAINT IF EXISTS chk_album_images_media_type;
ALTER TABLE album_images DROP COLUMN IF EXISTS file_size_bytes;
ALTER TABLE album_images DROP COLUMN IF EXISTS duration_seconds;
ALTER TABLE album_images DROP COLUMN IF EXISTS caption;
ALTER TABLE album_images DROP COLUMN IF EXISTS media_type;
```

### Verification Post-Migration
- Verifier que les 5 rows existantes ont media_type = 'photo'
- Tester insertion d'une video avec media_type = 'video'
- Tester rejet d'un media_type invalide (ex: 'audio')
- Tester rejet d'une caption > 500 caracteres

## Definition of Done
- [ ] Migration appliquee sur branche Supabase
- [ ] Toutes les colonnes creees avec types corrects (media_type, caption, duration_seconds, file_size_bytes)
- [ ] Contraintes CHECK fonctionnelles (media_type IN ('photo','video'), caption length <= 500)
- [ ] Donnees existantes preservees (5 rows intactes)
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
