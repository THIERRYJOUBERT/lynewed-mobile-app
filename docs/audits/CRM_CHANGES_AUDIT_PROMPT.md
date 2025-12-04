# 🔍 AUDIT MASTER PROMPT - Modifications CRM Fiche Pro (04/12/2025)

**Date de création:** 2025-12-04  
**Objectif:** Audit complet des modifications CRM et synchronisation avec l'app Flutter  
**Document source:** `docs/GUIDE_EQUIPE_APP_MOBILE_FICHE_PRO.md`  
**Priorité:** 🔴 HAUTE

---

## 📋 CONTEXTE

Le collègue travaillant sur le CRM a effectué plusieurs modifications majeures sur le backend Supabase et documenté les changements dans `GUIDE_EQUIPE_APP_MOBILE_FICHE_PRO.md`. Cet audit doit vérifier:

1. **Cohérence Backend ↔ Frontend** - Les modifications backend sont-elles correctement reflétées dans le code Flutter?
2. **Fonctionnalités manquantes** - Quelles fonctionnalités documentées ne sont pas encore implémentées?
3. **Erreurs potentielles** - Y a-t-il des incohérences ou erreurs dans la documentation ou l'implémentation?
4. **Actions requises** - Quelles modifications doivent être apportées côté app?

---

## 🔄 RÉSUMÉ DES CHANGEMENTS CRM

### 1. Vidéo YouTube/Vimeo (Priorité Haute)

| Aspect | Avant | Après |
|--------|-------|-------|
| **Source vidéo** | Upload Supabase Storage (.mp4) | Liens YouTube/Vimeo |
| **Colonne** | `profile_video_url` | `profile_video_url` (même colonne) |
| **Nouvelle colonne** | - | `has_cover_video` (boolean) |
| **Logique affichage** | Vidéo si FILMMAKER | Vidéo si `has_cover_video=true` ET URL valide |

**État Backend:** ✅ Colonnes existent (`has_cover_video`, `profile_video_url`)

### 2. Nouveau Format Images (Priorité Haute)

| Aspect | Avant | Après (selon doc CRM) |
|--------|-------|----------------------|
| **Format** | `List<String>` (URLs simples) | `List<PhotoWithCrops>` (objets JSON avec crops) |
| **Structure** | `["url1", "url2"]` | `[{id, order, original, crops: {square, vertical, fullscreen}}]` |

**État Backend:** ⚠️ **ATTENTION - Les données actuelles sont encore au format simple `string`!**
- Vérifié via SQL: `portfolio_type = "string"` pour tous les pros
- Le nouveau format n'est **PAS encore déployé** en production

### 3. Migration Localisations (Priorité Haute)

| Aspect | Avant | Après |
|--------|-------|-------|
| **Source principale** | `professional_details.location_coords` | `professional_fixed_locations` uniquement |
| **Colonne supprimée** | - | `professional_details.location_coords` ❌ |
| **Format retourné** | `{lat, lng}` | `{id, label, type, coordinates}` |

**État Backend:** ✅ Migration appliquée
- Colonne `location_coords` supprimée de `professional_details`
- RPC `get_pro_item_details` retourne maintenant `fixedLocations` avec `id` et `label`
- RPC `search_map_bundle` utilise uniquement `professional_fixed_locations`

### 4. Upcoming Travels (Phase 2 - Non prioritaire)

**État Backend:** ❌ Table `professional_upcoming_travels` n'existe pas encore

---

## 🔎 POINTS D'AUDIT DÉTAILLÉS

### AUDIT 1: Lecteur Vidéo YouTube/Vimeo

**Fichiers à vérifier:**
```
lib/pages/shared/pro_details/pro_details_widget.dart
lib/custom_code/widgets/videoplayer_filmmaker.dart
lib/features/map/presentation/sheets/professional_details_sheet.dart
```

**Questions d'audit:**
1. Le widget `VideoplayerFilmmaker` actuel utilise `video_player` package - supporte-t-il YouTube/Vimeo?
   - **RÉPONSE ATTENDUE:** NON - Il utilise `VideoPlayerController.networkUrl()` qui ne supporte que les fichiers vidéo directs
   
2. La logique actuelle vérifie `profession == FILMMAKER` - doit-elle être remplacée par `has_cover_video`?
   - **RÉPONSE ATTENDUE:** OUI - Selon la doc CRM

3. Existe-t-il un widget `VideoPlayerWidget` réutilisable (mentionné dans la doc)?
   - **RÉPONSE ATTENDUE:** NON - Grep ne trouve rien

