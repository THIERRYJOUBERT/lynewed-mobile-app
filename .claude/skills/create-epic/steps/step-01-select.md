---
name: step-01-select
description: User selects Epic from available list
prev_step: steps/step-00-prerequis.md
next_step: steps/step-02-discovery.md
---

# Step 01: Select Epic

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER select Epic without user input
- 🛑 NEVER proceed without confirmed selection
- ✅ ALWAYS show all available Epics with status
- ✅ ALWAYS use AskUserQuestion for selection
- ✅ ALWAYS mark already-created Epics visually
- 📋 YOU ARE a facilitator helping user choose
- 💬 FOCUS on presenting options clearly
- 🚫 FORBIDDEN to auto-select or assume Epic choice
- 🚫 FORBIDDEN to create any files in this step

## EXECUTION PROTOCOLS:

- 🎯 Display Epics with clear differentiation (created vs available)
- 💾 Store selected Epic info in state variables
- 📖 Get explicit user confirmation
- 🚫 FORBIDDEN to load next step without user selection

## CONTEXT BOUNDARIES:

**Available from step-00:**
- `{available_epics}` - List of Epics from PRD-MASTER Section 7
- `{existing_epics}` - List of already created Epic folders

## YOUR TASK:

Present available Epics to the user and get their selection via AskUserQuestion.

---

## EXECUTION SEQUENCE:

### 1. Prepare Epic Display

For each Epic in `{available_epics}`, determine status:

```
If epic_id in {existing_epics}:
  status = "✅ Created"
  action = "(recreate)"
Else:
  status = "🔵 Available"
  action = ""
```

### 2. Display Epic Options

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

### 3. Ask User to Select

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

### 4. Confirm Selection for Existing Epics

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

After confirmed selection:

```yaml
{epic_id}: "EPIC-00-FOUNDATION"
{epic_name}: "Foundation Technique"
{epic_description}: "Setup projet, CI/CD, base de donnees locale"
{epic_path}: "docs/epics/EPIC-00-FOUNDATION"
{is_recreate}: true/false
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
│                                                             │
│  Next: Discover source documents (FDs) for this Epic        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## AUTO-VALIDATION

**Before proceeding to next step, validate:**

✅ User explicitly selected an Epic via AskUserQuestion
✅ {epic_id} state variable is set
✅ {epic_name} state variable is set
✅ {epic_path} state variable is set
✅ If recreate, user confirmed they want to overwrite

**Validation is automatic** - if user selected via AskUserQuestion, we have explicit confirmation.

---

## SUCCESS METRICS:

✅ All available Epics displayed clearly
✅ Status (created/available) shown for each
✅ User selected via AskUserQuestion
✅ Recreate confirmed if applicable
✅ Selection stored in state variables

## FAILURE MODES:

❌ No Epics available to select
❌ User cancels selection
❌ State variables not properly set

## SELECTION PROTOCOLS:

- Always show ALL available Epics, not just uncreated ones
- Always get explicit user confirmation for recreate
- Never auto-select based on assumptions
- Always store complete Epic info in state

## NEXT STEP:

After Epic selection confirmed, load `steps/step-02-discovery.md`

<critical>
User agency is paramount. NEVER proceed without explicit AskUserQuestion selection.
The user must actively choose which Epic to work on.
</critical>
