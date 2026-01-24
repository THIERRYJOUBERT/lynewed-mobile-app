---
name: step-05-commit
description: "Finalisation, update story status, et commit via /commit"
prev_step: steps/step-04-verify.md
next_step: null
---

# Step 05: Commit & Story Finalization

## MANDATORY EXECUTION RULES (READ FIRST)

- 🛑 NEVER commit without step-04 validation PASS
- 🛑 NEVER bypass /commit skill (it has additional checks)
- 🛑 NEVER commit with generic message ("fix", "update", "changes")
- 🛑 NEVER forget to update story status
- 🛑 NEVER forget to update TRACKING.md
- ✅ ALWAYS update story status to "Done" before commit
- ✅ ALWAYS update TRACKING.md with story completion
- ✅ ALWAYS invoke /commit skill for finalization
- ✅ ALWAYS include story reference in commit message
- ✅ ALWAYS present final summary to user
- 📋 YOU ARE completing a successful story implementation
- 💬 FOCUS on proper closure and documentation
- 🚫 FORBIDDEN: Manual git commit (use /commit skill)

## EXECUTION PROTOCOLS

- 🎯 **Goal**: Update story status, TRACKING.md, create commit, present summary
- 💾 **Output**: `{commit_hash}`, `{summary}` presented to user
- 📖 **Reference**: /commit skill integration
- ⚡ **Performance**: Story tracking update + single commit

## CONTEXT BOUNDARIES

**Available from previous steps:**
- `{story_id}` - Story implemented, from step-00
- `{mode}` - auto or supervised, from step-00
- `{story_path}` - Path to story file, from step-00
- `{story_content}` - Story with criteria, from step-00
- `{epic_path}` - Path to Epic folder, from step-00
- `{code_written}` - Files created/modified, from step-03
- `{tests_written}` - Test files created, from step-03
- `{review_results}` - Review outcome, from step-03
- `{validation_status}` - MUST be PASS, from step-04

**Produced by this step:**
- `{commit_hash}` - Hash of the created commit
- `{summary}` - Final summary presented to user

**NOT available (do not use):**
- All needed variables are available

## YOUR TASK

Update story status, update TRACKING.md, invoke /commit skill, and present final summary.

---

## EXECUTION SEQUENCE

### 1. Verify Prerequisites

Confirm step-04 completed successfully.

**Check:**
```yaml
validation_status: PASS  # REQUIRED
```

**If validation_status != PASS:**
- Do NOT proceed
- Return to step-04
- Or escalate if stuck

### 2. Update Story Status

Edit the story file to mark as Done.

**Update `{story_path}`:**
```markdown
## Status
- [x] Done  ← Change from "[ ] To Do" or "[ ] In Progress"
```

**Add implementation notes:**
```markdown
## Implementation Notes
- **Date**: {current_date}
- **Commit**: {will be added after commit}
- **Notes**: Implementation summary

### Files Created
- {list from code_written}

### Files Modified
- {list from code_written}

### Tests Added
- {list from tests_written}
```

### 3. Update TRACKING.md

Update the Epic's TRACKING.md file.

**Find and update `{epic_path}/TRACKING.md`:**

```markdown
## Stories Progress

| Story | Status | Date |
|-------|--------|------|
| {story_id} | ✅ Done | {date} |  ← Update this row
```

**Add to Recent Activity:**
```markdown
## Recent Activity

- {date}: {story_id} completed - [brief description]
```

**Mark todo complete: "UPDATE: Story status + TRACKING.md"**

### 4. Prepare Commit Message

Structure the commit message for /commit skill.

**Format:**
```
feat(scope): {story_id} - {story_title_short}

Implemented story {story_id}: {story_title}

Acceptance Criteria:
- AC1: {brief} ✓
- AC2: {brief} ✓

Implementation:
- {file1}: {what was done}
- {file2}: {what was done}

Tests:
- {test1}: {what is tested}

Story: {story_id}
Epic: EPIC-{epic_number}
```

**Example:**
```
feat(training): STORY-01-03 - Add session timer

Implemented story STORY-01-03: Add real-time timer to training session

Acceptance Criteria:
- AC1: Timer displays elapsed time ✓
- AC2: Timer persists across pauses ✓

Implementation:
- lib/features/training/widgets/session_timer.dart: New timer widget
- lib/features/training/providers/timer_provider.dart: Timer state

Tests:
- test/features/training/session_timer_test.dart: Timer behavior tests

Story: STORY-01-03
Epic: EPIC-01-Training-Foundation
```

