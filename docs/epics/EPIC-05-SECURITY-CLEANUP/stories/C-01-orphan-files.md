# Story C-01: Identifier et Supprimer Fichiers Orphelins

## Metadata
| Champ | Valeur |
|-------|--------|
| **ID** | C-01 |
| **Epic** | EPIC-05-SECURITY-CLEANUP |
| **Priorite** | P2 - MOYENNE |
| **Estimation** | 4h |
| **Statut** | NOT_STARTED |

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

- [ ] Script d'analyse pour trouver fichiers non importes
- [ ] Liste des fichiers orphelins documentes
- [ ] Verification manuelle des fichiers suspects
- [ ] Suppression des fichiers confirmes orphelins
- [ ] `flutter analyze` passe sans erreur
- [ ] Tests de regression passent
- [ ] Documentation rollback (liste fichiers supprimes)

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

- [ ] Analyse complete des imports
- [ ] Fichiers orphelins documentes
- [ ] Suppression validee (analyze + tests)
- [ ] Documentation rollback
- [ ] PR reviewee et mergee
