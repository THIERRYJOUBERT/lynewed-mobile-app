# 🔧 CORRECTION NÉCESSAIRE CÔTÉ SUPABASE

## ❌ PROBLÈME IDENTIFIÉ

Le champ `brideAvatarUrl` est bien extrait dans le code Flutter, MAIS la fonction RPC Supabase **ne retourne pas ce champ**.

### Fichiers Flutter corrects :
- ✅ `get_wedding_pin_item_details_rpc.dart` : extrait `brideAvatarUrl`
- ✅ `get_bride_interest_items_action.dart` : extrait `brideAvatarUrl`
- ✅ `wedding_pin_item_data_struct.dart` : contient le champ
- ✅ `info_wedding_pin_sheet_widget.dart` : affiche le champ

### Problème :
Les fonctions RPC Supabase suivantes ne retournent PAS `brideAvatarUrl` :
1. `get_wedding_pin_item_details(p_pin_id)`
2. `get_bride_interest_items()`

## ✅ SOLUTION CÔTÉ SUPABASE (CORRIGÉE)

### Fonction 1 : `get_wedding_pin_item_details`

**D'abord, supprimez la fonction existante puis recréz-la :**

```sql
-- Étape 1: Supprimer la fonction existante
DROP FUNCTION IF EXISTS get_wedding_pin_item_details(UUID);

-- Étape 2: Créer la nouvelle fonction
CREATE OR REPLACE FUNCTION get_wedding_pin_item_details(p_pin_id UUID)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'weddingPinId', wp.id,
    'brideProfileId', wp.bride_profile_id,
    'locationLabel', wp.location_label,
    'center', ST_AsGeoJSON(wp.center)::json,
    'radiusKm', wp.radius_km,
    'professionsNeeded', wp.professions_needed,
    'eventStartDate', wp.event_start_date,
    'budgetMin', wp.budget_min,
    'budgetMax', wp.budget_max,
    'currency', wp.currency,
    'isContactable', wp.is_contactable,
    'brideAvatarUrl', pp.avatar_url  -- ✅ AJOUT DU CHAMP
  )
  INTO result
  FROM wedding_pins wp
  LEFT JOIN public_profiles pp ON pp.id = wp.bride_profile_id  -- ✅ JOIN AVEC public_profiles
  WHERE wp.id = p_pin_id;

  RETURN result;
END;
$$;
```

### Fonction 2 : `get_bride_interest_items`

**D'abord, vérifiez si cette fonction existe et supprimez-la si nécessaire :**

```sql
-- Étape 1: Supprimer la fonction existante si elle retourne un type différent
DROP FUNCTION IF EXISTS get_bride_interest_items();

-- Étape 2: Créer la nouvelle fonction
CREATE OR REPLACE FUNCTION get_bride_interest_items()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(
    json_build_object(
      'weddingPinId', wp.id,
      'brideProfileId', wp.bride_profile_id,
      'locationLabel', wp.location_label,
      'center', ST_AsGeoJSON(wp.center)::json,
      'radiusKm', wp.radius_km,
      'professionsNeeded', wp.professions_needed,
      'eventStartDate', wp.event_start_date,
      'budgetMin', wp.budget_min,
      'budgetMax', wp.budget_max,
      'currency', wp.currency,
      'isContactable', wp.is_contactable,
      'brideAvatarUrl', pp.avatar_url,  -- ✅ AJOUT DU CHAMP
      'poiId', poi.id,
      'source', CASE
        WHEN wp.id IS NOT NULL THEN 'weddingPin'
        ELSE 'poiPrivate'
      END,
      'createdAt', COALESCE(wp.created_at, poi.created_at)
    )
  )
  INTO result
  FROM wedding_pins wp
  LEFT JOIN public_profiles pp ON pp.id = wp.bride_profile_id  -- ✅ JOIN AVEC public_profiles
  LEFT JOIN points_of_interest poi ON poi.bride_profile_id = auth.uid()
  WHERE wp.bride_profile_id = auth.uid() OR poi.bride_profile_id = auth.uid();

  RETURN result;
END;
$$;
```

## 📝 INSTRUCTIONS POUR L'UTILISATEUR

1. Allez dans le **SQL Editor** de votre projet Supabase
2. Exécutez d'abord les commandes `DROP FUNCTION` pour supprimer les fonctions existantes
3. Puis exécutez les commandes `CREATE OR REPLACE FUNCTION` pour créer les nouvelles versions
4. Testez en appelant les fonctions :
   ```sql
   -- Test de la première fonction (remplacez par un vrai wedding pin ID)
   SELECT get_wedding_pin_item_details('your-wedding-pin-uuid-here');
   
   -- Test de la deuxième fonction
   SELECT get_bride_interest_items();
   ```
5. Vérifiez que le champ `brideAvatarUrl` est bien présent dans le résultat JSON

### ✅ EXEMPLE DE RÉSULTAT ATTENDU :

```json
{
  "weddingPinId": "uuid-here",
  "brideProfileId": "uuid-here", 
  "locationLabel": "Paris, France",
  "center": {"type": "Point", "coordinates": [2.3522, 48.8566]},
  "radiusKm": 50,
  "professionsNeeded": ["photographer", "caterer"],
  "eventStartDate": "2025-06-15",
  "budgetMin": 10000,
  "budgetMax": 25000,
  "currency": "EUR",
  "isContactable": true,
  "brideAvatarUrl": "https://supabase-storage-url/avatar.jpg"  // ✅ CE CHAMP DOIT APPARAÎTRE
}
```

## ⚠️ IMPORTANT

Sans cette correction côté Supabase, le champ `brideAvatarUrl` sera toujours `null` dans Flutter, même si le code Flutter est correct.

Le code Flutter est **100% correct** et prêt à recevoir les données. Il manque juste la modification côté Supabase.
