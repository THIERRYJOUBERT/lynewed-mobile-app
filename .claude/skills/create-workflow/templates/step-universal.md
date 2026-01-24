# Template: Universal Step File

> Template for individual workflow steps in multi-step skills.
> Each step is self-contained with clear inputs, outputs, and validation.

---

## When to Use This Template

Use this template for every step file in a multi-step workflow skill.
Steps are loaded progressively - one at a time - to maintain LLM focus.

---

## Template Structure

```markdown
---
name: step-{step_number}-{step_name}
description: "{step_description}"
prev_step: {prev_step_file}
next_step: {next_step_file}
---

# Step {step_number}: {step_title}

## MANDATORY RULES (READ FIRST)

- {rule_emoji_1} {rule_text_1}
- {rule_emoji_2} {rule_text_2}
- {rule_emoji_3} {rule_text_3}

## PROTOCOLS

- 🎯 **Goal**: {goal}
- 💾 **Output**: {output}
- 📖 **Reference**: {reference_file}
- ⚡ **Performance**: {performance_note}

## CONTEXT

**Available from previous steps:**
- `{{{available_var_1}}}` - {available_description_1} (from {source_step_1})
- `{{{available_var_2}}}` - {available_description_2} (from {source_step_2})

**Produced by this step:**
- `{{{produced_var_1}}}` - {produced_description_1}
- `{{{produced_var_2}}}` - {produced_description_2}

**NOT available (do not use):**
- `{{{unavailable_var_1}}}` - {unavailable_reason_1}

## TASK

{task_statement}

---

## EXECUTION

### 1. {action_1_title}

{action_1_instructions}

**Input**: `{{{action_1_input}}}`
**Output**: `{{{action_1_output}}}`

### 2. {action_2_title}

{action_2_instructions}

**Condition**: {action_2_condition}
**Fallback**: {action_2_fallback}

### 3. {action_3_title}

{action_3_instructions}

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ {validation_criterion_1}
✅ {validation_criterion_2}
✅ {validation_criterion_3}

**Self-Critique Questions:**
- {critique_question_1}?
- {critique_question_2}?
- {critique_question_3}?

**If validation fails:**
1. {corrective_action}
2. Max {max_attempts} attempts with learning
3. If persistent: {escalation}

---

## SUCCESS / FAILURE

**Success:**
✅ {success_metric_1}
✅ {success_metric_2}

**Failure modes:**
❌ {failure_condition_1} → {failure_fallback_1}
❌ {failure_condition_2} → {failure_fallback_2}

## NEXT

After validation passes, load `{next_step_file}`

<critical>
{critical_reminder}
</critical>
```

---

## Variable Reference

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `{step_number}` | Yes | Two-digit number | `00`, `01`, `02` |
| `{step_name}` | Yes | kebab-case name | `analyze`, `validate` |
| `{step_title}` | Yes | Human-readable title | `Analyze Requirements` |
| `{step_description}` | Yes | Brief description | `Parse and understand input` |
| `{prev_step_file}` | Yes | Previous step or `null` | `step-00-init.md` |
| `{next_step_file}` | Yes | Next step or `null` | `step-02-execute.md` |
| `{rule_emoji_N}` | Yes | Visual marker | `🚫`, `✅`, `⚠️` |
| `{rule_text_N}` | Yes | Rule content | `Never skip validation` |
| `{goal}` | Yes | Step's objective | `Extract acceptance criteria` |
| `{output}` | Yes | What step produces | `List of criteria to implement` |
| `{available_var_N}` | No | Variable from previous step | `story_path` |
| `{produced_var_N}` | Yes | Variable this step creates | `criteria_list` |
| `{unavailable_var_N}` | No | Variable not yet available | `test_results` |
| `{task_statement}` | Yes | What to accomplish | `Read the story file and...` |
| `{action_N_title}` | Yes | Action heading | `Read Story File` |
| `{action_N_instructions}` | Yes | How to perform action | `Use Read tool to...` |
| `{validation_criterion_N}` | Yes | What to check | `All criteria extracted` |
| `{critique_question_N}` | Yes | Self-review question | `Did I miss any criteria` |
| `{corrective_action}` | Yes | How to fix issues | `Re-read with more attention` |
| `{max_attempts}` | Yes | Retry limit | `5` |
| `{escalation}` | Yes | What if stuck | `Ask user for clarification` |
| `{critical_reminder}` | Yes | Important note | `Never proceed with missing data` |

