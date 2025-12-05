# 🚀 PROMPT MASTER - FEED PHASE 1

> **Pour:** Assistant Windsurf spécialisé  
> **Objectif:** Implémenter le Feed en 6-7h  
> **Date:** 2025-12-05  
> **Approche:** Pragmatique - modifications directes, pas de réécriture

---

## 🎯 CONTEXTE PROJET

Tu travailles sur **Lynewed**, une application Flutter de mise en relation entre mariées (Brides) et professionnels du mariage (Pros). L'app utilise **Supabase** comme backend.

### Modules Terminés
- ✅ Design System v3 (`lib/core/design/`)
- ✅ Map Module (`lib/features/map/`)
- ✅ Chat Module
- ✅ Notifications

### Module Actuel: FEED
Le Feed est une **vitrine d'inspiration** où les Brides découvrent des pros via leurs photos de portfolio. Il doit être accessible aux **Brides ET Pros**.

---

## 📚 DOCUMENTS À LIRE EN PREMIER (OBLIGATOIRE)

Lis ces fichiers dans cet ordre avant de commencer:

1. **`docs/FEED_REFACTORING_PLAN.md`** - Plan détaillé v5 avec code SQL et Dart
2. **`docs/audits/FEED_FEATURE_AUDIT.md`** - Audit complet du module actuel
3. **`docs/TODO_FINALISATION.md`** - Vue d'ensemble des phases

---

## 🌍 RÈGLE BUSINESS CRITIQUE: MARKET REGION

```
🇮🇳 UTILISATEUR INDIEN (Bride ou Pro):
├── Voit UNIQUEMENT les pros indiens
├── Filtres localisation: MASQUÉS (pas de choix)
├── Filtre pays: BLOQUÉ sur India (forcé côté backend)
├── Professions disponibles: Toutes SAUF JEWELLER, STATIONER, CONTENTCREATOR
└── L'app est "India only" pour eux

🌍 UTILISATEUR GLOBAL (reste du monde):
├── Voit pros GLOBAL (JAMAIS l'Inde)
├── Filtres localisation: VISIBLES
├── Dropdown pays: TOUS les pays SAUF India
├── Professions disponibles: Toutes SAUF CATERER, DJ, BRIDALWEARDESIGNER
└── India n'apparaît JAMAIS dans les options
```

---

## 📋 PHASES À IMPLÉMENTER (DANS CET ORDRE)

### 🔴 PHASE 1.1 - BACKEND RPC PATCH (2h)

**Fichier Supabase à modifier:** RPC `get_portfolio_feed`

**Objectif:** Ajouter la logique market region + feed_enabled + ambassador

**Étapes:**
1. Lire la RPC actuelle via MCP Supabase
2. Comprendre la structure existante
3. Ajouter les modifications suivantes:

```sql
-- AJOUTER dans DECLARE:
v_my_market text := public.get_my_market_region();

-- AJOUTER dans le WHERE:
AND (pd.feed_enabled = true OR pr.ambassador = true)
AND public.is_visible_in_market(pd.location_country_code, v_my_market)

-- AJOUTER filtrage professions par marché:
AND (
  (v_my_market = 'IN' AND pd.profession NOT IN ('JEWELLER', 'STATIONER', 'CONTENTCREATOR'))
  OR
  (v_my_market = 'GLOBAL' AND pd.profession NOT IN ('CATERER', 'DJ', 'BRIDALWEARDESIGNER'))
)

-- MODIFIER ORDER BY pour ambassadeurs en premier:
ORDER BY pr.ambassador DESC, sort_key ASC
```

**Vérification:** Tester avec un utilisateur IN et un utilisateur GLOBAL

---

### 🔴 PHASE 1.2 - ENUMS + PROFESSIONS (1h)

**Fichier à modifier:** `lib/backend/schema/enums/enums.dart` (ou fichier profession_enum)

**Objectif:** Ajouter 6 nouvelles professions

**Étapes:**
1. Trouver le fichier enum des professions: `grep -r "enum Profession" lib/`
2. Ajouter les nouvelles valeurs:

```dart
enum Profession {
  // ... existantes ...
  
  // 🇮🇳 Inde uniquement
  caterer,
  dj,
  bridalWearDesigner,
  
  // 🌍 Monde entier
  jeweller,
  stationer,
  contentCreator,
}
```

3. Mettre à jour la fonction de conversion string → enum
4. Mettre à jour la fonction de display name
5. Créer les constantes de filtrage:

