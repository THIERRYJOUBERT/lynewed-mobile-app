---
name: step-03-explore
description: Launch 3 parallel Sonnet agents to explore FD sources
prev_step: steps/step-02-discovery.md
next_step: steps/step-04-synthesize.md
---

# Step 03: Parallel Exploration

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER launch agents sequentially - must be PARALLEL (single message, 3 Task calls)
- 🛑 NEVER skip exploration for any source
- 🛑 NEVER proceed if ALL agents fail
- ✅ ALWAYS use model: sonnet for all exploration agents (quality over cost)
- ✅ ALWAYS apply domain-specific prompts
- ✅ ALWAYS validate each agent's output
- 📋 YOU ARE the exploration coordinator launching parallel agents
- 💬 FOCUS on extracting structured technical information
- 🚫 FORBIDDEN to generate Epic content in this step
- 🚫 FORBIDDEN to launch agents one at a time

## EXECUTION PROTOCOLS:

- 🎯 Prepare domain-specific prompts BEFORE launching
- 💾 Store all agent results in state
- 📖 Validate outputs and handle failures
- 🚫 FORBIDDEN to load next step until exploration validated

## CONTEXT BOUNDARIES:

**Available from previous steps:**
- `{epic_id}` - Epic ID
- `{epic_name}` - Epic name
- `{domain}` - INFRA | DATA | UI | API
- `{sources_mapping}` - Primary FD, secondary FDs, detailed docs

## YOUR TASK:

Launch 3 parallel exploration agents using domain-specific prompts, then validate and consolidate results.

---

## EXECUTION SEQUENCE:

### 1. Prepare Domain-Specific Prompts

Based on `{domain}`, select the appropriate exploration focus:

**INFRA Domain Focus:**
```
1. Project structure and directory organization
2. Packages and dependencies (exact versions)
3. Build, test, deploy scripts
4. Environment configurations (.env, configs)
5. CI/CD pipelines and workflows
6. Naming conventions and organization patterns
```

**DATA Domain Focus:**
```
1. Database schemas (tables, columns, types, relations)
2. Migrations and schema versioning
3. Indexes and optimization (FTS, etc.)
4. Cache strategies (local, remote)
5. Data access patterns (DAO, Repository)
6. Offline handling and synchronization
```

**UI Domain Focus:**
```
1. Wireframes and mockups referenced
2. Design tokens (colors, spacing, typography)
3. Reusable components available
4. Animations and transitions
5. Responsive and adaptability rules
6. Accessibility (a11y) requirements
```

**API Domain Focus:**
```
1. Endpoints and API contracts
2. Authentication and authorization flows
3. Rate limiting and quotas
4. Error handling and codes
5. Serialization (JSON, Protobuf)
6. Retry and resilience patterns
```

### 2. Launch 3 Agents in SINGLE MESSAGE

**CRITICAL: All 3 Task calls must be in ONE message for parallel execution.**

```
┌─────────────────────────────────────────────────────────────┐
│         PARALLEL EXPLORATION (3 Task tools)                 │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Task 1       │  │ Task 2       │  │ Task 3       │      │
│  │ Primary FD   │  │ Secondary FDs│  │ Detailed Docs│      │
│  │ (sonnet)      │  │ (sonnet)      │  │ (sonnet)      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                │                  │               │
│         └────────────────┴──────────────────┘               │
│                          ↓                                  │
│                   CONSOLIDATE RESULTS                       │
└─────────────────────────────────────────────────────────────┘
```

**Task 1 - Primary FD Exploration:**

```
Task:
  description: "Explore primary FD for {epic_id}"
  model: sonnet
  subagent_type: Explore
  prompt: |
    Explore the primary FD source for {epic_name}.
    File: {sources_mapping.primary.file}

    DOMAIN: {domain}
    FOCUS AREAS:
    {domain_specific_focus}  # Insert from section 1

    Extract and structure:
    1. Sections pertinent to implementation (with section numbers)
    2. Precise technical specifications
       - For DATA: table schemas, columns, types, constraints
       - For INFRA: packages (exact versions), configs, paths
       - For UI: component specs, design tokens
       - For API: endpoints, payloads, error codes
    3. Mandatory constraints and rules
    4. Mentioned risks
    5. Stories or tasks mentioned

    Return structured list with FD section references (e.g., §3.1, §4.2).
    Be SPECIFIC - no vague descriptions.
```

**Task 2 - Secondary FDs Exploration:**

```
Task:
  description: "Explore secondary FDs for {epic_id}"
  model: sonnet
  subagent_type: Explore
  prompt: |
    Explore the secondary FD sources for {epic_name}.
    Files: {sources_mapping.secondary[*].file}

    Extract:
    1. Elements that impact this Epic
    2. Interfaces and dependencies with other Epics
    3. Complementary specifications
    4. Constraints that apply

    Return structured list of impacts and dependencies.
    Include FD section references.
```

**Task 3 - Detailed Docs Exploration:**