---

## Example: Completed Step File

```markdown
---
name: step-01-red
description: "Write failing tests for current acceptance criterion"
prev_step: steps/step-00-analyze.md
next_step: steps/step-02-green.md
---

# Step 01: RED (Write Failing Tests)

## MANDATORY RULES (READ FIRST)

- 🚫 NEVER write implementation code in this step
- ✅ Tests MUST fail before proceeding
- ✅ Tests MUST be meaningful (not trivially false)
- ⚠️ One criterion at a time - don't test multiple criteria

## PROTOCOLS

- 🎯 **Goal**: Create tests that define expected behavior
- 💾 **Output**: Test files that fail with clear messages
- 📖 **Reference**: `references/testing-patterns.md`
- ⚡ **Performance**: Keep tests focused and fast

## CONTEXT

**Available from previous steps:**
- `{story_path}` - Path to story file (from step-00)
- `{acceptance_criteria}` - List of criteria to implement (from step-00)
- `{current_criterion}` - Index of criterion being implemented (from step-00)

**Produced by this step:**
- `{test_files}` - List of test files created
- `{test_run_result}` - Result of running tests (should be FAIL)

**NOT available (do not use):**
- `{implementation_files}` - Not created until step-02

## TASK

Write tests for acceptance criterion #{current_criterion} that:
1. Clearly express the expected behavior
2. Fail with descriptive error messages
3. Will pass once implementation is complete

---

## EXECUTION

### 1. Identify Test Location

Determine where tests should go based on:
- Feature being tested
- Project test structure
- Existing test patterns

**Input**: `{current_criterion}`
**Output**: `{test_file_path}`

### 2. Write Test Cases

Create test cases covering:
- Happy path (expected behavior)
- Edge cases (boundaries, empty inputs)
- Error cases (invalid inputs, failures)

**Condition**: Test file exists or will be created
**Fallback**: Create new test file following project patterns

### 3. Run Tests (Expect Failure)

Execute the tests to verify they fail:
```bash
{{TEST_CMD}} {test_file_path}
```

Tests MUST fail. If they pass:
- Tests are not testing new behavior
- Implementation already exists
- Tests are incorrectly written

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ Test file(s) created at correct location
✅ Tests cover the acceptance criterion
✅ Tests fail with meaningful error messages
✅ No implementation code written

**Self-Critique Questions:**
- Did I cover all aspects of the criterion?
- Are the test names descriptive?
- Will the error messages help debug failures?
- Am I testing behavior, not implementation details?

**If validation fails:**
1. Review criterion and adjust tests
2. Max 3 attempts for test writing
3. If persistent: Ask user to clarify expected behavior

---

## SUCCESS / FAILURE

**Success:**
✅ Tests exist and are well-structured
✅ Tests fail with clear messages
✅ Ready to implement (step-02)

**Failure modes:**
❌ Tests pass unexpectedly → Check if feature already exists, adjust tests
❌ Cannot determine test location → Ask user for project test conventions
❌ Criterion is unclear → Return to step-00, ask for clarification

## NEXT

After validation passes, load `steps/step-02-green.md`

<critical>
Do NOT proceed to step-02 if tests are passing.
The RED phase requires failing tests to prove the tests are valid.
</critical>
```

---

## Tips for Step Files

1. **Self-contained** - Each step has all info needed to execute
2. **Clear boundaries** - Explicit inputs (available) and outputs (produced)
3. **Validation before progress** - Never proceed without passing checks
4. **Self-healing built-in** - Steps know how to recover from common errors
5. **Critical reminders** - Reinforce the most important constraints
