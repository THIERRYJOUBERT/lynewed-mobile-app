# Template: Simple Task Skill

> Template for single-purpose skills that execute a focused task in 1-3 steps.
> No multi-file structure needed - all logic contained in one SKILL.md file.

---

## When to Use This Template

**Use for:**
- Quick utilities (commit, lint, format)
- Single-purpose transformations
- Simple validations
- Tasks completable in one session without state tracking

**Don't use for:**
- Multi-step workflows needing state between steps (use `skill-task-workflow.md`)
- Pure documentation (use `skill-reference.md`)
- Tasks requiring subagents or complex coordination

---

## Template Structure

```markdown
---
name: {workflow_name}
description: "{description}"
model: {model}
# Optional configurations:
# allowed-tools:
#   - Bash
#   - Read
#   - Edit
# argument-hint: "{argument_hint}"
# hooks:
#   PreToolUse:
#     - matcher: {tool_pattern}
#       body: {hook_body}
---

# {title}

> {short_description}

---

## Rules

- {emoji_1} {rule_1}
- {emoji_2} {rule_2}
- {emoji_3} {rule_3}

---

## Task

{task_description}

---

## Execution

### 1. {step_1_title}

{step_1_instructions}

**Validation**: {step_1_validation}

### 2. {step_2_title}

{step_2_instructions}

**Validation**: {step_2_validation}

### 3. {step_3_title}

{step_3_instructions}

**Validation**: {step_3_validation}

---

## Validation

**Before completing:**
✅ {validation_criterion_1}
✅ {validation_criterion_2}
✅ {validation_criterion_3}

**If issues found:**
{failure_handling}

---

## Output

{output_description}
```

---

## Variable Reference

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `{workflow_name}` | Yes | kebab-case identifier | `format-code` |
| `{description}` | Yes | Trigger phrase | `Use to format code before committing` |
| `{model}` | Yes | `opus`, `sonnet`, or `haiku` | `sonnet` |
| `{title}` | Yes | Human-readable title | `Code Formatter` |
| `{short_description}` | Yes | One-line summary | `Format code using project standards` |
| `{emoji_N}` | Yes | Visual rule marker | `🚫`, `✅`, `⚠️` |
| `{rule_N}` | Yes | Constraint or requirement | `Never modify test files` |
| `{task_description}` | Yes | What to accomplish | `Format all staged files...` |
| `{step_N_title}` | Yes | Step heading | `Identify Files` |
| `{step_N_instructions}` | Yes | Step details | `Run git diff --staged...` |
| `{step_N_validation}` | Yes | How to verify step | `All files identified` |
| `{validation_criterion_N}` | Yes | Final check | `No formatting errors` |
| `{failure_handling}` | Yes | What to do if fails | `Report errors and stop` |
| `{output_description}` | Yes | What skill produces | `Formatted files ready to commit` |
| `{argument_hint}` | No | Help text for args | `<file_pattern>` |

---

## Example: Completed Simple Task Skill

```markdown
---
name: format-imports
description: "Use to organize and sort imports in source files"
model: sonnet
allowed-tools:
  - Read
  - Edit
  - Bash
argument-hint: "<file_path or pattern>"
---

# Import Formatter

> Organize and sort imports following project conventions.

---

## Rules

- 🚫 Never modify imports in test files
- ✅ Always group imports: external → internal → relative
- ⚠️ Preserve any special comments above imports

---

## Task

Organize imports in the specified file(s) following the project's import ordering conventions:
1. External packages (alphabetized)
2. Internal packages (alphabetized)
3. Relative imports (by depth, then alphabetized)

---

## Execution

### 1. Identify Target Files

If `$ARGUMENTS` provided, use that pattern. Otherwise, find all modified TypeScript files:
```bash
git diff --name-only --cached | grep '\.tsx\?$'
```

**Validation**: At least one file identified

### 2. Analyze and Reorder Imports

For each file:
1. Read the file
2. Extract import block
3. Group into categories
4. Sort alphabetically within groups
5. Rebuild import section

**Validation**: Import block identified and parsed

### 3. Apply Changes

Edit each file with reorganized imports. Preserve:
- Comments attached to imports
- Empty lines between groups
- Type-only imports separate from value imports

**Validation**: File saves successfully

---

## Validation

**Before completing:**
✅ All target files processed
✅ Import order follows convention
✅ No syntax errors introduced
✅ Special comments preserved

**If issues found:**
Report which files failed and why. Do not partially apply changes.

---

## Output

Summary of files processed:
- Files modified: N
- Imports reorganized: M
- Any warnings or skipped files
```

---

## Tips for Simple Task Skills

1. **Keep it focused** - One clear purpose, not multiple features
2. **Validate each step** - Catch errors early before they compound
3. **Clear failure modes** - User knows what went wrong and why
4. **Minimal tools** - Only request tools actually needed
5. **Handle edge cases** - Empty inputs, no files found, etc.

---

## Common Patterns

### With Dynamic Context
```markdown
## Context

- Current branch: !`git branch --show-current`
- Staged files: !`git diff --staged --name-only`
```

### With Hooks
```yaml
hooks:
  PreToolUse:
    - matcher: Edit
      body: "Verify file is not in node_modules or dist"
```

### With Arguments
```markdown
If `$ARGUMENTS` is empty, prompt user for required input.
Otherwise, use `$ARGUMENTS` as the target file path.
```
