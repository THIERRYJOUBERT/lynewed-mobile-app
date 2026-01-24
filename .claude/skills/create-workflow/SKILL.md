---
name: create-workflow
description: Create or update Claude Code workflows with intelligent feature decisions and auto-critique. Supports reference, simple task, and multi-step workflow types.
model: opus
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Task
  - AskUserQuestion
  - TodoWrite
argument-hint: "<workflow-name> - name of workflow to create or update"
---

# /create-workflow v3

Meta-skill for creating production-ready Claude Code workflows through intelligent feature selection and rigorous self-critique.

## What This Workflow Does

Creates or updates workflows by:
1. **Understanding needs deeply** via hybrid structured interview
2. **Deciding intelligently** which CC features to use (subagents, hooks, context fork)
3. **Generating production-quality files** with justified design choices
4. **Self-critiquing** via checklist + adversarial review with iterations

## When to Use

**Use for:**
- Creating new workflows from scratch
- Updating existing workflows with improvements
- Migrating monolithic skills to multi-file architecture
- Standardizing workflows to validated patterns

**Don't use for:**
- Simple one-off scripts (use Bash directly)
- Single-step operations (no workflow needed)
- Pure documentation tasks (use /explore)

---

## Mode Detection (Router)

This section acts as Step-00: detect mode and route to appropriate flow.

### Detection Logic

```
INPUT: $ARGUMENTS

IF $ARGUMENTS is empty:
    → AskUserQuestion for workflow name
    → Then proceed with detection

IF .claude/skills/{$ARGUMENTS}/SKILL.md exists:
    → MODE = UPDATE
    → target_path = .claude/skills/{$ARGUMENTS}/
    → Load steps/step-U1-analyze.md

ELSE:
    → MODE = CREATE
    → workflow_name = $ARGUMENTS
    → target_path = .claude/skills/{$ARGUMENTS}/
    → Load steps/step-01-interview.md
```

### Handle Missing Arguments

If no argument provided, ask with examples:

```
AskUserQuestion:
  question: "What is the name of the workflow you want to create or update?"
  header: "Workflow"
  options:
    - label: "[Type name]"
      description: "Enter a kebab-case name (e.g., my-workflow)"
```

After getting the name, re-run detection logic.

---

## CREATE Mode Flow

When creating a new workflow:

```
┌─────────────────────────────────────────────────────────────────┐
│                    CREATE MODE (8 Steps)                         │
│                                                                  │
│  01. INTERVIEW   → Hybrid structured questions (AskUserQuestion) │
│       ↓                                                          │
│  02. EXPLORE     → 3 Sonnet agents in PARALLEL                   │
│       ↓           (patterns + similar workflows + system)        │
│                                                                  │
│  03. DESIGN      → Architecture + CC feature decisions           │
│       ↓           Each decision with justification               │
│                                                                  │
│  04. CHECKPOINT  → Present design for user validation            │
│       ↓           (AskUserQuestion - adjust or proceed)          │
│                                                                  │
│  05. GENERATE    → Create all workflow files                     │
│       ↓           Using templates from templates/                │
│                                                                  │
│  06. CRITIQUE    → Checklist + Adversarial review               │
│       ↓           Max 3 iterations to fix issues                 │
│                                                                  │
│  07. VALIDATE    → Structure, syntax, mental simulation          │
│       ↓                                                          │
│                                                                  │
│  08. REGISTER    → Update CLAUDE.md + summary                    │
└─────────────────────────────────────────────────────────────────┘
```

**Entry Point:** Load `steps/step-01-interview.md`

---

## UPDATE Mode Flow

When updating an existing workflow:

```
┌─────────────────────────────────────────────────────────────────┐
│                    UPDATE MODE (U1-U4 + 06-08)                   │
│                                                                  │
│  U1. ANALYZE     → Read all existing files                       │
│       ↓           Create structured synthesis                    │
│                                                                  │
│  U2. ASSESS      → Evaluate against quality criteria             │
│       ↓           Identify strengths and weaknesses              │
│                                                                  │
│  U3. PROPOSE     → Present improvements for validation           │
│       ↓           (AskUserQuestion - CHECKPOINT)                 │
│                                                                  │
│  U4. IMPROVE     → Apply validated changes                       │
│       ↓           Preserve what works                            │
│                                                                  │
│  06-08. CRITIQUE → VALIDATE → REGISTER (same as CREATE)          │
└─────────────────────────────────────────────────────────────────┘
```

