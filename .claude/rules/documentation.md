# Regles Documentation

## Structure du Projet

```
docs/
├── specs/                         # Source de verite - VISION
│   ├── FD-01 a FD-10              # Documents de Fondation
│   ├── PRD-MASTER.md              # Synthese (apres FDs)
│   └── INDEX.md                   # Navigation
│
├── detailed/                      # Details techniques
│   └── [sous-dossiers]/           # Crees selon besoins (ui-ux/, exercises/, etc.)
│
└── epics/                         # Developpement
    ├── CROSS-EPIC.md              # Coordination inter-Epics
    └── EPIC-XX-NOM/
        ├── EPIC-XX-NOM.md
        ├── TRACKING.md
        └── stories/

.claude/
├── context/                       # Contexte conversations
│   └── SYSTEM.md                  # Source de verite workflows + architecture
│
├── skills/                        # Workflows reutilisables
│   ├── dev-story/                 # Story Workflow 8 etapes
│   ├── debug/                     # Debugging Constrained ReAct
│   ├── commit/                    # Commit avec verifications
│   ├── create-workflow/           # Meta-skill creation workflows
│   ├── create-epic/               # Creation Epics
│   ├── create-story/              # Creation Stories
│   ├── documentation/             # Documentation intelligente (conversation + git)
│   ├── launch-epic/               # Lancement Epic
│   └── sync-project/              # Maintenance projet
│
├── agents/                        # Agents specialises
│   ├── pm.md                      # Product Manager
│   ├── sm.md                      # Scrum Master
│   ├── story-executor.md          # Executeur de story
│   ├── explore-*.md               # Agents d'exploration
│   └── websearch.md               # Recherche web
│
├── commands/                      # Commandes legacy
│   ├── dev/prompt.md              # Transformation prompts
│   ├── exploration/explore.md     # Exploration deep
│   └── git/                       # Operations git
│
└── rules/                         # Regles projet
    ├── core-rules.md              # TDD, qualite, workflow 8 etapes
    ├── documentation.md           # Ce fichier
    ├── prd.md                     # Structure FDs et PRD
    ├── project-preferences.md     # Preferences utilisateur
    └── tdd-cycle.md               # Cycle Red-Green-Refactor
```

## Hierarchie de Confiance

| Niveau | Source | Usage |
|--------|--------|-------|
| 1 | PRD-MASTER Section 10 | **Philosophie dev (source ultime)** |
| 2 | `.claude/context/SYSTEM.md` | **Architecture workflows** |
| 3 | `docs/specs/*.md` | Source de verite VISION |
| 4 | `.claude/rules/` | Regles techniques |
| 5 | `.claude/skills/` | Implementation workflows |
| 6 | `docs/detailed/` | Details techniques |
| 7 | `docs/epics/` | Documentation dev |

## Role des Dossiers

```
docs/specs/     = VISION + POURQUOI (haut niveau)
docs/detailed/  = COMMENT + DETAILS (conception)
docs/epics/     = IMPLEMENTATION (developpement)
```

## Regles Phase 1 (Documents de Fondation)

1. **ALWAYS** lire la doc legacy avant de rediger un FD si existante
2. **NEVER** valider un FD sans AskUserQuestion section par section
3. **ALWAYS** mettre a jour CLAUDE.md tracking quand FD valide
4. **NEVER** inventer des specs - demander si info manquante
5. **ALWAYS** documenter concisement et clairement

## Regles Phase 2 (Developpement)

1. **ALWAYS** verifier PRD-MASTER avant d'implementer
2. **ALWAYS** avoir une story validee avant de coder
3. **ALWAYS** mettre a jour TRACKING.md de l'epic
4. **NEVER** coder sans story dans docs/epics/
5. **ALWAYS** TDD : test first, puis code
6. **ALWAYS** documenter decisions dans stories
7. **ALWAYS** checker CROSS-EPIC.md pour dependances
8. **ALWAYS** suivre le workflow 8 etapes (voir SYSTEM.md)

## Skills Disponibles

### Workflows Principaux

| Skill | Action |
|-------|--------|
| `/dev-story` | Story workflow 8 etapes (TDD + Review Adversariale) |
| `/debug` | Debugging scientifique Constrained ReAct |
| `/commit` | Commit avec verifications (bloque si tests fail) |

### Creation

| Skill | Action |
|-------|--------|
| `/create-epic` | Creer Epic + Epic Assistant |
| `/create-story` | Creer Stories INVEST depuis Epic |
| `/create-workflow` | Meta-skill creation workflows |

### Operations

| Skill | Action |
|-------|--------|
| `/documentation` | Documenter session de travail (conversation + git → docs denses) |
| `/launch-epic` | Lancer Epic (autonomous/supervised) |
| `/sync-project` | Synchroniser INDEX, README, CLAUDE.md (auto par workflows) |
| `/oneshot` | Dev rapide APEX sans Epic/Story |
