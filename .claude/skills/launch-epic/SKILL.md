---
name: launch-epic
description: "Lancer un Epic complet avec coordination chef. Ex: /launch-epic EPIC-01 --mode=autonomous --deep"
model: opus
argument-hint: "[EPIC-ID] [--mode=supervised|autonomous] [--deep]"
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, TodoWrite, Skill, EnterPlanMode, ExitPlanMode
---

# /launch-epic v4

Tu es le **Chef d'Epic** - tu coordonnes, orchestres et valides l'implémentation d'un Epic complet via des subagents spécialisés.

---

## Modes de Fonctionnement

| Mode | Caractéristique | Usage |
|------|-----------------|-------|
| **supervised** | Interactif, décisions utilisateur | Travail collaboratif agile |
| **autonomous** | 100% automatique via Task agents | L'utilisateur lance et attend le résultat |
| **autonomous --deep** | **NOUVEAU** Chef Opus critique + verification approfondie | Qualite PARFAITE garantie |

### Mode DEEP (--deep)

Le mode `--deep` transforme le Chef en **garant de la qualite absolue** :

- **Plan Mode obligatoire** avant chaque story
- **Verification approfondie** apres chaque sub-agent
- **Iteration jusqu'a perfection** - relance si qualite insuffisante
- **Design System verifie** explicitement
- **Coordination inter-agents** via fichier partage
- **Zero tolerance** pour les manquements

---

## NOUVEAUTÉS v4 - Mode DEEP + Orchestration Task

### Mode DEEP: Chef Opus Garant de Qualite

Le mode `--deep` active un comportement de supervision rigoureuse :

```
autonomous         → Delegation simple, verification post-completion
autonomous --deep  → Chef critique, Plan Mode, verification approfondie
```

**Caracteristiques DEEP:**

| Aspect | Standard | DEEP |
|--------|----------|------|
| Supervision | Delegation simple | Chef Opus critique |
| Sub-agents | `/dev-story --auto` | `/dev-story --deep` |
| Verification | Post-completion | Avant ET apres chaque story |
| Plan Mode | Occasionnel | Systematique avant chaque story |
| Design System | Mentionne | VERIFIE explicitement |
| Tolerance erreurs | 5 tentatives | 3 tentatives puis escalade |
| Coordination | Independante | Fichier COORDINATION.md partage |

### Subagents Disponibles pour le Mode Autonomous

Les subagents peuvent maintenant utiliser les **workflows réels** du projet :

| Workflow | Mode Standard | Mode DEEP |
|----------|--------------|-----------|
| `/dev-story` | `--auto` | `--deep` (iteration jusqu'a perfection) |
| `/debug` | `--auto` | `--auto` (meme comportement) |
| `/oneshot` | `--auto` | `--auto` (meme comportement) |
| `/exploration:explore` | Standard | Standard |
| `EnterPlanMode` | Occasionnel | **OBLIGATOIRE** avant chaque story |

### Modèle par Défaut

**Tous les subagents utilisent `model: opus`** - JAMAIS Sonnet pour l'implementation.

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
$ARGUMENTS → EPIC-ID + MODE + [DEEP]
Ex: "EPIC-01 --mode=supervised" → EPIC-ID=EPIC-01, MODE=supervised, DEEP=false
Ex: "EPIC-01 --mode=autonomous" → EPIC-ID=EPIC-01, MODE=autonomous, DEEP=false
Ex: "EPIC-01 --mode=autonomous --deep" → EPIC-ID=EPIC-01, MODE=autonomous, DEEP=true
Ex: "EPIC-01 --auto --deep" → EPIC-ID=EPIC-01, MODE=autonomous, DEEP=true
Default MODE si non spécifié: supervised
Default DEEP si non spécifié: false
```

### Alias

| Alias | Equivalent |
|-------|------------|
| `--auto` | `--mode=autonomous` |
| `--auto --deep` | `--mode=autonomous --deep` |

---

## State Variables

| Variable | Type | Description |
|----------|------|-------------|
| `{epic_id}` | string | ID de l'Epic (ex: EPIC-01) |
| `{mode}` | enum | supervised, autonomous, ou autonomous-deep |
| `{deep}` | boolean | Mode DEEP active (verification approfondie) |
| `{epic_path}` | string | Chemin vers l'Epic (docs/epics/{epic_id}/) |
| `{stories}` | array | Liste des stories à implémenter |
| `{current_story}` | object | Story en cours d'implémentation |
| `{completed_stories}` | array | Stories terminées avec succès |
| `{active_agents}` | array | Agents Task en cours d'exécution |
| `{coordination_file}` | string | (DEEP) Chemin vers COORDINATION.md |
| `{quality_report}` | object | (DEEP) Rapport qualite global |

---

## Workflow Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    /launch-epic v4 WORKFLOW                      │
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
│  │                              (Task-based standard)      │    │
│  │                                                         │    │
│  │  autonomous --deep? ───────► step-02-autonomous-deep.md│    │
│  │                              (NEW v4: Chef Opus critique)    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  03. REVIEW      → Review adversariale (commun aux 3 modes)     │
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
| 02 | [steps/step-02-autonomous.md](steps/step-02-autonomous.md) | Orchestration Task-based standard |
| 02-deep | [steps/step-02-autonomous-deep.md](steps/step-02-autonomous-deep.md) | **NEW v4**: Chef Opus critique + verification approfondie |
| 03 | [steps/step-03-review.md](steps/step-03-review.md) | Review adversariale (commun) |
| 04 | [steps/step-04-finalize.md](steps/step-04-finalize.md) | Finalisation Epic et rapport |
| 05 | (inline) | Finalization intelligente (sync/doc selon mode) |

---

## Key Patterns v4

### Mode DEEP - Chef Opus Critique

En mode `--deep`, le Chef Opus suit ce cycle pour chaque story :

```
┌────────────────────────────────────────────────────────────────────────────┐
│                    CYCLE STORY DEEP (Chef Opus)                             │
│                                                                             │
│  A. PLAN MODE ──► EnterPlanMode AVANT delegation                            │
│       │          Analyser story, preparer instructions enrichies            │
│       ↓                                                                     │
│  B. DELEGATE ──► Task sub-agent avec /dev-story --deep                      │
│       │          Instructions precises du Chef                              │
│       ↓                                                                     │
│  C. VERIFY ────► Verification OBJECTIVE du Chef                             │
│       │          - Tous AC satisfaits ?                                     │
│       │          - Design System respecte ?                                 │
│       │          - Tests passants ?                                         │
│       ↓                                                                     │
│  D. DECIDE ────► PARFAIT → Next story                                       │
│                  INSUFFISANT → Relancer avec corrections                    │
│                  (Max 3 iterations puis escalade)                           │
└────────────────────────────────────────────────────────────────────────────┘
```

### Orchestration Task-Based (Standard)

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
