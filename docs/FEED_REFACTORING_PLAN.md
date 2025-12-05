# 📱 FEED REFACTORING PLAN - V5 (RAPIDE & PRAGMATIQUE)

> **Version**: 5.0  
> **Date**: 2025-12-05  
> **Priorité**: 🔴 CRITIQUE (livraison rapide)  
> **Estimation MVP**: 6-7 heures  
> **Estimation Complète**: 16-19 heures (avec Phase 1.5)  
> **Audit**: `docs/audits/FEED_FEATURE_AUDIT.md`
> **Guide Images**: `docs/GUIDE_EQUIPE_APP_MULTI_FORMAT_IMAGES.md`
> **TODO**: `docs/TODO_FINALISATION.md`

---

## 🎯 OBJECTIF: LIVRAISON RAPIDE

**Approche pragmatique:**
- ❌ PAS de réécriture complète Clean Architecture
- ✅ Modifier les fichiers existants directement
- ✅ Garder le design actuel (90% correct)
- ✅ Ajouter seulement les fonctionnalités critiques
- ✅ Ajuster le design à la fin si temps

---

## 🧠 DÉCISIONS FINALES - RAPIDITÉ

| Question | Décision | Raison |
|----------|----------|--------|
| **Architecture** | Modifier fichiers existants | Pas le temps de réécrire |
| **Filtre localisation** | Dropdown pays + bouton "Autour de moi" (mutuellement exclusifs) | UX claire |
| **Filtres dans Sheet** | ✅ OUI (depuis le HAUT) | Sheet intégré |
| **Nouvelles professions** | Ajouter aux enums existants | Extension rapide |
| **Design System** | Minimal, seulement si nécessaire | Garder 90% actuel |
| **Images V2** | Fallback legacy si V2 vide | Transition progressive |

---

## 🌍 LOGIQUE MARKET REGION + FILTRES

### Règles Marché

```
🇮🇳 UTILISATEUR INDIEN:
├── Voit UNIQUEMENT pros IN
├── Filtre pays: MASQUÉ (India only)
├── Localisation: MASQUÉE
└── Filtres: Professions (IN) + Budget

🌍 UTILISATEUR GLOBAL:
├── Voit pros GLOBAL (JAMAIS India)
├── Filtre pays: TOUS SAUF India
├── Localisation: Dropdown pays OU "Autour de moi"
└── Filtres: Professions (GLOBAL) + Budget
```

### Filtre Localisation (Utilisateurs GLOBAL)

**Nouvelle logique (mutuellement exclusifs):**

```dart
// Dans FeedFilterSheet:
enum LocationMode {
  country,    // Dropdown pays sélectionné
  nearby,     // Bouton "Autour de moi" activé
}

Widget _buildLocationFilter() {
  return Column(
    children: [
      // Toggle pour choisir le mode
      Row(
        children: [
          Expanded(
            child: RadioListTile<LocationMode>(
              title: Text('Country'),
              value: LocationMode.country,
              groupValue: _locationMode,
              onChanged: (value) => setState(() => _locationMode = value!),
            ),
          ),
          Expanded(
            child: RadioListTile<LocationMode>(
              title: Text('Around me'),
              value: LocationMode.nearby,
              groupValue: _locationMode,
              onChanged: (value) => setState(() => _locationMode = value!),
            ),
          ),
        ],
      ),
      
      // Afficher le bon filtre selon le mode
      if (_locationMode == LocationMode.country)
        _buildCountryDropdown(excludeIndia: true),
      if (_locationMode == LocationMode.nearby)
        _buildNearbyFilter(),
    ],
  );
}
```

---

## 🎨 NOUVELLES PROFESSIONS

### Liste Complète (20 professions)

**Tous marchés:**
```
PHOTOGRAPHER, FILMMAKER, PLANNER, MAKEUP, HAIRDRESSER, DESIGNER, 
BRIDALDESIGNER, VENUE, BRIDALSHOP, FLORIST, PHOTOMOVIE, MAKEUPARTIST, 
EVENTDESIGNER, OTHER
```

