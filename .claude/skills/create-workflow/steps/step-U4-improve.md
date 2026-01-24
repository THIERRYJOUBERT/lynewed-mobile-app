# Step U4: Apply Improvements

> Purpose: Apply approved improvements to workflow using minimal, targeted edits.

---

## MANDATORY RULES (READ FIRST)

- ✏️ PREFER Edit over Write - minimal changes preserve context
- 🔒 PRESERVE strengths - do not break what works
- 🔢 UPDATE version in manifest.yaml
- ✅ VALIDATE each change before next

## PROTOCOLS

- 🎯 **Goal**: Apply all approved improvements without breaking existing functionality
- 💾 **Output**: `{modifications}` tracking all changes made
- 📖 **Reference**: `{approved_improvements}` from step-U3
- ⚡ **Performance**: Surgical edits are safer than rewrites

---

## CONTEXT

**Available from previous steps:**
- `{existing_workflow}` - Complete workflow analysis (from step-U1)
- `{assessment}` - Quality assessment (from step-U2)
- `{approved_improvements}` - User-approved changes (from step-U3)

**Produced by this step:**
- `{modifications}` - Complete record of all changes made

**NOT available (do not use):**
- `{critique_results}` - Created in step-06

---

## TASK

Apply each approved improvement systematically:
1. Plan the specific edits needed
2. Apply changes using Edit tool (preferred) or Write tool
3. Validate each change didn't break other parts
4. Update manifest version
5. Track all modifications

---

## EXECUTION

### 1. Pre-flight Checks

Before making any changes:

**Verify preserved strengths:**

```yaml
preserved_check:
  FOR each strength in {approved_improvements.preserved_strengths}:
    - strength: "S1"
      location: "SKILL.md:45-52"
      current_content: "..." (read actual content)
      must_not_change: true
```

**Verify current state matches analysis:**

```yaml
state_check:
  - Confirm files exist at expected paths
  - Confirm content matches {existing_workflow} analysis
  - If mismatch: Re-analyze before proceeding
```

---

### 2. Plan Edit Strategy

For each approved improvement:

```yaml
edit_plan:
  improvement_id: "improvement_1"

  strategy: "edit" | "write" | "mixed"

  edits:
    - file: "SKILL.md"
      operation: "replace"
      old_string: "exact text to replace"
      new_string: "new text"
      reason: "Why this change"

    - file: "steps/step-02.md"
      operation: "insert"
      location: "after line containing 'AUTO-VALIDATION'"
      content: "new content to insert"
      reason: "Why this addition"

  writes:  # Only if file doesn't exist or needs full rewrite
    - file: "templates/new-template.md"
      reason: "New file needed for feature"
      content_source: "generate from pattern"

  deletes:  # Rare - usually just edit to remove
    - file: "old-file.md"
      reason: "Obsolete after refactor"
```

**Edit preference hierarchy:**

1. **Edit single string** - Best for typos, small fixes
2. **Edit section** - Good for updating related content
3. **Edit multiple locations** - For consistent changes across file
4. **Write file** - Only for new files or complete restructure

---

### 3. Apply Improvements (One at a Time)

**Process each improvement sequentially:**

```
FOR each improvement in {approved_improvements}:

    1. ANNOUNCE what you're changing
       "Applying improvement {id}: {description}"

    2. READ current file state
       Verify content is as expected

    3. APPLY edits using Edit tool

    4. VERIFY change was correct
       - Re-read affected section
       - Check no unintended changes
       - Confirm preserved strengths intact

    5. RECORD in modifications log

    6. PROCEED to next improvement
```

---

### 4. Edit Tool Usage Patterns

**Pattern: Simple text replacement**

```
Edit tool:
  file_path: ".claude/skills/{workflow}/SKILL.md"
  old_string: "outdated description text"
  new_string: "updated description text"
```

**Pattern: Add section**

```
Edit tool:
  file_path: ".claude/skills/{workflow}/steps/step-02.md"
  old_string: "## NEXT"
  new_string: |
    ## FALLBACK HANDLING

    If primary method fails:
    1. Try alternative approach
    2. If still failing, escalate

    ## NEXT
```

**Pattern: Remove section**

```
Edit tool:
  file_path: ".claude/skills/{workflow}/SKILL.md"
  old_string: |
    ## DEPRECATED SECTION

    This content is no longer relevant...
    (entire section)

    ## NEXT SECTION
  new_string: "## NEXT SECTION"
```

**Pattern: Update YAML frontmatter**

```
Edit tool:
  file_path: ".claude/skills/{workflow}/SKILL.md"
  old_string: |
    ---
    name: workflow-name
    description: "old description"
    ---
  new_string: |
    ---
    name: workflow-name
    description: "new improved description"
    ---
```

**Pattern: Fix multiple occurrences**

```
Edit tool:
  file_path: ".claude/skills/{workflow}/steps/step-03.md"
  old_string: "incorect"
  new_string: "incorrect"
  replace_all: true
```

---

### 5. Handle Custom Requests

For custom improvements (not from proposals):

```yaml
custom_handling:
  - Read custom request from {approved_improvements.custom_requests}

  - Analyze what files need changing

  - Determine edit strategy:
      IF clear and simple: Apply directly
      IF ambiguous: Create best interpretation, note assumption

  - Apply changes following same edit patterns

  - Document what was done and any assumptions made
```

---

