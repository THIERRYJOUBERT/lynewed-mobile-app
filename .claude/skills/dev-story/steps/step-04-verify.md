---
name: step-04-verify
description: "Validation finale technique et fonctionnelle"
prev_step: steps/step-03-execute.md
next_step: steps/step-05-commit.md
---

# Step 04: Final Verification

## MANDATORY EXECUTION RULES (READ FIRST)

- 🛑 NEVER proceed to commit with failing tests
- 🛑 NEVER proceed to commit with warnings
- 🛑 NEVER skip verification even if step-03 passed
- 🛑 NEVER repeat same fix approach without analysis (self-healing intelligent)
- ✅ ALWAYS run full test suite (not just modified tests)
- ✅ ALWAYS run {{LINT_CMD}}nfos
- ✅ ALWAYS verify no debug code remains
- ✅ ALWAYS verify all acceptance criteria are satisfied
- ✅ ALWAYS check git status for unexpected files
- 📋 YOU ARE a QA Engineer doing final acceptance testing
- 💬 FOCUS on ensuring production readiness before commit
- 🚫 FORBIDDEN: Committing with known issues

## EXECUTION PROTOCOLS

- 🎯 **Goal**: Confirm story implementation is production-ready
- 💾 **Output**: `{validation_status}` = PASS or FAIL
- 📖 **Reference**: Pattern #8 (Fallback Strategies)
- ⚡ **Performance**: Self-healing with max 5 attempts if issues found

## CONTEXT BOUNDARIES

**Available from previous steps:**
- `{story_id}` - Story implemented, from step-00
- `{story_content}` - Story with criteria, from step-00
- `{implementation_plan}` - What was planned, from step-02
- `{code_written}` - Files created/modified, from step-03
- `{tests_written}` - Test files created, from step-03
- `{review_results}` - Review outcome, from step-03

**Produced by this step:**
- `{validation_status}` - PASS or FAIL
- `{issues_found}` - Any remaining issues (if FAIL)

**NOT available (do not use):**
- `{commit_hash}` - Produced in step-05

## YOUR TASK

Perform final verification to confirm the story implementation is production-ready and all acceptance criteria are satisfied.

---

## EXECUTION SEQUENCE

### 1. Run Full Test Suite

Execute all project tests, not just the ones for this story.

```bash
{{TEST_CMD}}
```

**Expected**: ALL tests pass (0 failures)

**If tests fail:**
```
Self-healing loop:
1. Identify failing test
2. Analyze: Is it a regression? New bug? Flaky test?
3. Fix based on analysis
4. Re-run tests
5. Max 5 attempts with DIFFERENT approaches each time
```

**Output**: Test status

### 2. Run Static Analysis

Execute {{LINT_CMD}}ngs.

```bash
{{LINT_CMD}}nfos
```

**Expected**: 0 issues (no errors, warnings, or infos)

**If issues found:**
```
For each issue:
1. Read the message carefully
2. Fix the actual problem (not just suppress)
3. If suppression needed: Add comment explaining why
```

**Common fixes:**
- Unused imports → Remove
- Missing await → Add await
- Deprecated API → Update to new API
- Unused variables → Remove or use

**Output**: Analyze status

### 3. Check for Debug Code

Search for debug artifacts that shouldn't be committed.

**Patterns to find:**
```bash
# Search for common debug patterns in modified files
grep -r "print(" lib/ --include="*.dart"
grep -r "debugPrint" lib/ --include="*.dart"
grep -r "TODO" lib/ --include="*.dart"
grep -r "FIXME" lib/ --include="*.dart"
```

**If found:**
- Remove print statements
- Resolve or document TODOs
- Fix FIXMEs

**Output**: Debug code check status

### 4. Verify Acceptance Criteria Satisfaction

**CRITICAL**: Verify EACH criterion from the story is implemented.

For each criterion in `{story_content}.acceptance_criteria`:

| Criterion | Gherkin | Implemented | Test Exists |
|-----------|---------|-------------|-------------|
| AC1 | Given... When... Then... | ✅/❌ | ✅/❌ |
| AC2 | ... | ✅/❌ | ✅/❌ |