```
Task:
  description: "Explore detailed docs for {epic_id}"
  model: sonnet
  subagent_type: Explore
  prompt: |
    Explore docs/detailed/ directory for {epic_name}.
    Specific files: {sources_mapping.detailed[*].file}

    Search for:
    1. Technical schemas (SCHEMA_*.md)
    2. UX specifications
    3. Existing technical documentation
    4. Wireframes or UI specs

    Return list of relevant files with summary of content.
```

### 3. Collect and Validate Results

After all 3 agents complete, collect results:

```yaml
{exploration_results}:
  agent_1_primary:
    status: success | partial | failed
    sections_found: 12
    specs_extracted: [...]
    stories_identified: [...]
  agent_2_secondary:
    status: success | partial | failed
    impacts_found: 4
    dependencies: [...]
  agent_3_detailed:
    status: success | partial | failed
    files_found: 2
    schemas: [...]
```

### 4. Handle Agent Failures (Autonomous)

**CRITICAL: No AskUserQuestion in this step - 100% autonomous after Epic selection.**

For each agent that returned empty/failed results:

```
⚠️  EXPLORATION FAILURE (Autonomous Handling)

Agent: Task {N} - {description}
Source: {source_file}
Result: No relevant content found
```

**Autonomous Fallback Strategy:**

1. **First: Retry with broader terms**
   - Remove specific keywords
   - Expand search scope
   - Max 1 retry per agent

2. **Second: Use default domain sources**
   ```yaml
   DOMAIN_DEFAULTS:
     INFRA: Look for project setup, config files, package specs
     DATA: Look for schema definitions, migrations, database configs
     UI: Look for design specs, component docs, wireframes
     API: Look for endpoint specs, auth docs, integration guides
   ```

3. **Third: Document as gap and proceed**
   ```yaml
   {gaps}:
     - agent: "Task {N}"
       source: "{source_file}"
       type: "exploration_failure"
       description: "Could not extract relevant content from source"
       impact: medium
       action: "Manual review recommended after Epic creation"
   ```

**DO NOT:**
- ❌ Use AskUserQuestion
- ❌ Block workflow
- ❌ Cancel without trying fallbacks

**DO:**
- ✅ Try autonomous fallbacks first
- ✅ Document failures as gaps
- ✅ Continue workflow with available data

### 5. Consolidate Successful Results

Merge all agent outputs into unified structure:

```yaml
{consolidated_exploration}:
  total_sections_explored: 18
  technical_specs:
    schemas: [...]
    packages: [...]
    configs: [...]
  stories_identified:
    - name: "Story 1"
      source: "FD-09 §3.1"
      criteria_hints: [...]
    - name: "Story 2"
      source: "FD-09 §4.2"
      criteria_hints: [...]
  dependencies:
    - epic: EPIC-01-AUTH
      reason: "Auth required for user sessions"
  risks:
    - description: "Complex migration"
      source: "FD-09 §5"
  gaps:
    - source: "FD-07"
      description: "No exercise schema found"
```

---

## AUTO-VALIDATION (APEX SELF-CRITIQUE)

**Before proceeding to next step, validate:**

✅ At least 2 of 3 agents returned useful results
✅ Primary FD exploration returned technical specs
✅ Stories or tasks were identified from FDs
✅ Any failures are documented in {gaps}
✅ {consolidated_exploration} is populated

**Self-Critique Questions:**
- Did exploration yield SPECIFIC technical details, not vague descriptions?
- Are there section references (§X.Y) for traceability?
- Is there enough material to enrich stories with acceptance criteria?
- Would an adversarial reviewer say this exploration is thorough?

**If validation fails:**
1. Re-run failed agents with modified prompts
2. Use domain-default sources as fallback (autonomous)
3. Max 2 retry attempts per agent
4. Document unrecoverable failures as gaps and PROCEED

**Validation Passed When:**
- Primary FD yielded technical specs
- Stories/tasks identified
- Enough context for story enrichment

---

## SUCCESS METRICS:

✅ 3 agents launched in SINGLE message (parallel)
✅ Domain-specific prompts applied
✅ At least 2 agents returned useful data
✅ Technical specs extracted with section references
✅ Stories/tasks identified
✅ Failures handled and gaps documented
✅ Consolidated results ready for synthesis

## FAILURE MODES:

❌ Agents launched sequentially (not parallel)
❌ All 3 agents failed
❌ Generic prompts used instead of domain-specific
❌ No technical specs extracted (only vague descriptions)
❌ No stories/tasks identified

## EXPLORATION PROTOCOLS:

- ALWAYS use sonnet model (quality over cost - finds more sources)
- ALWAYS launch ALL 3 in SINGLE message
- ALWAYS use domain-specific focus areas
- ALWAYS extract with section references
- Handle failures gracefully, document gaps
- Never proceed with 0 useful results

## NEXT STEP:

After exploration validated, load `steps/step-04-synthesize.md`

<critical>
PARALLEL EXECUTION IS MANDATORY.
The 3 Task calls MUST be in a single message.
Sequential execution defeats the purpose of parallel agents.
</critical>
