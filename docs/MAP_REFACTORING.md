# MAP REFACTORING - Plan de Correction Final Validé

**Date:** 2025-11-27  
**Version:** 3.0 (Plan Final Validé)  
**Objectif:** Appliquer le Design System existant et corriger UI/UX du module map  
**Statut:** Phase 0 ✅ TERMINÉE (Design System créé), Phase 1 ⏳ À DÉMARRER

---

## 🎯 SITUATION ACTUELLE

### ✅ Ce Qui Est Fait
- **Design System créé** : `lib/core/design/` (9 fichiers complets)
- **Documentation Design System** : `docs/App/DESIGN_SYSTEM.md` (515 lignes)
- **Architecture Clean Architecture** : `lib/features/map/` (~3400 lignes)
- **Backend fonctionnel** : RPC `search_map_bundle` (44ms)
- **Tests unitaires** : 63/63 passants

### ⏳ Ce Qui Reste À Faire
- **Appliquer** le Design System au module map (pas encore fait!)
- **Restaurer** les éléments UI manquants (zoom, AddressSearch, FAB, géoloc)
- **Corriger** les fonctionnalités cassées (filtres, markers, sheets, actions)
- **Valider** en tests simulateur complet

---

## 🚨 PROBLÈMES IDENTIFIÉS (Tests Simulateur 27/11)

| Problème | Description | Phase |
|----------|-------------|-------|
| ❌ Design system non appliqué | Couleurs/style différents de validation Thierry | Phase 1 |
| ❌ Boutons zoom manquants | Pas de boutons +/- pour zoomer | Phase 1 |
| ❌ AddressSearch absent | Widget recherche localisation non intégré | Phase 1 |
| ❌ FAB création manquant | Pas de bouton créer wedding (bride) / alerte (pro) | Phase 1 |
| ❌ Géolocalisation cassée | Bouton centrage position ne fonctionne pas | Phase 1 |
| ❌ Style map absent | Pas de changement satellite/terrain/hybrid | Phase 1 |
| ❌ Filtres UI incorrect | Layout différent de l'original validé | Phase 2 |
| ❌ Filtres non fonctionnels | Professions non filtrées (RPC ou code Flutter?) | Phase 2 |
| ❌ Markers style incorrect | Pins identiques au lieu de cercles avatar pour pros | Phase 3 |
| ❌ Markers alerts/weddings | Doivent avoir formes distinctives | Phase 3 |
| ❌ Sheets style incorrect | Pas le bon design system appliqué | Phase 4 |
| ❌ Boutons sheets cassés | View Profile, Contact ne fonctionnent pas | Phase 5 |

---

## ✅ PHASE 0 - Design System TERMINÉE

**Design System créé et documenté :**

```
lib/core/design/
├── design.dart                    # Barrel export (import principal)
├── lynewed_colors.dart           # Couleurs (noir/blanc validés Thierry)
├── lynewed_text_styles.dart      # Typographie 'Haas Grot Text Trial'
├── lynewed_spacing.dart          # Espacements (baseline 4px)
├── lynewed_borders.dart          # Bordures (0.0 boutons, 24.0 sheets)
├── lynewed_component_styles.dart # Composants (boutons 48px, inputs, cards)
├── lynewed_design_system.dart    # API LynewedTheme.of(context)
├── lynewed_app_theme.dart        # ThemeData complet
└── test_design_system_widget.dart # Widget validation
```

**Documentation :** `docs/App/DESIGN_SYSTEM.md` (515 lignes)

**Import unique :**
```dart
import '/core/design/design.dart';
```

**Migration :**
```dart
// Avant: FlutterFlowTheme.of(context).primaryBackground
// Après: LynewedTheme.of(context).primaryBackground
```

---

## 📋 PLAN DE CORRECTION (6 Phases Restantes)

### Phase 1: Restauration Layout Map + Application Design System (3-4h)
**Objectif:** Remettre tous les éléments UI manquants avec le bon style

**Tâches:**
- [ ] Appliquer Design System à tous les composants existants
- [ ] Ajouter boutons zoom (+/-) en bas à droite avec style Design System
- [ ] Intégrer `AddressSearchWidget` en bas de page
- [ ] Ajouter bouton FAB "+" pour créer wedding (bride) ou alerte (pro)
- [ ] Réparer bouton géolocalisation (centrer sur position user)
- [ ] Ajouter menu style map (normal/satellite/terrain/hybrid)
- [ ] Restaurer compteur résultats en bas

**Fichiers à modifier:**
- `lib/features/map/presentation/pages/map_page.dart`
- `lib/features/map/presentation/widgets/`

---

### Phase 2: Correction Filtres (2-3h)
**Objectif:** Réparer le système de filtres complet

