# Unified Workflow Patterns

> Fusion of official Claude Code best practices + {{PROJECT_NAME}} validated patterns
> Version: 3.0
> Sources: Official docs + /create-epic v7 + /oneshot v2 + SYSTEM.md

---

## Quick Reference Table

| ID | Pattern | Category | One-liner | Required |
|----|---------|----------|-----------|----------|
| A1 | Multi-File Architecture | Architecture | SKILL.md + steps/ + templates/ + references/ | For 3+ steps |
| A2 | Progressive Step Loading | Architecture | Load ONE step at a time | Yes |
| A3 | Two Content Types | Architecture | Reference OR Task, not both | Yes |
| E1 | Model Strategy | Execution | opus orchestrate, sonnet explore, haiku simple | Yes |
| E2 | Parallel Agent Execution | Execution | 3 Tasks in 1 message | For exploration |
| E3 | Context Isolation | Execution | Fork or subagents for heavy ops | For heavy ops |
| Q1 | APEX Self-Validation | Quality | Validate EACH step before proceeding | Yes |
| Q2 | Adversarial Review | Quality | Change role to critic | Yes |
| Q3 | Verification First | Quality | Define success criteria upfront | Yes |
| Q4 | Completeness Challenge | Quality | 5-check responsibility | Yes |
| R1 | Fallback Strategies | Resilience | Always have plan B | Yes |
| R2 | Gap Documentation | Resilience | Document and continue | Yes |
| R3 | Self-Healing Loop | Resilience | Learn from failures, max 5 | Yes |
| S1 | Sandwich Structure | Structure | Critical rules at START and END | Yes |
| S2 | State Variable Management | Structure | Explicit data flow between steps | For multi-step |
| S3 | Single Entry Point | Structure | SKILL.md directs to first step | Yes |
| I1 | Intelligent Interview | Interaction | Hybrid structured questions | For interactive |
| I2 | Strategic Checkpoints | Interaction | Human validation at critical only | When needed |
| I3 | Minimal User Interaction | Interaction | Capture needs upfront, work autonomously | Yes |
| G1 | Dynamic Context Injection | Integration | !`cmd` syntax for real-time | When needed |
| G2 | Hook Integration | Integration | Deterministic automation | When needed |

---

## Category: Architecture Patterns

### Pattern A1: Multi-File Architecture

**Source**: {{PROJECT_NAME}} Pattern #1 + Official documentation
**Required**: For workflows with 3+ steps

**Principle**: Separate concerns for maintainability and progressive loading.

**Standard Structure**:
```
skill/
├── SKILL.md           # Entry point compact (< 500 lines)
├── steps/             # One file per step (100-200 lines each)
│   ├── step-00-init.md
│   ├── step-01-analyze.md
│   ├── step-02-design.md
│   └── step-03-execute.md
├── templates/         # Active templates with {{PLACEHOLDERS}}
│   ├── skill-template.md
│   └── step-template.md
└── references/        # On-demand documentation
    ├── patterns.md
    └── examples.md
```

**When to use**:
- Multi-step workflows (3+ steps)
- Workflow would exceed 300 lines if monolithic
- Need progressive loading to maintain LLM attention
- Multiple templates or reference documents

**When NOT to use**:
- Simple reference content skills (just knowledge, no steps)
- Task content with <3 steps
- Quick utility commands

**Benefits**:
- Each step gets maximum attention (recency effect)
- Easier maintenance and updates
- Clear separation of concerns
- Templates are reusable

---

### Pattern A2: Progressive Step Loading

**Source**: {{PROJECT_NAME}} Pattern #10 + "Lost in the Middle" research
**Required**: Yes, for multi-step workflows

**Principle**: Load ONE step at a time for maximum LLM attention.

**Why it works**:
LLMs pay most attention to the START and END of context. By loading one step at a time, the current step is always at the END (most recent), receiving maximum attention.

**Implementation**:
```markdown
# In SKILL.md
<entry_point>
Read and execute `steps/step-00-init.md`
</entry_point>

# In each step file
---
step: 01
name: analyze
prev_step: steps/step-00-init.md
next_step: steps/step-02-design.md
---

## Step 01: Analyze

[Step content...]

## NEXT STEP

When complete, read and execute `steps/step-02-design.md`
```

**Anti-pattern**: Loading all steps at once

```markdown
# BAD: Loads everything upfront
Read all files in steps/ directory and execute in order.

# GOOD: Progressive loading
Read and execute steps/step-00-init.md
(Step 00 will direct to step 01, etc.)
```

---

### Pattern A3: Two Content Types

