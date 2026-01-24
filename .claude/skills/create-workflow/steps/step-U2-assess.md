# Step U2: Assess Workflow Quality

> Purpose: Evaluate workflow strengths and weaknesses using quality criteria to prioritize improvements.

---

## MANDATORY RULES (READ FIRST)

- 📊 Apply FULL quality criteria checklist (loaded in step-U1)
- ⚖️ Score EVERY category - no skipping
- 🎯 Identify SPECIFIC issues with evidence
- 📋 Prioritize by severity (CRITICAL → LOW)

## PROTOCOLS

- 🎯 **Goal**: Systematic quality assessment with actionable findings
- 💾 **Output**: `{assessment}` with scores, strengths, and weaknesses
- 📖 **Reference**: `{quality_baseline}` (loaded in step-U1)
- ⚡ **Performance**: Honest assessment prevents wasted improvement effort

---

## CONTEXT

**Available from previous steps:**
- `{existing_workflow}` - Complete workflow analysis (from step-U1)
- `{quality_baseline}` - Quality criteria reference (from step-U1)

**Produced by this step:**
- `{assessment}` - Complete quality assessment with priorities

**NOT available (do not use):**
- `{approved_improvements}` - Created in step-U3
- `{modifications}` - Created in step-U4

---

## TASK

Evaluate the existing workflow against quality criteria to:
1. Score each quality category
2. Identify top strengths (what to preserve)
3. Identify top weaknesses (what to improve)
4. Prioritize issues by severity
5. Determine update scope recommendation

---

## EXECUTION

### 1. Category Scoring

Apply quality criteria from `{quality_baseline}` to `{existing_workflow}`.

#### Category 1: Alignment (5 criteria, max 5 points)

| # | Criterion | Evidence | Score |
|---|-----------|----------|-------|
| A1 | Solves original problem | Does it achieve stated purpose? | 0/1 |
| A2 | Correct type | Reference vs Task appropriate? | 0/1 |
| A3 | Clear description | Keywords match use cases? | 0/1 |
| A4 | Correct invocation mode | user/model settings match intent? | 0/1 |
| A5 | Scope appropriate | Not too broad/narrow? | 0/1 |

**Subtotal**: _/5

**Notes on alignment:**
```
[Document specific observations about how well
the workflow aligns with its intended purpose]
```

---

#### Category 2: Technical Quality (7 criteria, max 7 points)

| # | Criterion | Evidence | Score |
|---|-----------|----------|-------|
| T1 | SKILL.md < 500 lines | Line count: ___ | 0/1 |
| T2 | CC features justified | Each feature has reason? | 0/1 |
| T3 | No placeholders | TBD, TODO, ... found? | 0/1 |
| T4 | Templates usable | Work immediately as-is? | 0/1 |
| T5 | YAML valid | Frontmatters parse? | 0/1 |
| T6 | Markdown well-formed | Format issues? | 0/1 |
| T7 | Internal links valid | All paths exist? | 0/1 |

**Subtotal**: _/7

**Notes on technical quality:**
```
[Document specific technical findings -
placeholder locations, format issues, etc.]
```

---

#### Category 3: Robustness (5 criteria, max 5 points)

| # | Criterion | Evidence | Score |
|---|-----------|----------|-------|
| R1 | Fallbacks defined | Failure handling exists? | 0/1 |
| R2 | Validation in steps | AUTO-VALIDATION sections? | 0/1 |
| R3 | Edge cases covered | Boundary handling? | 0/1 |
| R4 | Error messages clear | Helpful failure info? | 0/1 |
| R5 | Recovery possible | Self-healing defined? | 0/1 |

**Subtotal**: _/5

**Notes on robustness:**
```
[Document missing fallbacks, unclear error handling,
steps without validation, etc.]
```

---

#### Category 4: Coherence (5 criteria, max 5 points)

