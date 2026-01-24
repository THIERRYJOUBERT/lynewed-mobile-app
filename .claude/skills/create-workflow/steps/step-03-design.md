# Step 03: Design

> Purpose: Design workflow architecture with justification for each choice.

---

## MANDATORY RULES (READ FIRST)

- 🎯 ALWAYS justify EVERY CC feature decision
- 📊 Use exploration results to inform decisions
- ✅ Each step must have distinct, non-overlapping purpose
- 🚫 NEVER add features without clear justification

## PROTOCOLS

- 🎯 **Goal**: Complete workflow architecture with justified decisions
- 💾 **Output**: `{design}` object with type, features, steps, flow
- 📖 **Reference**: `{exploration_results}` from step-02
- ⚡ **Performance**: Design once, well - avoid redesign cycles

---

## CONTEXT

**Available from previous steps:**
- `{interview_data}` - Complete requirements (step-01)
- `{exploration_results}` - Patterns, similar workflows, constraints (step-02)
  - `{exploration_results.patterns.recommended_features}` - CC feature recommendations
  - `{exploration_results.similar_workflows}` - Inspiration from existing
  - `{exploration_results.system}` - Conventions and constraints

**Produced by this step:**
- `{design}` - Complete design document
- `{manifest_draft}` - Initial manifest.yaml content

**NOT available (do not use):**
- `{generated_files}` - Not yet created (step-05)
- `{critique_results}` - Not yet performed (step-06)

---

## TASK

Design the complete workflow architecture:
1. Classify workflow type
2. Decide CC features with justifications
3. Design step structure (if multi-step)
4. Create flow diagram
5. Identify risks and mitigations

---

## EXECUTION

### 1. Classify Workflow Type

Determine the workflow type based on objective and outputs.

**Decision Tree:**

```
{interview_data.objective} analysis:
│
├─ Primarily knowledge/guidelines/reference?
│  └─ TYPE = "reference"
│
└─ Primarily actions/generation/tasks?
   │
   ├─ Less than 3 distinct steps?
   │  └─ TYPE = "task-simple"
   │
   └─ 3 or more distinct steps?
      └─ TYPE = "task-workflow"
```

**Type Characteristics:**

| Type | Template | Steps | Typical Use |
|------|----------|-------|-------------|
| `reference` | `skill-reference.md` | None | Knowledge, patterns, guidelines |
| `task-simple` | `skill-task-simple.md` | None (inline) | Quick actions, simple generation |
| `task-workflow` | `skill-task-workflow.md` | Multiple files | Complex multi-phase processes |

**Record:**
```yaml
workflow_type: "reference" | "task-simple" | "task-workflow"
type_justification: "Why this type was chosen"
```

---

### 2. Decide CC Features

For EACH feature, make explicit decision with justification.
Use `{exploration_results.patterns.recommended_features}` as input.

#### Feature: context:fork

**Question**: Should this workflow start with a fresh context?

**Decision Matrix:**
| Condition | Decision | Reason |
|-----------|----------|--------|
| Multi-step needing isolation | YES | Prevents context pollution |
| Needs conversation history | NO | Loses important context |
| Meta-workflow (creates workflows) | NO | Needs full conversation |
| Simple one-shot task | Usually NO | Overhead not worth it |

**Record:**
```yaml
context_fork:
  decision: true | false
  justification: "..."
```

#### Feature: Subagents

**Question**: Does this workflow need specialized agents?

**Decision Matrix:**
| Condition | Decision | Reason |
|-----------|----------|--------|
| Heavy exploration (>5 files) | YES | Isolate exploration context |
| Parallelizable independent tasks | YES | Speed improvement |
| Need different models for tasks | YES | Cost optimization |
| Simple sequential work | NO | Overhead not worth it |

If YES, define each agent:
```yaml
subagents:
  needed: true
  agents:
    - name: "agent-name"
      role: "What this agent does"
      model: "sonnet" | "haiku" | "opus"
      tools: ["Tool1", "Tool2"]
  justification: "Why subagents are needed"
```

#### Feature: Hooks

**Question**: Should automatic actions occur?

**Decision Matrix:**
| Condition | Hook Type | Example |
|-----------|-----------|---------|
| Auto-validate outputs | PostToolUse | Run linter after Write |
| Block dangerous operations | PreToolUse | Prevent force push |
| Side effects on success | PostToolUse | Git commit after generation |
| Intercept specific patterns | PreToolUse | Validate file paths |

If YES, define each hook:
```yaml
hooks:
  needed: true
  hooks:
    - event: "PreToolUse" | "PostToolUse"
      matcher: "Tool pattern or regex"
      action: "What happens"
  justification: "Why hooks are needed"
```

#### Feature: allowed-tools

**Question**: Which tools does this workflow need?

**Principle**: Minimum necessary for the task.

| Workflow Type | Typical Tools |
|---------------|---------------|
| Read-only/analysis | Read, Glob, Grep, Task |
| Generation | + Write, Edit |
| System interaction | + Bash |
| User interaction | + AskUserQuestion |
| Web research | + WebSearch, WebFetch |

```yaml
allowed_tools:
  list: ["Read", "Glob", "Grep", "Write", "Edit"]
  justification: "Why each tool is needed"
```

#### Feature: model

**Question**: Which model should execute this workflow?

| Model | When to Use | Cost |
|-------|-------------|------|
| `opus` | Complex reasoning, orchestration | High |
| `sonnet` | Balanced tasks, exploration | Medium |
| `haiku` | Simple/repetitive tasks | Low |

