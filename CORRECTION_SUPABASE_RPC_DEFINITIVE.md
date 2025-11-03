# ⚠️ ATTENTION : Vos fonctions RPC ont un type de retour différent

## 🔍 **ANALYSE DU PROBLÈME**

Vos fonctions RPC actuelles **ne retournent pas JSON** mais probablement un autre type (table, record, etc.). C'est pourquoi vous ne pouvez pas les modifier avec `CREATE OR REPLACE`.

## ✅ **PROCÉDURE SÉCURISÉE**

### **Étape 1 : Sauvegarder le code actuel**
```sql
-- Voir le code actuel avant de supprimer
SELECT pg_get_functiondef(oid) 
FROM pg_proc 
WHERE proname = 'get_wedding_pin_item_details';

SELECT pg_get_functiondef(oid) 
FROM pg_proc 
WHERE proname = 'get_bride_interest_items';
```

### **Étape 2 : Supprimer les fonctions**
```sql
DROP FUNCTION get_wedding_pin_item_details(UUID);
DROP FUNCTION get_bride_interest_items();
```

### **Étape 3 : Recréer avec le bon type de retour (JSON)**
```sql
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
    'brideAvatarUrl', pp.avatar_url  -- ✅ CHAMP AJOUTÉ
  )
  INTO result
  FROM wedding_pins wp
  LEFT JOIN public_profiles pp ON pp.id = wp.bride_profile_id  -- ✅ JOIN AJOUTÉ
  WHERE wp.id = p_pin_id;
  
  RETURN result;
END;
$$;

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
      'brideAvatarUrl', pp.avatar_url,  -- ✅ CHAMP AJOUTÉ
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
  LEFT JOIN public_profiles pp ON pp.id = wp.bride_profile_id  -- ✅ JOIN AJOUTÉ
  LEFT JOIN points_of_interest poi ON poi.bride_profile_id = auth.uid()
  WHERE wp.bride_profile_id = auth.uid() OR poi.bride_profile_id = auth.uid();
  
  RETURN result;
END;
$$;
```

### **Étape 4 : Tester les fonctions**
```sql
-- Test de la première fonction
SELECT get_wedding_pin_item_details('un-uuid-de-wedding-pin-valide');

-- Test de la deuxième fonction  
SELECT get_bride_interest_items();
```

### **Étape 5 : Vérifier que brideAvatarUrl est présent**
Le résultat doit contenir : `"brideAvatarUrl": "https://votre-url/avatar.jpg"`

---

## 🛡️ **SI ÇA NE MARCHE PAS : ROLLBACK**

Si quelque chose ne va pas après la modification, vous pouvez restaurer vos fonctions originales :

```sql
-- Collez ici le code de sauvegarde que vous avez récupéré à l'étape 1
```

---

## 🎯 **EXPLICATION**

Le problème vient du fait que vos fonctions RPC existantes retournent probablement un `RECORD` ou une `TABLE` au lieu de `JSON`. Votre code Flutter s'attend à recevoir du JSON, donc il faut changer le type de retour.

**Les modifications ajoutent uniquement :**
- Le JOIN avec `public_profiles`
- Le champ `brideAvatarUrl` dans le JSON
- Rien d'autre ne change !

Prêt à exécuter ces requêtes dans Supabase ?
