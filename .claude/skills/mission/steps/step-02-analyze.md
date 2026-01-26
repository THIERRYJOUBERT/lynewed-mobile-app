# Step 02: Analyze (Tier 2 - Sonnet)

> Purpose: Lancer les agents Sonnet en parallele pour analyse profonde des resultats du scan.

---

## MANDATORY RULES

- 🚀 ALWAYS lancer TOUS les agents Sonnet en UNE SEULE message
- 🎯 ALWAYS utiliser les resultats de step-01 comme input
- 📊 ALWAYS produire analyse structuree avec risques
- 🚫 NEVER lancer les agents sequentiellement

## PROTOCOLS

- 🎯 **Goal**: Analyse profonde pour structurer les Epics
- 💾 **Output**: `{analysis_results}` avec features, dependencies, risks
- ⚡ **Performance**: Sonnet agents (deep analysis) en parallele

---

## CONTEXT

**Available from previous steps:**
- `{scan_results}` - Resultats du scan Haiku (step-01)
- `{project_context}` - Contexte projet (step-00)
- `{agent_counts.sonnet_count}` - Nombre d'agents (step-00)

**Produced by this step:**
- `{analysis_results}` - Analyse profonde consolidee

---

## TASK

### Agents a lancer (TOUS en parallele)

| Agent | Role | Model |
|-------|------|-------|
| scope-analyzer | Grouper requirements en features/Epics | sonnet |
| arch-analyzer | Analyser dependencies et architecture | sonnet |
| risk-analyzer | Identifier risques et estimer complexite | sonnet |
| integration-analyzer | Points d'integration avec existant (si applicable) | sonnet |
| validation-analyzer | Criteres de validation et tests (si sonnet_count >= 5) | sonnet |

---

## EXECUTION

### Lancer les agents (SINGLE MESSAGE)

**CRITICAL**: Tous les Task tool calls doivent etre dans UNE SEULE message.

```yaml
# Agent 1: Scope Analyzer
Task:
  subagent_type: Explore
  model: sonnet
  description: "Analyze scope and group features"
  prompt: |
    Analyze these requirements and group them into logical Epics.

    Scan Results:
    ---
    {scan_results}
    ---

    Your task:
    1. GROUP requirements into cohesive features (future Epics)
    2. IDENTIFY dependencies between features
    3. PROPOSE execution order based on dependencies
    4. ESTIMATE relative size (S/M/L) for each feature group

    For each Epic proposal:
    - Name (EPIC-XX-NAME format)
    - Objective (1 sentence)
    - Requirements included
    - Dependencies (blocks/blocked by)
    - Estimated size

    Format output as structured YAML.

# Agent 2: Architecture Analyzer
Task:
  subagent_type: Explore
  model: sonnet
  description: "Analyze architecture dependencies"
  prompt: |
    Analyze technical dependencies and architecture implications.

    Scan Results:
    ---
    {scan_results}
    ---

    Project Context:
    ---
    {project_context}
    ---

    Your task:
    1. MAP how new features affect existing architecture
    2. IDENTIFY shared components to create/modify
    3. DETECT potential breaking changes
    4. RECOMMEND technical approach for each feature group

    For each architectural concern:
    - Component affected
    - Type of change (new/modify/extend)
    - Risk level (low/medium/high)
    - Recommended approach

    Format output as structured YAML.

# Agent 3: Risk Analyzer
Task:
  subagent_type: Explore
  model: sonnet
  description: "Analyze risks and complexity"
  prompt: |
    Analyze risks and estimate complexity for implementation.

    Scan Results:
    ---
    {scan_results}
    ---

    Your task:
    1. IDENTIFY technical risks (integration, performance, security)
    2. IDENTIFY business risks (timeline, scope creep, unclear requirements)
    3. ESTIMATE complexity for each feature group (story points scale)
    4. PROPOSE mitigations for high-risk items

    For each risk:
    - Description
    - Category (technical/business)
    - Likelihood (low/medium/high)
    - Impact (low/medium/high)
    - Mitigation strategy

    For complexity:
    - Feature group
    - Estimated points (1-8 scale)
    - Confidence level (low/medium/high)
    - Complexity drivers

    Format output as structured YAML.

# Agent 4: Integration Analyzer (if has_existing_code)
Task:
  subagent_type: Explore
  model: sonnet
  description: "Analyze integration points"
  prompt: |
    Analyze how new features integrate with existing codebase.

    Scan Results:
    ---
    {scan_results}
    ---

    Project Context:
    ---
    {project_context}
    ---

    Your task:
    1. IDENTIFY files/modules to modify
    2. MAP integration points (where new code hooks into existing)
    3. DETECT potential conflicts with ongoing work
    4. RECOMMEND integration strategy

    For each integration point:
    - Location (file:line if possible)
    - Type (extend/modify/replace)
    - Complexity (simple/moderate/complex)
    - Notes

    Format output as structured YAML.

# Agent 5: Validation Analyzer (if sonnet_count >= 5)
Task:
  subagent_type: Explore
  model: sonnet
  description: "Define validation criteria"
  prompt: |
    Define validation criteria and testing strategy.

    Scan Results:
    ---
    {scan_results}
    ---

    Your task:
    1. DEFINE acceptance criteria for each feature group
    2. IDENTIFY testing needs (unit, integration, E2E)
    3. PROPOSE validation checkpoints
    4. MAP to existing test patterns if applicable

    For each feature group:
    - Acceptance criteria (Gherkin format)
    - Test types needed
    - Validation checkpoint
    - Coverage requirements

    Format output as structured YAML.
```

