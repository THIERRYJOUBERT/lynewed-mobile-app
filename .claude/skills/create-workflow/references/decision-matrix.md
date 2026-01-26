# Claude Code Features Decision Matrix

> Reference for deciding WHEN to use each feature in a workflow.
> Used by /create-workflow during Step-03 (Design Architecture).
> Version: 3.0

---

## Quick Reference Table

| Feature | Use when... | Avoid when... |
|---------|-------------|---------------|
| `context: fork` | Multi-step isolation needed, 5+ steps | Need conversation history, meta-workflows |
| Subagents (Task) | Heavy exploration, parallel independent tasks | Sequential dependencies, simple lookups |
| Hooks | Automatic validation, security gates, side effects | Simple workflows, no automation needed |
| `allowed-tools` | Need to restrict capabilities for safety | Full capability workflow |
| `model: opus` | Main orchestration, complex decisions | Exploration, simple tasks |
| `model: sonnet` | Exploration agents, analysis, extraction | Main orchestration requiring complex reasoning |
| `model: haiku` | Simple, fast, repetitive tasks | Complex analysis |
| `disable-model-invocation` | Destructive/side-effect actions | Read-only analysis |
| `user-invocable: false` | Background knowledge, internal helpers | User-facing workflows |
| `!`cmd`` | Need real-time context at skill load time | Static context sufficient |
| `$ARGUMENTS` | Skill accepts user input | No arguments expected |

---

## Feature: context: fork

### What it does

Isolates the skill execution in a forked context, completely separate from the main conversation. The forked context starts fresh and does not inherit conversation history.

### Decision Table

| Scenario | Decision | Reason |
|----------|----------|--------|
| Multi-step workflow (5+ steps) | RECOMMENDED | Prevents context pollution in main conversation |
| Workflow produces many intermediate outputs | RECOMMENDED | Keeps main context clean and focused |
| Workflow needs heavy file reading (10+ files) | RECOMMENDED | Intermediate content stays in fork |
| Simple workflow (<3 steps) | NOT NEEDED | Overhead not justified for simple tasks |
| Workflow needs conversation history | DO NOT USE | Fork doesn't see previous context |
| Meta-workflows (like /create-workflow) | NEVER | Needs interview → design → generate flow with context |
| Interactive workflows with user decisions | DO NOT USE | User context would be lost |
| Reference/knowledge skills | DO NOT USE | Run inline to apply to current context |

### Critical Warning

```yaml
# NEVER use context: fork for meta-workflows or interactive workflows
# These depend on conversation history:
# - Interview answers inform design
# - Design decisions inform generation
# - Forking would lose this critical context
```

### Example: When to Fork

```yaml
---
name: generate-report
description: Generate comprehensive analysis report from codebase
context: fork  # Good: Heavy processing, many intermediate steps
---
```

### Example: When NOT to Fork

```yaml
---
name: coding-standards
description: Provides coding standards for the project
# NO context: fork - This is reference content that applies to conversation
---
```

### Interaction with Other Features

| Combined with | Result | Recommendation |
|---------------|--------|----------------|
| Subagents | Subagents inherit forked context | Works well for isolation |
| `user-invocable: false` | Claude invokes in fork | Good for internal processing |
| Hooks | Hooks run in fork context | Consider carefully |

---

## Feature: Subagents (Task tool)

### What it does

Delegates work to specialized agents with isolated context. Each agent runs independently and returns only a summary to the parent context.

### Decision Table

| Scenario | Decision | Reason |
|----------|----------|--------|
| Need to read >5 files for context | YES | Preserves main context, only summary returned |
| Independent parallel tasks | YES | 3x faster execution, optimal performance |
| Need specialized role (reviewer, debugger) | YES | Focused behavior with dedicated instructions |
| Complex exploration spanning many files | YES | Agent handles heavy lifting autonomously |
| Sequential dependent tasks | NO | Use main flow, agents can't share state |
| Simple lookups (<3 files) | NO | Overhead not justified |
| Tasks requiring conversation history | NO | Agents don't inherit full history |
| Tightly coupled operations | NO | State sharing would be needed |

