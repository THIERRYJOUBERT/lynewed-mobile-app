# Step 07: Validate

> Purpose: Final validation before registration via structure, syntax, and simulation checks.

---

## MANDATORY RULES (READ FIRST)

- 📁 ALWAYS verify ALL expected files exist
- 🔍 Parse YAML frontmatters to catch syntax errors
- 🧠 Mental simulation is REQUIRED before proceeding
- ⚠️ Warnings do not block, but must be documented

## PROTOCOLS

- 🎯 **Goal**: Final validation ensuring workflow is ready for use
- 💾 **Output**: `{validation_report}` with status and details
- 📖 **Reference**: `{generated_files}` from step-05
- ⚡ **Performance**: Thorough validation prevents runtime failures

---

## CONTEXT

**Available from previous steps:**
- `{design}` - Approved design document (step-03)
- `{generated_files}` - List of created files (step-05)
- `{target_path}` - Root path of workflow
- `{critique_results}` - Critique report (step-06)

**Produced by this step:**
- `{validation_status}` - PASS | PASS_WITH_WARNINGS | FAIL
- `{validation_report}` - Complete validation details

**NOT available (do not use):**
- Final user confirmation (happens in step-08)

---

## TASK

Perform three-layer validation:
1. Structure verification (files exist, organized correctly)
2. Syntax verification (YAML, markdown, links)
3. Mental simulation (execution walkthrough)

---

## EXECUTION

### 1. Structure Verification

**Check all expected files exist:**

```
For each file in {generated_files}:
    Use Glob or Read to verify existence
    Mark as: EXISTS | MISSING
```

**Expected structure based on type:**

**Reference type:**
```
{target_path}/
├── SKILL.md           ✓ Required
└── manifest.yaml      ✓ Required
```

**Task-simple type:**
```
{target_path}/
├── SKILL.md           ✓ Required
├── manifest.yaml      ✓ Required
└── templates/         ○ Optional
    └── *.md
```

**Task-workflow type:**
```
{target_path}/
├── SKILL.md           ✓ Required
├── manifest.yaml      ✓ Required
├── steps/             ✓ Required
│   ├── step-01-*.md   ✓ Required (at least one)
│   └── ...
├── templates/         ○ Optional
│   └── *.md
└── references/        ○ Optional
    └── *.md
```

**Check for orphan files:**
```
List all files in {target_path}
Compare against {generated_files}
Flag any unexpected files
```

**Structure result:**
```yaml
structure:
  status: "OK" | "ISSUES"
  expected_files: N
  found_files: N
  missing:
    - path: "..."
      severity: "critical" | "warning"
  orphans:
    - path: "..."
```

---

### 2. Syntax Verification

**YAML Frontmatter Validation:**

For each markdown file:
```
1. Extract content between --- markers
2. Check required fields present:
   - name (required)
   - description (required)
3. Verify syntax:
   - No unclosed quotes
   - Proper indentation
   - Boolean values are true/false (not "yes"/"no")
   - Lists use proper YAML syntax
```

**Validation method:**
```
For each .md file:
    content = Read(file)
    frontmatter = extract_between_markers(content, "---", "---")

    Check:
    - Frontmatter exists (has opening and closing ---)
    - 'name:' field present
    - 'description:' field present
    - No syntax errors (malformed YAML indicators)
```

**Common YAML issues to detect:**
- Missing closing `---`
- Unquoted strings with special characters
- Incorrect indentation
- Missing required fields

**Markdown Validation:**