**Actions requises:**
- [ ] Créer un nouveau widget `YouTubeVimeoPlayer` utilisant `youtube_player_flutter` ou `webview_flutter`
- [ ] Ajouter les fonctions `isYouTubeUrl()`, `isVimeoUrl()`, `extractYouTubeId()`, `extractVimeoId()`
- [ ] Modifier `pro_details_widget.dart` pour utiliser `has_cover_video` au lieu de `profession == FILMMAKER`
- [ ] Ajouter `hasCoverVideo` au modèle `ProDetailsStruct`

---

### AUDIT 2: Format Images avec Crops

**Fichiers à vérifier:**
```
lib/backend/schema/structs/pro_details_struct.dart
lib/custom_code/actions/get_pro_item_details_action.dart
lib/pages/shared/pro_details/pro_details_widget.dart
```

**État actuel vérifié:**
- `ProDetailsStruct.portfolioImages` = `List<String>` ✅ (format actuel)
- `ProDetailsStruct.slideshowImages` = `List<String>` ✅ (format actuel)
- Données en base = format `string` simple ✅

**Conclusion:** ⚠️ **Le nouveau format avec crops n'est PAS encore déployé côté CRM/Backend**

**Actions requises (QUAND le CRM déploiera le nouveau format):**
- [ ] Créer modèle `PhotoWithCrops` et `PhotoCrops`
- [ ] Créer fonction `parseImages()` avec rétrocompatibilité
- [ ] Modifier `ProDetailsStruct` pour supporter les deux formats
- [ ] Utiliser `crops.square` pour thumbnails, `crops.vertical` pour slideshow, `crops.fullscreen` pour plein écran

**⚠️ IMPORTANT:** Ne pas implémenter maintenant - attendre que le CRM déploie le nouveau format

---

### AUDIT 3: Migration Localisations

**Fichiers à vérifier:**
```
lib/features/map/domain/entities/professional_details.dart
lib/features/map/data/models/professional_details_model.dart
lib/custom_code/actions/get_pro_item_details_action.dart
lib/backend/schema/structs/pro_details_struct.dart
lib/pages/shared/pro_details/pro_details_widget.dart
```

**État Backend (vérifié via MCP):**

1. **RPC `get_pro_item_details`** - ✅ Modifiée
   - Retourne `fixedLocations` avec `id`, `label`, `type`, `coordinates`
   - Ne référence plus `pd.location_coords`

2. **RPC `search_map_bundle`** - ✅ Modifiée
   - Section "Pros live" supprimée
   - Pros affichés uniquement via `professional_fixed_locations`
   - Retourne `locationLabel` dans `styleInfo`

3. **Table `professional_details`** - ✅ Modifiée
   - Colonne `location_coords` supprimée

**État Frontend (vérifié via code):**

1. **`get_pro_item_details_action.dart`** - ⚠️ À VÉRIFIER
   ```dart
   // Ligne 82-88: Parse fixedLocations
   if (data['fixedLocations'] is List) {
     for (final g in (data['fixedLocations'] as List)) {
       final p = geoJsonToLatLng(g);  // ⚠️ Ne parse pas id/label!
       if (p != null) fixedLocs.add(p);
     }
   }
   ```
   - **PROBLÈME:** Le code actuel ne parse que les coordonnées, pas `id` ni `label`

2. **`ProDetailsStruct`** - ⚠️ À MODIFIER
   ```dart
   List<LatLng>? _fixedLocations;  // ⚠️ Devrait être List<FixedLocationStruct>
   ```
   - **PROBLÈME:** Le struct ne contient pas `id` ni `label` pour chaque location

3. **`pro_details_widget.dart`** - ⚠️ À MODIFIER
   ```dart
   // Ligne 488-489
   center: widget.proDetails!.fixedLocations.firstOrNull!,
   ```
   - **PROBLÈME:** Utilise la première location par défaut, pas celle cliquée depuis la map

**Actions requises:**
- [ ] Créer struct `FixedLocationStruct` avec `id`, `label`, `lat`, `lng`
- [ ] Modifier `ProDetailsStruct.fixedLocations` de `List<LatLng>` vers `List<FixedLocationStruct>`
- [ ] Modifier `get_pro_item_details_action.dart` pour parser `id` et `label`
- [ ] Modifier navigation Map → ProDetails pour passer `clickedLocationId`
- [ ] Modifier `pro_details_widget.dart` pour afficher la location cliquée

---

### AUDIT 4: Passage du `clickedLocationId` depuis la Map

**Fichiers à vérifier:**
```
lib/features/map/presentation/services/map_actions_service.dart
lib/features/map/presentation/sheets/professional_details_sheet.dart
```

**État actuel:**
- `ProfessionalDetailsSheet` a un paramètre `fixedLocation` (String? city name)
- `MapActionsService._navigateToProProfileById()` ne passe pas l'ID de la location cliquée