**🇮🇳 Inde uniquement:**
```
CATERER, DJ, BRIDALWEARDESIGNER
```

**🌍 Monde entier:**
```
JEWELLER, STATIONER, CONTENTCREATOR
```

### Implémentation Rapide

```dart
// Étendre l'enum existant dans:
// lib/backend/schema/enums/profession_enum.dart
enum Profession {
  // ... existantes ...
  caterer,
  dj,
  bridalWearDesigner,
  jeweller,
  stationer,
  contentCreator,
}

// Ajouter la logique de filtrage par marché:
List<Profession> getAvailableProfessions(String market) {
  if (market == 'IN') {
    return Profession.values.where((p) => 
      !globalOnlyProfessions.contains(p)
    ).toList();
  } else {
    return Profession.values.where((p) => 
      !indiaOnlyProfessions.contains(p)
    ).toList();
  }
}
```

---

## 🚨 CORRECTIONS CRITIQUES BACKEND

### 1. Market Region Manquant (CRITIQUE)

**Problème**: `get_portfolio_feed` n'utilise PAS `is_visible_in_market()` !

```sql
-- AJOUTER dans get_portfolio_feed:
v_my_market text := public.get_my_market_region();

-- AJOUTER dans le WHERE:
AND public.is_visible_in_market(pd.location_country_code, v_my_market)
```

### 2. feed_enabled + ambassador Ignorés

```sql
-- AJOUTER dans le WHERE:
AND (pd.feed_enabled = true OR pr.ambassador = true)

-- AJOUTER dans le ORDER BY:
ORDER BY pr.ambassador DESC, sort_key ASC
```

### 3. Colonnes V2 Vides (BLOQUANT CRM)
```sql
-- État actuel: portfolio_images_v2 = [] pour tous les pros
-- Le CRM doit synchroniser les données
```
**Action**: Vérifier Edge Function de sync CRM → APP

### 4. Ambassador Existe Déjà
```sql
-- profiles.ambassador (boolean) - EXISTE
-- PAS BESOIN de migration SQL
```

---

## 📋 PLAN D'IMPLÉMENTATION RÉVISÉ

### 🔴 PHASE 1 - CORRECTIONS BACKEND CRITIQUES (4-5h)

#### 1.1 Modifier RPC `get_portfolio_feed` (3-4h)

**Changements OBLIGATOIRES:**

