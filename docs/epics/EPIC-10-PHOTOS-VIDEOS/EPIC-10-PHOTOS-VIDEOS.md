# EPIC-10-PHOTOS-VIDEOS

> Resume : Enrichir la galerie existante avec support video, legendes, albums guests separes, et telechargement haute qualite
> Status : 🔵 Draft
> Domaine : Features / Media / Storage
> Cree le : 2026-01-28

---

## Contexte

### Pourquoi cet Epic

Cet Epic **enrichit** les fonctionnalites de galerie existantes pour supporter les videos, les legendes, et creer un systeme d'albums separe pour les guests. Il prepare egalement l'infrastructure pour les futures fonctionnalites de commande d'impressions et d'achat d'albums.

**Etat actuel verifie en production (Supabase MCP):**

| Element | Etat actuel | Contenu |
|---------|-------------|---------|
| `inspiration_albums` | ✅ Existe | 6 rows - Albums bride avec categories |
| `album_images` | ✅ Existe | 5 rows - Photos uploadees (PAS de videos, PAS de legendes) |
| `saved_posts` | ✅ Existe | 4 rows - Photos sauvees depuis feed |
| `guest_albums` | ❌ N'existe pas | Table a creer |
| `guest_media` | ❌ N'existe pas | Table a creer |
| `gallery_access_logs` | ❌ N'existe pas | Table a creer |
| Bucket `wedding-media` | ⏳ En attente | Cree dans EPIC-06 |

**Colonnes manquantes dans album_images:**
- `media_type` (photo/video)
- `caption` (legende max 500 chars)
- `duration_seconds` (pour videos)
- `file_size_bytes`
- `print_ready` (flag pour futur)

### Dependances

| Dependance | Epic | Status | Impact si non fait |
|------------|------|--------|-------------------|
| Bucket `wedding-media` | EPIC-06-PREREQUISITES | ⏳ Draft | Stockage impossible |
| Systeme guest | EPIC-09-GUESTS (APP-03) | ⏳ A creer | Albums guests non fonctionnels |
| Enum `userRole` avec `guest` | EPIC-06-PREREQUISITES | ⏳ Draft | Pas de role guest |

### Piliers Techniques Concernes

| Pilier | Implication pour cet Epic |
|--------|---------------------------|
| **Supabase Database** | Nouvelles tables guest_albums, guest_media, gallery_access_logs |
| **Supabase Storage** | Utilisation bucket wedding-media (EPIC-06) |
| **Flutter/Dart** | Nouveaux use cases, UI upload video, composants legende |
| **Securite** | RLS strictes - guest voit UNIQUEMENT ses propres medias |

---

## Architecture Cible

### Structure de Stockage

```
Bucket: wedding-media (cree dans EPIC-06)
└── {wedding_id}/
    ├── bride/
    │   └── {filename}          # Medias de la bride
    └── guests/
        └── {guest_user_id}/
            └── {filename}      # Medias du guest (isole)
```

### Schema de Donnees

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SCHEMA PHOTOS & VIDEOS (APP-04)                           │
│                                                                              │
│  album_images (ENRICHIR - existante)                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  id, album_id, image_url, thumbnail_url, uploaded_at (existants)     │   │
│  │  + media_type VARCHAR(10) DEFAULT 'photo' CHECK (photo|video)        │   │
│  │  + caption TEXT CHECK (length <= 500)                                │   │
│  │  + duration_seconds INTEGER (pour videos)                            │   │
│  │  + file_size_bytes BIGINT                                            │   │
│  │  + print_ready BOOLEAN DEFAULT FALSE (preparation futur)             │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  guest_albums (NOUVELLE)                                                     │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  id UUID PRIMARY KEY                                                 │   │
│  │  wedding_id UUID REFERENCES weddings(id)                             │   │
│  │  guest_user_id UUID REFERENCES profiles(id)                          │   │
│  │  shared_with_bride BOOLEAN DEFAULT FALSE  ← OPT-IN                   │   │
│  │  created_at TIMESTAMP                                                │   │
│  │  UNIQUE(wedding_id, guest_user_id)  ← 1 album par guest par mariage │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  guest_media (NOUVELLE)                                                      │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  id UUID PRIMARY KEY                                                 │   │
│  │  album_id UUID REFERENCES guest_albums(id) ON DELETE CASCADE         │   │
│  │  media_type VARCHAR(10) CHECK (photo|video)                          │   │
│  │  storage_path TEXT NOT NULL                                          │   │
│  │  thumbnail_path TEXT                                                 │   │
│  │  caption TEXT CHECK (length <= 500)                                  │   │
│  │  duration_seconds INTEGER (pour videos)                              │   │
│  │  file_size_bytes BIGINT                                              │   │
│  │  print_ready BOOLEAN DEFAULT FALSE                                   │   │
│  │  created_at TIMESTAMP                                                │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  gallery_access_logs (NOUVELLE)                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  id UUID PRIMARY KEY                                                 │   │
│  │  wedding_id UUID REFERENCES weddings(id)                             │   │
│  │  accessed_by UUID REFERENCES profiles(id)                            │   │
│  │  access_type VARCHAR(50)  ← view|download|share_enabled|share_disabled │
│  │  ip_address VARCHAR(50)                                              │   │
│  │  created_at TIMESTAMP                                                │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Limites de Fichiers (PRD Section 6)

