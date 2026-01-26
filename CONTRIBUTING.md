# Contributing to Lynewed

Merci de contribuer au projet Lynewed ! Ce guide explique les conventions, le workflow de développement et les standards de qualité attendus.

---

## Prérequis

Avant de contribuer, assurez-vous d'avoir:
- Lu le [README.md](README.md) pour l'installation
- Compris l'[ARCHITECTURE.md](ARCHITECTURE.md) du projet
- Flutter 3.32.4+ et Dart 3.8.1+ installés

---

## Workflow Git

### Branches

```
main              → Production stable
develop           → Intégration (si utilisé)
feature/*         → Nouvelles fonctionnalités
fix/*             → Corrections de bugs
epic-XX/*         → Travail sur un Epic spécifique
```

### Créer une Feature

```bash
# 1. Partir de main à jour
git checkout main
git pull origin main

# 2. Créer la branche
git checkout -b feature/nom-de-la-feature
# OU pour un fix:
git checkout -b fix/description-courte

# 3. Développer avec commits structurés

# 4. Pousser et créer PR
git push -u origin feature/nom-de-la-feature
```

---

## Conventions de Commit

Format: `type(scope): description`

| Type | Usage |
|------|-------|
| `feat` | Nouvelle fonctionnalité |
| `fix` | Correction de bug |
| `refactor` | Refactoring sans changement fonctionnel |
| `docs` | Documentation |
| `style` | Formatage, style |
| `test` | Ajout/modification de tests |
| `chore` | Maintenance, dépendances |

### Exemples

```bash
# Feature avec Epic
feat(epic-01): complete S30-S42 migration - dashboard, wishlist, profile

# Documentation
docs(epic-01): complete EPIC-01 migration with final documentation

# Fix spécifique
fix(ios): restore flutter_dotenv, fix firebase & notifications provider

# Maintenance
chore: update dependencies to latest versions
```

### Bonnes Pratiques

- Inclure le numéro d'Epic/Story si applicable: `feat(epic-04):`
- Description en **anglais**, concise mais descriptive
- Corps du commit pour détails si nécessaire

---

## Conventions de Code

### Langue

- **Code:** Anglais (classes, variables, fonctions)
- **Commentaires:** Anglais
- **Documentation:** Français (CLAUDE.md, epics)

### Nommage

| Élément | Convention | Exemple |
|---------|------------|---------|
| Fichiers | snake_case | `wedding_guest.dart` |
| Classes | PascalCase | `WeddingGuest` |
| Variables | camelCase | `guestCount` |
| Constantes | camelCase | `maxGuests` |
| Privées | _préfixe | `_internalState` |
| Enums | SCREAMING_CASE | `UserRole.PROFESSIONAL` |

### Structure de Fichier

```dart
// 1. Imports dart:
import 'dart:async';

// 2. Imports package:
import 'package:flutter/material.dart';

// 3. Imports relatifs projet (chemins absolus)
import '/core/design/design.dart';
import '../domain/entities/wedding_guest.dart';

// 4. Code
class MyWidget extends StatelessWidget {
  // ...
}
```

### Règles Dart/Flutter

| Règle | Exigence |
|-------|----------|
| Analyse | `flutter analyze --fatal-infos` = **0 warnings** |
| Tests | `flutter test` doit passer |
| Prints | Pas de `print()` en production |
| iOS minimum | **15.0** (Firebase 12.x) |
| Secrets | Via `dotenv.env['KEY']` uniquement |

---

## Créer un Nouveau Module

### Structure

```
lib/features/[module_name]/
├── domain/
│   ├── entities/
│   │   └── [entity_name].dart
│   └── repositories/
│       └── [module]_repository.dart
├── data/
│   ├── datasources/
│   │   └── supabase_[module]_datasource.dart
│   └── repositories/
│       └── [module]_repository_impl.dart
└── presentation/
    ├── pages/
    ├── widgets/
    ├── sheets/
    └── bloc/ (ou state/)
```

### Checklist Nouveau Module

- [ ] Entity créée dans `domain/entities/`
- [ ] Repository interface dans `domain/repositories/`
- [ ] Datasource dans `data/datasources/`
- [ ] Repository impl dans `data/repositories/`
- [ ] Page principale dans `presentation/pages/`
- [ ] Tests unitaires pour la logique métier
- [ ] Utilisation du Design System pour l'UI

### Exemple Entity

