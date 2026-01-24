---
name: step-01-explore
description: "Explorer le contexte via 3 agents paralleles"
prev_step: steps/step-00-prerequis.md
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
- ✅ ALWAYS present synthesis to user BEFORE generating plan
- ✅ ALWAYS validate each agent's output before consolidation
- 📋 YOU ARE an Exploration Coordinator orchestrating parallel discovery
- 💬 FOCUS on understanding the codebase context BEFORE planning
- 🚫 FORBIDDEN: Coding anything in this step - exploration only

## EXECUTION PROTOCOLS

- 🎯 **Goal**: Understand codebase context through parallel exploration
- 💾 **Output**: `{exploration_synthesis}` with patterns, files, docs
- 📖 **Reference**: Pattern #2 (Model Strategy), Pattern #6 (Parallel Agents)
- ⚡ **Performance**: 3 agents in parallel = ~3x faster than sequential

## CONTEXT BOUNDARIES

**Available from previous steps:**
- `{description}` - What to implement, from step-00
- `{mode}` - auto or supervised, from step-00
- `{complexity}` - S/M/L, from step-00
- `{session_file}` - Path to session documentation file, from step-00

**Produced by this step:**
- `{patterns_found}` - Existing patterns in codebase relevant to feature
- `{files_impacted}` - Files to create/modify
- `{docs_relevant}` - Relevant documentation found
- `{exploration_synthesis}` - Consolidated results from all agents

**NOT available (do not use):**
- `{implementation_plan}` - Produced in step-02
- `{code_written}` - Produced in step-03
- `{review_results}` - Produced in step-03

## YOUR TASK

Launch 3 parallel exploration agents using the Task tool in a SINGLE message, then consolidate and present synthesis to user.

---

## EXECUTION SEQUENCE

### 1. Prepare Agent Prompts

Define focused, specific prompts for each exploration agent based on `{description}`.

**Each prompt must:**
- Be specific to the feature being implemented
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
│  │  PATTERNS   │  │  FILES      │  │  DOCS       │              │
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
- `description`: "Find patterns for {description}"

**Prompt template:**
```
Pour implementer "{description}", cherche dans le codebase:

1. Features similaires (meme type de fonctionnalite)
2. Patterns utilises (services, widgets, state management)
3. Conventions de nommage et structure
4. Services/classes reutilisables

Retourne en YAML:
```yaml
patterns_found:
  - name: "Pattern name"
    location: "lib/path/file.dart"
    relevance: "Pourquoi c'est pertinent"
    reusable: true | false
```
```

#### Agent 2: File Exploration

**Task call parameters:**
- `subagent_type`: "explore-codebase"
- `model`: "sonnet"
- `description`: "Identify files for {description}"

**Prompt template:**
```
Pour implementer "{description}", identifie:

1. Fichiers a CREER (nouveaux)
2. Fichiers a MODIFIER (existants)
3. Tests existants a adapter
4. Dossier cible selon structure du projet

Retourne en YAML:
```yaml
files_impacted:
  - action: CREATE | MODIFY
    path: "lib/path/file.dart"
    purpose: "Pourquoi ce fichier"

tests_needed:
  - path: "test/path/test.dart"
    type: unit | widget | integration
```
```

#### Agent 3: Documentation Exploration

**Task call parameters:**
- `subagent_type`: "explore-docs" (ou "Explore" si libs externes)
- `model`: "sonnet"
- `description`: "Find docs for {description}"

**Prompt template:**
```
Pour implementer "{description}", cherche:

1. Documentation interne (docs/, README)
2. APIs des libs utilisees (si libs externes)
3. Best practices pour ce type de feature
4. Exemples de code similaires

Retourne en YAML:
```yaml
docs_relevant:
  - source: "internal | external"
    location: "path or URL"
    content: "Resume pertinent"

best_practices:
  - practice: "Description"
    applies_to: "Aspect de l'implementation"
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
| Agent 2 (Files) | At least 1 file to create OR modify identified |
| Agent 3 (Docs) | Any relevant doc found OR explicit "no docs found" |

**If agent output invalid:**
1. Check if agent encountered error
2. Extract partial results if available
3. Document as exploration gap