### 5. Invoke /commit Skill

**CRITICAL**: Use the Skill tool to invoke /commit.

```yaml
skill: commit
args: null  # /commit will auto-generate based on changes
```

**What /commit does:**
1. Verifies tests pass (re-check)
2. Verifies analyze passes (re-check)
3. Stages relevant files
4. Creates commit with Co-Authored-By
5. Returns commit hash

**If /commit fails:**
- Read the error message
- Fix the issue (usually test or analyze failure)
- Retry /commit
- Max 3 attempts

**Output**: `{commit_hash}` from /commit result

### 6. Update Story with Commit Hash

After commit success, update story file with commit reference.

**Edit `{story_path}`:**
```markdown
## Implementation Notes
- **Date**: {current_date}
- **Commit**: {commit_hash}  ← Add this
```

### 7. Mark All Todos Complete

Ensure all tracking todos are marked done.

```yaml
TodoWrite:
  - content: "COMMIT: Finaliser via /commit"
    status: completed
    activeForm: "Finalisant via /commit"
```

### 8. Generate Final Summary

Create comprehensive summary for user.

**Summary structure:**

```markdown
## Story Complete: {story_id}

### Story
**Titre**: {title}
**Epic**: EPIC-{number}

### Mode
{mode} (supervised | auto)

### Acceptance Criteria
| Criterion | Status |
|-----------|--------|
| AC1: {desc} | ✅ |
| AC2: {desc} | ✅ |

### Implementation

**Fichiers crees:**
- {new_file_1}
- {new_file_2}

**Fichiers modifies:**
- {modified_file_1}
- {modified_file_2}

**Tests ajoutes:**
- {test_file_1}

### Qualite

| Check | Status |
|-------|--------|
| Tests | PASS |
| Analyze | 0 warnings |
| Review | APPROVE |

### Tracking Updated
- ✅ Story status → Done
- ✅ TRACKING.md updated

### Commit
- **Hash**: {commit_hash}
- **Message**: {commit_message_short}

### Prochaines Etapes
- [ ] Test manuel sur device/simulateur
- [ ] Verifier l'Epic progress
- [ ] Implementer next story if any
```

### 9. Present Summary to User

Display the final summary in the conversation.

**This is the final output the user sees.**

---

## AUTO-VALIDATION (APEX SELF-CRITIQUE)

**Before completing workflow, validate:**

✅ `{validation_status}` was PASS from step-04
✅ Story status updated to "Done" in story file
✅ TRACKING.md updated with story completion
✅ /commit skill was invoked (not manual git commit)
✅ Commit was created successfully (`{commit_hash}` exists)
✅ Story file updated with commit hash
✅ All todos marked complete
✅ Final summary presented to user

**Self-Critique Questions:**
- Did I update BOTH the story file AND TRACKING.md?
- Did /commit pass on first try, or were there issues?
- Is the commit message descriptive with story reference?
- Would the user understand what was done from the summary?

**If validation fails:**
1. If story status not updated: Edit story file
2. If TRACKING.md not updated: Edit TRACKING.md
3. If /commit failed: Fix issue and retry
4. Max 3 attempts for commit

---

## SUCCESS METRICS

✅ Story status updated to "Done"
✅ TRACKING.md updated
✅ /commit skill invoked successfully
✅ Commit created with story reference
✅ `{commit_hash}` captured
✅ Story file has commit reference
✅ All todos marked complete
✅ Final summary presented

## FAILURE MODES

❌ /commit fails verification → Fallback: Return to step-04, fix issues
❌ Story file can't be updated → Fallback: Manual update, note in summary
❌ TRACKING.md not found → Fallback: Skip tracking update, warn user
❌ Git commit fails → Fallback: Check git status, resolve conflicts
❌ No changes to commit → Error: Something went wrong in step-03

## WORKFLOW COMPLETE

This is the final step. After presenting the summary:

1. Story is marked "Done" in docs
2. TRACKING.md reflects completion
3. Commit exists with proper message
4. User can proceed to next story

<critical>
ALWAYS update story status AND TRACKING.md before commit.
ALWAYS use /commit skill - it has additional safety checks.
NEVER commit with generic messages - include story reference.
The summary is the user's confirmation of completion.
Story-driven development requires proper documentation closure.
</critical>
