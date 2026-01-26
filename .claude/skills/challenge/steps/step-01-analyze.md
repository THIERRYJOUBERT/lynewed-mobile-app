# Step 01: Analyze Target

> Purpose: Detect and load the target to challenge, classify its type, prepare for critique.

---

## MANDATORY RULES

- 🎯 ALWAYS detect target from argument OR context
- 🚫 NEVER assume target type - verify from content
- ✅ ALWAYS load complete target content before proceeding
- ⚠️ If unclear, ASK user with structured options

## PROTOCOLS

- 🎯 **Goal**: Identify and understand what we're challenging
- 💾 **Output**: `{target}`, `{target_type}`, `{target_content}` populated
- 📖 **Reference**: None needed at this step
- ⚡ **Performance**: Direct file reads, no subagents

---

## CONTEXT

**Available from invocation:**
- `$ARGUMENTS` - May contain file path, "last", "--deep" flag, or empty

**Produced by this step:**
- `{target}` - Path or identifier of target
- `{target_type}` - Classification (code, plan, epic, story, decision, architecture, workflow, doc)
- `{target_content}` - Full content loaded
- `{target_context}` - Relevant surrounding context (related files, PRD references)
- `{deep_mode}` - Boolean: true if --deep flag OR auto-detected HIGH complexity
- `{complexity}` - LOW, MEDIUM, or HIGH

---

## TASK

### Phase 1: Target Detection & Mode Parsing

```
PARSE $ARGUMENTS:
    → Extract --deep flag if present → {deep_mode} = true
    → Remove flag from arguments for target detection

IF remaining args is a valid file path:
    → {target} = file path
    → Load file content

ELIF remaining args == "last":
    → Scan conversation for last significant output
    → {target} = last created/modified artifact

ELIF remaining args is empty:
    → Analyze conversation context
    → Detect most likely target (recent creation, discussed topic)
    → IF ambiguous: AskUserQuestion with options

ELSE:
    → Treat as concept/topic name
    → Search for related files
```

### Phase 2: Target Classification

Based on content and location, classify:

| Pattern | Type | Critique Focus |
|---------|------|----------------|
| `.dart`, `.ts`, `.py` files | code | Logic, security, patterns |
| `docs/epics/EPIC-*.md` | epic | Scope, alignment, completeness |
| `docs/epics/*/stories/*.md` | story | INVEST, Gherkin, testability |
| `PLAN-*.md`, `*-plan.md` | plan | Feasibility, steps, risks |
| `docs/specs/*.md` | doc | Clarity, accuracy, coherence |
| Discussion in conversation | decision | Rationale, alternatives, risks |
| `lib/`, architecture files | architecture | Patterns, scalability, coupling |
| `.claude/skills/**/*.md` | workflow | Step logic, patterns, clarity |

### Phase 3: Context Loading

For each target type, load relevant context:

**For Code:**
- Related test files
- Interface/contract definitions
- Calling code

**For Epic/Story:**
- PRD-MASTER.md
- CROSS-EPIC.md
- Parent Epic (for stories)

**For Plan/Decision:**
- Original requirements
- Constraints mentioned
- Previous discussions

### Phase 4: Complexity Detection & Mode Decision

Assess complexity to determine if subagents are beneficial:

| Indicator | Complexity |
|-----------|------------|
| Single file < 200 lines | LOW |
| Single file 200-500 lines | MEDIUM |
| Multiple files OR > 500 lines | HIGH |
| Directory/codebase-wide | HIGH |
| Epic with 5+ stories | HIGH |
| Workflow with 4+ steps | HIGH |
| Decision with 3+ alternatives | MEDIUM |

```
IF --deep flag was set:
    → {deep_mode} = true (forced)

ELIF {complexity} == HIGH:
    → {deep_mode} = true (auto-detected)
    → Note: "Deep mode auto-enabled due to HIGH complexity"

ELSE:
    → {deep_mode} = false
    → Standard single-agent challenge
```

### Phase 5: Pre-Challenge Assessment

```markdown
## Pre-Challenge Assessment

**Target**: {target}
**Type**: {target_type}
**Size**: {lines/sections count}
**Complexity**: {complexity}
**Deep Mode**: {deep_mode} (reason: forced/auto-detected/not needed)

**Context Loaded**:
- [x] Main target content
- [x] Related files: {list}
- [x] Requirements reference: {if applicable}

**Initial Observations** (NOT findings yet):
- {observation_1}
- {observation_2}
```

---

## AUTO-VALIDATION

Before proceeding, validate:

✅ `{target}` is clearly identified
✅ `{target_content}` is fully loaded (not truncated)
✅ `{target_type}` is classified
✅ Relevant context is available

**If validation fails:**
1. If target unclear → AskUserQuestion with detected options
2. If content loading fails → Report error, ask for alternative
3. If type ambiguous → Present options, let user clarify

---

## FALLBACK: Ambiguous Target

```
AskUserQuestion:
  question: "I detected multiple possible targets. Which should I challenge?"
  header: "Target"
  options:
    - label: "{option_1_name}"
      description: "{path or description}"
    - label: "{option_2_name}"
      description: "{path or description}"
    - label: "Specify different"
      description: "I'll describe what to challenge"
```

---

## OUTPUT

```yaml
step_01_output:
  target: "{path_or_identifier}"
  target_type: "{classification}"
  target_content: "{full_content}"
  target_context:
    related_files: ["{file_1}", "{file_2}"]
    requirements_ref: "{if applicable}"
    constraints: ["{constraint_1}"]
  complexity: "LOW|MEDIUM|HIGH"
  deep_mode: true|false
  deep_mode_reason: "forced|auto-detected|not needed"
  pre_assessment:
    size: "{measurement}"
    initial_observations: ["{obs_1}", "{obs_2}"]
```

---

## NEXT

After validation passes, load `steps/step-02-challenge.md`

<critical>
Do NOT proceed to step-02 without:
1. Clear target identification
2. Complete content loaded
3. Type classified
4. Relevant context available

The quality of the challenge depends on fully understanding the target first.
</critical>