---

## COMPILE RESULTS

After all agents complete, merge into `{analysis_results}`:

```yaml
analysis_results:
  features_grouped:
    - name: "EPIC-XX-FEATURE-NAME"
      objective: "..."
      requirements_included: [...]
      dependencies:
        blocks: [...]
        blocked_by: [...]
      estimated_size: "S" | "M" | "L"
      estimated_points: 1-8
    - ...

  architecture:
    components_affected:
      - component: "..."
        change_type: "new" | "modify" | "extend"
        risk_level: "low" | "medium" | "high"
        approach: "..."
    shared_components: [...]
    breaking_changes: [...]

  risks:
    technical:
      - description: "..."
        likelihood: "low" | "medium" | "high"
        impact: "low" | "medium" | "high"
        mitigation: "..."
    business:
      - description: "..."
        likelihood: "..."
        impact: "..."
        mitigation: "..."

  integration:
    points:
      - location: "file:line"
        type: "extend" | "modify" | "replace"
        complexity: "simple" | "moderate" | "complex"
    conflicts: [...]
    strategy: "..."

  validation:
    criteria_per_feature: {...}
    testing_strategy: "..."
    checkpoints: [...]

  metadata:
    agents_launched: {count}
    agents_completed: {count}
    confidence_level: "low" | "medium" | "high"
```

---

## AUTO-VALIDATION

**Before proceeding, verify:**
- [ ] All Sonnet agents completed
- [ ] Features grouped logically
- [ ] Dependencies identified
- [ ] Risks assessed with mitigations

**Self-Critique Questions:**
- Les features sont-elles bien decoupees (pas trop grosses)?
- Les dependencies sont-elles completes?
- Les risques sont-ils realistes?
- L'estimation de complexite est-elle coherente?

**If validation fails:**
1. Retry specific agent with more context
2. Document gaps in metadata
3. Max 2 retries per agent

---

## SUCCESS / FAILURE

**Success:**
✅ Features clearly grouped into Epic proposals
✅ Dependencies mapped
✅ Risks identified with mitigations
✅ Ready for synthesis

**Failure modes:**
❌ Agent timeout → Retry with focused scope
❌ Features too vague → Add more analysis agents
❌ Conflicting analyses → Flag for user decision

---

## NEXT

When validation passes, load `steps/step-03-synthesize.md`

<critical>
PARALLEL EXECUTION IS MANDATORY.
Sonnet agents sont plus couteux - maximiser le parallelisme.
Tous les Task calls dans UNE SEULE message.
</critical>