**Source**: Official Claude Code documentation
**Required**: Yes

**Principle**: A skill is either Reference Content OR Task Content, never both.

**Reference Content**:
- Knowledge Claude applies to ongoing work
- Conventions, patterns, style guides, rules
- Runs inline with conversation (no fork)
- Usually `user-invocable: false`
- Claude loads when relevant

**Examples**:
```yaml
---
name: coding-standards
description: Coding standards for the project
user-invocable: false
---

# Coding Standards
- Use meaningful variable names
- Write tests for all public functions
- Document complex logic
```

**Task Content**:
- Step-by-step instructions to execute
- Produces specific outputs or side effects
- Often user-invoked with arguments
- May use `context: fork` for isolation

**Examples**:
```yaml
---
name: create-component
description: Creates a new React component with tests
argument-hint: "<component-name>"
---

## Task: Create Component

1. Create component file at src/components/$ARGUMENTS.tsx
2. Create test file at src/components/$ARGUMENTS.test.tsx
3. Export from index.ts
```

**Decision guide**:
```
IF skill provides knowledge/guidelines → Reference Content
IF skill performs actions/generates outputs → Task Content
```

---

## Category: Execution Patterns

### Pattern E1: Model Strategy

**Source**: {{PROJECT_NAME}} Pattern #2 + Official documentation
**Required**: Yes

**Principle**: Match model capability to task complexity.

| Task | Model | Reason |
|------|-------|--------|
| Main orchestration | opus | Complex multi-step decisions |
| Exploration agents | sonnet | Good quality, 3x cheaper than opus |
| Simple/repetitive tasks | haiku | Fast and cheap, sufficient capability |
| Code review | sonnet | Balance of quality and cost |
| Critical analysis | opus | Highest reasoning capability |

**Implementation in skill**:
```yaml
---
name: complex-workflow
model: opus  # Main orchestration
---

# In content, subagents use sonnet:
Launch 3 agents (model: sonnet) for exploration...
```

**Cost considerations**:
- opus: ~15x base cost - use for critical decisions
- sonnet: ~3x base cost - default for agents
- haiku: ~1x base cost - use for high-volume simple tasks

---

### Pattern E2: Parallel Agent Execution

**Source**: {{PROJECT_NAME}} Pattern #6 + Official documentation
**Required**: For exploration phases

**Principle**: Performance via parallelization of independent tasks.

**The 3-Agent Pattern** (proven optimal):
```markdown
Launch 3 agents in SINGLE MESSAGE for parallel execution.

CRITICAL: All Task calls MUST be in ONE message.

**Agent 1 - Pattern Analysis** (model: sonnet):
Read references/patterns.md and identify applicable patterns.
Return: Prioritized list with rationale.

**Agent 2 - Example Discovery** (model: sonnet):
Search .claude/skills/ for similar workflows.
Return: Reusable structures and conventions.

**Agent 3 - Constraint Extraction** (model: sonnet):
Read CLAUDE.md and .claude/rules/ for constraints.
Return: Must-respect constraints and preferences.
```

**Why 3 agents**:
- Optimal performance/overhead balance
- Natural coverage split: patterns + examples + constraints
- Proven effective in /create-epic v7

**Anti-pattern**: Sequential agents

```markdown
# BAD: Sequential execution
Launch Agent 1 to read patterns
[wait for result]
Launch Agent 2 to find examples
[wait for result]
Launch Agent 3 to extract constraints

# GOOD: Parallel execution
Launch 3 agents in SINGLE message:
[All agents defined together]
```

---

### Pattern E3: Context Isolation

**Source**: Official documentation (subagents + context: fork)
**Required**: For heavy operations

**Principle**: Heavy operations shouldn't pollute main context.

**When to isolate**:
- Reading >5 files
- Generating verbose intermediate output
- Tasks that don't need conversation history
- Processing that produces temporary artifacts

**Methods of isolation**:

| Method | Use when |
|--------|----------|
| `context: fork` | Entire skill should be isolated |
| Subagents (Task) | Specific operations need isolation |

**Fork approach**:
```yaml
---
name: heavy-analysis
context: fork
---
# All operations run in isolated context
```

**Subagent approach**:
```markdown
# Main context orchestrates, agents do heavy lifting
Launch agent to analyze all 50 test files...
# Agent reads files, returns only summary
```

---

## Category: Quality Patterns

### Pattern Q1: APEX Self-Validation

**Source**: {{PROJECT_NAME}} Pattern #3 + core-rules.md
**Required**: Yes

**Principle**: Autonomous validation at EACH step before proceeding.