**Logique documentée par CRM:**
1. User clique marker sur map → récupérer `marker.id` (= ID de la fixed_location)
2. Passer cet ID à `ProDetailsScreen`
3. Afficher la location correspondante dans la mini-map

**Actions requises:**
- [ ] Modifier `ProDetailsWidget` pour accepter `clickedLocationId` optionnel
- [ ] Modifier `MapActionsService` pour passer l'ID du marker cliqué
- [ ] Afficher le bon label de location dans ProDetails

---

## 📊 TABLEAU RÉCAPITULATIF

| Modification | Backend | Frontend | Action |
|--------------|---------|----------|--------|
| **Vidéo YouTube/Vimeo** | ✅ Prêt | ❌ Non implémenté | 🔴 À faire |
| **`has_cover_video`** | ✅ Existe | ❌ Non utilisé | 🔴 À faire |
| **Format images crops** | ❌ Pas déployé | ❌ Non implémenté | ⏳ Attendre CRM |
| **Suppression `location_coords`** | ✅ Fait | ⚠️ Partiel | 🟡 Vérifier |
| **`fixedLocations` avec id/label** | ✅ Retourné | ❌ Non parsé | 🔴 À faire |
| **Passage `clickedLocationId`** | N/A | ❌ Non implémenté | 🔴 À faire |
| **Upcoming Travels** | ❌ Table absente | ❌ Non implémenté | ⏳ Phase 2 |

---

## 🎯 PLAN D'ACTION RECOMMANDÉ

### Phase 1: Corrections Critiques (4-6h)

1. **Vidéo YouTube/Vimeo** (2-3h)
   - Créer widget `YouTubeVimeoPlayer` 
   - Ajouter helpers de détection URL
   - Modifier logique affichage dans `pro_details_widget.dart`
   - Ajouter `hasCoverVideo` au modèle

2. **FixedLocations avec id/label** (2-3h)
   - Créer `FixedLocationStruct`
   - Modifier parsing dans `get_pro_item_details_action.dart`
   - Mettre à jour `ProDetailsStruct`

### Phase 2: Améliorations UX (2-3h)

3. **Passage clickedLocationId** (1-2h)
   - Modifier navigation Map → ProDetails
   - Afficher la bonne location

4. **Tests et validation** (1h)
   - Tester avec données réelles
   - Vérifier tous les scénarios

### Phase 3: Futur (Quand CRM prêt)

5. **Format images crops** - Attendre déploiement CRM
6. **Upcoming Travels** - Phase 2

---

## 📁 FICHIERS CLÉS À AUDITER

```
# Backend/Modèles
lib/backend/schema/structs/pro_details_struct.dart
lib/custom_code/actions/get_pro_item_details_action.dart

# Pages ProDetails
lib/pages/shared/pro_details/pro_details_widget.dart
lib/pages/shared/pro_details/pro_details_model.dart

# Map Module
lib/features/map/presentation/services/map_actions_service.dart
lib/features/map/presentation/sheets/professional_details_sheet.dart
lib/features/map/domain/entities/professional_details.dart
lib/features/map/data/models/professional_details_model.dart

# Widgets vidéo
lib/custom_code/widgets/videoplayer_filmmaker.dart
```

---

## ⚠️ ERREURS IDENTIFIÉES DANS LA DOC CRM

1. **Format images crops** - La doc indique que c'est déployé, mais les données en base sont encore au format simple `string`. Le CRM n'a probablement pas encore migré les données.

2. **Table `professional_upcoming_travels`** - Mentionnée comme existante mais n'existe pas en base.

3. **Rétrocompatibilité** - La doc mentionne de supporter l'ancien format, ce qui confirme que la migration n'est pas terminée.

---

## 🔧 COMMANDES DE VÉRIFICATION

```bash
# Vérifier les packages vidéo installés
grep -r "youtube_player\|webview_flutter\|video_player" pubspec.yaml

# Chercher les références à location_coords dans le code
grep -r "location_coords\|locationCoords" lib/

# Chercher les références à has_cover_video
grep -r "has_cover_video\|hasCoverVideo" lib/

# Vérifier le format des fixedLocations
grep -r "fixedLocations\|fixed_locations" lib/
```

---

## 📞 QUESTIONS POUR L'ÉQUIPE CRM

1. **Format images crops** - Quand sera-t-il déployé en production?
2. **Upcoming Travels** - La table sera-t-elle créée bientôt?
3. **Vidéos existantes** - Y a-t-il des pros avec des vidéos YouTube/Vimeo en prod actuellement?

---

**Dernière mise à jour:** 2025-12-04 12:00  
**Auteur:** Audit automatique Windsurf  
**Statut:** 🔴 Actions requises
