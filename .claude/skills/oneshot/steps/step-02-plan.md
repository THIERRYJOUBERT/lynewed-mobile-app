---
name: step-02-plan
description: "Generer plan d'implementation et checkpoint si mode supervised"
prev_step: steps/step-01-explore.md
next_step: steps/step-03-execute.md
---

# Step 02: Plan Generation

## MANDATORY EXECUTION RULES (READ FIRST)

- 🛑 NEVER skip the plan generation (even in AUTO mode)
- 🛑 NEVER proceed to EXECUTE without a complete plan
- 🛑 NEVER ask user in AUTO mode (checkpoint is SUPERVISED only)
- ✅ ALWAYS present the complete plan in Markdown BEFORE checkpoint
- ✅ ALWAYS include TDD sequence (test then implementation for each unit)
- ✅ ALWAYS identify risks with mitigations
- ✅ ALWAYS use TodoWrite to create execution todos
- 📋 YOU ARE a Technical Architect designing an implementation strategy
- 💬 FOCUS on creating a clear, actionable plan based on exploration
- 🚫 FORBIDDEN: Coding in this step - planning only

## EXECUTION PROTOCOLS

- 🎯 **Goal**: Create detailed implementation plan with TDD sequence
- 💾 **Output**: `{implementation_plan}`, `{risks}`, todos created
- 📖 **Reference**: Pattern #4 (Completeness Challenge)
- ⚡ **Performance**: Mode-conditional checkpoint (SUPERVISED = ask, AUTO = skip)

## CONTEXT BOUNDARIES

**Available from previous steps:**
- `{description}` - What to implement, from step-00
- `{mode}` - auto or supervised, from step-00
- `{complexity}` - S/M/L, from step-00
- `{session_file}` - Path to session documentation file, from step-00
- `{patterns_found}` - Existing patterns, from step-01
- `{files_impacted}` - Files to create/modify, from step-01
- `{docs_relevant}` - Documentation found, from step-01
- `{exploration_synthesis}` - Consolidated context, from step-01

**Produced by this step:**
- `{implementation_plan}` - Detailed plan with sequence
- `{risks}` - Identified risks with mitigations
- TodoWrite todos created for execution tracking

**NOT available (do not use):**
- `{code_written}` - Produced in step-03
- `{tests_written}` - Produced in step-03
- `{review_results}` - Produced in step-03

## YOUR TASK

Generate a complete implementation plan based on exploration results, create todos, and validate with user if mode=supervised.

---

## EXECUTION SEQUENCE

### 1. Design Implementation Sequence

Order the work for TDD flow (test → implementation for each unit).

**Sequence principles:**
- Dependencies first (services before widgets that use them)
- Tests before implementation (TDD)
- One logical unit at a time
- Group related changes

**For each identified file in `{files_impacted}`:**
```yaml
sequence_item:
  order: 1
  file: "lib/path/file.dart"
  action: CREATE | MODIFY
  test_file: "test/path/file_test.dart"
  description: "What changes/creates"
  depends_on: [0] | []  # Previous items this depends on
```

### 2. Generate Plan Document

Create the complete plan in Markdown format.

**Plan structure:**

```markdown
# Plan Implementation : {description}

## Resume Exploration
[Synthese des patterns trouves et contexte]

## Approche Technique
[Description de l'approche choisie et pourquoi, basee sur patterns trouves]

## Fichiers a Modifier

| # | Action | Fichier | Test | Description |
|---|--------|---------|------|-------------|
| 1 | CREATE | lib/services/x.dart | test/services/x_test.dart | Service principal |
| 2 | MODIFY | lib/features/y.dart | test/features/y_test.dart | Integration |

## Sequence d'Implementation (TDD)

### 1. [Premier element]
- **Test** : [Ce que le test verifie]
- **Code** : [Ce que l'implementation fait]
- **Fichiers** : [Fichiers concernes]

### 2. [Deuxieme element]
- **Test** : [...]
- **Code** : [...]
- **Fichiers** : [...]

[... pour chaque element]

## Risques Identifies

| Risque | Probabilite | Impact | Mitigation |
|--------|-------------|--------|------------|
| [Risque 1] | Low/Med/High | Low/Med/High | [Action] |

## Estimation

- **Complexite** : {complexity}
- **Fichiers** : X a creer, Y a modifier
- **Tests** : Z scenarios
```

**Output**: `{implementation_plan}`

### 3. Identify Risks

Analyze potential issues.

**Risk categories:**
- **Technical**: API changes, breaking changes, performance
- **Scope**: Feature creep, unclear requirements
- **Integration**: Other features affected, tests breaking
- **Quality**: Edge cases, error handling gaps

**For each risk:**
```yaml
risk:
  description: "What could go wrong"
  probability: Low | Medium | High
  impact: Low | Medium | High
  mitigation: "How to prevent or handle"
```

