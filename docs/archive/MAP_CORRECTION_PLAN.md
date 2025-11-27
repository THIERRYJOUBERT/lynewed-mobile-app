# Plan de Correction Map Module - Phase 2

**Date:** 2025-11-27  
**Version:** 1.0  
**Objectif:** Corriger les problèmes UI/UX et fonctionnels identifiés lors des tests simulateur  
**Priorité:** HAUTE - Bloquant pour validation refactorisation

---

## 🚨 PROBLÈMES IDENTIFIÉS

### Résumé du Test Simulateur
- ✅ Build réussi, app lancée sans crash
- ✅ Map affiche la vue correctement
- ❌ Design system non respecté (couleurs, style)
- ❌ Éléments UI manquants sur la map
- ❌ Fonctionnalités non fonctionnelles
- ❌ Markers avec style incorrect
- ❌ Sheets avec mauvais design et boutons non fonctionnels

---

## 📋 PLAN DE CORRECTION (7 Phases)

### Phase 0: Design System Unifié (PRIORITÉ 1)
**Objectif:** Créer un guide de design réutilisable basé sur le code existant FlutterFlow

**Tâches:**
1. [ ] Créer `lib/core/design/lynewed_design_system.dart`
   - Couleurs: Noir/Blanc principalement (primary=#000000, background=#FFFFFF)
   - Typographie: 'Haas Grot Text Trial' avec variantes (body, title, label)
   - Espacements: 8, 12, 14, 16, 20, 24 (basé sur code existant)
   - Bordures: borderRadius 0.0 (boutons carrés), 24.0 (sheets), 100.0 (avatars)
   - Boutons: FFButtonWidget avec style noir/blanc, hauteur 48px
   - Sheets: borderRadius top 24.0, padding 20px, fond primaryBackground

2. [ ] Documenter dans `docs/DESIGN_SYSTEM.md`
   - Règles de couleurs
   - Règles de typographie
   - Règles d'espacement
   - Exemples de composants

**Fichiers à analyser pour extraction:**
- `lib/flutter_flow/flutter_flow_theme.dart` - Couleurs et typos
- `lib/flutter_flow/flutter_flow_widgets.dart` - FFButtonWidget
- `lib/compo_finaux/info_pro_item_sheet/` - Sheet style référence
- `lib/compo_finaux/add_filter_sheet/` - Filter sheet référence

**Effort estimé:** 2-3h

---

### Phase 1: Restauration Layout Map (PRIORITÉ 2)
**Objectif:** Remettre tous les éléments UI manquants sur MapPage

**Problèmes à corriger:**
- ❌ Pas de boutons zoom cliquables
- ❌ AddressSearchWidget non utilisé (doit être en bas)
- ❌ Pas de bouton créer wedding (bride) / alertes (pro)
- ❌ Bouton centrage géolocalisation ne marche pas
- ❌ Pas de changement style map (satellite, etc.)

**Tâches:**
1. [ ] Ajouter boutons zoom (+/-) en bas à droite
2. [ ] Intégrer `AddressSearchWidget` existant en bas de page
3. [ ] Ajouter bouton FAB "+" pour créer wedding (bride) ou alerte (pro)
4. [ ] Réparer bouton géolocalisation (centrer sur position user)
5. [ ] Ajouter menu style map (normal/satellite/terrain/hybrid)
6. [ ] Restaurer compteur résultats en bas

**Référence legacy:**
```dart
// De map_brides_large_widget.dart archivé
Stack(
  children: [
    // Map widget
    // AddressSearchWidget en bas
    // Boutons zoom à droite
    // FAB créer POI/Wedding
    // Bouton géoloc
  ]
)
```

**Effort estimé:** 3-4h

---

### Phase 2: Correction Filtres (PRIORITÉ 3)
**Objectif:** Réparer le système de filtres complet

**Problèmes à corriger:**
- ❌ UI filtres incorrect (doit reprendre AddFilterSheetWidget existant)
- ❌ Filtres ne fonctionnent pas (professions, types markers)
- ❌ Filtrage par rôle seulement actif, pas par profession

**Tâches:**
1. [ ] Utiliser `AddFilterSheetWidget` existant au lieu du nouveau FilterSheet
2. [ ] Vérifier passage des filtres à `search_map_bundle` RPC
3. [ ] Débugger paramètre `p_filters` envoyé au backend
4. [ ] Tester filtrage par profession sur simulateur
5. [ ] Vérifier toggles showPros/showAlerts/showWeddingPins

**Debug SQL à exécuter:**
```sql
-- Vérifier que search_map_bundle reçoit bien les filtres professions
SELECT search_map_bundle(
  '{"min_lat": 48.8, "min_lng": 2.2, "max_lat": 48.9, "max_lng": 2.5}'::jsonb,
  'bride',
  '{"showPros": true, "professions": ["PHOTOGRAPHER"]}'::jsonb,
  10
);
```

**Effort estimé:** 2-3h

---

### Phase 3: Markers Style Correct (PRIORITÉ 4)
**Objectif:** Restaurer le style visuel des markers

**Problèmes à corriger:**
- ❌ Tous les markers sont des pins identiques (juste couleur différente)
- ❌ Pros doivent avoir cercles avec avatarURL
- ❌ Alerts et Weddings doivent avoir pins de forme différente

**Tâches:**
1. [ ] Markers Pros: Cercle avec avatar (comme avant)
   - Border colorée par profession
   - Avatar au centre
   - Taille 48-56px selon zoom

2. [ ] Markers Alerts: Pin spécifique
   - Icône alerte/entraide
   - Couleur bleue (#2196F3)
   - Forme distinctive

3. [ ] Markers Weddings: Pin cœur
   - Icône cœur/mariage
   - Couleur rose (#E91E63)
   - Forme distinctive

4. [ ] Utiliser `marker_icon_generator.dart` existant mais adapter

**Effort estimé:** 2-3h

---

### Phase 4: Sheets avec Design System (PRIORITÉ 5)
**Objectif:** Refaire les sheets avec le bon style et fonctionnalités

**Problèmes à corriger:**
- ❌ Pro sheet: style incorrect, boutons non fonctionnels
- ❌ Wedding sheet: style incorrect, non fonctionnel
- ❌ Alert sheet: style incorrect, non fonctionnel

**Tâches:**
1. [ ] **Pro Details Sheet** - Utiliser `InfoProItemSheetWidget` existant
   - OU adapter le nouveau pour matcher le style
   - Bouton "View Profile" → navigation vers ProDetails
   - Bouton contact fonctionnel
   - Toggle wishlist fonctionnel

2. [ ] **Wedding Details Sheet** - Utiliser `InfoWeddingPinSheetWidget` existant
   - OU adapter le nouveau pour matcher le style
   - Bouton "Request Contact" fonctionnel
   - Informations affichées correctement

3. [ ] **Alert Details Sheet** - Utiliser `InfoAlertItemSheetWidget` existant
   - OU adapter le nouveau pour matcher le style
   - Bouton contact/répondre fonctionnel
   - Statut expired/active correct

**Effort estimé:** 4-5h

---

### Phase 5: Actions Fonctionnelles (PRIORITÉ 6)
**Objectif:** Faire fonctionner tous les boutons et interactions

**Tâches:**
1. [ ] Navigation vers ProDetails depuis sheet pro
2. [ ] Toggle wishlist (ajouter/retirer favori)
3. [ ] Bouton contact bride → demande de connexion
4. [ ] Bouton contact pro depuis alert
5. [ ] Création wedding depuis map bride (FAB)
6. [ ] Création alert depuis map pro (FAB)
7. [ ] Ouverture sheet filtres

**Actions existantes à réutiliser:**
- `actions.getProItemDetailsAction()`
- `actions.toggleWishlistAction()`
- `actions.getAlertItemDetailsRpc()`
- `actions.getWeddingPinItemDetailsRpc()`

**Effort estimé:** 3-4h

---

### Phase 6: Tests Finaux (PRIORITÉ 7)
**Objectif:** Valider toutes les corrections

**Checklist:**
- [ ] Map bride: affichage, filtres, markers, sheets, actions
- [ ] Map pro: affichage, filtres, markers, sheets, actions
- [ ] Design system respecté sur tous les éléments
- [ ] Performance < 1s chargement
- [ ] Pas de crash ou erreur console

**Effort estimé:** 1-2h

---

## 📊 RÉSUMÉ EFFORT

| Phase | Description | Effort | Priorité |
|-------|-------------|--------|----------|
| 0 | Design System | 2-3h | 1 |
| 1 | Layout Map | 3-4h | 2 |
| 2 | Filtres | 2-3h | 3 |
| 3 | Markers | 2-3h | 4 |
| 4 | Sheets | 4-5h | 5 |
| 5 | Actions | 3-4h | 6 |
| 6 | Tests | 1-2h | 7 |
| **TOTAL** | | **17-24h** | |

---

## 🎯 STRATÉGIE VALIDÉE - OPTION B

### ✅ DÉCISION PRISE: Créer de Nouveaux Composants Propres

**RÈGLE ABSOLUE DU PROJET:**
- ❌ **JAMAIS** réutiliser les composants FlutterFlow existants (`lib/compo_finaux/`, etc.)
- ✅ **TOUJOURS** créer de nouveaux composants propres dans `lib/features/map/`
- ✅ **TOUJOURS** appliquer le Design System unifié (`lib/core/design/`)

**APPROCHE:**
1. Créer le Design System unifié basé sur les couleurs/typos validées par Thierry
2. Réécrire les sheets avec le bon style ET les fonctionnalités
3. S'inspirer du code FlutterFlow pour comprendre les fonctionnalités, mais NE PAS le réutiliser
4. Archiver l'ancien code dans `docs/archive/`

**AVANTAGES:**
- ✅ Code propre et maintenable
- ✅ Architecture Clean Architecture
- ✅ Pas de dette technique FlutterFlow
- ✅ Design System réutilisable pour autres modules

---

## 📝 FICHIERS À MODIFIER

### Nouveaux fichiers à créer:
```
lib/core/design/
├── lynewed_design_system.dart      # Design tokens
├── lynewed_colors.dart             # Palette couleurs
├── lynewed_typography.dart         # Styles texte
└── lynewed_spacing.dart            # Espacements
```

### Fichiers à modifier:
```
lib/features/map/presentation/
├── pages/map_page.dart             # Layout complet
├── widgets/map_controls.dart       # Boutons zoom, géoloc, style
├── widgets/map_markers.dart        # Style markers
├── sheets/
│   ├── professional_details_sheet.dart  # Intégrer InfoProItemSheet
│   ├── wedding_details_sheet.dart       # Intégrer InfoWeddingPinSheet
│   ├── alert_details_sheet.dart         # Intégrer InfoAlertItemSheet
│   └── filter_sheet.dart                # Utiliser AddFilterSheetWidget
```

---

## ✅ DÉCISION VALIDÉE

**Stratégie:** Option B - Créer de nouveaux composants propres  
**Validé par:** Utilisateur (2025-11-27 12:12)  
**Raison:** Objectif du projet = supprimer FlutterFlow, pas le réutiliser

---

**Document créé:** 2025-11-27 12:05  
**Stratégie validée:** 2025-11-27 12:12  
**Prochaine action:** Démarrer Phase 0 - Design System Unifié
