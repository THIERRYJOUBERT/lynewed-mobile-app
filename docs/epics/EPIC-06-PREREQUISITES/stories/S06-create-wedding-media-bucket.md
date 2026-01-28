# Story S06: Create wedding-media Storage Bucket with RLS

## Description
En tant que **systeme**, je veux **creer un bucket Supabase Storage 'wedding-media' avec des policies RLS granulaires**, afin de **permettre aux guests de stocker leurs photos/videos de mariage de maniere securisee avec controle d'acces par la mariee**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the Supabase Storage service When the bucket wedding-media is created Then the bucket should exist and be active And the bucket should be private (not public) And the max file size should be 500MB
- [ ] Given a guest with user_id 'guest-123' in wedding 'wedding-456' When the guest uploads a photo to 'wedding-456/guests/guest-123/photo.jpg' Then the upload should succeed And the file should be accessible to the guest
- [ ] Given guest-A and guest-B in the same wedding When guest-A tries to read from 'wedding-456/guests/guest-B-id/photo.jpg' Then the access should be denied (RLS policy violation)
- [ ] Given a guest in wedding 'wedding-456' When the guest tries to upload to 'wedding-789/guests/guest-123/photo.jpg' Then the upload should be denied
- [ ] Given a guest has uploaded media and shared_with_bride = TRUE in guest_albums When the bride of that wedding requests the file Then the bride should be able to view the file
- [ ] Given a guest has uploaded media and shared_with_bride = FALSE When the bride tries to view the file Then the access should be denied
- [ ] Given a guest trying to upload a 600MB video When the upload is attempted Then the upload should fail with size limit error

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260128000006_create_wedding_media_bucket.sql` (policies RLS)
- Documentation bucket creation steps

### A Modifier
- Aucun fichier Dart (configuration Storage)

## Notes Techniques

**Bucket Creation (via Supabase Dashboard ou API):**
```typescript
const { data, error } = await supabase.storage.createBucket('wedding-media', {
  public: false,
  fileSizeLimit: 524288000, // 500MB max
  allowedMimeTypes: [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic',
    'video/mp4',
    'video/quicktime',
    'video/x-m4v'
  ]
});
```

**Migration SQL (Storage Policies):**
```sql
-- Policy 1: Guest can upload to their own folder
CREATE POLICY "Guest upload own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'wedding-media'
  AND (storage.foldername(name))[1] IN (
    SELECT w.id::text FROM weddings w
    JOIN wedding_guests wg ON wg.wedding_id = w.id
    WHERE wg.user_id = auth.uid()
  )
  AND (storage.foldername(name))[2] = 'guests'
  AND (storage.foldername(name))[3] = auth.uid()::text
);

-- Policy 2: Guest can read their own files
CREATE POLICY "Guest read own files"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'wedding-media'
  AND (storage.foldername(name))[2] = 'guests'
  AND (storage.foldername(name))[3] = auth.uid()::text
);

-- Policy 3: Guest can delete their own files
CREATE POLICY "Guest delete own files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'wedding-media'
  AND (storage.foldername(name))[2] = 'guests'
  AND (storage.foldername(name))[3] = auth.uid()::text
);

-- Policy 4: Bride can read shared guest media
-- Note: Requires guest_albums table (created in APP-04)
-- This policy will be updated when guest_albums exists
CREATE POLICY "Bride read shared guest media"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'wedding-media'
  AND (storage.foldername(name))[2] = 'guests'
  AND EXISTS (
    SELECT 1 FROM weddings w
    WHERE w.bride_profile_id = auth.uid()
    AND w.id::text = (storage.foldername(name))[1]
  )
);

-- Policy 5: Bride can upload to bride folder
CREATE POLICY "Bride upload own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'wedding-media'
  AND (storage.foldername(name))[2] = 'bride'
  AND EXISTS (
    SELECT 1 FROM weddings w
    WHERE w.bride_profile_id = auth.uid()
    AND w.id::text = (storage.foldername(name))[1]
  )
);

-- Policy 6: Bride can read own files
CREATE POLICY "Bride read own files"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'wedding-media'
  AND (storage.foldername(name))[2] = 'bride'
  AND EXISTS (
    SELECT 1 FROM weddings w
    WHERE w.bride_profile_id = auth.uid()
    AND w.id::text = (storage.foldername(name))[1]
  )
);
```

**Structure des dossiers:**
```
wedding-media/
  {wedding_id}/
    guests/
      {guest_user_id}/
        photo1.jpg
        video1.mp4
    bride/
      {filename}
```

**Rollback SQL:**
```sql
DROP POLICY IF EXISTS "Guest upload own folder" ON storage.objects;
DROP POLICY IF EXISTS "Guest read own files" ON storage.objects;
DROP POLICY IF EXISTS "Guest delete own files" ON storage.objects;
DROP POLICY IF EXISTS "Bride read shared guest media" ON storage.objects;
DROP POLICY IF EXISTS "Bride upload own folder" ON storage.objects;
DROP POLICY IF EXISTS "Bride read own files" ON storage.objects;
-- Bucket deletion manual: requires verification of data
```

**Note importante:**
La policy "Bride read shared guest media" sera completee dans EPIC-10 (APP-04) quand la table `guest_albums` avec le champ `shared_with_bride` sera creee. Pour l'instant, la bride peut voir tous les medias de son mariage.

## Definition of Done

- [ ] Bucket 'wedding-media' cree (via Dashboard ou API)
- [ ] Bucket configure: private, 500MB max, MIME types limites
- [ ] Policy "Guest upload own folder" creee et fonctionne
- [ ] Policy "Guest read own files" creee et fonctionne
- [ ] Policy "Guest delete own files" creee et fonctionne
- [ ] Policy "Bride upload own folder" creee et fonctionne
- [ ] Policy "Bride read own files" creee et fonctionne
- [ ] Policy "Bride read shared guest media" creee (version initiale)
- [ ] Test: Guest peut upload dans son dossier
- [ ] Test: Guest ne peut PAS lire dossier autre guest
- [ ] Test: Guest ne peut PAS upload dans autre wedding
- [ ] Test: Upload > 500MB echoue
- [ ] `flutter analyze --fatal-infos` passe (aucun changement Dart)

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (RLS Storage complexes, impact securite)

## Dependances

- Aucune (peut etre fait en parallele des autres stories)

## Stories Dependantes

- EPIC-10 (APP-04 Photos/Videos) - Utilisera ce bucket
- EPIC-12 (APP-06 Reels) - Utilisera ce bucket
