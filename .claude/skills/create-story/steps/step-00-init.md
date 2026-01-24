# Step 00: Init - Verify Epic Exists

> Purpose: Verify Epic exists and capture initial context before decomposition.

---

## MANDATORY RULES (READ FIRST)

- 🔍 VERIFY Epic exists before any analysis
- 📁 LOCATE exact path to Epic file
- ❓ ASK user if Epic not specified or not found
- ✅ CAPTURE $ARGUMENTS if provided

## PROTOCOLS

- 🎯 **Goal**: Confirm Epic exists and is ready for decomposition
- 💾 **Output**: `{epic_id}` and `{epic_path}` validated
- 📖 **Reference**: docs/epics/ directory structure
- ⚡ **Performance**: Quick verification before heavy analysis

---

## CONTEXT

**Available from SKILL.md:**
- `$ARGUMENTS` - Optional Epic ID passed by user

**Produced by this step:**
- `{epic_id}` - Validated Epic identifier
- `{epic_path}` - Full path to Epic file

**NOT available (do not use):**
- `{epic_content}` - Not loaded until step-01
- `{proposed_stories}` - Not created until step-02

---

## TASK

Verify that a valid Epic exists in `docs/epics/` and capture its path for analysis.

---

## EXECUTION

### 1. Parse Arguments

Check if user provided an Epic ID via $ARGUMENTS.

```
IF $ARGUMENTS is not empty:
    {epic_id} = normalize($ARGUMENTS)  # e.g., "01" → "EPIC-01"
ELSE:
    {epic_id} = null  # Will ask user
```

### 2. Discover Available Epics

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

### 3. Validate or Ask

**If {epic_id} provided AND exists:**
```
{epic_path} = docs/epics/EPIC-XX-NAME/EPIC-XX-NAME.md
✅ Epic found, ready for analysis
```

**If {epic_id} provided BUT not found:**
```
AskUserQuestion:
  question: "Epic '{epic_id}' not found. Which Epic do you want to decompose?"
  header: "Epic"
  options:
    - [List discovered Epics]
```

**If no Epic ID provided:**
```
AskUserQuestion:
  question: "Which Epic do you want to decompose into stories?"
  header: "Epic"
  options:
    - [List discovered Epics as options]
```

### 4. Set State Variables

After Epic selection:

```yaml
epic_id: "EPIC-XX"
epic_path: "docs/epics/EPIC-XX-NAME/EPIC-XX-NAME.md"
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ Epic ID is captured in `{epic_id}`
✅ Epic file exists at `{epic_path}`
✅ Epic file is readable (not empty or corrupted)

**Self-Critique Questions:**
- Did I verify the file actually exists, or just assume?
- Is the Epic path correct with full directory structure?
- Did I handle the case where no Epics exist in the project?

**If validation fails:**
1. Re-check docs/epics/ structure
2. Ask user for correct Epic identifier
3. If no Epics exist: inform user to create Epic first (/create-epic)

---

## SUCCESS / FAILURE

**Success:**
✅ `{epic_id}` is set (e.g., "EPIC-01")
✅ `{epic_path}` points to valid .md file
✅ Ready to analyze Epic content

**Failure modes:**
❌ No Epics in project → Inform user, suggest /create-epic
❌ Epic file empty/corrupt → Report error, ask to verify Epic
❌ Multiple matching Epics → Ask user to be more specific

## NEXT

After validation passes, load `steps/step-01-analyze.md`

<critical>
NEVER proceed without a validated Epic.
The entire workflow depends on Epic content.
If Epic is missing or invalid, STOP and inform user.
</critical>