### Model Selection Guide

| Task type | Model | Reason | Cost factor |
|-----------|-------|--------|-------------|
| Simple file search | haiku | Fast and cheap | ~1x |
| Pattern extraction | sonnet | Good quality, balance | ~3x |
| Complex analysis | sonnet | Sufficient for most analysis | ~3x |
| Exploration, discovery | sonnet | Best quality/cost for research | ~3x |
| Critical decisions | opus | Highest capability | ~15x |
| Main orchestration | opus | Complex multi-step reasoning | ~15x |

### Parallel Execution Pattern

```markdown
Launch 3 agents in SINGLE message for parallel execution:

**Agent 1 - Patterns** (model: sonnet):
Read references/patterns.md and extract patterns applicable to [context].
Return: List of applicable patterns with rationale.

**Agent 2 - Examples** (model: sonnet):
Search for similar workflows in .claude/skills/ directory.
Return: Reusable structures and conventions found.

**Agent 3 - System** (model: sonnet):
Read CLAUDE.md and .claude/rules/ to extract project constraints.
Return: Constraints and preferences that must be respected.
```

### Critical Rules

1. **All Task calls MUST be in ONE message** for parallel execution
2. **Never chain subagents sequentially** if they can run in parallel
3. **Each agent should have clear, bounded scope** - one responsibility
4. **Prefer 3 agents** - proven optimal balance of coverage vs overhead
5. **Use sonnet by default** for exploration agents (cost-effective)

### Anti-Patterns

```markdown
# BAD: Sequential when could be parallel
Launch Agent 1 to read file A
[wait for result]
Launch Agent 2 to read file B  # Could have run with Agent 1!

# BAD: Too many agents
Launch 7 agents for different aspects  # Overhead exceeds benefit

# BAD: Agent for trivial task
Launch Agent to count lines in one file  # Just Read the file directly
```

---

## Feature: Hooks

### What it does

Runs scripts automatically at specific points in Claude's workflow. Hooks provide deterministic automation and enforcement.

### Hook Types Overview

| Event | When it fires | Common uses |
|-------|---------------|-------------|
| PreToolUse | Before tool execution | Validation, blocking, confirmation |
| PostToolUse | After tool success | Tests, formatting, notifications |
| PostToolUseFailure | After tool failure | Error handling, cleanup |
| Stop | Response complete | Summary generation, final checks |

### PreToolUse Decision Table

| Scenario | Decision | Example command |
|----------|----------|-----------------|
| Validate before file write | YES | `{{LINT_CMD}}nfos` |
| Block dangerous operations | YES | `./scripts/check-no-secrets.sh` |
| Require confirmation for destructive actions | YES | `./scripts/confirm-delete.sh` |
| Format code before save | CONSIDER | `dart format $FILE` |
| Simple workflows | NO | Overhead not needed |

### PostToolUse Decision Table

| Scenario | Decision | Example command |
|----------|----------|-----------------|
| Run tests after edit | YES | `{{TEST_CMD}}` |
| Format code after write | YES | `prettier --write $FILE` |
| Trigger notifications | YES | `./notify-team.sh` |
| Update documentation | CONSIDER | `./update-docs.sh` |
| Logging/analytics | YES | `./log-action.sh` |

### Stop Hook Decision Table

| Scenario | Decision | Example use |
|----------|----------|-------------|
| Verify task completion | YES | Check all criteria met |
| Generate summary | YES | Create completion report |
| Cleanup temporary files | YES | Remove intermediate outputs |
| Push changes | CONSIDER | May want user control |

### Example: Development Quality Hooks

```yaml
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "echo 'Validating before write...'"
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "{{LINT_CMD}}nfos && {{TEST_CMD}}"
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/check-output.sh"
```

### Example: Security Hooks

```yaml
hooks:
  PreToolUse:
    - matcher: "Write"
      hooks:
        - type: command
          command: "./scripts/check-no-secrets.sh"
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh"
```

