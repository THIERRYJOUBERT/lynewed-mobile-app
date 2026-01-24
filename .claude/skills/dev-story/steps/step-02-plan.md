---
name: step-02-plan
description: "Generer plan TDD par critere et checkpoint si mode supervised"
prev_step: steps/step-01-explore.md
next_step: steps/step-03-execute.md
---

# Step 02: TDD Plan Generation

## MANDATORY EXECUTION RULES (READ FIRST)

- 🛑 NEVER skip the plan generation (even in AUTO mode)
- 🛑 NEVER proceed to EXECUTE without a complete plan
- 🛑 NEVER ask user in AUTO mode (checkpoint is SUPERVISED only)
- 🛑 NEVER plan out of acceptance criteria order without justification
- ✅ ALWAYS create ONE plan item per acceptance criterion
- ✅ ALWAYS include TDD sequence (test then implementation for each AC)
- ✅ ALWAYS identify risks with mitigations
- ✅ ALWAYS use TodoWrite to create execution todos
- ✅ ALWAYS present plan in Markdown BEFORE checkpoint
- 📋 YOU ARE a Technical Architect designing TDD implementation strategy
- 💬 FOCUS on creating actionable plan aligned with story criteria
- 🚫 FORBIDDEN: Coding in this step - planning only

## EXECUTION PROTOCOLS

- 🎯 **Goal**: Create TDD plan with one sequence per acceptance criterion
- 💾 **Output**: `{implementation_plan}`, `{risks}`, todos created
- 📖 **Reference**: Pattern #4 (Completeness Challenge)
- ⚡ **Performance**: Mode-conditional checkpoint (SUPERVISED = ask, AUTO = skip)

## CONTEXT BOUNDARIES

**Available from previous steps:**
- `{story_id}` - Story being implemented, from step-00
- `{mode}` - auto or supervised, from step-00
- `{story_path}` - Path to story file, from step-00
- `{story_content}` - Parsed story with criteria, from step-00
- `{epic_path}` - Path to parent Epic folder, from step-00
- `{patterns_found}` - Existing patterns, from step-01
- `{files_impacted}` - Files analysis, from step-01
- `{exploration_synthesis}` - Consolidated context, from step-01

**Produced by this step:**
- `{implementation_plan}` - TDD plan by acceptance criterion
- `{risks}` - Identified risks with mitigations
- TodoWrite todos created for execution tracking

**NOT available (do not use):**
- `{code_written}` - Produced in step-03
- `{tests_written}` - Produced in step-03
- `{review_results}` - Produced in step-03

## YOUR TASK

Generate TDD implementation plan organized by acceptance criteria, create todos, and validate with user if mode=supervised.

---

## EXECUTION SEQUENCE

### 1. Order Acceptance Criteria

Determine implementation order based on dependencies.

**Ordering principles:**
- Foundation criteria first (models, services)
- Dependent criteria after their dependencies
- UI criteria typically last
- Group related criteria

**For each criterion in `{story_content}.acceptance_criteria`:**
```yaml
criterion_order:
  - order: 1
    id: AC1
    description: "Given... When... Then..."
    depends_on: []  # No dependencies
    files: ["lib/x.dart"]
    test_file: "test/x_test.dart"

  - order: 2
    id: AC2
    description: "..."
    depends_on: [AC1]  # Depends on AC1
    files: [...]
```

### 2. Create TDD Sequence Per Criterion

For each acceptance criterion, define RED → GREEN → REFACTOR.

**TDD sequence template:**
```yaml
criterion_plan:
  id: AC1
  description: "Given X When Y Then Z"
  order: 1

  red_phase:
    test_description: "Test that verifies: Given X When Y Then Z"
    test_file: "test/unit/feature_test.dart"
    test_name: "should [expected behavior]"
    assertions:
      - "expect(result, expectedValue)"

  green_phase:
    implementation_description: "Minimal code to pass test"
    files_to_modify:
      - path: "lib/feature.dart"
        changes: "Add method X that..."
    patterns_to_use:
      - pattern: "Pattern from exploration"
        reason: "Why this pattern fits"

  refactor_phase:
    improvements:
      - "Apply naming conventions"
      - "Extract if duplication"
    keep_tests_green: true
```

### 3. Generate Plan Document

Create the complete plan in Markdown format.

**Plan structure:**

```markdown
# Plan TDD : {story_id}

## Story
**Titre**: {title}
**Criteres**: {count} acceptance criteria

## Resume Exploration
- **Patterns identifies**: [list]
- **Contexte Epic**: [summary]
- **Contraintes**: [list]

## Sequence d'Implementation

### AC1: {description}
**Ordre**: 1 | **Dependances**: Aucune

#### RED (Test First)
- **Fichier**: test/unit/x_test.dart
- **Test**: `should [behavior]`
- **Assertions**: expect(...)

#### GREEN (Implementation)
- **Fichier(s)**: lib/x.dart
- **Changes**: [description]
- **Pattern**: [if applicable]

#### REFACTOR
- [Improvements to make]

---

### AC2: {description}
**Ordre**: 2 | **Dependances**: AC1

[Same structure...]

---

## Risques Identifies

| Risque | Probabilite | Impact | Mitigation |
|--------|-------------|--------|------------|
| [Risk 1] | Low/Med/High | Low/Med/High | [Action] |

## Estimation

| Metrique | Valeur |
|----------|--------|
| Criteres | {count} |
| Fichiers a creer | {count} |
| Fichiers a modifier | {count} |
| Tests a ecrire | {count} |
```