**Mental test per criterion:**
> "If I execute the Gherkin scenario, does the implementation satisfy it?"

**If criterion not satisfied:**
- Return to step-03 for that criterion
- Implement missing behavior
- Re-verify

**Output**: Criteria satisfaction status

### 5. Verify Clean Git Status

Check what will be committed.

```bash
git status
git diff --staged
```

**Verify:**
- Only expected files are changed
- No unintended files (credentials, local config, etc.)
- No large binary files accidentally added
- Changes match what was planned

**If unexpected files:**
- Remove from staging
- Add to .gitignore if needed

### 6. Final Checklist

```markdown
## VERIFICATION FINALE - Story: {story_id}

### Tests
- [ ] {{TEST_CMD}}: PASS (0 failures)
- [ ] All new tests run successfully
- [ ] No regression in existing tests

### Analyse
- [ ] {{LINT_CMD}}
- [ ] No errors, warnings, or infos

### Code Quality
- [ ] No print/debugPrint statements
- [ ] No TODO/FIXME without justification
- [ ] No commented-out code

### Acceptance Criteria
- [ ] AC1: Implemented and tested
- [ ] AC2: Implemented and tested
- [ ] ... (all criteria)
- [ ] No scope creep (no extra features)

### Git
- [ ] Only expected files staged
- [ ] No secrets or credentials
- [ ] Ready for commit

### STATUS: PASS | FAIL
```

### 7. Handle Failures (Self-Healing)

If any check fails:

```
TENTATIVE N: [Check] echoue
     |
     v
ANALYSER: Pourquoi ? Quelle est la cause racine ?
     |
     v
AJUSTER: Nouvelle approche (DIFFERENTE de la precedente)
     |
     v
CORRIGER: Appliquer le fix
     |
     v
RE-VERIFIER: Re-run all checks

Max 5 tentatives, puis escalader.
```

**Regle d'or:** Chaque tentative doit APPRENDRE de la precedente.

**If max attempts reached:**
- Document all 5 attempts
- Explain why each failed
- Escalate with detailed report

---

## AUTO-VALIDATION (APEX SELF-CRITIQUE)

**Before proceeding to next step, validate:**

✅ `{{TEST_CMD}}` passes with 0 failures
✅ `{{LINT_CMD}}nfos` passes with 0 issues
✅ No debug code (print, TODO, FIXME)
✅ ALL acceptance criteria satisfied
✅ Git status shows only expected changes
✅ Final checklist all items checked
✅ `{validation_status}` = PASS

**Self-Critique Questions:**
- Did all tests pass, or did I just run the new ones?
- Did I actually fix analyze issues or just ignore them?
- Is EVERY acceptance criterion from the story satisfied?
- Would I be comfortable shipping this to production?

**If validation fails:**
1. Identify which check failed
2. Analyze root cause (not just symptoms)
3. Fix with new approach
4. Max 5 attempts total
5. Si echec persistant: Escalate, do NOT proceed to commit

---

## SUCCESS METRICS

✅ All tests pass (0 failures)
✅ All analyze passes (0 issues)
✅ No debug artifacts
✅ All acceptance criteria satisfied
✅ Clean git status
✅ `{validation_status}` = PASS
✅ Ready for commit

## FAILURE MODES

❌ Tests fail after 5 attempts → Escalate: Cannot commit failing tests
❌ Analyze issues persist → Escalate: Document and ask for guidance
❌ Debug code can't be removed → Fallback: Add justification comment
❌ Criterion not satisfied → Return to step-03 for more implementation
❌ Unexpected files in git → Fallback: Unstage and .gitignore
❌ Overall verification fails → Do NOT proceed to commit

## NEXT STEP

After all checks pass (`{validation_status}` = PASS), load `steps/step-05-commit.md`

<critical>
NEVER commit with:
- Failing tests
- Analyze warnings
- Debug code
- Unsatisfied acceptance criteria

If verification fails, FIX IT or ESCALATE.
Do NOT proceed to commit with known issues.
Self-healing must learn from each failure.
Production quality is non-negotiable.
</critical>