### When NOT to Use Hooks

- Simple reference content skills
- Workflows that need flexibility in execution order
- When automation would be fragile or unreliable
- When user control is preferred over automation

---

## Feature: allowed-tools

### What it does

Restricts which tools Claude can use within the skill. Implements principle of least privilege.

### Decision Table by Workflow Type

| Workflow type | Tools to allow | Reason |
|---------------|----------------|--------|
| Read-only exploration | Read, Glob, Grep | No modifications possible |
| Analysis with output | + Write | Need to create reports |
| Code generation | + Edit | Need to modify files |
| Full development | + Bash | Need shell access for tests/builds |
| Interactive | + AskUserQuestion | Need user input |
| With subagents | + Task | Need to delegate |
| Web research | + WebFetch, WebSearch | Need external info |
| No restrictions | (omit field) | Full capability |

### Common Configurations

```yaml
# Read-only exploration
allowed-tools:
  - Read
  - Glob
  - Grep

# Analysis workflow
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write

# Development workflow
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Bash
  - Task

# Interactive exploration
allowed-tools:
  - Read
  - Glob
  - Grep
  - AskUserQuestion
  - Task

# Full research
allowed-tools:
  - Read
  - Glob
  - Grep
  - WebFetch
  - WebSearch
  - Task
  - TodoWrite
```

### Principle

**MINIMUM NECESSARY** - Only allow what the workflow actually needs. This:
- Prevents accidental modifications
- Makes workflow intent clearer
- Improves security
- Helps debugging (fewer possible actions)

---

## Feature: model

### What it does

Specifies which Claude model to use for the skill execution.

### Decision Table

| Skill type | Model | Reason |
|------------|-------|--------|
| Main orchestration workflow | opus | Complex decisions, multi-step reasoning |
| Exploration/discovery agents | sonnet | Good quality, cost-effective |
| Simple extraction tasks | haiku | Fast and cheap |
| Code review | sonnet or opus | Depends on criticality |
| Reference content | (inherit) | Uses session model |

### Cost vs Capability Trade-off

| Model | Capability | Cost | Speed | Best for |
|-------|------------|------|-------|----------|
| opus | Highest | ~15x | Slower | Critical decisions, complex orchestration |
| sonnet | High | ~3x | Medium | Most exploration and analysis tasks |
| haiku | Good | ~1x | Fastest | Simple, repetitive, high-volume tasks |

### Example: Orchestration with Sonnet Agents

```yaml
---
name: complex-workflow
model: opus  # Main orchestration needs full capability
---

# In workflow content:
Launch 3 agents (model: sonnet) for exploration...
# Agents use sonnet for cost-effective exploration
```

---

## Feature: disable-model-invocation

### What it does

Prevents Claude from automatically invoking the skill. User MUST explicitly type `/name` to run it.

### Decision Table

| Scenario | Decision | Reason |
|----------|----------|--------|
| Destructive actions (deploy, delete) | YES | Safety - explicit user consent required |
| Side effects (commit, push, send) | YES | User control over external effects |
| Cost implications (API calls, resources) | YES | User controls spending |
| Time-consuming operations | CONSIDER | User should know about long operations |
| Read-only analysis | NO | Let Claude decide when relevant |
| Reference/knowledge content | NO | Let Claude use when helpful |
| Quick utilities | NO | Low friction for common tasks |

### Key Distinction

```yaml
# User-only: Must type /deploy to run
disable-model-invocation: true

# Default: Claude can invoke when user intent matches description
# (field omitted or set to false)
```

### Example: Deployment Workflow

```yaml
---
name: deploy
description: Deploy application to production environment
disable-model-invocation: true  # NEVER auto-invoke deployment
---
```

---

## Feature: user-invocable

### What it does

When set to `false`, hides the skill from the `/` menu. Only Claude can invoke it internally.

### Decision Table