```sql
CREATE OR REPLACE FUNCTION get_portfolio_feed(
  p_filters jsonb DEFAULT '{}',
  p_cursor text DEFAULT NULL,
  p_page_size int DEFAULT 30,
  p_seed text DEFAULT NULL
) RETURNS jsonb AS $$
DECLARE
  v_viewer_id uuid := auth.uid();
  v_my_market text := public.get_my_market_region();  -- AJOUT CRITIQUE
  -- ... autres variables
BEGIN
  -- ... parsing des filtres (SUPPRIMER countryCode, center, radiusKm)
  
  WITH base_items AS (
    SELECT
      ps.profile_id,
      pr.full_name,
      pr.avatar_url,
      pr.ambassador,  -- AJOUT
      pd.profession,
      pd.location_label,
      -- Fallback V2 → legacy
      COALESCE(
        (SELECT elem->>'crop_3x4' FROM jsonb_array_elements(pd.portfolio_images_v2) elem LIMIT 1),
        pd.portfolio_images[1]
      ) AS image_url,
      -- ...
    FROM professional_subscriptions ps
    JOIN professional_details pd ON ps.profile_id = pd.profile_id
    JOIN profiles pr ON ps.profile_id = pr.id
    -- ...
    WHERE
      ps.subscription_tier IN ('premiumVisibility', 'ultimateAccess')
      AND pd.is_live = true
      AND (pd.feed_enabled = true OR pr.ambassador = true)  -- AJOUT
      AND public.is_visible_in_market(pd.location_country_code, v_my_market)  -- AJOUT CRITIQUE
      AND (/* filtres professions, budget */)
    ORDER BY pr.ambassador DESC, sort_key ASC  -- Ambassadeurs en premier
  )
  -- ...
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### 1.2 Vérification Sync CRM (1h)
- [ ] Vérifier Edge Function sync vers `*_images_v2`
- [ ] Si vide, implémenter fallback legacy dans RPC
- [ ] Documenter le format JSON attendu

**Nouveau format de retour:**
```json
{
  "items": [
    {
      "photoId": "abc-123",
      "crop3x4": "https://.../crop_3x4.jpg",
      "crop9x16": "https://.../crop_9x16.jpg",
      "proProfileId": "uuid",
      "proFullName": "Name",
      "proAvatarUrl": "https://...",
      "proProfession": "PHOTOGRAPHER",
      "proLocationLabel": "Paris, France",
      "isAmbassador": true,
      "isFavorited": false
    }
  ],
  "nextCursor": "...",
  "newSeed": "..."
}
```

---

### 🟡 PHASE 2 - FRONTEND STRUCTS & ACTIONS (3-4h)

#### 2.1 Nouveau Struct `FeedImageItemV2Struct`

```dart
// lib/backend/schema/structs/feed_image_item_v2_struct.dart
class FeedImageItemV2Struct extends BaseStruct {
  String? photoId;         // ID unique de la photo
  String? crop3x4;         // URL crop 3:4 pour grille
  String? crop9x16;        // URL crop 9:16 pour fullscreen
  String? proProfileId;
  String? proFullName;
  String? proAvatarUrl;
  Profession? proProfession;
  String? proLocationLabel;
  bool? isAmbassador;      // NOUVEAU
  bool? isFavorited;
}
```

#### 2.2 Modifier `getPortfolioFeedAction`

```dart
// Adapter le parsing pour le nouveau format
feedItems.add(
  FeedImageItemV2Struct(
    photoId: item['photoId'] as String?,
    crop3x4: item['crop3x4'] as String?,
    crop9x16: item['crop9x16'] as String?,
    proProfileId: item['proProfileId']?.toString(),
    proFullName: item['proFullName'] as String?,
    proAvatarUrl: item['proAvatarUrl'] as String?,
    proProfession: professionFromString(item['proProfession'] as String?),
    proLocationLabel: item['proLocationLabel'] as String?,
    isAmbassador: item['isAmbassador'] as bool? ?? false,
    isFavorited: item['isFavorited'] as bool? ?? false,
  ),
);
```

---

### 🟡 PHASE 3 - UI FILTRES & DESIGN SYSTEM (5-7h)

#### 3.1 Créer FeedFilterSheet (depuis le HAUT) (3h)

**Sheet intégré à la page, s'ouvre depuis le haut:**

```dart
// lib/features/feed/presentation/widgets/feed_filter_sheet.dart
class FeedFilterSheet extends StatefulWidget {
  final FeedFilter currentFilter;
  final bool isIndianMarket;  // Détermine quels filtres afficher
  final VoidCallback onApply;
  
  // ...
}

// Structure de la page avec sheet intégré:
class FeedPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Grille de photos
          FeedGrid(...),
          
          // Sheet de filtres (animé depuis le haut)
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            top: _showFilters ? 0 : -_filterSheetHeight,
            left: 0,
            right: 0,
            child: FeedFilterSheet(
              isIndianMarket: _userMarket == 'IN',
              currentFilter: _currentFilter,
              onApply: _applyFilters,
            ),
          ),
          
          // Overlay semi-transparent
          if (_showFilters)
            GestureDetector(
              onTap: () => setState(() => _showFilters = false),
              child: Container(color: Colors.black26),
            ),
        ],
      ),
    );
  }
}
```

#### 3.2 Contenu du FeedFilterSheet selon Marché (1h)

```dart
// Pour utilisateur INDIEN:
if (isIndianMarket) {
  return Column(
    children: [
      // PAS de filtre pays (bloqué sur India)
      // PAS de filtre ville/rayon
      _buildProfessionChips(),
      _buildBudgetSlider(),
      _buildApplyButton(),
    ],
  );
}

