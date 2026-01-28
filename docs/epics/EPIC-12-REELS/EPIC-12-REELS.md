# EPIC-12-REELS

> Resume : Generation de reels a partir des videos du mariage (guests et brides)
> Status : 🔵 Draft
> Domaine : Feature / Backend / Edge Functions
> Cree le : 2026-01-28

---

## Contexte

### Pourquoi cet Epic

Cet Epic implemente la fonctionnalite Reels (APP-06) permettant aux utilisateurs de creer des montages video automatises a partir de leurs videos de mariage.

**Decision cle D-14** : Les guests PEUVENT creer des reels avec leurs propres videos uniquement. Cette decision override les conversations precedentes qui mentionnaient "pas d'acces reels" pour les guests.

**Strategie MVP** :
- **Gratuit** dans un premier temps pour tester le marche
- **Architecture prete pour paiement futur** (champs `is_paid`, `price_cents`)
- **FFmpeg server-side** pour le MVP (transitions fade simples)
- **Evolutif** vers Shotstack API ou IA (OpusClip-like) pour V2/V3

### Piliers Techniques Concernes

| Pilier | Implication pour cet Epic |
|--------|---------------------------|
| **Supabase Database** | Table `reels` avec statuts et tracking |
| **Supabase Edge Functions** | `generate-reel` (FFmpeg), `cleanup-expired-reels` |
| **Supabase Storage** | Stockage preview (480p) et output (1080p) dans bucket existant |
| **Flutter/Dart** | UI selection videos, preview, download |
| **FCM Notifications** | Push "Votre reel est pret !" |
| **pg_cron** | Cleanup automatique des reels expires (7 jours) |

### Dependances

| Dependance | Epic | Statut | Impact |
|------------|------|--------|--------|
| Bucket `wedding-media` | EPIC-06 | 🔵 Todo | Stockage des fichiers reel |
| Table `guest_albums` | EPIC-10 | 🔵 Todo | Validation ownership videos guest |
| Table `guest_media` | EPIC-10 | 🔵 Todo | Source videos guest |
| Video upload support | EPIC-10 | 🔵 Todo | Les videos doivent exister pour creer reels |
| Table `purchases` | EPIC-08 | 🔵 Todo | Pour paiement futur |

**Note** : Cet Epic peut etre prepare en parallele mais ne pourra etre teste qu'apres EPIC-10 (Photos/Videos).

---

## Architecture Cible

### Pipeline de Generation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        PIPELINE GENERATION REEL                              │
│                                                                              │
│  1. SELECTION                                                               │
│     User selectionne videos (max 10, max 2min chacune, 10min total)        │
│     ↓                                                                        │
│  2. VALIDATION                                                              │
│     ┌─────────────────────────────────────────────────────────────┐        │
│     │  Guest: TOUTES videos lui appartiennent (guest_media)       │        │
│     │  Bride: Videos sa galerie + guests partages                 │        │
│     │  Duree totale ≤ 10 minutes                                  │        │
│     │  Chaque video ≤ 2 minutes                                   │        │
│     └─────────────────────────────────────────────────────────────┘        │
│     ↓                                                                        │
│  3. CGVU (1ere fois)                                                        │
│     Modal consentement specifique reels (4 checkboxes)                      │
│     ↓                                                                        │
│  4. CREATION RECORD                                                         │
│     INSERT INTO reels (status = 'pending')                                  │
│     ↓                                                                        │
│  5. PROCESSING (Edge Function: generate-reel)                               │
│     ┌─────────────────────────────────────────────────────────────┐        │
│     │  MVP: FFmpeg concatenation + fade transitions (1s)          │        │
│     │  - Download videos from Storage                             │        │
│     │  - Concatenate with crossfade                               │        │
│     │  - Generate preview (480p + watermark "LYNEWED")            │        │
│     │  - Generate output (1080p + logo discret coin inferieur)    │        │
│     │  - Upload both to Storage                                   │        │
│     │  - Update reel status = 'ready'                             │        │
│     └─────────────────────────────────────────────────────────────┘        │
│     ↓                                                                        │
│  6. NOTIFICATION                                                            │
│     Push FCM "Votre reel est pret !"                                        │
│     ↓                                                                        │
│  7. PREVIEW                                                                 │
│     User voit preview basse qualite + watermark                             │
│     ↓                                                                        │
│  8. TELECHARGEMENT                                                          │
│     ┌─────────────────────────────────────────────────────────────┐        │
│     │  - Download haute qualite (1080p)                           │        │
│     │  - Logo Lynewed discret (coin inferieur)                    │        │
│     │  - Marquer downloaded_at                                    │        │
│     │  - (Futur: Paiement si is_paid = TRUE)                      │        │
│     └─────────────────────────────────────────────────────────────┘        │
│     ↓                                                                        │
│  9. CLEANUP (pg_cron daily)                                                 │
│     Suppression automatique apres 7 jours (expires_at)                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Schema Base de Donnees

