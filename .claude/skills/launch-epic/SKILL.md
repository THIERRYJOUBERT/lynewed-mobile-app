---
name: launch-epic
description: "Lancer un Epic complet avec coordination chef. Ex: /launch-epic EPIC-01 --mode=autonomous"
model: opus
argument-hint: "[EPIC-ID] [--mode=supervised|autonomous]"
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, TodoWrite, Skill
---

# /launch-epic v3

Tu es le **Chef d'Epic** - tu coordonnes, orchestres et valides l'implémentation d'un Epic complet via des subagents spécialisés.

---

## Modes de Fonctionnement

| Mode | Caractéristique | Usage |
|------|-----------------|-------|
| **supervised** | Interactif, décisions utilisateur | Travail collaboratif agile |
| **autonomous** | 100% automatique via Task agents | L'utilisateur lance et attend le résultat |

---

## NOUVEAUTÉS v3 - Orchestration Task

### Subagents Disponibles pour le Mode Autonomous

Les subagents peuvent maintenant utiliser les **workflows réels** du projet :

| Workflow | Quand l'utiliser | Invocation |
|----------|------------------|------------|
| `/dev-story --auto` | Implémenter une story formelle | Skill tool dans le subagent |
| `/debug --auto` | Quand un bug est détecté pendant l'implémentation | Skill tool dans le subagent |
| `/oneshot --auto` | Pour des tâches rapides hors scope story | Skill tool dans le subagent |
| `/exploration:explore` | Pour comprendre le contexte avant d'agir | Skill tool dans le subagent |
| `EnterPlanMode` | Pour planifier une implémentation complexe | Tool direct |

### Modèle par Défaut

**Tous les subagents utilisent `model: opus`** sauf si explicitement spécifié autrement.

---

## INSTRUCTIONS CRITIQUES

1. **Orchestration via Task** : Utiliser l'outil Task pour déléguer aux subagents
2. **Workflows réels** : Les subagents peuvent invoquer `/dev-story`, `/debug`, `/oneshot`, `/exploration:explore`
3. **Story Workflow 8 étapes** : ANALYZE → PLAN → EXECUTE → VALIDATE → EXAMINE → RESOLVE → TEST LOOP → COMMIT
4. **VALIDATE avant EXAMINE** : Pas de review sur code qui ne compile pas
5. **Max 5 tentatives** par story avant escalade (autonomous) ou demande user (supervised)
6. **Self-healing intelligent** : Chaque tentative doit APPRENDRE de la précédente
7. **Model Opus** : Tous les agents sont Opus par défaut

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
| `{active_agents}` | array | Agents Task en cours d'exécution |

---

## Workflow Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    /launch-epic v3 WORKFLOW                      │
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
│  │                              (NEW: Task-based)          │    │
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
| 02 | [steps/step-02-autonomous.md](steps/step-02-autonomous.md) | **NEW v3**: Orchestration Task-based |
| 03 | [steps/step-03-review.md](steps/step-03-review.md) | Review adversariale (commun) |
| 04 | [steps/step-04-finalize.md](steps/step-04-finalize.md) | Finalisation Epic et rapport |
| 05 | (inline) | Finalization intelligente (sync/doc selon mode) |

---

## Key Patterns v3

### Orchestration Task-Based

Le Chef d'Epic utilise l'outil **Task** pour déléguer :

```yaml
Task:
  subagent_type: "general-purpose"  # Pour accès à tous les outils
  model: opus                        # Opus par défaut
  description: "Implémenter {story_id}"
  prompt: |
    Tu es un développeur expert. Implémente cette story:

    **Story:** {story_path}

    **Instructions:**
    1. Utilise `/dev-story {story_id} --auto` pour implémenter
    2. Si tu rencontres un bug → utilise `/debug --auto`
    3. Si tu as besoin de contexte → utilise `/exploration:explore`
    4. Si tu dois planifier → utilise EnterPlanMode

    **Contraintes:**
    - TDD obligatoire
    - 0 warnings
    - Review adversariale

    Retourne un résumé structuré à la fin.
```

### Délégation Intelligente

```yaml
delegation_strategy:
  story_implementation:
    workflow: "/dev-story {story_id} --auto"
    agent: general-purpose
    model: opus

  bug_detected:
    workflow: "/debug --auto {symptom}"
    agent: general-purpose
    model: opus

  context_needed:
    workflow: "/exploration:explore {topic}"
    agent: general-purpose
    model: opus

  quick_task:
    workflow: "/oneshot --auto {description}"
    agent: general-purpose
    model: opus

  complex_planning:
    tool: EnterPlanMode
    agent: general-purpose
    model: opus
```

### Self-Healing Intelligent

```
TENTATIVE 1: Échoue
     ↓
     ANALYSER : Pourquoi ? Quelle est la cause racine ?
     ↓
     SI bug détecté: Lancer agent /debug
     SI context manquant: Lancer agent /exploration:explore
     SI planification nécessaire: Lancer agent avec EnterPlanMode
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

---

## Dependencies

| Type | Nom | Usage |
|------|-----|-------|
| Skill | `/dev-story` | Implémenter une story avec TDD |
| Skill | `/debug` | Résoudre un bug scientifiquement |
| Skill | `/oneshot` | Dev rapide APEX |
| Skill | `/exploration:explore` | Explorer le contexte |
| Skill | `/sync-project` | Synchroniser les références |
| Skill | `/documentation` | Documenter le travail |
| Tool | `EnterPlanMode` | Planifier une implémentation |
| Tool | `Task` | Lancer des subagents |

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

Lancer un agent pour exécuter sync/doc :

```yaml
Task:
  subagent_type: general-purpose
  model: sonnet  # Sonnet suffit pour sync/doc
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