| Type | Limite | Raison |
|------|--------|--------|
| **Photo** | 20 MB max | Qualite suffisante |
| **Video duree** | 10 minutes max | Eviter abus storage |
| **Video taille** | 500 MB max | Balance qualite/cout |
| **Video pour reel** | 2 minutes max par video | Reels exploitables |
| **Legende** | 500 caracteres max | UX concise |

---

## Stories

| # | Story | Domaine | Dep. | Criteres cles | Source PRD | Complexite |
|---|-------|---------|------|---------------|------------|------------|
| S01 | Enrichir album_images pour video + legendes | DB | - | media_type, caption, duration, file_size, print_ready | US-04.1, US-04.2 | S |
| S02 | Creer table guest_albums avec RLS | DB | EPIC-06 S01 | 1 album/guest/mariage, shared_with_bride opt-in | US-04.7, D.3 | S |
| S03 | Creer table guest_media avec RLS | DB | S02 | Colonnes media, RLS strictes | US-04.8, D.3 | S |
| S04 | Creer table gallery_access_logs | DB | - | Tracabilite acces, types d'action | PRD 6 | S |
| S05 | Implementer upload video avec validation | Flutter | S01 | Duree ≤10min, taille ≤500MB, formats video | US-04.1 | M |
| S06 | Ajouter saisie legende a l'upload media | Flutter | S01 | Champ texte 500 chars, preview | US-04.2, US-04.9 | S |
| S07 | Implementer toggle shared_with_bride | Flutter | S02, S03 | Switch opt-in, confirmation, logs | US-04.11 | S |
| S08 | Vue bride des albums guests partages | Flutter | S02, S03 | Liste albums partages, navigation medias | US-04.3 | M |
| S09 | Telechargement haute qualite (zip multiple) | Flutter | S01-S03 | Download unique/multiple, zip si plusieurs | US-04.4 | M |
| S10 | Preparer flag print_ready pour futur | DB + Flutter | S01 | Flag sur medias, UI visible mais desactive | PRD anticipation | S |

---

## Detail des Stories

### S01 : Enrichir album_images pour video + legendes

**Contexte** : La table `album_images` existe avec 5 rows mais ne supporte que les photos sans legendes.

**Criteres cles** :
- Colonne `media_type` VARCHAR(10) ajoutee avec CHECK (photo|video) et DEFAULT 'photo'
- Colonne `caption` TEXT ajoutee avec CHECK (length <= 500)
- Colonne `duration_seconds` INTEGER ajoutee (NULL pour photos)
- Colonne `file_size_bytes` BIGINT ajoutee
- Colonne `print_ready` BOOLEAN ajoutee avec DEFAULT FALSE
- Les 5 rows existantes sont preservees avec media_type='photo'

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 6 (APP-04)

**Complexite** : S (Small) - Ajout colonnes simple, pas de changement de structure

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Enrich album_images table for video and caption support

  Scenario: Adding media_type column
    Given the album_images table exists with 5 rows
    When the migration enrich_album_images is applied
    Then album_images should have column media_type of type VARCHAR(10)
    And media_type should default to 'photo'
    And all existing rows should have media_type = 'photo'
    And only 'photo' or 'video' values should be allowed

  Scenario: Adding caption column
    Given the album_images table exists
    When the migration enrich_album_images is applied
    Then album_images should have column caption of type TEXT
    And caption should allow NULL
    And captions longer than 500 characters should be rejected

  Scenario: Adding video-specific columns
    Given the album_images table exists
    When the migration enrich_album_images is applied
    Then album_images should have column duration_seconds of type INTEGER
    And album_images should have column file_size_bytes of type BIGINT
    And both columns should allow NULL

  Scenario: Adding print_ready flag
    Given the album_images table exists
    When the migration enrich_album_images is applied
    Then album_images should have column print_ready of type BOOLEAN
    And print_ready should default to FALSE

  Scenario: Existing data is preserved
    Given 5 existing images in album_images
    When the migration is applied
    Then all 5 images should remain unchanged
    And their image_url, thumbnail_url, uploaded_at should be intact
```

**Details techniques** :

**Migration SQL** :
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

-- Verification
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'album_images' AND column_name = 'media_type'
  ) THEN
    RAISE EXCEPTION 'Migration failed: media_type column not created';
  END IF;
END $$;

-- Comment
COMMENT ON COLUMN album_images.media_type IS 'Type of media: photo or video';
COMMENT ON COLUMN album_images.caption IS 'User caption for the media (max 500 chars)';
COMMENT ON COLUMN album_images.duration_seconds IS 'Duration in seconds for video files';
COMMENT ON COLUMN album_images.file_size_bytes IS 'File size in bytes';
COMMENT ON COLUMN album_images.print_ready IS 'Flag for future print order feature';
```

**Rollback** :
```sql
-- Rollback: 20260128100001_enrich_album_images

ALTER TABLE album_images DROP CONSTRAINT IF EXISTS chk_album_images_caption_length;
ALTER TABLE album_images DROP CONSTRAINT IF EXISTS chk_album_images_media_type;
ALTER TABLE album_images DROP COLUMN IF EXISTS print_ready;
ALTER TABLE album_images DROP COLUMN IF EXISTS file_size_bytes;
ALTER TABLE album_images DROP COLUMN IF EXISTS duration_seconds;
ALTER TABLE album_images DROP COLUMN IF EXISTS caption;
ALTER TABLE album_images DROP COLUMN IF EXISTS media_type;
```

