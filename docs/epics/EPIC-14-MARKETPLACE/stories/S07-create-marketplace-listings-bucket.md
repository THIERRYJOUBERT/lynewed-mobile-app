# Story S07: Create marketplace-listings storage bucket with RLS

## Description
En tant que developpeur backend, je veux creer le bucket Supabase Storage marketplace-listings avec RLS, afin de stocker les photos des annonces de maniere securisee.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the Supabase Storage service When bucket marketplace-listings is created Then the bucket should exist and be private And file size limit should be 20MB
- [ ] Given a seller with a listing When uploading a photo to {listing_id}/photo1.jpg Then upload should succeed
- [ ] Given seller-A with listing-A and seller-B with listing-B When seller-A tries to upload to listing-B folder Then upload should be denied (RLS)
- [ ] Given an active listing with photos When any authenticated user requests the photos Then photos should be accessible
- [ ] Given a draft listing with photos When the seller requests photos Then it should succeed When another user requests Then it should be denied (RLS)
- [ ] Given an upload attempt with file > 20MB Then upload should be rejected
- [ ] Given an upload attempt with mime type application/pdf Then upload should be rejected (only jpeg, png, webp, heic allowed)

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260204100007_create_marketplace_listings_bucket_rls.sql` - RLS policies ONLY (bucket creation via MCP)
- Documentation setup bucket via MCP

### A Modifier
- Aucun

## ⚠️ IMPORTANT: Bucket Creation Strategy

**PROBLÈME** : Les buckets Supabase Storage NE PEUVENT PAS être créés via SQL migration standard.

**SOLUTION** : Utiliser MCP Supabase pour créer le bucket, puis SQL migration pour les RLS policies.

## Setup Instructions (MCP + SQL)

### Étape 1: Vérifier si le bucket existe déjà

```bash
# Via MCP mcp__supabase__execute_sql
SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets
WHERE id = 'marketplace-listings';
```

**Résultat attendu** :
- Si 0 rows : Bucket n'existe pas → créer via Étape 2
- Si 1 row : Bucket existe déjà → passer à Étape 3

### Étape 2: Créer le bucket (via MCP si nécessaire)

**Option A: Via Supabase Dashboard (Recommandé)**
1. Aller sur https://supabase.com/dashboard/project/hekyovgnovhfhmkpfrna/storage/buckets
2. Cliquer "New bucket"
3. Configurer :
   - Name: `marketplace-listings`
   - Public: `false` (private)
   - File size limit: `20 MB` (20971520 bytes)
   - Allowed MIME types: `image/jpeg, image/png, image/webp, image/heic`

**Option B: Via SQL (si Dashboard indisponible)**

```sql
-- Via MCP mcp__supabase__execute_sql (service_role)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'marketplace-listings',
  'marketplace-listings',
  false,
  20971520, -- 20 MB
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic']
)
ON CONFLICT (id) DO NOTHING;
```

**Note** : Cette approche peut ne pas fonctionner selon la version de Supabase. Préférer Dashboard ou MCP.

### Étape 3: Appliquer les RLS policies (via migration SQL)

```sql
-- Migration: 20260204100007_create_marketplace_listings_bucket_rls.sql

-- Enable RLS on storage.objects (if not already enabled)
-- Note: Supabase enables RLS by default on storage.objects

-- Policy 1: Seller uploads listing photos
-- Seller can upload to their own listing folder
CREATE POLICY "Seller uploads listing photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'marketplace-listings'
  AND (storage.foldername(name))[1] IN (
    SELECT ml.id::text
    FROM marketplace_listings ml
    WHERE ml.seller_id = auth.uid()
  )
);

-- Policy 2: Read active listing photos (public)
-- Any authenticated user can view photos of active listings
CREATE POLICY "Read active listing photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'marketplace-listings'
  AND (storage.foldername(name))[1] IN (
    SELECT ml.id::text
    FROM marketplace_listings ml
    WHERE ml.status = 'active'
  )
);

-- Policy 3: Seller reads own listing photos (even draft)
-- Seller can view photos of their own listings regardless of status
CREATE POLICY "Seller reads own listing photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'marketplace-listings'
  AND (storage.foldername(name))[1] IN (
    SELECT ml.id::text
    FROM marketplace_listings ml
    WHERE ml.seller_id = auth.uid()
  )
);

-- Policy 4: Seller deletes listing photos
-- Seller can delete photos from their own listing folder
CREATE POLICY "Seller deletes listing photos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'marketplace-listings'
  AND (storage.foldername(name))[1] IN (
    SELECT ml.id::text
    FROM marketplace_listings ml
    WHERE ml.seller_id = auth.uid()
  )
);
```

## Post-Migration Verification

```sql
-- 1. Verify bucket exists
SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets
WHERE id = 'marketplace-listings';

-- Expected result:
-- id: marketplace-listings
-- name: marketplace-listings
-- public: false
-- file_size_limit: 20971520
-- allowed_mime_types: {image/jpeg, image/png, image/webp, image/heic}

-- 2. Verify RLS is enabled on storage.objects
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'storage' AND tablename = 'objects';

-- Expected: rowsecurity = true

-- 3. Verify policies created on storage.objects
SELECT policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND policyname LIKE '%listing%';

-- Expected: 4 policies
-- - Seller uploads listing photos (INSERT)
-- - Read active listing photos (SELECT)
-- - Seller reads own listing photos (SELECT)
-- - Seller deletes listing photos (DELETE)

