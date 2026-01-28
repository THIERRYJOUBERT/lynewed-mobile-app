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
- `supabase/migrations/20260128100007_create_marketplace_listings_bucket.sql` - Storage RLS policies
- Documentation setup bucket via Dashboard/API

### A Modifier
- Aucun

## Notes Techniques

### Bucket Configuration
```typescript
// Via Supabase Dashboard ou API
const { data, error } = await supabase.storage.createBucket('marketplace-listings', {
  public: false,
  fileSizeLimit: 20971520, // 20MB
  allowedMimeTypes: [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic'
  ]
});
```

### Structure des fichiers
```
marketplace-listings/
├── {listing_id_1}/
│   ├── photo_0.jpg  (cover)
│   ├── photo_1.jpg
│   └── photo_2.jpg
├── {listing_id_2}/
│   └── ...
```

### RLS Policies sur storage.objects (4 policies)
```sql
-- 1. Seller uploads listing photos
CREATE POLICY "Seller uploads listing photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'marketplace-listings'
  AND EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id::text = (storage.foldername(name))[1]
    AND ml.seller_id = auth.uid()
  )
);

-- 2. Read active listing photos (public)
CREATE POLICY "Read active listing photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'marketplace-listings'
  AND EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id::text = (storage.foldername(name))[1]
    AND ml.status = 'active'
  )
);

-- 3. Seller reads own listing photos (even draft)
CREATE POLICY "Seller reads own listing photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'marketplace-listings'
  AND EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id::text = (storage.foldername(name))[1]
    AND ml.seller_id = auth.uid()
  )
);

-- 4. Seller deletes listing photos
CREATE POLICY "Seller deletes listing photos"
ON storage.objects FOR DELETE
TO authenticated
USING (...);
```

## Definition of Done
- [ ] Bucket cree via Dashboard/API
- [ ] 4 RLS policies sur storage.objects
- [ ] Tests upload/download
- [ ] Tests RLS (access denied pour non-proprietaires)
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances
- S01 (marketplace_listings table - pour RLS JOIN)
- S02 (marketplace_photos table - pour storage_path)

## Stories Dependantes
- S14 (create listing form - upload photos)