| # | Criterion | Evidence | Score |
|---|-----------|----------|-------|
| C1 | Aligned with CLAUDE.md | Follows project conventions? | 0/1 |
| C2 | Matches existing patterns | Consistent with other workflows? | 0/1 |
| C3 | Consistent naming | kebab-case, clear names? | 0/1 |
| C4 | Terminology consistent | Same terms throughout? | 0/1 |
| C5 | Style consistent | Same formatting patterns? | 0/1 |

**Subtotal**: _/5

**Notes on coherence:**
```
[Document convention violations, naming issues,
style inconsistencies, etc.]
```

---

#### Category 5: Maintainability (4 criteria, max 4 points)

| # | Criterion | Evidence | Score |
|---|-----------|----------|-------|
| M1 | Self-documenting | Understandable without external docs? | 0/1 |
| M2 | Modular structure | Changes isolated to single files? | 0/1 |
| M3 | Clear dependencies | Step dependencies explicit? | 0/1 |
| M4 | Version noted | manifest.yaml has version? | 0/1 |

**Subtotal**: _/4

**Notes on maintainability:**
```
[Document documentation gaps, coupling issues,
unclear dependencies, missing versioning, etc.]
```

---

### 2. Calculate Overall Score

```yaml
scores:
  alignment: X/5
  technical: X/7
  robustness: X/5
  coherence: X/5
  maintainability: X/4

  total: X/26
  percentage: X%
```

**Score interpretation:**

| Range | Quality Level | Recommendation |
|-------|---------------|----------------|
| 22-26 | Excellent | Minor polish only |
| 18-21 | Good | Targeted improvements |
| 14-17 | Adequate | Significant updates needed |
| 10-13 | Poor | Major revision required |
| <10 | Inadequate | Consider rewrite |

---

### 3. Identify Strengths

List the TOP 3 strengths (what works well):

```yaml
strengths:
  - id: "S1"
    category: "alignment" | "technical" | "robustness" | "coherence" | "maintainability"
    description: "What works well"
    evidence: "Specific example or location"
    preserve: true  # Flag to not change during update

  - id: "S2"
    category: "..."
    description: "..."
    evidence: "..."
    preserve: true

  - id: "S3"
    category: "..."
    description: "..."
    evidence: "..."
    preserve: true
```

**Strength identification criteria:**
- Scores 1 consistently across multiple criteria
- Implementation exceeds minimum requirements
- Could serve as example for other workflows

---

### 4. Identify Weaknesses

List ALL weaknesses found, then prioritize TOP 3:

```yaml
weaknesses:
  - id: "W1"
    category: "alignment" | "technical" | "robustness" | "coherence" | "maintainability"
    criterion: "T3"  # Which criterion failed
    severity: "CRITICAL" | "HIGH" | "MEDIUM" | "LOW"
    description: "What's wrong"
    evidence: "Specific location and example"
    potential_fix: "How it could be addressed"
    effort_estimate: "quick" | "moderate" | "significant"

  - id: "W2"
    severity: "..."
    # ... same structure

  # Continue for all weaknesses found
```

**Severity definitions:**

| Severity | Meaning | Examples |
|----------|---------|----------|
| CRITICAL | Workflow broken or dangerous | Invalid YAML, security issue, wrong output |
| HIGH | Major functionality affected | Missing fallbacks, unclear instructions, broken links |
| MEDIUM | Quality concern | Inconsistent naming, missing validation, style issues |
| LOW | Polish item | Minor formatting, could be clearer |

---

### 5. Categorize Issues

Group weaknesses by fix type:

```yaml
issue_categories:
  quick_fixes:
    # Issues fixable with simple edits
    - weakness_id: "W3"
      fix: "Replace placeholder text"
      files: ["SKILL.md"]
    - weakness_id: "W5"
      fix: "Fix broken link"
      files: ["steps/step-02.md"]

  structural_changes:
    # Issues requiring reorganization
    - weakness_id: "W1"
      fix: "Add missing fallback handling"
      files: ["steps/step-01.md", "steps/step-02.md"]
    - weakness_id: "W2"
      fix: "Restructure step flow"
      files: ["SKILL.md", "steps/*"]

  design_improvements:
    # Issues requiring design decisions
    - weakness_id: "W4"
      fix: "Add new CC feature"
      decision_needed: "Which feature? How to integrate?"
```

