# Workflow Quality Criteria

> Reference for evaluating workflow quality during critique and validation phases.
> Used by /create-workflow in Step-05 (Critique) and UPDATE mode assessment.
> Version: 3.0

---

## Overview

This document provides:
1. **Systematic Checklist** - 5 categories of validation criteria
2. **Adversarial Questions** - Challenge questions for review phase
3. **Scoring Guide** - Assessment framework for UPDATE mode
4. **Quick Validation** - 10-item fast check

---

## Systematic Checklist

### Category 1: Alignment (Does it solve the problem?)

| # | Criterion | How to verify | Severity |
|---|-----------|---------------|----------|
| 1.1 | Solves original problem | Compare stated objective vs implementation | CRITICAL |
| 1.2 | Correct content type | Reference vs Task matches actual content | CRITICAL |
| 1.3 | Clear description | Keywords match intended use cases | HIGH |
| 1.4 | Correct invocation mode | user-invocable / disable-model-invocation match intent | HIGH |
| 1.5 | Arguments handled | $ARGUMENTS used correctly if skill accepts input | MEDIUM |
| 1.6 | Output matches expectation | Generated artifacts are what user needs | HIGH |

**Verification questions**:
- Read the original objective. Does the workflow achieve it completely?
- Is the content type (Reference/Task) appropriate for what this does?
- Would Claude correctly identify when to use this based on description alone?
- Are there any user intentions not addressed?

**Example check**:
```markdown
# Checking criterion 1.1
Objective: "Create a workflow for debugging Flutter apps"
Implementation: Creates debug workflow with Flutter-specific commands
Result: ✅ PASS - Solves the stated problem
```

---

### Category 2: Technical Quality (Is it well-built?)

| # | Criterion | How to verify | Severity |
|---|-----------|---------------|----------|
| 2.1 | SKILL.md under 500 lines | Count lines in SKILL.md | HIGH |
| 2.2 | Features correctly used | Validate frontmatter syntax and values | CRITICAL |
| 2.3 | No placeholders | Search for "TBD", "TODO", "...", "[insert]" | CRITICAL |
| 2.4 | Templates complete | Each template usable as-is without edits | HIGH |
| 2.5 | Steps have clear roles | Each step has distinct, documented purpose | HIGH |
| 2.6 | Valid YAML frontmatter | Parse YAML without errors | CRITICAL |
| 2.7 | Markdown well-formed | No broken links, proper formatting | MEDIUM |
| 2.8 | File paths valid | All referenced files exist or are created | HIGH |

**Verification questions**:
- Can I copy any template and use it immediately without modification?
- Is each step's purpose immediately clear from its name and content?
- Are there any syntax errors that would cause runtime failures?
- Do all internal links point to valid locations?

**Example check**:
```markdown
# Checking criterion 2.3
Search results for placeholders:
- "TBD": 0 occurrences
- "TODO": 0 occurrences
- "...": 2 occurrences (both in code examples, valid)
- "[insert": 0 occurrences
Result: ✅ PASS - No placeholder text
```

---

### Category 3: Robustness (Will it handle errors?)

| # | Criterion | How to verify | Severity |
|---|-----------|---------------|----------|
| 3.1 | Fallbacks defined | Each potential failure has documented fallback | HIGH |
| 3.2 | Auto-validation in steps | Each step has validation section | HIGH |
| 3.3 | Edge cases considered | List potential edge cases, check coverage | MEDIUM |
| 3.4 | Self-healing defined | Max attempts + learning documented | MEDIUM |
| 3.5 | Escalation path | Clear action when all fallbacks fail | HIGH |
| 3.6 | Graceful degradation | Partial success possible when full success fails | MEDIUM |

**Verification questions**:
- What happens if step 2 fails? Is there a documented response?
- Are there inputs that could break this workflow?
- What's the worst-case scenario, and how is it handled?
- Can the workflow produce partial value if it can't complete fully?

**Example check**:
```markdown
# Checking criterion 3.1
Step-02 (Design):
- If exploration agents fail: ✅ Fallback to direct file reading
- If no patterns match: ✅ Fallback to basic structure
- If user input invalid: ✅ Re-prompt with clarification
Result: ✅ PASS - Fallbacks defined for key failures
```

