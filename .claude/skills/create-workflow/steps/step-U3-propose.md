# Step U3: Propose Improvements

> Purpose: Present improvement proposals to user and get approval for which updates to apply.

---

## MANDATORY RULES (READ FIRST)

- 🙋 USE AskUserQuestion for validation - never assume
- 📋 Present ALL options clearly with pros/cons
- ✅ Respect user choice - even if different from recommendation
- 🔀 Support multiSelect for combining improvements

## PROTOCOLS

- 🎯 **Goal**: Get user approval on specific improvements to apply
- 💾 **Output**: `{approved_improvements}` with user-validated scope
- 📖 **Reference**: `{assessment}` from step-U2
- ⚡ **Performance**: Clear proposals prevent rework

---

## CONTEXT

**Available from previous steps:**
- `{existing_workflow}` - Complete workflow analysis (from step-U1)
- `{assessment}` - Quality assessment with prioritized weaknesses (from step-U2)

**Produced by this step:**
- `{approved_improvements}` - User-approved list of improvements to apply

**NOT available (do not use):**
- `{modifications}` - Created in step-U4
- `{critique_results}` - Created in step-06

---

## TASK

Generate improvement proposals from assessment and get user approval:
1. Transform weaknesses into actionable proposals
2. Categorize as quick fixes vs structural changes
3. Present options via AskUserQuestion
4. Handle user selections including custom requests
5. Build approved improvements list

---

## EXECUTION

### 1. Transform Weaknesses to Proposals

For each weakness in `{assessment.weaknesses}`:

```yaml
proposal:
  id: "P{N}"
  from_weakness: "W{N}"
  title: "Short descriptive title"
  description: |
    What will be changed and why.
    Expected improvement.
  type: "quick_fix" | "structural" | "design"
  severity: "CRITICAL" | "HIGH" | "MEDIUM" | "LOW"
  files_affected: ["list", "of", "files"]
  effort: "quick" | "moderate" | "significant"
```

**Grouping rules:**
- Related weaknesses → Single combined proposal
- Independent weaknesses → Separate proposals
- CRITICAL issues → Always separate (highlight importance)

---

### 2. Build Proposal List

Organize proposals for presentation:

```yaml
proposals:
  critical:
    - id: "P1"
      title: "..."
      must_fix: true

  high_priority:
    - id: "P2"
      title: "..."
      recommended: true

  improvements:
    - id: "P3"
      title: "..."
      optional: true

  polish:
    - id: "P4"
      title: "..."
      optional: true
```

---

### 3. Generate AskUserQuestion Options

**Option generation rules:**

```yaml
# Maximum 4 options per AskUserQuestion
# Structure options from most comprehensive to most minimal

option_templates:
  - label: "All improvements (Recommended)"
    description: "Apply all suggested fixes: {list}"
    includes: ["P1", "P2", "P3", "P4"]

  - label: "Critical + High priority"
    description: "Fix important issues only: {list}"
    includes: ["P1", "P2"]

  - label: "Critical only"
    description: "Minimum fixes: {list}"
    includes: ["P1"]

  - label: "Select specific"
    description: "I'll specify which improvements"
    includes: []  # Triggers follow-up
```

**If only 1-2 proposals:**

```yaml
option_templates:
  - label: "Apply fix"
    description: "{description of the fix}"
    includes: ["P1"]

  - label: "Apply all fixes"
    description: "{descriptions}"
    includes: ["P1", "P2"]

  - label: "Skip updates"
    description: "Keep workflow as-is"
    includes: []
```

---

### 4. Present to User

**CRITICAL**: Use AskUserQuestion tool now.

**For standard case (3+ proposals):**

```json
{
  "questions": [
    {
      "question": "Which improvements would you like to apply to {workflow_name}?",
      "header": "Updates",
      "options": [
        {
          "label": "All improvements (Recommended)",
          "description": "Apply all {N} suggested fixes for comprehensive update"
        },
        {
          "label": "Critical + High priority",
          "description": "Fix {N} important issues: {brief list}"
        },
        {
          "label": "Critical fixes only",
          "description": "Apply only {N} must-fix issues"
        },
        {
          "label": "Minimal/Custom",
          "description": "Specify exactly which improvements to apply"
        }
      ],
      "multiSelect": true
    }
  ]
}
```

**For simple case (1-2 proposals):**

```json
{
  "questions": [
    {
      "question": "Would you like to apply this improvement to {workflow_name}?",
      "header": "Update",
      "options": [
        {
          "label": "Yes, apply fix",
          "description": "{description of what will change}"
        },
        {
          "label": "No, skip",
          "description": "Keep workflow unchanged"
        }
      ],
      "multiSelect": false
    }
  ]
}
```

---

### 5. Handle User Response

**Process selection:**

```yaml
user_selection_handling:
  "All improvements":
    action: Include all proposals
    approved: ["P1", "P2", "P3", "P4"]

  "Critical + High priority":
    action: Include critical and high
    approved: ["P1", "P2"]

  "Critical fixes only":
    action: Include critical only
    approved: ["P1"]

  "Minimal/Custom":
    action: Ask follow-up question
    next: Present individual proposals

  "Other" (custom text):
    action: Parse user intent
    next: Map to proposals or add custom request
```