```sql
CREATE TABLE reels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  wedding_id UUID REFERENCES weddings(id) NOT NULL,

  -- Type de createur (Decision D-14: guests PEUVENT creer reels)
  creator_type VARCHAR(10) CHECK (creator_type IN ('guest', 'bride')) NOT NULL,

  -- Videos source
  source_media_ids UUID[] NOT NULL, -- IDs des videos utilisees
  total_duration_seconds INTEGER,

  -- Fichiers generes
  preview_path TEXT, -- Basse qualite (480p) + watermark
  output_path TEXT,  -- Haute qualite (1080p) + logo discret

  -- Statut
  status VARCHAR(20) DEFAULT 'pending' CHECK (
    status IN ('pending', 'processing', 'ready', 'downloaded', 'expired', 'failed')
  ),

  -- Paiement (futur - MVP gratuit)
  is_paid BOOLEAN DEFAULT FALSE,
  price_cents INTEGER DEFAULT 0, -- 0 = gratuit
  purchase_id UUID REFERENCES purchases(id),

  -- Metadonnees
  error_message TEXT,
  ffmpeg_log TEXT, -- Debug processing

  -- Timestamps
  expires_at TIMESTAMP, -- Auto-suppression apres 7 jours
  created_at TIMESTAMP DEFAULT NOW(),
  processing_started_at TIMESTAMP,
  processing_completed_at TIMESTAMP,
  downloaded_at TIMESTAMP
);

-- Index pour requetes courantes
CREATE INDEX idx_reels_user ON reels(user_id);
CREATE INDEX idx_reels_wedding ON reels(wedding_id);
CREATE INDEX idx_reels_status ON reels(status);
CREATE INDEX idx_reels_expires ON reels(expires_at) WHERE status != 'expired';
```

### FFmpeg Commands (MVP)

```bash
# 1. Concatenation avec fade transitions (1 seconde)
# Input: video1.mp4, video2.mp4, video3.mp4
# Output: concatenated.mp4

# Creer fichier de concatenation
echo "file 'video1.mp4'" > list.txt
echo "file 'video2.mp4'" >> list.txt
echo "file 'video3.mp4'" >> list.txt

# Concatenation basique avec crossfade
ffmpeg -f concat -safe 0 -i list.txt \
  -filter_complex "[0:v]fade=t=out:st=DURATION1-1:d=1[v0]; \
                   [1:v]fade=t=in:st=0:d=1,fade=t=out:st=DURATION2-1:d=1[v1]; \
                   [v0][v1]concat=n=2:v=1:a=0" \
  -c:v libx264 -preset medium -crf 23 \
  output_temp.mp4

# 2. Preview (480p + watermark central)
ffmpeg -i output_temp.mp4 \
  -vf "scale=854:480,drawtext=text='LYNEWED':fontsize=72:fontcolor=white@0.5:x=(w-text_w)/2:y=(h-text_h)/2" \
  -c:v libx264 -preset fast -crf 28 \
  preview.mp4

# 3. Output final (1080p + logo discret coin inferieur droit)
ffmpeg -i output_temp.mp4 -i logo.png \
  -filter_complex "[0:v]scale=1920:1080[v];[v][1:v]overlay=W-w-20:H-h-20" \
  -c:v libx264 -preset medium -crf 20 \
  output.mp4
```

### Affichage @ Instagram Pros (Bride Only)

```dart
// Pour les brides, afficher liste des @ Instagram des pros du mariage
// A copier pour crediter sur les reseaux sociaux

Future<List<String>> getProInstagramHandles(String weddingId) async {
  // Recuperer les pros du mariage via wedding_participants
  final response = await supabase
    .from('wedding_participants')
    .select('professional_id, professional_details!inner(instagram_handle)')
    .eq('wedding_id', weddingId)
    .not('professional_details.instagram_handle', 'is', null);

  return (response as List)
    .map((p) => '@${p['professional_details']['instagram_handle']}')
    .toList();
}

// UI: Bouton "Copier les @ des pros" avec liste
```

---

## Limites

| Limite | Valeur | Raison |
|--------|--------|--------|
| Videos par reel | **10 max** | Performance processing |
| Duree par video | **2 minutes max** | Reels exploitables, eviter videos longues |
| Duree totale reel | **10 minutes max** | Limite raisonnable, cout processing |
| Retention reels | **7 jours** | Eviter cout stockage excessif |
| Format output | **MP4 H.264** | Compatibilite universelle |
| Resolution preview | **480p** | Basse qualite volontaire + watermark |
| Resolution output | **1080p** | Haute qualite pour partage |

---

## Stories

| # | Story | Domaine | Dep. | Criteres cles | Source PRD | Complexite |
|---|-------|---------|------|---------------|------------|------------|
| S01 | Creer table reels avec tous les champs | DB | - | Schema complet, indexes, RLS policies | APP-06 | S |
| S02 | Ajouter RLS policies pour reels | DB | S01 | D.4 policies (user own, bride wedding) | Section D.4 | S |
| S03 | Implementer UI selection videos | Flutter | - | Max 10, max 2min chacune, validation | US-06.1 | M |
| S04 | Valider ownership videos | Flutter/Backend | S03 | Guest=own only, Bride=all shared | D-14 | M |
| S05 | Modal CGVU acceptation reels | Flutter | - | 4 checkboxes, 1ere fois only | Section 11 | S |
| S06 | Creer Edge Function generate-reel | Backend | S01 | FFmpeg MVP, fade transitions | US-06.2 | L |
| S07 | Generer preview (480p + watermark) | Backend | S06 | Watermark "LYNEWED" central | US-06.2 | M |
| S08 | Generer output final (1080p + logo) | Backend | S06 | Logo discret coin inferieur | US-06.3 | M |
| S09 | Envoyer notification reel pret | Backend | S06 | Push FCM | US-06.6 | S |
| S10 | Implementer download feature | Flutter | S08 | Download haute qualite, track downloaded_at | US-06.3 | M |
| S11 | Afficher @ Instagram pros (bride only) | Flutter | - | Bouton copier, liste handles | US-06.8 | S |
| S12 | Creer pg_cron job cleanup-expired-reels | Backend | S01 | Suppression 7 jours | Pipeline | S |

