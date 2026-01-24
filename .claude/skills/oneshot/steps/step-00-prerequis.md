---
name: step-00-prerequis
description: "Clarifier la demande et detecter le mode d'execution"
prev_step: null
next_step: steps/step-01-explore.md
---

# Step 00: Prerequisites

## MANDATORY EXECUTION RULES (READ FIRST)

- 🛑 NEVER proceed without a clear description of what to implement
- 🛑 NEVER assume the mode if --auto flag is ambiguous
- 🛑 NEVER use AskUserQuestion after this step in AUTO mode
- ✅ ALWAYS detect mode from argument flags (--auto or default supervised)
- ✅ ALWAYS clarify vague descriptions via AskUserQuestion
- ✅ ALWAYS estimate complexity (S/M/L) before proceeding
- 📋 YOU ARE a Requirements Analyst gathering implementation scope
- 💬 FOCUS on capturing clear, actionable requirements that enable autonomous execution
- 🚫 FORBIDDEN: Starting exploration without understanding what to build

## EXECUTION PROTOCOLS

- 🎯 **Goal**: Capture implementation requirements and determine execution mode
- 💾 **Output**: {description}, {mode}, {complexity} populated
- 📖 **Reference**: Pattern #7 (Single User Interaction)
- ⚡ **Performance**: Single AskUserQuestion if needed, then 100% autonomous

## CONTEXT BOUNDARIES

**Available from previous steps:**
- None (this is the first step)
- `$ARGUMENTS` - CLI argument passed to /oneshot

**Produced by this step:**
- `{description}` - Clear description of what to implement
- `{mode}` - auto or supervised (default: supervised)
- `{complexity}` - S (< 2h), M (2-4h), L (4-8h) estimated
- `{session_file}` - Path to session documentation file

**NOT available (do not use):**
- `{patterns_found}` - Produced in step-01
- `{implementation_plan}` - Produced in step-02
- `{code_written}` - Produced in step-03

## YOUR TASK

Parse the CLI argument to extract description and mode flag, clarify if needed, and estimate complexity.

---

## EXECUTION SEQUENCE

### 1. Parse CLI Argument

Extract description and flags from `$ARGUMENTS`.

**Input**: `$ARGUMENTS` (e.g., "Add dark mode toggle --auto")

**Parsing logic:**
```
if contains "--auto":
    mode = auto
    description = ARGUMENTS without "--auto"
else if contains "--mode=auto":
    mode = auto
    description = ARGUMENTS without "--mode=auto"
else:
    mode = supervised (default)
    description = ARGUMENTS
```

**Output**: `{description}` (raw), `{mode}`

### 2. Evaluate Description Clarity

Check if description is actionable.

**Clarity criteria:**
- Describes WHAT to build (not just "improve" or "fix")
- Has enough context to identify affected files
- Scope is bounded (can estimate complexity)

**If unclear, use AskUserQuestion:**

```yaml
questions:
  - question: "Peux-tu preciser ce que tu veux implementer ?"
    header: "Feature"
    options:
      - label: "Ajouter une nouvelle fonctionnalite"
        description: "Creer quelque chose de nouveau"
      - label: "Modifier un comportement existant"
        description: "Changer comment quelque chose fonctionne"
      - label: "Ameliorer/Refactorer"
        description: "Ameliorer du code existant sans changer le comportement"
```

**Output**: `{description}` (clarified)

**Fallback**: If still unclear after 1 follow-up, proceed with best interpretation and document assumption

### 3. Estimate Complexity

Assess implementation scope.

**Complexity factors:**
| Factor | S (Simple) | M (Medium) | L (Large) |
|--------|------------|------------|-----------|
| Files | 1-2 | 3-5 | 6+ |
| New tests | 1-3 | 4-8 | 9+ |
| Logic | Straightforward | Some edge cases | Complex flows |
| Dependencies | None | 1-2 services | Multiple systems |

**Output**: `{complexity}` = S | M | L

**Warning**: If complexity = L, suggest using /create-epic instead:
> "Cette feature semble complexe (L). Consider /create-epic pour une meilleure decomposition."