---

### 6. Determine Update Priority

Create prioritized improvement list:

```yaml
update_priority:
  - rank: 1
    weakness_id: "W1"
    reason: "CRITICAL severity - must fix"

  - rank: 2
    weakness_id: "W2"
    reason: "HIGH severity - blocks effective use"

  - rank: 3
    weakness_id: "W3"
    reason: "Quick fix with high impact"

  # Continue for all weaknesses...
```

**Priority factors (in order):**
1. Severity (CRITICAL first)
2. Impact on usability
3. Effort to fix (quick fixes can be prioritized)
4. User-requested changes (if any)

---

### 7. Generate Update Recommendation

Based on assessment:

```yaml
recommendation:
  update_type: "incremental" | "targeted" | "significant" | "major" | "rewrite"

  rationale: |
    Based on score of X/26 and [N] issues found:
    - [CRITICAL count] critical issues requiring immediate fix
    - [HIGH count] high-priority improvements
    - [Strength summary]

  scope_suggestion:
    must_fix: ["W1", "W2"]  # CRITICAL and HIGH
    should_fix: ["W3", "W4"]  # MEDIUM
    could_fix: ["W5"]  # LOW

  estimated_changes:
    files_to_edit: [list]
    files_to_add: [list] | null
    files_to_delete: [list] | null
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ All 26 criteria evaluated
✅ All 5 categories scored
✅ At least 3 strengths identified
✅ All weaknesses have severity assigned
✅ Priorities are ordered correctly
✅ Recommendation is clear

**Self-Critique Questions:**
- Did I score honestly, or inflate/deflate scores?
- Are my severity assignments consistent?
- Did I miss any obvious issues?
- Would another reviewer reach similar conclusions?
- Are the top 3 strengths genuinely strong points?

**If validation fails:**
1. Re-evaluate criteria scored questionably
2. Cross-check severity assignments
3. Verify priority ordering logic

---

## OUTPUT STRUCTURE

Complete `{assessment}`:

```yaml
assessment:
  scores:
    alignment: X/5
    technical: X/7
    robustness: X/5
    coherence: X/5
    maintainability: X/4
    total: X/26
    percentage: X%

  strengths:
    - id: "S1"
      category: "..."
      description: "..."
      evidence: "..."
    # Top 3

  weaknesses:
    - id: "W1"
      category: "..."
      criterion: "..."
      severity: "..."
      description: "..."
      evidence: "..."
      potential_fix: "..."
      effort_estimate: "..."
    # All found

  issue_categories:
    quick_fixes: [...]
    structural_changes: [...]
    design_improvements: [...]

  update_priority:
    - rank: 1
      weakness_id: "..."
      reason: "..."
    # Ordered list

  recommendation:
    update_type: "..."
    rationale: "..."
    scope_suggestion:
      must_fix: [...]
      should_fix: [...]
      could_fix: [...]
    estimated_changes:
      files_to_edit: [...]
      files_to_add: [...]
      files_to_delete: [...]
```

---

## SUCCESS / FAILURE

**Success:**
✅ Complete `{assessment}` with all sections
✅ Scores are evidence-based
✅ Weaknesses have clear fixes identified
✅ Priorities make logical sense
✅ Ready for user proposal (step-U3)

**Failure modes:**
❌ Cannot determine score → Re-read criterion definition, make best judgment
❌ No weaknesses found → Re-examine with adversarial mindset
❌ Too many weaknesses → Group related issues, focus on root causes
❌ Conflicting priorities → Apply severity rules strictly

---

## NEXT

After validation passes, load `steps/step-U3-propose.md`

<critical>
Assessment must be HONEST and EVIDENCE-BASED.
Do not inflate scores to make workflow look good.
Do not deflate to justify unnecessary changes.
Each weakness must have a specific location and example.
Strengths are equally important - preserve what works!
</critical>
