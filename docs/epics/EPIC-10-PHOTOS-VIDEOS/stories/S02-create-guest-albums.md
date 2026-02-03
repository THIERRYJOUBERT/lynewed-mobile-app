# Story S02: Creer table guest_albums avec RLS

> **Revision 2026-02-03** : Suppression de `shared_with_bride` - la bride voit automatiquement TOUS les albums guests de son mariage (pas d'opt-in).

## Description
En tant que **guest invite a un mariage**, je veux **avoir mon propre album photo separe de celui de la bride**, afin de **pouvoir uploader et gerer mes photos dans mon espace personnel**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the database schema When the migration create_guest_albums is applied Then table guest_albums should exist with columns: id (UUID PK), wedding_id (FK weddings), guest_user_id (FK profiles), created_at (TIMESTAMPTZ)
- [ ] Given a guest with user_id 'guest-123' in wedding 'wedding-456' When the guest creates an album for wedding 'wedding-456' Then the album should be created successfully
- [ ] Given guest 'guest-123' already has an album in wedding 'wedding-456' When the guest tries to create another album in 'wedding-456' Then the insert should fail with unique constraint violation
- [ ] Given guest-A and guest-B both have albums in wedding 'wedding-456' When guest-A queries guest_albums Then guest-A should only see their own album And guest-A should NOT see guest-B's album
- [ ] Given guest-A and guest-B both have albums in wedding 'wedding-456' When the bride queries guest_albums for her wedding Then the bride should see BOTH guest-A's and guest-B's albums (automatic visibility)
- [ ] Given guest 'guest-123' in wedding 'wedding-456' When the guest tries to view albums from wedding 'wedding-789' Then the query should return 0 rows (RLS blocks access)

## Fichiers Concernes

### A Creer
- Migration SQL via Supabase MCP: `20260203_create_guest_albums`

### A Modifier
- Aucun fichier Flutter (migration DB uniquement)

## Notes Techniques

### Migration SQL
```sql
-- Migration: 20260203_create_guest_albums
-- Description: Create guest_albums table with RLS
-- Revision 2026-02-03: No shared_with_bride column - bride sees all albums automatically

CREATE TABLE IF NOT EXISTS guest_albums (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE NOT NULL,
  guest_user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- One album per guest per wedding
  CONSTRAINT uq_guest_albums_wedding_guest UNIQUE (wedding_id, guest_user_id)
);

-- Index for queries by wedding (for bride view - all albums)
CREATE INDEX IF NOT EXISTS idx_guest_albums_wedding
  ON guest_albums(wedding_id);

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

-- Policy 2: Bride views ALL albums of her wedding (no opt-in filter)
CREATE POLICY "Bride views all albums"
ON guest_albums FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM weddings w
    WHERE w.id = guest_albums.wedding_id
    AND w.bride_profile_id = auth.uid()
  )
);

-- Comments
COMMENT ON TABLE guest_albums IS 'Personal photo albums for wedding guests (one per guest per wedding)';
COMMENT ON COLUMN guest_albums.wedding_id IS 'Reference to the wedding this album belongs to';
COMMENT ON COLUMN guest_albums.guest_user_id IS 'Reference to the guest profile who owns this album';
```

### Rollback SQL
```sql
DROP POLICY IF EXISTS "Bride views all albums" ON guest_albums;
DROP POLICY IF EXISTS "Guest manages own album" ON guest_albums;
DROP INDEX IF EXISTS idx_guest_albums_guest_user;
DROP INDEX IF EXISTS idx_guest_albums_wedding;
DROP TABLE IF EXISTS guest_albums;
```

### Tests RLS a executer
1. Creer 2 users guest (guest-A, guest-B) et 1 bride
2. Creer albums pour chaque guest dans le meme mariage
3. Verifier que guest-A ne voit que son album
4. Verifier que guest-B ne voit que son album
5. Verifier que la bride voit TOUS les albums de son mariage (guest-A + guest-B)
6. Verifier qu'un guest d'un autre mariage ne voit pas ces albums

## Definition of Done
- [ ] Table guest_albums creee avec colonnes: id, wedding_id, guest_user_id, created_at
- [ ] Contrainte UNIQUE sur (wedding_id, guest_user_id) active
- [ ] RLS activee avec 2 policies
- [ ] Policy "Guest manages own album" testee
- [ ] Policy "Bride views all albums" testee (bride voit TOUS les albums)
- [ ] Index sur wedding_id et guest_user_id crees
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Moyen (RLS critique pour la privacy)

## Dependances
- EPIC-06 S01 (bucket wedding-media) - pour le stockage des fichiers

## Stories Dependantes
- S03 (Creer table guest_media)
- S08 (Vue bride albums guests)

---

## Historique des Revisions

| Date | Changement |
|------|------------|
| 2026-02-03 | **BREAKING**: Suppression colonne `shared_with_bride` - la bride voit automatiquement tous les albums guests de son mariage. Simplifie le modele (pas d'opt-in). RLS policy "Bride views shared albums" renommee en "Bride views all albums" sans filtre. TIMESTAMPTZ au lieu de TIMESTAMP. Suppression colonne `updated_at` (inutile). Points reduits de 3 a 2. |
| 2026-01-28 | Creation initiale avec opt-in via `shared_with_bride` |
