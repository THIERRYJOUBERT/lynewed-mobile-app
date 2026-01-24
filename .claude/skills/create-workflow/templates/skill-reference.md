# Template: Reference Content Skill

> Template for creating knowledge-only skills that provide conventions, guidelines, or documentation.
> These skills contain no execution logic - they load reference content into context.

---

## When to Use This Template

**Use for:**
- Code conventions and style guides
- Architecture documentation
- API references
- Best practices collections
- Domain knowledge bases

**Don't use for:**
- Skills that execute tasks (use `skill-task-simple.md` or `skill-task-workflow.md`)
- Skills that coordinate multi-step processes
- Skills that require validation or iteration

---

## Template Structure

```markdown
---
name: {workflow_name}
description: "{description}"
# Optional: Set to false if this should only be loaded by other skills
# user-invocable: false
---

# {title}

> {short_description}

---

## Overview

{overview_content}

---

## Guidelines

### {guideline_1_title}

{guideline_1_content}

### {guideline_2_title}

{guideline_2_content}

<!-- Add more guidelines as needed -->

---

## Examples

### {example_1_title}

```{language}
{example_1_code}
```

### {example_2_title}

```{language}
{example_2_code}
```

---

## Quick Reference

| Concept | Description |
|---------|-------------|
| {concept_1} | {description_1} |
| {concept_2} | {description_2} |
| {concept_3} | {description_3} |

---

## Related

- [{related_1_name}]({related_1_path}) - {related_1_description}
- [{related_2_name}]({related_2_path}) - {related_2_description}
```

---

## Variable Reference

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `{workflow_name}` | Yes | kebab-case identifier | `coding-standards` |
| `{description}` | Yes | Trigger phrase for skill | `Use when writing new code to follow conventions` |
| `{title}` | Yes | Human-readable heading | `Coding Standards` |
| `{short_description}` | Yes | One-line summary | `Project-wide coding conventions and best practices` |
| `{overview_content}` | Yes | Introduction paragraph | `This guide defines...` |
| `{guideline_N_title}` | Yes | Section heading | `Naming Conventions` |
| `{guideline_N_content}` | Yes | Section content | `Use camelCase for...` |
| `{example_N_title}` | No | Example heading | `Good Function Names` |
| `{language}` | No | Code fence language | `typescript`, `python` |
| `{example_N_code}` | No | Code example | `const getUserById = ...` |
| `{concept_N}` | No | Quick ref term | `camelCase` |
| `{description_N}` | No | Quick ref definition | `For variables and functions` |
| `{related_N_name}` | No | Related resource name | `API Guidelines` |
| `{related_N_path}` | No | Relative path | `./api-guidelines.md` |
| `{related_N_description}` | No | Brief description | `REST API conventions` |

---

## Example: Completed Reference Skill

```markdown
---
name: error-handling
description: "Use when implementing error handling to follow project conventions"
---

# Error Handling Guidelines

> Standardized error handling patterns for consistent, debuggable code.

---

## Overview

This guide defines how errors should be caught, logged, and propagated throughout the application. Following these conventions ensures consistent error messages and simplifies debugging.

---

## Guidelines

### Error Classification

Errors fall into three categories:

1. **Recoverable** - Can be handled gracefully (retry, fallback)
2. **User-facing** - Should be translated to friendly messages
3. **Fatal** - Should terminate the operation and log details

### Logging Requirements

All errors must be logged with:
- Timestamp (ISO 8601)
- Error code (if applicable)
- Stack trace
- Context (user ID, request ID)

### Propagation Rules

- Never swallow errors silently
- Wrap low-level errors with context
- Preserve original error in chain

---

## Examples

### Wrapping Errors with Context

```typescript
async function fetchUser(id: string): Promise<User> {
  try {
    return await db.users.findById(id);
  } catch (error) {
    throw new AppError(
      'USER_FETCH_FAILED',
      `Failed to fetch user ${id}`,
      { cause: error, userId: id }
    );
  }
}
```

### Recoverable Error Handling

```typescript
async function sendNotification(userId: string): Promise<void> {
  const maxRetries = 3;
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await notificationService.send(userId);
      return;
    } catch (error) {
      if (attempt === maxRetries) throw error;
      await delay(attempt * 1000);
    }
  }
}
```

---

## Quick Reference

| Concept | Description |
|---------|-------------|
| AppError | Custom error class with code, message, context |
| Error code | Uppercase snake_case identifier (e.g., USER_NOT_FOUND) |
| Error chain | Original error preserved via `cause` property |
| Retry pattern | Exponential backoff with max attempts |

---

## Related

- [Logging Standards](./logging-standards.md) - Structured logging conventions
- [API Error Responses](./api-errors.md) - HTTP error response formats
```

---

## Tips for Creating Reference Skills

1. **Keep it scannable** - Use tables, bullet points, and clear headings
2. **Include real examples** - Abstract guidelines need concrete illustrations
3. **Cross-reference** - Link to related documentation
4. **Version awareness** - Note when guidelines changed and why
5. **Make it searchable** - Include keywords developers might search for

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Better Approach |
|--------------|---------|-----------------|
| Wall of text | Hard to scan | Use structure and formatting |
| No examples | Abstract and unclear | Add concrete code samples |
| Outdated info | Causes confusion | Date and version your content |
| Too broad | Unfocused, hard to apply | Split into focused guides |
| No rationale | Guidelines feel arbitrary | Explain the "why" |
