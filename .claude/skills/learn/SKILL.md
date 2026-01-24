---
name: learn
description: "Pipeline d'acquisition de connaissance : explorer feature/concept, comprendre a 100%, generer documentation LLM-optimized."
model: opus
allowed-tools:
  - Read
  - Glob
  - Grep
  - Task
  - Write
  - TodoWrite
  - AskUserQuestion
argument-hint: "<topic> [--depth=quick|standard|deep]"
---

# /learn - Knowledge Acquisition Pipeline

<objective>
Explorer une feature ou concept du codebase en profondeur, atteindre une comprehension de 100%, puis generer de la documentation dense, sourcee et optimisee pour relecture par Claude.
</objective>

<critical_rule>
🛑 NEVER modifier le code source (read-only)
🛑 NEVER generer de documentation verbose ou fluffy
🛑 NEVER documenter sans sources (file:line obligatoire)
🛑 NEVER lancer agents sequentiellement (toujours PARALLELE)
✅ ALWAYS citer les sources avec file:line
✅ ALWAYS utiliser le pipeline 3 niveaux (Haiku → Sonnet → Opus)
✅ ALWAYS valider completude via review adversariale
✅ ALWAYS produire documentation exploitable par Claude
</critical_rule>

<when_to_use>
**Use this skill when:**
- Tu dois comprendre une feature avant de la modifier
- Tu veux documenter un concept complexe pour future reference
- Tu fais de l'onboarding sur une partie du codebase
- Tu prepares le contexte pour une implementation future

**Don't use for:**
- Implementation de code → use /dev-story ou /oneshot
- Bug investigation → use /debug
- Quick context gathering → use /explore
- Session documentation → use /documentation
</when_to_use>

## Arguments

```
$ARGUMENTS format: <topic> [--depth=quick|standard|deep]

Examples:
  /learn auth-system
  /learn state-management --depth=deep
  /learn "workout tracking" --depth=quick

Depth levels:
  quick    → Scan rapide, documentation minimale (3 agents Haiku only)
  standard → Pipeline complet standard (3 Haiku + 3 Sonnet) [DEFAULT]
  deep     → Exploration exhaustive, multiple iterations
```

## State Variables

