# Story C-02: Nettoyer Fonctions Inutilisees

## Metadata
| Champ | Valeur |
|-------|--------|
| **ID** | C-02 |
| **Epic** | EPIC-05-SECURITY-CLEANUP |
| **Priorite** | P2 - MOYENNE |
| **Estimation** | 4h |
| **Statut** | COMPLETE |

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

- [x] Audit des fonctions dans fichiers cibles
- [x] Liste des fonctions non appelees
- [x] Verification manuelle pour faux positifs
- [x] Suppression des fonctions confirmees inutiles
- [x] `flutter analyze` passe sans erreur
- [x] Tests passent (pre-existing failures not related)
- [x] Documentation des suppressions

---

## Implementation Details

### Fonctions Supprimees

#### custom_functions.dart (2 fonctions)
| Fonction | Raison suppression |
|----------|-------------------|
| `jsonToQueryFilters()` | Jamais appelee dans le codebase |
| `stringToDateTime()` | Jamais appelee dans le codebase |

**Imports supprimes:**
- `import 'lat_lng.dart';`
- `import '/backend/supabase/supabase.dart';`

#### flutter_flow_util.dart (26 elements)
| Element | Type | Raison suppression |
|---------|------|-------------------|
| `colorFromCssString()` | Function | Jamais appelee |
| `dateTimeFromSecondsSinceEpoch()` | Function | Jamais appelee |
| `getJsonField()` | Function | Jamais appelee |
| `getWidgetBoundingBox()` | Function | Jamais appelee |
| `isWeb` | Getter | Jamais utilise |
| `kBreakpointSmall/Medium/Large` | Constants | Jamais utilisees |
| `isMobileWidth()` | Function | Jamais appelee |
| `responsiveVisibility()` | Function | Jamais appelee |
| `kTextValidatorUsernameRegex` | Constant | Jamais utilisee |
| `kTextValidatorEmailRegex` | Constant | Jamais utilisee |
| `kTextValidatorWebsiteRegex` | Constant | Jamais utilisee |
| `IterableExt.sortedList()` | Extension | Jamais utilise |
| `IterableExt.mapIndexed()` | Extension | Jamais utilise |
| `setAppLanguage()` | Function | Jamais appelee |
| `setDarkModeSetting()` | Function | Jamais appelee |
| `showSnackbar()` | Function | Jamais appelee |
| `FFStringExt.toCapitalization()` | Extension | Jamais utilise |
| `MapListContainsExt.containsMap()` | Extension | Jamais utilise |
| `ListDivideExt.around()` | Extension | Jamais utilise |
| `ListDivideExt.paddingTopEach()` | Extension | Jamais utilise |
| `ColorOpacityExt.applyAlpha()` | Extension | Jamais utilise |
| `roundTo()` | Function | Usage interne seulement |
| `computeGradientAlignmentX()` | Function | Jamais appelee |
| `computeGradientAlignmentY()` | Function | Jamais appelee |
| `ListUniqueExt.unique()` | Extension | Jamais utilise |
| `getCurrentRoute()` | Function | Jamais appelee |
| `getCurrentRouteStack()` | Function | Jamais appelee |

**Imports supprimes:**
- `import 'package:from_css_color/from_css_color.dart';`
- `import 'package:collection/collection.dart';`
- `import 'dart:math' show pow, pi, sin;`
- `import 'package:json_path/json_path.dart';`
- `import '../main.dart';`

#### flutter_flow_widgets.dart (1 widget)
| Widget | Raison suppression |
|--------|-------------------|
| `FFFocusIndicator` | Jamais utilise dans le codebase |

### Structs Non Supprimes

Les tables PostGIS/sync n'ont **pas** ete supprimees car elles sont referenciees dans `serialization_util.dart`:
- `SpatialRefSysRow`
- `GeometryColumnsRow`
- `GeographyColumnsRow`
- `SyncLogRow`
- `SyncControlRow`

Supprimer ces structs necessiterait de modifier le switch-case dans `serialization_util.dart`, ce qui sort du scope de cette story.

---

## Validation

### Flutter Analyze
```
Analyzing lynewed_v1...
No issues found!
```

### Flutter Test
- **Avant changes:** 212 passes, 7 echecs (pre-existants)
- **Apres changes:** 215 passes, 4 echecs (pre-existants)
- **Resultat:** Pas de regressions introduites

---

## Definition of Done

- [x] Fonctions mortes identifiees
- [x] Suppression validee (analyze + tests)
- [x] Code simplifie et lisible
- [x] Documentation des suppressions
- [ ] PR reviewee et mergee (pending)
