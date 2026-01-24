# Template: Multi-Step Workflow Skill

> Template for complex skills with multiple coordinated steps, state tracking, and step files.
> Uses progressive step loading for focused LLM attention.

---

## When to Use This Template

**Use for:**
- Multi-phase workflows (4+ steps)
- Tasks requiring state between steps
- Complex processes with branching logic
- Workflows needing validation between phases

**Don't use for:**
- Simple 1-3 step tasks (use `skill-task-simple.md`)
- Pure documentation (use `skill-reference.md`)
- Single-purpose utilities

---

## Template Structure

```markdown
---
name: {workflow_name}
description: "{description}"
model: {model}
# Optional configurations:
# context: fork
# allowed-tools:
#   - Read
#   - Write
#   - Edit
#   - Bash
#   - Task
# argument-hint: "{argument_hint}"
# hooks:
#   Stop:
#     - body: "Verify all validations passed before stopping"
---

<objective>
{objective}
</objective>

<critical_rule>
🛑 NEVER {never_rule_1}
🛑 NEVER {never_rule_2}
✅ ALWAYS {always_rule_1}
✅ ALWAYS {always_rule_2}
</critical_rule>

<when_to_use>
**Use this skill when:**
- {use_case_1}
- {use_case_2}
- {use_case_3}

**Don't use for:**
- {anti_pattern_1}
- {anti_pattern_2}
</when_to_use>

<state_variables>
| Variable | Type | Description |
|----------|------|-------------|
| `{{{state_var_1}}}` | {type_1} | {description_1} |
| `{{{state_var_2}}}` | {type_2} | {description_2} |
| `{{{state_var_3}}}` | {type_3} | {description_3} |
</state_variables>

<entry_point>
Load `steps/step-00-{first_step_name}.md`
</entry_point>

<step_files>
| Step | File | Purpose | Auto-Validation |
|------|------|---------|-----------------|
| 00 | step-00-{step_name_0}.md | {purpose_0} | {validation_0} |
| 01 | step-01-{step_name_1}.md | {purpose_1} | {validation_1} |
| 02 | step-02-{step_name_2}.md | {purpose_2} | {validation_2} |
| 03 | step-03-{step_name_3}.md | {purpose_3} | {validation_3} |
</step_files>

<execution_rules>
1. **Progressive Loading**: Load ONE step at a time - never peek ahead
2. **State Tracking**: Update state variables after each step
3. **Validation Gates**: Pass step validation before proceeding
4. **Self-Healing**: Max {max_attempts} attempts per step with learning
5. **Escalation**: If stuck after max attempts, report and ask user
</execution_rules>

<success_criteria>
✅ {success_criterion_1}
✅ {success_criterion_2}
✅ {success_criterion_3}
</success_criteria>

<failure_modes>
❌ {failure_condition_1} → {failure_action_1}
❌ {failure_condition_2} → {failure_action_2}
❌ {failure_condition_3} → {failure_action_3}
</failure_modes>

<workflow_diagram>
```
{workflow_diagram}
```
</workflow_diagram>

<begin>
Load `steps/step-00-{first_step_name}.md` to start the workflow.
</begin>
```

---

## Variable Reference

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `{workflow_name}` | Yes | kebab-case identifier | `feature-implementation` |
| `{description}` | Yes | Trigger phrase | `Use to implement new features with TDD` |
| `{model}` | Yes | `opus`, `sonnet`, `haiku` | `opus` |
| `{objective}` | Yes | 1-2 sentence goal | `Implement features following TDD cycle` |
| `{never_rule_N}` | Yes | Hard constraints | `skip the testing phase` |
| `{always_rule_N}` | Yes | Required behaviors | `run tests before committing` |
| `{use_case_N}` | Yes | When to use | `Adding new functionality` |
| `{anti_pattern_N}` | Yes | When not to use | `Quick bug fixes` |
| `{state_var_N}` | Yes | State variable name | `current_step` |
| `{type_N}` | Yes | Variable type | `string`, `list`, `boolean` |
| `{first_step_name}` | Yes | Initial step name | `analyze` |
| `{step_name_N}` | Yes | Step file name part | `execute`, `validate` |
| `{purpose_N}` | Yes | Step purpose | `Run tests and collect results` |
| `{validation_N}` | Yes | Step validation | `All tests pass` |
| `{max_attempts}` | Yes | Self-healing limit | `5` |
| `{success_criterion_N}` | Yes | Success condition | `Feature works as specified` |
| `{failure_condition_N}` | Yes | Failure trigger | `Tests fail after 5 attempts` |
| `{failure_action_N}` | Yes | Failure response | `Report errors and escalate` |
| `{workflow_diagram}` | Yes | ASCII flow diagram | See example below |