---

## Detail des Stories

### S01 : Creer table reels avec tous les champs

**Criteres cles** :
- Table `reels` creee avec schema complet (voir Architecture)
- Colonnes: id, user_id, wedding_id, creator_type, source_media_ids, etc.
- Indexes sur user_id, wedding_id, status, expires_at
- Champs paiement prepares (is_paid, price_cents, purchase_id)
- Champ error_message pour debug

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 8 (APP-06)

**Complexite** : S (Small) - Table standard avec FK

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Reels table creation

  Scenario: Table structure is complete
    Given the database schema
    When the migration create_reels_table is applied
    Then table reels should exist
    And it should have all required columns:
      | column                    | type          | nullable |
      | id                        | UUID          | false    |
      | user_id                   | UUID          | false    |
      | wedding_id                | UUID          | false    |
      | creator_type              | VARCHAR(10)   | false    |
      | source_media_ids          | UUID[]        | false    |
      | total_duration_seconds    | INTEGER       | true     |
      | preview_path              | TEXT          | true     |
      | output_path               | TEXT          | true     |
      | status                    | VARCHAR(20)   | false    |
      | is_paid                   | BOOLEAN       | false    |
      | price_cents               | INTEGER       | false    |
      | error_message             | TEXT          | true     |
      | expires_at                | TIMESTAMP     | true     |
      | downloaded_at             | TIMESTAMP     | true     |

  Scenario: Foreign keys are valid
    Given the reels table exists
    Then user_id should reference profiles(id)
    And wedding_id should reference weddings(id)
    And purchase_id should reference purchases(id)

  Scenario: Status constraint is enforced
    Given the reels table exists
    When inserting a reel with status 'invalid_status'
    Then the insert should fail with constraint violation
    And only 'pending', 'processing', 'ready', 'downloaded', 'expired', 'failed' should be allowed

  Scenario: Creator type constraint is enforced
    Given the reels table exists
    When inserting a reel with creator_type 'admin'
    Then the insert should fail
    And only 'guest', 'bride' should be allowed
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128001201_create_reels_table
-- Description: Create reels table for video montage feature (APP-06)

CREATE TABLE IF NOT EXISTS reels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  wedding_id UUID REFERENCES weddings(id) NOT NULL,

  -- Type de createur (D-14: guests CAN create reels)
  creator_type VARCHAR(10) NOT NULL,
  CONSTRAINT chk_creator_type CHECK (creator_type IN ('guest', 'bride')),

  -- Videos source (array of guest_media or album_images IDs)
  source_media_ids UUID[] NOT NULL,
  total_duration_seconds INTEGER,

  -- Fichiers generes
  preview_path TEXT,
  output_path TEXT,

  -- Statut
  status VARCHAR(20) NOT NULL DEFAULT 'pending',
  CONSTRAINT chk_reel_status CHECK (
    status IN ('pending', 'processing', 'ready', 'downloaded', 'expired', 'failed')
  ),

  -- Paiement (futur - MVP gratuit)
  is_paid BOOLEAN NOT NULL DEFAULT FALSE,
  price_cents INTEGER NOT NULL DEFAULT 0,
  purchase_id UUID REFERENCES purchases(id),

  -- Metadonnees
  error_message TEXT,
  ffmpeg_log TEXT,

  -- Timestamps
  expires_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  processing_started_at TIMESTAMP,
  processing_completed_at TIMESTAMP,
  downloaded_at TIMESTAMP
);

-- Indexes
CREATE INDEX idx_reels_user ON reels(user_id);
CREATE INDEX idx_reels_wedding ON reels(wedding_id);
CREATE INDEX idx_reels_status ON reels(status) WHERE status IN ('pending', 'processing', 'ready');
CREATE INDEX idx_reels_expires ON reels(expires_at) WHERE status NOT IN ('expired', 'failed');
CREATE INDEX idx_reels_created ON reels(created_at DESC);

-- Enable RLS
ALTER TABLE reels ENABLE ROW LEVEL SECURITY;

-- Comments
COMMENT ON TABLE reels IS 'Generated video reels from wedding media (APP-06)';
COMMENT ON COLUMN reels.creator_type IS 'guest or bride - determines video access rights';
COMMENT ON COLUMN reels.is_paid IS 'Future: enable paid reels (MVP is free)';
COMMENT ON COLUMN reels.expires_at IS 'Auto-deletion after 7 days';
```

**Rollback** :
```sql
-- Rollback: 20260128001201_create_reels_table

