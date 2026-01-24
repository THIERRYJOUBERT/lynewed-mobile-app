# Step U1: Analyze Existing Workflow

> Purpose: Deep analysis of existing workflow structure, features, and execution flow before modification.

---

## MANDATORY RULES (READ FIRST)

- 💾 BACKUP FIRST: Create backup in `workspace/archive/` BEFORE any analysis
- 📖 JIT LOAD: Load `references/quality-criteria.md` at START (baseline for step-U2)
- 📂 Read ALL workflow files before any analysis
- 🧠 Mental simulation: "What happens when this workflow runs?"
- ✅ Understand before judging - analysis first, assessment later (step-U2)

## PROTOCOLS

- 🎯 **Goal**: Complete understanding of existing workflow
- 💾 **Output**: `{existing_workflow}` with comprehensive structure map
- 📖 **Reference**: `references/quality-criteria.md` (JIT loaded for assessment baseline)
- ⚡ **Performance**: Thorough analysis prevents incorrect modifications

---

## CONTEXT

**Available from SKILL.md:**
- `{mode}` = "UPDATE" (confirmed)
- `{target_workflow}` - Name/path of workflow to update
- `{update_reason}` - Why user wants to update (optional)

**Produced by this step:**
- `{backup_path}` - Path to backup copy in workspace/archive/
- `{existing_workflow}` - Complete analysis of current workflow
- `{quality_baseline}` - Quality criteria loaded for step-U2

**NOT available (do not use):**
- `{assessment}` - Created in step-U2
- `{approved_improvements}` - Created in step-U3

---

## TASK

Perform deep analysis of the existing workflow to understand:
1. Structure and organization
2. Current features and capabilities
3. Execution flow and step dependencies
4. Claude Code features in use
5. Potential issues or areas for improvement

---

## EXECUTION

### 1. Create Backup (MANDATORY)

**CRITICAL**: Create a complete backup of the workflow BEFORE any modifications.

This backup serves as a safety net in case of regression after updates.

**Backup location:**
```
workspace/archive/{workflow_name}-backup-{YYYYMMDD}/
```

**Execution:**
```bash
# Create backup directory
mkdir -p workspace/archive/{target_workflow}-backup-$(date +%Y%m%d)

# Copy entire workflow directory
cp -r .claude/skills/{target_workflow}/* workspace/archive/{target_workflow}-backup-$(date +%Y%m%d)/
```

**Output:**
```yaml
backup_path: "workspace/archive/{target_workflow}-backup-{YYYYMMDD}/"
backup_files: [list of all files copied]
backup_timestamp: "{ISO timestamp}"
```

**Why backup first:**
- Allows rollback if UPDATE introduces regressions
- Preserves original state before any analysis changes perception
- User can compare before/after easily
- Safety net for destructive operations

---

### 2. JIT Loading - Quality Criteria

**CRITICAL**: Load quality criteria NOW for assessment baseline.

```
Read .claude/skills/create-workflow/references/quality-criteria.md
```

Store mentally as `{quality_baseline}` - this will be used in step-U2.

---

### 3. Locate Workflow Files

Identify all files belonging to the target workflow:

```
Glob .claude/skills/{target_workflow}/**/*
```

**Expected structure possibilities:**

```
# Reference type (single file)
.claude/skills/{name}/
└── SKILL.md

# Task-simple type (single file + resources)
.claude/skills/{name}/
├── SKILL.md
└── templates/   (optional)

# Task-workflow type (multi-step)
.claude/skills/{name}/
├── SKILL.md
├── manifest.yaml
├── steps/
│   ├── step-01-*.md
│   ├── step-02-*.md
│   └── ...
├── templates/   (optional)
└── references/  (optional)
```

**Output**: `{workflow_files}` - List of all files found

---

### 4. Read and Parse SKILL.md

Read the main skill file:

```
Read .claude/skills/{target_workflow}/SKILL.md
```

**Extract from frontmatter:**

```yaml
cc_features_detected:
  context_fork:
    present: boolean
    reason: "Why used" | "Not present"

  subagents:
    present: boolean
    agents: ["list", "of", "agents"]

  hooks:
    present: boolean
    hooks: ["list", "of", "hooks"]

  model:
    specified: boolean
    value: "opus" | "sonnet" | "haiku" | null

  allowed_tools:
    specified: boolean
    tools: ["list"] | null

  user_invocable:
    value: boolean
    reason: "Why this setting"

  disable_model_invocation:
    value: boolean
    reason: "Why this setting"
```

**Extract from content:**

```yaml
content_analysis:
  type: "reference" | "task-simple" | "task-workflow"
  line_count: number
  sections: ["list", "of", "main", "sections"]
  has_execution_instructions: boolean
  has_templates: boolean
  has_step_loading: boolean
```

---

### 5. Analyze Multi-Step Structure (if applicable)

If `type == "task-workflow"`:

**Read each step file:**

```
FOR each file in steps/:
    Read and extract:
    - Step number and name
    - Purpose statement
    - Input variables (CONTEXT.Available)
    - Output variables (CONTEXT.Produced)
    - Dependencies on other steps
    - References loaded (JIT loading)
    - Validation criteria
```

**Build dependency map:**

