# Step 03: Iterate and Improve

> Purpose: Apply fixes, re-challenge with new perspective, track progress toward perfection.

---

## MANDATORY RULES

- 🎯 ALWAYS apply fixes BEFORE re-challenging
- 🚫 NEVER repeat the same fix twice (must learn)
- 🚫 NEVER iterate more than 3 times without progress
- ✅ ALWAYS change perspective each iteration
- ✅ ALWAYS track what CHANGED between iterations
- ⚠️ If same issue returns, it's likely architectural

## PROTOCOLS

- 🎯 **Goal**: Iterative improvement until perfection or escalation
- 💾 **Output**: Updated `{findings}`, `{fixes_applied}`, `{confidence_score}`
- 📖 **Reference**: Previous iteration results
- ⚡ **Performance**: Fix → Challenge → Evaluate loop

---

## CONTEXT

**Available from step-02:**
- `{dimensions_status}` - Scores per dimension
- `{findings}` - Issues found
- `{iteration}` - Current iteration number

**Produced by this step:**
- `{fixes_applied}` - What was corrected
- `{iteration}` - Incremented
- `{confidence_score}` - Updated scores
- `{improvement_delta}` - Change from previous iteration

---

## TASK

### The Iteration Loop

```
WHILE iteration <= 3 AND overall_confidence < 90%:

    1. APPLY FIXES
       - Address HIGH severity findings first
       - Apply MEDIUM if time permits
       - Document each fix

    2. SHIFT PERSPECTIVE
       - Iteration 1: "The Implementer" (already done)
       - Iteration 2: "The Critic" (find weaknesses)
       - Iteration 3: "The Attacker" (break it)

    3. RE-CHALLENGE
       - Re-evaluate all dimensions
       - Focus on areas that changed
       - Check if fixes introduced new issues

    4. CALCULATE DELTA
       - What improved?
       - What got worse?
       - What's stuck?

    5. DECIDE
       - confidence >= 90%? → Exit loop, proceed to finalize
       - confidence < 90% AND iteration < 3? → Continue
       - iteration = 3 AND stuck? → Escalate
```

---

### Phase 1: Apply Fixes

For each HIGH severity finding:

```markdown
### Fix Applied: F-{number}

**Finding**: {original issue}
**Fix**: {what was changed}
**Verification**: {how to confirm fix works}
**Side Effects**: {any new concerns introduced?}
```

For file modifications:
- Use Edit tool to apply changes
- Run relevant tests/validation if applicable
- Document before/after
- **If fix cannot be applied** (permission denied, read-only, structural issue):
  - Document as gap with reason
  - Continue in report-only mode
  - Do NOT block the iteration loop

For non-file targets (plans, decisions):
- Document the improved version
- Explain the change rationale

---

### Phase 2: Perspective Shift

#### Iteration 2: The Critic

Ask yourself:
- What are the weakest points in this solution?
- If I HAD to find 3 problems, what would they be?
- What would a senior reviewer criticize?
- What would a perfectionist change?

#### Iteration 3: The Attacker

Ask yourself:
- How could a malicious user exploit this?
- What inputs would break this?
- What environment conditions would cause failure?
- If I wanted to cause maximum damage, where would I attack?

---

### Phase 3: Re-Challenge

Re-evaluate each dimension with new perspective:

```markdown
## Re-Evaluation (Iteration {N})

### Correctness
- Previous score: XX%
- Current score: YY%
- Change: {improved/degraded/same}
- New observations: {what the new perspective revealed}

### Security
[same structure]

### Coherence
[same structure]

### Robustness
[same structure]

### Clarity
[same structure]

### Efficiency
[same structure]
```

---

### Phase 4: Calculate Delta

```markdown
## Iteration Delta

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Overall Confidence | XX% | YY% | +/-Z% |
| HIGH findings | N | M | +/-K |
| MEDIUM findings | N | M | +/-K |
| LOW findings | N | M | +/-K |

**Improvement Summary**:
- Fixes applied: {count}
- New issues found: {count}
- Net improvement: {positive/negative/neutral}

**Stuck Indicators**:
- Same issue returning? {yes/no}
- No progress on a dimension? {yes/no}
- Circular fixes? {yes/no}
```

---

### Phase 5: Decision Point

```
IF overall_confidence >= 90%:
    → PROCEED to step-04-finalize.md
    → Mark as "ready for final report"

ELIF iteration < 3 AND making_progress:
    → INCREMENT iteration
    → LOOP back to Phase 1

ELIF iteration = 3 OR no_progress:
    → ESCALATE via AskUserQuestion
    → Present remaining issues
    → Ask for decision
```

---

## ESCALATION PROTOCOL

When stuck after 3 iterations:

```
AskUserQuestion:
  question: "I've completed 3 challenge iterations but haven't reached 90% confidence. How should I proceed?"
  header: "Challenge"
  options:
    - label: "Accept current state"
      description: "Confidence at {X}%. Remaining issues: {list}"
    - label: "Focus on specific issue"
      description: "I'll guide you on what to investigate deeper"
    - label: "Continue iterating"
      description: "Do one more pass with your guidance"
    - label: "Abort challenge"
      description: "Stop here, I'll handle it differently"
```

---

## LEARNING BETWEEN ITERATIONS

Each iteration MUST document:

```markdown
## Iteration {N} Learnings

**What I discovered**:
- {insight_1}
- {insight_2}

**What I should have caught earlier**:
- {miss_1}

**Changed mental model**:
- Before: {assumption}
- After: {reality}

**Applied to next iteration**:
- Will focus more on: {area}
- Will be skeptical of: {assumption}
```

---

## OUTPUT

```yaml
step_03_output:
  iteration: {current_number}

  fixes_applied:
    - finding_id: "F-1"
      fix_description: "{what was done}"
      verification: "{how confirmed}"
      side_effects: "{if any}"

  updated_dimensions:
    correctness: {new_score}
    security: {new_score}
    coherence: {new_score}
    robustness: {new_score}
    clarity: {new_score}
    efficiency: {new_score}

  overall_confidence: {new_score}

  delta:
    previous_confidence: {old}
    current_confidence: {new}
    net_change: {+/-X%}
    findings_resolved: {count}
    new_findings: {count}

  decision: "PROCEED" | "CONTINUE" | "ESCALATE"

  learnings:
    - "{learning_1}"
    - "{learning_2}"
```

---

## NEXT

Based on decision:
- `PROCEED` → Load `steps/step-04-finalize.md`
- `CONTINUE` → Loop back to Phase 1 of THIS step (stay in step-03, increment iteration counter)
- `ESCALATE` → AskUserQuestion, then follow user direction

**IMPORTANT**: `CONTINUE` means staying in step-03 and running another iteration cycle, NOT going back to step-02. The initial challenge was done in step-02; step-03 handles the improvement loop internally.

<critical>
Each iteration MUST:
1. Apply at least one fix (unless nothing found)
2. Use a different perspective
3. Track what changed
4. Document learnings
5. Make progress OR escalate

Never iterate blindly without learning from the previous pass.
</critical>