```dart
const List<Profession> indiaOnlyProfessions = [
  Profession.caterer,
  Profession.dj,
  Profession.bridalWearDesigner,
];

const List<Profession> globalOnlyProfessions = [
  Profession.jeweller,
  Profession.stationer,
  Profession.contentCreator,
];

List<Profession> getAvailableProfessions(String market) {
  if (market == 'IN') {
    return Profession.values.where((p) => !globalOnlyProfessions.contains(p)).toList();
  } else {
    return Profession.values.where((p) => !indiaOnlyProfessions.contains(p)).toList();
  }
}
```

**Vérification:** Compiler sans erreur, vérifier que les nouvelles professions sont reconnues

---

### 🟡 PHASE 1.3 - FILTRES LOCALISATION (2-3h)

**Fichiers à modifier:**
- `lib/pages/bride/feed_brides/feed_brides_widget.dart`
- `lib/pages/bride/feed_brides/feed_profession_grid.dart`

**Objectif:** 
- Remplacer `AddressSearchWidget` + slider par toggle Country/Nearby
- Cacher filtres pour utilisateurs IN
- Exclure India du dropdown pour GLOBAL

**Étapes:**

1. **Lire le code actuel:**
```bash
# Comprendre la structure
cat lib/pages/bride/feed_brides/feed_brides_widget.dart
```

2. **Détecter le marché utilisateur:**
```dart
// Ajouter dans initState ou au chargement
Future<void> _detectUserMarket() async {
  final result = await SupaFlow.client.rpc('get_my_market_region').execute();
  setState(() {
    _userMarket = result.data as String? ?? 'GLOBAL';
    _isIndianMarket = _userMarket == 'IN';
  });
}
```

3. **Adapter l'UI des filtres:**
```dart
// Pour utilisateur IN: masquer les filtres de localisation
if (!_isIndianMarket) {
  // Afficher dropdown pays (sans India)
  _buildCountryDropdown(excludeIndia: true),
  // Afficher toggle "Autour de moi"
  _buildNearbyToggle(),
}

// Pour utilisateur IN: forcer le pays à India
if (_isIndianMarket) {
  _forcedCountryCode = 'IN';
}
```

4. **Créer le toggle Country/Nearby (mutuellement exclusifs):**
```dart
enum LocationMode { country, nearby }

Widget _buildLocationFilter() {
  return Column(
    children: [
      // Boutons radio pour choisir le mode
      Row(
        children: [
          _buildModeButton('Country', LocationMode.country),
          _buildModeButton('Around me', LocationMode.nearby),
        ],
      ),
      // Afficher le bon filtre selon le mode
      if (_locationMode == LocationMode.country)
        _buildCountryDropdown(excludeIndia: true),
      if (_locationMode == LocationMode.nearby)
        _buildNearbySlider(),
    ],
  );
}
```

5. **Adapter les professions affichées selon le marché:**
```dart
// Dans FeedProfessionGrid
final availableProfessions = getAvailableProfessions(_userMarket);
// Utiliser availableProfessions au lieu de Profession.values
```

**Vérification:** 
- Utilisateur IN ne voit PAS les filtres de localisation
- Utilisateur GLOBAL ne voit PAS India dans le dropdown
- Toggle Country/Nearby fonctionne

---

### 🟡 PHASE 1.4 - FEED POUR PROS (1h)

**Fichiers à modifier:**
- `lib/components/nav_bar_pros/nav_bar_pros_widget.dart` (ou équivalent)

**Objectif:** Ajouter onglet Feed dans navbar Pro

**Étapes:**

1. **Trouver la navbar Pro:**
```bash
grep -r "NavBarPros" lib/
# ou
find lib -name "*nav*pro*"
```

2. **Ajouter l'onglet Feed:**
```dart
// Remplacer l'onglet "Profil" par "Feed"
// Le profil sera accessible depuis Settings
NavItem(
  icon: Icons.grid_view,
  label: 'Feed',
  route: '/feed',  // Réutilise FeedBridesWidget
),
```

3. **Adapter FeedBridesWidget pour les Pros:**
```dart
// Dans FeedDetailViewerWidget, adapter selon le rôle:
final bool isBride = currentUser?.role == 'bride';

// Bouton favoris visible seulement pour Brides
if (isBride) {
  _buildFavoriteButton(),
}
// Bouton "View Profile" visible pour tous
_buildViewProfileButton(),
```