---

### S02 : Creer table guest_albums avec RLS

**Contexte** : Les guests doivent avoir leur propre album separe des albums d'inspiration de la bride. Un album par guest par mariage.

**Criteres cles** :
- Table `guest_albums` creee avec colonnes: id, wedding_id, guest_user_id, shared_with_bride, created_at
- Contrainte UNIQUE sur (wedding_id, guest_user_id)
- `shared_with_bride` DEFAULT FALSE (opt-in obligatoire)
- RLS: Guest gere uniquement son propre album
- RLS: Bride voit uniquement les albums partages de son mariage
- Index sur wedding_id pour requetes performantes

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 6, Decision D.3

**Complexite** : S (Small) - Table simple avec RLS

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Guest albums table with strict RLS

  Scenario: Creating guest_albums table
    Given the database schema
    When the migration create_guest_albums is applied
    Then table guest_albums should exist
    And it should have column wedding_id of type UUID referencing weddings(id)
    And it should have column guest_user_id of type UUID referencing profiles(id)
    And it should have column shared_with_bride of type BOOLEAN defaulting to FALSE
    And it should have a UNIQUE constraint on (wedding_id, guest_user_id)

  Scenario: Guest can create their own album
    Given a guest with user_id 'guest-123' in wedding 'wedding-456'
    When the guest creates an album for wedding 'wedding-456'
    Then the album should be created successfully
    And shared_with_bride should be FALSE by default

  Scenario: One album per guest per wedding
    Given guest 'guest-123' already has an album in wedding 'wedding-456'
    When the guest tries to create another album in 'wedding-456'
    Then the insert should fail with unique constraint violation

  Scenario: Guest can only see their own album
    Given guest-A and guest-B both have albums in wedding 'wedding-456'
    When guest-A queries guest_albums
    Then guest-A should only see their own album
    And guest-A should not see guest-B's album

  Scenario: Bride can see shared albums only
    Given guest-A has shared_with_bride = TRUE
    And guest-B has shared_with_bride = FALSE
    When the bride queries guest_albums for her wedding
    Then the bride should see guest-A's album
    And the bride should NOT see guest-B's album

  Scenario: Guest from different wedding cannot access
    Given guest 'guest-123' in wedding 'wedding-456'
    When the guest tries to view albums from wedding 'wedding-789'
    Then the query should return 0 rows (RLS blocks access)
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128100002_create_guest_albums
-- Description: Create guest_albums table with strict RLS (D.3)

CREATE TABLE IF NOT EXISTS guest_albums (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID REFERENCES weddings(id) NOT NULL,
  guest_user_id UUID REFERENCES profiles(id) NOT NULL,
  shared_with_bride BOOLEAN DEFAULT FALSE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW() NOT NULL,

  -- One album per guest per wedding
  CONSTRAINT uq_guest_albums_wedding_guest UNIQUE (wedding_id, guest_user_id)
);

-- Index for queries by wedding (for bride view)
CREATE INDEX IF NOT EXISTS idx_guest_albums_wedding_shared
  ON guest_albums(wedding_id)
  WHERE shared_with_bride = TRUE;

-- Index for queries by guest
CREATE INDEX IF NOT EXISTS idx_guest_albums_guest_user
  ON guest_albums(guest_user_id);

-- Enable RLS
ALTER TABLE guest_albums ENABLE ROW LEVEL SECURITY;

-- Policy 1: Guest manages own album (CRUD)
CREATE POLICY "Guest manages own album"
ON guest_albums FOR ALL
TO authenticated
USING (guest_user_id = auth.uid())
WITH CHECK (guest_user_id = auth.uid());

-- Policy 2: Bride views shared albums of her wedding
CREATE POLICY "Bride views shared albums"
ON guest_albums FOR SELECT
TO authenticated
USING (
  shared_with_bride = TRUE
  AND EXISTS (
    SELECT 1 FROM weddings w
    WHERE w.id = guest_albums.wedding_id
    AND w.bride_profile_id = auth.uid()
  )
);

-- Comments
COMMENT ON TABLE guest_albums IS 'Personal photo albums for wedding guests (one per guest per wedding)';
COMMENT ON COLUMN guest_albums.shared_with_bride IS 'Opt-in flag: TRUE = bride can view this album';
COMMENT ON POLICY "Guest manages own album" ON guest_albums IS 'RLS D.3: Guest can only CRUD their own album';
COMMENT ON POLICY "Bride views shared albums" ON guest_albums IS 'RLS D.3: Bride sees only shared albums from her wedding';
```

**Rollback** :
```sql
-- Rollback: 20260128100002_create_guest_albums

