---
name: step-03-execute
description: "APEX Engine: TDD + Review Adversariale par critere"
prev_step: steps/step-02-plan.md
next_step: steps/step-04-verify.md
---

# Step 03: APEX Execution

## MANDATORY EXECUTION RULES (READ FIRST)

- 🛑 NEVER write implementation before test (TDD obligatoire)
- 🛑 NEVER skip VALIDATE before EXAMINE (technique avant review)
- 🛑 NEVER skip Review Adversariale (EXAMINE obligatoire)
- 🛑 NEVER proceed with APPROVE if 0 problems found (suspect - re-examine)
- 🛑 NEVER repeat same approach without analyzing failure (self-healing intelligent)
- 🛑 NEVER skip any acceptance criterion
- ✅ ALWAYS follow TDD: RED → GREEN → REFACTOR for EACH criterion
- ✅ ALWAYS run {{TEST_CMD}} + analyze BEFORE Review Adversariale
- ✅ ALWAYS change role for Review Adversariale (Critic, not Builder)
- ✅ ALWAYS mark todos complete as you progress
- 📋 YOU ARE a Senior Developer implementing with APEX quality
- 💬 FOCUS on disciplined TDD per acceptance criterion
- 🚫 FORBIDDEN: Skipping any phase of the APEX cycle

## EXECUTION PROTOCOLS

- 🎯 **Goal**: Implement each criterion with TDD, validate, then review
- 💾 **Output**: `{code_written}`, `{tests_written}`, `{review_results}`
- 📖 **Reference**: Pattern #3 (APEX Self-Validation), Pattern #8 (Fallback)
- ⚡ **Performance**: Self-healing loops with max 5 attempts, learning between each

## CONTEXT BOUNDARIES

**Available from previous steps:**
- `{story_id}` - Story being implemented, from step-00
- `{story_content}` - Parsed story with criteria, from step-00
- `{patterns_found}` - Existing patterns, from step-01
- `{files_impacted}` - Files analysis, from step-01
- `{implementation_plan}` - TDD plan by criterion, from step-02
- `{risks}` - Identified risks, from step-02

**Produced by this step:**
- `{code_written}` - Array of files created/modified
- `{tests_written}` - Array of test files created
- `{review_results}` - Review Adversariale outcome

**NOT available (do not use):**
- `{validation_status}` - Produced in step-04
- `{commit_hash}` - Produced in step-05

## YOUR TASK

Execute TDD cycle (RED-GREEN-REFACTOR) for EACH acceptance criterion, then validate technically, then perform Review Adversariale.

---

## EXECUTION SEQUENCE

### 1. For EACH Acceptance Criterion in Plan

Execute TDD cycle following `{implementation_plan}` order.

**Mark todo "in_progress" before starting each criterion.**

#### 1.1 RED Phase (Test First)

Write the test that defines expected behavior for this criterion.

**Test structure:**
```dart
// test/unit/feature_test.dart
group('[Criterion ID] - [Description]', () {
  test('should [expected behavior from Gherkin]', () {
    // Given - Setup matching criterion
    final sut = createSystemUnderTest();

    // When - Action from criterion
    final result = sut.doAction();

    // Then - Assertion from criterion
    expect(result, expectedValue);
  });
});
```

**Execute test to confirm it FAILS:**
```bash
{{TEST_CMD}} test/path/specific_test.dart
```

