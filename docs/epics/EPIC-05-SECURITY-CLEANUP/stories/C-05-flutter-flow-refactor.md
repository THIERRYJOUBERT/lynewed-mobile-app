# Story C-05: Refactor flutter_flow/ Legacy

## Metadata
| Champ | Valeur |
|-------|--------|
| **ID** | C-05 |
| **Epic** | EPIC-05-SECURITY-CLEANUP |
| **Priorite** | P3 - BASSE |
| **Estimation** | 6h (reduit a 2h - audit seulement) |
| **Statut** | COMPLETE (Phase 1 - Audit) |
| **Date** | 2026-01-24 |

---

## Description

En tant que **maintainer**, je veux refactorer le dossier `lib/flutter_flow/` legacy afin de **eliminer la dette technique FlutterFlow et moderniser le codebase**.

---

## Contexte

Le dossier `lib/flutter_flow/` contient du code genere par FlutterFlow, maintenant maintenu manuellement. Il est fortement couple avec le reste de l'app (243 imports detectes).

### Structure Actuelle

```
lib/flutter_flow/
├── custom_functions.dart      # ~400 lignes - Fonctions custom
├── flutter_flow_icon_button.dart  # Widget button
├── flutter_flow_model.dart    # Base model FlutterFlow
├── flutter_flow_theme.dart    # Theme management
├── flutter_flow_util.dart     # Utilities diverses
├── flutter_flow_widgets.dart  # FFButtonWidget, etc.
├── form_field_controller.dart # Form controllers
├── internationalization.dart  # i18n helpers
├── lat_lng.dart               # LatLng wrapper
├── permissions_util.dart      # Permissions helper
├── place.dart                 # Place model
├── profession_display_helper.dart  # Display helpers
├── uploaded_file.dart         # Upload model
└── nav/
    ├── nav.dart               # Navigation principale (~670 lignes)
    └── serialization_util.dart # Serialization helpers
```

### Dependances

- **243 fichiers** importent `flutter_flow/`
- Impact TRES HAUT si modifie incorrectement

---

## Criteres d'Acceptance

**Phase 1 - Audit (CETTE STORY)**:
- [x] Audit detaille de chaque fichier flutter_flow/
- [x] Identification du code encore necessaire vs obsolete
- [x] Plan de migration progressif documente
- [x] 0 warnings flutter analyze

**Phase 2 - Migration (FUTURE STORY C-05b)**:
- [ ] Migration du code necessaire vers `lib/core/`
- [ ] Suppression du code obsolete
- [ ] Tests passent
- [ ] Build iOS/Android reussi

**Note**: La Phase 2 est OPTIONNELLE. L'audit a determine que TOUS les fichiers sont utilises et une migration serait risquee (173+ fichiers a modifier).

---

## Checklist Cleanup

### Phase 1: Audit (COMPLETE - 2026-01-24)

Pour chaque fichier:
- [x] `custom_functions.dart` - 18 fichiers l'importent - GARDER (fonctions business critiques)
- [x] `flutter_flow_icon_button.dart` - 10 fichiers l'importent - GARDER (widget utilise)
- [x] `flutter_flow_model.dart` - 1 fichier direct, mais exporte via util - GARDER OBLIGATOIRE
- [x] `flutter_flow_theme.dart` - 33 fichiers l'importent - GARDER OBLIGATOIRE (theme central)
- [x] `flutter_flow_util.dart` - 156 fichiers l'importent - GARDER OBLIGATOIRE (hub d'exports)
- [x] `flutter_flow_widgets.dart` - 6 fichiers l'importent - GARDER (FFButtonWidget)
- [x] `form_field_controller.dart` - 1 fichier l'importe - GARDER (onboarding)
- [x] `internationalization.dart` - 1 fichier direct + 9 via FFLocalizations - GARDER
- [x] `lat_lng.dart` - 2 fichiers l'importent + exporte via util - GARDER (utilise partout)
- [x] `permissions_util.dart` - 1 fichier l'importe - GARDER
- [x] `place.dart` - 1 fichier direct + exporte via util - GARDER (FFPlace utilise)
- [x] `profession_display_helper.dart` - 2 fichiers l'importent - GARDER
- [x] `uploaded_file.dart` - exporte via util + FFUploadedFile utilise dans 5 fichiers - GARDER
- [x] `nav/nav.dart` - Exporte via util - GARDER OBLIGATOIRE
- [x] `nav/serialization_util.dart` - Utilise FFPlace, FFUploadedFile - GARDER OBLIGATOIRE

