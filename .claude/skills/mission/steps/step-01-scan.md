# Step 01: Scan (Tier 1 - Haiku)

> Purpose: Lancer les agents Haiku en parallele pour scanner le brief et la codebase.

---

## MANDATORY RULES

- 🚀 ALWAYS lancer TOUS les agents Haiku en UNE SEULE message
- 🎯 ALWAYS adapter le nombre d'agents selon `{agent_counts.haiku_count}`
- 📊 ALWAYS collecter les resultats de tous les agents
- 🚫 NEVER lancer les agents sequentiellement

## PROTOCOLS

- 🎯 **Goal**: Scan rapide du brief + codebase
- 💾 **Output**: `{scan_results}` avec requirements, technical, priorities, codebase_map
- ⚡ **Performance**: Haiku agents (cheap, fast) en parallele

---

## CONTEXT

**Available from previous steps:**
- `{brief_content}` - Contenu du brief (step-00)
- `{project_context}` - Contexte projet (step-00)
- `{agent_counts.haiku_count}` - Nombre d'agents a lancer (step-00)

**Produced by this step:**
- `{scan_results}` - Resultats consolides du scan

---

## TASK

### Agents a lancer (TOUS en parallele)

**Agents Brief (toujours lances - 3 minimum):**

| Agent | Role | Model |
|-------|------|-------|
| brief-requirements | Extraire exigences fonctionnelles | haiku |
| brief-technical | Extraire contraintes techniques | haiku |
| brief-priorities | Extraire timeline, budget, priorites | haiku |

**Agents Codebase (adaptatifs selon haiku_count):**

| Agent | Condition | Role | Model |
|-------|-----------|------|-------|
| codebase-structure | haiku_count >= 4 | Mapper structure dossiers | haiku |
| codebase-patterns | haiku_count >= 5 | Identifier patterns code | haiku |
| codebase-deps | haiku_count >= 6 | Analyser dependencies | haiku |
| codebase-tests | haiku_count >= 7 | Scanner tests existants | haiku |
| codebase-config | haiku_count >= 8 | Analyser config build | haiku |
| codebase-api | haiku_count >= 9 | Mapper endpoints API | haiku |
| codebase-models | haiku_count >= 10 | Scanner models/entites | haiku |

---

## EXECUTION

### Lancer les agents (SINGLE MESSAGE)

**CRITICAL**: Tous les Task tool calls doivent etre dans UNE SEULE message.

```yaml
# Agent 1: Brief Requirements
Task:
  subagent_type: Explore
  model: haiku
  description: "Scan brief requirements"
  prompt: |
    Scan this client brief and extract ALL functional requirements.

    Brief content:
    ---
    {brief_content}
    ---

    Extract:
    1. USER STORIES - What users need to do
    2. FEATURES - Specific functionalities requested
    3. BUSINESS RULES - Constraints on behavior
    4. INTEGRATIONS - External systems to connect

    Format output as structured YAML.

# Agent 2: Brief Technical
Task:
  subagent_type: Explore
  model: haiku
  description: "Scan brief technical constraints"
  prompt: |
    Scan this client brief and extract ALL technical constraints.

    Brief content:
    ---
    {brief_content}
    ---

    Extract:
    1. TECH REQUIREMENTS - Specific technologies mentioned
    2. PERFORMANCE - Speed, scale, load requirements
    3. SECURITY - Auth, encryption, compliance needs
    4. COMPATIBILITY - Browser, device, API version needs

    Format output as structured YAML.

# Agent 3: Brief Priorities
Task:
  subagent_type: Explore
  model: haiku
  description: "Scan brief priorities"
  prompt: |
    Scan this client brief and extract priorities and constraints.

    Brief content:
    ---
    {brief_content}
    ---

    Extract:
    1. TIMELINE - Deadlines, phases, milestones
    2. BUDGET - Cost constraints if mentioned
    3. PRIORITIES - What's most important (MoSCoW)
    4. DEPENDENCIES - What blocks what

    Format output as structured YAML.

# Agent 4-10: Codebase agents (conditional)
# Only launch if haiku_count >= threshold
```

### Agents Codebase (si applicable)

```yaml
# Agent 4: Codebase Structure (if haiku_count >= 4)
Task:
  subagent_type: Explore
  model: haiku
  description: "Map codebase structure"
  prompt: |
    Map the structure of this codebase.

    Focus on:
    1. TOP-LEVEL DIRECTORIES - What each folder contains
    2. ARCHITECTURE PATTERN - MVC, Clean, Feature-first, etc.
    3. ENTRY POINTS - Main files, app initialization
    4. SHARED CODE - Utilities, common components

    Use Glob and Read tools to explore.
    Format output as structured YAML with key paths.

# Agent 5: Codebase Patterns (if haiku_count >= 5)
Task:
  subagent_type: Explore
  model: haiku
  description: "Identify code patterns"
  prompt: |
    Identify patterns and conventions in this codebase.

    Look for:
    1. NAMING CONVENTIONS - Files, classes, functions
    2. STATE MANAGEMENT - How data flows
    3. ERROR HANDLING - Try/catch patterns
    4. TESTING PATTERNS - How tests are structured

    Use Grep to find examples.
    Format output as structured YAML.

# Continue for agents 6-10 based on haiku_count...
```

---

## COMPILE RESULTS

After all agents complete, merge into `{scan_results}`:

```yaml
scan_results:
  brief:
    requirements:
      user_stories: [...]
      features: [...]
      business_rules: [...]
      integrations: [...]
    technical:
      tech_requirements: [...]
      performance: [...]
      security: [...]
      compatibility: [...]
    priorities:
      timeline: [...]
      budget: "..."
      priorities_moscow: {must: [...], should: [...], could: [...], wont: [...]}
      dependencies: [...]

  codebase:  # Only if agents launched
    structure:
      directories: [...]
      architecture: "..."
      entry_points: [...]
      shared_code: [...]
    patterns:
      naming: "..."
      state_management: "..."
      error_handling: "..."
      testing: "..."
    # ... other codebase findings

  metadata:
    agents_launched: {count}
    agents_completed: {count}
    gaps_detected: [...]
```

---

## AUTO-VALIDATION

**Before proceeding, verify:**
- [ ] All 3 brief agents completed
- [ ] Codebase agents completed (if launched)
- [ ] Requirements extracted are non-empty
- [ ] No critical gaps in understanding

**Self-Critique Questions:**
- Les requirements extraits couvrent-ils tout le brief ?
- Y a-t-il des parties du brief ignorees ?
- La codebase a-t-elle ete suffisamment exploree ?

**If validation fails:**
1. Retry failed agents with narrower scope
2. Document gaps in scan_results.gaps_detected
3. Max 2 retries per agent

---

## SUCCESS / FAILURE

**Success:**
✅ All brief agents completed
✅ Requirements clearly extracted
✅ Codebase mapped (if applicable)

**Failure modes:**
❌ Agent timeout → Retry with smaller scope
❌ Empty requirements → Flag for user clarification
❌ Codebase too large → Limit to top-level only

---

## NEXT

When validation passes, load `steps/step-02-analyze.md`

<critical>
PARALLEL EXECUTION IS MANDATORY.
Lancer les agents un par un = perte de temps inacceptable.
Tous les Task calls dans UNE SEULE message.
</critical>
