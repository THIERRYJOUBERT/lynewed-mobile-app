# Step 06: Critique

> Purpose: Rigorous self-critique of generated workflow via checklist and adversarial review.

---

## MANDATORY RULES (READ FIRST)

- 📚 JIT LOAD: Load `references/quality-criteria.md` at START of this step
- ✅ Complete FULL checklist before adversarial review
- 🔄 Fix issues immediately, then re-verify
- ⚠️ Max 3 correction iterations - document remaining issues

## PROTOCOLS

- 🎯 **Goal**: Ensure workflow quality through systematic critique
- 💾 **Output**: `{critique_results}` with issues found and resolutions
- 📖 **Reference**: `references/quality-criteria.md` (loaded JIT)
- ⚡ **Performance**: Thorough now saves debugging later

---

## CONTEXT

**Available from previous steps:**
- `{design}` - Approved design document (step-03)
- `{generated_files}` - List of created files (step-05)
- `{target_path}` - Root path of workflow

**Produced by this step:**
- `{critique_results}` - Complete critique report

**NOT available (do not use):**
- `{validation_report}` - Not yet created (step-07)

---

## TASK

Perform rigorous self-critique in two phases:
1. Systematic checklist evaluation
2. Adversarial review with role switch

---

## EXECUTION

### JIT Loading

**CRITICAL**: Load quality criteria NOW (not earlier).

```
Read .claude/skills/create-workflow/references/quality-criteria.md
```

This file contains the complete checklist with ~26 criteria across 5 categories.

---

## PHASE 1: SYSTEMATIC CHECKLIST

Evaluate EVERY criterion. Mark PASS/FAIL with notes.

### Category 1: Alignment (5 criteria)

| # | Criterion | Check | Status | Notes |
|---|-----------|-------|--------|-------|
| A1 | Solves original problem | Does workflow address `{interview_data.objective}`? | PASS/FAIL | |
| A2 | Correct type | Is `{design.workflow_type}` the right choice? | PASS/FAIL | |
| A3 | Clear description | Is description triggering and accurate? | PASS/FAIL | |
| A4 | Correct invocation | Matches user need (user/model/both)? | PASS/FAIL | |
| A5 | Scope appropriate | Not too broad, not too narrow? | PASS/FAIL | |

### Category 2: Technical Quality (7 criteria)

| # | Criterion | Check | Status | Notes |
|---|-----------|-------|--------|-------|
| T1 | SKILL.md < 500 lines | Count lines in SKILL.md | PASS/FAIL | |
| T2 | CC features justified | Each feature has clear justification? | PASS/FAIL | |
| T3 | No placeholders | Search for TBD, TODO, "...", etc. | PASS/FAIL | |
| T4 | Templates usable | Templates work immediately? | PASS/FAIL | |
| T5 | YAML valid | All frontmatters parse correctly? | PASS/FAIL | |
| T6 | Markdown well-formed | Headers, lists, code blocks correct? | PASS/FAIL | |
| T7 | Internal links valid | All step/reference links exist? | PASS/FAIL | |

### Category 3: Robustness (5 criteria)

| # | Criterion | Check | Status | Notes |
|---|-----------|-------|--------|-------|
| R1 | Fallbacks defined | Each step has failure handling? | PASS/FAIL | |
| R2 | Validation in steps | Steps have AUTO-VALIDATION sections? | PASS/FAIL | |
| R3 | Edge cases covered | Common edge cases handled? | PASS/FAIL | |
| R4 | Error messages clear | Failure modes have clear messages? | PASS/FAIL | |
| R5 | Recovery possible | Can recover from common errors? | PASS/FAIL | |

### Category 4: Coherence (5 criteria)

| # | Criterion | Check | Status | Notes |
|---|-----------|-------|--------|-------|
| C1 | Aligned with CLAUDE.md | Follows project conventions? | PASS/FAIL | |
| C2 | Matches existing patterns | Consistent with other workflows? | PASS/FAIL | |
| C3 | Consistent naming | kebab-case, clear names? | PASS/FAIL | |
| C4 | Terminology consistent | Same terms throughout? | PASS/FAIL | |
| C5 | Style consistent | Same formatting patterns? | PASS/FAIL | |

### Category 5: Maintainability (4 criteria)

| # | Criterion | Check | Status | Notes |
|---|-----------|-------|--------|-------|
| M1 | Self-documenting | Can understand without external docs? | PASS/FAIL | |
| M2 | Modular structure | Changes isolated to single files? | PASS/FAIL | |
| M3 | Clear dependencies | Step dependencies explicit? | PASS/FAIL | |
| M4 | Version noted | manifest.yaml has version? | PASS/FAIL | |

---

## PHASE 2: ADVERSARIAL REVIEW

