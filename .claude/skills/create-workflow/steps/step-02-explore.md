# Step 02: Explore

> Purpose: Explore existing context to inform design decisions via parallel agent exploration.

---

## MANDATORY RULES (READ FIRST)

- 🚀 ALWAYS launch ALL 3 agents in a SINGLE message (parallel execution)
- 📚 JIT LOADING: Load reference files in Agent 1 (not before)
- 🎯 Use model: sonnet for all exploration agents
- ⚠️ Wait for ALL agents to complete before proceeding

## PROTOCOLS

- 🎯 **Goal**: Gather context for intelligent design decisions
- 💾 **Output**: `{exploration_results}` with patterns, examples, constraints
- 📖 **Reference**: Loaded by Agent 1 (JIT principle)
- ⚡ **Performance**: 3 parallel agents = ~3x faster than sequential

---

## CONTEXT

**Available from previous steps:**
- `{interview_data}` - Complete requirements from interview (step-01)
  - `{interview_data.workflow_name}` - Validated kebab-case name
  - `{interview_data.objective}` - Clear problem statement
  - `{interview_data.invocation}` - user | model | both
  - `{interview_data.hints.subagents}` - Boolean hint for subagent need
  - `{interview_data.hints.hooks}` - Boolean hint for hook need

**Produced by this step:**
- `{exploration_results}` - Compiled exploration data

**NOT available (do not use):**
- `{design}` - Not yet created (step-03)
- `{cc_features}` - Not yet decided (step-03)

---

## TASK

Launch 3 parallel exploration agents to gather:
1. Applicable patterns and CC feature recommendations
2. Similar existing workflows for inspiration
3. System conventions and constraints

---

## EXECUTION

### JIT Loading Principle

Reference files (`patterns-unified.md`, `decision-matrix.md`) are loaded HERE by Agent 1, not in SKILL.md. This:
- Reduces initial context size
- Follows "lost-in-the-middle" mitigation
- Keeps references close to where they're used

---

### Launch All 3 Agents (SINGLE MESSAGE)

**CRITICAL**: Use a single message with 3 Task tool calls to ensure parallel execution.

```
// In a single message, invoke Task tool THREE times:

Task 1 (Agent: Patterns)
Task 2 (Agent: Similar Workflows)
Task 3 (Agent: System Coherence)
```

---

### Agent 1: Patterns Extraction

**Configuration:**
```yaml
subagent_type: Explore
model: sonnet
description: "Extract applicable patterns"
```

**Prompt:**
```
Read the following reference files:
- .claude/skills/create-workflow/references/patterns-unified.md
- .claude/skills/create-workflow/references/decision-matrix.md

Extract patterns applicable to a workflow with these characteristics:
- Objective: {interview_data.objective}
- Invocation mode: {interview_data.invocation}
- Hints for subagents: {interview_data.hints.subagents}
- Hints for hooks: {interview_data.hints.hooks}
- Inputs: {interview_data.inputs}
- Outputs: {interview_data.outputs}

Return structured analysis:
1. APPLICABLE PATTERNS
   List each pattern with brief justification of why it applies.

2. RECOMMENDED CC FEATURES
   Based on decision matrix, recommend:
   - context: fork? (yes/no + reason)
   - Subagents needed? (number, roles, model)
   - Hooks needed? (type, trigger, action)
   - allowed-tools? (list)
   - model? (opus/sonnet/haiku)
   - disable-model-invocation? (yes/no)

3. WARNINGS
   Any considerations or potential issues.
```

**Expected Output:**
```yaml
patterns:
  applicable:
    - name: "Pattern name"
      reason: "Why it applies"
    - ...
  recommended_features:
    context_fork: {decision: bool, reason: "..."}
    subagents: {needed: bool, count: N, roles: [...], reason: "..."}
    hooks: {needed: bool, types: [...], reason: "..."}
    allowed_tools: ["Tool1", "Tool2"]
    model: "sonnet" | "opus" | "haiku"
    disable_model_invocation: {decision: bool, reason: "..."}
  warnings:
    - "Warning text"
```

---

### Agent 2: Similar Workflows

**Configuration:**
```yaml
subagent_type: Explore
model: sonnet
description: "Find similar workflows"
```