DROP INDEX IF EXISTS idx_reels_created;
DROP INDEX IF EXISTS idx_reels_expires;
DROP INDEX IF EXISTS idx_reels_status;
DROP INDEX IF EXISTS idx_reels_wedding;
DROP INDEX IF EXISTS idx_reels_user;
DROP TABLE IF EXISTS reels;
```

---

### S02 : Ajouter RLS policies pour reels

**Criteres cles** :
- User peut CRUD ses propres reels
- Bride peut voir les reels de son mariage (tous creators)
- Guest ne voit que SES reels
- Service role peut tout (pour Edge Functions)

**Source** : MISSION-01-EVOLUTIONS-2026.md Section D.4

**Complexite** : S (Small) - Policies standard

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: RLS policies for reels table

  Scenario: User can manage own reels
    Given a user with user_id 'user-123'
    When they create a reel with user_id 'user-123'
    Then the insert should succeed
    And they should be able to SELECT that reel
    And they should be able to UPDATE that reel
    And they should be able to DELETE that reel

  Scenario: User cannot access other user's reels
    Given user-A has created a reel
    When user-B tries to SELECT that reel
    Then they should receive 0 rows

  Scenario: Bride can view all reels from her wedding
    Given a bride owns wedding 'wedding-456'
    And guest-A has created a reel for wedding-456
    When the bride queries reels for wedding-456
    Then she should see guest-A's reel (read-only)
    But she should NOT be able to UPDATE or DELETE it

  Scenario: Guest cannot view other guest's reels
    Given guest-A and guest-B are in the same wedding
    And guest-A has created a reel
    When guest-B queries reels
    Then guest-B should NOT see guest-A's reel

  Scenario: Service role bypasses RLS
    Given the service_role key
    When querying all reels
    Then all reels should be returned (for Edge Functions)
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128001202_add_reels_rls_policies
-- Description: Add RLS policies for reels table (Section D.4)

-- Policy 1: User can manage their own reels
CREATE POLICY "User manages own reels"
ON reels FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Policy 2: Bride can view all reels from her wedding (read-only)
CREATE POLICY "Bride views wedding reels"
ON reels FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM weddings w
    WHERE w.id = reels.wedding_id
    AND w.bride_profile_id = auth.uid()
  )
);

-- Note: No DELETE/UPDATE for bride on other users' reels
-- The "User manages own reels" policy handles the user's own reels

-- Comments
COMMENT ON POLICY "User manages own reels" ON reels IS 'Users can CRUD their own reels only';
COMMENT ON POLICY "Bride views wedding reels" ON reels IS 'Bride can view (not modify) all reels from her wedding';
```

**Rollback** :
```sql
-- Rollback: 20260128001202_add_reels_rls_policies

DROP POLICY IF EXISTS "Bride views wedding reels" ON reels;
DROP POLICY IF EXISTS "User manages own reels" ON reels;
```

---

### S03 : Implementer UI selection videos

**Criteres cles** :
- Affichage grid de videos disponibles
- Selection multiple avec compteur (X/10)
- Validation max 10 videos
- Validation max 2 minutes par video
- Validation max 10 minutes total
- Preview de l'ordre des videos (drag & drop)
- Bouton "Creer mon reel" desactive si invalide

**Source** : MISSION-01-EVOLUTIONS-2026.md US-06.1

**Complexite** : M (Medium) - UI complexe avec validation

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Video selection UI for reels

  Scenario: Display available videos
    Given a user with 5 videos in their gallery
    When they open the reel creation screen
    Then they should see all 5 videos in a grid
    And each video should show duration and thumbnail

  Scenario: Select videos with limit
    Given a user viewing video selection
    When they select 10 videos
    Then the counter should show "10/10"
    And attempting to select more should show "Maximum 10 videos reached"

  Scenario: Validate individual video duration
    Given a video with duration 150 seconds (2.5 min)
    When the user tries to select it
    Then selection should be blocked
    And message "Video exceeds 2 minute limit" should appear

  Scenario: Validate total duration
    Given 6 videos selected totaling 9 minutes
    And another video of 2 minutes available
    When user tries to select the 2-minute video
    Then selection should be blocked
    And message "Total duration would exceed 10 minutes" should appear

  Scenario: Reorder selected videos
    Given videos A, B, C selected in that order
    When user drags video C to position 1
    Then the order should become C, A, B
    And preview should update accordingly

  Scenario: Create button state
    Given 0 videos selected
    Then "Create reel" button should be disabled

    Given 3 valid videos selected
    Then "Create reel" button should be enabled
```

**Chemins fichiers** :
- `lib/features/reels/presentation/pages/video_selection_page.dart`
- `lib/features/reels/presentation/widgets/video_grid.dart`
- `lib/features/reels/presentation/widgets/selection_counter.dart`
- `lib/features/reels/domain/entities/video_selection.dart`

---

### S04 : Valider ownership videos

**Criteres cles** :
- Guest peut UNIQUEMENT utiliser SES propres videos (guest_media)
- Bride peut utiliser ses videos + videos guests partagees (shared_with_bride = TRUE)
- Validation cote serveur (Edge Function) avant processing
- Rejection claire avec message d'erreur

**Source** : MISSION-01-EVOLUTIONS-2026.md Decision D-14

**Complexite** : M (Medium) - Logique metier complexe

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Video ownership validation

  Scenario: Guest can only use own videos
    Given a guest with user_id 'guest-123'
    And they own videos [vid-1, vid-2] in guest_media
    And another guest owns video [vid-3]
    When guest-123 tries to create reel with [vid-1, vid-3]
    Then validation should fail
    And error "You can only use your own videos" should appear
    And vid-3 should be highlighted as invalid

  Scenario: Guest creates reel with own videos
    Given a guest with user_id 'guest-123'
    And they own videos [vid-1, vid-2, vid-3]
    When they create a reel with [vid-1, vid-2]
    Then validation should pass
    And reel creation should proceed

  Scenario: Bride can use own videos
    Given a bride with wedding 'wedding-456'
    And she has videos [vid-1, vid-2] in album_images
    When she creates a reel with [vid-1, vid-2]
    Then validation should pass

  Scenario: Bride can use shared guest videos
    Given a bride with wedding 'wedding-456'
    And guest-A has shared videos [vid-3, vid-4] (shared_with_bride = TRUE)
    When bride creates a reel with [vid-1, vid-3, vid-4]
    Then validation should pass
    And reel should be created with all 3 videos

  Scenario: Bride cannot use unshared guest videos
    Given a bride with wedding 'wedding-456'
    And guest-B has unshared video [vid-5] (shared_with_bride = FALSE)
    When bride tries to include vid-5
    Then validation should fail
    And error "This video has not been shared with you" should appear

  Scenario: Server-side validation in Edge Function
    Given a reel creation request
    When the Edge Function receives source_media_ids
    Then it should verify ownership for each ID
    And reject with 403 if any video is not authorized
```

