# 📱 FEED FEATURE AUDIT - Analyse Complète v2

> **Version**: 2.1  
> **Date**: 2025-12-05  
> **Statut**: ✅ AUDIT TERMINÉ - PRÊT POUR IMPLÉMENTATION  
> **Plan d'action**: `docs/FEED_REFACTORING_PLAN.md` (v5)  
> **TODO**: `docs/TODO_FINALISATION.md`

---

## 📋 RÉSUMÉ EXÉCUTIF

### État Actuel
Le module Feed est **fonctionnel** mais présente des **incohérences de logique** avec le reste de l'app (Map, Market Region). L'UI est validée mais les filtres doivent être repensés.

### Points Clés Critiques
- ✅ **UI validée** - Grille d'images, navigation fonctionnels
- ⚠️ **Images legacy** - Utilise `portfolio_images` (text[]) au lieu de `portfolio_images_v2` (jsonb)
- ⚠️ **Pas de fullscreen 9:16** - Les images s'ouvrent en plein écran mais sans crop optimisé
- ⚠️ **FlutterFlowTheme** - Encore utilisé dans plusieurs composants
- 🔴 **MARKET REGION MANQUANT** - `get_portfolio_feed` n'utilise PAS `is_visible_in_market()` !
- 🔴 **FILTRES INCOHÉRENTS** - Dropdown pays + recherche adresse = logique confuse
- ❌ **feed_enabled ignoré** - La RPC ne vérifie pas `feed_enabled`
- ✅ **ambassador existe** - Colonne dans `profiles` (pas `professional_details`)
- ⚠️ **Wed of the Week** - Table `wed_articles` existe, pas intégrée

---

## 🌍 LOGIQUE MARKET REGION - CLARIFIÉE

### Règle Business Fondamentale

```
┌─────────────────────────────────────────────────────────────────┐
│                    SÉPARATION DES MARCHÉS                       │
├─────────────────────────────────────────────────────────────────┤
│  🇮🇳 MARCHÉ INDIEN (IN)                                         │
│  - Brides IN: Voient UNIQUEMENT pros IN                         │
│  - Pros IN: Voient UNIQUEMENT pros IN                           │
│  - PAS de filtres de localisation visibles (app = Inde only)    │
│  - Filtre pays BLOQUÉ sur "India"                               │
├─────────────────────────────────────────────────────────────────┤
│  🌍 MARCHÉ GLOBAL (reste du monde)                              │
│  - Brides GLOBAL: Voient pros GLOBAL (JAMAIS l'Inde)            │
│  - Pros GLOBAL: Voient pros GLOBAL (JAMAIS l'Inde)              │
│  - Filtres de localisation disponibles (pays, ville)            │
│  - L'Inde n'apparaît JAMAIS dans les options                    │
└─────────────────────────────────────────────────────────────────┘
```

### Détection Automatique du Marché

```sql
-- get_my_market_region()
-- 1. Check professional_details.location_country_code (pour pros)
-- 2. Check profiles.country (pour brides)
-- Retourne 'IN' si indien, 'GLOBAL' sinon
```

### Problème Feed Actuel

**`get_portfolio_feed` N'UTILISE PAS cette logique !**

```sql
-- Actuellement le feed utilise:
-- 1. countryCode passé en filtre (dropdown frontend)
-- 2. OU center + radiusKm (recherche adresse)
-- 
-- MAIS PAS is_visible_in_market() !
```

**Conséquence**: Un utilisateur indien pourrait voir des pros français.

### Solution Requise

```sql
-- Ajouter dans get_portfolio_feed:
v_my_market text := public.get_my_market_region();

-- Pour utilisateurs IN:
-- - Forcer le filtre sur 'IN' uniquement
-- - Ignorer tout filtre pays passé par le frontend

-- Pour utilisateurs GLOBAL:
-- - Appliquer is_visible_in_market() qui exclut automatiquement l'Inde
-- - Permettre filtrage par pays (sauf IN)
```