**Standard structure in every step**:
```markdown
## AUTO-VALIDATION

**Before proceeding, verify:**
- [ ] Criterion 1: [specific, measurable check]
- [ ] Criterion 2: [specific, measurable check]
- [ ] Criterion 3: [specific, measurable check]

**Self-Critique Questions:**
- Could this fail silently? How?
- Is there an edge case not covered?
- Would another agent interpret this unambiguously?

**If validation fails:**
1. Identify specific failure
2. Apply correction (max 3 attempts)
3. If still failing, document and escalate
```

**Key characteristics**:
- Criteria must be concrete and verifiable
- Questions must challenge assumptions
- Failure path must be defined

---

### Pattern Q2: Adversarial Review

**Source**: {{PROJECT_NAME}} core-rules.md (Review Adversariale)
**Required**: Yes, after generation phases

**Principle**: After building, change role to CRITIC.

**Implementation**:
```markdown
## ADVERSARIAL REVIEW

"I am now a Senior Reviewer whose sole purpose is to FIND PROBLEMS."

**Questions to ask:**
1. What could go wrong with this output?
2. What's the most obvious weakness?
3. Could another agent execute this unambiguously?
4. Is there over-engineering? Under-engineering?
5. What assumption might be wrong?

**If 0 problems found:**
⚠️ This is suspicious. Re-examine more carefully.

**For each problem found:**
- Severity: CRITICAL | HIGH | MEDIUM | LOW
- Description: What's wrong
- Location: Where in the output
- Fix: How to correct it
```

**The Rule**: Finding 0 problems is a red flag. Always find at least one area for improvement.

---

### Pattern Q3: Verification First

**Source**: Official documentation
**Required**: Yes

**Principle**: Include verification criteria BEFORE generating.

**Implementation**:
```markdown
## EXPECTED OUTPUT

The generated workflow must:
- [ ] Have valid YAML frontmatter
- [ ] Include all required sections
- [ ] Follow naming conventions
- [ ] Have no placeholder text

## GENERATION

Now generate the workflow...

## VERIFICATION

Check against expected output criteria above.
```

**Benefits**:
- Claude can self-verify against defined criteria
- Clear definition of "done"
- Prevents incomplete outputs

---

### Pattern Q4: Completeness Challenge

**Source**: {{PROJECT_NAME}} Pattern #4
**Required**: Yes, before finalizing

**Principle**: Agent takes RESPONSIBILITY for completeness.

**The 5 Mandatory Checks**:

```markdown
## COMPLETENESS CHALLENGE

Before declaring this complete, verify:

1. **Step Coverage**
   - Does each step have a clear, distinct purpose?
   - Is the step sequence logical?
   - Are there missing steps?

2. **Pattern Application**
   - Which patterns from patterns-unified.md apply?
   - Are all applicable patterns used?
   - If a pattern is skipped, why?

3. **Failure Modes**
   - What could fail at each step?
   - Is there a fallback for each failure?
   - Is escalation defined?

4. **State Flow**
   - What data flows between steps?
   - Are all variables documented?
   - Is the flow complete from start to end?

5. **Adversarial Test**
   - Could another agent execute this successfully?
   - Is there any ambiguity?
   - What questions would a new reader have?
```

---

## Category: Resilience Patterns

### Pattern R1: Fallback Strategies

**Source**: {{PROJECT_NAME}} Pattern #8
**Required**: Yes

**Principle**: Never block on error, always have plan B.

**Implementation**:
```markdown
## ERROR HANDLING

**If [operation] fails:**
1. **Fallback 1**: [alternative approach]
2. **Fallback 2**: [degraded mode]
3. **Fallback 3**: [minimum viable outcome]
4. **Max 3 attempts** with learning between each
5. **If all fail**: Document gap and proceed with what's available

**Example:**
If file not found:
1. Search for similar filename
2. Ask user for correct path
3. Proceed without this input, noting the gap
```

**Anti-pattern**: Blocking on first error

```markdown
# BAD
If file not found, STOP and report error.

# GOOD
If file not found:
1. Try alternative locations
2. If still not found, document as gap
3. Continue with available information
```

---

### Pattern R2: Gap Documentation

**Source**: {{PROJECT_NAME}} Pattern #9
**Required**: Yes

**Principle**: Document and continue > block on missing info.

**Implementation**:
```markdown
## GAPS TRACKING

When information is unavailable, document:

```yaml
gaps:
  - type: "discovery_failure"
    description: "Could not find test patterns"
    location: "step-02"
    impact: medium
    mitigation: "Using default patterns"
  - type: "missing_input"
    description: "User didn't specify database type"
    location: "step-01"
    impact: low
    mitigation: "Assumed PostgreSQL based on project"
