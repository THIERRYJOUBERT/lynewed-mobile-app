# Step 04: Checkpoint

> Purpose: Present design to user for validation before generation.

---

## MANDATORY RULES (READ FIRST)

- 🎯 ALWAYS present complete design summary before asking
- ✅ Use AskUserQuestion for structured validation
- 🔄 Return to step-03 if adjustments needed
- 🚫 NEVER proceed to generation without explicit approval

## PROTOCOLS

- 🎯 **Goal**: User validation of workflow design
- 💾 **Output**: `{design_approved: true}` or loop back
- 📖 **Reference**: `{design}` from step-03
- ⚡ **Performance**: Clear presentation = faster approval

---

## CONTEXT

**Available from previous steps:**
- `{interview_data}` - Original requirements (step-01)
- `{exploration_results}` - Context and patterns (step-02)
- `{design}` - Complete design document (step-03)
  - `{design.workflow_type}` - Chosen type
  - `{design.cc_features}` - Feature decisions with justifications
  - `{design.steps}` - Step definitions (if multi-step)
  - `{design.flow_diagram}` - Visual flow
  - `{design.risks}` - Identified risks

**Produced by this step:**
- `{design_approved}` - Boolean: true if approved
- `{adjustment_feedback}` - User feedback if adjustments requested

**NOT available (do not use):**
- `{generated_files}` - Not yet created (step-05)

---

## TASK

Present the complete design to the user and get explicit approval before proceeding to file generation.

---

## EXECUTION

### 1. Prepare Design Summary

Format the design for clear presentation.

**Presentation Template:**

```markdown
## Workflow Design Summary

### Understanding

I will create a workflow named `{design.workflow_name}` that:
{interview_data.objective}

### Type

**{design.workflow_type}**
{design.type_justification}

### Claude Code Features

| Feature | Decision | Justification |
|---------|----------|---------------|
| context: fork | {cc_features.context_fork.decision} | {cc_features.context_fork.justification} |
| Subagents | {cc_features.subagents.needed} {details} | {cc_features.subagents.justification} |
| Hooks | {cc_features.hooks.needed} {details} | {cc_features.hooks.justification} |
| allowed-tools | {cc_features.allowed_tools.list} | {cc_features.allowed_tools.justification} |
| model | {cc_features.model.choice} | {cc_features.model.justification} |
| Invocation | {user-invocable + disable-model} | {justification} |

### Structure

{design.flow_diagram}

### Steps (if multi-step)

| Step | Purpose | Claude Role |
|------|---------|-------------|
| 01-{name} | {purpose} | {role} |
| 02-{name} | {purpose} | {role} |
...

### Identified Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| {risk.risk} | {risk.likelihood} | {risk.mitigation} |
...

### Files to be Created

- `.claude/skills/{name}/SKILL.md` - Entry point
- `.claude/skills/{name}/steps/step-01-*.md` - (if multi-step)
- `.claude/skills/{name}/templates/*.md` - (if templates needed)
```

---

### 2. Present to User

Output the formatted design summary directly (not in a tool call).

---

### 3. Ask for Validation

Use AskUserQuestion tool:

```json
{
  "questions": [
    {
      "question": "Does this design meet your needs?",
      "header": "Validation",
      "options": [
        {
          "label": "Yes, proceed",
          "description": "Design is good, generate the workflow files"
        },
        {
          "label": "Adjust features",
          "description": "I want to change some CC feature decisions"
        },
        {
          "label": "Adjust structure",
          "description": "I want to change steps or flow"
        },
        {
          "label": "Start over",
          "description": "This doesn't match my need, restart interview"
        }
      ],
      "multiSelect": false
    }
  ]
}
```

---

### 4. Handle Response

**If "Yes, proceed":**
```yaml
design_approved: true
```
→ Load `steps/step-05-generate.md`

**If "Adjust features":**
Ask follow-up question:
```json
{
  "questions": [
    {
      "question": "Which features would you like to change?",
      "header": "Features",
      "options": [
        {"label": "context:fork", "description": "Change isolation decision"},
        {"label": "Subagents", "description": "Change agent configuration"},
        {"label": "Hooks", "description": "Change automation"},
        {"label": "Model", "description": "Change execution model"}
      ],
      "multiSelect": true
    }
  ]
}
```

Capture feedback:
```yaml
adjustment_feedback:
  type: "features"
  items: ["Selected features"]
  details: "User's specific requests"
```
→ Return to `steps/step-03-design.md` with feedback

**If "Adjust structure":**
Ask follow-up question:
```json
{
  "questions": [
    {
      "question": "What structural changes would you like?",
      "header": "Structure",
      "options": [
        {"label": "Add steps", "description": "Need more steps"},
        {"label": "Remove steps", "description": "Too many steps"},
        {"label": "Reorder steps", "description": "Change step sequence"},
        {"label": "Change type", "description": "Different workflow type"}
      ],
      "multiSelect": true
    }
  ]
}
```

Capture feedback:
```yaml
adjustment_feedback:
  type: "structure"
  items: ["Selected changes"]
  details: "User's specific requests"
```
→ Return to `steps/step-03-design.md` with feedback

**If "Start over":**
```yaml
adjustment_feedback:
  type: "restart"
  reason: "User request"
```
→ Return to `steps/step-01-interview.md` with clean state

---

## ADJUSTMENT LOOP

When returning to step-03 with feedback:

1. Pass `{adjustment_feedback}` to step-03
2. Step-03 modifies only the requested aspects
3. Return to step-04 with updated design
4. Present changes highlighted
5. Ask for validation again

**Max loops**: 3 adjustment cycles
After 3 cycles with continued rejection:
- Summarize the issues
- Ask user if they want to proceed anyway or cancel

---

## AUTO-VALIDATION

**Before proceeding to step-05, validate:**
✅ User explicitly selected "Yes, proceed"
✅ `{design_approved}` is set to true
✅ No unresolved concerns from user

**Self-Critique Questions:**
- Did I present the design clearly?
- Were justifications understandable?
- Did I capture all adjustment feedback accurately?
- Is the user's approval genuine (not just rushing)?

**If validation fails:**
1. Re-present unclear sections
2. Ask specific clarifying questions
3. If user seems confused: Explain in simpler terms

---

## SUCCESS / FAILURE

**Success:**
✅ `{design_approved: true}` with explicit user approval
✅ User understands what will be created
✅ Clear to proceed with generation

**Failure modes:**
❌ User rejects after 3 adjustment cycles → Offer to cancel or force proceed
❌ User is confused by design → Simplify presentation, ask specific questions
❌ User wants something impossible → Explain constraints, suggest alternatives

---

## NEXT

After `{design_approved: true}`, load `steps/step-05-generate.md`

<critical>
This is the LAST CHANCE to course-correct before generation.
Correcting design now is cheap.
Correcting after generation is expensive.
Get explicit approval. Don't assume.
</critical>
