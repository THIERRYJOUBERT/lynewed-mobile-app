# Step 05: Generate

> Purpose: Generate all workflow files based on approved design.

---

## MANDATORY RULES (READ FIRST)

- 📝 ALWAYS use appropriate template for workflow type
- 🚫 NEVER leave placeholders (TBD, TODO, ...)
- ✅ All files must be complete and immediately usable
- 📁 Create directory structure before writing files

## PROTOCOLS

- 🎯 **Goal**: Generate all workflow files from approved design
- 💾 **Output**: `{generated_files}` list of created files
- 📖 **Reference**: Templates in `templates/` directory
- ⚡ **Performance**: Generate files in logical order

---

## CONTEXT

**Available from previous steps:**
- `{interview_data}` - Original requirements (step-01)
- `{design}` - Approved design document (step-03)
  - `{design.workflow_type}` - reference | task-simple | task-workflow
  - `{design.cc_features}` - All feature decisions
  - `{design.steps}` - Step definitions (if multi-step)
- `{design_approved}` - true (from step-04)
- `{manifest_draft}` - Initial manifest content (step-03)

**Produced by this step:**
- `{generated_files}` - List of all created files with paths
- `{target_path}` - Root path of created workflow

**NOT available (do not use):**
- `{critique_results}` - Not yet performed (step-06)

---

## TASK

Generate all files for the workflow:
1. Create directory structure
2. Generate SKILL.md (entry point)
3. Generate step files (if task-workflow)
4. Generate templates (if needed)
5. Generate references (if needed)
6. Generate agents (if subagents decided)
7. Create manifest.yaml

---

## EXECUTION

### 1. Create Directory Structure

**Base path:** `.claude/skills/{workflow_name}/`

**Standard structure:**
```
.claude/skills/{workflow_name}/
├── SKILL.md           # Always created
├── manifest.yaml      # Always created
├── steps/             # If task-workflow
│   ├── step-01-*.md
│   └── ...
├── templates/         # If outputs need templates
│   └── *.md
└── references/        # If supporting docs needed
    └── *.md
```

**Create directories first:**
```bash
mkdir -p .claude/skills/{workflow_name}/steps
mkdir -p .claude/skills/{workflow_name}/templates
mkdir -p .claude/skills/{workflow_name}/references
```

---

### 2. Generate SKILL.md

**Select template based on type:**

| Type | Template |
|------|----------|
| `reference` | `templates/skill-reference.md` |
| `task-simple` | `templates/skill-task-simple.md` |
| `task-workflow` | `templates/skill-task-workflow.md` |

**Load the template:**
```
Read .claude/skills/create-workflow/templates/{template_name}
```

**Fill placeholders:**

| Placeholder | Source |
|-------------|--------|
| `{workflow_name}` | `design.workflow_name` |
| `{description}` | `interview_data.objective` |
| `{invocation}` | From `cc_features.user_invocable` + `disable_model_invocation` |
| `{allowed_tools}` | `cc_features.allowed_tools.list` |
| `{model}` | `cc_features.model.choice` |
| `{context_fork}` | `cc_features.context_fork.decision` |

**Inject CC features into frontmatter:**
```yaml
---
name: {workflow_name}
description: "{description}"
model: {model}
allowed-tools: [{tools}]
context: {fork if true}
---
```

**Size constraint:** SKILL.md must be < 500 lines.
If content exceeds, move detailed instructions to step files or references.

---

### 3. Generate Step Files (if task-workflow)

For each step in `{design.steps}`:

**Load template:**
```
Read .claude/skills/create-workflow/templates/step-universal.md
```

**Create step file:** `steps/step-{number}-{name}.md`

**Fill step-specific content:**

```yaml
Mapping from design.steps[i]:
  {step_number} → steps[i].number
  {step_name} → steps[i].name
  {step_title} → Capitalized version of name
  {step_description} → steps[i].purpose
  {prev_step} → Previous step file or null
  {next_step} → Next step file or null
  {goal} → steps[i].purpose
  {output} → steps[i].outputs
  {available_vars} → From previous steps' outputs
  {produced_vars} → steps[i].outputs
  {task_statement} → Derived from purpose and role
  {actions} → Derived from purpose
  {validation_criteria} → steps[i].validation
  {failure_handling} → steps[i].failure_handling
```