**Expected**: Test fails (correct - we haven't implemented yet)

**If test passes unexpectedly**: Behavior already exists or test is wrong. Investigate.

**Mark todo complete: "AC[N] - RED: Ecrire test..."**

#### 1.2 GREEN Phase (Minimal Implementation)

Write the MINIMAL code that makes the test pass.

**Rules:**
- Implement ONLY what the criterion requires
- No extra features beyond Gherkin specification
- No premature optimization
- Use patterns from `{patterns_found}` if applicable
- Just enough to pass the test

**Execute test to confirm it PASSES:**
```bash
{{TEST_CMD}} test/path/specific_test.dart
```

**Expected**: Test passes

**If test still fails**: Debug, fix, retry (max 3 attempts before investigating further)

**Mark todo complete: "AC[N] - GREEN: Implementer..."**

#### 1.3 REFACTOR Phase (Clean Code)

Improve the code without changing behavior.

**Refactoring opportunities:**
- Apply patterns from exploration
- Remove duplication with existing code
- Improve naming per project conventions
- Extract methods if too long
- Ensure code matches project style

**Execute test to confirm it STILL PASSES:**
```bash
{{TEST_CMD}} test/path/specific_test.dart
```

**Expected**: Test still passes

**If test fails after refactor**: Revert refactoring, analyze what broke

**Mark todo complete: "AC[N] - REFACTOR: Nettoyer..."**

#### 1.4 Continue with Next Criterion

Repeat 1.1-1.3 for EACH acceptance criterion in order.

**Track progress:**
- Mark todos as completed per criterion
- Note any deviations from plan
- Document unexpected discoveries

### 2. VALIDATE (Technical Validation)

**CRITICAL**: This step comes BEFORE Review Adversariale.

We don't review code that doesn't compile or has warnings.

#### 2.1 Run All Tests

```bash
{{TEST_CMD}}
```

**Expected**: All tests pass (0 failures)

**If tests fail:**
- Identify which test fails
- Analyze: Is it related to current story or regression?
- Fix (return to TDD cycle for that criterion)
- Max 5 attempts with different approaches

#### 2.2 Run Static Analysis

```bash
{{LINT_CMD}}
```

**Expected**: 0 issues

**If issues found:**
- Fix each issue
- Prioritize: errors → warnings → infos
- Re-run analyze
- Max 5 attempts

**Mark todo complete: "VALIDATE: {{TEST_CMD}} + analyze"**

**Output after VALIDATE:**
```yaml
validate_status:
  tests: PASS | FAIL
  analyze: 0 issues | N issues
  ready_for_review: true | false
```

**If not ready for review**: Fix issues before proceeding. Do NOT review broken code.

### 3. EXAMINE (Review Adversariale)

**CHANGEMENT DE ROLE OBLIGATOIRE**

Tu n'es PLUS le developpeur. Tu es maintenant un **Senior Reviewer Impitoyable** dont l'unique but est de TROUVER DES PROBLEMES.

Le code a DEJA passe VALIDATE. Cherche maintenant des problemes de QUALITE.

#### 3.1 Review Checklist (Per Criterion)

For EACH acceptance criterion implemented:

**Criterion Alignment:**
- [ ] Implementation matches EXACTLY the Gherkin spec?
- [ ] No scope creep (extra features not in criterion)?
- [ ] No missing behavior from criterion?

**Securite:**
- [ ] Injection possible (SQL, commandes, XSS)?
- [ ] Donnees sensibles exposees?
- [ ] Validation des inputs manquante?
- [ ] Secrets hardcodes?

**Logique:**
- [ ] Edge cases from criterion not handled?
- [ ] Race conditions possibles?
- [ ] Memory leaks potentiels?
- [ ] Erreurs silencieuses (catch vide)?

**Coherence:**
- [ ] Nommage inconsistant avec codebase?
- [ ] Conventions du projet non respectees?
- [ ] Code duplique qui aurait pu reutiliser patterns existants?

**Tests:**
- [ ] Test covers ALL aspects of Gherkin criterion?
- [ ] Cas limites non testes?
- [ ] Comportement d'erreur non teste?

#### 3.2 Document Findings

**Output format:**
```markdown
## REVIEW ADVERSARIALE - Story: {story_id}

### Par Critere

#### AC1: [Description]
- ✅ Implementation conforme au Gherkin
- ⚠️ [IMPORTANT] Edge case X non gere - lib/x.dart:42

#### AC2: [Description]
- ✅ Implementation conforme
- ✅ Aucun probleme trouve

### Problemes Globaux

1. **[CRITIQUE]** [Description] - [fichier:ligne]
   - Raison: [Pourquoi c'est un probleme]
   - Fix: [Comment corriger]

2. **[IMPORTANT]** [Description] - [fichier:ligne]
   - Raison: [...]
   - Fix: [...]

3. **[MINEUR]** [Description] - [fichier:ligne]
   - Raison: [...]
   - Fix: [...]

### VERDICT: APPROVE | NEEDS_WORK
```

**Severite:**
- **CRITIQUE**: Securite, bugs bloquants, criterion non respecte
- **IMPORTANT**: Logique incorrecte, edge cases, maintenabilite
- **MINEUR**: Style, nommage, optimisations

**REGLE D'OR**: Si 0 probleme trouve → C'est suspect. Re-examiner.

**Mark todo in_progress: "EXAMINE: Review Adversariale"**

### 4. RESOLVE (Fix Review Issues)

Pour chaque probleme identifie:

#### 4.1 For CRITIQUE and IMPORTANT:

1. Ecrire test qui expose le probleme (si pas deja teste)
2. Corriger le code
3. Verifier que le test passe
4. Re-run VALIDATE (tests + analyze)

#### 4.2 For MINEUR:

1. Fix if quick (<5 min)
2. Or document as acceptable for this story

#### 4.3 Re-EXAMINE After Fixes

After fixing, repeat EXAMINE (review loop).

**Boucle de correction:**
```
EXAMINE → RESOLVE → VALIDATE → EXAMINE
(max 5 iterations)
```

**If issues persist after 5 iterations:**
- Document remaining issues
- Escalate with detailed report
- Proceed only if no CRITIQUE issues remain

#### 4.4 Final Verdict

**When EXAMINE returns APPROVE:**
- All criteria implemented per Gherkin
- No CRITIQUE issues
- No IMPORTANT issues (or all fixed)
- MINEUR issues documented or fixed

**Mark todo complete: "EXAMINE: Review Adversariale"**

**Output**: `{review_results}`
```yaml
review_results:
  criteria_reviewed: [AC1, AC2, ...]
  all_criteria_conform: true | false
  iterations: N
  final_verdict: APPROVE | NEEDS_WORK
  issues_found: X
  issues_fixed: Y
  remaining_issues: [...]
```

---

## AUTO-VALIDATION (APEX SELF-CRITIQUE)

**Before proceeding to next step, validate:**

✅ All acceptance criteria implemented (check each AC from story)
✅ All TDD cycles completed (RED-GREEN-REFACTOR for each AC)
✅ All tests pass ({{TEST_CMD}})
✅ 0 warnings ({{LINT_CMD}})
✅ Review Adversariale completed with per-criterion check
✅ Final verdict is APPROVE (or escalated with justification)
✅ No debug code left (print statements, TODO comments)
✅ All criterion todos marked complete

**Self-Critique Questions:**
- Did I implement EVERY acceptance criterion from the story?
- Did I truly write tests BEFORE implementation?
- Did I check each criterion against its Gherkin spec in review?
- Would I be comfortable if a teammate reviewed this code?

**If validation fails:**
1. If criterion missing: Go back, implement it
2. If tests fail: Return to TDD cycle, fix
3. If review finds issues: RESOLVE loop
4. Max 5 overall iterations
5. Si echec persistant: Escalate with detailed report

---

## SUCCESS METRICS

✅ All acceptance criteria implemented
✅ All tests written and passing
✅ 0 warnings in {{LINT_CMD}}
✅ Review Adversariale verdict: APPROVE
✅ Each criterion verified against Gherkin
✅ No CRITIQUE issues remaining
✅ Ready for final verification

## FAILURE MODES

❌ Criterion missed → Return to step, implement missing criterion
❌ Tests keep failing → Analyze root cause, try different approach, max 5
❌ Review keeps finding issues → Max 5 RESOLVE iterations, then escalate
❌ Can't achieve APPROVE → Proceed with MINEUR only, document IMPORTANT
❌ Self-healing exhausted → Escalate: Detailed report of all 5 attempts

## NEXT STEP

After validation passes, load `steps/step-04-verify.md`

<critical>
TDD is NON-NEGOTIABLE: RED → GREEN → REFACTOR per CRITERION.
VALIDATE (technique) comes BEFORE EXAMINE (review).
Review Adversariale requires ROLE CHANGE - you are a CRITIC now.
CHECK EACH CRITERION against its Gherkin spec.
If 0 problems found, RE-EXAMINE - that's suspicious.
Self-healing must LEARN from each failure.
Max 5 iterations total before escalation.
</critical>
