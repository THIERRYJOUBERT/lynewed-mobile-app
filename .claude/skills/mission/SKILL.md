---
name: mission
description: "Transformer brief/devis client en Mission + Epics + Stories via exploration cascade adaptative de la codebase."
model: opus
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Task
  - AskUserQuestion
  - TodoWrite
argument-hint: "<brief_path> - chemin vers fichier brief/devis client"
---

# /mission - Brief to Epics Pipeline

<objective>
Transformer un brief ou devis client en documentation executable : MISSION.md (scope consolide) + Epics structures + Stories INVEST. Utilise une architecture cascade adaptative (Haiku scan → Sonnet analyze → Opus synthesize) pour explorer la codebase existante et comprendre comment integrer les nouvelles fonctionnalites.
</objective>

<critical_rule>
🛑 NEVER generer Epics/Stories sans checkpoint utilisateur
🛑 NEVER inventer des requirements non presents dans le brief
🛑 NEVER lancer agents sequentiellement (toujours PARALLELE par tier)
🛑 NEVER creer des Stories sans criteres Gherkin
✅ ALWAYS adapter le nombre d'agents a la taille de la codebase
✅ ALWAYS documenter les gaps dans le brief
✅ ALWAYS verifier conflits avec Epics existants
✅ ALWAYS suivre criteres INVEST pour les Stories
</critical_rule>

<when_to_use>
**Use this skill when:**
- Tu recois un brief/devis client avec plusieurs fonctionnalites
- Tu dois planifier l'integration de features dans un projet existant
- Tu veux decomposer une mission complexe en Epics executables
- Tu travailles sur un projet que tu n'as pas cree

**Don't use for:**
- Projet neuf sans codebase → use PRD-MASTER + /create-epic
- Feature simple (< 1 jour) → use /oneshot
- Epic deja cree → use /create-story
- Bug fixing → use /debug
</when_to_use>

## Arguments

```
$ARGUMENTS format: <brief_path>

Examples:
  /mission docs/brief-client.md
  /mission workspace/current/devis-2026-01.md
  /mission ~/Desktop/mission-client.pdf

Supported formats:
  .md    → Markdown (recommended)
  .txt   → Plain text
  .pdf   → PDF (extracted as text)
```

## State Variables

| Variable | Type | Description |
|----------|------|-------------|
| `{brief_path}` | string | Chemin vers le fichier brief |
| `{brief_content}` | string | Contenu du brief extrait |
| `{project_context}` | object | has_existing_code, codebase_size, existing_epics |
| `{agent_counts}` | object | haiku_count (3-10), sonnet_count (3-5) |
| `{scan_results}` | object | Resultats tier 1 Haiku |
| `{analysis_results}` | object | Resultats tier 2 Sonnet |
| `{mission_document}` | object | Mission structuree (scope, epics, deps) |
| `{user_decision}` | enum | approve, adjust, cancel |
| `{generated_epics}` | array | Paths des Epics crees |
| `{generated_stories}` | array | Paths des Stories creees |

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         WORKFLOW: /mission                                   │
│                   "Brief to Epics Pipeline"                                  │
│                                                                              │
│  00. INIT         → Valider brief, scanner codebase, adapter agent counts   │
│       ↓            ✓ Brief lisible, context projet, counts adaptatifs       │
│                                                                              │
│  01. SCAN         → Tier 1 : 3-10 Haiku agents en PARALLELE                 │
│       │            ├── brief-requirements: Exigences fonctionnelles         │
│       │            ├── brief-technical: Contraintes techniques              │
│       │            ├── brief-priorities: Timeline/budget/priorites          │
│       │            └── codebase-* (adaptatif): Structure, patterns, deps    │
│       ↓            ✓ Requirements extraits, codebase mappee                 │
│                                                                              │
│  02. ANALYZE      → Tier 2 : 3-5 Sonnet agents en PARALLELE                 │
│       │            ├── scope-analyzer: Grouper par features                 │
│       │            ├── arch-analyzer: Dependencies techniques               │
│       │            ├── risk-analyzer: Risques et complexite                 │
│       │            └── integration-* (adaptatif): Points d'integration      │
│       ↓            ✓ Features groupees, risques identifies                  │
│                                                                              │
│  03. SYNTHESIZE   → Tier 3 : Opus synthetise en MISSION.md                  │
│       ↓            ✓ Scope, Epics proposes, ordre, dependencies             │
│                                                                              │
│  04. CHECKPOINT   → [AskUserQuestion] Validation avant generation           │
│       │            ├── Approuver → Continue                                 │
│       │            ├── Ajuster → Retour step-03                             │
│       │            └── Annuler → Stop                                       │
│       ↓            ✓ User a valide                                          │
│                                                                              │
│  05. MISSION      → Ecrire docs/specs/MISSION-{name}.md                     │
│       ↓            ✓ Fichier cree                                           │
│                                                                              │
│  06. EPICS        → Generer dossiers Epic + TRACKING.md                     │
│       ↓            ✓ N Epics crees, CROSS-EPIC.md updated                   │
│                                                                              │
│  07. STORIES      → Generer Stories INVEST pour chaque Epic                 │
│       ↓            ✓ M Stories/Epic, Gherkin criteria                       │
│                                                                              │
│  08. FINALIZE     → Rapport final + proposition sync/doc                    │
│                    ✓ Resume, next steps                                     │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Step Files

