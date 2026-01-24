---
name: step-04-synthesize
description: Consolidate exploration results and enrich ALL stories with acceptance criteria
prev_step: steps/step-03-explore.md
next_step: steps/step-05-generate.md
---

# Step 04: Synthesize & Enrich Stories

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER leave a story without acceptance criteria from FDs
- 🛑 NEVER use "TBD", "...", "voir FD", or "a definir"
- 🛑 NEVER proceed with vague story descriptions
- ✅ ALWAYS extract 2-3 KEY criteria per story from FD sources
- ✅ ALWAYS include FD section reference for each story
- ✅ ALWAYS estimate complexity (S/M/L) for each story
- 📋 YOU ARE a synthesizer and story enricher
- 💬 FOCUS on transforming raw exploration into actionable stories
- 🚫 FORBIDDEN to generate files in this step (that's step-05)
- 🚫 FORBIDDEN to skip story enrichment

## EXECUTION PROTOCOLS:

- 🎯 Process every identified story
- 💾 Store enriched stories in state
- 📖 Validate ALL stories have criteria before proceeding
- 🚫 FORBIDDEN to load next step with incomplete stories

## CONTEXT BOUNDARIES:

**Available from previous steps:**
- `{epic_id}` - Epic ID
- `{epic_name}` - Epic name
- `{domain}` - INFRA | DATA | UI | API
- `{sources_mapping}` - Source documents
- `{consolidated_exploration}` - Results from 3 agents
- `{gaps}` - Identified gaps

## YOUR TASK:

Transform exploration results into enriched, actionable stories with acceptance criteria extracted from FDs.

---

## EXECUTION SEQUENCE:

### 1. Consolidate Technical Specifications

From `{consolidated_exploration}`, organize:

```yaml
{technical_context}:
  # For INFRA domain
  packages:
    - name: drift
      version: ^2.15.0
      source: "FD-09 §3.2"
    - name: sqlcipher_flutter_libs
      version: ^0.6.3
      source: "FD-09 §3.2"

  # For DATA domain
  schemas:
    - table: sessions
      columns: [id (ULID PK), user_id (FK), started_at (INT), ...]
      source: "FD-09 §4.1"

  # For UI domain
  components:
    - name: ExerciseCard
      props: [exercise, onTap, isSelected]
      source: "FD-05 §6.2"

  # For API domain
  endpoints:
    - path: /auth/login
      method: POST
      payload: {email, password}
      source: "FD-08 §2.1"

  configs:
    pragmas:
      - "PRAGMA cipher_compatibility = 4"
      - "PRAGMA journal_mode = WAL"
    source: "FD-09 §4.2"
```

### 2. Extract Stories from Exploration

From `{consolidated_exploration}.stories_identified`, build initial list:

```yaml
{raw_stories}:
  - id: "STORY-XX-01"
    name: "Setup projet Flutter"
    source_hint: "FD-09 §2"
  - id: "STORY-XX-02"
    name: "Configuration Drift + SQLCipher"
    source_hint: "FD-09 §3-4"
  # ... more from exploration
```

### 3. Enrich EACH Story (CRITICAL)

For EVERY story in `{raw_stories}`, apply enrichment:

```
┌─────────────────────────────────────────────────────────────┐
│              STORY ENRICHMENT PROCESS                       │
│                                                             │
│  For each story:                                            │
│                                                             │
│  1. Find FD section(s) that describe this story             │
│  2. Extract 2-3 KEY acceptance criteria (specific!)         │
│  3. Identify technical details (schemas, packages, etc.)    │
│  4. Estimate complexity (S/M/L)                             │
│  5. Note dependencies on other stories                      │
│                                                             │
│  VALIDATION: Story is enriched when:                        │
│  ✓ Has 2-3 specific criteria (not vague)                    │
│  ✓ Has FD section reference (§X.Y format)                   │
│  ✓ Has complexity estimate                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Enrichment Template per Story:**

```yaml
{enriched_story}:
  id: "STORY-XX-01"
  name: "Configuration Drift + SQLCipher"
  domain: DATA

  # KEY CRITERIA (extracted from FD - BE SPECIFIC!)
  key_criteria:
    - "Double database (user.db encrypted, ref.db read-only)"
    - "Pragmas: cipher_compatibility=4, WAL, foreign_keys=ON"
    - "Isolate compute for heavy queries"

  # FD SOURCE with section
  source:
    fd: "FD-09"
    sections: ["§4.1", "§4.2"]
    content_summary: "Database architecture and SQLCipher setup"

  # TECHNICAL DETAILS (domain-specific)
  technical_details:
    # For DATA:
    tables:
      - name: sessions
        columns: "id (ULID PK), user_id (FK→users), started_at (INT), completed_at (INT nullable)"
      - name: sets
        columns: "id (ULID PK), session_id (FK), exercise_id (FK), reps (INT), weight_grams (INT)"
    indexes:
      - "idx_sessions_user: sessions(user_id)"
    # For INFRA:
    packages:
      - "drift: ^2.15.0"
      - "sqlcipher_flutter_libs: ^0.6.3"
    paths:
      - "lib/core/database/app_database.dart"

  # COMPLEXITY
  complexity: L  # S = Small, M = Medium, L = Large

  # DEPENDENCIES
  dependencies: []  # or ["STORY-XX-00"]
```

### 4. Handle Stories Without Clear Criteria

For stories where FD source is unclear:

**Strategy 1: Cross-reference**
- Search other FDs for relevant info
- Check detailed docs

**Strategy 2: Infer from context**
- Use similar stories as reference
- Apply domain conventions

**Strategy 3: Mark for clarification**
```yaml
{story}:
  key_criteria:
    - "⚠️ A clarifier: [specific question]"
  needs_clarification: true
```

Add to gaps:
```yaml
{gaps}:
  - story: "STORY-XX-05"
    description: "UX spec needed for Home screen layout"
    impact: medium
    action: "Clarify with designer"
```

### 5. Validate Story Completeness

**For EACH story, verify:**

| Check | Requirement |
|-------|-------------|
| ✅ Name | Clear, actionable (verb + noun) |
| ✅ Key Criteria | 2-3 specific items, no "..." |
| ✅ FD Source | §X.Y reference present |
| ✅ Technical Details | Domain-specific, complete |
| ✅ Complexity | S, M, or L assigned |

**FORBIDDEN in Key Criteria:**
```
❌ "Tables: sessions (id, user_id, ...)"
❌ "Packages: drift, sqlcipher, etc."
❌ "Voir FD pour details"
❌ "TBD"
❌ "A definir"
```

**REQUIRED in Key Criteria:**
```
✅ "Tables: sessions(id ULID PK, user_id FK→users, started_at INT)"
✅ "Packages: drift ^2.15.0, sqlcipher_flutter_libs ^0.6.3"
✅ "Pragmas: PRAGMA cipher_compatibility = 4"
```

### 6. Build Final Stories Array

```yaml
{stories}:
  - id: "STORY-00-01"
    name: "Setup projet Flutter"
    domain: INFRA
    key_criteria: [...]
    source: {fd: "FD-09", sections: ["§2.1"]}
    technical_details: {...}
    complexity: M
    dependencies: []

  - id: "STORY-00-02"
    name: "Configuration Drift + SQLCipher"
    domain: DATA
    key_criteria: [...]
    source: {fd: "FD-09", sections: ["§4.1", "§4.2"]}
    technical_details: {...}
    complexity: L
    dependencies: ["STORY-00-01"]

  # ... all stories

{stories_count}: 12
{stories_with_gaps}: 1  # needing clarification
```

### 7. Generate Context Summary

```yaml
{epic_context}:
  why_this_epic: |
    [3-5 sentences from exploration about:
    - What problem this Epic solves
    - What happens if we don't do it
    - What value it brings]

  technical_pillars:
    - pillar: "Offline-First"
      impact: "Double database architecture for offline support"
    - pillar: "Performance"
      impact: "Isolate compute for heavy operations"

  architecture_needed: true  # if INFRA or DATA domain
  architecture_components:
    - "Double database (user.db + ref.db)"
    - "Drift DAO layer"
    - "Isolate for sync operations"

  risks:
    - risk: "Complex migration"
      impact: H
      mitigation: "Incremental migration with rollback"
```

### 8. STORY COMPLETENESS CHALLENGE (Critical)

**AVANT de finaliser {stories}, l'agent DOIT se challenger :**

```
┌─────────────────────────────────────────────────────────────┐
│              STORY COMPLETENESS CHALLENGE                    │
│                                                              │
│  L'agent prend ses RESPONSABILITÉS sur l'exhaustivité.      │
│  Le PRD-MASTER est une base, mais l'agent doit COMPRENDRE   │
│  réellement le POURQUOI et le COMMENT de l'Epic.            │
│                                                              │
│  QUESTIONS OBLIGATOIRES :                                    │
│                                                              │
│  1. SCOPE CHECK                                              │
│     Relire PRD-MASTER scope de cet Epic.                    │
│     → Chaque élément du scope a-t-il une story ?            │
│     → Exemple: "Widgets base" mentionné → Story existe ?    │
│                                                              │
│  2. FD COVERAGE CHECK                                        │
│     Pour chaque FD dans {sources_mapping} :                 │
│     → Toutes les sections importantes ont une story ?       │
│     → Aucun FD n'a été "oublié" dans l'exploration ?        │
│                                                              │
│  3. DOMAIN COVERAGE CHECK                                    │
│     Selon {domain}, vérifier les stories typiques :         │
│     - INFRA: Setup, CI/CD, i18n, Config → présents ?        │
│     - DATA: Schemas, Migrations, Indexes → présents ?       │
│     - UI: Tokens, Widgets base, Inputs → présents ?         │
│     - API: Endpoints, Auth, Error handling → présents ?     │
│                                                              │
│  4. CROSS-REFERENCE CHECK                                    │
│     Si des versions précédentes de cet Epic existent :      │
│     → Comparer le nombre et le scope des stories            │
│     → Justifier toute différence significative              │
│                                                              │
│  5. ADVERSARIAL CHECK                                        │
│     "Si je devais implémenter cet Epic demain, aurais-je    │
│      TOUT ce qu'il me faut dans ces stories ?"              │
│     → Si doute → Ajouter la story manquante                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Actions si stories manquantes détectées :**

1. Retourner à l'exploration si un FD a été mal couvert
2. Ajouter les stories manquantes avec critères complets
3. Documenter dans {gaps} si l'info n'existe pas dans les FDs

**Exemple concret pour EPIC-00-FOUNDATION :**

```
PRD-MASTER dit : "Stack, Drift schemas, Riverpod core, CI/CD, Design tokens, Widgets base, i18n setup"

L'agent DOIT vérifier :
- ✅ Stack → Story Setup projet
- ✅ Drift schemas → Stories Drift
- ✅ Riverpod core → Story Riverpod
- ✅ CI/CD → Story Pipeline
- ✅ Design tokens → Story Theme (OK)
- ❓ Widgets base → **MANQUANT !** → Ajouter stories :
  - Base Widgets (Cards, Containers) - FD-08 §3.5
  - Input Widgets (Wheel, NumericTap) - FD-05 §4.1-4.3
  - Gesture Widgets (Swipe*) - FD-05 §2.2
- ✅ i18n setup → Story i18n
```

**Règle d'or** : Mieux vaut 15 stories complètes que 10 stories avec des trous.

---

## AUTO-VALIDATION (APEX SELF-CRITIQUE)

**Before proceeding to next step, validate:**

✅ ALL stories have 2-3 specific key criteria
✅ ALL stories have FD section reference (§X.Y)
✅ ALL stories have complexity estimate (S/M/L)
✅ NO story contains "TBD", "...", or vague text
✅ {stories} array is fully populated
✅ {stories_count} matches array length
✅ {epic_context} has why_this_epic populated
✅ STORY COMPLETENESS CHALLENGE executed (5 checks done)
✅ All scope items from PRD-MASTER have corresponding stories

**Self-Critique Questions:**
- Would a developer know exactly what to implement from these criteria?
- Are the technical details specific enough to code against?
- Would an adversarial reviewer accept these as "production-ready"?
- Did I ACTUALLY extract from FDs, or did I invent criteria?

**If validation fails:**
1. Identify stories with incomplete criteria
2. Re-examine FD sources for missing info
3. If info truly unavailable → document as gap, mark for clarification
4. Max 2 passes through validation

---

## SUCCESS METRICS:

✅ All stories enriched with specific criteria
✅ All stories have FD section references
✅ All stories have complexity estimates
✅ Technical details are domain-specific and complete
✅ Epic context (why, pillars) is captured
✅ Gaps documented for incomplete stories
✅ No vague or placeholder content

## FAILURE MODES:

❌ Stories with "TBD" or "..." criteria
❌ Missing FD section references
❌ Vague technical details
❌ Missing complexity estimates
❌ Epic context not captured

## SYNTHESIS PROTOCOLS:

- ALWAYS trace criteria back to FD source
- ALWAYS be specific (exact versions, full schemas)
- NEVER invent criteria not in FDs (mark as gap instead)
- ALWAYS estimate complexity based on scope
- Handle gaps gracefully, don't block on missing info

## NEXT STEP:

After all stories enriched and validated, load `steps/step-05-generate.md`

<critical>
STORY QUALITY IS THE ENTIRE POINT OF THIS WORKFLOW.
Vague stories = vague implementation = bugs.
Take time to enrich properly. If info is missing, document the gap.
But NEVER use placeholder text ("...", "TBD").
</critical>