```yaml
step_dependencies:
  step-01:
    inputs_from: []
    outputs: ["{var1}", "{var2}"]
    loads_reference: null

  step-02:
    inputs_from: ["step-01"]
    outputs: ["{var3}"]
    loads_reference: "references/something.md"

  step-03:
    inputs_from: ["step-01", "step-02"]
    outputs: ["{var4}"]
    loads_reference: null
```

**Identify flow:**

```yaml
execution_flow:
  entry: "step-01"
  linear_path: ["01", "02", "03"]
  branches: []  # or conditional paths if any
  exit: "step-N"
```

---

### 6. Read Supporting Files

**Templates (if present):**

```
FOR each file in templates/:
    Read and note:
    - Template purpose
    - Variables used ({{var}})
    - Completeness (usable as-is?)
```

**References (if present):**

```
FOR each file in references/:
    Read and note:
    - Reference purpose
    - Where loaded (which step)
    - Content summary
```

**Manifest (if present):**

```
Read manifest.yaml:
- Version
- Description
- Any custom configuration
```

---

### 7. Mental Simulation

Walk through the workflow execution mentally:

```markdown
## Mental Execution Walkthrough

**Trigger**: User invokes /{workflow_name} [args]

**Step 1**:
- What loads?
- What inputs are needed?
- What outputs are produced?
- What could fail?

**Step 2**:
- What context is available?
- What actions happen?
- What validation occurs?
- What could fail?

[Continue for all steps...]

**Completion**:
- What is the final output?
- Does it match the stated purpose?
- Are there gaps in the flow?
```

**Identify potential issues during simulation:**

```yaml
potential_issues:
  - location: "step-02"
    type: "gap"
    description: "No fallback if X fails"

  - location: "SKILL.md"
    type: "outdated"
    description: "Description doesn't match actual behavior"

  - location: "templates/foo.md"
    type: "incomplete"
    description: "Contains placeholder text"
```

---

### 8. Compile Analysis

Build the complete `{existing_workflow}` output:

```yaml
existing_workflow:
  path: ".claude/skills/{workflow_name}/"

  type: "reference" | "task-simple" | "task-workflow"

  files:
    - path: "SKILL.md"
      lines: number
      purpose: "Entry point"
    - path: "steps/step-01-*.md"
      lines: number
      purpose: "..."
    # ... all files

  cc_features:
    context_fork:
      current: boolean
      reason: "..."
    subagents:
      current: boolean
      agents_found: ["..."]
    hooks:
      current: boolean
      hooks_found: ["..."]
    model: "opus" | "sonnet" | "haiku" | null
    user_invocable: boolean
    disable_model_invocation: boolean
    allowed_tools: ["..."] | null

  steps:  # null if not multi-step
    - number: "01"
      name: "..."
      purpose: "..."
      inputs: ["..."]
      outputs: ["..."]
      jit_loading: "..." | null
    # ... all steps

  flow_summary: |
    Narrative description of how the workflow executes
    from start to finish, including decision points
    and error handling.

  potential_issues:
    - location: "..."
      type: "gap" | "outdated" | "incomplete" | "redundant" | "unclear"
      description: "..."
      severity_hint: "CRITICAL" | "HIGH" | "MEDIUM" | "LOW"
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ Backup created in `workspace/archive/{workflow}-backup-{date}/`
✅ All workflow files have been read
✅ SKILL.md frontmatter fully parsed
✅ Step dependencies mapped (if multi-step)
✅ Mental simulation completed
✅ Potential issues identified
✅ `{quality_baseline}` loaded for step-U2

**Self-Critique Questions:**
- Did I read EVERY file, or did I assume some content?
- Do I understand WHY this workflow was designed this way?
- Can I explain the execution flow without looking at the files?
- Did I identify real issues, or just note possible improvements?

**If validation fails:**
1. Re-read files that were skimmed
2. Trace execution flow step-by-step
3. If workflow is unclear: Note ambiguity as a finding

---

## OUTPUT STRUCTURE

The complete analysis must include:

```yaml
existing_workflow:
  # Core identification
  path: "..."
  type: "..."
  files: [...]

  # Claude Code features
  cc_features:
    context_fork: {...}
    subagents: {...}
    hooks: {...}
    model: "..."
    user_invocable: boolean
    disable_model_invocation: boolean
    allowed_tools: [...]

  # Structure (for multi-step)
  steps: [...]  # or null

  # Understanding
  flow_summary: "..."

  # Findings
  potential_issues: [...]
```

---

## SUCCESS / FAILURE

**Success:**
✅ Backup created at `{backup_path}`
✅ Complete `{existing_workflow}` with all sections filled
✅ All files read and understood
✅ Flow is clear and documentable
✅ Ready for quality assessment (step-U2)

**Failure modes:**
❌ Backup failed → STOP, do not proceed without backup, report error
❌ Workflow not found → Verify path, check for typos, ask user
❌ Files unreadable → Report error, ask user to check permissions
❌ Structure unclear → Document ambiguity, proceed with best understanding
❌ Too complex to analyze → Break into sub-analyses, document complexity

---

## NEXT

After validation passes, load `steps/step-U2-assess.md`

<critical>
BACKUP IS MANDATORY - Never proceed without a successful backup.
DO NOT start assessing quality yet - that's step-U2's job.
This step is ANALYSIS only: understand what exists.
The quality criteria loaded here is preparation for step-U2.
If you skip files or rush analysis, step-U2 assessment will be wrong.
</critical>
