# Step 04: Validate and Update Tracking

> Purpose: Final validation of created stories and **COMPLETE UPDATE** of TRACKING.md.

---

## MANDATORY RULES (READ FIRST)

- ✅ VERIFY all story files exist and are complete
- 📊 **CRITICAL**: UPDATE TRACKING.md with FULL implementation (not generic template!)
- 📋 REPORT summary to user
- 🔍 CHECK for any remaining issues
- 🚫 NEVER use AskUserQuestion in auto mode

## PROTOCOLS

- 🎯 **Goal**: Complete validation and PROPER tracking update
- 💾 **Output**: Updated TRACKING.md with stories, deps, conflicts
- 📖 **Reference**: Epic's TRACKING.md file
- ⚡ **Performance**: Final quality gate

---

## CONTEXT

**Available from previous steps:**
- `{mode}` - interactive ou auto (from step-00)
- `{epic_id}` - Epic identifier (from step-00)
- `{epic_path}` - Path to Epic folder (from step-00)
- `{approved_stories}` - User-validated stories (from step-02)
- `{stories_created}` - Created story files (from step-03)
- `{file_conflicts}` - Detected conflicts (from step-02)
- `{generation_errors}` - Any creation errors (from step-03)

**Produced by this step:**
- `{validation_result}` - Final validation status
- Updated TRACKING.md file with COMPLETE story data

---

## TASK

Validate all created stories and update Epic tracking with COMPLETE implementation.

---

## EXECUTION

### 1. Verify Created Files

For each story in `{stories_created}`:

```
Read {story.path}
```

**Check for:**
- File exists and is readable
- All required sections present
- No placeholder text ({{...}})
- Gherkin syntax valid
- Story points assigned
- Technical tasks listed

### 2. Run Validation Checklist

```yaml
validation_result:
  stories_validated: X
  stories_with_issues: Y
  issues:
    - story_id: "STORY-XX-02"
      issue: "Missing AC-2 Gherkin scenario"
      severity: "LOW"
      fix: "Can be added during implementation"
```

**Severity levels:**
- **CRITICAL**: Story cannot be implemented (missing AC, wrong format)
- **HIGH**: Major issue that should be fixed (incomplete tasks)
- **MEDIUM**: Quality concern (vague language)
- **LOW**: Polish item (minor formatting)

### 3. UPDATE TRACKING.md (CRITICAL - FULL IMPLEMENTATION)

**This is the most important task. DO NOT skip or use generic template.**

Locate TRACKING.md:
```
{epic_path}/TRACKING.md
```

#### 3.1 Read Current TRACKING.md

```
Read {epic_path}/TRACKING.md
```

Parse existing structure to understand:
- Current "Progression Stories" table format
- Existing timeline entries
- Any existing stories (should be "Todo" status from /create-epic)

#### 3.2 Update Stories Table

**Find the "Progression Stories" section and MERGE new stories:**

```markdown
## Progression Stories

| Story | Status | Assignee | Date Start | Date Done | Points |
|-------|--------|----------|------------|-----------|--------|
| STORY-XX-01 | 🔵 Todo | - | - | - | {pts} |
| STORY-XX-02 | 🔵 Todo | - | - | - | {pts} |
| STORY-XX-03 | 🔵 Todo | - | - | - | {pts} |
... (for each story in {stories_created})

**Total**: {sum_of_points} points
**Created**: {current_date}
```

**IMPORTANT**:
- Use ACTUAL story IDs from {stories_created}
- Use ACTUAL points from each story
- Calculate REAL total points

#### 3.3 Add Story Dependencies Section

**Add or update "Story Dependencies" section:**

```markdown
## Story Dependencies

### Dependency Graph

```mermaid
graph TD
    subgraph Phase1[Phase 1 - Foundation]
        S01[STORY-XX-01<br/>"{title}"]
    end
    subgraph Phase2[Phase 2 - Core]
        S02[STORY-XX-02<br/>"{title}"]
        S03[STORY-XX-03<br/>"{title}"]
    end
    S01 --> S02
    S01 --> S03
```

### Execution Order

| Order | Story | Depends On | Rationale |
|-------|-------|------------|-----------|
| 1 | STORY-XX-01 | - | Foundation, no deps |
| 2 | STORY-XX-02 | STORY-XX-01 | Needs X from story 01 |
| 3 | STORY-XX-03 | STORY-XX-01 | Can run parallel with 02 |
```