// Pour utilisateur GLOBAL:
else {
  return Column(
    children: [
      _buildCountryDropdown(excludeIndia: true),  // Sans India
      _buildLocationFilter(),  // "Autour de moi" ou ville
      _buildProfessionChips(),
      _buildBudgetSlider(),
      _buildApplyButton(),
    ],
  );
}
```

#### 3.3 Simplifier Filtre Localisation (1h)

**Option recommandée: "Autour de moi" toggle + ville**

```dart
// Remplacer AddressSearchWidget + slider par:
Widget _buildLocationFilter() {
  return Column(
    children: [
      // Toggle "Autour de moi"
      SwitchListTile(
        title: Text('Around me'),
        subtitle: Text('Show pros within 100km'),
        value: _nearbyMode,
        onChanged: (v) => setState(() => _nearbyMode = v),
      ),
      
      // OU sélection de ville (si pas nearby)
      if (!_nearbyMode)
        CityAutocomplete(
          onCitySelected: (city) => _selectedCity = city,
        ),
    ],
  );
}
```

#### 3.4 Design System Migration (1h)

**Avant:**
```dart
Text(
  'FILTER',
  style: FlutterFlowTheme.of(context).bodyMedium.override(
    fontFamily: 'Haas Grot Text Trial',
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
  ),
)
```

**Après:**
```dart
import '/core/design/design.dart';

Text(
  'FILTER',
  style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18),
)
```

#### 3.2 FeedBridesWidget - Bouton Apply (0.5h)

**Avant:**
```dart
FFButtonWidget(
  onPressed: () async { ... },
  text: 'Apply filters',
  options: FFButtonOptions(
    color: FlutterFlowTheme.of(context).primary,
    borderRadius: BorderRadius.circular(4.0),
  ),
)
```

**Après:**
```dart
LynewedButton(
  text: 'Apply filters',
  onPressed: () { ... },
  type: LynewedButtonType.primary,
  width: double.infinity,
)
```

#### 3.3 FeedBridesWidget - Divider (0.5h)

**Avant:**
```dart
Container(
  height: 1.0,
  decoration: BoxDecoration(
    color: FlutterFlowTheme.of(context).secondary,
  ),
)
```

**Après:**
```dart
const Divider(height: 1, color: LynewedColors.gray200)
```

#### 3.4 FeedProfessionGrid - Checkboxes (1h)

**Option A - Garder checkboxes avec style unifié:**
```dart
Theme(
  data: ThemeData(
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  ),
  child: Checkbox(
    activeColor: LynewedColors.primary,
    side: BorderSide(color: LynewedColors.gray300, width: 1.5),
    ...
  ),
)
```

**Option B - Migrer vers LynewedChip:**
```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: professions.map((prof) => 
    LynewedChip(
      label: getProfessionDisplayName(prof),
      selected: filters?.professions.contains(prof) ?? false,
      onTap: () => _toggleProfession(prof),
    ),
  ).toList(),
)
```

#### 3.5 FeedPortfolioGrid - Items (1h)

**Avant:**
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(0),
  child: Image.network(url, ...),
)
```