| Scenario | Decision | Reason |
|----------|----------|--------|
| Background knowledge/context | false | Not an action users take |
| Internal helper skill | false | Implementation detail |
| Reference content (conventions, rules) | false | Claude loads when needed |
| Building blocks for other skills | false | Used internally |
| User-facing workflow | true (default) | Users should see it in menu |
| Utility the user might want directly | true | Visible and accessible |

### Combining with disable-model-invocation

| user-invocable | disable-model-invocation | Result |
|----------------|--------------------------|--------|
| true | false | **Normal**: user and Claude can invoke |
| true | true | **User-only**: visible in menu, Claude cannot auto-invoke |
| false | false | **Claude-only**: hidden, Claude invokes when relevant |
| false | true | **INVALID**: hidden AND blocked = never usable |

### Example: Internal Reference

```yaml
---
name: coding-conventions
description: Internal coding conventions reference
user-invocable: false  # Claude loads this, users don't invoke directly
---
```

---

## Feature: argument-hint

### What it does

Shows hint during autocomplete to indicate expected arguments.

### When to Use

**Always use when the skill accepts arguments.**

### Format Conventions

| Format | Meaning | Example |
|--------|---------|---------|
| `<arg>` | Required argument | `<issue-number>` |
| `[arg]` | Optional argument | `[--verbose]` |
| `<arg1> [arg2]` | First required, second optional | `<name> [--mode=create]` |
| `<arg1\|arg2>` | Either one required | `<create\|update>` |

### Examples

```yaml
# Simple required argument
argument-hint: "<workflow-name>"

# With description
argument-hint: "<workflow-name> - name of workflow to create or update"

# Multiple arguments
argument-hint: "<name> [--mode=create|update]"

# Issue reference
argument-hint: "<issue-number> - GitHub issue to fix"
```

---

## Feature: Dynamic Context Injection (!`cmd`)

### What it does

Runs shell command BEFORE sending content to Claude, injects the output into the skill content.

### Decision Table

| Scenario | Decision | Example command |
|----------|----------|-----------------|
| Current git state | YES | `git branch --show-current` |
| Environment info | YES | `echo $NODE_ENV` |
| File listings for context | YES | `ls -la src/` |
| Dynamic file discovery | YES | `find . -name "*.test.ts"` |
| Recent activity | YES | `git log --oneline -5` |
| Static information | NO | Just write it in the skill |
| Complex computation | CONSIDER | May be slow or unreliable |

### Syntax

```markdown
## Context

- Current branch: !`git branch --show-current`
- Modified files: !`git status --porcelain | head -10`
- Recent commits: !`git log --oneline -5`
- Test files: !`find test/ -name "*.test.ts" | head -5`
```

### Important Notes

1. Commands run BEFORE Claude sees the content
2. Command output replaces the placeholder
3. Claude sees the result, not the command
4. Keep commands fast and reliable
5. Handle potential command failures gracefully

### Example: Git-Aware Workflow

```markdown
---
name: smart-commit
description: Create intelligent commit based on current changes
---

## Current State

**Branch**: !`git branch --show-current`

**Status**:
```
!`git status --porcelain`
```

**Recent commits for style reference**:
```
!`git log --oneline -5`
```

Based on this context, create an appropriate commit message.
```

---

## Feature: $ARGUMENTS Substitution

### What it does

Replaces `$ARGUMENTS` with everything passed after `/skill-name` when invoking.

### When to Use

**Always use when the skill needs to reference user input.**

### Behavior

- If `$ARGUMENTS` appears in content: replaced with user input
- If `$ARGUMENTS` NOT in content: appended as `ARGUMENTS: <value>`

### Examples

```markdown
# User types: /fix-issue 123
# $ARGUMENTS becomes: 123

Fix GitHub issue $ARGUMENTS following the project's coding standards.

# User types: /search-code "function validate"
# $ARGUMENTS becomes: function validate

Search for $ARGUMENTS in the codebase and explain where it's used.
```

### Combined with argument-hint