**Details techniques** :

```dart
// lib/features/reels/domain/usecases/validate_video_ownership.dart

class ValidateVideoOwnershipUseCase {
  Future<ValidationResult> execute({
    required String userId,
    required String userRole, // 'guest' or 'bride'
    required String weddingId,
    required List<String> mediaIds,
  }) async {
    if (userRole == 'guest') {
      return _validateGuestOwnership(userId, mediaIds);
    } else {
      return _validateBrideAccess(userId, weddingId, mediaIds);
    }
  }

  Future<ValidationResult> _validateGuestOwnership(
    String userId,
    List<String> mediaIds,
  ) async {
    // All videos must be in guest_media with guest_user_id = userId
    final ownedMedia = await supabase
      .from('guest_media')
      .select('id')
      .in_('id', mediaIds)
      .eq('album_id', /* subquery for guest's album */)
      .count();

    if (ownedMedia.count != mediaIds.length) {
      return ValidationResult.failure(
        'You can only use your own videos',
        invalidIds: /* IDs not owned */,
      );
    }
    return ValidationResult.success();
  }
}
```

---

### S05 : Modal CGVU acceptation reels

**Criteres cles** :
- Modal affichee uniquement la 1ere fois
- 4 checkboxes obligatoires (voir PRD Section 11)
- Enregistrement dans `cgvu_acceptances` avec IP, user_agent, device_info
- Bouton "Continuer" desactive tant que pas tout coche
- Ne plus afficher apres acceptation

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 11 (CGVU)

**Complexite** : S (Small) - Modal standard

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: CGVU acceptance modal for reels

  Scenario: First time creating a reel
    Given a user who has never created a reel
    When they tap "Create reel"
    Then the CGVU modal should appear
    And it should contain 4 checkboxes:
      | Checkbox | Text                                        |
      | 1        | ACCEPTANCE OF TERMS                         |
      | 2        | OWNERSHIP OF CONTENT                        |
      | 3        | GENERATED CONTENT                           |
      | 4        | DISTRIBUTION RESPONSIBILITY                 |
    And "Continue" button should be disabled

  Scenario: All checkboxes required
    Given the CGVU modal is displayed
    When user checks only 3 of 4 checkboxes
    Then "Continue" button should remain disabled

    When user checks all 4 checkboxes
    Then "Continue" button should become enabled

  Scenario: Acceptance is logged
    Given the user has checked all 4 checkboxes
    When they tap "Continue"
    Then a record should be inserted in cgvu_acceptances with:
      | field         | value                    |
      | user_id       | current user ID          |
      | cgvu_type     | 'reel'                   |
      | cgvu_version  | '1.0'                    |
      | ip_address    | user's IP                |
      | user_agent    | app user agent           |
      | device_info   | OS, app version, etc.    |
      | accepted_at   | current timestamp        |

  Scenario: Modal not shown after acceptance
    Given a user who has accepted CGVU for reels
    When they create another reel
    Then the CGVU modal should NOT appear
    And they should proceed directly to video selection

  Scenario: CGVU version tracking
    Given CGVU version changes from '1.0' to '1.1'
    When a user who accepted '1.0' creates a new reel
    Then the CGVU modal should appear again (new version)
```

**Chemins fichiers** :
- `lib/features/reels/presentation/widgets/reel_cgvu_modal.dart`
- `lib/features/reels/domain/usecases/check_cgvu_acceptance.dart`
- `lib/features/reels/data/repositories/cgvu_repository_impl.dart`

---

### S06 : Creer Edge Function generate-reel

**Criteres cles** :
- Edge Function `generate-reel` deployee
- Input: reel_id (UUID)
- Download videos depuis Storage
- Concatenation avec FFmpeg + fade 1s
- Upload preview + output vers Storage
- Update status: pending → processing → ready/failed
- Gestion des erreurs avec message dans error_message
- Timeout raisonnable (max 10 min processing)

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 8 (Pipeline)

**Complexite** : L (Large) - FFmpeg integration complexe

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Edge Function generate-reel

  Scenario: Successful reel generation
    Given a reel with id 'reel-123' and status 'pending'
    And source_media_ids contains 3 valid video UUIDs
    When the Edge Function is invoked with reel_id 'reel-123'
    Then status should change to 'processing'
    And processing_started_at should be set
    And videos should be downloaded from Storage
    And FFmpeg should concatenate with 1s fade transitions
    And preview (480p + watermark) should be generated
    And output (1080p + logo) should be generated
    And both files should be uploaded to Storage
    And preview_path and output_path should be updated
    And status should change to 'ready'
    And processing_completed_at should be set
    And expires_at should be set to NOW() + 7 days

  Scenario: Invalid reel ID
    When the Edge Function is invoked with invalid reel_id
    Then it should return 404 "Reel not found"

  Scenario: Videos not found in Storage
    Given a reel with source_media_ids containing invalid paths
    When the Edge Function processes it
    Then status should change to 'failed'
    And error_message should contain "Video not found"

  Scenario: FFmpeg processing fails
    Given a reel with corrupted video file
    When FFmpeg fails during processing
    Then status should change to 'failed'
    And error_message should contain FFmpeg error
    And ffmpeg_log should contain full output

  Scenario: Timeout handling
    Given a reel with extremely large videos
    When processing exceeds 10 minutes
    Then the function should abort
    And status should change to 'failed'
    And error_message should contain "Processing timeout"
```