```
Check for:
- Unclosed code blocks (```)
- Broken headers (# without space)
- Invalid link syntax [text](path)
- Unclosed emphasis (*text or **text)
```

**Internal Link Verification:**

```
For each link in format: steps/step-XX-name.md or similar
    Verify target file exists
    Mark as: VALID | BROKEN
```

**Syntax result:**
```yaml
syntax:
  status: "OK" | "ISSUES"
  yaml_errors:
    - file: "..."
      line: N
      error: "Description"
  markdown_errors:
    - file: "..."
      line: N
      error: "Description"
  broken_links:
    - source: "..."
      target: "..."
```

---

### 3. Mental Simulation

**Execute the workflow mentally:**

```
Scenario: "If I execute /{workflow_name} now, what happens?"

STEP-BY-STEP WALKTHROUGH:

1. INVOCATION
   - User types: /{workflow_name} {example_args}
   - SKILL.md is loaded
   - Expected behavior: ___

2. FOR EACH STEP (if multi-step):
   - Step XX loads
   - Claude reads instructions
   - Expected actions: ___
   - Expected outputs: ___
   - Potential failure: ___

3. COMPLETION
   - Final output produced
   - Expected result: ___
```

**Identify first potential failure point:**

```
The workflow would first fail at: ___
Because: ___
To prevent: ___
```

**Simulation result:**
```yaml
simulation:
  status: "OK" | "CONCERNS"
  walkthrough:
    - step: "invocation"
      behavior: "SKILL.md loads, instructions clear"
      concern: null | "Description"
    - step: "step-01"
      behavior: "..."
      concern: null | "..."
  first_failure_point: null | "step-XX: reason"
  recommendations:
    - "Recommendation 1"
    - "Recommendation 2"
```

---

### 4. Generate Report

Compile all validation results:

```yaml
validation_report:
  timestamp: "{current_datetime}"
  workflow: "{workflow_name}"
  target_path: "{target_path}"

  structure:
    status: "OK" | "ISSUES"
    details: {...}

  syntax:
    status: "OK" | "ISSUES"
    details: {...}

  simulation:
    status: "OK" | "CONCERNS"
    details: {...}

  overall_status: "PASS" | "PASS_WITH_WARNINGS" | "FAIL"

  summary:
    files_validated: N
    issues_found: N
    warnings: N
    critical_issues: N

  warnings:
    - "Warning 1"
    - "Warning 2"

  recommendations:
    - "Recommendation 1"
    - "Recommendation 2"
```

---

## STATUS DETERMINATION

**PASS:**
- All structure checks pass
- All syntax checks pass
- Simulation shows no concerns
- No issues of any kind

**PASS_WITH_WARNINGS:**
- Structure OK
- Syntax OK (or minor issues)
- Simulation has minor concerns
- No critical issues
- Warnings documented

**FAIL:**
- Missing critical files
- YAML parsing errors
- Broken internal links
- Simulation identifies definite failure point
- Critical issues found

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ All 3 validation layers completed
✅ Status is PASS or PASS_WITH_WARNINGS
✅ Report is complete and structured
✅ Any warnings are documented

**Self-Critique Questions:**
- Did I actually check every file?
- Did I parse YAML or just scan visually?
- Was the mental simulation thorough?
- Are recommendations actionable?

**If validation fails:**
1. For structure issues: Return to step-05
2. For syntax issues: Fix inline, re-validate
3. For simulation concerns: Assess if critical
4. Max 2 fix iterations before escalating

---

## SUCCESS / FAILURE

**Success:**
✅ `{validation_status}` is PASS or PASS_WITH_WARNINGS
✅ Complete `{validation_report}` generated
✅ Workflow is ready for registration
✅ User will be informed of any warnings

**Failure modes:**
❌ Missing required files → Return to step-05
❌ YAML syntax errors → Fix and re-validate
❌ Critical simulation failure → May need design revision
❌ Too many issues → Assess viability

---

## NEXT

**If PASS or PASS_WITH_WARNINGS:**
Load `steps/step-08-register.md`

**If FAIL:**
- For structure/syntax issues: Return to step-05 with specific fixes
- For design issues: Return to step-03 with feedback
- For fundamental issues: Consult user

<critical>
Mental simulation is NOT optional.
Actually walk through what would happen.
If you can't explain the flow, neither can the executing Claude.
Find the first failure point BEFORE a user does.
</critical>
