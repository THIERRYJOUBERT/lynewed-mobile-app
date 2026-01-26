# EPIC-01: Migration FlutterFlow vers Clean Architecture

## Resume

Migration complete du code FlutterFlow legacy vers l'architecture Clean Architecture, en utilisant le module Map comme reference. Cette migration vise a ameliorer la maintenabilite, la testabilite et la qualite du code tout en preservant les fonctionnalites existantes.

## Contexte

### Etat Actuel
- **~60% code FlutterFlow legacy** : `lib/pages/`, `lib/flutter_flow/`, `lib/custom_code/`
- **~40% deja en Clean Architecture** : `lib/features/` (Map = reference complete)
- **Backend Supabase** : NE PAS TOUCHER (`lib/backend/supabase/`)

### Problemes du Code Legacy
1. **Couplage fort** : UI directement liee aux appels Supabase
2. **Non-testable** : Pas de separation des responsabilites
3. **Duplication** : Code similaire repete entre pages
4. **FlutterFlowModel** : Pattern proprietaire non-standard
5. **Actions disparates** : Logique metier dans `lib/custom_code/actions/`

### Architecture Cible

```
lib/features/<module>/
├── domain/                    # Couche Business Logic
│   ├── entities/              # Modeles metier (immutables)
│   ├── repositories/          # Interfaces des repositories
│   └── usecases/              # Cas d'utilisation (optionnel)
│
├── data/                      # Couche Data
│   ├── datasources/           # Sources de donnees (Supabase, cache)
│   ├── models/                # DTOs et mappers
│   └── repositories/          # Implementation des repositories
│
└── presentation/              # Couche UI
    ├── pages/                 # Pages/Screens
    ├── widgets/               # Widgets reutilisables
    ├── sheets/                # Bottom sheets
    ├── bloc/ ou state/        # State management (Cubit/ChangeNotifier)
    └── theme/                 # Theme specifique au module (optionnel)
```

## Objectifs

### Objectifs Principaux
1. **100% code en Clean Architecture** - Eliminer toute dependance FlutterFlow
2. **Testabilite** - Couverture de tests pour domain et data layers
3. **Maintenabilite** - Code modulaire et comprehensible
4. **Performance** - Optimisation des requetes et du state management

### Objectifs Secondaires
1. Reduction de ~30% du code (elimination duplication)
2. Documentation des modules migres
3. Patterns reutilisables pour futurs developpements

## Modules a Migrer (Priorite)

| Priorite | Module | Complexite | Dependances |
|----------|--------|------------|-------------|
| 1 | Chat (completion) | Moyenne | Aucune |
| 2 | Notifications (completion) | Faible | Aucune |
| 3 | Auth | Moyenne | Core |
| 4 | My Wedding (completion) | Elevee | Auth |
| 5 | Pages Shared | Elevee | Auth, Chat |
| 6 | Pages Bride | Moyenne | Auth, My Wedding |
| 7 | Pages Pro | Moyenne | Auth |
| 8 | Custom Code Actions | Elevee | Tous |
| 9 | Flutter Flow Utils | Faible | Core |

## Reference: Module Map

Le module Map (`lib/features/map/`) est la reference pour cette migration :

### Structure Exemplaire
```
lib/features/map/
├── map.dart                           # Barrel export
├── domain/
│   ├── entities/
│   │   ├── entities.dart              # Barrel
│   │   ├── map_marker.dart
│   │   ├── map_filter.dart
│   │   ├── professional_alert.dart
│   │   ├── professional_details.dart
│   │   ├── alert_details.dart
│   │   ├── wedding.dart
│   │   └── wedding_details.dart
│   ├── repositories/
│   │   └── map_repository.dart        # Interface abstraite
│   ├── usecases/
│   │   └── get_marker_details.dart
│   └── utils/
│       └── marker_offset.dart
├── data/
│   ├── datasources/
│   │   └── supabase_map_datasource.dart
│   ├── models/
│   │   └── marker_type_mapper.dart
│   └── repositories/
│       └── supabase_map_repository.dart
└── presentation/
    ├── pages/
    │   ├── map_page.dart
    │   ├── map_brides_large_wrapper.dart
    │   └── map_pro_large_wrapper.dart
    ├── widgets/
    │   ├── lynewed_map_widget.dart
    │   ├── filter_sheet.dart
    │   ├── marker_details_sheet.dart
    │   ├── animated_marker.dart
    │   ├── map_controls.dart
    │   └── wedding_location_filter.dart
    ├── sheets/
    │   ├── sheets.dart
    │   ├── professional_details_sheet.dart
    │   ├── alert_create_sheet.dart
    │   ├── alert_details_sheet.dart
    │   ├── wedding_create_sheet.dart
    │   └── upcoming_travels_sheet.dart
    ├── state/
    │   └── map_state.dart             # ChangeNotifier
    ├── services/
    │   └── map_actions_service.dart
    └── theme/
        └── map_theme.dart
```

### Patterns a Reproduire
1. **Barrel exports** : Un fichier `module.dart` qui exporte tout
2. **Entities immutables** : Classes avec `const` constructors et `copyWith`
3. **Repository interface** : Abstract class dans domain/
4. **Repository impl** : Implementation concrete dans data/
5. **State management** : ChangeNotifier ou Cubit selon complexite
6. **Wrappers legacy** : Maintenir compatibilite navigation FlutterFlow

