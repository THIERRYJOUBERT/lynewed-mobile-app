# Story S01: Create Reels Table with All Fields

## Description
En tant que **developpeur backend**, je veux **creer la table `reels` avec tous les champs necessaires**, afin de **stocker les informations des reels generes et leur statut**.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Reels table creation

  Scenario: Table structure is complete
    Given the database schema
    When the migration create_reels_table is applied
    Then table reels should exist
    And it should have all required columns:
      | column                    | type          | nullable | default   |
      | id                        | UUID          | false    | gen_uuid  |
      | user_id                   | UUID          | false    | -         |
      | wedding_id                | UUID          | false    | -         |
      | creator_type              | VARCHAR(10)   | false    | -         |
      | source_media_ids          | UUID[]        | false    | -         |
      | total_duration_seconds    | INTEGER       | true     | -         |
      | preview_path              | TEXT          | true     | -         |
      | output_path               | TEXT          | true     | -         |
      | status                    | VARCHAR(20)   | false    | 'pending' |
      | is_paid                   | BOOLEAN       | false    | FALSE     |
      | price_cents               | INTEGER       | false    | 0         |
      | purchase_id               | UUID          | true     | -         |
      | error_message             | TEXT          | true     | -         |
      | ffmpeg_log                | TEXT          | true     | -         |
      | expires_at                | TIMESTAMP     | true     | -         |
      | created_at                | TIMESTAMP     | false    | NOW()     |
      | processing_started_at     | TIMESTAMP     | true     | -         |
      | processing_completed_at   | TIMESTAMP     | true     | -         |
      | downloaded_at             | TIMESTAMP     | true     | -         |

  Scenario: Foreign keys are valid
    Given the reels table exists
    Then user_id should reference profiles(id)
    And wedding_id should reference weddings(id)
    And purchase_id should be nullable (FK added in separate migration S01b after EPIC-11)

  Scenario: Indexes are created
    Given the reels table exists
    Then index idx_reels_user should exist on user_id
    And index idx_reels_wedding should exist on wedding_id
    And index idx_reels_status should exist on status (partial: pending, processing, ready)
    And index idx_reels_expires should exist on expires_at (partial: not expired/failed)
    And index idx_reels_created should exist on created_at DESC

  Scenario: Status constraint is enforced
    Given the reels table exists
    When inserting a reel with status 'invalid_status'
    Then the insert should fail with constraint violation
    And only 'pending', 'processing', 'ready', 'downloaded', 'expired', 'failed' should be allowed

  Scenario: Creator type constraint is enforced
    Given the reels table exists
    When inserting a reel with creator_type 'admin'
    Then the insert should fail with constraint violation
    And only 'guest', 'bride' should be allowed

  Scenario: RLS is enabled
    Given the reels table exists
    Then Row Level Security should be enabled
    And no default policies should exist yet (added in S02)
```

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260128001201_create_reels_table.sql`

### A Modifier
- None

## Notes Techniques

### Migration SQL Complete
```sql
-- Migration: 20260128001201_create_reels_table
-- Description: Create reels table for video montage feature (APP-06)
-- Epic: EPIC-12-REELS
-- Story: S01

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
  purchase_id UUID, -- FK added in migration S01b after EPIC-11 completes

  -- Metadonnees
  error_message TEXT,
  ffmpeg_log TEXT,

  -- Timestamps
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  processing_started_at TIMESTAMPTZ,
  processing_completed_at TIMESTAMPTZ,
  downloaded_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_reels_user ON reels(user_id);
CREATE INDEX idx_reels_wedding ON reels(wedding_id);
CREATE INDEX idx_reels_status ON reels(status) WHERE status IN ('pending', 'processing', 'ready');
CREATE INDEX idx_reels_expires ON reels(expires_at) WHERE status NOT IN ('expired', 'failed');
CREATE INDEX idx_reels_created ON reels(created_at DESC);

-- Enable RLS (policies added in S02)
ALTER TABLE reels ENABLE ROW LEVEL SECURITY;

-- Comments
COMMENT ON TABLE reels IS 'Generated video reels from wedding media (APP-06)';
COMMENT ON COLUMN reels.creator_type IS 'guest or bride - determines video access rights (D-14)';
COMMENT ON COLUMN reels.source_media_ids IS 'Array of video IDs from guest_media or album_images';
COMMENT ON COLUMN reels.is_paid IS 'Future: enable paid reels (MVP is free)';
COMMENT ON COLUMN reels.expires_at IS 'Auto-deletion after 7 days';
COMMENT ON COLUMN reels.ffmpeg_log IS 'Debug: Shotstack/FFmpeg processing output';
```

### Rollback SQL
```sql
-- Rollback: 20260128001201_create_reels_table

DROP INDEX IF EXISTS idx_reels_created;
DROP INDEX IF EXISTS idx_reels_expires;
DROP INDEX IF EXISTS idx_reels_status;
DROP INDEX IF EXISTS idx_reels_wedding;
DROP INDEX IF EXISTS idx_reels_user;
DROP TABLE IF EXISTS reels;
```

## Definition of Done
- [ ] Criteres d'acceptance valides
- [ ] Migration applied successfully
- [ ] All columns exist with correct types
- [ ] Constraints work (test INSERT with invalid status/creator_type)
- [ ] Indexes created and visible in schema
- [ ] RLS enabled
- [ ] `flutter analyze --fatal-infos` passe (N/A - DB only)

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances
- EPIC-06: Bucket `wedding-media` must exist (for storage paths)
- EPIC-10: Tables `guest_albums` and `guest_media` must exist (referenced in source_media_ids)

## Stories Dependantes
- S01b: Add FK to purchases (after EPIC-11)
- S02: Add RLS policies
- S06: Edge Function generate-reel