```

**Gap severity**:
| Level | Impact | Action |
|-------|--------|--------|
| critical | Cannot proceed | Escalate immediately |
| high | Quality affected | Document, apply fallback |
| medium | Suboptimal output | Document, continue |
| low | Minor issue | Note and continue |
```

---

### Pattern R3: Self-Healing Loop

**Source**: {{PROJECT_NAME}} core-rules.md
**Required**: Yes

**Principle**: Learn from failures, don't repeat same mistake.

**Implementation**:
```
ATTEMPT 1 → FAIL → ANALYZE → ADJUST →
ATTEMPT 2 → FAIL → ANALYZE → ADJUST →
... (max 5 attempts)
ATTEMPT 5 → FAIL → ESCALATE with full report
```

**Critical rule**:
> "Each attempt MUST learn from the previous. Repeating the same approach 5 times = failure of the self-healing pattern."

**Structure**:
```markdown
## SELF-HEALING PROTOCOL

On failure:
1. **Analyze**: Why did it fail? Root cause?
2. **Adjust**: What should change for next attempt?
3. **Log**: Record attempt, analysis, adjustment
4. **Retry**: With adjusted approach

After 5 failures:
- Generate report of all attempts
- Explain what was tried and learned
- Recommend next steps
- Escalate to user
```

---

## Category: Structure Patterns

### Pattern S1: Sandwich Structure

**Source**: {{PROJECT_NAME}} Pattern #13
**Required**: Yes

**Principle**: Critical rules at START and END of content.

**Why it works**: LLM attention is highest at the beginning and end of context. Critical information in the middle gets less attention.

**Implementation**:
```markdown
# START OF STEP

## MANDATORY RULES

🛑 **CRITICAL**: Never skip validation
🛑 **CRITICAL**: Always check prerequisites
✅ **REQUIRED**: Document all decisions

---

[... main step content ...]

---

## END OF STEP

<critical>
REMINDER: The rules above are NON-NEGOTIABLE.
- Validation is mandatory
- Documentation is required
- Proceed only when criteria met
</critical>
```

---

### Pattern S2: State Variable Management

**Source**: {{PROJECT_NAME}} Pattern #11
**Required**: For multi-step workflows

**Principle**: Explicit data flow between steps.

**Implementation**:
```markdown
## CONTEXT BOUNDARIES

**Available from previous steps:**
- `{workflow_name}` - from step-00 (user input)
- `{requirements}` - from step-01 (analysis)
- `{architecture}` - from step-02 (design)

**Produced by this step:**
- `{generated_files}` - list of created files
- `{validation_result}` - pass/fail with details

**NOT available (produced later):**
- `{final_output}` - produced in step-05
```

**Benefits**:
- Clear data dependencies
- Easier debugging
- Prevents assumptions about unavailable data

---

### Pattern S3: Single Entry Point

**Source**: Official documentation + {{PROJECT_NAME}}
**Required**: Yes

**Principle**: SKILL.md is the only entry, directs to first step.

**Implementation**:
```markdown
# In SKILL.md

[Frontmatter and overview...]

## Execution

<entry_point>
Read and execute `steps/step-00-init.md`
</entry_point>

Do NOT read other files until directed by the step sequence.
```

**Anti-pattern**: Multiple entry points

```markdown
# BAD: Unclear where to start
You can start with step-01 or step-02 depending on context.

# GOOD: Single entry
Start by reading steps/step-00-init.md
```

---

## Category: Interaction Patterns

### Pattern I1: Intelligent Interview

**Source**: Official documentation ("Let Claude interview you")
**Required**: For interactive workflows

**Principle**: Hybrid structured interview for complex needs.

**Structure**:
```
1. Base questions (always ask)
   - What is the primary goal?
   - What type of workflow?

2. Contextual questions (based on answers)
   - If creating: What should it generate?
   - If updating: What needs to change?

3. Technical questions (adaptive)
   - Based on workflow type
   - Based on complexity detected
```

**Implementation**:
```markdown
## INTERVIEW

Use AskUserQuestion with structured options:

**Question 1**: What type of workflow?
- Options: [Reference Content, Task Workflow, Meta-Workflow]
- Based on answer, determine follow-up questions

**Question 2** (if Task Workflow):
- How many steps expected?
- Options: [Simple (1-2), Medium (3-5), Complex (5+)]
```

---

### Pattern I2: Strategic Checkpoints