**Tâches UI:**
- [ ] Recréer le sheet de filtres avec layout original (s'inspirer de `AddFilterSheetWidget`)
- [ ] Appliquer Design System au sheet

**Tâches Fonctionnelles:**
- [ ] Vérifier passage des filtres à `search_map_bundle` RPC
- [ ] Débugger paramètre `p_filters` envoyé au backend
- [ ] Tester filtrage par profession sur simulateur
- [ ] Vérifier toggles showPros/showAlerts/showWeddingPins

**Debug SQL:**
```sql
SELECT search_map_bundle(
  '{"min_lat": 48.8, "min_lng": 2.2, "max_lat": 48.9, "max_lng": 2.5}'::jsonb,
  'bride',
  '{"showPros": true, "professions": ["PHOTOGRAPHER"]}'::jsonb,
  10
);
```

---

### Phase 3: Markers Style Correct (2-3h)
**Objectif:** Restaurer le style visuel des markers

**Tâches:**
- [ ] **Markers Pros:** Cercle avec avatar (border colorée par profession, avatar au centre, taille 48-56px selon zoom)
- [ ] **Markers Alerts:** Pin spécifique (icône alerte/entraide, couleur bleue #2196F3, forme distinctive)
- [ ] **Markers Weddings:** Pin cœur (icône cœur/mariage, couleur rose #E91E63, forme distinctive)
- [ ] Adapter `marker_icon_generator.dart` existant

---

### Phase 4: Sheets avec Design System (4-5h)
**Objectif:** Refaire les sheets avec le bon style

**Tâches:**
- [ ] **Pro Details Sheet:** Recréer avec Design System (s'inspirer de `InfoProItemSheetWidget`)
- [ ] **Wedding Details Sheet:** Recréer avec Design System (s'inspirer de `InfoWeddingPinSheetWidget`)
- [ ] **Alert Details Sheet:** Recréer avec Design System (s'inspirer de `InfoAlertItemSheetWidget`)
- [ ] Conserver les bonnes informations affichées actuellement

---

### Phase 5: Actions Fonctionnelles (3-4h)
**Objectif:** Faire fonctionner tous les boutons et interactions

**Tâches:**
- [ ] Navigation vers ProDetails depuis sheet pro
- [ ] Toggle wishlist (ajouter/retirer favori)
- [ ] Bouton contact bride → demande de connexion
- [ ] Bouton contact pro depuis alert
- [ ] Création wedding depuis map bride (FAB)
- [ ] Création alert depuis map pro (FAB)
- [ ] Ouverture sheet filtres

**Actions existantes à réutiliser:**
- `actions.getProItemDetailsAction()`
- `actions.toggleWishlistAction()`
- `actions.getAlertItemDetailsRpc()`
- `actions.getWeddingPinItemDetailsRpc()`

---

### Phase 6: Tests Finaux (1-2h)
**Objectif:** Valider toutes les corrections

**Checklist:**
- [ ] Map bride: affichage, filtres, markers, sheets, actions
- [ ] Map pro: affichage, filtres, markers, sheets, actions
- [ ] Design system respecté sur tous les éléments
- [ ] Performance < 1s chargement
- [ ] Pas de crash ou erreur console

---

## ⏱️ ESTIMATION TEMPS

| Phase | Description | Effort |
|-------|-------------|--------|
| ~~0~~ | ~~Design System~~ | ~~✅ FAIT~~ |
| 1 | Layout Map + Design System | 3-4h |
| 2 | Filtres | 2-3h |
| 3 | Markers | 2-3h |
| 4 | Sheets | 4-5h |
| 5 | Actions | 3-4h |
| 6 | Tests | 1-2h |
| **TOTAL** | | **15-21h** |

---

## 🚨 RÈGLES ABSOLUES

### Option B TOUJOURS
- ❌ **JAMAIS** réutiliser les composants FlutterFlow (`lib/compo_finaux/`, etc.)
- ✅ **TOUJOURS** créer de nouveaux composants dans `lib/features/map/`
- ✅ **TOUJOURS** appliquer le Design System (`lib/core/design/`)
- ✅ **S'INSPIRER** du code FlutterFlow pour comprendre les fonctionnalités

### Design System
- Noir/blanc principaux (validation Thierry)
- Import: `import '/core/design/design.dart';`
- API: `LynewedTheme.of(context)`

---

## �� RÉFÉRENCES

### Documentation
- **Design System:** `docs/App/DESIGN_SYSTEM.md`
- **Technical Audit:** `docs/audits/MAP_FEATURE_AUDIT.md`
- **Plan Original:** `docs/archive/MAP_CORRECTION_PLAN.md`

### Code Source
- **Module Map:** `lib/features/map/`
- **Design System:** `lib/core/design/`
- **Legacy (référence):** `lib/compo_finaux/`

---

**Statut:** Phase 0 ✅ terminée, Phase 1 ⏳ à démarrer  
**Prochaine action:** Démarrer Phase 1 - Appliquer Design System + Restaurer Layout  
**Objectif final:** Module map 100% fonctionnel avec UI/UX cohérente