---

### Category 4: Coherence (Does it fit the ecosystem?)

| # | Criterion | How to verify | Severity |
|---|-----------|---------------|----------|
| 4.1 | Aligned with CLAUDE.md | No contradictions with project rules | HIGH |
| 4.2 | Follows established patterns | Uses patterns from patterns-unified.md | MEDIUM |
| 4.3 | Consistent naming | Follows project naming conventions | MEDIUM |
| 4.4 | No duplication | No existing workflow does the same thing | MEDIUM |
| 4.5 | References correct | All paths and links are valid | HIGH |
| 4.6 | Style consistent | Formatting matches project standards | LOW |

**Verification questions**:
- Does this workflow contradict any rule in CLAUDE.md or .claude/rules/?
- Is the naming consistent with other workflows in the project?
- Does another workflow already accomplish this purpose?
- Are all file references using correct relative paths?

**Example check**:
```markdown
# Checking criterion 4.4
Existing workflows in .claude/skills/:
- /dev-story: Story implementation
- /debug: Bug investigation
- /commit: Git commits
- /create-workflow: Creating workflows (THIS ONE - updating)
New workflow: /create-workflow v3
Result: ✅ PASS - Updating existing, not duplicating
```

---

### Category 5: Maintainability (Can it be updated easily?)

| # | Criterion | How to verify | Severity |
|---|-----------|---------------|----------|
| 5.1 | Clear structure | Files organized logically, navigation obvious | MEDIUM |
| 5.2 | Documented decisions | Why choices were made is recorded | MEDIUM |
| 5.3 | Modular design | Can change one part without breaking others | MEDIUM |
| 5.4 | No hardcoded values | Paths, names use variables where appropriate | LOW |
| 5.5 | Comments where needed | Complex logic has explanatory comments | LOW |

**Verification questions**:
- Could another developer modify this workflow without asking the creator?
- Is it clear why each design decision was made?
- Can one step be changed without affecting unrelated steps?

---

## Adversarial Review Questions

### Functional Adversarial

**Question 1: What could go wrong?**
```markdown
List the 3 most likely failure scenarios:
1. [Scenario]: [Mitigation present? Y/N]
2. [Scenario]: [Mitigation present? Y/N]
3. [Scenario]: [Mitigation present? Y/N]

If any mitigation is missing, this is a finding.
```

**Question 2: How could a user misuse it?**
```markdown
Consider:
- Wrong arguments (typos, wrong format)
- Wrong context (running in unexpected project state)
- Unexpected expectations (user thinks it does more/less)
- Malicious intent (could this cause harm if misused?)
```

**Question 3: What's the most obvious weakness?**
```markdown
"If I had to break this workflow, where would I attack?"
- Input validation?
- Error handling?
- Assumptions about environment?
- Dependencies on external state?
```

### Design Adversarial

**Question 4: Is there over-engineering?**
```markdown
Check for:
- Features that aren't needed for the stated purpose
- Complexity without clear benefit
- Steps that could be merged
- Abstractions that add overhead without value
```

**Question 5: Is there under-engineering?**
```markdown
Check for:
- Missing validation that should exist
- Edge cases not handled
- Assumptions that might break in production
- Security considerations ignored
```

**Question 6: Could another agent execute this unambiguously?**
```markdown
For each step, ask:
- Is there ANY ambiguity in the instructions?
- Are all terms defined clearly?
- Is the expected output format specified?
- Are decision criteria explicit?
```

### Comparison Adversarial

**Question 7: Is this the simplest solution?**
```markdown
- Could the same outcome be achieved with less complexity?
- Is every step necessary?
- Is the complexity justified by the requirements?
```

**Question 8: Does it follow the patterns?**
```markdown
Cross-reference with patterns-unified.md:
- Which required patterns are applied? ✅
- Which required patterns are missing? ❌
- For each missing pattern: Is this intentional? Why?
```

---

## Scoring Guide

### Severity Definitions

| Level | Meaning | Action Required |
|-------|---------|-----------------|
| CRITICAL | Workflow will not function correctly | Must fix before completion |
| HIGH | Workflow will have significant issues | Should fix, document if not |
| MEDIUM | Quality concern, not blocking | Consider fixing |
| LOW | Polish item, nice to have | Optional fix |

