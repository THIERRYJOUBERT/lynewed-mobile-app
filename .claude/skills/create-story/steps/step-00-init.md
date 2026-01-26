# Step 00: Init - Parse Args & Verify Epic

> Purpose: Parse arguments (epic-id, --auto), verify Epic exists, and capture initial context.

---

## MANDATORY RULES (READ FIRST)

- ✅ PARSE arguments FIRST to detect mode (--auto)
- 🔍 VERIFY Epic exists before any analysis
- 📁 LOCATE exact path to Epic file
- ❓ ASK user if Epic not specified or not found (ONLY in interactive mode)
- 🚫 NEVER use AskUserQuestion in auto mode

## PROTOCOLS

- 🎯 **Goal**: Parse mode + Confirm Epic exists and is ready for decomposition
- 💾 **Output**: `{mode}`, `{epic_id}`, `{epic_path}` validated
- 📖 **Reference**: docs/epics/ directory structure
- ⚡ **Performance**: Quick verification before heavy analysis

---

## CONTEXT

**Available from SKILL.md:**
- `$ARGUMENTS` - Optional Epic ID and flags (e.g., "EPIC-01 --auto")

**Produced by this step:**
- `{mode}` - "interactive" or "auto"
- `{epic_id}` - Validated Epic identifier
- `{epic_path}` - Full path to Epic file

**NOT available (do not use):**
- `{epic_content}` - Not loaded until step-01
- `{proposed_stories}` - Not created until step-02

---

## TASK

1. Parse arguments to detect mode and epic-id
2. Verify that a valid Epic exists in `docs/epics/`
3. Capture its path for analysis

---

## EXECUTION

### 0. Parse Arguments (FIRST!)

Parse `$ARGUMENTS` to extract mode and epic-id:

```yaml
# Argument patterns:
# ""                      → mode: interactive, epic_id: null
# "EPIC-01"               → mode: interactive, epic_id: "EPIC-01"
# "--auto"                → mode: auto, epic_id: null (auto-select)
# "EPIC-01 --auto"        → mode: auto, epic_id: "EPIC-01"
# "01"                    → mode: interactive, epic_id: "EPIC-01" (normalized)

parsing:
  if "--auto" in $ARGUMENTS:
    {mode}: "auto"
  else:
    {mode}: "interactive"

  # Extract epic-id (anything that's not a flag)
  epic_pattern: /EPIC-\d+|^\d+$/
  if match found:
    {epic_arg}: normalize_epic_id(match)  # "01" → "EPIC-01"
  else:
    {epic_arg}: null
```

**Store in state:**
```yaml
{mode}: "interactive" | "auto"
{epic_arg}: null | "EPIC-01" | etc.
```

### 1. Discover Available Epics

List all Epics in the project:

```
Glob docs/epics/EPIC-*/EPIC-*.md
```

**Expected format:**
```
docs/epics/EPIC-01-AUTH/EPIC-01-AUTH.md
docs/epics/EPIC-02-WORKOUT/EPIC-02-WORKOUT.md
...
```

### 2. Mode-Based Epic Selection

**IF {epic_arg} is provided:**
```yaml
# Direct selection by argument
{epic_id}: {epic_arg}
{selection_method}: "argument"
# Validate it exists
if {epic_id} not in discovered_epics:
  IF {mode} == "interactive":
    → AskUserQuestion for correct Epic
  ELSE:
    → Error: "Epic {epic_arg} not found"
```

**IF {mode} == "auto" AND {epic_arg} is null:**
```yaml
# Auto mode without explicit epic → ERROR
# Must specify epic in auto mode
{error}: "Auto mode requires an Epic ID. Usage: /create-story EPIC-01 --auto"
# Display available Epics and stop
```

**IF {mode} == "interactive" AND {epic_arg} is null:**
```yaml
# Ask user to select Epic
AskUserQuestion:
  question: "Which Epic do you want to decompose into stories?"
  header: "Epic"
  options:
    - [List discovered Epics as options]
```

### 3. Validate Epic Path

After Epic selection (by any method):

```yaml
{epic_path}: "docs/epics/{epic_id}-NAME/{epic_id}-NAME.md"

# Verify file exists
Read {epic_path}

IF file not found:
  IF {mode} == "interactive":
    → AskUserQuestion with available Epics
  ELSE:
    → Error: "Epic file not found at {epic_path}"
```

### 4. Set State Variables

After Epic validation:

```yaml
{mode}: "interactive" | "auto"
{epic_id}: "EPIC-XX"
{epic_path}: "docs/epics/EPIC-XX-NAME/EPIC-XX-NAME.md"
{epic_folder}: "docs/epics/EPIC-XX-NAME/"
```

### 5. Display Init Summary

```
┌─────────────────────────────────────────────────────────────┐
│                  /create-story INIT                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  🎯 Mode: {mode}                                            │
│  📌 Epic: {epic_id}                                         │
│  📁 Path: {epic_path}                                       │
│                                                             │
│  Next: Analyze Epic content                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ {mode} is set ("interactive" or "auto")
✅ {epic_id} is captured
✅ {epic_path} points to valid .md file
✅ Epic file is readable (not empty or corrupted)
✅ If auto mode: NO AskUserQuestion was used

**Self-Critique Questions:**
- Did I parse --auto flag correctly?
- Did I verify the file actually exists?
- Is the Epic path correct with full directory structure?
- In auto mode, did I avoid all user interaction?

**If validation fails:**
1. Re-check argument parsing
2. Re-check docs/epics/ structure
3. In interactive mode: Ask user for correct Epic
4. In auto mode: Error with clear message

---

## SUCCESS / FAILURE

**Success:**
✅ `{mode}` is set
✅ `{epic_id}` is set (e.g., "EPIC-01")
✅ `{epic_path}` points to valid .md file
✅ Ready to analyze Epic content

**Failure modes:**
❌ No Epics in project → Inform user, suggest /create-epic
❌ Epic file empty/corrupt → Report error
❌ Auto mode without Epic ID → Error with usage message
❌ Epic not found in auto mode → Error with available Epics list

## NEXT

After validation passes, load `steps/step-01-analyze.md`

<critical>
Mode detection MUST happen FIRST.
In AUTO mode: Never use AskUserQuestion.
In INTERACTIVE mode: AskUserQuestion is allowed for Epic selection.
NEVER proceed without a validated Epic.
</critical>