-- 4. Test file upload (manual test in app)
-- Via Supabase client:
-- final path = '$listingId/photo_0.jpg';
-- await supabase.storage.from('marketplace-listings').upload(path, file);
-- Expected: Success if seller owns listing, fail otherwise

-- 5. Test file download (manual test in app)
-- Via Supabase client:
-- final url = supabase.storage.from('marketplace-listings').getPublicUrl('$listingId/photo_0.jpg');
-- Expected: URL generated, but access denied if listing is draft and user is not seller
```

## Storage Path Structure

```
marketplace-listings/
├── {listing_id_1}/
│   ├── photo_0.jpg      # Cover photo (position 0)
│   ├── photo_1.jpg
│   ├── photo_2.jpg
│   ├── ...
│   └── photo_9.jpg      # Max 10 photos
├── {listing_id_2}/
│   ├── photo_0.jpg
│   └── ...
```

### Path Generation (Application Logic)

```dart
// In app code
String generateStoragePath(String listingId, int position, String extension) {
  return '$listingId/photo_$position.$extension';
}

// Example usage:
// final path = generateStoragePath('abc-123-def', 0, 'jpg');
// Result: "abc-123-def/photo_0.jpg"
```

## File Constraints

| Constraint | Value | Enforced By |
|------------|-------|-------------|
| **Max file size** | 20 MB | Bucket config |
| **Allowed MIME types** | image/jpeg, image/png, image/webp, image/heic | Bucket config |
| **Min photos per listing** | 5 | App logic (block publish) |
| **Max photos per listing** | 10 | App logic (block upload) |
| **Path format** | `{listing_id}/photo_{position}.{ext}` | App logic |

## storage.foldername() Function

**Note du challenger** : "`storage.foldername()` non documenté"

**Réponse** : `storage.foldername()` est une fonction Supabase interne qui extrait le dossier d'un path.

### Fonctionnement

```sql
-- Given path: "abc-123-def/photo_0.jpg"
SELECT (storage.foldername('abc-123-def/photo_0.jpg'))[1];
-- Result: "abc-123-def"

-- Given path: "listing-a/subfolder/photo.jpg"
SELECT (storage.foldername('listing-a/subfolder/photo.jpg'))[1];
-- Result: "listing-a"
```

**Explication** :
- `storage.foldername(path)` retourne un array de segments du path
- `[1]` accède au premier segment (le listing_id)
- Utilisé dans RLS pour vérifier que l'utilisateur a accès au listing

### Alternative (si fonction non disponible)

Si `storage.foldername()` n'existe pas dans votre version de Supabase :

```sql
-- Alternative: Extract listing_id via string split
CREATE POLICY "Seller uploads listing photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'marketplace-listings'
  AND split_part(name, '/', 1) IN (
    SELECT ml.id::text
    FROM marketplace_listings ml
    WHERE ml.seller_id = auth.uid()
  )
);
```

## Tests Requis

### Tests infrastructure (manual):
- Test 1: Bucket created with correct config (20MB limit, private, MIME types)
- Test 2: RLS policies created (4 policies on storage.objects)
- Test 3: Seller can upload to own listing folder
- Test 4: Seller cannot upload to other seller's listing folder
- Test 5: Authenticated user can view active listing photos
- Test 6: Authenticated user cannot view draft listing photos (unless seller)
- Test 7: Seller can view own draft listing photos
- Test 8: Seller can delete own listing photos
- Test 9: File > 20MB rejected
- Test 10: Invalid MIME type (e.g., .pdf) rejected

### Tests application (Flutter):
- Test 1: Upload photo to listing (success path)
- Test 2: Upload photo to listing owned by other seller (RLS denial)
- Test 3: Download photo from active listing (public access)
- Test 4: Download photo from draft listing owned by self (seller access)
- Test 5: Download photo from draft listing owned by other (RLS denial)
- Test 6: Delete photo from own listing (success)
- Test 7: File size validation (block upload > 20MB client-side)
- Test 8: MIME type validation (block non-image uploads client-side)

## Definition of Done
- [ ] Bucket `marketplace-listings` créé (Dashboard ou MCP)
- [ ] Bucket config vérifié (20MB, private, MIME types)
- [ ] Migration RLS appliquée avec succès (MCP apply_migration)
- [ ] Post-migration verification complete (bucket + 4 policies)
- [ ] Tests manuels RLS passed (upload/download/delete avec différents users)
- [ ] Tests Flutter passed (8 test scenarios)
- [ ] Documentation path structure et storage.foldername() complète
- [ ] `flutter analyze --fatal-infos` passe (0 warnings si fichiers Dart ajoutés)

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances

### Requires (BLOQUANTS):
- S01: `marketplace_listings` table doit exister (RLS JOIN sur seller_id et status)
- S02: `marketplace_photos` table doit exister (pour stocker les storage_path)

### Order:
- S01 (marketplace_listings) → S02 (marketplace_photos) → **S07 (storage bucket)**

### Important:
- **Bucket creation** doit être faite AVANT la migration RLS (sinon policies échouent)
- **S02** peut techniquement être implémentée en parallèle, mais logiquement S07 complète l'écosystème photos

## Stories Dependantes (BLOQUEES si S07 incomplete)
- S14 (create listing form) - upload photos vers bucket marketplace-listings
- S16 (detail page) - affiche photos depuis bucket
