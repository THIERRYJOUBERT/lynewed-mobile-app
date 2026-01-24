# Step 01: Interview

> Purpose: Capture complete workflow requirements via intelligent hybrid interview.

---

## MANDATORY RULES (READ FIRST)

- 🎯 ALWAYS ask base questions first, then adapt
- 🚫 NEVER assume answers - ask if unclear
- ✅ ALWAYS validate workflow name is kebab-case
- ⚠️ Questions must be clear and provide good defaults

## PROTOCOLS

- 🎯 **Goal**: Capture complete workflow requirements
- 💾 **Output**: `{interview_data}` object with all requirements
- 📖 **Reference**: None needed - interview is conversational
- ⚡ **Performance**: Use AskUserQuestion for structured input

---

## CONTEXT

**Available from previous steps:**
- `{mode}` - CREATE (confirmed by step-00/SKILL.md router)
- `{workflow_name}` - May be pre-filled from argument, or null
- `{target_path}` - Target path for workflow files

**Produced by this step:**
- `{interview_data}` - Complete requirements object

**NOT available (do not use):**
- `{exploration_results}` - Not yet created (step-02)
- `{design}` - Not yet created (step-03)

---

## TASK

Conduct a hybrid structured interview to capture:
1. Workflow identity (name, objective)
2. Invocation mode (user, model, both)
3. Inputs and outputs
4. Constraints and rules
5. Hints for advanced features (subagents, hooks)

---

## EXECUTION

### Phase 1: Base Questions (Always Asked)

Use AskUserQuestion tool to gather essential information.

**If `{workflow_name}` is null:**

```
Question 1: Workflow Name
{
  question: "What should this workflow be called?",
  header: "Name",
  options: [
    {label: "Suggest name", description: "I'll suggest based on your objective"}
  ],
  multiSelect: false
}
```

Validate the name is kebab-case (lowercase, hyphens only).
If user provides name with spaces or capitals, convert automatically.

**Question 2: Objective**

```
{
  question: "What problem does this workflow solve? Describe in 1-2 sentences.",
  header: "Objective",
  options: [
    {label: "General purpose", description: "Flexible workflow for various tasks"},
    {label: "Specific task", description: "Focused on one particular action"},
    {label: "Validation/Quality", description: "Checks, validates, or reviews"},
    {label: "Generation/Creation", description: "Produces files or content"}
  ],
  multiSelect: false
}
```

If user selects an option, ask for specific details.
Capture the full objective text.

**Question 3: Invocation Mode**

```
{
  question: "Who should be able to invoke this workflow?",
  header: "Invocation",
  options: [
    {label: "User only (/command)", description: "Only manual invocation via slash command"},
    {label: "Claude decides", description: "Claude can invoke when relevant context detected"},
    {label: "Both", description: "User can invoke, Claude can also auto-trigger"}
  ],
  multiSelect: false
}
```

---

### Phase 2: Contextual Questions (Based on Answers)

Analyze the objective text and ask relevant follow-up questions.

**Detection patterns:**

| Objective Contains | Follow-up Focus |
|--------------------|-----------------|
| "create", "generate", "build", "produce" | Ask about outputs, formats, templates |
| "analyze", "explore", "search", "find" | Ask about inputs, scope, depth |
| "validate", "verify", "check", "review" | Ask about criteria, standards, actions on failure |
| "fix", "debug", "solve", "resolve" | Ask about error handling, recovery, logging |
| "transform", "convert", "migrate" | Ask about source, target, preservation |

**Example contextual question for generation:**

```
{
  question: "What outputs should this workflow produce?",
  header: "Outputs",
  options: [
    {label: "Files (code, docs)", description: "Creates new files in the project"},
    {label: "Report/Summary", description: "Generates a summary or analysis"},
    {label: "Configuration", description: "Produces config files or settings"},
    {label: "Multiple artifacts", description: "Several different types of output"}
  ],
  multiSelect: true
}
```

---

### Phase 3: Technical Questions (Adaptive)