**Output**: `{implementation_plan}`

### 4. Identify Risks

Analyze potential issues based on story and exploration.

**Risk categories:**
- **Technical**: API changes, breaking changes, performance
- **Story-Specific**: Unclear criteria, missing dependencies
- **Integration**: Other stories affected, shared code
- **Testing**: Edge cases, async behavior, mocking

**For each risk:**
```yaml
risk:
  description: "What could go wrong"
  probability: Low | Medium | High
  impact: Low | Medium | High
  mitigation: "How to prevent or handle"
  related_criterion: AC1 | ALL
```

**Output**: `{risks}`

### 5. Create TodoWrite Todos

Use TodoWrite to track execution per criterion.

**Todos structure:**
```yaml
todos:
  # For each acceptance criterion
  - content: "AC1 - RED: Ecrire test [criterion summary]"
    status: pending
    activeForm: "Ecrivant test pour AC1"

  - content: "AC1 - GREEN: Implementer [criterion summary]"
    status: pending
    activeForm: "Implementant AC1"

  - content: "AC1 - REFACTOR: Nettoyer AC1"
    status: pending
    activeForm: "Refactorant AC1"

  # Repeat for AC2, AC3, etc.

  # Standard validation todos
  - content: "VALIDATE: {{TEST_CMD}} + analyze"
    status: pending
    activeForm: "Validant avec tests et analyze"

  - content: "EXAMINE: Review Adversariale"
    status: pending
    activeForm: "Executant Review Adversariale"

  - content: "UPDATE: Story status + TRACKING.md"
    status: pending
    activeForm: "Mettant a jour tracking"

  - content: "COMMIT: Finaliser via /commit"
    status: pending
    activeForm: "Finalisant via /commit"
```

### 6. Present Plan to User

**CRITICAL**: ALWAYS present the complete plan BEFORE any checkpoint.

Display the full plan document in the conversation.

### 7. Mode-Conditional Checkpoint

**IF {mode} == supervised:**

Use AskUserQuestion to validate the plan:

```yaml
questions:
  - question: "Ce plan TDD te convient ?"
    header: "Plan"
    options:
      - label: "Oui, executer"
        description: "Le plan est bon, commencer l'implementation TDD"
      - label: "Modifier le plan"
        description: "Je veux ajuster certains aspects"
      - label: "Annuler"
        description: "Abandonner cette story"
```

**Actions based on response:**
- "Oui, executer" → Proceed to step-03
- "Modifier le plan" → Ask what to change, regenerate plan, re-present
- "Annuler" → Stop workflow with message

**IF {mode} == auto:**

Skip checkpoint, proceed directly to step-03.

---

## AUTO-VALIDATION (APEX SELF-CRITIQUE)

**Before proceeding to next step, validate:**

✅ Plan has ONE sequence per acceptance criterion
✅ Each sequence has RED → GREEN → REFACTOR defined
✅ Criteria order respects dependencies
✅ At least 1 risk identified with mitigation
✅ TodoWrite todos created (3 per criterion + 4 standard)
✅ Plan was presented to user
✅ Mode-appropriate checkpoint handled
✅ No "TBD", "...", or empty sections in plan

**Self-Critique Questions:**
- Does EVERY acceptance criterion have a plan item?
- Is the order logical (dependencies first)?
- Are the test descriptions specific enough to write actual tests?
- Would another developer understand this plan?

**If validation fails:**
1. If criterion missing from plan: Add it
2. If sequence incomplete: Fill in RED/GREEN/REFACTOR
3. If checkpoint rejected: Incorporate feedback, regenerate
4. Max 2 plan iterations before proceeding with best version

---

## SUCCESS METRICS

✅ Every acceptance criterion has a plan item
✅ TDD sequence defined for each (RED → GREEN → REFACTOR)
✅ Dependencies identified and order set
✅ At least 1 risk with mitigation documented
✅ Todos created in TodoWrite
✅ Checkpoint handled according to mode
✅ Ready for APEX execution

## FAILURE MODES

❌ Plan missing criteria → Fallback: Add all missing criteria
❌ Checkpoint rejected (supervised) → Action: Ask what to change, iterate
❌ User cancels (supervised) → Action: Stop workflow, display message
❌ No risks identified → Fallback: Add "Integration risk" as minimum
❌ TodoWrite fails → Fallback: Track manually in step-03

## NEXT STEP

After validation passes (and checkpoint approved if supervised), load `steps/step-03-execute.md`

<critical>
PLAN MUST COVER ALL ACCEPTANCE CRITERIA.
TDD sequence is NON-NEGOTIABLE: test BEFORE implementation for EACH criterion.
Checkpoint is ONLY for SUPERVISED mode.
AUTO mode = plan generated and proceed immediately.
NEVER start coding without a clear plan per criterion.
</critical>
