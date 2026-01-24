# Story C-01: Identifier et Supprimer Fichiers Orphelins

## Metadata
| Champ | Valeur |
|-------|--------|
| **ID** | C-01 |
| **Epic** | EPIC-05-SECURITY-CLEANUP |
| **Priorite** | P2 - MOYENNE |
| **Estimation** | 4h |
| **Statut** | COMPLETE |

---

## Description

En tant que **maintainer**, je veux identifier et supprimer les fichiers orphelins afin de **reduire la taille du codebase et la surface d'attaque**.

---

## Contexte

Le codebase contient ~88,600 lignes de Dart avec potentiellement 40% de code inutilise (heritage FlutterFlow). Les fichiers orphelins sont des fichiers jamais importes/references.

### Zones Suspectes

| Dossier | Suspicion | Raison |
|---------|-----------|--------|
| `lib/flutter_flow/` | HAUTE | Legacy FlutterFlow utilities |
| `lib/conversation_sheet/` | MOYENNE | Ancien systeme sheets? |
| `lib/compo_finaux/` | MOYENNE | Composants remplaces par Clean Arch? |
| `lib/custom_code/` | BASSE | Actions utilisees mais a verifier |

---

## Criteres d'Acceptance

- [x] Script d'analyse pour trouver fichiers non importes
- [x] Liste des fichiers orphelins documentes
- [x] Verification manuelle des fichiers suspects
- [x] Suppression des fichiers confirmes orphelins
- [x] `flutter analyze` passe sans erreur
- [x] Tests de regression passent (pre-existing failures only)
- [x] Documentation rollback (liste fichiers supprimes)

---

## Checklist Cleanup

### Analyse
- [ ] Scanner tous les imports dans le codebase
- [ ] Identifier fichiers sans aucun import entrant
- [ ] Verifier routes dans `lib/flutter_flow/nav/nav.dart`
- [ ] Verifier exports dans `lib/index.dart`
- [ ] Croiser avec `lib/main.dart` entry points

### Verification Manuelle
- [ ] `lib/conversation_sheet/` - Encore utilise?
- [ ] `lib/compo_finaux/` - Remplace par features/?
- [ ] `lib/flutter_flow/place.dart` - Remplace par Google Places SDK?
- [ ] `lib/flutter_flow/lat_lng.dart` - Remplace?

### Suppression
- [ ] Creer branche `cleanup/orphan-files`
- [ ] Supprimer fichiers confirmes orphelins
- [ ] Run `flutter analyze --fatal-infos`
- [ ] Run `flutter test`
- [ ] Run `flutter build ios --no-codesign`

### Documentation
- [ ] Liste fichiers supprimes dans ce PR
- [ ] Raison de suppression pour chaque fichier
- [ ] Instructions rollback (git revert)

---

## Implementation

### Script d'Analyse Orphelins

```bash
#!/bin/bash
# find_orphans.sh

# Lister tous les fichiers .dart
all_files=$(find lib -name "*.dart" | grep -v "_test.dart")

# Pour chaque fichier, verifier s'il est importe
for file in $all_files; do
  filename=$(basename "$file" .dart)
  # Chercher des imports de ce fichier
  imports=$(grep -r "import.*$filename" lib --include="*.dart" | wc -l)
  if [ "$imports" -eq 0 ]; then
    echo "ORPHAN: $file"
  fi
done
```

### Verification Import Graph

```dart
// Utiliser dart analyze pour verifier
// ou package:import_sorter pour visualiser

// Commande utile:
// dart pub global activate import_graph
// dart pub global run import_graph lib/
```

---

## Fichiers Candidats a la Suppression

### Haute Probabilite

| Fichier | Raison |
|---------|--------|
| `lib/flutter_flow/place.dart` | Remplace par flutter_google_places_sdk |
| `lib/flutter_flow/lat_lng.dart` | Utilise LatLng de google_maps_flutter |
| `lib/flutter_flow/uploaded_file.dart` | A verifier usage |
| `lib/conversation_sheet/*` | Potentiellement remplace |