**Details techniques** :

```typescript
// Edge Function: generate-reel
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

interface GenerateReelRequest {
  reel_id: string;
}

Deno.serve(async (req: Request) => {
  const { reel_id } = await req.json() as GenerateReelRequest;

  // 1. Fetch reel record
  const { data: reel, error } = await supabase
    .from('reels')
    .select('*')
    .eq('id', reel_id)
    .single();

  if (error || !reel) {
    return new Response(JSON.stringify({ error: 'Reel not found' }), {
      status: 404,
      headers: { 'Content-Type': 'application/json' }
    });
  }

  // 2. Update status to processing
  await supabase.from('reels').update({
    status: 'processing',
    processing_started_at: new Date().toISOString()
  }).eq('id', reel_id);

  try {
    // 3. Download videos from Storage
    const videos = await downloadVideos(reel.source_media_ids);

    // 4. Generate reel with FFmpeg
    const { preview, output, duration } = await generateReelFFmpeg(videos);

    // 5. Upload to Storage
    const previewPath = `reels/${reel_id}/preview.mp4`;
    const outputPath = `reels/${reel_id}/output.mp4`;

    await uploadToStorage(previewPath, preview);
    await uploadToStorage(outputPath, output);

    // 6. Update reel record
    await supabase.from('reels').update({
      status: 'ready',
      preview_path: previewPath,
      output_path: outputPath,
      total_duration_seconds: duration,
      processing_completed_at: new Date().toISOString(),
      expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
    }).eq('id', reel_id);

    // 7. Send notification (trigger via another function or queue)
    await notifyReelReady(reel.user_id, reel_id);

    return new Response(JSON.stringify({ success: true, reel_id }), {
      headers: { 'Content-Type': 'application/json' }
    });

  } catch (error) {
    // Handle failure
    await supabase.from('reels').update({
      status: 'failed',
      error_message: error.message,
      ffmpeg_log: error.ffmpegLog || null
    }).eq('id', reel_id);

    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
});
```

---

### S07 : Generer preview (480p + watermark)

**Criteres cles** :
- Resolution 480p (854x480)
- Watermark "LYNEWED" central, blanc semi-transparent
- Qualite basse (CRF 28)
- Format MP4 H.264

**Source** : MISSION-01-EVOLUTIONS-2026.md US-06.2

**Complexite** : M (Medium) - FFmpeg specifique

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Preview generation with watermark

  Scenario: Preview resolution is 480p
    Given a reel is being processed
    When the preview is generated
    Then the resolution should be 854x480 (16:9)
    Or 480p equivalent for other aspect ratios

  Scenario: Watermark is centered
    Given the preview video
    When viewed
    Then "LYNEWED" text should be centered horizontally
    And centered vertically
    And font size should be 72px
    And color should be white with 50% opacity

  Scenario: Preview quality is intentionally low
    Given the preview video
    Then file size should be smaller than output
    And quality should be noticeably lower (CRF 28)
    And this is intentional to encourage download of full quality

  Scenario: Preview is playable
    Given a generated preview
    When user plays it in the app
    Then it should play smoothly
    And watermark should be visible throughout
```

**FFmpeg command** :
```bash
ffmpeg -i input.mp4 \
  -vf "scale=854:480,drawtext=text='LYNEWED':fontsize=72:fontcolor=white@0.5:x=(w-text_w)/2:y=(h-text_h)/2" \
  -c:v libx264 -preset fast -crf 28 \
  -c:a aac -b:a 128k \
  preview.mp4
```

---

### S08 : Generer output final (1080p + logo)

**Criteres cles** :
- Resolution 1080p (1920x1080)
- Logo Lynewed coin inferieur droit, discret
- Haute qualite (CRF 20)
- Format MP4 H.264

**Source** : MISSION-01-EVOLUTIONS-2026.md US-06.3

**Complexite** : M (Medium) - FFmpeg specifique

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Final output generation with logo

  Scenario: Output resolution is 1080p
    Given a reel is being processed
    When the final output is generated
    Then the resolution should be 1920x1080 (16:9)
    Or 1080p equivalent maintaining aspect ratio

  Scenario: Logo placement is discreet
    Given the output video
    When viewed
    Then Lynewed logo should be in bottom-right corner
    And positioned 20px from edges
    And size should be small (not intrusive)
    And opacity should be subtle

  Scenario: Output quality is high
    Given the final output
    Then quality should be suitable for social media sharing
    And compression should be CRF 20 (high quality)
    And video should look professional

  Scenario: Output is shareable
    Given a generated output
    Then file size should be reasonable for sharing
    And format should be compatible with Instagram, TikTok, etc.
```

**FFmpeg command** :
```bash
ffmpeg -i input.mp4 -i logo.png \
  -filter_complex "[0:v]scale=1920:1080[v];[v][1:v]overlay=W-w-20:H-h-20" \
  -c:v libx264 -preset medium -crf 20 \
  -c:a aac -b:a 192k \
  output.mp4
```