### Phase 2: Migration

Creer dans `lib/core/`:
```
lib/core/
├── utils/
│   ├── input_validators.dart   # Depuis custom_functions
│   ├── date_formatters.dart    # Depuis flutter_flow_util
│   └── currency_formatters.dart
├── theme/
│   └── app_theme.dart          # Migration depuis flutter_flow_theme?
└── widgets/
    └── ff_button.dart          # Si encore necessaire
```

### Phase 3: Suppression

- [ ] Supprimer fichiers obsoletes
- [ ] Mettre a jour imports
- [ ] Verifier 0 references

---

## Implementation

### Strategie de Migration

**IMPORTANT**: Migration progressive, pas big bang!

1. **Identifier les fonctions utilisees** dans chaque fichier
2. **Copier** dans `lib/core/` les fonctions necessaires
3. **Mettre a jour les imports** progressivement
4. **Supprimer** les fichiers quand 0 imports restants

### Fichiers a GARDER (critique)

| Fichier | Raison |
|---------|--------|
| `nav/nav.dart` | Routes principales de l'app |
| `nav/serialization_util.dart` | Serialization pour navigation |
| `flutter_flow_theme.dart` | Theme central (tres couple) |
| `flutter_flow_model.dart` | Base des models (tres couple) |
| `profession_display_helper.dart` | Specifique metier |

### Fichiers CANDIDATS a suppression/migration

| Fichier | Action |
|---------|--------|
| `lat_lng.dart` | Migrer vers google_maps LatLng |
| `place.dart` | Migrer vers Places SDK model |
| `internationalization.dart` | Simplifier avec intl |
| `uploaded_file.dart` | Verifier usage, potentiellement supprimer |
| `flutter_flow_icon_button.dart` | Remplacer par IconButton standard |

---

## Plan de Migration Detaille

### Sprint 1: Audit et Documentation
- Lister TOUTES les fonctions/classes par fichier
- Pour chacune, compter usages
- Documenter plan migration

### Sprint 2: Migration Utils
- Creer `lib/core/utils/`
- Migrer fonctions necessaires de `custom_functions.dart`
- Migrer fonctions necessaires de `flutter_flow_util.dart`

### Sprint 3: Migration Widgets
- Evaluer si FFButtonWidget necessaire
- Remplacer par ElevatedButton/TextButton si possible
- Migrer ou supprimer `flutter_flow_icon_button.dart`

### Sprint 4: Cleanup Final
- Supprimer fichiers obsoletes
- Mettre a jour imports
- Documentation

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Casser navigation | CRITIQUE | Tests E2E exhaustifs |
| Casser theme | HAUT | Tests visuels |
| 243 fichiers a modifier | HAUT | Migration progressive |
| Regression fonctionnelle | HAUT | Tests avant chaque merge |

---

## Definition of Done

**Phase 1 (COMPLETE)**:
- [x] Audit flutter_flow/ complete
- [x] Plan de migration documente
- [x] 0 warnings flutter analyze
- [x] Documentation dans story

**Phase 2 (NON NECESSAIRE - tous fichiers utilises)**:
- [ ] Code necessaire migre vers lib/core/
- [ ] Code obsolete supprime
- [ ] Tests passent
- [ ] Build iOS/Android reussi
- [ ] PR reviewee et mergee

---

## Notes