---

## 🔍 ANALYSE DES FILTRES - DÉCISION FINALE

### Filtres à Conserver

| Filtre | Marché IN | Marché GLOBAL | Notes |
|--------|-----------|---------------|-------|
| **Pays** | ❌ MASQUÉ (bloqué sur IN) | ✅ Visible (sans IN) | Dropdown simplifié |
| **Ville/Rayon** | ❌ MASQUÉ | ⚠️ À DISCUTER | Simplifier? "Autour de moi" ? |
| **Professions** | ✅ Visible | ✅ Visible | Chips dans sheet |
| **Budget** | ✅ Visible | ✅ Visible | Range slider |

### UI du Sheet de Filtres

**Le sheet s'ouvre depuis le HAUT de la page** (pas un bottom sheet):
- Fait partie intégrante de la page
- Animation slide down depuis le header
- Overlay semi-transparent sur le contenu

```dart
// Structure de la page Feed
Scaffold(
  body: Stack(
    children: [
      // Contenu principal (grille)
      FeedGrid(...),
      
      // Sheet de filtres (animé depuis le haut)
      if (_showFilters)
        AnimatedPositioned(
          top: _showFilters ? 0 : -filterHeight,
          child: FeedFilterSheet(...),
        ),
    ],
  ),
)
```

### Logique de Filtrage par Marché

```dart
// Pour utilisateur IN:
if (userMarket == 'IN') {
  // Masquer complètement les filtres de localisation
  // Forcer countryCode = 'IN' dans la requête
  showLocationFilters = false;
  forcedCountryCode = 'IN';
}

// Pour utilisateur GLOBAL:
else {
  // Afficher filtres de localisation
  // Dropdown pays SANS l'option "India"
  showLocationFilters = true;
  availableCountries = CountryFilter.values.where((c) => c != CountryFilter.india);
}
```

### Question Ouverte: Ville/Rayon

**Options possibles:**

| Option | Complexité | UX |
|--------|------------|----|
| A - Supprimer | Simple | Feed = découverte globale |
| B - "Autour de moi" (toggle) | Moyenne | Utilise position GPS + rayon fixe (100km?) |
| C - Sélection ville | Moyenne | Autocomplete ville, rayon fixe |
| D - Garder tel quel | Complexe | Adresse + slider rayon |

**Recommandation**: Option B ou C - Plus simple que l'actuel

---

## 🎯 BUT DU FEED - Clarification

### Objectif Business

