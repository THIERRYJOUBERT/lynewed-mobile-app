# lynewed_beta

A flutter project

## Contexte de Travail

Ce projet utilise une **methodologie structuree** avec des workflows, des agents, et une documentation rigoureuse.

**Mode de travail** via workflows definis dans `.claude/skills/`. Mode **supervised** (interactif) ou **autonomous** (agent autonome).

---

## Regles Principales

### Qualite Production

- Code maintenable, bien architecture
- 0 warnings (`flutter analyze --fatal-infos`)
- Tests pour chaque feature
- Pas de dette technique

### Documentation

- Documenter les decisions importantes
- Mettre a jour TRACKING.md apres chaque story

### Code

- **Commentaires en anglais** (code et commentaires)
- **Nommage clair** et conventions Dart

---

## Tech Stack

- **Langage** : Dart
- **Type** : flutter

## Commandes

```bash
flutter test                       # Tests
flutter analyze --fatal-infos                       # Linting
flutter build                      # Build
flutter run                        # Run
```

---

## Structure Projet

### Documentation (`docs/`)

| Dossier | Role |
|---------|------|
| `docs/specs/` | **Vision produit** - PRD, specs |
| `docs/detailed/` | **Details techniques** |
| `docs/epics/` | **Developpement** - Stories, tracking |

### Configuration Claude (`.claude/`)

| Dossier | Role |
|---------|------|
| `.claude/skills/` | **Workflows** - `/dev-story`, `/debug`, etc. |
| `.claude/rules/` | **Regles** - Qualite, TDD |
| `.claude/context/` | **Architecture** - SYSTEM.md |
| `.claude/agents/` | **Agents** - PM, SM, explorers |

---

## Workflows Disponibles

### Developper

| Workflow | Usage |
|----------|-------|
| `/dev-story` | Implementer une story (TDD, Review Adversariale) |
| `/oneshot` | Dev rapide sans Epic/Story |
| `/debug` | Investigation scientifique de bugs |
| `/commit` | Commit avec verifications |

### Creer

| Workflow | Usage |
|----------|-------|
| `/create-epic` | Creer un Epic depuis PRD |
| `/create-story` | Decomposer Epic en Stories |
| `/create-workflow` | Creer un nouveau workflow |

### Maintenance

| Workflow | Usage |
|----------|-------|
| `/project-cleanup` | Nettoyer, optimiser, moderniser le projet (Ralph) |

### Utilitaires

| Workflow | Usage |
|----------|-------|
| `/learn` | Comprendre une feature/concept |
| `/documentation` | Documenter session de travail |
| `/sync-project` | Synchroniser references |

---

## Index Rapide

| Besoin | Ou chercher |
|--------|-------------|
| Vision produit | `docs/specs/PRD-MASTER.md` |
| Architecture workflows | `.claude/context/SYSTEM.md` |
| Regles techniques | `.claude/rules/` |
| Stories en cours | `docs/epics/` |