---

### 6. Handle "Other" / Custom Requests

If user provides custom input:

**Parse intent:**

```yaml
custom_request_handling:
  # User specifies known proposals
  "Just P2 and P4":
    approved: ["P2", "P4"]
    custom_requests: null

  # User adds new request
  "P1 plus add better error messages":
    approved: ["P1"]
    custom_requests:
      - type: "new_improvement"
        description: "Add better error messages"
        needs_clarification: false

  # Ambiguous request
  "Make it faster":
    approved: []
    custom_requests:
      - type: "clarification_needed"
        original: "Make it faster"
        clarification_question: "Which aspect should be faster? Execution? Loading?"
```

**If clarification needed:**

```json
{
  "questions": [
    {
      "question": "Could you clarify what you mean by '{custom_input}'?",
      "header": "Clarify",
      "options": [
        {
          "label": "Option interpretation 1",
          "description": "This would mean..."
        },
        {
          "label": "Option interpretation 2",
          "description": "This would mean..."
        }
      ],
      "multiSelect": false
    }
  ]
}
```

---

### 7. Handle Follow-up for Specific Selection

If user chose "Minimal/Custom", present individual proposals:

```json
{
  "questions": [
    {
      "question": "Select the specific improvements to apply:",
      "header": "Select",
      "options": [
        {
          "label": "P1: {title}",
          "description": "{brief description}"
        },
        {
          "label": "P2: {title}",
          "description": "{brief description}"
        },
        {
          "label": "P3: {title}",
          "description": "{brief description}"
        },
        {
          "label": "P4: {title}",
          "description": "{brief description}"
        }
      ],
      "multiSelect": true
    }
  ]
}
```

---

### 8. Build Approved Improvements List

Compile final approved list:

```yaml
approved_improvements:
  - id: "improvement_1"
    from_proposal: "P1"
    type: "quick_fix" | "structural" | "design"
    description: "Clear description of what will be done"
    files_affected:
      - path: "SKILL.md"
        change_type: "edit"
        change_description: "Update description text"
      - path: "steps/step-02.md"
        change_type: "edit"
        change_description: "Add fallback handling"

  - id: "improvement_2"
    from_proposal: "P2"
    type: "..."
    description: "..."
    files_affected: [...]

  # Include custom requests if any
  - id: "improvement_custom_1"
    from_proposal: null  # Custom request
    type: "custom"
    description: "{User's custom request}"
    files_affected: []  # TBD in step-U4
    user_specified: true

  custom_requests: "Full text of any custom requests" | null

  preserved_strengths:
    - strength_id: "S1"
      description: "What to not change"
    - strength_id: "S2"
      description: "What to not change"

  scope_summary:
    total_improvements: N
    quick_fixes: N
    structural: N
    custom: N
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ AskUserQuestion was used (not assumed)
✅ User selection is recorded
✅ All approved improvements have clear descriptions
✅ Files affected are identified for each improvement
✅ Custom requests (if any) are captured
✅ Strengths to preserve are noted

**Self-Critique Questions:**
- Did I present options clearly without bias?
- Did I honor the user's choice even if not optimal?
- Are the improvement descriptions actionable?
- Did I capture ALL user requests including custom ones?

**If validation fails:**
1. Re-present options if user response unclear
2. Ask clarifying question for ambiguous input
3. Document any unresolvable ambiguity

---

## OUTPUT STRUCTURE

Complete `{approved_improvements}`:

```yaml
approved_improvements:
  - id: "improvement_1"
    from_proposal: "P1" | null
    type: "quick_fix" | "structural" | "design" | "custom"
    description: "What will be done"
    files_affected:
      - path: "..."
        change_type: "edit" | "add" | "delete"
        change_description: "..."
    user_specified: boolean

  # ... all approved improvements

  custom_requests: "..." | null

  preserved_strengths:
    - strength_id: "..."
      description: "..."

  scope_summary:
    total_improvements: N
    quick_fixes: N
    structural: N
    custom: N
```

---

## SUCCESS / FAILURE

**Success:**
✅ User has approved specific improvements
✅ `{approved_improvements}` is complete and actionable
✅ Scope is clear for step-U4
✅ Strengths to preserve are documented

**Failure modes:**
❌ User wants no changes → Confirm, then skip to completion
❌ User request unclear → Ask clarifying question
❌ User wants changes outside scope → Note for manual follow-up
❌ Too many custom requests → Prioritize with user

---

## SPECIAL CASE: No Updates Requested

If user selects "Skip" or "No changes":

```yaml
approved_improvements: []
custom_requests: null
user_decision: "no_update"
reason: "User chose to keep workflow as-is"
```

**Action**: Skip step-U4, proceed directly to confirmation message.

---

## NEXT

After validation passes:
- If improvements approved: Load `steps/step-U4-improve.md`
- If no updates: Display confirmation and exit workflow

<critical>
NEVER assume user approval - ALWAYS use AskUserQuestion.
User choice is final - do not argue or re-ask if they decline recommendations.
Custom requests are valid - capture them even if not in your proposals.
Preserve strengths - improvements should not break what works.
</critical>