Based on complexity signals, ask technical questions.

**Inputs/Arguments:**

```
{
  question: "Does this workflow need any inputs or arguments?",
  header: "Arguments",
  options: [
    {label: "No arguments", description: "Works without any input"},
    {label: "Optional argument", description: "Can take input but works without"},
    {label: "Required argument", description: "Needs specific input to function"},
    {label: "Multiple arguments", description: "Takes several inputs"}
  ],
  multiSelect: false
}
```

If arguments needed, ask for details:
- Argument names and types
- Default values if optional
- Validation rules

**Complexity Hints (for later CC feature decisions):**

```
{
  question: "Will this workflow need to read many files or explore the codebase?",
  header: "Exploration",
  options: [
    {label: "Minimal reading", description: "Reads 1-3 specific files"},
    {label: "Moderate exploration", description: "Searches and reads several files"},
    {label: "Heavy exploration", description: "Deep codebase analysis, many files"}
  ],
  multiSelect: false
}
```

Store answer as `{hints_subagents}` = true if "Heavy exploration".

```
{
  question: "Should any automatic actions happen during execution?",
  header: "Automation",
  options: [
    {label: "No automation", description: "Manual workflow, user controls everything"},
    {label: "Validation hooks", description: "Auto-validate outputs (lint, format, test)"},
    {label: "Side effects", description: "Trigger actions (git, deploy, notify)"},
    {label: "Multiple automations", description: "Several automatic behaviors"}
  ],
  multiSelect: true
}
```

Store answer as `{hints_hooks}` = true if automation selected.

---

### Phase 4: Constraints and Rules

```
{
  question: "Are there any specific constraints or rules this workflow must follow?",
  header: "Constraints",
  options: [
    {label: "No special constraints", description: "Standard workflow behavior"},
    {label: "Read-only", description: "Must not modify any files"},
    {label: "Security sensitive", description: "Handles credentials or sensitive data"},
    {label: "Performance critical", description: "Must complete quickly"}
  ],
  multiSelect: true
}
```

If constraints selected, capture details.

---

## OUTPUT STRUCTURE

Compile all answers into `{interview_data}`:

```yaml
interview_data:
  workflow_name: "{validated_kebab_case_name}"
  objective: "{full_objective_text}"
  invocation: "user" | "model" | "both"

  inputs:
    - name: "{arg_name}"
      type: "{arg_type}"
      required: true|false
      default: "{default_value}" # if optional

  outputs:
    - type: "file" | "report" | "config" | "artifact"
      description: "{what_is_produced}"

  constraints:
    - "{constraint_1}"
    - "{constraint_2}"

  hints:
    subagents: true|false  # Heavy exploration detected
    hooks: true|false      # Automation needs detected

  examples:
    invocation: "/{workflow_name} {example_args}"
    use_case: "{when_to_use_description}"
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ `workflow_name` is valid kebab-case (lowercase, hyphens, no spaces)
✅ `objective` is clear and non-empty
✅ `invocation` mode is explicitly chosen
✅ No "TBD" or placeholder values in data

**Self-Critique Questions:**
- Did I understand the user's actual need?
- Are there ambiguities I should clarify?
- Is the scope clear enough for design?
- Will another Claude instance understand this data?

**If validation fails:**
1. Ask clarifying questions for unclear points
2. Max 3 rounds of clarification
3. If persistent: Proceed with best understanding, flag uncertainties

---

## SUCCESS / FAILURE

**Success:**
✅ All required fields populated in `{interview_data}`
✅ Objective is actionable and clear
✅ Enough information to design workflow

**Failure modes:**
❌ User provides conflicting requirements → Ask to clarify priority
❌ Scope is too broad → Suggest breaking into multiple workflows
❌ Objective is vague → Ask for concrete examples of use

---

## NEXT

After validation passes, load `steps/step-02-explore.md`

<critical>
Do NOT proceed to step-02 with incomplete data.
The interview is the foundation - gaps here create problems later.
If uncertain, ASK. Don't assume.
</critical>