**Après:**
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(4), // Design System v3
  child: CachedNetworkImage(
    imageUrl: item.crop3x4, // Utiliser crop 3:4
    fit: BoxFit.cover,
    placeholder: (_, __) => Container(color: LynewedColors.surface),
    errorWidget: (_, __, ___) => Container(
      color: LynewedColors.surface,
      child: Icon(Icons.broken_image, color: LynewedColors.gray300),
    ),
  ),
)
```

#### 3.6 Aspect Ratio Correction (0.5h)

**Avant:**
```dart
SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  childAspectRatio: (1 / 1.2), // ~0.833
)
```

**Après:**
```dart
SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  crossAxisSpacing: 4,
  mainAxisSpacing: 4,
  childAspectRatio: 3 / 4, // 0.75 - Format vertical standard
)
```

#### 3.7 Empty State Unifié (0.5h)

```dart
if (_items.isEmpty && !_isLoading) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off_outlined,
          size: 64,
          color: LynewedColors.gray300,
        ),
        const SizedBox(height: 16),
        Text(
          'No inspiration found',
          style: LynewedTextStyles.bodyLarge.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Try adjusting your filters',
          style: LynewedTextStyles.bodySmall.copyWith(
            color: LynewedColors.gray300,
          ),
        ),
      ],
    ),
  );
}
```

---

### 🟡 PHASE 4 - FULLSCREEN VIEWER V2 (3-4h)

#### 4.1 Utiliser crop_9x16

```dart
// FeedDetailViewerWidget
Widget _buildImage(FeedImageItemV2Struct? feed) {
  // Utiliser crop 9:16 pour fullscreen
  final imageUrl = feed?.crop9x16 ?? feed?.crop3x4 ?? '';
  
  return InteractiveViewer(
    child: CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      ...
    ),
  );
}
```

#### 4.2 Navigation Entre Photos (2h)

```dart
// Ajouter PageView pour navigation horizontale
class FeedDetailViewerWidget extends StatefulWidget {
  final List<FeedImageItemV2Struct> allPhotos; // Toutes les photos du pro
  final int initialIndex;
  
  // ...
}

// Dans le build:
PageView.builder(
  controller: PageController(initialPage: widget.initialIndex),
  itemCount: widget.allPhotos.length,
  itemBuilder: (context, index) {
    final photo = widget.allPhotos[index];
    return _buildImage(photo);
  },
)
```

#### 4.3 Badge Ambassadeur (0.5h)

```dart
// Dans bottom info bar
if (feed.isAmbassador == true)
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFD4AF37), // Or
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      'AMBASSADOR',
      style: LynewedTextStyles.labelSmall.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
