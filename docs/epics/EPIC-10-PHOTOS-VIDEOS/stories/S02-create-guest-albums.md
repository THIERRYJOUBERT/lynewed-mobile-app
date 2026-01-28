# Story S02: Creer table guest_albums avec RLS

## Description
En tant que **guest invite a un mariage**, je veux **avoir mon propre album photo separe de celui de la bride**, afin de **pouvoir uploader et gerer mes photos sans melanger avec les albums de la mariee**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the database schema When the migration create_guest_albums is applied Then table guest_albums should exist with columns: id (UUID PK), wedding_id (FK weddings), guest_user_id (FK profiles), shared_with_bride (BOOLEAN), created_at, updated_at
- [ ] Given a guest with user_id 'guest-123' in wedding 'wedding-456' When the guest creates an album for wedding 'wedding-456' Then the album should be created successfully And shared_with_bride should be FALSE by default
- [ ] Given guest 'guest-123' already has an album in wedding 'wedding-456' When the guest tries to create another album in 'wedding-456' Then the insert should fail with unique constraint violation
- [ ] Given guest-A and guest-B both have albums in wedding 'wedding-456' When guest-A queries guest_albums Then guest-A should only see their own album And guest-A should NOT see guest-B's album
- [ ] Given guest-A has shared_with_bride = TRUE And guest-B has shared_with_bride = FALSE When the bride queries guest_albums for her wedding Then the bride should see guest-A's album And the bride should NOT see guest-B's album
- [ ] Given guest 'guest-123' in wedding 'wedding-456' When the guest tries to view albums from wedding 'wedding-789' Then the query should return 0 rows (RLS blocks access)

## Fichiers Concernes

### A Creer
- Migration SQL via Supabase MCP: `20260128100002_create_guest_albums`

### A Modifier
- Aucun fichier Flutter (migration DB uniquement)

## Notes Techniques

### Migration SQL
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
```

### Rollback SQL
```sql
DROP POLICY IF EXISTS "Bride views shared albums" ON guest_albums;
DROP POLICY IF EXISTS "Guest manages own album" ON guest_albums;
DROP INDEX IF EXISTS idx_guest_albums_guest_user;
DROP INDEX IF EXISTS idx_guest_albums_wedding_shared;
DROP TABLE IF EXISTS guest_albums;
```

### Tests RLS a executer
1. Creer 2 users guest (guest-A, guest-B) et 1 bride
2. Creer albums pour chaque guest dans le meme mariage
3. Verifier que guest-A ne voit que son album
4. Verifier que la bride ne voit que les albums partages
5. Verifier que le toggle shared_with_bride fonctionne

## Definition of Done
- [ ] Table guest_albums creee
- [ ] Contrainte UNIQUE sur (wedding_id, guest_user_id) active
- [ ] RLS activee avec 2 policies
- [ ] Policy "Guest manages own album" testee
- [ ] Policy "Bride views shared albums" testee
- [ ] Index crees pour performance
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 3
**Complexite** : Faible
**Risque** : Moyen (RLS critique pour la privacy)

## Dependances
- EPIC-06 S01 (bucket wedding-media) - pour le stockage des fichiers

## Stories Dependantes
- S03 (Creer table guest_media)
- S07 (Toggle shared_with_bride)
- S08 (Vue bride albums guests)