```yaml
---
name: fix-issue
description: Fix a GitHub issue
argument-hint: "<issue-number>"
---

## Task

Fix GitHub issue #$ARGUMENTS following project coding standards.
```

---

## Decision Flowchart: Feature Selection

```
START: What kind of workflow?
│
├─► Reference Content (knowledge, conventions)
│   ├─ user-invocable: false
│   ├─ NO context: fork
│   └─ allowed-tools: Read, Glob, Grep (if any)
│
├─► Simple Task (<3 steps)
│   ├─ NO context: fork
│   ├─ NO subagents
│   └─ model: inherit or haiku
│
├─► Multi-Step Workflow (3-5 steps)
│   ├─ CONSIDER context: fork
│   ├─ CONSIDER subagents for heavy exploration
│   └─ model: opus (orchestration) + sonnet (agents)
│
├─► Complex Workflow (5+ steps)
│   ├─ context: fork (RECOMMENDED)
│   ├─ subagents for exploration phases
│   ├─ model: opus
│   └─ CONSIDER hooks for automation
│
├─► Interactive Workflow (user decisions)
│   ├─ NO context: fork (need history)
│   ├─ allowed-tools: + AskUserQuestion
│   └─ NO disable-model-invocation (unless destructive)
│
└─► Destructive/Side-Effect Workflow
    ├─ disable-model-invocation: true
    ├─ CONSIDER hooks for safety checks
    └─ CONSIDER allowed-tools restrictions
```

---

## Common Mistakes

### Mistake 1: Using fork for meta-workflows

```yaml
# WRONG
name: create-workflow
context: fork  # This loses interview context!

# RIGHT
name: create-workflow
# No fork - needs conversation history
```

### Mistake 2: Sequential agents when parallel possible

```markdown
# WRONG
Launch Agent 1 to gather patterns
[wait]
Launch Agent 2 to find examples
[wait]
Launch Agent 3 to read constraints

# RIGHT
Launch 3 agents in SINGLE message:
Agent 1: patterns
Agent 2: examples
Agent 3: constraints
```

### Mistake 3: Opus for everything

```yaml
# WRONG - expensive and unnecessary
model: opus  # For a simple file search agent

# RIGHT
model: sonnet  # Good enough for exploration
```

### Mistake 4: No tool restrictions on exploration skills

```yaml
# WRONG - exploration can accidentally modify files
allowed-tools: # (omitted = all tools)

# RIGHT
allowed-tools:
  - Read
  - Glob
  - Grep
```

### Mistake 5: disable-model-invocation on read-only skills

```yaml
# WRONG - adds friction for no benefit
name: code-analysis
disable-model-invocation: true  # Why? It's read-only

# RIGHT - let Claude use it when relevant
name: code-analysis
# (field omitted)
```

---

## Feature Compatibility Matrix

| Feature A | Feature B | Compatible | Notes |
|-----------|-----------|------------|-------|
| context: fork | user-invocable: false | ✅ | Claude forks internally |
| context: fork | needs history | ❌ | Fork loses history |
| subagents | context: fork | ✅ | Agents run in forked context |
| subagents | sequential tasks | ⚠️ | Works but loses parallelism benefit |
| disable-model-invocation | user-invocable: false | ❌ | Never usable |
| hooks | context: fork | ✅ | Hooks run in fork |
| allowed-tools | subagents | ✅ | Each can have own restrictions |
| model: opus | subagents | ✅ | Agents can override model |

---

## Summary Checklist

Before finalizing your workflow design, verify:

- [ ] Did you choose the right `context` setting based on history needs?
- [ ] Are subagents used for heavy exploration (>5 files)?
- [ ] Are parallel tasks launched in ONE message?
- [ ] Is the model appropriate for each component's complexity?
- [ ] Are tools restricted to minimum necessary?
- [ ] Are destructive actions protected with `disable-model-invocation`?
- [ ] Is `argument-hint` set if arguments are expected?
- [ ] Is dynamic context (`!`cmd``) used for real-time info?
- [ ] Is `$ARGUMENTS` used to reference user input?