### 6. Update Manifest Version

**ALWAYS update version after modifications:**

```yaml
# Read current version
current_version: "1.2.0"

# Determine version bump:
#   PATCH (1.2.0 → 1.2.1): Bug fixes, typos, minor improvements
#   MINOR (1.2.0 → 1.3.0): New features, significant improvements
#   MAJOR (1.2.0 → 2.0.0): Breaking changes, major restructure

new_version: "1.2.1"  # or "1.3.0" based on changes

# Apply version update
Edit tool:
  file_path: ".claude/skills/{workflow}/manifest.yaml"
  old_string: "version: \"1.2.0\""
  new_string: "version: \"1.2.1\""
```

**If no manifest.yaml exists:**

```yaml
# Create minimal manifest
Write tool:
  file_path: ".claude/skills/{workflow}/manifest.yaml"
  content: |
    # Workflow Manifest
    name: "{workflow_name}"
    version: "1.0.1"
    description: "{description from SKILL.md}"
    updated: "{current_date}"
```

---

### 7. Post-Change Validation

After ALL improvements applied:

**Syntax validation:**

```yaml
validation_checks:
  - Check YAML frontmatters parse correctly
  - Check markdown structure is valid
  - Check internal links still work
  - Check no accidental content deletion
```

**Preserved strengths validation:**

```yaml
strengths_check:
  FOR each preserved strength:
    - Re-read the location
    - Confirm content unchanged or improved
    - If broken: IMMEDIATELY revert and fix
```

**Coherence validation:**

```yaml
coherence_check:
  - Read through modified workflow mentally
  - Confirm changes work together
  - Identify any new inconsistencies introduced
```

---

### 8. Record Modifications

Build complete modifications log:

```yaml
modifications:
  - id: "mod_1"
    improvement_id: "improvement_1"
    file: ".claude/skills/{workflow}/SKILL.md"
    change_type: "edit"
    description: "Updated description to match actual behavior"
    old_content: "Previous text..."
    new_content: "Updated text..."
    verified: true

  - id: "mod_2"
    improvement_id: "improvement_1"
    file: ".claude/skills/{workflow}/steps/step-02.md"
    change_type: "edit"
    description: "Added fallback handling section"
    old_content: null  # insertion
    new_content: "## FALLBACK HANDLING..."
    verified: true

  - id: "mod_3"
    improvement_id: "improvement_custom_1"
    file: ".claude/skills/{workflow}/SKILL.md"
    change_type: "edit"
    description: "Custom: {user's request}"
    assumption: "Interpreted as X"  # if any
    verified: true

version_update:
  old: "1.2.0"
  new: "1.2.1"
  bump_type: "patch"
  reason: "Bug fixes and minor improvements"

summary:
  files_modified: N
  files_added: N
  files_deleted: N
  total_edits: N
  all_verified: true
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ All approved improvements have been applied
✅ Each modification was verified after application
✅ Preserved strengths are still intact
✅ Manifest version was updated
✅ No syntax errors introduced
✅ Modifications log is complete

**Self-Critique Questions:**
- Did I use Edit instead of Write where possible?
- Did I accidentally change something not in scope?
- Are all my edits minimal and surgical?
- Did I verify each change actually worked?
- Could any of my changes have broken something else?

**If validation fails:**
1. Identify which change caused the issue
2. Revert that specific change
3. Retry with different approach
4. If stuck: Document issue and proceed with partial success

---

## OUTPUT STRUCTURE

Complete `{modifications}`:

```yaml
modifications:
  - id: "mod_N"
    improvement_id: "..."
    file: "..."
    change_type: "edit" | "add" | "delete"
    description: "..."
    old_content: "..." | null
    new_content: "..." | null
    assumption: "..." | null  # for custom requests
    verified: boolean

version_update:
  old: "..."
  new: "..."
  bump_type: "patch" | "minor" | "major"
  reason: "..."

summary:
  files_modified: N
  files_added: N
  files_deleted: N
  total_edits: N
  all_verified: boolean
  preserved_strengths_intact: boolean
```

---

## SUCCESS / FAILURE

**Success:**
✅ All approved improvements applied
✅ All changes verified
✅ Preserved strengths intact
✅ Version updated
✅ Ready for critique (step-06)

**Failure modes:**
❌ Edit fails (string not found) → Re-read file, adjust old_string
❌ Change breaks other content → Revert, analyze impact, retry
❌ Custom request unclear → Document best interpretation, flag for review
❌ Cannot apply improvement → Document why, proceed with others

---

## ROLLBACK PROTOCOL

If critical failure during application:

```yaml
rollback:
  1. Note which modifications succeeded
  2. For failed modification:
     - Document exact error
     - Revert if partial change made
  3. Options:
     a. Skip this improvement, continue with others
     b. Ask user for guidance via AskUserQuestion
     c. Proceed to critique with documented gap
```

---

## NEXT

After validation passes, load `steps/step-06-critique.md`

The critique step will:
- Evaluate the updated workflow
- Verify improvements actually improved quality
- Catch any issues introduced by modifications

<critical>
EDIT OVER WRITE: Every rewrite risks losing context.
VERIFY EVERY CHANGE: Don't assume edit succeeded - read and confirm.
PRESERVE STRENGTHS: Improvements that break working features are not improvements.
VERSION MATTERS: Unversioned changes cause confusion.
</critical>