**Role Switch**: Become a Senior Reviewer whose ONLY goal is to FIND PROBLEMS.

### Mental Shift

```
Previous role: Creator (wants workflow to succeed)
New role: Critic (wants to find flaws)

I am now looking for:
- Hidden bugs
- Edge cases that will fail
- Confusing instructions
- Missing information
- Over-engineering
- Under-engineering
```

### Adversarial Questions

Answer each question honestly:

**Q1: What could go wrong?**
```
Think through execution:
- Step 1 could fail if...
- Step 2 could fail if...
- User could cause failure by...
```

**Q2: How could a user misuse this?**
```
Consider:
- Wrong arguments
- Unexpected input
- Running at wrong time
- Misunderstanding purpose
```

**Q3: What's the most obvious weakness?**
```
The weakest part is: ___
Because: ___
To fix it: ___
```

**Q4: Is there over-engineering?**
```
Check for:
- Unused features
- Unnecessary complexity
- Steps that could be merged
- Excessive validation
```

**Q5: Is there under-engineering?**
```
Check for:
- Missing validation
- No error handling
- Gaps in flow
- Assumptions not checked
```

**Q6: Could another Claude instance execute this unambiguously?**
```
Simulate fresh context:
- Are instructions clear?
- Are all variables defined?
- Are transitions explicit?
- Is anything assumed but not stated?
```

---

## PHASE 3: CORRECTIVE ITERATIONS

**If problems found:**

```
FOR each issue found:
    1. Identify the file(s) affected
    2. Determine the fix
    3. Apply the fix (Edit tool)
    4. Re-verify the specific criterion

REPEAT until:
    - All issues resolved, OR
    - Max 3 iterations reached
```

**Iteration tracking:**

```yaml
iteration_1:
  issues_found: N
  issues_fixed: N
  remaining: N

iteration_2:
  issues_found: N
  issues_fixed: N
  remaining: N

iteration_3:
  issues_found: N
  issues_fixed: N
  remaining: N
```

**After 3 iterations:**
If issues persist:
1. Document remaining issues clearly
2. Add warnings to output
3. Proceed to step-07 anyway
4. Flag for user awareness

---

## OUTPUT STRUCTURE

Compile complete critique results:

```yaml
critique_results:
  checklist:
    alignment:
      pass: N
      fail: N
      issues:
        - criterion: "A1"
          issue: "Description"
          resolution: "How it was fixed"

    technical:
      pass: N
      fail: N
      issues: [...]

    robustness:
      pass: N
      fail: N
      issues: [...]

    coherence:
      pass: N
      fail: N
      issues: [...]

    maintainability:
      pass: N
      fail: N
      issues: [...]

  adversarial:
    questions_answered:
      q1_failures: ["Potential failure 1", ...]
      q2_misuse: ["Misuse scenario 1", ...]
      q3_weakness: "The weakest part is..."
      q4_over_engineering: "Found: X" | "None found"
      q5_under_engineering: "Found: X" | "None found"
      q6_clarity: "Issues: X" | "Clear"
    issues_found:
      - issue: "Description"
        severity: "critical" | "major" | "minor"
        resolution: "How it was fixed"

  iterations:
    count: N  # 1-3
    history: [...]

  remaining_issues:
    - issue: "Description"
      severity: "..."
      reason_unresolved: "Why it couldn't be fixed"
    # OR null if all resolved

  summary:
    total_criteria: 26
    passed: N
    failed: N
    fixed: N
    remaining: N
    quality_score: "X/26"
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ All 26 checklist criteria evaluated
✅ All 6 adversarial questions answered
✅ Issues either fixed or documented
✅ No critical issues remaining unresolved

**Self-Critique of Critique:**
- Did I actually try to find problems, or just confirm success?
- Did I check real edge cases?
- Was I honest about weaknesses?
- Did each fix actually resolve the issue?

**If validation fails:**
1. Review skipped criteria
2. Answer unanswered questions
3. If genuinely blocked: Document and proceed

---

## SUCCESS / FAILURE

**Success:**
✅ Complete `{critique_results}` with all evaluations
✅ All critical issues resolved
✅ Remaining issues (if any) are documented and minor
✅ Quality score is acceptable (>20/26)

**Failure modes:**
❌ Critical issue cannot be fixed → Return to step-05 with feedback
❌ Fundamental design flaw → Return to step-03 with feedback
❌ Too many issues → Consider if workflow is viable

---

## NEXT

After validation passes, load `steps/step-07-validate.md`

<critical>
The adversarial review is NOT optional.
If you find 0 problems, you're not looking hard enough.
Role switch must be genuine - actively try to break the workflow.
Finding problems now prevents user frustration later.
</critical>
