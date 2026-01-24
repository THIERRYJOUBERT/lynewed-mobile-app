---
name: step-05-commit
description: "Finalisation et commit via /commit skill"
prev_step: steps/step-04-verify.md
next_step: null
---

# Step 05: Commit & Finalization

## MANDATORY EXECUTION RULES (READ FIRST)

- 🛑 NEVER commit without step-04 validation PASS
- 🛑 NEVER bypass /commit skill (it has additional checks)
- 🛑 NEVER commit with generic message ("fix", "update", "changes")
- ✅ ALWAYS invoke /commit skill for finalization
- ✅ ALWAYS include "Oneshot:" prefix in commit message
- ✅ ALWAYS present final summary to user
- ✅ ALWAYS mark all remaining todos as complete
- 📋 YOU ARE completing a successful implementation
- 💬 FOCUS on clean finalization and clear communication
- 🚫 FORBIDDEN: Manual git commit (use /commit skill)

## EXECUTION PROTOCOLS

- 🎯 **Goal**: Create clean commit and present final summary
- 💾 **Output**: `{commit_hash}`, `{summary}` presented to user
- 📖 **Reference**: /commit skill integration
- ⚡ **Performance**: Single commit with descriptive message

## CONTEXT BOUNDARIES

**Available from previous steps:**
- `{description}` - What was implemented, from step-00
- `{mode}` - auto or supervised, from step-00
- `{complexity}` - S/M/L, from step-00
- `{session_file}` - Path to session documentation file, from step-00
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

Invoke /commit skill to create a clean commit, then present final summary to user.

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

### 2. Prepare Commit Message

Structure the commit message for /commit skill.

**Format:**
```
feat(scope): Oneshot - {description short}

{description detailed}

Implementation:
- {file1}: {what was done}
- {file2}: {what was done}

Tests:
- {test1}: {what is tested}

Oneshot: {original description}
```

**Example:**
```
feat(auth): Oneshot - Add logout button

Added a logout button to the settings screen that clears user session
and navigates to login.

Implementation:
- lib/features/settings/settings_screen.dart: Added logout button
- lib/services/auth_service.dart: Added logout method

Tests:
- test/features/settings/settings_screen_test.dart: Logout flow tests
- test/services/auth_service_test.dart: Logout method tests

Oneshot: Add logout button to settings
```

### 3. Invoke /commit Skill

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

### 4. Mark All Todos Complete

Ensure all tracking todos are marked done.

```yaml
TodoWrite:
  - content: "COMMIT: Finaliser via /commit"
    status: completed
    activeForm: "Finalisant via /commit"
```

### 5. Generate Final Summary

Create comprehensive summary for user.

**Summary structure:**

```markdown
## Oneshot Complete

### Objectif
{description}

### Mode
{mode} (supervised | auto)

### Complexite
{complexity} (S | M | L)

### Implementation

**Fichiers crees:**
- {new_file_1}
- {new_file_2}

**Fichiers modifies:**
- {modified_file_1}
- {modified_file_2}

**Tests ajoutes:**
- {test_file_1}
- {test_file_2}

### Qualite

| Check | Status |
|-------|--------|
| Tests | PASS |
| Analyze | 0 warnings |
| Review | APPROVE |

### Commit

- **Hash**: {commit_hash}
- **Message**: {commit_message_short}

### Prochaines Etapes (si applicable)

- [ ] Test manuel sur device/simulateur
- [ ] PR si travail sur branche
- [ ] Deploiement si pertinent
```

### 6. Present Summary to User

Display the final summary in the conversation.

**This is the final output the user sees.**

### 7. Update Session File - Result

**CRITICAL**: Finaliser le fichier de session avec le resultat.

**Update section "6. Result" in `{session_file}`:**

```markdown
## 6. Result

### Commit
- **Hash**: {commit_hash}
- **Message**: {commit_message_short}

### Resume Final

| Metrique | Valeur |
|----------|--------|
| Fichiers crees | {count} |
| Fichiers modifies | {count} |
| Tests ajoutes | {count} |
| Problemes rencontres | {count} |
| Problemes resolus | {count} |

### Qualite

| Check | Status |
|-------|--------|
| Tests | PASS |
| Analyze | 0 warnings |
| Review | APPROVE |

### Prochaines Etapes (optionnel)
- [ ] Test manuel
- [ ] PR si sur branche
- [ ] Deploiement
```

**Also update Status checklist (all complete):**
```markdown
## Status

- [x] Exploration
- [x] Plan
- [x] Execution
- [x] Verification
- [x] Commit
```

**Fallback**: Si Edit echoue, mentionner dans le summary final.

---

## AUTO-VALIDATION (APEX SELF-CRITIQUE)

**Before completing workflow, validate:**

✅ `{validation_status}` was PASS from step-04
✅ /commit skill was invoked (not manual git commit)
✅ Commit was created successfully (`{commit_hash}` exists)
✅ All todos marked complete
✅ Final summary presented to user
✅ Summary includes all key information
✅ `{session_file}` section "6. Result" updated and Status all checked

**Self-Critique Questions:**
- Did /commit pass on first try, or were there issues?
- Is the commit message descriptive enough?
- Would the user understand what was done from the summary?
- Is there anything left undone?

**If validation fails:**
1. If /commit failed: Fix issue and retry
2. If commit didn't create: Check git status, retry
3. If summary incomplete: Add missing information
4. Max 3 attempts for commit

---

## SUCCESS METRICS

✅ /commit skill invoked successfully
✅ Commit created with proper message
✅ `{commit_hash}` captured
✅ All todos marked complete
✅ Final summary presented
✅ User informed of completion

## FAILURE MODES

❌ /commit fails verification → Fallback: Return to step-04, fix issues
❌ Git commit fails → Fallback: Check git status, resolve conflicts
❌ No changes to commit → Error: Something went wrong in step-03
❌ /commit times out → Fallback: Manual commit as last resort (document)

## WORKFLOW COMPLETE

This is the final step. After presenting the summary:

1. Workflow is complete
2. User can test the feature
3. User can create PR if on branch
4. User can continue with other tasks

<critical>
ALWAYS use /commit skill - it has additional safety checks.
NEVER commit with generic messages.
The summary is the user's confirmation of completion.
Include "Oneshot:" prefix to identify oneshot commits in git history.
Production quality maintained throughout.
</critical>