**Ensure each step has:**
- Clear MANDATORY RULES section
- Explicit CONTEXT (available/produced/unavailable)
- Detailed EXECUTION instructions
- AUTO-VALIDATION criteria
- SUCCESS/FAILURE conditions
- NEXT step reference

---

### 4. Generate Templates (if needed)

If `{design.cc_features}` indicates outputs that need templates:

**Identify template needs from:**
- `interview_data.outputs`
- Step outputs that are documents/files

**For each template:**
1. Create file in `templates/` directory
2. Include clear structure markers
3. Add usage instructions as comments
4. Make immediately usable (no placeholders)

**Example template structure:**
```markdown
# Template: {template_name}

> Purpose: {what this template produces}

---

## Usage

This template is used by step-XX to generate {output}.

---

## Template

{actual template content with variable markers}

---

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{var1}` | What it is | Example value |
```

---

### 5. Generate References (if needed)

If the workflow needs supporting documentation:

**Common reference types:**
- Pattern guides
- Decision matrices
- Quality criteria
- Examples

**For each reference:**
1. Create file in `references/` directory
2. Include clear purpose statement
3. Make content actionable
4. Link from relevant step files

---

### 6. Generate Agents (if subagents decided)

If `{design.cc_features.subagents.needed}` is true:

**For each agent in** `{design.cc_features.subagents.agents}`:

**Create file:** `.claude/agents/{agent_name}.md`

**Use template:** `.claude/skills/create-workflow/templates/agent.md`

**Fill content:**
```yaml
---
name: {agent_name}
description: "{agent role}"
model: {agent model}
allowed-tools: [{agent tools}]
---

# Agent: {agent_name}

{Detailed agent instructions}
```

---

### 7. Create manifest.yaml

**Use template:** `.claude/skills/create-workflow/templates/manifest.yaml`

**Fill from** `{manifest_draft}` and final state:

```yaml
name: "{workflow_name}"
description: "{interview_data.objective}"
version: "1.0.0"
created: "{current_date}"
type: "{design.workflow_type}"

cc_features:
  context_fork: {bool}
  subagents: {bool}
  hooks: {bool}
  model: "{model}"
  user_invocable: {bool}

files:
  skill: "SKILL.md"
  steps:
    - "steps/step-01-*.md"
    - "steps/step-02-*.md"
  templates:
    - "templates/*.md"
  references:
    - "references/*.md"

dependencies: []

notes: |
  Generated by /create-workflow v3
  {any relevant notes from design}
```

---

## OUTPUT TRACKING

Track all generated files:

```yaml
generated_files:
  - path: ".claude/skills/{name}/SKILL.md"
    type: "entry_point"
    lines: N
  - path: ".claude/skills/{name}/steps/step-01-*.md"
    type: "step"
    lines: N
  - path: ".claude/skills/{name}/manifest.yaml"
    type: "manifest"
    lines: N
  ...

target_path: ".claude/skills/{workflow_name}/"

summary:
  total_files: N
  total_lines: N
  skill_lines: N  # Must be < 500
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ All planned files created
✅ No placeholders remain (search for TBD, TODO, ...)
✅ SKILL.md is < 500 lines
✅ YAML frontmatters are valid
✅ Markdown is well-formed
✅ All internal references (step links) are correct

**Self-Critique Questions:**
- Did I miss any files from the design?
- Are all step transitions correct?
- Are templates immediately usable?
- Would this workflow execute successfully?

**If validation fails:**
1. Identify missing or malformed content
2. Fix issues in place
3. Max 2 fix iterations
4. If structural issue: Flag for critique step

---

## SUCCESS / FAILURE

**Success:**
✅ All files created at `{target_path}`
✅ `{generated_files}` list is complete
✅ Files are syntactically valid
✅ Ready for critique

**Failure modes:**
❌ Template not found → Use fallback inline generation
❌ Path already exists → Check if UPDATE mode was intended
❌ SKILL.md too long → Move content to steps/references
❌ YAML invalid → Fix syntax issues

---

## NEXT

After validation passes, load `steps/step-06-critique.md`

<critical>
Files must be COMPLETE. No shortcuts.
A workflow with "TBD" sections is worse than no workflow.
Every generated file must be immediately usable.
</critical>