DROP POLICY IF EXISTS "Bride views shared albums" ON guest_albums;
DROP POLICY IF EXISTS "Guest manages own album" ON guest_albums;
DROP INDEX IF EXISTS idx_guest_albums_guest_user;
DROP INDEX IF EXISTS idx_guest_albums_wedding_shared;
DROP TABLE IF EXISTS guest_albums;
```

---

### S03 : Creer table guest_media avec RLS

**Contexte** : Les medias des guests sont stockes separement des medias de la bride. Chaque media appartient a un album guest.

**Criteres cles** :
- Table `guest_media` creee avec toutes les colonnes specifiees
- FK vers guest_albums(id) avec ON DELETE CASCADE
- RLS: Guest gere uniquement ses propres medias (via album ownership)
- RLS: Bride voit uniquement les medias des albums partages
- Support photo et video avec memes contraintes que album_images
- Index pour requetes performantes

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 6, Decision D.3

**Complexite** : S (Small) - Table avec RLS similaire a S02

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Guest media table with strict RLS

  Scenario: Creating guest_media table
    Given the guest_albums table exists
    When the migration create_guest_media is applied
    Then table guest_media should exist
    And it should have all required columns (album_id, media_type, storage_path, etc.)
    And album_id should reference guest_albums(id) with ON DELETE CASCADE

  Scenario: Guest can upload media to their album
    Given guest 'guest-123' has an album 'album-A'
    When the guest inserts a photo into album 'album-A'
    Then the insert should succeed
    And the media should be visible to the guest

  Scenario: Guest cannot upload to other guest's album
    Given guest-A has album 'album-A'
    When guest-B tries to insert media into 'album-A'
    Then the insert should fail (RLS policy violation)

  Scenario: Cascade delete removes media
    Given guest album 'album-A' with 5 media files
    When album 'album-A' is deleted
    Then all 5 media files should be deleted automatically

  Scenario: Media type constraints
    Given a guest uploading media
    When media_type is set to 'invalid'
    Then the insert should fail with check constraint violation
    And only 'photo' or 'video' should be allowed

  Scenario: Caption length constraint
    Given a guest uploading media with a caption
    When caption length is 501 characters
    Then the insert should fail with check constraint violation

  Scenario: Bride can view shared media only
    Given guest-A's album is shared (shared_with_bride = TRUE)
    And guest-B's album is not shared
    When the bride queries guest_media for her wedding
    Then the bride should see media from guest-A's album
    And the bride should NOT see media from guest-B's album
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128100003_create_guest_media
-- Description: Create guest_media table with strict RLS (D.3)

CREATE TABLE IF NOT EXISTS guest_media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  album_id UUID REFERENCES guest_albums(id) ON DELETE CASCADE NOT NULL,
  media_type VARCHAR(10) NOT NULL,
  storage_path TEXT NOT NULL,
  thumbnail_path TEXT,
  caption TEXT,
  duration_seconds INTEGER,
  file_size_bytes BIGINT,
  print_ready BOOLEAN DEFAULT FALSE NOT NULL,
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
    (media_type = 'video' AND file_size_bytes <= 524288000) OR  -- 500MB
    (media_type = 'photo' AND file_size_bytes <= 20971520)       -- 20MB
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

-- Policy 2: Bride views media from shared albums
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

-- Comments
COMMENT ON TABLE guest_media IS 'Media files (photos/videos) uploaded by wedding guests';
COMMENT ON COLUMN guest_media.media_type IS 'Type of media: photo or video';
COMMENT ON COLUMN guest_media.storage_path IS 'Path in wedding-media bucket: {wedding_id}/guests/{guest_id}/{filename}';
COMMENT ON COLUMN guest_media.caption IS 'User caption for the media (max 500 chars)';
COMMENT ON COLUMN guest_media.duration_seconds IS 'Duration in seconds for video files (max 600 = 10 min)';
COMMENT ON COLUMN guest_media.print_ready IS 'Flag for future print order feature';
COMMENT ON POLICY "Guest manages own media" ON guest_media IS 'RLS D.3: Guest can only CRUD media in their own album';
COMMENT ON POLICY "Bride views shared media" ON guest_media IS 'RLS D.3: Bride sees only media from shared albums';
```

**Rollback** :
```sql
-- Rollback: 20260128100003_create_guest_media

DROP POLICY IF EXISTS "Bride views shared media" ON guest_media;
DROP POLICY IF EXISTS "Guest manages own media" ON guest_media;
DROP INDEX IF EXISTS idx_guest_media_created;
DROP INDEX IF EXISTS idx_guest_media_album;
DROP TABLE IF EXISTS guest_media;
```

---

### S04 : Creer table gallery_access_logs

**Contexte** : Pour des raisons de tracabilite et de conformite, tous les acces a la galerie (vue, telechargement, partage) doivent etre logges.

**Criteres cles** :
- Table `gallery_access_logs` creee avec colonnes specifiees
- Types d'acces: view, download, share_enabled, share_disabled
- IP address capturee pour audit
- RLS: service_role uniquement (pas d'acces public)
- Index pour requetes par wedding_id et par date

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 6

**Complexite** : S (Small) - Table simple avec RLS restrictive

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Gallery access logs for traceability

  Scenario: Creating gallery_access_logs table
    Given the database schema
    When the migration create_gallery_access_logs is applied
    Then table gallery_access_logs should exist
    And it should have columns: id, wedding_id, accessed_by, access_type, ip_address, created_at

  Scenario: Logging a view action
    Given a user views media in a wedding gallery
    When the access is logged
    Then a row should be inserted with access_type = 'view'
    And accessed_by should contain the user's profile_id

  Scenario: Logging a download action
    Given a user downloads media
    When the access is logged
    Then a row should be inserted with access_type = 'download'

  Scenario: Logging share toggle
    Given a guest toggles shared_with_bride
    When shared_with_bride changes to TRUE
    Then a row should be inserted with access_type = 'share_enabled'

    When shared_with_bride changes to FALSE
    Then a row should be inserted with access_type = 'share_disabled'

  Scenario: RLS prevents direct user access
    Given a user authenticated with anon key
    When they try to SELECT from gallery_access_logs
    Then they should receive 0 rows (RLS blocks access)

  Scenario: Service role can access logs
    Given a service authenticated with service_role key
    When querying gallery_access_logs
    Then all logs should be accessible
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128100004_create_gallery_access_logs
-- Description: Create audit log table for gallery access traceability

CREATE TABLE IF NOT EXISTS gallery_access_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID REFERENCES weddings(id),
  accessed_by UUID REFERENCES profiles(id),
  access_type VARCHAR(50) NOT NULL,
  media_id UUID, -- Optional: specific media accessed
  ip_address VARCHAR(50),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,

  -- Constraint for valid access types
  CONSTRAINT chk_access_type CHECK (
    access_type IN ('view', 'download', 'download_zip', 'share_enabled', 'share_disabled')
  )
);