---

### S09 : Envoyer notification reel pret

**Criteres cles** :
- Push notification FCM quand status = 'ready'
- Titre: "Votre reel est pret !"
- Body: "Votre montage video est termine. Telechargez-le maintenant."
- Deep link vers page reel
- Insert dans notifications_outbox existante

**Source** : MISSION-01-EVOLUTIONS-2026.md Pipeline etape 6

**Complexite** : S (Small) - Integration FCM existant

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Notification when reel is ready

  Scenario: Push notification is sent
    Given a reel has finished processing successfully
    And status has changed to 'ready'
    When the notification trigger fires
    Then a push notification should be sent via FCM
    And the user should receive it even if app is closed

  Scenario: Notification content is correct
    Given a push notification for reel completion
    Then title should be "Votre reel est pret !"
    And body should be "Votre montage video est termine. Telechargez-le maintenant."
    And data should contain reel_id for deep linking

  Scenario: Tapping notification opens reel
    Given the user receives the notification
    When they tap on it
    Then the app should open
    And navigate to the reel detail/download page

  Scenario: Notification is logged
    Given a reel completion notification
    Then it should be inserted into notifications_outbox
    And processed by the existing FCM delivery system
```

**Details techniques** :

```sql
-- Insert notification into outbox (existing pattern)
INSERT INTO notifications_outbox (user_id, event_type, payload, status)
VALUES (
  reel.user_id,
  'reel_ready',
  jsonb_build_object(
    'reel_id', reel.id,
    'title', 'Votre reel est pret !',
    'body', 'Votre montage video est termine. Telechargez-le maintenant.'
  ),
  'pending'
);
```

---

### S10 : Implementer download feature

**Criteres cles** :
- Bouton "Telecharger" visible sur page reel
- Download du fichier output (1080p + logo)
- Save vers galerie device
- Update downloaded_at timestamp
- Affichage progression download
- Gestion erreur reseau

**Source** : MISSION-01-EVOLUTIONS-2026.md US-06.3

**Complexite** : M (Medium) - Download + permissions

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Download reel in high quality

  Scenario: Download button is visible
    Given a reel with status 'ready'
    When user views the reel detail page
    Then "Download" button should be visible
    And it should indicate "High quality (1080p)"

  Scenario: Download starts successfully
    Given user taps "Download"
    When download begins
    Then a progress indicator should appear
    And it should show percentage or bytes downloaded

  Scenario: Save to device gallery
    Given download completes successfully
    When file is saved
    Then it should appear in device photo gallery
    And toast "Reel saved to gallery" should appear

  Scenario: Track download timestamp
    Given a successful download
    Then reels.downloaded_at should be updated
    And it should contain the current timestamp

  Scenario: Handle network error
    Given download is in progress
    When network connection is lost
    Then download should pause/fail gracefully
    And user should see "Download failed. Retry?"
    And retry should resume where left off if possible

  Scenario: Permissions handling
    Given user taps "Download"
    When storage permission is not granted
    Then permission request should appear
    And download should start after permission granted
```

**Chemins fichiers** :
- `lib/features/reels/presentation/pages/reel_detail_page.dart`
- `lib/features/reels/presentation/widgets/download_button.dart`
- `lib/features/reels/domain/usecases/download_reel.dart`

---

### S11 : Afficher @ Instagram pros (bride only)

**Criteres cles** :
- Section visible uniquement pour bride
- Liste des @ Instagram des pros du mariage
- Bouton "Copier tout" pour copier la liste
- Explication: "Tag these professionals when sharing your reel"

**Source** : MISSION-01-EVOLUTIONS-2026.md US-06.8

**Complexite** : S (Small) - Query + UI simple

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Display pro Instagram handles for bride

  Scenario: Section visible only for bride
    Given a bride viewing her reel
    Then "Tag the professionals" section should be visible
    And it should list Instagram handles of pros in wedding

    Given a guest viewing their reel
    Then "Tag the professionals" section should NOT be visible

  Scenario: Display all pro handles
    Given a wedding with 3 pros:
      | Pro          | Instagram Handle |
      | Photographer | photo_pro        |
      | Florist      | flower_artist    |
      | DJ           | dj_beats         |
    When bride views the section
    Then she should see:
      | @photo_pro     |
      | @flower_artist |
      | @dj_beats      |

  Scenario: Handle pros without Instagram
    Given a wedding with 2 pros, one without Instagram
    When bride views the section
    Then only the pro with Instagram should be listed

  Scenario: Copy all handles
    Given the list of Instagram handles
    When bride taps "Copy all"
    Then all handles should be copied to clipboard
    And toast "Copied to clipboard" should appear

  Scenario: Empty state
    Given a wedding with no pros (or none with Instagram)
    When bride views the section
    Then message "No professional Instagram handles found" should appear