| Step | File | Purpose | Gate |
|------|------|---------|------|
| 00 | step-00-init.md | Valider brief, scanner projet, adapter counts | Brief lisible |
| 01 | step-01-scan.md | Tier 1 Haiku agents paralleles | Scan complete |
| 02 | step-02-analyze.md | Tier 2 Sonnet agents paralleles | Analyse complete |
| 03 | step-03-synthesize.md | Opus synthetise MISSION | Mission structuree |
| 04 | step-04-checkpoint.md | Validation utilisateur | User approve |
| 05 | step-05-generate-mission.md | Ecrire MISSION.md | Fichier cree |
| 06 | step-06-generate-epics.md | Creer dossiers Epic | Epics crees |
| 07 | step-07-generate-stories.md | Creer Stories INVEST | Stories creees |
| 08 | step-08-finalize.md | Rapport final | Termine |

## Cascade Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CASCADE ADAPTATIVE 3 TIERS                                │
│                                                                              │
│  TIER 1: SCAN (Haiku - rapide, cheap)                                       │
│  ──────────────────────────────────────                                     │
│  Nombre d'agents: 3-10 (adaptatif selon taille codebase)                    │
│  • < 50 fichiers    → 3 agents (brief only)                                 │
│  • 50-150 fichiers  → 5 agents (+ codebase structure)                       │
│  • 150-500 fichiers → 7 agents (+ patterns, deps)                           │
│  • > 500 fichiers   → 10 agents (full exploration)                          │
│                                                                              │
│  TIER 2: ANALYZE (Sonnet - profond)                                         │
│  ──────────────────────────────────────                                     │
│  Nombre d'agents: 3-5 (adaptatif selon complexite brief)                    │
│  • Brief simple     → 3 agents                                              │
│  • Brief complexe   → 5 agents                                              │
│                                                                              │
│  TIER 3: SYNTHESIZE (Opus - decision)                                       │
│  ──────────────────────────────────────                                     │
│  Agent principal synthetise toutes les analyses                             │
│  → Produit MISSION.md structure avec Epics proposes                         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Output Structure

```
docs/
├── specs/
│   └── MISSION-{name}.md          # Document de mission consolide
│
└── epics/
    ├── CROSS-EPIC.md              # Updated avec nouvelles deps
    │
    ├── EPIC-XX-FEATURE-A/
    │   ├── EPIC-XX-FEATURE-A.md   # Description Epic
    │   ├── TRACKING.md            # Progress tracking
    │   └── stories/
    │       ├── STORY-XX-01.md     # Stories INVEST
    │       └── STORY-XX-02.md
    │
    └── EPIC-YY-FEATURE-B/
        └── ...
```

## Execution Rules

1. **Cascade Sequentielle**: SCAN → ANALYZE → SYNTHESIZE (tiers dans cet ordre)
2. **Agents Paralleles**: Dans chaque tier, lancer TOUS agents en SINGLE message
3. **Model Strategy**: Haiku (scan cheap), Sonnet (analyse profonde), Opus (synthese)
4. **Adaptive Counts**: Ajuster nombre d'agents selon taille codebase
5. **Checkpoint Obligatoire**: TOUJOURS valider avant generation
6. **INVEST Stories**: Toutes stories suivent criteres INVEST
7. **Gherkin Required**: Acceptance criteria en format Gherkin
8. **Gap Documentation**: Documenter manques du brief, ne pas bloquer

## Success Criteria

✅ Brief transforme en Mission structuree
✅ Epics logiquement organises avec dependencies
✅ Stories INVEST avec criteres Gherkin
✅ Conflits Epics existants resolus
✅ User a valide au checkpoint
✅ CROSS-EPIC.md updated

## Failure Modes

❌ Brief introuvable → AskUserQuestion pour path correct
❌ Brief trop vague → Documenter gaps, demander clarification
❌ Codebase trop grosse → Limiter scope, documenter zones non explorees
❌ Conflits IDs Epic → Incrementer automatiquement, documenter
❌ Stories trop grosses → Decomposer, jamais > 8 points
❌ User annule → Sauvegarder draft MISSION pour reprise

## Cost Warning

⚠️ Ce workflow peut etre couteux selon la taille de la codebase:
- Petite codebase (< 50 fichiers): ~10x base cost
- Grande codebase (> 500 fichiers): ~40x base cost

Le nombre d'agents s'adapte automatiquement. Pour forcer moins d'agents,
reduire le scope du brief.

<begin>
Load `steps/step-00-init.md` to start the brief-to-epics pipeline.
</begin>
