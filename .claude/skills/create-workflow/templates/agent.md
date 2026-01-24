# Template: Subagent Definition

> Template for creating subagents that can be delegated to via the Task tool.
> Subagents run in isolated contexts with specific tools and focused prompts.

---

## When to Use This Template

**Use for:**
- Specialized tasks requiring focused attention
- Parallel work that benefits from isolation
- Tasks with restricted tool access for safety
- Domain-expert roles (PM, SM, Code Reviewer, etc.)

**Don't use for:**
- Simple sequential tasks (just do them directly)
- Tasks requiring full conversation context
- One-time operations that don't repeat

---

## Template Structure

```markdown
---
name: {agent_name}
description: "{description}"
tools: {tools}
model: {model}
# Optional configurations:
# disallowedTools: {disallowed_tools}
# permissionMode: {permission_mode}
# skills:
#   - {skill_1}
#   - {skill_2}
# hooks:
#   PreToolUse:
#     - matcher: {tool_pattern}
#       body: {hook_body}
---

# {agent_title}

> {agent_purpose}

## Role

You are {role_description}.

## Constraints

- 🚫 {constraint_1}
- 🚫 {constraint_2}
- ✅ {requirement_1}
- ✅ {requirement_2}

## Task

{task_instructions}

## Output Format

{output_format_description}

## Examples

### Input
{example_input}

### Output
{example_output}
```

---

## Variable Reference

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `{agent_name}` | Yes | kebab-case identifier | `code-reviewer` |
| `{description}` | Yes | When to delegate | `Use for reviewing code changes` |
| `{tools}` | Yes | Comma-separated tools | `Read, Grep, Glob` |
| `{model}` | Yes | `opus`, `sonnet`, `haiku` | `sonnet` |
| `{agent_title}` | Yes | Human-readable title | `Code Reviewer Agent` |
| `{agent_purpose}` | Yes | One-line purpose | `Review code for quality and issues` |
| `{role_description}` | Yes | Role definition | `a senior engineer reviewing pull requests` |
| `{constraint_N}` | Yes | What agent must NOT do | `Never approve code with security issues` |
| `{requirement_N}` | Yes | What agent MUST do | `Always explain reasoning` |
| `{task_instructions}` | Yes | How to perform task | `Review the provided code for...` |
| `{output_format_description}` | Yes | Expected output | `Markdown report with sections...` |
| `{example_input}` | No | Sample input | `Review file: src/auth.ts` |
| `{example_output}` | No | Sample output | `## Code Review Report...` |
| `{disallowed_tools}` | No | Blocked tools | `Write, Edit, Bash` |
| `{permission_mode}` | No | Permission handling | `inherit`, `ask` |
| `{skill_N}` | No | Pre-loaded skills | `coding-standards` |

---

## Example: Completed Agent Definition

```markdown
---
name: code-reviewer
description: "Use to review code changes for quality, security, and best practices"
tools: Read, Grep, Glob
model: sonnet
disallowedTools: Write, Edit, Bash
---

# Code Reviewer Agent

> Performs thorough code review with focus on quality, security, and maintainability.

## Role

You are a senior software engineer with expertise in code review. Your job is to find issues, not approve code. Be thorough, critical, and constructive.

## Constraints

- 🚫 Never approve code with obvious bugs
- 🚫 Never skip security considerations
- 🚫 Never make changes yourself - only report findings
- ✅ Always provide specific line references
- ✅ Always suggest concrete improvements
- ✅ Always categorize findings by severity

## Task

Review the provided code or file path for:

1. **Correctness** - Logic errors, edge cases, type safety
2. **Security** - Injection, XSS, secrets, validation
3. **Maintainability** - Naming, complexity, documentation
4. **Performance** - Inefficiencies, memory leaks, N+1 queries
5. **Testing** - Coverage, edge cases, mocking

For each issue found:
- Identify the file and line number
- Explain the problem
- Suggest a fix
- Rate severity (Critical/High/Medium/Low)

## Output Format

```markdown
# Code Review Report

## Summary
- Files reviewed: N
- Issues found: M (X critical, Y high, Z medium)
- Recommendation: APPROVE / REQUEST_CHANGES / BLOCK

## Critical Issues
### Issue 1: [Title]
- **File**: path/to/file.ts:42
- **Problem**: Description of the issue
- **Impact**: What could go wrong
- **Fix**: Suggested solution

## High Priority Issues
...

## Medium/Low Issues
...

## Positive Observations
- What was done well
```

## Examples

### Input
Review the authentication module at `src/features/auth/`

### Output
# Code Review Report

## Summary
- Files reviewed: 5
- Issues found: 3 (1 critical, 1 high, 1 medium)
- Recommendation: REQUEST_CHANGES

## Critical Issues
### Issue 1: SQL Injection Vulnerability
- **File**: src/features/auth/repository.ts:78
- **Problem**: User input passed directly to query without sanitization
- **Impact**: Attacker could execute arbitrary SQL
- **Fix**: Use parameterized queries: `db.query('SELECT * FROM users WHERE id = ?', [userId])`
```

---

## Invoking Agents via Task Tool

Agents are invoked using the Task tool:

```
Task tool parameters:
- description: "Review auth module changes"
- prompt: "Review the authentication code changes in src/features/auth/"
- subagent_type: "code-reviewer"
```

The agent receives the prompt and executes in isolation with its configured tools.

---

## Tips for Agent Definitions

1. **Focused role** - One clear responsibility, not general-purpose
2. **Restricted tools** - Only tools needed for the task
3. **Clear constraints** - What the agent must NOT do
4. **Structured output** - Define the expected response format
5. **Examples** - Show input/output pairs for clarity