| Variable | Type | Description |
|----------|------|-------------|
| `{topic}` | string | Sujet a explorer |
| `{depth}` | enum | quick, standard, deep (default: standard) |
| `{output_path}` | string | workspace/current/{sanitized_topic}/ |
| `{file_list}` | array | Fichiers decouverts (step-01) |
| `{structure_map}` | object | Organisation et relations (step-01) |
| `{dependency_graph}` | object | Dependances et imports (step-01) |
| `{impl_analysis}` | object | Analyse implementation (step-02) |
| `{patterns}` | array | Patterns extraits (step-02) |
| `{gotchas}` | array | Pieges et edge cases (step-02) |
| `{docs_generated}` | array | Fichiers documentation crees (step-03) |
| `{validation_status}` | enum | PASS ou NEEDS_WORK (step-04) |

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    /learn WORKFLOW                               │
│         "Knowledge Acquisition Pipeline"                         │
│                                                                  │
│  00. INIT        → Parse topic + depth                           │
│       ↓           ✓ Topic clair, path sanitized                  │
│                                                                  │
│  01. SCAN        → 3 Haiku agents en PARALLELE                   │
│       │           ├── scan-files: Glob/Grep fichiers             │
│       │           ├── scan-structure: Mapper organisation        │
│       │           └── scan-deps: Identifier dependances          │
│       ↓           ✓ Files, structure, deps collectes             │
│                                                                  │
│  02. UNDERSTAND  → 3 Sonnet agents en PARALLELE                  │
│       │           ├── analyze-impl: Comprendre code              │
│       │           ├── analyze-patterns: Extraire patterns        │
│       │           └── analyze-gotchas: Trouver pieges            │
│       ↓           ✓ Comprehension complete                       │
│                                                                  │
│  03. SYNTHESIZE  → Opus genere documentation                     │
│       │           ├── INDEX.md (navigation)                      │
│       │           ├── architecture.md (comment)                  │
│       │           ├── key-files.md (fichiers critiques)          │
│       │           ├── gotchas.md (pieges)                        │
│       │           └── context.md (pourquoi)                      │
│       ↓           ✓ Docs crees, sources, dense                   │
│                                                                  │
│  04. VALIDATE    → Review Adversariale                           │
│       │           ├── Completude?                                │
│       │           ├── Dense? (0 fluff)                           │
│       │           ├── Source? (file:line)                        │
│       │           └── Exploitable?                               │
│       ↓           ✓ PASS (ou retour step-03, max 3x)             │
│                                                                  │
│  05. FINALIZE    → Resume + proposition archive                  │
│                    ✓ workspace/current/{topic}/ pret             │
└─────────────────────────────────────────────────────────────────┘
```

## Step Files

| Step | File | Purpose | Gate |
|------|------|---------|------|
| 00 | step-00-init.md | Parse arguments, valider topic | Topic clair |
| 01 | step-01-scan.md | 3 Haiku agents paralleles | Fichiers trouves |
| 02 | step-02-understand.md | 3 Sonnet agents paralleles | Comprehension complete |
| 03 | step-03-synthesize.md | Opus genere docs | Docs crees |
| 04 | step-04-validate.md | Review adversariale | PASS |
| 05 | step-05-finalize.md | Resume et archive | Termine |

## Pipeline 3 Niveaux

| Niveau | Model | Role | Cost |
|--------|-------|------|------|
| **SCAN** | Haiku | Decouverte rapide, filtrage | $ (cheap) |
| **UNDERSTAND** | Sonnet | Analyse profonde, comprehension | $$ (medium) |
| **SYNTHESIZE** | Opus | Redaction haute qualite | $$$ (high) |

**Justification**: Optimise cout/qualite. Haiku fait le travail rapide et cheap. Sonnet apporte la comprehension. Opus produit la documentation finale de qualite.

## Output Structure

```
workspace/current/{topic}/
├── INDEX.md           # Navigation + resume executif
├── architecture.md    # Comment ca marche (avec sources)
├── key-files.md       # Fichiers critiques expliques
├── gotchas.md         # Pieges, edge cases, incoherences
└── context.md         # Pourquoi c'est fait comme ca
```

**Format Documentation**:
- Dense : Haute information par token
- Source : Chaque affirmation avec `file:line`
- Date : Date de generation
- Structure : Headings, bullets, code blocks
- Scannable : Claude trouve rapidement l'info

## Execution Rules

1. **Pipeline Sequentiel**: SCAN → UNDERSTAND → SYNTHESIZE (dans cet ordre)
2. **Agents Paralleles**: Dans chaque phase, lancer 3 agents en SINGLE message
3. **Model Strategy**: Haiku (scan), Sonnet (understand), Opus (synthesize)
4. **Read-Only**: Jamais modifier le code source
5. **Source Everything**: Toute affirmation doit avoir file:line
6. **Dense Output**: Zero fluff, maximum signal
7. **Self-Healing**: Max 3 iterations de correction en step-04

## Success Criteria

✅ Topic explore en profondeur
✅ Documentation complete dans workspace/current/{topic}/
✅ Toutes affirmations sourcees (file:line)
✅ Format dense et exploitable par Claude
✅ Review adversariale passee

## Failure Modes

❌ Topic trop vague → AskUserQuestion pour clarifier
❌ Aucun fichier trouve → Suggerer topics similaires
❌ Context trop large → Prioriser top 20 fichiers
❌ Documentation verbose → Iteration de correction
❌ Sources manquantes → Retour step-03

<begin>
Load `steps/step-00-init.md` to start the knowledge acquisition pipeline.
</begin>