### A Verifier

| Fichier | Question |
|---------|----------|
| `lib/flutter_flow/custom_functions.dart` | Quelles fonctions encore utilisees? |
| `lib/flutter_flow/form_field_controller.dart` | Encore utilise? |
| `lib/flutter_flow/internationalization.dart` | Remplace par intl package? |

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Supprimer fichier encore utilise | HAUT | flutter analyze + tests |
| Dynamic imports non detectes | MOYEN | Grep manuel + tests E2E |
| Reflection/mirrors | BAS | Flutter ne supporte pas bien |

---

## Definition of Done

- [x] Analyse complete des imports
- [x] Fichiers orphelins documentes
- [x] Suppression validee (analyze + tests)
- [x] Documentation rollback
- [ ] PR reviewee et mergee

---

## Implementation Results (2025-01-24)

### Orphan Files Deleted (10 files)

| File | Reason | Lines Removed |
|------|--------|---------------|
| `lib/core/design/test_design_system_widget.dart` | Test widget never imported | ~330 |
| `lib/custom_code/actions/upsert_pro_recent_opt_in.dart` | Legacy action never used | ~26 |
| `lib/utils/error_handler.dart` | Utility class never imported | ~67 |
| `lib/features/chat/chat.dart` | Barrel export never imported | ~72 |
| `lib/pages/bride/feed_brides/feed_profession_filter_grid.dart` | Widget never used | ~132 |
| `lib/features/my_wedding/presentation/pages/wedding_onboarding_page.dart` | Page never imported (replaced) | ~1242 |
| `lib/pages/shared/preference/preference_model.dart` | Legacy FlutterFlow model | ~39 |
| `lib/pages/shared/settings_permissions/settings_permissions_model.dart` | Legacy FlutterFlow model | ~49 |
| `lib/pages/shared/support/support_model.dart` | Legacy FlutterFlow model | ~46 |
| `lib/compo_finaux/address_search/address_search_model.dart` | Legacy FlutterFlow model | ~19 |

**Total lines removed: ~2,022 lines**

### Files Verified as STILL IN USE (Not Deleted)

| File | Reason Still Needed |
|------|---------------------|
| `lib/flutter_flow/place.dart` | Used in nav/serialization_util.dart, flutter_flow_util.dart |
| `lib/flutter_flow/lat_lng.dart` | Used in database.dart, custom_functions.dart, map wrappers |
| `lib/flutter_flow/uploaded_file.dart` | Used in serialization_util.dart, flutter_flow_util.dart |
| `lib/flutter_flow/internationalization.dart` | Used in main.dart |
| `lib/flutter_flow/custom_functions.dart` | Widely used across codebase |
| `lib/flutter_flow/form_field_controller.dart` | Used in onboarding wizard |
| `lib/conversation_sheet/*` | Still imported in messages pages |
| `lib/compo_finaux/address_search/address_search_widget.dart` | Used in multiple feature pages |
| `lib/compo_finaux/replay_guest_card/*` | Used in content_replay_widget.dart |

### Validation Results

- `flutter analyze --fatal-infos`: PASS (No issues found)
- `flutter test`: +215 -4 (same as before, pre-existing failures unrelated)

### Rollback Instructions

To rollback these deletions:
```bash
git checkout HEAD~1 -- \
  lib/core/design/test_design_system_widget.dart \
  lib/custom_code/actions/upsert_pro_recent_opt_in.dart \
  lib/utils/error_handler.dart \
  lib/features/chat/chat.dart \
  lib/pages/bride/feed_brides/feed_profession_filter_grid.dart \
  lib/features/my_wedding/presentation/pages/wedding_onboarding_page.dart \
  lib/pages/shared/preference/preference_model.dart \
  lib/pages/shared/settings_permissions/settings_permissions_model.dart \
  lib/pages/shared/support/support_model.dart \
  lib/compo_finaux/address_search/address_search_model.dart
```

### Additional Changes

- Updated `lib/features/chat/README.md` to remove reference to deleted chat.dart barrel
