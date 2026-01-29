# S06 - Étapes Manuelles pour Compléter le Bucket wedding-media

> **Story**: S06 - Créer bucket wedding-media avec RLS  
> **Statut**: 🟡 PARTIEL - Actions manuelles requises  
> **Date**: 2026-01-29  
> **Environnement**: Production (Projet: LYNEWED-V1-APP, ID: hekyovgnovhfhmkpfrna)

---

## Contexte

La création du bucket `wedding-media` et de ses policies RLS nécessite des privilèges **owner** sur la base de données qui ne sont pas disponibles via l'API MCP Supabase. Ces actions doivent donc être effectuées manuellement via le **Supabase Dashboard**.

---

## Prérequis Avant de Commencer

- [ ] Accès au Supabase Dashboard (https://supabase.com/dashboard)
- [ ] Projet LYNEWED-V1-APP ouvert
- [ ] Permissions d'administration sur le projet
- [ ] Vérification que les stories S01-S05 sont déployées ( ✅ Done )

---

## Étape 1: Créer le Bucket wedding-media

### Via Supabase Dashboard

1. **Naviguer vers Storage:**
   - Dashboard → Storage (menu latéral gauche)
   - Cliquer sur "New bucket"

2. **Configuration du bucket:**

| Paramètre | Valeur | Description |
|-----------|--------|-------------|
| **Name** | `wedding-media` | Identifiant unique du bucket |
| **Public** | ❌ **Unchecked** | Bucket privé - accès via RLS uniquement |
| **File size limit** | `524288000` | 500MB maximum (pour les vidéos) |
| **Allowed MIME types** | Voir liste ci-dessous | Restriction des formats acceptés |

3. **Allowed MIME types à ajouter:**

```
image/jpeg
image/png
image/webp
image/heic
video/mp4
video/quicktime
video/x-m4v
```

4. **Cliquer sur "Create bucket"**

### Vérification

Après création, vous devriez voir:
- Bucket name: `wedding-media`
- Status: `Active`
- Public: `Disabled`

---

## Étape 2: Créer les Policies RLS

### Accéder à l'éditeur SQL

1. Dashboard → SQL Editor
2. Cliquer sur "New query"
3. Nommer la requête: `S06-wedding-media-policies`

### Exécuter le Script SQL

**⚠️ IMPORTANT:** Exécuter chaque policy séparément pour faciliter le débogage si une erreur survient.

```sql
-- ============================================================
-- S06: Création des policies RLS pour le bucket wedding-media
-- Date: 2026-01-29
-- Environnement: Production
-- ============================================================

-- -----------------------------------------------------------
-- Policy 1: Guest can upload to their own folder
-- -----------------------------------------------------------
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

-- -----------------------------------------------------------
-- Policy 2: Guest can read their own files
-- -----------------------------------------------------------
CREATE POLICY "Guest read own files"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'wedding-media'
  AND (storage.foldername(name))[2] = 'guests'
  AND (storage.foldername(name))[3] = auth.uid()::text
);

-- -----------------------------------------------------------
-- Policy 3: Guest can delete their own files
-- -----------------------------------------------------------
CREATE POLICY "Guest delete own files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'wedding-media'
  AND (storage.foldername(name))[2] = 'guests'
  AND (storage.foldername(name))[3] = auth.uid()::text
);

-- -----------------------------------------------------------
-- Policy 4: Bride can read shared guest media
-- -----------------------------------------------------------
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

-- -----------------------------------------------------------
-- Policy 5: Bride can upload to bride folder
-- -----------------------------------------------------------
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

-- -----------------------------------------------------------
-- Policy 6: Bride can read own files
-- -----------------------------------------------------------
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

### Vérification des Policies

Après exécution, vérifier dans Dashboard → Storage → Policies:

| Policy | Operation | Role | Bucket |
|--------|-----------|------|--------|
| Guest upload own folder | INSERT | authenticated | wedding-media |
| Guest read own files | SELECT | authenticated | wedding-media |
| Guest delete own files | DELETE | authenticated | wedding-media |
| Bride read shared guest media | SELECT | authenticated | wedding-media |
| Bride upload own folder | INSERT | authenticated | wedding-media |
| Bride read own files | SELECT | authenticated | wedding-media |

---

## Étape 3: Tester les Policies

### Test via Supabase Dashboard

1. **Créer un test manuel (optionnel):**
   ```sql
   -- Vérifier que les policies existent
   SELECT policyname, permissive, roles, cmd, qual
   FROM pg_policies
   WHERE schemaname = 'storage' AND tablename = 'objects'
   AND policyname LIKE '%wedding-media%';
   ```

2. **Vérifier la structure du bucket:**
   - Dashboard → Storage → wedding-media
   - Vérifier que le bucket est bien privé (icône cadenas)

---

## Structure des Dossiers Attendue

```
wedding-media/
├── {wedding_id}/
│   ├── guests/
│   │   └── {guest_user_id}/
│   │       ├── photo1.jpg
│   │       ├── photo2.png
│   │       └── video1.mp4
│   └── bride/
│       └── photo_officielle.jpg
```

### Exemple de chemins:

| Type | Chemin | Accès |
|------|--------|-------|
| Photo guest | `wedding-uuid-123/guests/user-uuid-456/photo.jpg` | Guest uniquement |
| Photo bride | `wedding-uuid-123/bride/photo.jpg` | Bride uniquement |

---

## Rollback (En Cas de Problème)

Si vous devez annuler les policies:

```sql
-- Supprimer toutes les policies du bucket wedding-media
DROP POLICY IF EXISTS "Guest upload own folder" ON storage.objects;
DROP POLICY IF EXISTS "Guest read own files" ON storage.objects;
DROP POLICY IF EXISTS "Guest delete own files" ON storage.objects;
DROP POLICY IF EXISTS "Bride read shared guest media" ON storage.objects;
DROP POLICY IF EXISTS "Bride upload own folder" ON storage.objects;
DROP POLICY IF EXISTS "Bride read own files" ON storage.objects;

-- Supprimer le bucket (⚠️ Attention: supprime tous les fichiers!)
-- À faire uniquement si aucune donnée n'a été uploadée
-- DELETE FROM storage.buckets WHERE id = 'wedding-media';
```

---

## Checklist Post-Configuration

- [ ] Bucket `wedding-media` créé et visible dans Dashboard
- [ ] Bucket configuré: **Private** (Public = No)
- [ ] File size limit: **500MB** (524288000 bytes)
- [ ] Allowed MIME types configurés (images + vidéos)
- [ ] 6 policies créées et visibles dans Dashboard → Storage → Policies
- [ ] Policies testées (upload/read/delete pour guest/bride)

---

## Notes Importantes

### ⚠️ Policy "Bride read shared guest media"

Cette policy sera **améliorée** dans EPIC-10 (APP-04 Photos/Videos) lorsque la table `guest_albums` avec le champ `shared_with_bride` sera créée.

Pour l'instant, la bride peut voir tous les médias des guests de son mariage. C'est acceptable pour la phase actuelle car:
- APP-03 (Invitations) ne nécessite pas de restriction de visibilité
- APP-04 implémentera la logique de partage granulaire

### Sécurité

- Les policies utilisent `auth.uid()` pour identifier l'utilisateur connecté
- La vérification du `wedding_id` empêche l'accès inter-mariages
- Le chemin du fichier est parsé via `storage.foldername(name)`

---

## Références

- [Story S06](./stories/S06-create-wedding-media-bucket.md)
- [EPIC-06-PREREQUISITES](./EPIC-06-PREREQUISITES.md)
- [Supabase Storage RLS Documentation](https://supabase.com/docs/guides/storage/security/access-control)
- [Supabase Storage Policies Guide](https://supabase.com/docs/guides/storage/security/policies)

---

## Prochaines Étapes Après Configuration

Une fois S06 complété:
1. ✅ Mettre à jour [TRACKING.md](./TRACKING.md) - Marquer S06 comme Done
2. ✅ Mettre à jour [EPIC-06-BILAN.md](./EPIC-06-BILAN.md) 
3. 🔄 Passer à EPIC-07 (APP-01 Système d'avis clients)

---

*Document créé le 2026-01-29 - EPIC-06-PREREQUISITES*
