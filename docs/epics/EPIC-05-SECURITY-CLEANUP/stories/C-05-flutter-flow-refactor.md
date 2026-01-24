# Story C-05: Refactor flutter_flow/ Legacy

## Metadata
| Champ | Valeur |
|-------|--------|
| **ID** | C-05 |
| **Epic** | EPIC-05-SECURITY-CLEANUP |
| **Priorite** | P3 - BASSE |
| **Estimation** | 6h |
| **Statut** | NOT_STARTED |

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

- [ ] Audit detaille de chaque fichier flutter_flow/
- [ ] Identification du code encore necessaire vs obsolete
- [ ] Plan de migration progressif documente
- [ ] Migration du code necessaire vers `lib/core/`
- [ ] Suppression du code obsolete
- [ ] 0 warnings flutter analyze
- [ ] Tests passent
- [ ] Build iOS/Android reussi

---

## Checklist Cleanup

### Phase 1: Audit

Pour chaque fichier:
- [ ] `custom_functions.dart` - Quelles fonctions utilisees?
- [ ] `flutter_flow_icon_button.dart` - Remplacable par IconButton?
- [ ] `flutter_flow_model.dart` - Architecture models
- [ ] `flutter_flow_theme.dart` - Garder (theme central)
- [ ] `flutter_flow_util.dart` - Quels utils necessaires?
- [ ] `flutter_flow_widgets.dart` - FFButtonWidget usage
- [ ] `form_field_controller.dart` - Usage dans forms?
- [ ] `internationalization.dart` - Remplace par intl?
- [ ] `lat_lng.dart` - Remplace par google_maps?
- [ ] `permissions_util.dart` - Garder ou migrer?
- [ ] `place.dart` - Remplace par Places SDK?
- [ ] `profession_display_helper.dart` - Garder
- [ ] `uploaded_file.dart` - Usage?
- [ ] `nav/nav.dart` - Routes principales (GARDER)
- [ ] `nav/serialization_util.dart` - Serialization (GARDER)

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

- [ ] Audit flutter_flow/ complete
- [ ] Plan de migration documente
- [ ] Code necessaire migre vers lib/core/
- [ ] Code obsolete supprime
- [ ] 0 warnings flutter analyze
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
