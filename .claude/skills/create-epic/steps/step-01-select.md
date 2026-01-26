---
name: step-01-select
description: Select Epic (interactive or auto based on mode)
prev_step: steps/step-00-prerequis.md
next_step: steps/step-02-discovery.md
---

# Step 01: Select Epic

## MANDATORY EXECUTION RULES (READ FIRST):

- ✅ ALWAYS check {mode} first - behavior differs completely
- ✅ ALWAYS show all available Epics with status
- ✅ ALWAYS mark already-created Epics visually
- 📋 IF mode=interactive: Use AskUserQuestion for selection
- 📋 IF mode=auto: Auto-select FIRST uncreated Epic
- 🚫 FORBIDDEN to create any files in this step
- 🚫 FORBIDDEN to use AskUserQuestion in auto mode

## EXECUTION PROTOCOLS:

- 🎯 Display Epics with clear differentiation (created vs available)
- 💾 Store selected Epic info in state variables
- 📖 Get explicit user confirmation (interactive) OR auto-select (auto)

## CONTEXT BOUNDARIES:

**Available from step-00:**
- `{mode}` - "interactive" or "auto"
- `{epic_arg}` - Epic name from argument (optional, e.g., "Foundation")
- `{available_epics}` - List of Epics from PRD-MASTER Section 7
- `{existing_epics}` - List of already created Epic folders

## YOUR TASK:

Select Epic based on mode and arguments.

---

## EXECUTION SEQUENCE:

### 1. Prepare Epic Display

For each Epic in `{available_epics}`, determine status:

```
If epic_id in {existing_epics}:
  status = "✅ Created"
  available_for_auto = false
Else:
  status = "🔵 Available"
  available_for_auto = true
```

### 2. Mode-Based Selection

**IF {epic_arg} is provided:**
```yaml
# Direct selection by argument
{epic_id}: Find Epic matching {epic_arg} name
{selection_method}: "argument"
# Skip to Step 5 (confirmation)
```

**IF {mode} == "auto":**
```yaml
# Auto-select FIRST uncreated Epic
for epic in {available_epics}:
  if epic not in {existing_epics}:
    {epic_id}: epic.id
    {selection_method}: "auto"
    break

# If ALL epics already created:
if no uncreated epic found:
  {error}: "All Epics already created. Use interactive mode to recreate."
  # Display message and stop workflow
```

**IF {mode} == "interactive":**
```yaml
# Continue to Step 3 for user selection
```

### 3. Display Epic Options (Interactive Only)

Show formatted table:

```
┌─────────────────────────────────────────────────────────────┐
│                    AVAILABLE EPICS                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  #  │ Epic ID              │ Status      │ Description      │
│ ────┼──────────────────────┼─────────────┼──────────────────│
│  1  │ EPIC-00-FOUNDATION   │ ✅ Created  │ Foundation tech  │
│  2  │ EPIC-01-AUTH         │ 🔵 Availbl  │ Authentication   │
│  3  │ EPIC-02-EXERCISES    │ 🔵 Availbl  │ Exercise library │
│  ... │ ...                 │ ...         │ ...              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4. Ask User to Select (Interactive Only)

Use AskUserQuestion to get selection:

```yaml
AskUserQuestion:
questions:
  - question: "Which Epic do you want to create or recreate?"
    header: "Epic"
    options:
      - label: "{EPIC-00-FOUNDATION} (recreate)"
        description: "Already exists - will recreate from scratch"
      - label: "{EPIC-01-AUTH}"
        description: "Authentication - not yet created"
      - label: "{EPIC-02-EXERCISES}"
        description: "Exercise library - not yet created"
      # ... dynamically generated from available_epics
    multiSelect: false
```

**Note:** Generate options dynamically based on `{available_epics}`.

### 4b. Confirm Selection for Existing Epics (Interactive Only)

**If user selected an already-created Epic:**

```yaml
AskUserQuestion:
questions:
  - question: "EPIC-XX already exists. This will recreate it from scratch. Continue?"
    header: "Confirm"
    options:
      - label: "Yes, recreate"
        description: "Overwrite existing Epic files"
      - label: "No, choose different"
        description: "Go back to Epic selection"
    multiSelect: false
```

**If "No":** Return to Step 3

### 5. Store Selection in State

After selection (regardless of method):

```yaml
{epic_id}: "EPIC-00-FOUNDATION"
{epic_name}: "Foundation Technique"
{epic_description}: "Setup projet, CI/CD, base de donnees locale"
{epic_path}: "docs/epics/EPIC-00-FOUNDATION"
{is_recreate}: true/false
{selection_method}: "interactive" | "auto" | "argument"
```

### 6. Display Selection Summary

```
┌─────────────────────────────────────────────────────────────┐
│                   EPIC SELECTED                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📌 Epic: {epic_id}                                         │
│  📝 Name: {epic_name}                                       │
│  📁 Path: {epic_path}                                       │
│  🔄 Mode: {Create | Recreate}                               │
│  🎯 Selection: {interactive | auto | argument}              │
│                                                             │
│  Next: Discover source documents (FDs) for this Epic        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## AUTO-VALIDATION

**Before proceeding to next step, validate:**

✅ {epic_id} state variable is set
✅ {epic_name} state variable is set
✅ {epic_path} state variable is set
✅ If interactive + recreate, user confirmed they want to overwrite
✅ If auto mode, no AskUserQuestion was used

---

## SUCCESS METRICS:

✅ All available Epics displayed clearly
✅ Correct selection method based on mode
✅ Selection stored in state variables
✅ Summary displayed to user

## FAILURE MODES:

❌ No Epics available to select → Error message
❌ All Epics already created (auto mode) → Error message, suggest interactive
❌ Epic argument doesn't match any Epic → Fallback to selection/auto
❌ User cancels selection (interactive) → Ask again

## SELECTION PROTOCOLS:

**Auto Mode:**
- Select FIRST Epic without existing folder
- NO AskUserQuestion
- If all created, error and suggest interactive mode

**Interactive Mode:**
- Show ALL Epics (created + available)
- Get explicit user selection
- Confirm before recreating

## NEXT STEP:

After Epic selection confirmed, load `steps/step-02-discovery.md`

<critical>
Mode determines behavior:
- interactive: User agency paramount, use AskUserQuestion
- auto: 100% autonomous, NO user interaction, select first uncreated
- argument: Direct selection by name, skip interaction if unambiguous
</critical>
