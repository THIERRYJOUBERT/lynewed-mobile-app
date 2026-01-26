# Contexte Claude

> **ROLE** : Contexte pour les nouvelles conversations Claude
> Ce dossier contient la source de verite pour l'architecture des workflows.

## Contenu

| Fichier | Role |
|---------|------|
| `SYSTEM.md` | **Source de verite unique** : Workflows, architecture, patterns (v3.0.0) |
| `WORKFLOWS.md` | **Reference rapide** : Toutes les commandes avec exemples |
| `Glossaire Officiel Claude Code.md` | Terminologie officielle Claude Code |
| `Claude Documentation Official/` | Documentation officielle Anthropic |

## Difference avec docs/specs/

```
docs/specs/      = QUOI construire (FDs, PRD-MASTER)
.claude/context/ = COMMENT travailler (workflows, architecture)
```

## Quand lire

- **Nouvelle conversation** : Lire `SYSTEM.md` pour comprendre l'architecture des workflows
- **Creer un workflow** : Consulter `SYSTEM.md` + `/create-workflow`
- **Terminologie** : Consulter le Glossaire pour les definitions officielles

## Hierarchie de Confiance

```
1. PRD-MASTER Section 10       ← Philosophie dev (source ultime)
2. .claude/context/SYSTEM.md   ← Ce dossier (architecture workflows)
3. .claude/rules/              ← Regles techniques
4. .claude/skills/             ← Implementation des workflows
5. .claude/agents/             ← Subagents specialises
```

## Workflows Disponibles

### Developpement

| Workflow | Usage |
|----------|-------|
| `/dev-story` | Implementer une story (TDD, Review, 9 etapes) |
| `/oneshot` | Dev rapide APEX sans Epic/Story (< 1 jour) |
| `/debug` | Debugging scientifique Constrained ReAct |
| `/commit` | Commit avec verifications {{PROJECT_NAME}} |

### Creation

| Workflow | Usage |
|----------|-------|
| `/mission` | Brief client → Mission + Epics + Stories (cascade adaptative) |
| `/create-epic` | Creer Epic depuis PRD-MASTER |
| `/create-story` | Decomposer Epic en Stories INVEST |
| `/create-workflow` | Creer/mettre a jour workflows (14 patterns) |

### Orchestration

| Workflow | Usage |
|----------|-------|
| `/launch-epic` | Lancer Epic complet (supervised/autonomous) |

### Apprentissage

| Workflow | Usage |
|----------|-------|
| `/learn` | Comprendre feature/concept → Doc LLM-optimized |
| `/explore` | Exploration rapide codebase/docs/web |

### Utilitaires

| Workflow | Usage |
|----------|-------|
| `/sync-project` | Synchroniser INDEX, README, CLAUDE.md |
| `/documentation` | Generer documentation de session |
| `/prompt` | Transformer prompt en anglais optimise |

## Principes Cles

1. **VALIDATE avant EXAMINE** : Lint/build AVANT review adversariale
2. **Self-healing intelligent** : Max 5 tentatives, chacune apprend
3. **Review Adversariale** : Changer de role pour critiquer son code
4. **Finalization Intelligente** : Sync/doc optionnel selon mode (supervised = ask, auto = agent sonnet)
