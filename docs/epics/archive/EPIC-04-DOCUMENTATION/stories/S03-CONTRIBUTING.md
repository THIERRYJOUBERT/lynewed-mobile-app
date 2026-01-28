# Story S03: CONTRIBUTING.md

**Epic:** EPIC-04-DOCUMENTATION
**ID:** S03
**Points:** 3
**Priorite:** P2 - Important
**Statut:** A faire
**Dependances:** S01 (README)

---

## Description

En tant que **contributeur** au projet Lynewed,
je veux un **guide de contribution clair**
afin de **comprendre les conventions, le workflow de developpement et les standards de qualite attendus**.

---

## Criteres d'Acceptance

- [ ] Workflow Git documente (branches, commits, PRs)
- [ ] Conventions de code Dart/Flutter
- [ ] Standards de nommage (fichiers, classes, variables)
- [ ] Guide pour creer un nouveau module Clean Architecture
- [ ] Checklist de PR
- [ ] Process de review

---

## Contenu Attendu

### 1. Workflow Git

> **Note**: Ce workflow reflete les pratiques REELLES observees sur le projet.

#### Branches
```
main           → Production stable
develop        → Integration (si utilise)
feature/*      → Nouvelles fonctionnalites
fix/*          → Corrections de bugs
epic-XX/*      → Travail sur un Epic specifique
phase-*        → Phases de migration/refactoring
```

#### Workflow Actuel
```
1. Creer branche depuis main (ou develop si actif)
   git checkout main
   git pull
   git checkout -b feature/ma-feature
   # OU pour un fix: git checkout -b fix/description-courte

2. Developper avec commits structures (voir format ci-dessous)

3. Pousser et creer PR
   git push -u origin feature/ma-feature

4. Review + CI checks (flutter analyze, flutter test)

5. Merge dans main (squash ou merge selon taille)
```

#### Branches Actuelles du Projet
- `main` - Production
- `develop` - Integration
- `fix/project-cleanup` - Maintenance en cours
- `phase-1-enum-cleanup` - Migration historique

### 2. Conventions de Commit

Format: `type(scope): description`

| Type | Usage |
|------|-------|
| `feat` | Nouvelle fonctionnalite |
| `fix` | Correction de bug |
| `refactor` | Refactoring sans changement fonctionnel |
| `docs` | Documentation |
| `style` | Formatage, style |
| `test` | Ajout/modification de tests |
| `chore` | Maintenance, deps |

#### Exemples Reels du Projet
```bash
# Feature avec tracking Epic
feat(epic-01): complete S30-S42 migration - dashboard, wishlist, profile, cleanup

# Documentation Epic
docs(epic-01): complete EPIC-01 migration with final documentation

# Maintenance
chore: update Claude Code config from template + add new workflows

# Fix specifique
fix(ios): restore flutter_dotenv, fix firebase & notifications provider

# Build
chore(build-ios): add cleanup step for duplicate files
```

#### Bonnes Pratiques
- Inclure le numero d'Epic/Story si applicable: `feat(epic-01):`
- Description en anglais, concise mais descriptive
- Corps du commit pour details si necessaire

### 3. Conventions de Code

#### Nommage
| Element | Convention | Exemple |
|---------|------------|---------|
| Fichiers | snake_case | `wedding_guest.dart` |
| Classes | PascalCase | `WeddingGuest` |
| Variables | camelCase | `guestCount` |
| Constantes | camelCase | `maxGuests` |
| Privees | _prefixe | `_internalState` |

#### Structure de Fichier
```dart
// 1. Imports dart:
import 'dart:async';

// 2. Imports package:
import 'package:flutter/material.dart';

// 3. Imports relatifs projet
import '/core/design/design.dart';
import '../domain/entities/wedding_guest.dart';

// 4. Part directives (si applicable)

// 5. Code
```

#### Regles Dart
- Langue du code: **Anglais**
- Langue des commentaires: **Anglais**
- Max 80 caracteres par ligne (soft limit)
- `flutter analyze --fatal-infos` doit passer (0 warnings obligatoire)
- Pas de `print()` en production (utiliser `SecureLogger`)
- **iOS minimum**: 15.0 (ne pas utiliser APIs iOS < 15)
- **Secrets**: Utiliser `dotenv.env['KEY']` (voir ARCHITECTURE.md)

### 4. Creer un Nouveau Module

```bash
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

#### Checklist Nouveau Module
- [ ] Entity creee dans `domain/entities/`
- [ ] Repository interface dans `domain/repositories/`
- [ ] Datasource dans `data/datasources/`
- [ ] Repository impl dans `data/repositories/`
- [ ] Page principale dans `presentation/pages/`
- [ ] Barrel file `[module].dart` a la racine
- [ ] Export dans feature barrel si applicable

### 5. Design System

**OBLIGATOIRE:** Utiliser le Design System pour toute nouvelle UI.

```dart
import '/core/design/design.dart';
import '/core/design/widgets/widgets.dart';

// Couleurs
LynewedColors.primary
LynewedColors.textSecondary

// Typography
LynewedTextStyles.sheetTitle
LynewedTextStyles.bodyMedium

// Widgets
LynewedButton(text: 'Submit', onPressed: () {})
LynewedSheet(title: 'My Sheet', child: ...)
```

**Regles:**
- Maximum `fontWeight: w500` (jamais w600, w700...)
- Spacing: 30px entre sections, 10px label→contenu
- Boutons: hauteur 48px, radius 0

### 6. Checklist PR

Avant de soumettre une PR:

#### Code
- [ ] `flutter analyze --fatal-infos` passe
- [ ] `flutter test` passe
- [ ] Pas de secrets dans le code
- [ ] Pas de `print()` ou logs debug
- [ ] Design System utilise

#### Documentation
- [ ] Code documente si complexe
- [ ] PR description claire

#### Tests
- [ ] Tests unitaires pour logique metier
- [ ] Tests widget si composant reutilisable

### 7. Process de Review

1. **Auteur** cree la PR avec description
2. **Reviewer** verifie:
   - Code fonctionne comme decrit
   - Conventions respectees
   - Pas de regression
   - Tests adequats
3. **Approbation** ou demande de changements
4. **Merge** par l'auteur apres approbation

---

## Notes Techniques

### Sources d'Information
- `.claude/rules/core-rules.md` - Regles TDD et qualite
- `.claude/rules/tdd-cycle.md` - Cycle TDD
- `docs/App/DESIGN_SYSTEM.md` - Reference Design System

### Fichier a Creer
- `/CONTRIBUTING.md` (racine du projet)

### Points d'Attention
- Aligner avec les pratiques actuelles de l'equipe
- Garder concis mais complet
- Inclure des exemples concrets

---

## Definition of Done

- [ ] Document cree avec toutes les sections
- [ ] Exemples de code fonctionnels
- [ ] Conventions alignees avec le codebase existant
- [ ] Review par l'equipe

---

## Estimation

| Tache | Temps estime |
|-------|--------------|
| Sections 1-3 (Git, commits, code) | 1h |
| Section 4 (nouveau module) | 45min |
| Sections 5-7 (Design, PR, review) | 1h |
| Review et ajustements | 15min |
| **Total** | **3h** |