### Issue Counting

After running the checklist:
```markdown
## Issue Summary

| Severity | Count | Items |
|----------|-------|-------|
| CRITICAL | 0 | - |
| HIGH | 2 | 2.8, 3.5 |
| MEDIUM | 1 | 4.3 |
| LOW | 0 | - |
```

### Overall Score Interpretation

| CRITICAL | HIGH | Assessment | Recommendation |
|----------|------|------------|----------------|
| 0 | 0 | Excellent | Minor polish only |
| 0 | 1-2 | Good | Fix high issues |
| 0 | 3+ | Needs work | Prioritize fixes |
| 1+ | any | Blocked | Fix critical first |

### Decision Matrix

| Score | For CREATE mode | For UPDATE mode |
|-------|-----------------|-----------------|
| 0 CRITICAL, 0-1 HIGH | Proceed to finalize | Minor update recommended |
| 0 CRITICAL, 2-3 HIGH | Fix before proceeding | Update recommended |
| 1+ CRITICAL | Cannot proceed | Major update required |

---

## Quick Validation Checklist

For fast validation, check these 10 critical items:

```markdown
## Quick Validation (10 items)

□ 1. Solves original problem (1.1)
□ 2. Correct content type (1.2)
□ 3. SKILL.md < 500 lines (2.1)
□ 4. No placeholders (2.3)
□ 5. Valid YAML frontmatter (2.6)
□ 6. Fallbacks defined (3.1)
□ 7. Auto-validation in steps (3.2)
□ 8. Aligned with CLAUDE.md (4.1)
□ 9. Clear structure (5.1)
□ 10. No obvious weakness (adversarial)

Score: __/10

Interpretation:
- 10/10: Ready for completion
- 8-9/10: Minor fixes needed
- 6-7/10: Review required
- <6/10: Major revision needed
```

---

## Iteration Protocol

When problems are found during validation:

```markdown
## ITERATION PROTOCOL

### Step 1: IDENTIFY
- What exactly is wrong?
- Which criterion failed?
- What is the severity?

### Step 2: FIX
- Apply specific correction
- Document what changed
- Update affected files

### Step 3: RE-VERIFY
- Check fix didn't break other criteria
- Run quick validation again
- Confirm issue resolved

### Step 4: ITERATE (max 3 times)
If still failing after 3 iterations:
- Document remaining issues
- Assess impact on usability
- Proceed with documented gaps OR
- Escalate for user decision
```

### Iteration Log Template

```markdown
## Iteration Log

### Iteration 1
- **Issue**: [Description]
- **Fix Applied**: [What changed]
- **Result**: [Resolved/Partially/Unresolved]

### Iteration 2
- **Issue**: [Description]
- **Fix Applied**: [What changed]
- **Result**: [Resolved/Partially/Unresolved]

### Final Status
- Issues resolved: X
- Issues remaining: Y
- Recommendation: [Proceed/Escalate]
```

---

## UPDATE Mode Assessment

When evaluating an existing workflow for updates:

### Initial Assessment Questions

```markdown
1. What is the current quality score? (Run quick validation)
2. What specific improvements are requested?
3. What patterns are missing that should be applied?
4. What is the effort vs benefit ratio?
```

### Update Recommendation Matrix

| Current Score | Requested Changes | Recommendation |
|---------------|-------------------|----------------|
| Good (8+/10) | Minor | Incremental update |
| Good (8+/10) | Major | Careful refactor |
| Medium (6-7/10) | Minor | Update + quality fixes |
| Medium (6-7/10) | Major | Consider rewrite |
| Poor (<6/10) | Any | Recommend rewrite |

### Update Scope Definition

```markdown
## Update Scope

**In Scope** (will be changed):
- [ ] Item 1
- [ ] Item 2

**Out of Scope** (will not change):
- [ ] Item 1
- [ ] Item 2

**Quality Improvements** (bonus):
- [ ] Item 1
- [ ] Item 2
```

---

## See Also

- [decision-matrix.md](decision-matrix.md) - WHEN to use features
- [features-guide.md](features-guide.md) - Claude Code features
- [patterns-unified.md](patterns-unified.md) - Best practices and patterns