```

---

### 🟢 PHASE 5 - WED OF THE WEEK (6-8h)

#### 5.1 RPC `get_current_wed_article` (2h)

```sql
CREATE OR REPLACE FUNCTION get_current_wed_article(p_region text DEFAULT 'all')
RETURNS jsonb AS $$
BEGIN
  RETURN (
    SELECT jsonb_build_object(
      'id', wa.id,
      'title', wa.title,
      'coverImages', wa.cover_images,
      'contentBlocks', wa.content_blocks,
      'linkedProProfileId', wa.linked_pro_profile_id,
      'publishedAt', wa.published_at
    )
    FROM wed_articles wa
    WHERE wa.is_published = true
      AND (wa.target_region = 'all' OR wa.target_region = p_region)
    ORDER BY wa.published_at DESC
    LIMIT 1
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### 5.2 Card Wed of the Week (2h)

```dart
// lib/features/feed/presentation/widgets/wed_article_card.dart
class WedArticleCard extends StatelessWidget {
  final WedArticleStruct article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: LynewedColors.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              child: CachedNetworkImage(
                imageUrl: article.coverImages.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WEDDING OF THE WEEK',
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title['en'] ?? '',
                    style: LynewedTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 5.3 Page Article (3h)

```dart
// lib/features/feed/presentation/pages/wed_article_page.dart
class WedArticlePage extends StatelessWidget {
  final WedArticleStruct article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: CustomScrollView(
        slivers: [
          // Header avec cover image
          SliverAppBar(
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: article.coverImages.first,
                fit: BoxFit.cover,
              ),
            ),
            leading: _buildBackButton(context),
          ),
          
          // Content blocks
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildContentBlock(article.contentBlocks[index]),
              childCount: article.contentBlocks.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBlock(Map<String, dynamic> block) {
    switch (block['type']) {
      case 'video':
        return YouTubeVimeoPlayer(url: block['url']);
      case 'gallery':
        return _buildGallery(block['urls'], block['columns']);
      case 'paragraph':
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            block['content']['en'] ?? '',
            style: LynewedTextStyles.bodyMedium,
          ),
        );
      case 'single_image':
        return CachedNetworkImage(imageUrl: block['urls'][0]);
      default:
        return const SizedBox.shrink();
    }
  }
}
```

---

## 📊 TIMELINE ULTRA-RAPIDE - MINIMUM VIABLE

| Phase | Heures | Jours | Priorité | Fichiers Modifiés |
|-------|--------|-------|----------|-------------------|
| Phase 1 - Backend RPC (patch) | 2h | 0.25 jour | 🔴 CRITIQUE | `get_portfolio_feed` |
| Phase 2 - Enums + Professions | 1h | 0.25 jour | 🔴 CRITIQUE | `profession_enum.dart` |
| Phase 3 - Filtres Localisation | 2-3h | 0.5 jour | 🟡 IMPORTANTE | `FeedBridesWidget` |
| Phase 4 - Feed pour Pros | 1h | 0.25 jour | 🟡 IMPORTANTE | `NavBarProsWidget` |
| **TOTAL** | **6-7h** | **1 jour** | | |

---

## 🎯 PLAN ULTRA-RAPIDE - PATCH DIRECT

### Phase 1: Patch RPC `get_portfolio_feed` (2h)

**Modification MINIMALE mais COMPLÈTE:**
```sql
-- Ajouter les lignes manquantes:
WHERE pd.is_live = true
  AND (pd.feed_enabled = true OR pr.ambassador = true)  -- AJOUT
  AND public.is_visible_in_market(pd.location_country_code, v_my_market)  -- AJOUT
  -- CRITIQUE: Filtrer professions par marché
  AND (
    p_professions IS NULL
    OR (
      v_my_market = 'IN' AND pd.profession = ANY(ARRAY[
        'PHOTOGRAPHER', 'FILMMAKER', 'PLANNER', 'MAKEUP', 'HAIRDRESSER', 
        'DESIGNER', 'BRIDALDESIGNER', 'VENUE', 'BRIDALSHOP', 'FLORIST', 
        'PHOTOMOVIE', 'MAKEUPARTIST', 'EVENTDESIGNER', 'OTHER',
        'CATERER', 'DJ', 'BRIDALWEARDESIGNER'  -- IN only
      ])
    )
    OR (
      v_my_market = 'GLOBAL' AND pd.profession = ANY(ARRAY[
        'PHOTOGRAPHER', 'FILMMAKER', 'PLANNER', 'MAKEUP', 'HAIRDRESSER', 
        'DESIGNER', 'BRIDALDESIGNER', 'VENUE', 'BRIDALSHOP', 'FLORIST', 
        'PHOTOMOVIE', 'MAKEUPARTIST', 'EVENTDESIGNER', 'OTHER',
        'JEWELLER', 'STATIONER', 'CONTENTCREATOR'  -- GLOBAL only
      ])
    )
  )