**Vérification:** Un Pro peut accéder au Feed depuis sa navbar

---

### 🟡 PHASE 1.5 - TESTS & VALIDATION (1h)

**Tests à effectuer:**

1. **Test utilisateur IN:**
   - [ ] Voit seulement les pros indiens
   - [ ] Pas de filtres de localisation visibles
   - [ ] Professions IN-only disponibles (CATERER, DJ, BRIDALWEARDESIGNER)
   - [ ] Professions GLOBAL-only NON disponibles

2. **Test utilisateur GLOBAL:**
   - [ ] Voit pros GLOBAL (pas d'indiens)
   - [ ] Dropdown pays visible (sans India)
   - [ ] Toggle Country/Nearby fonctionne
   - [ ] Professions GLOBAL-only disponibles (JEWELLER, STATIONER, CONTENTCREATOR)
   - [ ] Professions IN-only NON disponibles

3. **Test Pro:**
   - [ ] Feed accessible depuis navbar
   - [ ] Pas de bouton favoris (seulement View Profile)

---

## 📁 FICHIERS CLÉS À CONSULTER

### Backend (Supabase)
- RPC `get_portfolio_feed` - Via MCP Supabase
- RPC `get_my_market_region` - Logique de détection marché
- RPC `is_visible_in_market` - Fonction de filtrage

### Frontend (Flutter)
```
lib/pages/bride/feed_brides/
├── feed_brides_widget.dart       # Page principale (609 lignes)
├── feed_brides_model.dart        # Model
├── feed_profession_grid.dart     # Grille checkboxes professions

lib/pages/bride/feed_detail_viewer/
├── feed_detail_viewer_widget.dart  # Viewer fullscreen

lib/custom_code/widgets/
└── feed_portfolio_grid.dart      # Widget grille images

lib/custom_code/actions/
└── get_portfolio_feed_action.dart  # Action RPC

lib/backend/schema/enums/
└── enums.dart                    # Enum Profession
```

### Référence (Pattern à copier)
```
lib/features/map/presentation/widgets/filter_sheet.dart  # Pattern filtres
lib/features/map/presentation/sheets/                    # Sheets Design System
```

---

## ⚠️ PIÈGES À ÉVITER

1. **NE PAS réécrire en Clean Architecture** - Modifier les fichiers existants directement
2. **NE PAS toucher au Design System** - Le design actuel est 90% correct
3. **NE PAS implémenter les Images V2** - C'est Phase 1.5 (après MVP)
4. **NE PAS implémenter Wed of the Week** - C'est Phase 1.5
5. **Vérifier que l'enum Profession existe déjà dans Supabase** avant d'ajouter les nouvelles valeurs

---

## 🔧 COMMANDES UTILES

```bash
# Trouver les fichiers
grep -r "get_portfolio_feed" lib/
grep -r "enum Profession" lib/
grep -r "FeedBrides" lib/
grep -r "NavBarPros" lib/

# Compiler pour vérifier les erreurs
flutter analyze
flutter build ios --debug
```

---

## ✅ CHECKLIST FINALE

### Backend
- [ ] RPC `get_portfolio_feed` patché avec `is_visible_in_market()`
- [ ] RPC `get_portfolio_feed` patché avec `feed_enabled` + `ambassador`
- [ ] Filtrage professions par marché ajouté

### Frontend
- [ ] 6 nouvelles professions ajoutées à l'enum
- [ ] Fonction `getAvailableProfessions(market)` créée
- [ ] Filtres localisation adaptés (masqués pour IN, sans India pour GLOBAL)
- [ ] Toggle Country/Nearby implémenté
- [ ] Feed ajouté dans navbar Pro

### Tests
- [ ] Utilisateur IN testé
- [ ] Utilisateur GLOBAL testé
- [ ] Pro avec Feed testé

---

## 📞 EN CAS DE BLOCAGE

1. **Relire** `docs/FEED_REFACTORING_PLAN.md` section concernée
2. **Consulter** `docs/audits/FEED_FEATURE_AUDIT.md` pour le contexte
3. **S'inspirer** de `lib/features/map/` pour les patterns

---

**Estimation:** 6-7 heures  
**Résultat attendu:** Feed fonctionnel avec séparation IN/GLOBAL, nouvelles professions, et accessible aux Pros

**BONNE IMPLÉMENTATION ! 🚀**
