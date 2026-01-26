# Claude Code Features Guide

> Complete reference for Claude Code features available in skills and workflows.
> Source: Official Claude Code documentation (2025-2026)
> Version: 3.0

---

## Overview

This guide documents all Claude Code features usable when building workflows. For guidance on WHEN to use each feature, see [decision-matrix.md](decision-matrix.md).

---

## Skill Configuration (Frontmatter)

Skills use YAML frontmatter to configure their behavior. The frontmatter appears between `---` markers at the top of the SKILL.md file.

### name

**Type**: string
**Required**: No (defaults to directory name)
**Format**: lowercase letters, numbers, hyphens (max 64 characters)

```yaml
---
name: my-workflow
---
```

**Purpose**: Defines the `/slash-command` for invoking the skill.

**Best practices**:
- Use descriptive, concise names (2-3 words max)
- Use hyphens for multi-word names
- Avoid abbreviations unless universally understood
- Match the directory name for consistency

**Examples**:
```yaml
name: create-workflow    # Good: clear and concise
name: cw                 # Bad: unclear abbreviation
name: my_workflow        # Bad: underscores not allowed
```

---

### description

**Type**: string
**Required**: Recommended
**Purpose**: Tells Claude when to automatically invoke this skill

```yaml
---
name: code-review
description: "Reviews code for quality and security issues. Use when reviewing pull requests, checking code quality, or auditing security."
---
```

**Best practices**:
- Include keywords users would naturally say
- Describe WHEN to use, not just WHAT it does
- Keep under 200 characters
- Include trigger scenarios

**Pattern**:
```
[What it does]. Use when [scenario 1], [scenario 2], or [scenario 3].
```

**Examples**:
```yaml
# Good: includes trigger scenarios
description: "Create and update workflows with validation. Use when building new workflows, migrating existing skills, or standardizing patterns."

# Bad: just describes function
description: "Creates workflows."
```

---

### model

**Type**: enum
**Values**: `opus`, `sonnet`, `haiku`
**Default**: inherits from session

```yaml
---
name: complex-analysis
model: opus
---
```

**Model characteristics**:

| Model | Capability | Speed | Cost | Best for |
|-------|------------|-------|------|----------|
| opus | Highest reasoning | Slower | ~15x | Complex orchestration, critical decisions, nuanced understanding |
| sonnet | High capability | Medium | ~3x | Exploration, analysis, code review, most agent tasks |
| haiku | Good capability | Fastest | ~1x | Simple extraction, fast lookups, repetitive tasks |

**Recommendations**:
- Main skill orchestration: `opus`
- Subagent exploration: `sonnet`
- High-volume simple tasks: `haiku`
- Reference content: inherit (no specification)

---

### context

**Type**: enum
**Values**: `fork` or omit
**Default**: runs inline with conversation

```yaml
---
name: heavy-processing
context: fork
---
```

**Behaviors**:

| Setting | Context behavior | Conversation history |
|---------|------------------|---------------------|
| (omitted) | Runs inline | Full access to history |
| `fork` | Isolated context | Fresh context, no history |

**When to fork**:
- Multi-step workflows (5+ steps)
- Heavy file processing (10+ files)
- Workflow produces large intermediate outputs
- Need to keep main context clean

**When NOT to fork**:
- Need conversation history for decisions
- Reference/knowledge skills
- Interactive workflows with multiple user inputs
- Meta-workflows that build on prior conversation

---

### allowed-tools

**Type**: array of strings
**Default**: inherits all tools from session

```yaml
---
name: exploration
allowed-tools:
  - Read
  - Glob
  - Grep
  - Task
---
```

**Available tools**:

| Tool | Purpose | Category |
|------|---------|----------|
| Read | Read file contents | File access |
| Write | Create new files | File modification |
| Edit | Modify existing files | File modification |
| Glob | Find files by pattern | Search |
| Grep | Search file contents | Search |
| Bash | Execute shell commands | System |
| Task | Launch subagents | Delegation |
| AskUserQuestion | Interactive user input | Interaction |
| WebFetch | Fetch URL content | External |
| WebSearch | Search the web | External |
| TodoWrite | Manage task list | Organization |
| Skill | Invoke other skills | Composition |

**Common configurations**:

```yaml
# Read-only exploration
allowed-tools: [Read, Glob, Grep]

# Analysis with report output
allowed-tools: [Read, Glob, Grep, Write]

# Development workflow
allowed-tools: [Read, Glob, Grep, Write, Edit, Bash, Task]

# Interactive research
allowed-tools: [Read, Glob, Grep, WebFetch, WebSearch, AskUserQuestion]
```

**Principle**: Only allow what's needed (least privilege).

---

### disable-model-invocation

**Type**: boolean
**Default**: false

```yaml
---
name: deploy
disable-model-invocation: true
---
```

**Effect**: Prevents Claude from automatically invoking the skill. User MUST type `/name` explicitly.

**Use when**:
- Destructive actions (deploy, delete, reset)
- Actions with external side effects (commit, push, send email)
- Operations with cost implications (API calls, cloud resources)
- Workflows requiring explicit user intent

**Do NOT use when**:
- Read-only analysis skills
- Reference/knowledge content
- Quick utility commands

---

### user-invocable

**Type**: boolean
**Default**: true

```yaml
---
name: internal-helper
user-invocable: false
---
```

**Effect**: When `false`, hides skill from `/` autocomplete menu. Only Claude can invoke internally.

**Use when**:
- Background knowledge/context skills
- Internal helper skills called by other skills
- Reference content Claude loads when relevant
- Building blocks not meaningful as standalone actions

**Visibility matrix**:

| user-invocable | disable-model-invocation | In menu | Claude auto-invoke |
|----------------|--------------------------|---------|-------------------|
| true (default) | false (default) | Yes | Yes |
| true | true | Yes | No |
| false | false | No | Yes |
| false | true | No | No (INVALID) |

---

### argument-hint

**Type**: string
**Purpose**: Shows hint during `/` autocomplete

```yaml
---
name: fix-issue
argument-hint: "<issue-number> - GitHub issue to fix"
---
```

**Conventions**:

| Format | Meaning | Example |
|--------|---------|---------|
| `<arg>` | Required | `<filename>` |
| `[arg]` | Optional | `[--verbose]` |
| `<a\|b>` | Either one | `<create\|update>` |
| `...` | Multiple | `<files...>` |

**Examples**:
```yaml
argument-hint: "<workflow-name>"
argument-hint: "<name> [--mode=create|update]"
argument-hint: "<issue-number> - GitHub issue to investigate"
argument-hint: "<query> [--type=code|docs]"
```

---

### hooks

**Type**: object
**Purpose**: Run scripts at specific lifecycle points

```yaml
---
name: dev-workflow
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "echo 'About to write file...'"
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "{{LINT_CMD}}nfos"
---
```

**Hook events**:

| Event | When | Matcher applies to |
|-------|------|-------------------|
| PreToolUse | Before tool execution | Tool name |
| PostToolUse | After tool succeeds | Tool name |
| PostToolUseFailure | After tool fails | Tool name |
| Stop | Response complete | N/A |

**Hook types**:

| Type | Purpose | Example |
|------|---------|---------|
| command | Run shell script | `{{TEST_CMD}}` |
| prompt | LLM evaluation | Validation prompts |

**Matcher patterns**:
```yaml
matcher: "Write"        # Exact match
matcher: "Write|Edit"   # Either tool
matcher: "Bash"         # Bash commands only
```

---

### agent

**Type**: string
**Purpose**: Specifies which subagent type to use when `context: fork`

```yaml
---
name: quick-explore
context: fork
agent: Explore
---
```

**Built-in agents**:

| Agent | Default model | Tools | Purpose |
|-------|---------------|-------|---------|
| Explore | haiku | read-only | Fast codebase search and navigation |
| Plan | inherit | read-only | Planning and research |
| general-purpose | inherit | all | Complex multi-step tasks |

---

## Content Features

These features work within the skill's markdown content.

### $ARGUMENTS Substitution

**Purpose**: Access arguments passed when invoking the skill.

```markdown
Fix GitHub issue #$ARGUMENTS following the project's coding standards.
```

**Invocation**: `/fix-issue 123`
**Result**: `Fix GitHub issue #123 following the project's coding standards.`

**Behavior**:
- If `$ARGUMENTS` appears in content: replaced with user input
- If `$ARGUMENTS` NOT in content: appended as `ARGUMENTS: <value>`