### 4. Confirm Oneshot Appropriateness

Verify this is the right workflow.

**Check:**
- Is this < 1 day of work? → Yes: continue, No: suggest /create-epic
- Does it need formal tracking? → No: continue, Yes: suggest /dev-story
- Is it a bug? → No: continue, Yes: suggest /debug

**If not appropriate:**
Present alternative and let user decide (AskUserQuestion with workflow suggestions).

### 5. Prepare State for Next Step

Structure captured information for handoff.

**Output state:**
```yaml
{description}: "Clear description of what to implement"
{mode}: supervised | auto
{complexity}: S | M | L
```

### 6. Create Session Documentation File

**CRITICAL**: Creer le fichier de session pour tracker tout le travail.

**File naming format:**
```
workspace/current/ONESHOT-YYYY-MM-DD-HH-MM-{description-slug}.md
```

**Slug generation:**
- Prendre les 3-5 premiers mots significatifs de `{description}`
- Remplacer espaces par tirets
- Tout en minuscule
- Max 30 caracteres

**Example:**
- Description: "Add dark mode toggle to settings"
- Slug: "add-dark-mode-toggle"
- File: `workspace/current/ONESHOT-2026-01-23-14-30-add-dark-mode-toggle.md`

**Initial content:**

```markdown
# ONESHOT: {description}

**Date**: {timestamp}
**Mode**: {mode}
**Complexite**: {complexity}

## Status

- [ ] Exploration
- [ ] Plan
- [ ] Execution
- [ ] Verification
- [ ] Commit

## 1. Context

**Objectif**: {description}

**Mode**: {mode} (supervised = checkpoint au plan, auto = 100% autonome)

**Complexite estimee**: {complexity}

## 2. Exploration

_A remplir dans step-01_

## 3. Plan

_A remplir dans step-02_

## 4. Execution

_A remplir dans step-03_

## 5. Problems & Solutions

_A remplir si problemes rencontres_

## 6. Result

_A remplir dans step-05_
```

**Output**: `{session_file}` - Path to created session file

**Fallback**: Si Write echoue, continuer le workflow (non-bloquant). Noter que session file n'a pas pu etre cree.

---

## AUTO-VALIDATION (APEX SELF-CRITIQUE)

**Before proceeding to next step, validate:**

✅ `{description}` is clear and actionable (not vague like "improve X")
✅ `{mode}` is explicitly set (auto or supervised)
✅ `{complexity}` is estimated (S, M, or L)
✅ Oneshot is appropriate (not too complex, not a bug)
✅ No "TBD" or placeholder text in captured values
✅ `{session_file}` created in workspace/current/ (or documented if failed)

**Self-Critique Questions:**
- Is the description specific enough to identify files to modify?
- If I had to explain this to another developer, would they understand?
- Did I correctly parse the --auto flag if present?
- Is this really < 1 day of work?

**If validation fails:**
1. If description unclear: Ask ONE clarifying question
2. Max 1 follow-up question (Pattern #7)
3. Si echec persistant: Proceed with best interpretation, document assumption

---

## SUCCESS METRICS

✅ `{description}` captures what to build (verb + object + context)
✅ `{mode}` is either "auto" or "supervised"
✅ `{complexity}` is S, M, or L
✅ `{session_file}` created with initial content
✅ User expectations are aligned (especially in SUPERVISED mode)
✅ Ready for autonomous exploration in step-01

## FAILURE MODES

❌ No argument provided → Fallback: AskUserQuestion "Que veux-tu implementer ?"
❌ Description too vague after clarification → Fallback: Proceed with assumption, document it
❌ Complexity = L → Suggest /create-epic, let user decide
❌ User wants formal tracking → Suggest /dev-story
❌ It's actually a bug → Suggest /debug

## NEXT STEP

After validation passes, load `steps/step-01-explore.md`

<critical>
This is the ONLY step with AskUserQuestion (unless mode=supervised has checkpoint in step-02).
In AUTO mode: After this step, ZERO user interaction until completion.
In SUPERVISED mode: One checkpoint at step-02 (plan validation), that's it.
Capture EVERYTHING needed NOW.
</critical>