**Source**: Design decision for /create-workflow v3
**Required**: When user validation is critical

**Principle**: Human validation at critical moments only.

**When to checkpoint**:
- After design, before generation (major decisions made)
- In UPDATE mode, before modifying existing files
- Before destructive operations
- When significant user preference affects outcome

**When NOT to checkpoint**:
- After every step (too much friction)
- After simple operations
- When autonomous execution is expected
- For read-only operations

**Implementation**:
```markdown
## CHECKPOINT

**Summary of decisions:**
- Workflow type: Task Content
- Architecture: Multi-file with 5 steps
- Features: context: fork, model: opus

**Waiting for user approval before proceeding to generation.**

Use AskUserQuestion:
- "Proceed with this design?"
- Options: [Approve, Modify, Cancel]
```

---

### Pattern I3: Minimal User Interaction

**Source**: {{PROJECT_NAME}} Pattern #7 (nuanced)
**Required**: Yes

**Principle**: Capture needs efficiently upfront, then work autonomously.

**Implementation**:
```
PHASE 1: Gather (interactive)
- Ask essential questions only
- Use structured options when possible
- Batch related questions

PHASE 2: Work (autonomous)
- Execute without interruption
- Apply self-validation
- Use self-healing for errors

PHASE 3: Deliver (interactive only if needed)
- Present final output
- Ask only if user decision required
```

**Anti-pattern**: Constant confirmation

```markdown
# BAD: Too many interruptions
Step 1 complete. Proceed? [Yes/No]
Step 2 complete. Proceed? [Yes/No]
Step 3 complete. Proceed? [Yes/No]

# GOOD: Autonomous with strategic checkpoints
[Gather requirements]
[Design checkpoint - one approval]
[Generate autonomously]
[Deliver final output]
```

---

## Category: Integration Patterns

### Pattern G1: Dynamic Context Injection

**Source**: Official documentation (!`cmd` syntax)
**Required**: When real-time context needed

**Principle**: Inject runtime context before Claude processes skill.

**Implementation**:
```markdown
## Current Context

- **Branch**: !`git branch --show-current`
- **Status**: !`git status --porcelain | head -10`
- **Recent commits**: !`git log --oneline -5`
- **Changed files**: !`git diff --name-only`
```

**Use cases**:
- Git state for commit/PR workflows
- Environment variables
- Dynamic file discovery
- Current timestamps

**Best practices**:
- Keep commands fast
- Limit output (use `head`, `tail`)
- Have fallback for empty output

---

### Pattern G2: Hook Integration

**Source**: Official documentation (Hooks reference)
**Required**: When deterministic automation needed

**Principle**: Use hooks for automatic, deterministic actions at lifecycle points.

**Common patterns**:

```yaml
# Quality gate on file write
hooks:
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "{{LINT_CMD}}nfos"

# Security check before write
hooks:
  PreToolUse:
    - matcher: "Write"
      hooks:
        - type: command
          command: "./scripts/check-no-secrets.sh"

# Completion verification
hooks:
  Stop:
    - hooks:
        - type: command
          command: "./scripts/verify-complete.sh"
```

**When to use hooks vs in-workflow checks**:
| Scenario | Approach |
|----------|----------|
| Must always run, no exceptions | Hook |
| Conditional based on context | In-workflow |
| External tool integration | Hook |
| Complex decision logic | In-workflow |

---

## Pattern Application Guide

### For Simple Reference Skills

Apply these patterns:
- A3 (Two Content Types) - mark as Reference
- S1 (Sandwich) - critical info at start/end
- I3 (Minimal Interaction) - no interaction needed

Skip these:
- A1 (Multi-File) - single file sufficient
- A2 (Progressive Loading) - no steps
- E2 (Parallel Agents) - no exploration

### For Multi-Step Task Workflows

Apply ALL patterns, especially:
- A1 (Multi-File Architecture)
- A2 (Progressive Step Loading)
- E1 (Model Strategy)
- E2 (Parallel Agents) - for exploration
- Q1-Q4 (All quality patterns)
- R1-R3 (All resilience patterns)
- S1-S3 (All structure patterns)

### For Interactive Workflows

Additional emphasis on:
- I1 (Intelligent Interview)
- I2 (Strategic Checkpoints)
- Pattern avoidance: `context: fork` (need history)

---

## See Also

- [decision-matrix.md](decision-matrix.md) - WHEN to use Claude Code features
- [features-guide.md](features-guide.md) - Claude Code features reference
- [quality-criteria.md](quality-criteria.md) - Validation checklist