**Examples**:
```markdown
# Search pattern
Search for `$ARGUMENTS` in the codebase and explain all usages.

# Create from name
Create a new component named `$ARGUMENTS` with tests.

# Multiple uses
The issue $ARGUMENTS needs investigation. Start by reading issue $ARGUMENTS details.
```

---

### ${CLAUDE_SESSION_ID} Substitution

**Purpose**: Access current session identifier for unique file naming.

```markdown
Save analysis to `logs/analysis-${CLAUDE_SESSION_ID}.md`
```

**Use cases**:
- Session-specific log files
- Unique temporary files
- Correlation across multiple operations
- Debugging with session tracking

**Example**:
```markdown
## Session Tracking

**Session**: ${CLAUDE_SESSION_ID}

Save all outputs to `workspace/session-${CLAUDE_SESSION_ID}/`
```

---

### Dynamic Context Injection (!`cmd`)

**Purpose**: Run shell command BEFORE sending to Claude, inject output.

```markdown
## Current State

- **Branch**: !`git branch --show-current`
- **Status**: !`git status --porcelain | head -10`
- **Recent commits**: !`git log --oneline -5`
```

**How it works**:
1. Skill content is parsed
2. Shell commands between `` !` `` and `` ` `` are executed
3. Command output replaces the placeholder
4. Claude receives the result, not the command

**Best practices**:
- Keep commands fast (avoid long-running operations)
- Handle potential empty output gracefully
- Limit output size with `head` or similar
- Use for real-time context, not static info

**Examples**:
```markdown
# Git context
Current branch: !`git branch --show-current`
Changed files: !`git diff --name-only HEAD~1`

# Environment
Node version: !`node --version`
Current directory: !`pwd`

# Discovery
Test files: !`find test/ -name "*.test.ts" | head -10`
```

---

## Supporting Files Structure

Skills can include additional files beyond SKILL.md.

### Directory Structure

```
my-skill/
├── SKILL.md              # Required: Main entry point and instructions
├── steps/                # Optional: Step-by-step execution files
│   ├── step-00-init.md
│   ├── step-01-analyze.md
│   └── step-02-execute.md
├── templates/            # Optional: Active templates with placeholders
│   ├── component.md
│   └── test.md
├── references/           # Optional: On-demand documentation
│   ├── patterns.md
│   └── examples.md
├── scripts/              # Optional: Executable helpers
│   └── validate.sh
└── examples/             # Optional: Example files
    └── sample-output.md
```

### Referencing Files

```markdown
## Resources

- For patterns, see [patterns.md](references/patterns.md)
- For examples, see [examples/](examples/)
- Load step 1: Read `steps/step-01-analyze.md`
```

### Size Guidelines

| File | Recommended size | Notes |
|------|------------------|-------|
| SKILL.md | < 500 lines | Entry point, compact |
| Individual steps | 100-200 lines | Focused on one phase |
| Templates | As needed | Complete and usable |
| References | As needed | Loaded on-demand |

---

## Subagent Features

### Creating Custom Agents

**Location**: `.claude/agents/name.md`

```markdown
---
name: code-reviewer
description: Reviews code for quality, security, and best practices
tools: Read, Grep, Glob
model: sonnet
---

You are a senior code reviewer. Your role is to:
1. Identify quality issues
2. Check for security vulnerabilities
3. Verify adherence to project conventions

Be thorough but constructive in your feedback.
```

### Agent Frontmatter Options

| Field | Type | Purpose |
|-------|------|---------|
| name | string | Unique identifier for Task tool |
| description | string | When to delegate to this agent |
| tools | string (comma-sep) | Allowed tools |
| disallowedTools | string | Denied tools |
| model | enum | sonnet, opus, haiku, or inherit |
| permissionMode | string | Permission handling |
| skills | array | Skills to preload |
| hooks | object | Agent-scoped hooks |

### Using Agents from Skills

```markdown
Launch 3 agents in SINGLE MESSAGE for parallel execution:

**Agent 1 - Pattern Analysis** (model: sonnet):
Read references/patterns.md and identify patterns applicable to this workflow.
Return a prioritized list with rationale.

**Agent 2 - Example Discovery** (model: sonnet):
Search .claude/skills/ for similar workflows.
Return reusable structures and conventions found.

**Agent 3 - Constraint Extraction** (model: sonnet):
Read CLAUDE.md and .claude/rules/ for project constraints.
Return constraints that must be respected.
```