**Prompt:**
```
Find workflows similar to this need:
- Objective: {interview_data.objective}
- Type hint: {interview_data.outputs}

Search in:
- .claude/skills/*/SKILL.md (current skills)
- .claude/commands/*.md (legacy commands)

For each similar workflow found:
1. Path to the workflow
2. What makes it similar
3. Reusable patterns observed
4. Structural elements worth adopting

Return structured findings:
1. SIMILAR WORKFLOWS
   - path: "..."
     similarity: "What makes it similar"
     reusable: ["Pattern 1", "Pattern 2"]

2. COMMON PATTERNS
   Patterns that appear across multiple similar workflows.

3. STRUCTURAL RECOMMENDATIONS
   Elements to consider for the new workflow structure.
```

**Expected Output:**
```yaml
similar_workflows:
  found:
    - path: ".claude/skills/example/SKILL.md"
      similarity: "Both create files from templates"
      reusable:
        - "Template loading pattern"
        - "Validation step structure"
    - ...
  common_patterns:
    - "Pattern appearing in 3+ workflows"
  structural_recommendations:
    - "Consider multi-step for this complexity"
```

---

### Agent 3: System Coherence

**Configuration:**
```yaml
subagent_type: Explore
model: sonnet
description: "Check system constraints"
```

**Prompt:**
```
Check system context for constraints that apply to new workflows.

Read:
- CLAUDE.md (project root)
- .claude/context/SYSTEM.md (if exists)
- .claude/rules/*.md (all rule files)

Extract:
1. CONVENTIONS
   Naming conventions, file organization, language requirements.

2. REQUIRED PATTERNS
   Patterns that MUST be followed (from rules).

3. CONSTRAINTS
   Limitations, restrictions, forbidden patterns.

4. INTEGRATION REQUIREMENTS
   How new workflows should integrate with existing system.

Return structured context:
```

**Expected Output:**
```yaml
system:
  conventions:
    - "Workflow files in .claude/skills/"
    - "English content, French user communication"
    - "kebab-case for file names"
  required_patterns:
    - "TDD mandatory"
    - "Self-critique required"
    - "Zero warnings policy"
  constraints:
    - "No TBD placeholders"
    - "No context:fork for meta-workflows"
  integration:
    - "Register in CLAUDE.md"
    - "Update SYSTEM.md if system-level"
```

---

## COMPILE RESULTS

After all 3 agents complete, merge their outputs:

```yaml
exploration_results:
  patterns:
    applicable: [...]    # From Agent 1
    recommended_features:
      context_fork: {...}
      subagents: {...}
      hooks: {...}
      allowed_tools: [...]
      model: "..."
      disable_model_invocation: {...}
    warnings: [...]

  similar_workflows:     # From Agent 2
    found: [...]
    common_patterns: [...]
    structural_recommendations: [...]

  system:               # From Agent 3
    conventions: [...]
    required_patterns: [...]
    constraints: [...]
    integration: [...]
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ All 3 agents completed successfully
✅ Results are structured and parseable
✅ No critical gaps (patterns, system constraints both present)
✅ Recommendations are actionable

**Self-Critique Questions:**
- Did Agent 1 find relevant patterns?
- Are Agent 2's similar workflows actually similar?
- Did Agent 3 capture project-specific constraints?
- Are there conflicts between recommendations?

**If validation fails:**
1. Identify which agent failed or returned incomplete data
2. Re-run that specific agent with clarified prompt
3. Max 2 retry attempts per agent
4. If persistent: Proceed with available data, note gaps

---

## SUCCESS / FAILURE

**Success:**
✅ `{exploration_results}` is complete and structured
✅ Clear CC feature recommendations with justifications
✅ System constraints captured
✅ Ready to design architecture

**Failure modes:**
❌ Agent timeout → Retry with smaller scope
❌ No similar workflows found → Proceed, design from patterns only
❌ References not found → Check paths, load manually if needed
❌ Conflicting recommendations → Flag for user decision in step-04

---

## NEXT

After validation passes, load `steps/step-03-design.md`

<critical>
PARALLEL EXECUTION IS MANDATORY.
If you launch agents sequentially, you are wasting time.
Single message with 3 Task tool calls = correct approach.
</critical>