### 5. Consolidate Results

Merge findings from all 3 agents.

**Output**: `{exploration_synthesis}`

```yaml
exploration_synthesis:
  patterns_found:
    - name: "Pattern X"
      location: "lib/..."
      relevance: "..."

  files_impacted:
    create:
      - path: "lib/..."
        purpose: "..."
    modify:
      - path: "lib/..."
        purpose: "..."

  docs_relevant:
    - source: "..."
      summary: "..."

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

Display consolidated findings in readable format:

```markdown
## Contexte Collecte

### Patterns Existants
- **[Pattern 1]** dans [fichier] - [relevance]
- **[Pattern 2]** dans [fichier] - [relevance]

### Fichiers Impactes
| Action | Fichier | Raison |
|--------|---------|--------|
| CREATE | lib/x.dart | Nouveau service |
| MODIFY | lib/y.dart | Ajout methode |

### Documentation Pertinente
- [Source] : [resume]

### Decisions Cles
1. [Decision basee sur exploration]
2. [Decision basee sur exploration]
```

Cette synthese informe le plan qui suit.

### 7. Update Session File - Exploration

**CRITICAL**: Mettre a jour le fichier de session avec les resultats d'exploration.

**Update section "2. Exploration" in `{session_file}`:**

```markdown
## 2. Exploration

### Patterns Trouves
- **{pattern_name}** - {location} - {relevance}
[... max 5 patterns ...]

### Fichiers Impactes
| Action | Fichier | Raison |
|--------|---------|--------|
| CREATE | {path} | {purpose} |
| MODIFY | {path} | {purpose} |
[... tous les fichiers ...]

### Documentation Pertinente
- {source}: {summary}
[... si applicable ...]

### Decisions Cles
1. {decision_1}
2. {decision_2}
[... basees sur exploration ...]
```

**Also update Status checklist:**
```markdown
## Status

- [x] Exploration
- [ ] Plan
- [ ] Execution
- [ ] Verification
- [ ] Commit
```

**Fallback**: Si Edit echoue, continuer (non-bloquant).

---

## AUTO-VALIDATION (APEX SELF-CRITIQUE)

**Before proceeding to next step, validate:**

✅ All 3 agents were launched in a SINGLE message (parallel execution)
✅ All agents used `model: sonnet` (not opus or haiku)
✅ At least 2/3 agents returned valid results
✅ `{files_impacted}` has at least 1 file identified
✅ Synthesis was presented to user
✅ Any gaps are documented in `{exploration_synthesis}.gaps`
✅ `{session_file}` section "2. Exploration" updated (or noted if failed)

**Self-Critique Questions:**
- Were all 3 Task calls truly in a single message? (If not, parallelization failed)
- Did I use sonnet for all agents? (Opus is wasteful for exploration)
- Are the identified patterns actually relevant to this feature?
- Did I miss any obvious files that should be modified?

**If validation fails:**
1. If agents launched sequentially → This is a critical Pattern #6 violation, note for future
2. Retry failed agent only (not all 3)
3. Max 2 retries per agent
4. Si echec persistant: Document gap, proceed with partial results

---

## SUCCESS METRICS

✅ 3 agents launched in parallel (single message)
✅ All agents used sonnet model
✅ At least 1 pattern or convention identified
✅ At least 1 file to create/modify identified
✅ Synthesis presented clearly
✅ Ready for plan generation

## FAILURE MODES

❌ Agents launched sequentially → Note violation, proceed (performance loss only)
❌ Agent 1 returns empty → Fallback: Assume no reusable patterns, create from scratch
❌ Agent 2 finds no files → Fallback: Ask in next step where to put code
❌ Agent 3 finds no docs → Fallback: Proceed without external guidance
❌ All agents fail → Escalate: Manual exploration needed

## NEXT STEP

After validation passes, load `steps/step-02-plan.md`

<critical>
PARALLEL EXECUTION IS CRITICAL (Pattern #6).
All 3 Task calls MUST be in a SINGLE message.
Sequential = 3x slower = WRONG implementation.
Use model: sonnet for ALL exploration agents (Pattern #2).
ALWAYS present synthesis before proceeding.
</critical>