-- Index for queries by wedding
CREATE INDEX IF NOT EXISTS idx_gallery_logs_wedding
  ON gallery_access_logs(wedding_id, created_at DESC);

-- Index for queries by user
CREATE INDEX IF NOT EXISTS idx_gallery_logs_user
  ON gallery_access_logs(accessed_by, created_at DESC);

-- Index for cleanup of old logs
CREATE INDEX IF NOT EXISTS idx_gallery_logs_created
  ON gallery_access_logs(created_at);

-- Enable RLS
ALTER TABLE gallery_access_logs ENABLE ROW LEVEL SECURITY;

-- No public policies - only service_role can access
-- Logs are written by Edge Functions using service_role

-- Comments
COMMENT ON TABLE gallery_access_logs IS 'Audit log for gallery access (view, download, share toggle)';
COMMENT ON COLUMN gallery_access_logs.access_type IS 'Type of access: view, download, download_zip, share_enabled, share_disabled';
COMMENT ON COLUMN gallery_access_logs.media_id IS 'Optional: UUID of specific media accessed (for single view/download)';
```

**Rollback** :
```sql
-- Rollback: 20260128100004_create_gallery_access_logs

DROP INDEX IF EXISTS idx_gallery_logs_created;
DROP INDEX IF EXISTS idx_gallery_logs_user;
DROP INDEX IF EXISTS idx_gallery_logs_wedding;
DROP TABLE IF EXISTS gallery_access_logs;
```

---

### S05 : Implementer upload video avec validation

**Contexte** : L'app supporte actuellement l'upload de photos. Il faut ajouter le support video avec des validations strictes de duree et taille.

**Criteres cles** :
- Upload video depuis galerie device (mp4, mov, m4v)
- Validation duree ≤ 10 minutes AVANT upload
- Validation taille ≤ 500 MB AVANT upload
- Generation thumbnail automatique
- Progress indicator pendant upload
- Gestion d'erreur avec messages clairs
- Compression optionnelle si video trop grande

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 6 (US-04.1)

**Complexite** : M (Medium) - Logique video complexe, thumbnail generation

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Video upload with duration and size validation

  Scenario: Selecting a valid video
    Given a user on the media upload screen
    When the user selects a video of 5 minutes and 200MB
    Then the video should be accepted
    And a preview should be shown

  Scenario: Rejecting video too long
    Given a user on the media upload screen
    When the user selects a video of 15 minutes
    Then the upload should be rejected
    And error message "Video must be 10 minutes or less" should be shown

  Scenario: Rejecting video too large
    Given a user on the media upload screen
    When the user selects a video of 600MB
    Then the upload should be rejected
    And error message "Video must be 500MB or less" should be shown

  Scenario: Uploading video with progress
    Given a user has selected a valid video
    When the upload starts
    Then a progress indicator should be visible
    And the percentage should update during upload

  Scenario: Thumbnail generation
    Given a video is successfully uploaded
    When the upload completes
    Then a thumbnail should be generated automatically
    And the thumbnail should be stored in storage

  Scenario: Supported video formats
    Given a user selecting a video file
    When the file is .mp4, .mov, or .m4v
    Then the file should be accepted

    When the file is .avi or .wmv
    Then the file should be rejected with format error

  Scenario: Network error handling
    Given a video upload in progress
    When network connection is lost
    Then upload should pause
    And user should see "Connection lost" message
    And retry option should be available

  Scenario: Video duration extraction
    Given a video file is selected
    When the app processes the file
    Then duration_seconds should be calculated
    And stored in the database
```

**Details techniques** :

**Fichiers a creer/modifier** :
- `lib/features/my_wedding/domain/usecases/upload_media_use_case.dart` - Enrichir
- `lib/features/my_wedding/presentation/widgets/video_picker_widget.dart` - Nouveau
- `lib/core/utils/video_utils.dart` - Nouveau (validation, thumbnail)

**Dependances Flutter** :
- `video_compress` - Pour compression et thumbnail
- Existant: `image_picker` (supporte deja video)

---

### S06 : Ajouter saisie legende a l'upload media

**Contexte** : Les utilisateurs doivent pouvoir ajouter une legende a leurs photos et videos.

**Criteres cles** :
- Champ texte avec limite 500 caracteres
- Compteur de caracteres visible
- Optionnel (peut etre laisse vide)
- Preview de la legende sur le media
- Modification possible apres upload
- Support emojis

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 6 (US-04.2, US-04.9)

