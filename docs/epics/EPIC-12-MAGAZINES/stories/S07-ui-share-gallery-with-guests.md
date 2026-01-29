# S07 - UI Share Gallery with Guests

> **Epic** : EPIC-12-MAGAZINES
> **Status** : 🔵 Draft
> **Estimation** : 5 points (M)
> **Domaine** : Flutter UI

---

## Description

Permettre a la bride de partager une selection de photos avec les guests du mariage. Les guests peuvent voir les photos partagees dans leur app.

## Dependances

- S05 (gallery multi-select)
- EPIC-09 (guest system)

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Share gallery with wedding guests

  Scenario: Sharing selection via action bar
    Given bride has selected 10 photos
    When bride taps "Share as gallery" in action bar
    Then confirmation modal should appear
    And message "Share 10 photos with your wedding guests?"

  Scenario: Confirming share
    Given share confirmation modal
    When bride taps "Share"
    Then photos should be marked as shared
    And toast "10 photos shared with guests"
    And gallery_access_logs should record 'share_enabled'

  Scenario: Guest viewing shared photos
    Given bride has shared photos
    When guest opens "Shared Gallery" section in their app
    Then guest should see the shared photos
    And photos should be view-only (no edit)
    And download should be available

  Scenario: Bride sees shared badge
    Given photos are shared with guests
    When bride views those photos
    Then a "Shared" badge should appear on photo tiles

  Scenario: Unsharing photos
    Given shared photos
    When bride selects them and taps "Unshare"
    Then photos should no longer be visible to guests
    And gallery_access_logs should record 'share_disabled'
    And "Shared" badge should disappear

  Scenario: Share all from album
    Given bride in guest album view
    When bride taps "Share all photos"
    Then all photos from that album should be shared

  Scenario: Real-time update for guests
    Given guest viewing shared gallery
    When bride shares new photos
    Then new photos should appear for guest
    And no manual refresh needed (Realtime subscription)
```

## Details Techniques

### Data Model

```sql
-- Option 1: Separate share table
CREATE TABLE photo_shares (
  id UUID PRIMARY KEY,
  wedding_id UUID,
  media_type VARCHAR(20),
  media_id UUID,
  shared_by UUID,
  shared_at TIMESTAMP,
  UNIQUE(wedding_id, media_type, media_id)
);

-- Option 2: Add shared flag to existing tables (simpler)
ALTER TABLE album_images ADD COLUMN shared_with_guests BOOLEAN DEFAULT FALSE;
-- guest_media already has shared_with_bride, inverse direction
```

**Decision**: Use separate `photo_shares` table for flexibility.

### UI Components

```
SHARE CONFIRMATION MODAL
┌─────────────────────────────────────┐
│       Share with Guests             │
│                                     │
│  Share 10 photos with your          │
│  wedding guests?                    │
│                                     │
│  They will be able to view and      │
│  download these photos.             │
│                                     │
│      [Cancel]     [Share]           │
└─────────────────────────────────────┘

PHOTO TILE WITH SHARED BADGE
┌─────────────────────────────────────┐
│  [Shared]                           │  ← Small badge top-left
│                                     │
│          [PHOTO]                    │
│                                     │
│                                     │
└─────────────────────────────────────┘

GUEST SHARED GALLERY VIEW
┌─────────────────────────────────────┐
│  Shared by [Bride Name]             │
│  10 photos                          │
│─────────────────────────────────────│
│  ┌─────┬─────┬─────┐               │
│  │     │     │     │               │
│  └─────┴─────┴─────┘               │
│  ┌─────┬─────┬─────┐               │
│  │     │     │     │               │
│  └─────┴─────┴─────┘               │
│─────────────────────────────────────│
│      [Download All]                 │
└─────────────────────────────────────┘
```

### Fichiers a Creer/Modifier

| Fichier | Action |
|---------|--------|
| `lib/features/my_wedding/domain/usecases/share_photos_with_guests_use_case.dart` | Nouveau |
| `lib/features/my_wedding/domain/usecases/unshare_photos_use_case.dart` | Nouveau |
| `lib/features/my_wedding/presentation/dialogs/share_gallery_dialog.dart` | Nouveau |
| `lib/features/my_wedding/presentation/widgets/shared_badge.dart` | Nouveau |
| `lib/features/my_wedding/presentation/pages/guest_shared_gallery_page.dart` | Nouveau (cote guest) |

### Migration SQL (photo_shares table)

```sql
-- Migration: 20260129100007_create_photo_shares
CREATE TABLE IF NOT EXISTS photo_shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID REFERENCES weddings(id) NOT NULL,
  media_type VARCHAR(20) NOT NULL,
  media_id UUID NOT NULL,
  shared_by UUID REFERENCES profiles(id) NOT NULL,
  shared_at TIMESTAMP DEFAULT NOW() NOT NULL,

  CONSTRAINT uq_photo_shares UNIQUE (wedding_id, media_type, media_id),
  CONSTRAINT chk_photo_shares_type CHECK (media_type IN ('album_image', 'guest_media'))
);

CREATE INDEX idx_photo_shares_wedding ON photo_shares(wedding_id, shared_at DESC);

ALTER TABLE photo_shares ENABLE ROW LEVEL SECURITY;

-- Bride can manage shares
CREATE POLICY "Bride manages shares"
ON photo_shares FOR ALL
TO authenticated
USING (shared_by = auth.uid())
WITH CHECK (shared_by = auth.uid());

-- Guests can view shared photos
CREATE POLICY "Guests view shared photos"
ON photo_shares FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM wedding_guests wg
    JOIN weddings w ON w.id = wg.wedding_id
    WHERE w.id = photo_shares.wedding_id
    AND wg.user_id = auth.uid()
  )
);
```

## Tests

- [ ] Share modal avec confirmation
- [ ] Photos marquees comme partagees
- [ ] Badge "Shared" visible
- [ ] Guests voient les photos partagees
- [ ] Unshare retire l'acces guests
- [ ] gallery_access_logs mis a jour
- [ ] Realtime update pour guests

## Notes

- Directions de partage:
  - Guest → Bride: via shared_with_bride dans guest_albums (EPIC-10)
  - Bride → Guests: via photo_shares table (cette story)
- Guests ont acces view + download seulement
- Realtime via Supabase subscription