```dart
/// Guest invited to a wedding
class WeddingGuest {
  const WeddingGuest({
    required this.id,
    required this.name,
    this.email,
    this.role = 'guest',
  });

  final String id;
  final String name;
  final String? email;
  final String role;
}
```

### Exemple Repository Interface

```dart
/// Repository for wedding guest operations
abstract class WeddingGuestRepository {
  /// Fetch all guests for a wedding
  Future<List<WeddingGuest>> getGuests(String weddingId);

  /// Add a new guest
  Future<WeddingGuest> addGuest(String weddingId, WeddingGuest guest);
}
```

---

## Design System

**OBLIGATOIRE** pour toute nouvelle UI.

### Import

```dart
import '/core/design/design.dart';
import '/core/design/widgets/widgets.dart';
```

### Usage

```dart
// Couleurs
LynewedColors.primary           // Noir principal
LynewedColors.textPrimary       // Texte principal
LynewedColors.textSecondary     // Texte secondaire

// Typographie
LynewedTextStyles.sheetTitle    // Titre de sheet (20px, w500)
LynewedTextStyles.sectionTitle  // Titre de section (16px, w500)
LynewedTextStyles.bodyMedium    // Texte courant (14px, w400)

// Espacement
LynewedSpacing.sheetHorizontalPadding  // 20px
LynewedSpacing.buttonHeight            // 48px

// Widgets
LynewedButton(
  text: 'Confirmer',
  onPressed: () {},
)
```

### Règles UI

| Règle | Valeur |
|-------|--------|
| Font weight max | `w500` (jamais w600, w700) |
| Espacement sections | 30px |
| Espacement label→contenu | 10px |
| Hauteur boutons | 48px |
| Border radius boutons | 0 |

Documentation complète: [docs/App/DESIGN_SYSTEM.md](docs/App/DESIGN_SYSTEM.md)

---

## Tests

### Types de Tests

| Type | Location | Usage |
|------|----------|-------|
| Unitaires | `test/unit/` | Logique métier, entities, repositories |
| Widget | `test/widget/` | Composants UI isolés |
| Integration | `test/integration/` | Flows complets |

### Commandes

```bash
# Tous les tests
flutter test

# Tests spécifiques
flutter test test/unit/features/map/

# Avec couverture
flutter test --coverage
```

### Bonnes Pratiques

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock
class MockMapRepository extends Mock implements MapRepository {}

void main() {
  group('MapCubit', () {
    late MapCubit cubit;
    late MockMapRepository repository;

    setUp(() {
      repository = MockMapRepository();
      cubit = MapCubit(repository);
    });

    test('should load markers on init', () async {
      when(() => repository.searchMarkers(any()))
          .thenAnswer((_) async => MapSearchResult.empty);

      await cubit.loadMarkers();

      expect(cubit.state.markers, isEmpty);
    });
  });
}
```

---

## Checklist PR

Avant de soumettre une Pull Request:

### Code
- [ ] `flutter analyze --fatal-infos` passe (0 warnings)
- [ ] `flutter test` passe
- [ ] Pas de secrets dans le code
- [ ] Pas de `print()` ou logs debug
- [ ] Design System utilisé pour l'UI

### Documentation
- [ ] Code documenté si complexe
- [ ] PR description claire avec contexte

### Tests
- [ ] Tests unitaires pour logique métier
- [ ] Tests widget si composant réutilisable

### Commit
- [ ] Messages de commit structurés
- [ ] Historique propre (pas de "WIP", "fix typo" répétés)

---

## Process de Review

### Pour l'Auteur

1. Créer la PR avec une description claire
2. Lier l'Epic/Story si applicable
3. S'assurer que les checks CI passent
4. Répondre aux commentaires rapidement

### Pour le Reviewer

Vérifier:
- [ ] Le code fonctionne comme décrit
- [ ] Les conventions sont respectées
- [ ] Pas de régression introduite
- [ ] Les tests sont adéquats
- [ ] La performance n'est pas dégradée

### Merge

- Après approbation, l'auteur merge
- Préférer **Squash merge** pour les petites features
- Préférer **Merge commit** pour les gros Epic

---

## Ressources

- [README.md](README.md) - Installation
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture technique
- [docs/App/DESIGN_SYSTEM.md](docs/App/DESIGN_SYSTEM.md) - Design System complet
- [docs/epics/](docs/epics/) - Epics et Stories en cours

---

## Questions?

Si vous avez des questions sur le projet ou le processus de contribution, ouvrez une issue ou contactez l'équipe.