**Complexite** : S (Small) - UI simple

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Caption input for media upload

  Scenario: Adding caption during upload
    Given a user has selected a photo or video
    When the upload screen is displayed
    Then a caption text field should be visible
    And placeholder text "Add a caption (optional)" should be shown

  Scenario: Character counter
    Given a user typing a caption
    When the user types "Hello"
    Then counter should show "5/500"

    When the user types 500 characters
    Then counter should show "500/500"
    And the text should turn orange as a warning

  Scenario: Enforcing character limit
    Given a caption with 500 characters
    When the user tries to type more
    Then no additional characters should be accepted
    And counter should remain at "500/500"

  Scenario: Empty caption allowed
    Given a user on the upload screen
    When the user leaves caption empty
    Then upload should proceed successfully
    And caption should be NULL in database

  Scenario: Caption preview
    Given a user has typed a caption
    When viewing the media preview
    Then the caption should be displayed below the media

  Scenario: Editing caption after upload
    Given a media with an existing caption
    When the user taps "Edit caption"
    Then the caption text field should appear with existing text
    And user should be able to modify and save
```

**Details techniques** :

**Fichiers a creer/modifier** :
- `lib/features/my_wedding/presentation/widgets/caption_input_widget.dart` - Nouveau
- `lib/features/my_wedding/presentation/pages/media_upload_page.dart` - Modifier

---

### S07 : Implementer toggle shared_with_bride

**Contexte** : Les guests doivent explicitement choisir de partager leur album avec la bride (opt-in).

**Criteres cles** :
- Switch toggle sur l'album guest
- Confirmation dialog avant activation
- Log dans gallery_access_logs a chaque changement
- Texte explicatif clair sur ce que "partager" signifie
- Etat initial = FALSE (non partage)
- Changement instantane (optimistic update)

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 6 (US-04.11)

**Complexite** : S (Small) - UI switch + confirmation

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Opt-in sharing with bride toggle

  Scenario: Default state is not shared
    Given a guest creates their album
    When viewing album settings
    Then shared_with_bride toggle should be OFF
    And label should say "Share with bride: Off"

  Scenario: Enabling sharing shows confirmation
    Given shared_with_bride is OFF
    When guest taps the toggle
    Then a confirmation dialog should appear
    And text should explain "The bride will be able to view your photos and videos"
    And options should be "Cancel" and "Share"

  Scenario: Confirming sharing
    Given confirmation dialog is shown
    When guest taps "Share"
    Then shared_with_bride should become TRUE
    And toggle should switch to ON
    And gallery_access_logs should record 'share_enabled'

  Scenario: Canceling sharing
    Given confirmation dialog is shown
    When guest taps "Cancel"
    Then shared_with_bride should remain FALSE
    And toggle should stay OFF
    And no log should be recorded

  Scenario: Disabling sharing
    Given shared_with_bride is TRUE
    When guest taps the toggle
    Then shared_with_bride should become FALSE immediately
    And gallery_access_logs should record 'share_disabled'
    And no confirmation needed for disabling

  Scenario: Visual indicator when shared
    Given shared_with_bride is TRUE
    When viewing the album
    Then a "Shared with bride" badge should be visible
```

**Details techniques** :

**Fichiers a creer/modifier** :
- `lib/features/my_wedding/presentation/widgets/share_toggle_widget.dart` - Nouveau
- `lib/features/my_wedding/domain/usecases/toggle_album_sharing_use_case.dart` - Nouveau

---

### S08 : Vue bride des albums guests partages

**Contexte** : La bride doit pouvoir voir les albums des guests qui ont choisi de partager.

**Criteres cles** :
- Liste des albums guests partages pour son mariage
- Navigation vers les medias de chaque album
- Indication du nom du guest pour chaque album
- Possibilite de telecharger (voir S09)
- Vue grille des medias (coherente avec albums bride)
- Lecture video inline

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 6 (US-04.3)

**Complexite** : M (Medium) - Nouvelle section UI, queries RLS

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Bride view of shared guest albums

  Scenario: Viewing list of shared albums
    Given the bride has 3 guests who shared their albums
    When the bride navigates to "Guest Albums" section
    Then 3 albums should be displayed
    And each album should show the guest's name
    And each album should show photo/video count

  Scenario: Empty state when no shared albums
    Given no guests have shared their albums
    When the bride navigates to "Guest Albums" section
    Then empty state should be shown
    And message "No guests have shared their albums yet" should appear

  Scenario: Opening a guest album
    Given guest "Alice" has shared 10 photos
    When the bride taps on Alice's album
    Then a grid of 10 photos should be displayed
    And each photo should be tappable for full view

  Scenario: Viewing guest's video
    Given a guest album contains a video
    When the bride taps on the video thumbnail
    Then video should play inline
    And playback controls should be visible

  Scenario: Albums not shared are hidden
    Given guest "Bob" has NOT shared their album
    When the bride views guest albums list
    Then Bob's album should NOT appear
    And bride should not be able to access Bob's media

  Scenario: Real-time update when guest shares
    Given bride is viewing guest albums list
    When guest "Charlie" enables sharing
    Then Charlie's album should appear in the list
    And no page refresh should be needed
