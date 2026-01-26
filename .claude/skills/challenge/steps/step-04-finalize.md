# Step 04: Finalize and Report

> Purpose: Generate final verdict, comprehensive report, and apply remaining corrections.

---

## MANDATORY RULES

- 🎯 ALWAYS generate structured report
- 🚫 NEVER finalize with unacknowledged HIGH findings
- ✅ ALWAYS provide actionable recommendations
- ✅ ALWAYS include confidence justification
- ⚠️ Report must stand alone (readable without context)

## PROTOCOLS

- 🎯 **Goal**: Final verdict and comprehensive report
- 💾 **Output**: Challenge report + verdict
- 📖 **Reference**: All previous step outputs
- ⚡ **Performance**: Report generation, optional final fixes

---

## CONTEXT

**Available from previous steps:**
- `{target}` - What was challenged
- `{target_type}` - Classification
- `{dimensions_status}` - Final scores
- `{findings}` - All issues found
- `{fixes_applied}` - Corrections made
- `{iteration}` - How many passes

**Produced by this step:**
- `{final_report}` - Comprehensive report
- `{overall_verdict}` - PERFECT, GOOD_ENOUGH, or NEEDS_USER_INPUT

---

## TASK

### Phase 1: Compile Results

Aggregate all findings and fixes:

```markdown
## Challenge Summary

**Target**: {target}
**Type**: {target_type}
**Iterations**: {count}
**Total Findings**: {count} (H:{x} M:{y} L:{z})
**Fixes Applied**: {count}
**Final Confidence**: {X}%
```

### Phase 2: Determine Verdict

```
IF overall_confidence >= 95%:
    verdict = "PERFECT"
    message = "No significant issues remain. Work is production-ready."

ELIF overall_confidence >= 90%:
    verdict = "GOOD_ENOUGH"
    message = "Minor notes remain but acceptable quality."

ELIF overall_confidence >= 80%:
    verdict = "APPROVED_WITH_NOTES"
    message = "Some concerns documented. User should review notes."

ELSE:
    verdict = "NEEDS_USER_INPUT"
    message = "Significant concerns remain. User decision required."
```

### Phase 3: Generate Report

Use this exact format:

```markdown
# Challenge Report

## Target Information

| Attribute | Value |
|-----------|-------|
| Target | {target} |
| Type | {target_type} |
| Iterations | {count} |
| Date | {date} |

---

## Executive Summary

**Verdict**: {verdict} ({confidence}%)

{1-2 sentence summary of the challenge outcome}

---

## Dimension Analysis

### Correctness: {score}%

{2-3 sentences explaining the score}

**Key Finding**: {most important observation}

### Security: {score}%

{2-3 sentences explaining the score}

**Key Finding**: {most important observation}

### Coherence: {score}%

{2-3 sentences explaining the score}

**Key Finding**: {most important observation}

### Robustness: {score}%

{2-3 sentences explaining the score}

**Key Finding**: {most important observation}

### Clarity: {score}%

{2-3 sentences explaining the score}

**Key Finding**: {most important observation}

### Efficiency: {score}%

{2-3 sentences explaining the score}

**Key Finding**: {most important observation}

---

## Findings Summary

### HIGH Severity ({count})

| ID | Issue | Status | Impact |
|----|-------|--------|--------|
| F-1 | {description} | Fixed/Open | {impact} |

### MEDIUM Severity ({count})

| ID | Issue | Status | Impact |
|----|-------|--------|--------|
| F-X | {description} | Fixed/Open | {impact} |

### LOW Severity ({count})

| ID | Issue | Status | Recommendation |
|----|-------|--------|----------------|
| F-Y | {description} | Fixed/Noted | {recommendation} |

---

## Improvements Made

During this challenge, the following corrections were applied:

1. **{Fix 1}**: {description of change}
2. **{Fix 2}**: {description of change}
...

---

## Open Items

{List any unresolved items with justification for why they remain}

---

## Recommendations

### Immediate Actions
- {action_1}
- {action_2}

### Future Considerations
- {consideration_1}
- {consideration_2}

---

## Confidence Justification

**Why {confidence}%?**

{Paragraph explaining the confidence score, what would increase it, and why the current level is acceptable}

---

## Verdict: {VERDICT}

{Final statement about the quality of the challenged artifact}
```

### Phase 4: Apply Final Corrections (if applicable)

If verdict is PERFECT or GOOD_ENOUGH and there are pending fixes:
- Apply remaining LOW/MEDIUM fixes that improve quality
- Document what was changed
- Do NOT re-challenge (would loop)

### Phase 5: Present to User

Output the report directly.

If verdict is NEEDS_USER_INPUT:

```
AskUserQuestion:
  question: "The challenge is complete but some issues need your decision. What would you like to do?"
  header: "Decision"
  options:
    - label: "Accept as-is"
      description: "Acknowledge issues, proceed anyway"
    - label: "Address specific items"
      description: "I'll tell you which to focus on"
    - label: "Start over"
      description: "Major rethink needed"
```

---

## OUTPUT

```yaml
step_04_output:
  verdict: "PERFECT" | "GOOD_ENOUGH" | "APPROVED_WITH_NOTES" | "NEEDS_USER_INPUT"
  overall_confidence: {X}

  summary:
    total_findings: {N}
    high_severity: {count}
    medium_severity: {count}
    low_severity: {count}
    fixes_applied: {count}
    open_items: {count}

  final_report: |
    {full markdown report as generated above}

  recommendations:
    immediate: ["{action_1}", "{action_2}"]
    future: ["{consideration_1}"]
```

---

## REPORT QUALITY CHECKLIST

Before finalizing, verify:

✅ Report is self-contained (readable without prior context)
✅ All dimensions have scores AND justifications
✅ HIGH severity items are all addressed or explicitly deferred
✅ Verdict matches confidence score
✅ Recommendations are actionable
✅ No "TBD" or placeholder text

---

## NEXT

This is the final step.

After report is generated:
1. Present report to user
2. If NEEDS_USER_INPUT: wait for decision
3. If any verdict: workflow complete

<critical>
The report is the deliverable.
It must be:
- Complete (all findings documented)
- Honest (confidence reflects reality)
- Actionable (clear next steps)
- Standalone (anyone can read and understand)

This report may be referenced later. Make it count.
</critical>
