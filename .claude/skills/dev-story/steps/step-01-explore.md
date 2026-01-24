---
name: step-01-explore
description: "Explorer le contexte via 3 agents paralleles"
prev_step: steps/step-00-load.md
next_step: steps/step-02-plan.md
---

# Step 01: Parallel Exploration

## MANDATORY EXECUTION RULES (READ FIRST)

- 🛑 NEVER launch agents sequentially (MUST be parallel in SINGLE message)
- 🛑 NEVER use opus for exploration agents (use sonnet - Pattern #2)
- 🛑 NEVER ask the user questions (100% autonomous)
- 🛑 NEVER proceed without consolidating all agent results
- ✅ ALWAYS launch all 3 Task calls in a SINGLE message
- ✅ ALWAYS use `model: sonnet` for all exploration agents
- ✅ ALWAYS include story context in exploration prompts
- ✅ ALWAYS present synthesis to user BEFORE generating plan
- ✅ ALWAYS validate each agent's output before consolidation
- 📋 YOU ARE an Exploration Coordinator orchestrating parallel discovery
- 💬 FOCUS on understanding the codebase context FOR THIS STORY
- 🚫 FORBIDDEN: Coding anything in this step - exploration only

## EXECUTION PROTOCOLS

- 🎯 **Goal**: Understand codebase context through parallel exploration
- 💾 **Output**: `{exploration_synthesis}` with patterns, files, story-context
- 📖 **Reference**: Pattern #2 (Model Strategy), Pattern #6 (Parallel Agents)
- ⚡ **Performance**: 3 agents in parallel = ~3x faster than sequential

## CONTEXT BOUNDARIES

**Available from previous steps:**
- `{story_id}` - Story being implemented, from step-00
- `{mode}` - auto or supervised, from step-00
- `{story_path}` - Path to story file, from step-00
- `{story_content}` - Parsed story with criteria, from step-00
- `{epic_path}` - Path to parent Epic folder, from step-00

**Produced by this step:**
- `{patterns_found}` - Existing patterns in codebase relevant to story
- `{files_impacted}` - Files to create/modify (refined from story)
- `{exploration_synthesis}` - Consolidated results from all agents

**NOT available (do not use):**
- `{implementation_plan}` - Produced in step-02
- `{code_written}` - Produced in step-03
- `{review_results}` - Produced in step-03

## YOUR TASK

Launch 3 parallel exploration agents using the Task tool in a SINGLE message, incorporating story context, then consolidate and present synthesis.

---

## EXECUTION SEQUENCE

### 1. Prepare Agent Prompts

Define focused prompts for each agent based on `{story_content}`.

**Each prompt must:**
- Reference the story and its acceptance criteria
- Be specific to files mentioned in the story
- Request structured output (YAML format)
- Include fallback instructions if not found

### 2. Launch 3 Agents in SINGLE MESSAGE

**CRITICAL**: All 3 Task calls MUST be in ONE message for parallel execution.

```
┌─────────────────────────────────────────────────────────────────┐
│         PARALLEL AGENT EXECUTION (ONE MESSAGE)                   │
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │  Agent 1    │  │  Agent 2    │  │  Agent 3    │              │
│  │  PATTERNS   │  │  FILES      │  │  STORY CTX  │              │
│  │  (sonnet)   │  │  (sonnet)   │  │  (sonnet)   │              │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘              │
│         │                │                │                      │
│         └────────────────┼────────────────┘                      │
│                          │                                       │
│                    CONSOLIDATE                                   │
└─────────────────────────────────────────────────────────────────┘
```

#### Agent 1: Pattern Exploration

**Task call parameters:**
- `subagent_type`: "explore-codebase"
- `model`: "sonnet"
- `description`: "Find patterns for story {story_id}"

**Prompt template:**
```
Pour implementer la story "{story_id}" avec ces criteres:
{acceptance_criteria_summary}

Cherche dans le codebase:

1. Features similaires (meme type de fonctionnalite)
2. Patterns utilises (services, widgets, state management)
3. Conventions de nommage et structure
4. Services/classes reutilisables

Focus sur les fichiers mentionnes dans la story:
{files_from_story}

Retourne en YAML:
```yaml
patterns_found:
  - name: "Pattern name"
    location: "lib/path/file.dart"
    relevance: "Pourquoi c'est pertinent pour cette story"
    reusable: true | false
```
```

#### Agent 2: File Exploration

**Task call parameters:**
- `subagent_type`: "explore-codebase"
- `model`: "sonnet"
- `description`: "Analyze files for story {story_id}"

**Prompt template:**
```
Pour implementer la story "{story_id}", la story specifie ces fichiers:

A CREER:
{files_to_create}

A MODIFIER:
{files_to_modify}

Pour chaque fichier:
1. Si MODIFIER: Lis le fichier, comprends sa structure actuelle
2. Si CREER: Verifie le dossier parent, trouve des exemples similaires
3. Identifie les imports/dependances necessaires
4. Note les tests existants qui pourraient etre impactes

Retourne en YAML:
```yaml
files_analysis:
  - path: "lib/path/file.dart"
    action: CREATE | MODIFY
    current_state: "Description si MODIFY"
    similar_example: "Fichier similaire a utiliser comme reference"
    dependencies: ["imports necessaires"]
    tests_impacted: ["test files"]
```
```

#### Agent 3: Story Context Exploration

**Task call parameters:**
- `subagent_type`: "explore-codebase"
- `model`: "sonnet"
- `description`: "Explore story context for {story_id}"

**Prompt template:**
```
Pour la story "{story_id}" dans l'Epic "{epic_path}":

1. Lis le fichier Epic principal pour comprendre le contexte global
2. Lis les stories precedentes (dependencies) pour comprendre ce qui existe deja
3. Lis TRACKING.md pour voir l'etat actuel de l'Epic
4. Identifie les decisions prises dans les stories precedentes

Story dependencies: {dependencies}

Retourne en YAML:
```yaml
story_context:
  epic_goal: "Objectif global de l'Epic"
  previous_decisions:
    - story: "STORY-XX-YY"
      decision: "Ce qui a ete decide"
  existing_implementations:
    - feature: "Description"
      location: "lib/path"
  constraints:
    - constraint: "Contrainte a respecter"
      source: "Story ou Epic"
```
```

### 3. Wait for All Agents

All 3 agents execute in parallel. Wait for all to complete.

**Expected timing**: ~30-60 seconds for all 3

### 4. Validate Agent Outputs

Before consolidation, validate each agent's output.

**Validation criteria:**
| Agent | Valid If |
|-------|----------|
| Agent 1 (Patterns) | At least 1 pattern identified OR explicit "no similar patterns" |
| Agent 2 (Files) | All story files analyzed |
| Agent 3 (Story Context) | Epic context captured |

**If agent output invalid:**
1. Check if agent encountered error
2. Extract partial results if available
3. Document as exploration gap

### 5. Consolidate Results

Merge findings from all 3 agents into `{exploration_synthesis}`.

**Output structure:**
```yaml
exploration_synthesis:
  patterns_found:
    - name: "Pattern X"
      location: "lib/..."
      relevance: "..."
      reusable: true

  files_analysis:
    create:
      - path: "lib/..."
        similar_example: "..."
        dependencies: [...]
    modify:
      - path: "lib/..."
        current_state: "..."
        tests_impacted: [...]

  story_context:
    epic_goal: "..."
    previous_decisions: [...]
    constraints: [...]

  key_decisions:
    - decision: "Utiliser pattern X car..."
    - decision: "Creer nouveau service car..."

  gaps:
    - type: "agent_partial"
      description: "..."
      impact: low | medium | high
```

### 6. Present Synthesis (OBLIGATOIRE)

**CRITICAL**: TOUJOURS presenter la synthese a l'utilisateur.

Display consolidated findings:

```markdown
## Contexte Collecte pour {story_id}

### Patterns Existants
- **[Pattern 1]** dans [fichier] - [relevance]
- **[Pattern 2]** dans [fichier] - [relevance]

### Analyse des Fichiers

**A creer:**
| Fichier | Reference | Dependencies |
|---------|-----------|--------------|
| lib/x.dart | lib/similar.dart | [imports] |

**A modifier:**
| Fichier | Etat Actuel | Tests Impactes |
|---------|-------------|----------------|
| lib/y.dart | [description] | [tests] |

### Contexte Story
- **Epic Goal**: [...]
- **Decisions precedentes**: [...]
- **Contraintes**: [...]

### Decisions Cles pour cette Implementation
1. [Decision basee sur exploration]
2. [Decision basee sur exploration]
```

Cette synthese informe le plan TDD qui suit.

---

## AUTO-VALIDATION (APEX SELF-CRITIQUE)

**Before proceeding to next step, validate:**

✅ All 3 agents were launched in a SINGLE message (parallel execution)
✅ All agents used `model: sonnet` (not opus or haiku)
✅ At least 2/3 agents returned valid results
✅ All files from story are analyzed
✅ Story context from Epic is captured
✅ Synthesis was presented to user
✅ Any gaps are documented in `{exploration_synthesis}.gaps`

**Self-Critique Questions:**
- Were all 3 Task calls truly in a single message? (If not, parallelization failed)
- Did I include story context in agent prompts?
- Are the identified patterns actually relevant to THIS story's criteria?
- Did I analyze ALL files mentioned in the story?

**If validation fails:**
1. If agents launched sequentially → This is a critical Pattern #6 violation
2. Retry failed agent only (not all 3)
3. Max 2 retries per agent
4. Si echec persistant: Document gap, proceed with partial results

---

## SUCCESS METRICS

✅ 3 agents launched in parallel (single message)
✅ All agents used sonnet model
✅ Patterns relevant to story identified
✅ All story files analyzed
✅ Epic context captured
✅ Synthesis presented clearly
✅ Ready for TDD plan generation

## FAILURE MODES

❌ Agents launched sequentially → Note violation, proceed (performance loss only)
❌ Agent 1 returns empty → Fallback: Assume no reusable patterns, create from scratch
❌ Agent 2 fails on files → Fallback: Read files directly in step-03
❌ Agent 3 can't find Epic → Fallback: Proceed with story only
❌ All agents fail → Escalate: Manual exploration needed

## NEXT STEP

After validation passes, load `steps/step-02-plan.md`

<critical>
PARALLEL EXECUTION IS CRITICAL (Pattern #6).
All 3 Task calls MUST be in a SINGLE message.
Sequential = 3x slower = WRONG implementation.
Use model: sonnet for ALL exploration agents (Pattern #2).
ALWAYS include story context in prompts - this is STORY-driven development.
ALWAYS present synthesis before proceeding.
</critical>