Le Feed est une **vitrine d'inspiration** pour les Brides:
- Découvrir des pros via leurs photos
- Pas de recherche géographique précise (c'est le rôle de la Map)
- Monétisation via `feed_enabled` (feature payante pour les pros)

### Qui Voit Quoi ?

| Viewer | Voit | Logique |
|--------|------|---------|
| **Bride IN** | Pros IN avec `feed_enabled=true` ou `ambassador=true` | Market IN |
| **Bride GLOBAL** | Pros GLOBAL avec `feed_enabled=true` ou `ambassador=true` | Market GLOBAL |
| **Pro IN** | Pros IN (pour voir la concurrence) | Market IN |
| **Pro GLOBAL** | Pros GLOBAL | Market GLOBAL |

### Feed pour les Pros

**OUI**, les Pros doivent aussi voir le Feed:
- Voir ce que font les autres pros
- Découvrir des inspirations
- Même logique de market region

**Implémentation:**
- Ajouter onglet Feed dans navbar Pro (remplacer Profil)
- Réutiliser la même page `FeedPage`
- Adapter les actions (pas de "Contacter" entre pros depuis le feed)

---

## 📊 DONNÉES BACKEND - État Réel

### Colonnes Images V2

```sql
-- État actuel (tous les pros live):
-- slideshow_images_v2 = [] (vide)
-- portfolio_images_v2 = [] (vide)
-- slideshow_images = ['url1', 'url2', ...] (données legacy)
-- portfolio_images = ['url1', 'url2', ...] (données legacy)
```

**⚠️ BLOQUANT**: Le CRM doit synchroniser vers les colonnes V2 avant migration.

### Colonne Ambassador

```sql
-- profiles.ambassador (boolean) - EXISTE
-- Actuellement: tous les pros ont ambassador = false
-- À activer manuellement pour les ambassadeurs
```

### Colonne feed_enabled

```sql
-- professional_details.feed_enabled (boolean) - EXISTE
-- Actuellement: tous les pros ont feed_enabled = false
-- À activer quand un pro paie pour la feature Feed
```

### Fixed Locations

```sql
-- professional_fixed_locations
-- Contient: id, professional_profile_id, label, location_coords, location_country_code
-- Utilisé par: search_map_bundle, get_portfolio_feed (pour filtrage géo)
-- Un pro peut avoir plusieurs fixed_locations dans différents pays
```

---

## �️ ARCHITECTURE ACTUELLE

### Structure des Fichiers

```
lib/pages/bride/feed_brides/
├── feed_brides_widget.dart       # Page principale (609 lignes)
├── feed_brides_model.dart        # Model FlutterFlow (80 lignes)
├── feed_profession_grid.dart     # Grille checkboxes professions (125 lignes)
└── feed_profession_filter_grid.dart  # Variante (non utilisée?)

lib/pages/bride/feed_detail_viewer/
├── feed_detail_viewer_widget.dart  # Viewer fullscreen (384 lignes) ✅ Design System v3
└── feed_detail_viewer_model.dart   # Model

lib/custom_code/widgets/
└── feed_portfolio_grid.dart      # Widget grille images (337 lignes)

lib/custom_code/actions/
├── get_portfolio_feed_action.dart     # Action RPC principale (132 lignes)
└── get_feed_professionals_action.dart # Action alternative (109 lignes)

lib/backend/schema/structs/
├── feed_image_item_struct.dart   # Item image feed (244 lignes)
├── feed_page_result_struct.dart  # Résultat paginé (122 lignes)
└── feed_result_struct.dart       # Résultat alternatif (99 lignes)
```

### Flux de Données

```
FeedBridesWidget
    ↓ (filters: QueryFiltersStruct)
FeedPortfolioGrid (custom_widgets)
    ↓ (appelle RPC)
getPortfolioFeedAction()
    ↓ (Supabase RPC)
get_portfolio_feed(p_filters, p_cursor, p_page_size, p_seed)
    ↓ (retourne)
FeedPageResultStruct { items: [FeedImageItemStruct], nextCursor, newSeed }
    ↓ (tap sur image)
FeedDetailViewerWidget (fullscreen)
    ↓ (tap "View Profile")
ProDetailsWidget
```

---

## 🗄️ BACKEND - État Actuel

### Table `professional_details`

| Colonne | Type | Usage Actuel | Usage Cible |
|---------|------|--------------|-------------|
| `portfolio_images` | text[] | ✅ Utilisé par RPC | ❌ À remplacer |
| `portfolio_images_v2` | jsonb | ❌ Non utilisé | ✅ À utiliser |
| `slideshow_images` | text[] | ✅ Utilisé | ❌ À remplacer |
| `slideshow_images_v2` | jsonb | ❌ Non utilisé | ✅ À utiliser |
| `feed_enabled` | boolean | ❌ Non vérifié dans RPC | ✅ À implémenter |
| `is_live` | boolean | ✅ Vérifié | ✅ OK |
| `ambassador` | - | ❌ N'EXISTE PAS | ⚠️ À créer |

### État des Colonnes V2 (Données Réelles)

```sql
-- Résultat de l'audit:
-- Tous les pros ont slideshow_images_v2 et portfolio_images_v2 = []
-- Les données sont dans les colonnes legacy (slideshow_images, portfolio_images)
```

**⚠️ PROBLÈME CRITIQUE**: Les colonnes V2 existent mais sont **vides** (jsonb = `[]`). 
Le CRM doit synchroniser les données vers ces colonnes.

### RPC `get_portfolio_feed`

**Paramètres:**
- `p_filters` (jsonb): center, radiusKm, professions, budgetMin, budgetMax, countryCode
- `p_cursor` (text): Pagination cursor
- `p_page_size` (int): Taille page (max 60)
- `p_seed` (text): Seed pour randomisation

**Logique:**
1. Filtre par `subscription_tier IN ('premiumVisibility', 'ultimateAccess')`
2. Filtre par `is_live = true`
3. Filtre géographique via `professional_fixed_locations`
4. Filtre par professions
5. Filtre par budget (EUR)
6. **NE VÉRIFIE PAS** `feed_enabled`
7. Retourne images de `portfolio_images` (legacy, pas V2)

**Retour:**
```json
{
  "items": [
    {
      "imageUrl": "https://...",
      "imageIndex": 1,
      "proProfileId": "uuid",
      "proFullName": "Name",
      "proAvatarUrl": "https://...",
      "proProfession": "PHOTOGRAPHER",
      "proLocationLabel": "Paris, France",
      "isFavorited": true
    }
  ],
  "nextCursor": "base64...",
  "newSeed": "uuid"
}
```

### Table `wed_articles` (Wed of the Week)

**Structure:**
- `id` (uuid)
- `title` (jsonb): `{en: "...", fr: "..."}`
- `linked_pro_profile_id` (uuid)
- `cover_images` (text[])
- `content_blocks` (jsonb): Array de blocks (video, gallery, paragraph, single_image)
- `is_published` (boolean)
- `published_at` (timestamptz)
- `target_region` (text): 'all', 'IN', 'ROW'

**Données existantes:** 2 articles (1 publié pour IN, 1 non publié pour ROW)

---

## 📱 FRONTEND - Analyse Détaillée

### FeedBridesWidget (Page Principale)

**Structure UI:**
```
Scaffold
├── Stack
│   ├── Padding (top: 130, bottom: 90)
│   │   └── FeedPortfolioGrid (custom widget)
│   ├── NavBarBridesWidget (bottom)
│   ├── Header Container (top, height: 110)
│   │   ├── Row: "FILTER" + "View All/See Less"
│   │   └── Divider
│   └── Filter Panel (conditional, top: 110)
│       ├── Reset Filters
│       ├── Country Dropdown + City Search
│       ├── Distance Slider
│       ├── FeedProfessionGrid (checkboxes)
│       ├── CustomRangeSliderWidget (budget)
│       └── Apply Filters Button
```

**Problèmes Identifiés:**
1. ❌ Utilise `FlutterFlowTheme.of(context)` partout
2. ❌ Header hardcodé (pas de composant réutilisable)
3. ❌ Bouton "Apply filters" avec `FFButtonWidget` au lieu de `LynewedButton`
4. ⚠️ Padding top: 130 hardcodé (devrait utiliser SafeArea)
5. ⚠️ Slider et RangeSlider custom (à évaluer si à garder)

### FeedPortfolioGrid (Widget Grille)

**Fonctionnalités:**
- ✅ Pagination infinie (scroll listener à 80%)
- ✅ Déduplication par `proProfileId#imageIndex`
- ✅ Gestion des filtres avec comparaison deep
- ✅ Seed pour randomisation stable
- ✅ Loading state et empty state

**Problèmes Identifiés:**
1. ❌ `GridView` avec `childAspectRatio: 1/1.2` - Pas exactement 3:4
2. ❌ `Image.network` au lieu de `CachedNetworkImage`
3. ❌ `BorderRadius.circular(0)` - Devrait être 4px selon Design System
4. ❌ Empty state en français hardcodé

**Aspect Ratio Actuel vs Cible:**
- Actuel: `1/1.2` = 0.833 (proche de 4:5)
- Cible: `3/4` = 0.75 (format vertical standard)

### FeedDetailViewerWidget (Fullscreen)

**✅ DÉJÀ DESIGN SYSTEM V3:**
- Utilise `LynewedColors`, `LynewedTextStyles`
- Utilise `LynewedButton`
- Utilise `CachedNetworkImage`
- Bottom sheet avec radius 24px

**Problèmes Identifiés:**
1. ❌ Affiche l'image originale, pas le crop 9:16
2. ❌ Pas de navigation entre images du même pro
3. ⚠️ `InteractiveViewer` pour zoom (OK mais à tester)

### FeedProfessionGrid (Checkboxes)

**Fonctionnalités:**
- ✅ Grille 3 colonnes (4-4-4 professions)
- ✅ Utilise `getProfessionDisplayName()` pour labels

**Problèmes Identifiés:**
1. ❌ Utilise `FlutterFlowTheme.of(context)`
2. ❌ Checkboxes avec `ThemeData` custom au lieu de style unifié
3. ⚠️ Pas de chips (checkboxes classiques)

---

## 🎨 ÉCARTS DESIGN SYSTEM V3

### Composants à Migrer

| Composant | Actuel | Cible |
|-----------|--------|-------|
| Header | Custom hardcodé | Pattern MessagesPage |
| Divider | `FlutterFlowTheme.secondary` | `LynewedColors.gray200` |
| Bouton Apply | `FFButtonWidget` | `LynewedButton` |
| Checkboxes | `ThemeData` custom | `LynewedChip` ou style unifié |
| Slider | `FlutterFlowTheme.primary` | `LynewedColors.primary` |
| Empty State | Texte français | Design unifié |
| Grid Items | radius 0 | radius 4px |

### Tokens Manquants

```dart
// Actuel
FlutterFlowTheme.of(context).primaryBackground
FlutterFlowTheme.of(context).bodyMedium
FlutterFlowTheme.of(context).primary
FlutterFlowTheme.of(context).secondary

// Cible
LynewedColors.background
LynewedTextStyles.bodyMedium
LynewedColors.primary
LynewedColors.gray200
```

---

## 📊 STRUCTS - Analyse

### FeedImageItemStruct

```dart
class FeedImageItemStruct {
  String? imageUrl;        // URL de l'image (legacy, pas de crops)
  int? imageIndex;         // Index dans le portfolio
  String? proProfileId;    // ID du pro
  String? proFullName;     // Nom complet
  String? proAvatarUrl;    // Avatar
  Profession? proProfession; // Profession enum
  String? proLocationLabel;  // Label localisation
  bool? isFavorited;       // Favori de l'utilisateur
}
```

**Champs Manquants pour V2:**
- `crop_1x1` (String)
- `crop_3x4` (String)
- `crop_9x16` (String)
- `photoId` (String) - Pour matching entre crops

### QueryFiltersStruct

```dart
class QueryFiltersStruct {
  List<Profession> professions;
  double? budgetMin;
  double? budgetMax;
  String? currency;
  LatLng? center;
  double? radiusKm;
  String? countryCode;
}
```

**OK - Pas de modifications nécessaires**

---

## 🔄 SYSTÈME MULTI-FORMAT IMAGES

### État Actuel

```
CRM génère → 4 versions (original, crop_1x1, crop_3x4, crop_9x16)
           ↓
Sync vers APP → Colonnes V2 (jsonb avec tous les crops)
           ↓
APP utilise → ❌ Colonnes legacy (text[] avec URLs simples)
```

### Format V2 Attendu

```json
[
  {
    "id": "abc-123-uuid",
    "crop_1x1": "https://.../crop_1x1.jpg",
    "crop_3x4": "https://.../crop_3x4.jpg",
    "crop_9x16": "https://.../crop_9x16.jpg"
  }
]
```

### Utilisation par Écran

| Écran | Colonne | Crop Affiché | Fullscreen |
|-------|---------|--------------|------------|
| Feed Grid | `portfolio_images_v2` | `crop_3x4` | `crop_9x16` |
| ProDetails Header | `slideshow_images_v2` | `crop_1x1` | `crop_9x16` |
| ProDetails Portfolio | `portfolio_images_v2` | `crop_3x4` | `crop_9x16` |

---

## 🎯 SYSTÈME AMBASSADEURS

### État Actuel
- ✅ Colonne `ambassador` EXISTE dans `profiles` (pas `professional_details`)
- ❌ Aucune logique ambassadeur dans le code Feed
- ❌ Tous les pros ont `ambassador = false` actuellement

### Implémentation Requise

1. **PAS de migration SQL** - La colonne existe déjà dans `profiles`

2. **Logique RPC:**
```sql
-- Modifier get_portfolio_feed pour:
-- 1. Joindre profiles pour récupérer ambassador
-- 2. Inclure ambassadeurs même si feed_enabled = false
-- 3. Trier ambassadeurs en premier
JOIN public.profiles pr ON ps.profile_id = pr.id
WHERE (pd.feed_enabled = true OR pr.ambassador = true)
ORDER BY pr.ambassador DESC, ...
```

3. **Frontend:**
- Badge "AMBASSADOR" sur les cards
- Priorité visuelle (icône étoile dorée?)

---

## 📰 WED OF THE WEEK

### État Actuel
- ✅ Table `wed_articles` existe avec données
- ❌ Pas d'intégration dans le Feed
- ❌ Pas de page de visualisation

### Structure Content Blocks

```json
[
  {"type": "video", "url": "https://youtu.be/...", "platform": "youtube"},
  {"type": "gallery", "urls": [...], "layout": "grid", "columns": 2},
  {"type": "paragraph", "content": {"en": "...", "fr": "..."}},
  {"type": "single_image", "urls": [...]}
]
```

### Intégration Proposée

1. **Section en haut du Feed** (si article publié pour la région)
2. **Card spéciale** avec cover image et titre
3. **Page dédiée** pour visualiser l'article complet
4. **Réutiliser** `YouTubeVimeoPlayer` de ProDetails

### ⚠️ Impact Images V2

Les images du Wed of the Week doivent aussi utiliser le système multi-format:
- Cover images: `crop_3x4` pour la card, `crop_9x16` pour fullscreen
- Gallery images: même logique

---

## 🔧 BUGS CONNUS À CORRIGER

### Bug: Localisation Bloquée sur Paris

**Problème**: Dans `FeedDetailViewerWidget`, la localisation affichée est toujours "Paris" au lieu de la vraie localisation du pro.

**Cause probable**: Le champ `proLocationLabel` n'est pas mis à jour dynamiquement ou est hardcodé.

**Solution**: Vérifier que `FeedImageItemStruct.proLocationLabel` est bien passé depuis la RPC et affiché correctement.

---

## 🌐 IMPACT GLOBAL - AUTRES MODULES

### ProDetails - Même Migration Images V2

Le module ProDetails doit aussi migrer vers les colonnes V2:

| Écran | Colonne | Crop Affiché | Fullscreen |
|-------|---------|--------------|------------|
| Header Slider | `slideshow_images_v2` | `crop_1x1` | `crop_9x16` |
| Portfolio Grid | `portfolio_images_v2` | `crop_3x4` | `crop_9x16` |

**À faire en même temps que le Feed pour cohérence.**

### Map - Déjà Bien Géré

La Map utilise déjà `is_visible_in_market()` dans `search_map_bundle`:
- ✅ Pros IN visibles uniquement pour viewers IN
- ✅ Pros GLOBAL visibles uniquement pour viewers GLOBAL
- ✅ Filtrage par `professional_fixed_locations`

**Le Feed doit s'inspirer de cette logique.**

---

## ✅ ACTIONS REQUISES

### Phase 1 - Migration Images V2 (8-12h)

| Tâche | Priorité | Estimation |
|-------|----------|------------|
| Vérifier sync CRM → colonnes V2 | 🔴 BLOQUANT | 2h |
| Modifier RPC `get_portfolio_feed` pour V2 | 🔴 | 3h |
| Créer `FeedImageItemV2Struct` avec crops | 🟡 | 1h |
| Modifier `FeedPortfolioGrid` pour crop_3x4 | 🟡 | 2h |
| Modifier `FeedDetailViewerWidget` pour crop_9x16 | 🟡 | 2h |
| Ajouter navigation entre photos | 🟢 | 2h |

### Phase 2 - Design System v3 (4-6h)

| Tâche | Priorité | Estimation |
|-------|----------|------------|
| Migrer `FeedBridesWidget` vers Design System | 🟡 | 2h |
| Migrer `FeedProfessionGrid` | 🟡 | 1h |
| Créer header unifié | 🟡 | 1h |
| Corriger aspect ratio grille (3:4) | 🟢 | 0.5h |
| Ajouter radius 4px aux items | 🟢 | 0.5h |
| Utiliser `CachedNetworkImage` | 🟢 | 1h |

### Phase 3 - Ambassadeurs (4-6h)

| Tâche | Priorité | Estimation |
|-------|----------|------------|
| Migration SQL `ambassador` | 🟡 | 0.5h |
| Modifier RPC pour ambassadeurs | 🟡 | 2h |
| Ajouter badge UI | 🟡 | 1h |
| Tri prioritaire | 🟢 | 1h |
| Tests | 🟢 | 1h |

### Phase 4 - Wed of the Week (6-8h)

| Tâche | Priorité | Estimation |
|-------|----------|------------|
| RPC `get_current_wed_article` | 🟡 | 2h |
| Card Wed of the Week dans Feed | 🟡 | 2h |
| Page article complète | 🟡 | 3h |
| Intégration vidéo | 🟢 | 1h |

### Phase 5 - Logique feed_enabled (2h)

| Tâche | Priorité | Estimation |
|-------|----------|------------|
| Ajouter vérification `feed_enabled` dans RPC | 🟡 | 1h |
| Tests avec différents états | 🟢 | 1h |

---

## 📊 ESTIMATION TOTALE

| Phase | Heures | Priorité |
|-------|--------|----------|
| Migration Images V2 | 8-12h | 🔴 CRITIQUE |
| Design System v3 | 4-6h | 🟡 IMPORTANTE |
| Ambassadeurs | 4-6h | 🟡 IMPORTANTE |
| Wed of the Week | 6-8h | 🟢 MODÉRÉE |
| Logique feed_enabled | 2h | 🟢 MODÉRÉE |
| **TOTAL** | **24-34h** | |

---

## 🚨 BLOQUANTS IDENTIFIÉS

1. **Colonnes V2 vides** - Le CRM doit synchroniser les données vers `portfolio_images_v2` et `slideshow_images_v2`
2. ~~**Colonne ambassador manquante**~~ - ✅ Existe dans `profiles`
3. **Dépendance FlutterFlow** - Plusieurs composants utilisent encore `FlutterFlowTheme`
4. **Market Region manquant** - `get_portfolio_feed` doit utiliser `is_visible_in_market()`

---

## ❓ DÉCISIONS À PRENDRE AVANT REFACTORING

### 1. Filtres du Feed - Simplification ?

**Question**: Garder la recherche par adresse + rayon ou simplifier ?

| Option | Avantages | Inconvénients |
|--------|-----------|---------------|
| **A - Garder** | Plus de contrôle pour l'utilisateur | Complexe, redondant avec Map |
| **B - Simplifier** | UX plus claire, Feed = découverte | Moins de filtrage géo |

**Recommandation**: **Option B** - Le Feed est pour l'inspiration, la Map pour la recherche géo.

### 2. Filtres dans un Sheet ?

**Question**: Ouvrir les filtres dans un Sheet au lieu de superposer sur la page ?

**Recommandation**: **OUI** - Utiliser le pattern `FilterSheet` de la Map pour cohérence.

### 3. Feed pour les Pros ?

**Question**: Les Pros doivent-ils voir le Feed ?

**Recommandation**: **OUI** - Ajouter onglet Feed dans navbar Pro (remplacer Profil qui va dans Settings).

### 4. Aspect Ratio des Images

**Question**: Garder 1:1.2 actuel ou passer à 3:4 strict ?

| Format | Ratio | Usage |
|--------|-------|-------|
| Actuel | 1:1.2 (0.833) | Proche de 4:5 |
| Cible | 3:4 (0.75) | Format vertical standard |

**Recommandation**: **3:4** - Correspond au crop_3x4 des colonnes V2.

### 5. Migration V2 - Fallback Legacy ?

**Question**: Supporter les deux formats (V2 + legacy) pendant la transition ?

**Recommandation**: **OUI** - Fallback sur legacy si V2 vide:
```sql
COALESCE(
  (SELECT url FROM jsonb_array_elements(pd.portfolio_images_v2) LIMIT 1),
  pd.portfolio_images[1]
)
```

---

## 📁 FICHIERS À MODIFIER

### Backend (Supabase)
- `get_portfolio_feed` RPC - Utiliser V2, ajouter feed_enabled, ambassador
- Migration SQL - Ajouter colonne `ambassador`

### Frontend (Flutter)
- `lib/pages/bride/feed_brides/feed_brides_widget.dart`
- `lib/pages/bride/feed_brides/feed_profession_grid.dart`
- `lib/custom_code/widgets/feed_portfolio_grid.dart`
- `lib/custom_code/actions/get_portfolio_feed_action.dart`
- `lib/backend/schema/structs/feed_image_item_struct.dart`
- `lib/pages/bride/feed_detail_viewer/feed_detail_viewer_widget.dart`

### Nouveaux Fichiers (Clean Architecture)
```
lib/features/feed/
├── domain/
│   ├── entities/
│   │   ├── feed_item.dart
│   │   └── photo_with_crops.dart
│   └── repositories/
│       └── feed_repository.dart
├── data/
│   ├── datasources/
│   │   └── feed_remote_datasource.dart
│   └── repositories/
│       └── feed_repository_impl.dart
└── presentation/
    ├── pages/
    │   ├── feed_page.dart
    │   └── wed_article_page.dart
    ├── widgets/
    │   ├── feed_grid.dart
    │   ├── feed_item_card.dart
    │   ├── photo_fullscreen_viewer.dart
    │   └── wed_article_card.dart
    └── providers/
        └── feed_provider.dart
```

---

---

## 🎯 DÉCISIONS FINALES VALIDÉES

| Question | Décision |
|----------|----------|
| **Approche** | Pragmatique - modifier fichiers existants |
| **Filtre localisation** | Dropdown pays + "Autour de moi" (mutuellement exclusifs) |
| **Utilisateurs IN** | Filtres localisation MASQUÉS, India forcé |
| **Utilisateurs GLOBAL** | Dropdown pays SANS India |
| **Nouvelles professions** | 6 ajoutées (3 IN-only, 3 GLOBAL-only) |
| **Design System** | Garder 90% actuel, ajuster à la fin |
| **Images V2** | Phase 1.5 (après MVP) |

---

**Créé:** 2025-12-05  
**Dernière mise à jour:** 2025-12-05  
**Auteur:** Cascade AI  
**Prochaine étape:** Implémenter Phase 1 MVP (6-7h)