```yaml
model:
  choice: "opus" | "sonnet" | "haiku"
  justification: "Why this model"
```

#### Feature: disable-model-invocation

**Question**: Should Claude be prevented from auto-invoking?

| Condition | Decision | Reason |
|-----------|----------|--------|
| Side effects (deploy, delete) | YES | User must control |
| Safe read-only operations | NO | Auto-invoke is helpful |
| Destructive potential | YES | Prevent accidents |

```yaml
disable_model_invocation:
  decision: true | false
  justification: "..."
```

#### Feature: user-invocable

**Question**: Can users invoke this via /command?

| Condition | Decision |
|-----------|----------|
| User workflow | YES |
| Internal/system workflow | NO |
| Helper workflow for other workflows | NO |

```yaml
user_invocable:
  decision: true | false
  justification: "..."
```

---

### 3. Design Steps (if task-workflow)

For `workflow_type: "task-workflow"`, design each step.

**Step Design Principles:**
- Each step = one specialized role for Claude
- Steps should have distinct, non-overlapping purposes
- Minimize step count (no useless steps)
- Each step must have clear validation criteria

**For each step, define:**
```yaml
steps:
  - number: "01"
    name: "step-name"  # kebab-case
    purpose: "One sentence describing what this step does"
    claude_role: "What role Claude takes in this step"
    inputs:
      - name: "input_var"
        source: "step-00" | "user" | "previous"
    outputs:
      - name: "output_var"
        type: "string" | "object" | "list"
    validation:
      - "Criterion 1"
      - "Criterion 2"
    failure_handling: "What to do if step fails"
```

---

### 4. Create Flow Diagram

Create ASCII diagram showing execution flow.

**Template:**
```
┌─────────────────────────────────────────────────────────┐
│                  WORKFLOW: {name}                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────┐                                           │
│  │  START   │                                           │
│  └────┬─────┘                                           │
│       │                                                  │
│       ▼                                                  │
│  ┌──────────┐                                           │
│  │ Step 01  │ {purpose}                                 │
│  └────┬─────┘                                           │
│       │                                                  │
│       ▼                                                  │
│  ┌──────────┐     ┌──────────┐                          │
│  │ Step 02  │────►│ Validate │ {checkpoint?}            │
│  └────┬─────┘     └────┬─────┘                          │
│       │                │                                 │
│       ▼                ▼                                 │
│  ┌──────────┐     ┌──────────┐                          │
│  │  OUTPUT  │     │   FAIL   │                          │
│  └──────────┘     └──────────┘                          │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

Include:
- Entry point
- All steps in sequence
- Decision/branch points
- Validation checkpoints
- Failure paths
- Output/completion

---

### 5. Identify Risks

For each potential failure point:

```yaml
risks:
  - risk: "What could go wrong"
    likelihood: "low" | "medium" | "high"
    impact: "low" | "medium" | "high"
    mitigation: "How to prevent or handle"
    fallback: "What to do if it happens"
```

**Common risks to consider:**
- User provides incomplete/invalid input
- External dependencies fail
- Context grows too large
- Model makes reasoning errors
- File operations fail
- Validation loops infinitely

---

## OUTPUT STRUCTURE

Compile complete design:

```yaml
design:
  workflow_name: "{from interview_data}"
  workflow_type: "reference" | "task-simple" | "task-workflow"
  type_justification: "..."

  cc_features:
    context_fork:
      decision: bool
      justification: "..."
    subagents:
      needed: bool
      agents: [...]  # if needed
      justification: "..."
    hooks:
      needed: bool
      hooks: [...]  # if needed
      justification: "..."
    allowed_tools:
      list: [...]
      justification: "..."
    model:
      choice: "..."
      justification: "..."
    disable_model_invocation:
      decision: bool
      justification: "..."
    user_invocable:
      decision: bool
      justification: "..."

  steps: [...]  # if task-workflow

  flow_diagram: |
    (ASCII diagram)

  risks:
    - risk: "..."
      mitigation: "..."
    - ...

manifest_draft:
  name: "{workflow_name}"
  description: "{from interview objective}"
  type: "{workflow_type}"
  version: "1.0.0"
  created: "{current_date}"
  cc_features:
    (summary of feature decisions)
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ Workflow type is definitively chosen and justified
✅ EVERY CC feature has explicit decision AND justification
✅ Steps (if any) have distinct, non-overlapping purposes
✅ Flow diagram accurately represents execution
✅ Risks identified with mitigations

**Self-Critique Questions:**
- Is the type choice the simplest that works?
- Are there features decided without clear need?
- Could steps be consolidated without loss?
- Are there missing risks?
- Would another Claude understand this design?

**If validation fails:**
1. Review exploration results for missed context
2. Reconsider feature decisions
3. Max 2 design iterations
4. If uncertain: Flag for user decision in step-04

---

## SUCCESS / FAILURE

**Success:**
✅ Complete `{design}` object with all sections
✅ All decisions justified (no "because we can")
✅ Clear structure ready for generation
✅ Risks documented with mitigations

**Failure modes:**
❌ Cannot decide between types → Ask user preference in step-04
❌ Conflicting feature recommendations → Present options in step-04
❌ Too many steps → Consolidate or consider simpler type
❌ No clear output → Re-examine interview data

---

## NEXT

After validation passes, load `steps/step-04-checkpoint.md`

<critical>
Every decision MUST have justification.
"We use subagents because they're cool" is NOT valid.
"We use subagents because we need to explore >10 files and isolate that context" IS valid.
</critical>
