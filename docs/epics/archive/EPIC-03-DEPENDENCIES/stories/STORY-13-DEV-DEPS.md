# Story STORY-13: Mise a Jour des Dev Dependencies

## Description

Mettre a jour les dependances de developpement. Ces packages n'impactent pas l'app en production mais peuvent affecter le workflow de developpement.

| Package | Actuel | Cible | Saut | Changelog |
|---------|--------|-------|------|-----------|
| flutter_launcher_icons | 0.13.1 | 0.14.4 | Minor | [pub.dev](https://pub.dev/packages/flutter_launcher_icons/changelog) |
| flutter_lints | 4.0.0 | 6.0.0 | 4 -> 6 | [pub.dev](https://pub.dev/packages/flutter_lints/changelog) |
| lints | 4.0.0 | 6.0.0 | 4 -> 6 | [pub.dev](https://pub.dev/packages/lints/changelog) |
| image | 4.2.0 | 4.7.2 | Minor | [pub.dev](https://pub.dev/packages/image/changelog) |

## Criteres d'Acceptance

- [ ] Tous les dev packages listes mis a jour
- [ ] `flutter pub get` reussit sans erreur
- [ ] `flutter analyze --fatal-infos` passe (avec potentiellement nouvelles regles)
- [ ] `flutter test` passe
- [ ] Generation des icones fonctionne (`flutter pub run flutter_launcher_icons`)
- [ ] App compile sur iOS et Android

## Breaking Changes Potentiels

### flutter_lints 6.x (MAJEUR)

**ATTENTION**: Nouvelles regles de lint = potentiellement beaucoup de warnings

Changements:
- Nouvelles regles strictes
- Regles existantes modifiees
- Certaines regles passent de warning a error

### lints 6.x (MAJEUR)

Package de base pour flutter_lints - memes changements.

### flutter_launcher_icons 0.14.x

Changements possibles:
- Nouveaux formats d'icones supportes
- Changements de configuration

### image 4.7.x

Utilise par flutter_launcher_icons:
- Nouveaux formats d'image
- Ameliorations de performance

## Strategie de Migration

### Etape 1: Mettre a jour flutter_lints/lints

1. Mettre a jour les packages
2. Executer `flutter analyze`
3. **ATTENTION**: Potentiellement beaucoup de nouveaux warnings
4. Decider: corriger ou ignorer certaines regles

### Etape 2: Gerer les Nouveaux Warnings

Option A: Corriger tous les warnings (recommande)
```bash
flutter analyze --fatal-infos
# Corriger chaque warning
```

Option B: Ignorer certaines regles temporairement
```yaml
# analysis_options.yaml
linter:
  rules:
    some_new_rule: false  # Desactiver temporairement
```

### Etape 3: Mettre a jour flutter_launcher_icons

1. Mettre a jour le package
2. Regenerer les icones:
```bash
flutter pub run flutter_launcher_icons
```
3. Verifier les icones generees dans:
   - `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
   - `android/app/src/main/res/mipmap-*/`

## Tests Manuels Requis

### 1. Test Lints

```bash
# Executer l'analyse
flutter analyze --fatal-infos

# Si warnings, les lister
flutter analyze 2>&1 | head -50
```

### 2. Test Launcher Icons

```bash
# Regenerer les icones
flutter pub run flutter_launcher_icons

# Verifier la generation
ls -la ios/Runner/Assets.xcassets/AppIcon.appiconset/
ls -la android/app/src/main/res/mipmap-hdpi/
```

### 3. Test Build

```bash
# iOS
flutter build ios --no-codesign

# Android
flutter build apk --debug
```

### 4. Test Visuel des Icones

- Installer l'app sur un device
- Verifier que l'icone s'affiche correctement
- Verifier sur iOS ET Android

## Migration Lints

### Nouvelles Regles Courantes (6.x)

```yaml
# Exemples de nouvelles regles possibles
linter:
  rules:
    # Regles qui peuvent etre nouvellement activees
    avoid_print: true
    avoid_relative_lib_imports: true
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_final_fields: true
    require_trailing_commas: true
    use_super_parameters: true
```

### Gerer les Warnings Existants

Si trop de warnings, prioriser:

1. **Critique**: Security-related rules
2. **Important**: Performance rules
3. **Nice to have**: Style rules

## Rollback

```bash
# Dans pubspec.yaml, revenir a:
dev_dependencies:
  flutter_launcher_icons: 0.13.1
  flutter_lints: 4.0.0
  image: 4.2.0
  lints: 4.0.0

# Puis:
flutter pub get
```

## Estimation

- **Effort**: S a L (2h a 1 jour) - Depend du nombre de warnings
- **Risque**: Faible (n'impacte pas la production)

## Notes

### Impact sur CI/CD

Si le pipeline CI echoue sur `flutter analyze`:
- Soit corriger tous les warnings
- Soit ajuster temporarily les regles dans `analysis_options.yaml`

### Strategie Recommandee

1. Mettre a jour flutter_launcher_icons et image d'abord (faible risque)
2. Ensuite flutter_lints/lints
3. Dedier du temps pour corriger les nouveaux warnings

### Fichier analysis_options.yaml

```yaml
# Exemple de configuration possible
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Ajuster selon les besoins du projet
    avoid_print: false  # Si utilise pour debug
    prefer_const_constructors: true
    # etc.

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
```

### Avant/Apres Warnings

Documenter le nombre de warnings avant et apres:
- Avant: X warnings
- Apres: Y warnings
- Corriges: Z warnings
- Ignores: W warnings (avec justification)