```

**Details techniques** :

**Fichiers a creer/modifier** :
- `lib/features/my_wedding/presentation/pages/guest_albums_page.dart` - Nouveau
- `lib/features/my_wedding/presentation/widgets/guest_album_card.dart` - Nouveau
- `lib/features/my_wedding/domain/usecases/get_shared_guest_albums_use_case.dart` - Nouveau

---

### S09 : Telechargement haute qualite (zip multiple)

**Contexte** : La bride doit pouvoir telecharger les medias en haute qualite, avec zip automatique pour les selections multiples.

**Criteres cles** :
- Download single media (originale, pas compresse)
- Download multiple → zip automatique
- Progress indicator pendant generation zip
- Log dans gallery_access_logs
- Support photos et videos
- Fonctionnel pour medias bride ET guests partages

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 6 (US-04.4)

**Complexite** : M (Medium) - Logic zip, download multiple

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: High quality download with zip for multiple files

  Scenario: Downloading single photo
    Given a bride viewing a photo
    When the bride taps "Download"
    Then the original high-quality photo should be downloaded
    And gallery_access_logs should record 'download'

  Scenario: Downloading single video
    Given a bride viewing a video
    When the bride taps "Download"
    Then the original video file should be downloaded
    And gallery_access_logs should record 'download'

  Scenario: Downloading multiple photos
    Given a bride selects 5 photos
    When the bride taps "Download Selected"
    Then a progress indicator should appear with "Creating zip..."
    And a zip file containing 5 photos should be downloaded
    And gallery_access_logs should record 'download_zip'

  Scenario: Downloading mixed media
    Given a bride selects 3 photos and 2 videos
    When the bride taps "Download Selected"
    Then a zip file containing all 5 files should be created
    And files should retain their original quality

  Scenario: Download from guest album
    Given a bride viewing a shared guest album
    When the bride taps "Download All"
    Then all media from that album should be zipped
    And downloaded to the device

  Scenario: Download progress for large files
    Given downloading a 400MB video
    When download is in progress
    Then progress percentage should be shown
    And download speed should be displayed

  Scenario: Download failure handling
    Given a download in progress
    When the download fails
    Then error message should be shown
    And retry option should be available
```

**Details techniques** :

**Fichiers a creer/modifier** :
- `lib/features/my_wedding/domain/usecases/download_media_use_case.dart` - Nouveau
- `lib/features/my_wedding/presentation/widgets/download_button.dart` - Nouveau
- `lib/core/utils/zip_utils.dart` - Nouveau (si zip cote client)

**Note** : Le zip peut etre genere cote serveur (Edge Function) ou cote client. Cote serveur recommande pour gros fichiers.

---

### S10 : Preparer flag print_ready pour futur

**Contexte** : Le PRD anticipe une future fonctionnalite de commande d'impressions. Le flag print_ready doit etre prepare mais la fonctionnalite desactivee.

**Criteres cles** :
- Colonnes print_ready deja ajoutees en S01 et S03
- UI visible mais desactivee ("Coming soon")
- Toggle pour marquer media comme "pret pour impression"
- Pas de fonctionnalite d'impression reelle
- Stockage de l'intention utilisateur

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 6 (Anticipation)

**Complexite** : S (Small) - UI placeholder

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Print ready flag preparation for future feature

  Scenario: Print option visible but disabled
    Given a user viewing their media
    When the media options are displayed
    Then "Order Print" option should be visible
    And option should be grayed out
    And "Coming soon" badge should be shown

  Scenario: Tapping disabled print option
    Given a user taps "Order Print" (disabled)
    When the tap is registered
    Then a snackbar should say "Print ordering coming soon!"
    And no action should be taken

  Scenario: Marking media as print ready
    Given a bride viewing their media
    When the bride taps "Mark for future print"
    Then print_ready should be set to TRUE
    And a bookmark icon should appear on the media

  Scenario: Unmarking print ready
    Given a media marked as print_ready = TRUE
    When the user taps "Remove from print list"
    Then print_ready should be set to FALSE
    And bookmark icon should disappear

  Scenario: Viewing print ready collection
    Given 5 media marked as print_ready
    When navigating to "Print Ready" section
    Then 5 media should be displayed
    And message "These items will be available when Print ordering launches"
```

**Details techniques** :

**Fichiers a creer/modifier** :
- `lib/features/my_wedding/presentation/widgets/print_ready_badge.dart` - Nouveau
- `lib/features/my_wedding/domain/usecases/toggle_print_ready_use_case.dart` - Nouveau

---

## RLS Policies Summary (Decision D.3)

Toutes les tables de cet Epic ont des RLS policies strictes:

| Table | Policy | Access |
|-------|--------|--------|
| `album_images` (existante) | Existantes | Bride via album ownership |
| `guest_albums` | "Guest manages own album" | Guest CRUD own |
| `guest_albums` | "Bride views shared albums" | Bride SELECT shared only |
| `guest_media` | "Guest manages own media" | Guest CRUD via album |
| `guest_media` | "Bride views shared media" | Bride SELECT shared only |
| `gallery_access_logs` | No public policy | service_role only |

**Principe cle** : **Guest voit UNIQUEMENT ses propres medias**. La bride ne voit que ce qui est explicitement partage.

---

## Risques et Mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Upload video echoue pour gros fichiers | MOYEN - UX degradee | Chunked upload, retry automatique |
| RLS mal configuree expose medias guests | HAUT - Privacy breach | Tests exhaustifs avant deploy |
| Zip generation lente pour beaucoup de fichiers | MOYEN - UX degradee | Generation serveur, progress indicator |
| Thumbnail generation video lente | FAIBLE - UX mineure | Async generation, placeholder |
| Bucket wedding-media pas encore cree | BLOQUANT | Depend de EPIC-06, verifier avant |
| Orphan files in Storage après suppression | MOYEN - Coût storage | Trigger cleanup (voir ci-dessous) |

---

## Storage Cleanup Strategy

> ⚠️ **IMPORTANT**: Quand un `guest_album` est supprimé (CASCADE), les fichiers dans Storage ne sont PAS automatiquement supprimés. Il faut un mécanisme de cleanup.

### Solution: Trigger + Edge Function

**Trigger SQL pour queue de cleanup** :
```sql
-- Migration: 20260128100010_storage_cleanup_trigger
-- Description: Queue orphan files for cleanup when records are deleted

