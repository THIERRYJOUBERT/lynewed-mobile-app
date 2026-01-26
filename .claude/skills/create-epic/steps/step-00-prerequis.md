---
name: step-00-prerequis
description: Parse args, detect mode, verify PRD-MASTER exists and has VALIDE status
prev_step: null
next_step: steps/step-01-select.md
---

# Step 00: Parse Arguments & Verify Prerequisites

## MANDATORY EXECUTION RULES (READ FIRST):

- ✅ ALWAYS parse arguments FIRST to detect mode
- 🛑 NEVER proceed without PRD-MASTER existing
- 🛑 NEVER proceed if PRD-MASTER status is not "VALIDE"
- ✅ ALWAYS read PRD-MASTER completely before proceeding
- ✅ ALWAYS extract available Epics from Section 7
- 📋 YOU ARE a prerequisite checker, not an Epic creator yet
- 💬 FOCUS on validation only - no Epic selection in this step
- 🚫 FORBIDDEN to create any files in this step
- 🚫 FORBIDDEN to load next step until prerequisites pass

## EXECUTION PROTOCOLS:

- 🎯 Parse arguments to detect mode and epic name
- 🎯 Check file existence before reading
- 💾 Store Epic list for next step
- 📖 Complete validation fully before proceeding
- 🚫 FORBIDDEN to skip validation even if PRD-MASTER was read recently

## CONTEXT BOUNDARIES:

- Arguments may be passed: `$ARGUMENTS`
- PRD-MASTER expected location: `docs/specs/PRD-MASTER.md`

## YOUR TASK:

1. Parse arguments to detect mode (interactive/auto) and optional epic name
2. Verify that PRD-MASTER exists and has VALIDE status
3. Extract the list of available Epics

---

## EXECUTION SEQUENCE:

### 0. Parse Arguments

Parse `$ARGUMENTS` to extract mode and optional epic name:

```yaml
# Argument patterns:
# ""                    → mode: interactive, epic_arg: null
# "--auto"              → mode: auto, epic_arg: null
# "Foundation"          → mode: interactive, epic_arg: "Foundation"
# "Foundation --auto"   → mode: auto, epic_arg: "Foundation"
# "EPIC-01"             → mode: interactive, epic_arg: "EPIC-01"

parsing:
  if "--auto" in $ARGUMENTS:
    {mode}: "auto"
  else:
    {mode}: "interactive"

  # Extract epic name (anything that's not a flag)
  epic_name_pattern: "[A-Za-z0-9-]+" (not starting with --)
  if match found:
    {epic_arg}: matched_name
  else:
    {epic_arg}: null
```

**Store in state:**
```yaml
{mode}: "interactive" | "auto"
{epic_arg}: null | "Foundation" | "EPIC-01" | etc.
```

### 1. Check PRD-MASTER Existence

Use the Read tool to check if `docs/specs/PRD-MASTER.md` exists.

**If file doesn't exist:**
```
⛔ WORKFLOW CANNOT PROCEED

PRD-MASTER not found at: docs/specs/PRD-MASTER.md

This workflow requires PRD-MASTER to be created first.
See: /create-prd or manually create the file.
```
→ END workflow

### 2. Verify PRD-MASTER Status

Look for status indicator in the document header.

**Expected format:**
```markdown
> Status : ✅ VALIDE
```

**If status is NOT "VALIDE":**
```
⛔ WORKFLOW CANNOT PROCEED

PRD-MASTER status: [CURRENT_STATUS]
Expected status: ✅ VALIDE

The PRD-MASTER must be validated before creating Epics.
Please complete PRD validation first.
```
→ END workflow

### 3. Extract Available Epics

Read Section 7 (Roadmap) of PRD-MASTER to extract Epics.

**Extract for each Epic:**
- Epic ID (e.g., EPIC-00-FOUNDATION)
- Epic Name
- Brief description
- Dependencies (if mentioned)

**Store in state:**
```yaml
{available_epics}:
  - id: EPIC-00-FOUNDATION
    name: "Foundation Technique"
    description: "..."
  - id: EPIC-01-AUTH
    name: "Authentification"
    description: "..."
```

### 4. Check for Existing Epics

List existing Epic folders in `docs/epics/`:

```bash
ls docs/epics/
```

**Store in state:**
```yaml
{existing_epics}: [EPIC-00-FOUNDATION, ...]
```

This helps identify which Epics are already created vs available.

### 5. Display Prerequisite Status

```
┌─────────────────────────────────────────────────────────────┐
│                  PREREQUISITES CHECK                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ PRD-MASTER found                                        │
│  ✅ Status: VALIDE                                          │
│                                                             │
│  📋 Available Epics: {count}                                │
│  📁 Already created: {existing_count}                       │
│                                                             │
│  🎯 Mode: {mode}                                            │
│  📌 Epic Arg: {epic_arg | "none"}                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## AUTO-VALIDATION

**Before proceeding to next step, validate:**

✅ {mode} is set to "interactive" or "auto"
✅ PRD-MASTER file exists at docs/specs/PRD-MASTER.md
✅ PRD-MASTER status is "✅ VALIDE"
✅ At least 1 Epic found in Section 7
✅ {available_epics} state variable populated
✅ {existing_epics} state variable populated

**If ANY validation fails:**
1. Display clear error message
2. Explain what's needed to fix
3. END workflow (do not proceed)

---

## SUCCESS METRICS:

✅ PRD-MASTER verified as existing
✅ PRD-MASTER status confirmed as VALIDE
✅ Available Epics extracted and stored
✅ Existing Epics identified
✅ Clear status displayed to user

## FAILURE MODES:

❌ PRD-MASTER file missing
❌ PRD-MASTER status not VALIDE
❌ No Epics found in Section 7
❌ Unable to read docs/epics/ directory

## PREREQUIS PROTOCOLS:

- Always check file existence before reading
- Always verify status before proceeding
- Store all discovered information for later steps
- Never create files during prerequisite check

## NEXT STEP:

If all prerequisites pass, load `steps/step-01-select.md`

<critical>
This step is a GATE. If prerequisites fail, the workflow MUST stop.
Do not attempt workarounds or proceed with partial data.
</critical>
