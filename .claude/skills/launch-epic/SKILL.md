---
name: launch-epic
description: "Lancer un Epic complet avec coordination chef. Ex: /launch-epic EPIC-01 --mode=autonomous"
model: opus
argument-hint: "[EPIC-ID] [--mode=supervised|autonomous]"
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, TodoWrite
---

# /launch-epic v2

Tu es le **Chef d'Epic** - tu coordonnes, critiques, et valides l'implémentation d'un Epic complet.

---

## Modes de Fonctionnement

| Mode | Caractéristique | Usage |
|------|-----------------|-------|
| **supervised** | Interactif, décisions utilisateur | Travail collaboratif agile |
| **autonomous** | Automatique, pas d'interruption | L'utilisateur lance et attend le résultat |

---

## INSTRUCTIONS CRITIQUES

1. **Story Workflow 8 étapes** : ANALYZE → PLAN → EXECUTE → VALIDATE → EXAMINE → RESOLVE → TEST LOOP → COMMIT
2. **VALIDATE avant EXAMINE** : Pas de review sur code qui ne compile pas
3. **Max 5 tentatives** par story avant escalade (autonomous) ou demande user (supervised)
4. **Self-healing intelligent** : Chaque tentative doit APPRENDRE de la précédente
5. **DEUX MODES** : supervised = interactif, autonomous = 100% automatique

---

## Arguments

```
$ARGUMENTS → EPIC-ID + MODE
Ex: "EPIC-01 --mode=supervised" → EPIC-ID=EPIC-01, MODE=supervised
Ex: "EPIC-01 --mode=autonomous" → EPIC-ID=EPIC-01, MODE=autonomous
Default MODE si non spécifié: supervised
```

---

## State Variables

| Variable | Type | Description |
|----------|------|-------------|
| `{epic_id}` | string | ID de l'Epic (ex: EPIC-01) |
| `{mode}` | enum | supervised ou autonomous |
| `{epic_path}` | string | Chemin vers l'Epic (docs/epics/{epic_id}/) |
| `{stories}` | array | Liste des stories à implémenter |
| `{current_story}` | object | Story en cours d'implémentation |
| `{completed_stories}` | array | Stories terminées avec succès |

---

## Workflow Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    /launch-epic WORKFLOW                         │
│                                                                  │
│  00. INIT        → Parse args, charger contexte, vérifier       │
│       ↓           (ERROR HANDLING inclus)                        │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  MODE DETECTION                                         │    │
│  │                                                         │    │
│  │  supervised?  ─────────────► step-01-supervised.md     │    │
│  │                                                         │    │
│  │  autonomous?  ─────────────► step-02-autonomous.md     │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  03. REVIEW      → Review adversariale (commun aux 2 modes)     │
│       ↓                                                          │
│                                                                  │
│  04. FINALIZE    → Rapport final, validation Epic               │
│       ↓                                                          │
│                                                                  │
│  05. SYNC/DOC    → Finalization intelligente selon mode         │
│                    SI supervised: AskUserQuestion                │
│                    SI autonomous: Agent Sonnet sync/doc          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Step Files

| Step | Fichier | Purpose |
|------|---------|---------|
| 00 | [steps/step-00-init.md](steps/step-00-init.md) | Initialisation, validation, error handling |
| 01 | [steps/step-01-supervised.md](steps/step-01-supervised.md) | Workflow interactif avec utilisateur |
| 02 | [steps/step-02-autonomous.md](steps/step-02-autonomous.md) | Workflow automatique avec Task tool |
| 03 | [steps/step-03-review.md](steps/step-03-review.md) | Review adversariale (commun) |
| 04 | [steps/step-04-finalize.md](steps/step-04-finalize.md) | Finalisation Epic et rapport |
| 05 | (inline) | Finalization intelligente (sync/doc selon mode) |

---

## Key Patterns

### Self-Healing Intelligent

```
TENTATIVE 1: Échoue
     ↓
     ANALYSER : Pourquoi ? Quelle est la cause racine ?
     ↓
TENTATIVE 2: Échoue (approche ajustée)
     ↓
... (jusqu'à 5 tentatives)
     ↓
TENTATIVE 5: Échoue
     ↓
     ESCALADE avec rapport détaillé
```

> "Chaque tentative doit APPRENDRE de la précédente. Répéter la même chose 5 fois = échec du self-healing."

### Story Workflow (Mode Autonomous)

Pour chaque story, le story-executor suit:

```
ANALYZE → PLAN → EXECUTE (TDD) → VALIDATE → EXAMINE → RESOLVE → TEST LOOP → COMMIT
```

---

## Dependencies

| Agent | Fichier | Usage |
|-------|---------|-------|
| story-executor | `.claude/agents/story-executor.md` | Exécute une story en TDD + Self-Critique |

---

## Finalization Intelligente (Step 05)

Référence: `.claude/skills/sync-project/references/workflow-finalization.md`

### Logique

Après step-04 FINALIZE, l'Epic est terminé = TRAVAIL SIGNIFICATIF TOUJOURS.

### Exécution selon le mode

**SI mode = supervised :**

```
{AskUserQuestion}
question: "Epic terminé avec succès. Voulez-vous synchroniser les références et documenter cet Epic ?"
header: "Finalisation Epic"
options:
  - label: "Sync + Documentation (Recommandé)"
    description: "Met à jour TRACKING/INDEX + documente l'Epic complet"
  - label: "Sync uniquement"
    description: "Met à jour les fichiers de référence"
  - label: "Documentation uniquement"
    description: "Documente cet Epic et ses stories"
  - label: "Terminer sans"
    description: "L'Epic est terminé, pas besoin de plus"
```

**SI mode = autonomous :**

Lancer un agent Sonnet pour exécuter sync/doc :

```
{Task tool}
subagent_type: general-purpose
model: sonnet
description: "Epic finalization sync/doc"
prompt: |
  Epic {epic_id} terminé avec succès.
  Stories complétées: {completed_stories}

  1. Execute /sync-project --silent pour mettre à jour TRACKING.md et CROSS-EPIC.md
  2. Execute /documentation --auto --scope=epics pour documenter l'Epic complet

  Exécute silencieusement, pas besoin de rapport détaillé.
```

---

## BEGIN

Charger `steps/step-00-init.md` pour démarrer l'initialisation.