---

## Example: Completed Workflow Skill

```markdown
---
name: implement-feature
description: "Use to implement new features following TDD methodology"
model: opus
context: fork
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Task
argument-hint: "<story_file_path>"
hooks:
  Stop:
    - body: "Verify all tests pass and code review complete before stopping"
---

<objective>
Implement features using strict TDD: write failing tests first, then minimal code to pass, then refactor.
</objective>

<critical_rule>
🛑 NEVER write implementation code before tests exist
🛑 NEVER skip the refactor phase
🛑 NEVER commit with failing tests
✅ ALWAYS run tests after each code change
✅ ALWAYS update story tracking after completion
</critical_rule>

<when_to_use>
**Use this skill when:**
- Implementing a new feature from a story
- Adding functionality with acceptance criteria
- Building components that need test coverage

**Don't use for:**
- Quick bug fixes (use /debug)
- Documentation updates
- Refactoring without new functionality
</when_to_use>

<state_variables>
| Variable | Type | Description |
|----------|------|-------------|
| `{story_path}` | string | Path to story file |
| `{acceptance_criteria}` | list | Criteria to implement |
| `{current_criterion}` | number | Index of current criterion |
| `{test_results}` | object | Latest test run results |
| `{files_modified}` | list | Files changed during implementation |
</state_variables>

<entry_point>
Load `steps/step-00-analyze.md`
</entry_point>

<step_files>
| Step | File | Purpose | Auto-Validation |
|------|------|---------|-----------------|
| 00 | step-00-analyze.md | Parse story and understand requirements | Criteria list extracted |
| 01 | step-01-red.md | Write failing tests for criterion | Tests exist and fail |
| 02 | step-02-green.md | Write minimal code to pass tests | All tests pass |
| 03 | step-03-refactor.md | Clean up code maintaining tests | Tests still pass |
| 04 | step-04-validate.md | Run full validation suite | Zero warnings |
| 05 | step-05-commit.md | Commit changes with proper message | Commit created |
</step_files>

<execution_rules>
1. **Progressive Loading**: Load ONE step at a time - never peek ahead
2. **State Tracking**: Update state variables after each step
3. **Validation Gates**: Pass step validation before proceeding
4. **Self-Healing**: Max 5 attempts per step with learning
5. **Escalation**: If stuck after 5 attempts, report and ask user
6. **TDD Cycle**: Steps 01-03 repeat for each acceptance criterion
</execution_rules>

<success_criteria>
✅ All acceptance criteria implemented
✅ All tests passing
✅ Zero lint warnings
✅ Code reviewed and clean
✅ Story tracking updated
</success_criteria>

<failure_modes>
❌ Story file not found → Ask user for correct path
❌ Tests fail after 5 attempts → Report blockers and escalate
❌ Lint warnings persist → Document and ask user to proceed
</failure_modes>

<workflow_diagram>
```
┌─────────────────────────────────────────────────────────┐
│                   IMPLEMENT FEATURE                      │
├─────────────────────────────────────────────────────────┤
│  00. ANALYZE   → Parse story, extract criteria          │
│       │                                                  │
│       ▼                                                  │
│  ┌─────────────────────────────────────────────┐        │
│  │  FOR EACH CRITERION:                        │        │
│  │  01. RED     → Write failing tests          │        │
│  │  02. GREEN   → Write minimal passing code   │        │
│  │  03. REFACTOR→ Clean code, tests still pass │        │
│  └─────────────────────────────────────────────┘        │
│       │                                                  │
│       ▼                                                  │
│  04. VALIDATE  → Full test + lint suite                 │
│       │                                                  │
│       ▼                                                  │
│  05. COMMIT    → Create commit with message             │
└─────────────────────────────────────────────────────────┘
```
</workflow_diagram>

<begin>
Load `steps/step-00-analyze.md` to start the workflow.
</begin>
```

---

## File Structure for Workflows

```
.claude/skills/{workflow_name}/
├── SKILL.md              # This template (main entry point)
├── steps/
│   ├── step-00-{name}.md # First step
│   ├── step-01-{name}.md # Second step
│   └── ...               # Additional steps
├── templates/            # Output templates (optional)
│   └── {template}.md
└── references/           # Reference content (optional)
    └── {reference}.md
```

---

## Tips for Workflow Skills

1. **Clear state boundaries** - Each step knows exactly what it receives and produces
2. **Progressive disclosure** - Load steps one at a time to maintain LLM focus
3. **Validation gates** - Never proceed to next step without passing validation
4. **Self-healing** - Steps should attempt recovery before escalating
5. **Escape hatches** - Always provide a way to ask the user when stuck