**IMPORTANT**:
- Analyze ACTUAL dependencies between stories
- Group by logical phases
- Suggest execution order

#### 3.4 Add File Conflicts Section (if any)

**If {file_conflicts} is not empty, add:**

```markdown
## File Conflicts

⚠️ The following files are modified by multiple stories:

| File | Stories | Conflict Type | Resolution |
|------|---------|---------------|------------|
| lib/features/x.dart | 01, 02 | Both modify | Sequential execution |
| test/x_test.dart | 02, 03 | Both create | Merge tests |

**Recommended**: Execute conflicting stories sequentially in the order shown.
```

#### 3.5 Update Timeline

**Add entry to Timeline section:**

```markdown
## Timeline

| Date | Evenement |
|------|-----------|
| {original_date} | Epic cree avec /create-epic v6 |
| {current_date} | Stories creees ({count}) avec /create-story |
```

#### 3.6 Perform the Edit

Use the Edit tool to update TRACKING.md with ALL of the above changes.

**Validation**: After edit, verify:
- [ ] Stories table has ALL new stories
- [ ] Points are correct and totaled
- [ ] Dependencies section exists with graph
- [ ] Execution order is documented
- [ ] File conflicts documented (if any)
- [ ] Timeline updated

### 4. Generate Summary

Prepare final summary for user:

```markdown
## /create-story Complete

**Epic**: {epic_id}
**Mode**: {mode}
**Stories Created**: {count}
**Total Points**: {total_points}

### Stories

| ID | Titre | Points | Dependencies |
|----|-------|--------|--------------|
| STORY-XX-01 | {title} | {pts} | - |
| STORY-XX-02 | {title} | {pts} | STORY-XX-01 |
| ... | ... | ... | ... |

### Recommended Execution Order

1. **Phase 1**: STORY-XX-01 (foundation)
2. **Phase 2**: STORY-XX-02, STORY-XX-03 (can parallel)
3. **Phase 3**: STORY-XX-04 (depends on 02+03)

### Conflicts Documented

{list of conflicts and resolutions, or "None detected"}

### TRACKING.md Updated

✅ Stories table with {count} stories
✅ Dependencies graph added
✅ Execution order documented
✅ Timeline updated

### Next Steps

- Review stories in `{epic_path}/stories/`
- Start implementation: `/dev-story STORY-XX-01`
- Track progress in TRACKING.md

### Issues (if any)

{list of validation issues, or "None"}
```

### 5. Present Summary

Display the summary to user. Step is complete.

---

## AUTO-VALIDATION

**Before completing, validate:**
✅ All story files verified and complete
✅ TRACKING.md updated with:
   - [ ] Stories table (all stories, correct points)
   - [ ] Dependencies section (graph + order)
   - [ ] File conflicts (if any)
   - [ ] Timeline entry
✅ Summary prepared

**Self-Critique Questions:**
- Did I verify EVERY created file?
- Did I update TRACKING.md with REAL data (not placeholders)?
- Are the dependencies ACTUALLY analyzed?
- Is the execution order LOGICAL?
- Did I calculate the REAL total points?

**If validation fails:**
1. Fix minor issues inline
2. Document unfixable issues
3. Present summary with caveats

---

## SUCCESS / FAILURE

**Success:**
✅ All stories validated
✅ TRACKING.md fully updated with real data
✅ Summary presented to user

**Failure modes:**
❌ TRACKING.md not found → Create minimal tracking section
❌ Validation issues found → Document in summary, continue
❌ Files corrupted → Report error, suggest manual check
❌ Cannot update tracking → Present summary, note issue

## PROCEED TO FINALIZATION

After this step, proceed to inline Step 05 (Finalization):

**IF mode = INTERACTIVE:**
- Use AskUserQuestion to propose sync

**IF mode = AUTO:**
- Execute /sync-project --silent automatically
- Display final summary

<critical>
The TRACKING.md update is the MOST IMPORTANT part of this step.
Generic templates are FORBIDDEN - use ACTUAL story data.
Stories MUST appear in the tracking table for /dev-story to work properly.
Without proper tracking, the workflow chain breaks.
</critical>