```

### Phase 2: Étendre Enums (1h)

**Ajouter 6 professions:**
```dart
enum Profession {
  // ... existantes ...
  caterer, dj, bridalWearDesigner,  // IN only
  jeweller, stationer, contentCreator,  // GLOBAL only
}
```

### Phase 3: Filtres Localisation (2-3h)

**Copier pattern de la Map:**
- `FilterSheet` de Map → adapter pour Feed
- Toggle Country/Nearby (mutuellement exclusifs)
- Garder design existant

### Phase 4: Feed pour Pros (1h)

**Simple modification navbar:**
- Remplacer "Profil" par "Feed"
- Réutiliser même page `FeedBridesWidget`

---

## ⚡ CE QU'ON SAUTE POUR L'INSTANT

| Feature | Raison | Fait plus tard |
|---------|--------|----------------|
| Images V2 | Colonnes vides, complexité | Quand CRM sync |
| ProDetails migration | Pas critique pour Feed | Phase 2 |
| Wed of the Week | Optionnel | Si temps |
| Bug localisation Paris | Mineur | Phase 2 |
| Design System complet | 90% correct déjà | Ajustements finaux |

---

## ✅ CHECKLIST MINIMUM VIABLE

### Backend (2h)
- [ ] Patch `get_portfolio_feed` avec `is_visible_in_market()`
- [ ] Ajouter `feed_enabled` + `ambassador` dans WHERE
- [ ] Tests avec utilisateur IN et GLOBAL

### Frontend (4-5h)
- [ ] Ajouter 6 nouvelles professions à l'enum
- [ ] Adapter filtres localisation (Country/Nearby toggle)
- [ ] Cacher filtres pour utilisateurs IN
- [ ] Exclure India du dropdown pour GLOBAL
- [ ] Ajouter Feed dans navbar Pro

### Tests (1h)
- [ ] Test utilisateur IN (voit seulement pros IN)
- [ ] Test utilisateur GLOBAL (voit pros GLOBAL, pas IN)
- [ ] Test filtres mutuellement exclusifs
- [ ] Test nouvelles professions par marché

---

## 🎯 PROCHAINES ÉTAPES (AUJOURD'HUI)

1. **PATCH RPC** - 2h - Modification minimale
2. **ENUMS** - 1h - Ajouter 6 professions
3. **FILTRES** - 3h - Copier pattern Map
4. **NAVBAR** - 1h - Ajouter Feed pour Pros
5. **TESTS** - 1h - Validation rapide

**TOTAL: 8h pour un Feed fonctionnel !**

---

## 📋 PHASE 2 (PLUS TARD)

| Feature | Priorité | Estimation |
|---------|----------|------------|
| Images V2 (Feed + ProDetails) | 🟡 | 4-5h |
| Bug localisation Paris | 🟢 | 1h |
| Wed of the Week | 🟢 | 3h |
| Design System complet | 🟢 | 2h |

---

**Statut**: 🚀 PRÊT À DÉMARRER - Plan ultra-rapide validé  
**Dernière mise à jour**: 2025-12-05  
**Approche**: Pragmatique - modifications directes, pas de réécriture  
**Timeline**: 8h pour un Feed fonctionnel
```

### 6.3 Code Exemple

```dart
// Header slider (1:1)
final slideshowV2 = proDetails['slideshow_images_v2'] as List<dynamic>? ?? [];
PageView.builder(
  itemCount: slideshowV2.length,
  itemBuilder: (context, index) {
    final photo = slideshowV2[index];
    return GestureDetector(
      onTap: () => _openFullscreen(photo),  // crop_9x16
      child: CachedNetworkImage(
        imageUrl: photo['crop_1x1'],  // Affiche 1:1
        fit: BoxFit.cover,
      ),
    );
  },
);

// Portfolio grid (3:4)
final portfolioV2 = proDetails['portfolio_images_v2'] as List<dynamic>? ?? [];
GridView.builder(
  itemCount: portfolioV2.length,
  itemBuilder: (context, index) {
    final photo = portfolioV2[index];
    return GestureDetector(
      onTap: () => _openFullscreen(photo),  // crop_9x16
      child: CachedNetworkImage(
        imageUrl: photo['crop_3x4'],  // Affiche 3:4
        fit: BoxFit.cover,
      ),
    );
  },
);
```

---

## 🟡 PHASE 5 - FEED POUR PROS (2h)

### 5.1 Ajouter Onglet Feed dans Navbar Pro

```dart
// Remplacer l'onglet "Profil" par "Feed" dans navbar pro
// Le profil sera accessible depuis Settings
NavBarProsWidget(
  items: [
    NavItem(icon: Icons.home, label: 'Home', route: '/home'),
    NavItem(icon: Icons.map, label: 'Map', route: '/map'),
    NavItem(icon: Icons.grid_view, label: 'Feed', route: '/feed'),  // NOUVEAU
    NavItem(icon: Icons.chat, label: 'Messages', route: '/messages'),
    NavItem(icon: Icons.settings, label: 'Settings', route: '/settings'),  // Profil ici
  ],
)
```

### 5.2 Adapter Actions pour Pros

```dart
// Dans FeedDetailViewerWidget, adapter selon le rôle:
if (currentUserRole == 'bride') {
  // Bouton "View Profile" + Favoris
} else {
  // Bouton "View Profile" uniquement (pas de favoris entre pros)
}
```

---

## ✅ CHECKLIST PRÉ-DÉPLOIEMENT