**Output**: `{risks}`

### 4. Create TodoWrite Todos

Use TodoWrite to track execution.

**Standard todos for oneshot:**

```yaml
todos:
  # For each sequence item
  - content: "RED: Ecrire test [description]"
    status: pending
    activeForm: "Ecrivant test [description]"

  - content: "GREEN: Implementer [description]"
    status: pending
    activeForm: "Implementant [description]"

  - content: "REFACTOR: Nettoyer [description]"
    status: pending
    activeForm: "Refactorant [description]"

  # Standard validation todos
  - content: "VALIDATE: {{TEST_CMD}} + analyze"
    status: pending
    activeForm: "Validant avec tests et analyze"

  - content: "EXAMINE: Review Adversariale"
    status: pending
    activeForm: "Executant Review Adversariale"

  - content: "COMMIT: Finaliser via /commit"
    status: pending
    activeForm: "Finalisant via /commit"
```

### 5. Present Plan to User

**CRITICAL**: ALWAYS present the complete plan BEFORE any checkpoint.

Display the full plan document in the conversation.

### 6. Mode-Conditional Checkpoint

**IF {mode} == supervised:**

Use AskUserQuestion to validate the plan:

```yaml
questions:
  - question: "Ce plan d'implementation te convient ?"
    header: "Plan"
    options:
      - label: "Oui, executer"
        description: "Le plan est bon, commencer l'implementation"
      - label: "Modifier le plan"
        description: "Je veux ajuster certains aspects"
      - label: "Annuler"
        description: "Abandonner ce oneshot"
```

**Actions based on response:**
- "Oui, executer" → Proceed to step-03
- "Modifier le plan" → Ask what to change, regenerate plan, re-present
- "Annuler" → Stop workflow with message

**IF {mode} == auto:**

Skip checkpoint, proceed directly to step-03.

### 7. Update Session File - Plan

**CRITICAL**: Mettre a jour le fichier de session avec le plan.

**Update section "3. Plan" in `{session_file}`:**

```markdown
## 3. Plan

### Approche Technique
{approche_description}

### Sequence TDD

| # | Test | Implementation | Fichiers |
|---|------|----------------|----------|
| 1 | {test_description} | {impl_description} | {files} |
| 2 | ... | ... | ... |
[... pour chaque element ...]

### Risques Identifies

| Risque | Impact | Mitigation |
|--------|--------|------------|
| {risk} | {impact} | {mitigation} |
[... si risques identifies ...]
```

**Also update Status checklist:**
```markdown
## Status

- [x] Exploration
- [x] Plan
- [ ] Execution
- [ ] Verification
- [ ] Commit
```

**Fallback**: Si Edit echoue, continuer (non-bloquant).

---

## AUTO-VALIDATION (APEX SELF-CRITIQUE)

**Before proceeding to next step, validate:**

✅ Plan document is complete (all sections filled)
✅ Sequence follows TDD (test before implementation for each unit)
✅ At least 1 risk identified with mitigation
✅ TodoWrite todos created for tracking
✅ Plan was presented to user
✅ Mode-appropriate checkpoint handled (supervised=asked, auto=skipped)
✅ No "TBD", "...", or empty sections in plan
✅ `{session_file}` section "3. Plan" updated (or noted if failed)

**Self-Critique Questions:**
- Is the sequence order correct (dependencies first)?
- Are the test descriptions specific enough to write actual tests?
- Did I miss any edge cases in risks?
- Would another developer understand this plan?

**If validation fails:**
1. If plan incomplete: Fill missing sections
2. If sequence wrong: Reorder based on dependencies
3. If checkpoint rejected: Incorporate feedback, regenerate
4. Max 2 plan iterations before proceeding with best version

---

## SUCCESS METRICS

✅ Plan has all required sections filled
✅ TDD sequence is clear (test → code → refactor for each)
✅ At least 1 risk with mitigation documented
✅ Todos created in TodoWrite
✅ Checkpoint handled according to mode
✅ Ready for APEX execution

## FAILURE MODES

❌ Plan too vague → Fallback: Add more detail from exploration results
❌ Checkpoint rejected (supervised) → Action: Ask what to change, iterate
❌ User cancels (supervised) → Action: Stop workflow, display message
❌ No risks identified → Fallback: Add "Integration risk" as minimum
❌ TodoWrite fails → Fallback: Track manually, note in step-03

## NEXT STEP

After validation passes (and checkpoint approved if supervised), load `steps/step-03-execute.md`

<critical>
PLAN MUST BE COMPLETE before execution.
TDD sequence is NON-NEGOTIABLE: test BEFORE implementation.
Checkpoint is ONLY for SUPERVISED mode.
AUTO mode = plan generated and proceed immediately.
NEVER start coding without a clear plan.
</critical>
