# Story C-02: Nettoyer Fonctions Inutilisees

## Metadata
| Champ | Valeur |
|-------|--------|
| **ID** | C-02 |
| **Epic** | EPIC-05-SECURITY-CLEANUP |
| **Priorite** | P2 - MOYENNE |
| **Estimation** | 4h |
| **Statut** | NOT_STARTED |

---

## Description

En tant que **maintainer**, je veux identifier et supprimer les fonctions inutilisees afin de **reduire la complexite du code et ameliorer la lisibilite**.

---

## Contexte

Meme dans les fichiers utilises, de nombreuses fonctions peuvent etre mortes (jamais appelees). C'est courant avec du code legacy FlutterFlow ou apres refactoring.

### Fichiers Volumineux a Auditer

| Fichier | Lignes | Suspicion |
|---------|--------|-----------|
| `lib/flutter_flow/custom_functions.dart` | ~400 | Fonctions legacy |
| `lib/flutter_flow/flutter_flow_util.dart` | ~500 | Utilities legacy |
| `lib/flutter_flow/flutter_flow_widgets.dart` | ~500 | Widgets legacy |
| `lib/backend/schema/structs/*.dart` | ~100+ chacun | Structs non utilisees? |

---

## Criteres d'Acceptance

- [ ] Audit des fonctions dans fichiers cibles
- [ ] Liste des fonctions non appelees
- [ ] Verification manuelle pour faux positifs
- [ ] Suppression des fonctions confirmees inutiles
- [ ] `flutter analyze` passe sans erreur
- [ ] Tests passent
- [ ] Documentation des suppressions

---

## Checklist Cleanup

### Analyse custom_functions.dart
- [ ] Lister toutes les fonctions exportees
- [ ] Pour chaque fonction, grep usage dans codebase
- [ ] Marquer fonctions sans usage

### Analyse flutter_flow_util.dart
- [ ] Lister toutes les fonctions/extensions
- [ ] Verifier usage de chaque utility
- [ ] Identifier helpers remplaces par packages

### Analyse Structs
- [ ] Lister tous les structs dans `lib/backend/schema/structs/`
- [ ] Verifier usage de chaque struct
- [ ] Identifier structs pour tables non utilisees

### Suppression
- [ ] Commenter d'abord (ne pas supprimer directement)
- [ ] Run `flutter analyze`
- [ ] Si pas d'erreur, supprimer
- [ ] Run `flutter test`

---

## Implementation

### Script Detection Fonctions Mortes

```bash
#!/bin/bash
# find_dead_functions.sh

FILE=$1  # ex: lib/flutter_flow/custom_functions.dart

# Extraire noms de fonctions (simpliste)
functions=$(grep -E "^(Future|void|String|int|double|bool|List|Map|dynamic|[A-Z][a-zA-Z]+)\s+[a-z][a-zA-Z]+\(" "$FILE" | sed 's/.*\s\+\([a-z][a-zA-Z]*\)(.*/\1/')

for func in $functions; do
  # Compter usages (exclure definition)
  usages=$(grep -r "\b$func\b" lib --include="*.dart" | grep -v "^$FILE" | wc -l)
  if [ "$usages" -eq 0 ]; then
    echo "DEAD: $func in $FILE"
  fi
done
```

### Utiliser dart analyze

```bash
# Les warnings "unused" de dart analyze
flutter analyze 2>&1 | grep -i "unused"
```

---

## Fonctions Candidates

### custom_functions.dart

A auditer:
- [ ] `formatPhoneNumber()`
- [ ] `calculateDistance()`
- [ ] `formatCurrency()`
- [ ] `convertTimestamp()`
- [ ] ... (lister toutes les fonctions)

### flutter_flow_util.dart

A auditer:
- [ ] `maybeDisposeModel()`
- [ ] `dateTimeFormat()`
- [ ] `responsiveVisibility()`
- [ ] `parseCurrency()`
- [ ] ... (lister toutes les fonctions)

### Structs potentiellement inutilises

| Struct | Table | Usage suspect |
|--------|-------|---------------|
| `SpatialRefSysRow` | spatial_ref_sys | PostGIS internal |
| `GeometryColumnsRow` | geometry_columns | PostGIS internal |
| `GeographyColumnsRow` | geography_columns | PostGIS internal |
| `SyncLogRow` | sync_log | Utilise? |
| `SyncControlRow` | sync_control | Utilise? |

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Supprimer fonction encore utilisee | HAUT | Grep exhaustif + tests |
| Callbacks passes en parametre | MOYEN | Verification manuelle |
| Reflection/dynamic calls | BAS | Tests E2E |

---

## Definition of Done

- [ ] Fonctions mortes identifiees
- [ ] Suppression validee (analyze + tests)
- [ ] Code simplifie et lisible
- [ ] Documentation des suppressions
- [ ] PR reviewee et mergee