### Backend
- [ ] RPC `get_portfolio_feed` avec `is_visible_in_market()`
- [ ] RPC `get_portfolio_feed` avec `feed_enabled` + `ambassador`
- [ ] Fallback legacy si colonnes V2 vides
- [ ] Tests avec utilisateur IN et GLOBAL
- [ ] Retourner `proLocationLabel` correct (bug Paris)

### Frontend - Feed
- [ ] `FeedFilterSheet` depuis le HAUT de la page
- [ ] Filtres adaptés selon marché (IN vs GLOBAL)
- [ ] Dropdown pays SANS India pour GLOBAL
- [ ] Filtre localisation simplifié ("Autour de moi" ou ville)
- [ ] `FeedPortfolioGrid` avec aspect ratio 3:4
- [ ] Badge ambassadeur affiché
- [ ] Feed accessible aux Pros

### Frontend - ProDetails
- [ ] Header slider avec `slideshow_images_v2` (crop_1x1)
- [ ] Portfolio grid avec `portfolio_images_v2` (crop_3x4)
- [ ] Fullscreen avec crop_9x16

### UX
- [ ] Utilisateurs IN: filtres localisation MASQUÉS
- [ ] Utilisateurs GLOBAL: India JAMAIS accessible
- [ ] Sheet de filtres intégré à la page (depuis le haut)
- [ ] Empty state unifié
- [ ] Pull-to-refresh

---

## 🎯 PROCHAINES ÉTAPES IMMÉDIATES

1. **Modifier RPC `get_portfolio_feed`** - Market region + feed_enabled + ambassador + bug localisation
2. **Créer `FeedFilterSheet`** - Depuis le haut, adapté selon marché
3. **Migrer vers colonnes V2** - Feed + ProDetails en même temps
4. **Ajouter Feed pour Pros** - Navbar + adaptations
5. **Wed of the Week** - Si temps disponible

---

## ❓ QUESTION OUVERTE À VALIDER

### Filtre Localisation pour GLOBAL

**Options proposées:**

| Option | Description | Complexité |
|--------|-------------|------------|
| **A** | Supprimer complètement | Simple |
| **B** | Toggle "Autour de moi" (GPS + 100km) | Moyenne |
| **C** | Sélection ville (autocomplete) | Moyenne |
| **D** | Garder adresse + slider rayon | Complexe |

**Ma recommandation**: Option B ou C - Plus simple, UX claire.

**À valider avant implémentation.**

---

**Statut**: ✅ PHASE 1 + 1.5 TERMINÉES  
**Dernière mise à jour**: 2025-12-05 13:35  
**Approche**: Pragmatique - modifications directes, pas de réécriture  
**Ordre**: ~~Phase 1 MVP~~ ✅ → ~~Phase 1.5 Compléments~~ ✅ → Phase 2 Auth ✅ → Phase 3 Settings

---

## ✅ HISTORIQUE DES PHASES TERMINÉES

### Phase 1 - Feed MVP (2025-12-05) ✅
- RPC `get_portfolio_feed` avec market region + feed_enabled + ambassador
- 6 nouvelles professions ajoutées (IN + GLOBAL)
- `FeedLocationFilter` avec toggle Country/Nearby
- `CountryFilter` enum avec 200+ pays
- Segmentation marché IN/GLOBAL complète

### Phase 1.5 - Feed Compléments (2025-12-05) ✅
- Migration Images V2 (crop_3x4 grille, crop_9x16 fullscreen)
- ProDetails avec portfolioImagesV2 et slideshowImagesV2
- Wed of the Week filtré par market_region
- Bug fixes localisation Paris

### Phase 2 - Auth Refactoring (2025-12-05) ✅
- Page d'accueil avec choix rôle Bride/Pro
- Onboarding 5 pages (Welcome → Profile → Preferences → Location → Notifications)
- Permissions demandées au bon moment
- Widget `DistanceUnitDropdown` créé
- Logique Currency → Unit cohérente (USD=miles, EUR=km)
- Fix popup notifications au login