**Entry Point:** Load `steps/step-U1-analyze.md`

---

## State Variables

Track these throughout execution:

| Variable | Type | Description |
|----------|------|-------------|
| `{mode}` | enum | CREATE or UPDATE |
| `{workflow_name}` | string | kebab-case name |
| `{target_path}` | string | .claude/skills/{name}/ |
| `{objective}` | string | Problem this workflow solves |
| `{invocation}` | enum | user-only, model-only, or both |
| `{inputs}` | array | Required inputs/arguments |
| `{outputs}` | array | Expected outputs/artifacts |
| `{constraints}` | array | Rules and limitations |
| `{workflow_type}` | enum | reference, task-simple, task-workflow |
| `{cc_features}` | object | Decided CC features with justifications |
| `{exploration_results}` | object | Results from 3 parallel agents |
| `{steps_design}` | array | Step definitions (if multi-step) |

---

## Key Patterns

### JIT Reference Loading

References are loaded in steps that need them, not here:
- `references/decision-matrix.md` → Loaded in step-02 (explore) and step-03 (design)
- `references/patterns-unified.md` → Loaded in step-02 (explore)
- `references/quality-criteria.md` → Loaded in step-06 (critique)
- `references/features-guide.md` → Loaded in step-03 (design)

### Checkpoint Strategy

User interaction points:
1. **Step-01 (Interview):** Gather requirements
2. **Step-04 (Checkpoint):** Validate design before generation
3. **Step-U3 (Propose):** Validate improvements before applying

Between checkpoints: autonomous execution.

### Parallel Agent Pattern

In step-02 (Explore), launch 3 Sonnet agents in SINGLE message:
- Agent 1: Patterns & Decision Matrix
- Agent 2: Similar Workflows
- Agent 3: System Coherence

---

## Step Files

### CREATE Mode
| Step | File | Purpose |
|------|------|---------|
| 01 | steps/step-01-interview.md | Hybrid structured interview |
| 02 | steps/step-02-explore.md | 3 parallel Sonnet agents |
| 03 | steps/step-03-design.md | Architecture + CC decisions |
| 04 | steps/step-04-checkpoint.md | User validates design |
| 05 | steps/step-05-generate.md | Generate all files |
| 06 | steps/step-06-critique.md | Checklist + adversarial |
| 07 | steps/step-07-validate.md | Final validation |
| 08 | steps/step-08-register.md | Update docs + summary |

### UPDATE Mode
| Step | File | Purpose |
|------|------|---------|
| U1 | steps/step-U1-analyze.md | Read + synthesize existing |
| U2 | steps/step-U2-assess.md | Evaluate strengths/weaknesses |
| U3 | steps/step-U3-propose.md | Present improvements |
| U4 | steps/step-U4-improve.md | Apply validated changes |
| 06-08 | (same as CREATE) | Critique, validate, register |

---

## Templates

| Template | File | Use Case |
|----------|------|----------|
| Reference Skill | templates/skill-reference.md | Knowledge/guidelines content |
| Simple Task | templates/skill-task-simple.md | <3 step workflows |
| Multi-Step | templates/skill-task-workflow.md | 3+ step workflows |
| Step Universal | templates/step-universal.md | Any step file |
| Agent | templates/agent.md | Subagent definitions |
| Manifest | templates/manifest.yaml | Version + metadata |

---

## Critical Constraints

1. **NO context: fork for this workflow** - Meta-workflow needs conversation history
2. **JIT loading only** - References loaded in steps that need them
3. **Templates must be complete** - No TBD/TODO placeholders
4. **Each CC feature justified** - Never use features "because it's available"
5. **Self-critique is mandatory** - Checklist + adversarial + iterations

---

## Begin

Execute mode detection logic above, then load appropriate step file.
