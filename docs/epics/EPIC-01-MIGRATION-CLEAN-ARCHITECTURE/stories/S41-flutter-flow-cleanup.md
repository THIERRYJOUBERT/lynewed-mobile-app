# Story S41: Flutter Flow Cleanup

## Description

En tant que developpeur, je veux supprimer tout le code FlutterFlow legacy afin d'avoir un codebase 100% Clean Architecture.

## Criteres d'Acceptance (Gherkin)

- [ ] Given le dossier lib/flutter_flow/ When je supprime les fichiers inutilises Then le build fonctionne

- [ ] Given le dossier lib/pages/ When je supprime les fichiers migres Then le build fonctionne

- [ ] Given le dossier lib/custom_code/ When je supprime les fichiers migres Then le build fonctionne

- [ ] Given les imports FlutterFlow When je les remplace Then aucun import flutter_flow n'existe

## Fichiers Concernes

### A Supprimer (apres migration complete)
```
lib/flutter_flow/
├── flutter_flow_icon_button.dart    # Remplace par design system
├── flutter_flow_model.dart          # Remplace par ChangeNotifier/Cubit
├── flutter_flow_theme.dart          # Remplace par design system
├── flutter_flow_util.dart           # Remplace par core/utils
├── flutter_flow_widgets.dart        # Remplace par design system
├── form_field_controller.dart       # Remplace par standard Flutter
├── uploaded_file.dart               # Remplace par core/utils
├── place.dart                       # Remplace par core/models
├── lat_lng.dart                     # Remplace par google_maps
├── permissions_util.dart            # Remplace par PermissionService
├── custom_functions.dart            # Migrer vers modules
├── profession_display_helper.dart   # Migrer vers core/utils
└── nav/                             # Garder/adapter si necessaire
    ├── nav.dart
    └── serialization_util.dart

lib/pages/                           # Tout supprimer apres migration
├── auth/
├── bride/
├── pro/
├── shared/
└── onboarding/

lib/custom_code/
├── actions/                         # Tout supprimer apres migration
└── widgets/                         # Tout supprimer apres migration
    └── index.dart
```

### A Garder/Adapter
```
lib/flutter_flow/
├── internationalization.dart        # Garder (i18n)
└── nav/                             # Adapter pour compatibilite
```

## Notes Techniques

### Etapes de Cleanup

#### 1. Verification Pre-Cleanup
```bash
# Verifier qu'aucun fichier flutter_flow n'est importe
grep -r "import.*flutter_flow" lib/ --include="*.dart" | grep -v "flutter_flow/"

# Verifier qu'aucun fichier pages/ n'est importe
grep -r "import.*pages/" lib/ --include="*.dart" | grep -v "pages/"

# Verifier qu'aucune action custom_code n'est importee
grep -r "import.*custom_code/actions" lib/ --include="*.dart" | grep -v "custom_code/"
```

#### 2. Suppression Progressive
1. **Supprimer un fichier a la fois**
2. **Lancer flutter analyze apres chaque suppression**
3. **Si erreur, identifier et migrer la dependance**

#### 3. Mise a jour index.dart
```dart
// lib/index.dart - AVANT
export 'pages/auth/sign_in_email_page/sign_in_email_page_widget.dart';
export 'pages/bride/home_brides/home_brides_widget.dart';
// ...

// lib/index.dart - APRES
export 'features/auth/auth.dart';
export 'features/home/home.dart';
export 'features/chat/chat.dart';
// ...
```

#### 4. Nettoyage Navigation
```dart
// Si nav.dart est garde, adapter pour pointer vers features/
GoRoute(
  path: '/home',
  name: 'HomeBrides',
  builder: (context, state) => const HomeBridesPage(), // from features/home
),
```

### Checklist Finale
- [ ] Aucun import `package:lynewed/flutter_flow/`
- [ ] Aucun import `package:lynewed/pages/`
- [ ] Aucun import `package:lynewed/custom_code/actions/`
- [ ] Aucun import `package:lynewed/custom_code/widgets/`
- [ ] `flutter analyze --fatal-infos` passe
- [ ] `flutter build ios` passe
- [ ] `flutter build apk` passe
- [ ] Tests passent

### Plan de Rollback
Si des problemes surviennent :
1. Garder une branche de backup avant cleanup
2. Ne pas supprimer les fichiers dans le meme commit que la migration
3. Avoir des tests de regression

## Definition of Done

- [ ] lib/flutter_flow/ nettoye (sauf i18n, nav adapter)
- [ ] lib/pages/ entierement supprime
- [ ] lib/custom_code/actions/ entierement supprime
- [ ] lib/custom_code/widgets/ entierement supprime
- [ ] lib/index.dart mis a jour
- [ ] Tous les builds passent
- [ ] Tous les tests passent
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Eleve (risque de regression)

## Dependances

- Toutes les stories de migration (S01-S40)

## Stories Dependantes

- S42 : Final cleanup