**Critical**: All Task tool calls must be in ONE message for parallel execution.

### Agent Communication

Agents return summaries to the parent context. Design prompts to:
- Specify exact return format
- Request concise, actionable output
- Include only what parent needs to proceed

---

## Integration with Project

### CLAUDE.md Interaction

| Aspect | CLAUDE.md | Skills |
|--------|-----------|--------|
| Loading | Always loaded | On-demand |
| Scope | Global project context | Specific workflows |
| Content | Rules, preferences, structure | Instructions, templates |
| Updates | Infrequent | Per workflow evolution |

Skills complement CLAUDE.md. Reference CLAUDE.md content but don't duplicate it.

### Imports in CLAUDE.md

```markdown
# In CLAUDE.md
See @README.md for project overview.
See @docs/architecture.md for system design.
```

The `@` prefix imports file content into CLAUDE.md context.

### Rules Files

**Location**: `.claude/rules/*.md`

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Rules

When working with API files:
- Use RESTful conventions
- Validate all inputs
- Include error handling
- Document endpoints
```

Rules with `paths` apply only to matching files.

---

## Permissions Configuration

### Permission Rules in Settings

**Location**: `.claude/settings.json`

```json
{
  "permissions": {
    "allow": [
      "Bash(npm:*)",
      "Bash(flutter:*)",
      "Write(src/**)",
      "Edit(src/**)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Write(.env)"
    ]
  }
}
```

### Permission Syntax

| Pattern | Meaning | Example |
|---------|---------|---------|
| `Tool(exact)` | Exact match | `Bash(npm test)` |
| `Tool(prefix:*)` | Prefix match | `Bash(npm:*)` |
| `Tool(path/**)` | Path pattern | `Write(src/**)` |

### Skill Permission Syntax

```
Skill(name)        # Exact skill match
Skill(name:*)      # Skill with any arguments
```

---

## Debugging Skills

### Skill Not Triggering

1. **Check description**: Does it contain keywords matching user intent?
2. **Verify visibility**: Is `user-invocable: false` set unintentionally?
3. **Test directly**: Try `/skill-name` to confirm it works
4. **Check model**: Ask "What skills are available?" to list loaded skills

### Skill Triggers Too Often

1. **Narrow description**: Make trigger scenarios more specific
2. **Add protection**: Use `disable-model-invocation: true`
3. **Rename**: Choose a more specific name

### Context Issues

| Symptom | Likely cause | Solution |
|---------|--------------|----------|
| Skill doesn't see conversation | `context: fork` is set | Remove fork or pass context explicitly |
| Skill pollutes main context | Too much output | Add `context: fork` |
| Subagent missing info | Didn't pass needed context | Include context in agent prompt |

### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| "Skill not found" | Typo in name or not in path | Check `.claude/skills/` directory |
| "Invalid YAML" | Frontmatter syntax error | Validate YAML structure |
| "Tool not allowed" | Tool restricted by allowed-tools | Add tool to list or remove restriction |

---

## Quick Reference

| Feature | Syntax | Purpose |
|---------|--------|---------|
| Name | `name: my-skill` | Set slash command |
| Description | `description: "..."` | Auto-invoke triggers |
| Model | `model: opus\|sonnet\|haiku` | Set capability level |
| Fork | `context: fork` | Isolate context |
| Tools | `allowed-tools: [...]` | Restrict capabilities |
| User-only | `disable-model-invocation: true` | Prevent auto-invoke |
| Hidden | `user-invocable: false` | Hide from menu |
| Args hint | `argument-hint: "<arg>"` | Autocomplete hint |
| Hooks | `hooks: {...}` | Lifecycle automation |
| Arguments | `$ARGUMENTS` | Access user input |
| Session | `${CLAUDE_SESSION_ID}` | Session tracking |
| Dynamic | `` !`git status` `` | Runtime context |

---

## See Also

- [decision-matrix.md](decision-matrix.md) - WHEN to use each feature
- [patterns-unified.md](patterns-unified.md) - Best practices and patterns
- [quality-criteria.md](quality-criteria.md) - Validation checklist