```

**Chemins fichiers** :
- `lib/features/reels/presentation/widgets/pro_instagram_section.dart`
- `lib/features/reels/domain/usecases/get_wedding_pro_instagrams.dart`

---

### S12 : Creer pg_cron job cleanup-expired-reels

**Criteres cles** :
- pg_cron job execute quotidiennement
- Supprime fichiers Storage (preview + output)
- Met a jour status = 'expired'
- Ne supprime pas les records (historique)
- Log des suppressions

**Source** : MISSION-01-EVOLUTIONS-2026.md Pipeline etape 9

**Complexite** : S (Small) - Cron standard

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Automatic cleanup of expired reels

  Scenario: Daily cron job runs
    Given the pg_cron extension is enabled
    When midnight passes
    Then the cleanup-expired-reels job should execute

  Scenario: Expired reels are cleaned up
    Given a reel with expires_at = 8 days ago
    And status = 'ready'
    When the cleanup job runs
    Then preview_path file should be deleted from Storage
    And output_path file should be deleted from Storage
    And status should be updated to 'expired'
    And the reel record should remain (for history)

  Scenario: Non-expired reels are not affected
    Given a reel with expires_at = 3 days from now
    When the cleanup job runs
    Then the reel should remain unchanged

  Scenario: Already expired reels are skipped
    Given a reel with status = 'expired'
    When the cleanup job runs
    Then it should be skipped (already processed)

  Scenario: Failed reels cleanup
    Given a reel with status = 'failed'
    And it was created 8 days ago
    When the cleanup job runs
    Then any partial files should be deleted
    And status should remain 'failed'
```

**Details techniques** :

```sql
-- Migration: 20260128001212_create_cleanup_reels_cron
-- Description: Create pg_cron job for expired reels cleanup

-- Ensure pg_cron is enabled
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Create cleanup function
CREATE OR REPLACE FUNCTION cleanup_expired_reels()
RETURNS void AS $$
DECLARE
  reel_record RECORD;
BEGIN
  FOR reel_record IN
    SELECT id, preview_path, output_path
    FROM reels
    WHERE expires_at < NOW()
    AND status IN ('ready', 'downloaded')
  LOOP
    -- Note: Storage deletion must be done via Edge Function
    -- This function marks for deletion, Edge Function does actual cleanup

    UPDATE reels
    SET
      status = 'expired',
      preview_path = NULL,
      output_path = NULL
    WHERE id = reel_record.id;

    -- Log the cleanup
    RAISE NOTICE 'Marked reel % as expired', reel_record.id;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Schedule daily at 3 AM UTC
SELECT cron.schedule(
  'cleanup-expired-reels',
  '0 3 * * *',
  'SELECT cleanup_expired_reels();'
);

COMMENT ON FUNCTION cleanup_expired_reels IS 'Marks expired reels (7+ days old) for cleanup';
```

**Edge Function for actual file deletion** :
```typescript
// Edge Function: cleanup-reel-files
// Called by cron or as part of cleanup_expired_reels

async function deleteReelFiles(reelId: string) {
  const { data: reel } = await supabase
    .from('reels')
    .select('preview_path, output_path')
    .eq('id', reelId)
    .single();

  if (reel.preview_path) {
    await supabase.storage.from('wedding-media').remove([reel.preview_path]);
  }
  if (reel.output_path) {
    await supabase.storage.from('wedding-media').remove([reel.output_path]);
  }
}
```

---

## Risques et Mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| FFmpeg non disponible sur Edge Runtime | CRITIQUE - Feature bloquee | Utiliser Supabase Edge Functions avec Deno + WASM FFmpeg ou service externe |
| Processing timeout (videos longues) | HAUT - Reels incomplets | Limite 10 min total, timeout 10 min, queue processing |
| Cout stockage reels | MOYEN - Budget | Expiration 7 jours, compression aggressive preview |
| Videos corrompues | MOYEN - Echecs | Validation format avant processing, messages d'erreur clairs |
| RLS trop permissive | HAUT - Fuite donnees | Tests exhaustifs policies, review adversariale |
| CGVU non acceptee | FAIBLE - Blocage legal | Modal obligatoire, logs complets |

---

## RLS Policies Summary

| Table | Policy | Access |
|-------|--------|--------|
| `reels` | "User manages own reels" | User can CRUD own reels |
| `reels` | "Bride views wedding reels" | Bride can view (not modify) all reels from her wedding |

---

## Ordre d'Execution Recommande

```
S01 (table reels) ──> S02 (RLS policies)
                  │
                  └──> S06 (Edge Function) ──> S07 (preview) ──> S08 (output)
                                           │
                                           └──> S09 (notification)
                                           │
                                           └──> S12 (cleanup cron)

S03 (UI selection) ──> S04 (ownership validation)

S05 (CGVU modal) ── Independant

S10 (download) ── Depend de S08

S11 (Instagram pros) ── Independant
```

**Ordre sequentiel recommande:**
1. S01 - Table reels
2. S02 - RLS policies
3. S05 - CGVU modal (peut etre fait en parallele)
4. S03 - UI selection videos
5. S04 - Validation ownership
6. S06 - Edge Function generate-reel
7. S07 - Preview generation
8. S08 - Output generation
9. S09 - Notification
10. S10 - Download feature
11. S11 - Instagram pros
12. S12 - Cleanup cron

---

## References PRD

| Section PRD | Contenu utilise |
|-------------|-----------------|
| Section 8 (APP-06) | User Stories US-06.x, Pipeline generation |
| Section 11 | CGVU Reel Generation (4 checkboxes) |
| Section 14 | Decision D-14 (Guests CAN create reels) |
| Section D.4 | RLS policies pour reels |
| Annexe B | Edge Functions a creer (generate-reel, cleanup-expired-reels) |

---

## Prochaine Etape

Apres validation de cet Epic:
1. Executer `/create-story EPIC-12` pour decomposer en stories individuelles
2. Attendre completion EPIC-10 (Photos/Videos) pour les tables dependantes
3. Configurer FFmpeg sur Edge Runtime (ou service alternatif)
4. Developper et tester sur branche Supabase
5. Valider avec tests automatises
6. Merger en production