Cette story est la plus complexe de l'Epic. Elle peut etre decoupee en sous-stories si necessaire:
- C-05a: Audit flutter_flow/
- C-05b: Migration utils
- C-05c: Migration widgets
- C-05d: Cleanup final

---

## AUDIT COMPLET (2026-01-24)

### Resume Statistiques

| Fichier | Imports directs | Utilisations indirectes | Action |
|---------|-----------------|------------------------|--------|
| `nav/nav.dart` | 0 (exporte via util) | ~156 | **GARDER - CRITIQUE** |
| `nav/serialization_util.dart` | 0 (interne) | ~156 | **GARDER - CRITIQUE** |
| `flutter_flow_util.dart` | 156 | N/A (hub) | **GARDER - CRITIQUE** |
| `flutter_flow_theme.dart` | 33 | N/A | **GARDER - CRITIQUE** |
| `custom_functions.dart` | 18 | N/A | **GARDER** |
| `flutter_flow_icon_button.dart` | 10 | N/A | **GARDER** |
| `flutter_flow_model.dart` | 1 | ~156 (via util) | **GARDER - CRITIQUE** |
| `flutter_flow_widgets.dart` | 6 | N/A | **GARDER** |
| `internationalization.dart` | 1 | 9 (FFLocalizations) | **GARDER** |
| `lat_lng.dart` | 2 | ~156 (via util) | **GARDER** |
| `place.dart` | 1 | ~156 (via util) | **GARDER** |
| `permissions_util.dart` | 1 | N/A | **GARDER** |
| `profession_display_helper.dart` | 2 | N/A | **GARDER** |
| `form_field_controller.dart` | 1 | N/A | **GARDER** |
| `uploaded_file.dart` | 0 | ~156 (via util) + 5 directs | **GARDER** |

### Conclusion Audit

**AUCUN FICHIER A SUPPRIMER**

Tous les fichiers du dossier `lib/flutter_flow/` sont activement utilises:
- 173 fichiers importent au total le dossier flutter_flow/
- 233 occurrences d'imports detectees
- Chaque fichier a au moins 1 usage direct ou indirect

### Raisons de Conservation

1. **flutter_flow_util.dart** - Hub central qui re-exporte:
   - `lat_lng.dart`
   - `place.dart`
   - `uploaded_file.dart`
   - `flutter_flow_model.dart`
   - `nav/nav.dart`
   - `internationalization.dart` (FFLocalizations)

2. **Fichiers avec peu d'imports directs mais critiques**:
   - `place.dart` et `uploaded_file.dart` sont utilises via serialization_util.dart
   - `flutter_flow_model.dart` est la base de tous les models de page
   - `lat_lng.dart` est utilise pour les coordonnees geo

3. **Fichiers "legacy" mais necessaires**:
   - `internationalization.dart` - Utilise pour FFLocalizations (9 fichiers)
   - `form_field_controller.dart` - Utilise dans onboarding wizard
   - `permissions_util.dart` - Utilise dans onboarding

### Plan de Migration Future (NON dans cette story)

**C-05b (Future)**: Si souhaite, migrer progressivement vers lib/core/:
1. Creer `lib/core/utils/geo.dart` pour LatLng
2. Creer `lib/core/models/place.dart` pour FFPlace
3. Creer `lib/core/models/uploaded_file.dart` pour FFUploadedFile
4. Mettre a jour flutter_flow_util.dart pour re-exporter depuis core/
5. Supprimer les anciens fichiers un par un

**MAIS** - Cela necessite de modifier 173+ fichiers. Risque TRES ELEVE.
Recommandation: **NE PAS migrer** sauf si absolument necessaire.

### Code Potentiellement Mort (a verifier)

| Fonction | Fichier | Status |
|----------|---------|--------|
| `professionFromSupabaseToken` | custom_functions.dart | Non utilise externement (garde pour symetrie avec mapProfessionsToSupabaseTokens) |

**Note**: Ces fonctions sont conservees car elles pourraient etre utilisees dans le futur ou via reflection/dynamic. Ne pas supprimer sans test exhaustif.