-- Table de queue pour fichiers à supprimer
CREATE TABLE IF NOT EXISTS storage_cleanup_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bucket_id TEXT NOT NULL,
  file_path TEXT NOT NULL,
  queued_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  processed BOOLEAN DEFAULT FALSE NOT NULL
);

CREATE INDEX idx_storage_cleanup_pending
  ON storage_cleanup_queue(processed, queued_at)
  WHERE processed = FALSE;

-- Fonction trigger pour guest_media
CREATE OR REPLACE FUNCTION queue_storage_cleanup()
RETURNS TRIGGER AS $$
BEGIN
  -- Queue les fichiers pour suppression
  INSERT INTO storage_cleanup_queue (bucket_id, file_path)
  VALUES
    ('wedding-media', OLD.storage_path),
    ('wedding-media', OLD.thumbnail_path)
  ON CONFLICT DO NOTHING;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger sur suppression guest_media
CREATE TRIGGER trg_guest_media_cleanup
  AFTER DELETE ON guest_media
  FOR EACH ROW
  EXECUTE FUNCTION queue_storage_cleanup();

-- Trigger sur suppression album_images (bride media)
CREATE TRIGGER trg_album_images_cleanup
  AFTER DELETE ON album_images
  FOR EACH ROW
  EXECUTE FUNCTION queue_storage_cleanup();
```

**Edge Function: process-storage-cleanup** (appelée par pg_cron toutes les heures) :
```typescript
// supabase/functions/process-storage-cleanup/index.ts
import { createClient } from '@supabase/supabase-js';

Deno.serve(async () => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );

  // Get pending cleanup tasks (batch of 100)
  const { data: tasks } = await supabase
    .from('storage_cleanup_queue')
    .select('*')
    .eq('processed', false)
    .limit(100);

  if (!tasks?.length) {
    return new Response(JSON.stringify({ processed: 0 }));
  }

  let processed = 0;
  for (const task of tasks) {
    try {
      // Delete from storage
      const { error } = await supabase.storage
        .from(task.bucket_id)
        .remove([task.file_path]);

      if (!error) {
        // Mark as processed
        await supabase
          .from('storage_cleanup_queue')
          .update({ processed: true })
          .eq('id', task.id);
        processed++;
      }
    } catch (e) {
      console.error(`Cleanup failed for ${task.file_path}:`, e);
    }
  }

  return new Response(JSON.stringify({ processed }));
});
```

**pg_cron job** :
```sql
SELECT cron.schedule(
  'process-storage-cleanup',
  '0 * * * *',  -- Every hour
  $$SELECT net.http_post(
    'https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/process-storage-cleanup',
    '{}',
    '{"Authorization": "Bearer ' || current_setting('supabase.service_role_key') || '"}'
  )$$
);
```

---

## Ordre d'Execution Recommande

```
S01 (album_images enrichi) ──┬── S05 (upload video) ── S06 (legendes)
                              │
S02 (guest_albums) ─────────┬── S03 (guest_media) ── S07 (toggle share)
                              │
                              └── S08 (bride view)

S04 (access_logs) ── Independant

S09 (download) ── Depend S01-S03

S10 (print_ready) ── Depend S01, S03
```

**Ordre sequentiel recommande:**
1. S01 - Enrichir album_images (base pour tout)
2. S02 - Creer guest_albums
3. S03 - Creer guest_media
4. S04 - Creer gallery_access_logs
5. S05 - Upload video avec validation
6. S06 - Saisie legendes
7. S07 - Toggle shared_with_bride
8. S08 - Vue bride albums guests
9. S09 - Telechargement haute qualite
10. S10 - Flag print_ready

---

## References PRD

| Section PRD | Contenu utilise |
|-------------|-----------------|
| Section 6 (APP-04) | Description complete feature |
| US-04.1 | Video upload (max 10 min) |
| US-04.2 | Legendes sur medias |
| US-04.3 | Bride voit albums guests partages |
| US-04.4 | Telechargement haute qualite |
| US-04.7 | Album personnel guest |
| US-04.8 | Guest upload photos/videos |
| US-04.9 | Guest ajoute legendes |
| US-04.10 | Guest voit UNIQUEMENT son album |
| US-04.11 | Opt-in partage avec bride |
| Decision D.3 | RLS policies guest_albums et guest_media |
| Limites fichiers | 20MB photo, 10min/500MB video, 500 chars caption |

---

## Prochaine Etape

Apres validation de cet Epic:
1. Executer `/create-story EPIC-10` pour decomposer en stories individuelles detaillees
2. Verifier que EPIC-06 (bucket wedding-media) est complete
3. Verifier que EPIC-09 (systeme guest) est en cours ou planifie
4. Executer les migrations sur branche de developpement Supabase
5. Implementer les stories Flutter
6. Valider avec tests automatises
7. Merger en production