## Contraintes

### A Respecter
- [ ] **NE PAS toucher** au backend Supabase (`lib/backend/supabase/`)
- [ ] **Maintenir** la compatibilite avec la navigation existante
- [ ] **TDD** : Tests avant code pour domain et data
- [ ] **0 warnings** : `flutter analyze --fatal-infos`
- [ ] **Incremental** : Migration module par module, pas de big bang

### A Eviter
- [ ] Casser les fonctionnalites existantes
- [ ] Modifier plusieurs modules en parallele
- [ ] Creer des dependances circulaires entre features

## Criteres de Succes

### Par Module
- [ ] Tous les tests passent
- [ ] 0 warnings flutter analyze
- [ ] Documentation du barrel export
- [ ] Review adversariale validee

### Global
- [ ] 100% du code migre
- [ ] `lib/flutter_flow/` peut etre supprime
- [ ] `lib/custom_code/` peut etre supprime
- [ ] `lib/pages/` peut etre supprime
- [ ] Performance equivalente ou superieure

## Timeline Estimee

| Phase | Stories | Duree Estimee |
|-------|---------|---------------|
| Phase 1 : Fondations | S01-S04 | 1 semaine |
| Phase 2 : Chat & Notifications | S05-S10 | 1 semaine |
| Phase 3 : Auth & Core | S11-S16 | 1 semaine |
| Phase 4 : My Wedding | S17-S22 | 2 semaines |
| Phase 5 : Pages Legacy | S23-S35 | 2 semaines |
| Phase 6 : Custom Code & Cleanup | S36-S42 | 1 semaine |

**Total estime** : 8 semaines

## Stories

Voir le dossier `stories/` pour le detail de chaque story.

### Index des Stories

#### Phase 1 : Fondations
- S01 : Setup infrastructure et conventions
- S02 : Migration FlutterFlow utilities
- S03 : Core design system extraction
- S04 : Navigation system refactoring

#### Phase 2 : Chat & Notifications
- S05 : Chat - Domain layer completion
- S06 : Chat - Data layer completion
- S07 : Chat - Presentation layer completion
- S08 : Notifications - Domain layer
- S09 : Notifications - Data layer
- S10 : Notifications - Presentation completion

#### Phase 3 : Auth
- S11 : Auth - Domain layer (entities, repository interface)
- S12 : Auth - Data layer (repository impl)
- S13 : Auth - Presentation layer (pages migration)
- S14 : Auth - Login/Signup pages
- S15 : Auth - Password reset flow
- S16 : Auth - Startup gate refactoring

#### Phase 4 : My Wedding
- S17 : My Wedding - Domain layer completion
- S18 : My Wedding - Data layer completion
- S19 : My Wedding - Onboarding flow
- S20 : My Wedding - Team management
- S21 : My Wedding - Inspirations/Albums
- S22 : My Wedding - Agenda/Budget/Guests

#### Phase 5 : Pages Legacy
- S23 : Shared - Profile pages
- S24 : Shared - Settings pages
- S25 : Shared - Support page
- S26 : Shared - Video call page
- S27 : Shared - Content/Replay pages
- S28 : Bride - Home page
- S29 : Bride - Feed pages
- S30 : Bride - Messages page wrapper
- S31 : Bride - Edit profile
- S32 : Pro - Dashboard page
- S33 : Pro - Messages page wrapper
- S34 : Pro - Wishlist page
- S35 : Pro - Public profile view

#### Phase 6 : Custom Code & Cleanup
- S36 : Custom Code - Chat actions migration
- S37 : Custom Code - Notification actions migration
- S38 : Custom Code - Profile actions migration
- S39 : Custom Code - Widgets migration
- S40 : Custom Code - Video/Media actions
- S41 : Flutter Flow cleanup
- S42 : Final cleanup et validation

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Regression fonctionnelle | Eleve | Tests E2E avant/apres |
| Performance degradee | Moyen | Benchmarks par module |
| Delai depasse | Moyen | Stories atomiques, parallelisation |
| Compatibilite navigation | Eleve | Wrappers legacy, migration incrementale |

## Notes Techniques

### Dependances a Ajouter
```yaml
dependencies:
  # State management (si pas deja present)
  flutter_bloc: ^8.x  # ou provider suffit

dev_dependencies:
  # Testing
  mocktail: ^1.x
  bloc_test: ^9.x  # si utilisation de Bloc
```

### Conventions de Nommage
- **Entities** : `PascalCase` (ex: `WeddingGuest`)
- **Repositories** : `PascalCaseRepository` (ex: `ChatRepository`)
- **Implementations** : `PascalCaseRepositoryImpl` (ex: `ChatRepositoryImpl`)
- **Datasources** : `SupabasePascalCaseDatasource` (ex: `SupabaseChatDatasource`)
- **State** : `PascalCaseState/Notifier/Cubit` (ex: `ChatRoomNotifier`)

---

**Cree le** : 2026-01-24
**Derniere mise a jour** : 2026-01-26
**Statut** : COMPLETE (86% - core features migres, cleanup defere)
