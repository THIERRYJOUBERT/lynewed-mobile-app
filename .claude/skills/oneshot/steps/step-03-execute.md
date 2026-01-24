---
name: step-03-execute
description: "APEX Engine: TDD + Review Adversariale"
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
- ✅ ALWAYS follow TDD: RED → GREEN → REFACTOR for each unit
- ✅ ALWAYS run {{TEST_CMD}} + analyze BEFORE Review Adversariale
- ✅ ALWAYS change role for Review Adversariale (Critic, not Builder)
- ✅ ALWAYS mark todos complete as you progress
- 📋 YOU ARE a Senior Developer implementing with APEX quality
- 💬 FOCUS on disciplined TDD and rigorous self-critique
- 🚫 FORBIDDEN: Skipping any phase of the APEX cycle

## EXECUTION PROTOCOLS

- 🎯 **Goal**: Implement feature with TDD, validate technically, then review adversarially
- 💾 **Output**: `{code_written}`, `{tests_written}`, `{review_results}`
- 📖 **Reference**: Pattern #3 (APEX Self-Validation), Pattern #8 (Fallback Strategies)
- ⚡ **Performance**: Self-healing loops with max 5 attempts, learning between each

## CONTEXT BOUNDARIES

**Available from previous steps:**
- `{description}` - What to implement, from step-00
- `{mode}` - auto or supervised, from step-00
- `{session_file}` - Path to session documentation file, from step-00
- `{patterns_found}` - Existing patterns, from step-01
- `{files_impacted}` - Files to create/modify, from step-01
- `{implementation_plan}` - Detailed plan with sequence, from step-02
- `{risks}` - Identified risks, from step-02

**Produced by this step:**
- `{code_written}` - Array of files created/modified
- `{tests_written}` - Array of test files created
- `{review_results}` - Review Adversariale outcome

**NOT available (do not use):**
- `{validation_status}` - Produced in step-04
- `{commit_hash}` - Produced in step-05

## YOUR TASK

Execute the implementation plan following TDD cycle (RED-GREEN-REFACTOR), then validate technically, then perform Review Adversariale.

---

## EXECUTION SEQUENCE

### 1. For Each Item in Implementation Plan

Execute TDD cycle for each sequence item from `{implementation_plan}`.

**Mark todo "in_progress" before starting each item.**

#### 1.1 RED Phase (Test First)

Write the test that defines expected behavior.

```dart
// Example test structure
test('should [expected behavior]', () {
  // Given - Setup
  final sut = createSystemUnderTest();

  // When - Action
  final result = sut.doSomething();

  // Then - Assertion
  expect(result, expectedValue);
});
```

**Execute test to confirm it FAILS:**
```bash
{{TEST_CMD}} test/specific_test.dart
```

**Expected**: Test fails (this is correct - we haven't implemented yet)

**If test passes unexpectedly**: The behavior already exists or test is wrong. Investigate.

**Mark todo complete: "RED: Ecrire test [description]"**

#### 1.2 GREEN Phase (Minimal Implementation)

Write the MINIMAL code that makes the test pass.

**Rules:**
- No extra features
- No premature optimization
- No additional error handling beyond what test requires
- Just enough to pass the test

**Execute test to confirm it PASSES:**
```bash
{{TEST_CMD}} test/specific_test.dart
```

**Expected**: Test passes

**If test still fails**: Debug, fix, retry (max 3 attempts before investigating further)

**Mark todo complete: "GREEN: Implementer [description]"**

#### 1.3 REFACTOR Phase (Clean Code)

Improve the code without changing behavior.

**Refactoring opportunities:**
- Apply patterns from `{patterns_found}`
- Remove duplication
- Improve naming
- Extract methods if too long
- Add appropriate comments (not excessive)

**Execute test to confirm it STILL PASSES:**
```bash
{{TEST_CMD}} test/specific_test.dart
```

**Expected**: Test still passes

**If test fails after refactor**: Revert refactoring, analyze what broke

**Mark todo complete: "REFACTOR: Nettoyer [description]"**

#### 1.4 Continue with Next Item

Repeat 1.1-1.3 for each item in the plan.

**Track progress:**
- Mark todos as completed
- Note any deviations from plan
- Document unexpected discoveries

### 2. VALIDATE (Technical Validation)

**CRITICAL**: This step comes BEFORE Review Adversariale.

We don't review code that doesn't compile or has warnings.

#### 2.1 Run All Tests

```bash
{{TEST_CMD}}
```

**Expected**: All tests pass

**If tests fail:**
- Identify which test fails
- Analyze failure
- Fix (return to TDD cycle for that item)
- Max 5 attempts with different approaches

#### 2.2 Run Static Analysis

```bash
{{LINT_CMD}}
```

**Expected**: 0 issues

**If issues found:**
- Fix each issue
- Prioritize errors, then warnings, then infos
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

Le code a DEJA passe VALIDATE, donc il compile et les tests passent. Cherche maintenant des problemes de QUALITE.

#### 3.1 Review Checklist

Relire TOUT le code ecrit et chercher activement:

**Securite:**
- [ ] Injection possible (SQL, commandes, XSS) ?
- [ ] Donnees sensibles exposees ?
- [ ] Validation des inputs manquante ?
- [ ] Secrets hardcodes ?

**Logique:**
- [ ] Edge cases non geres ?
- [ ] Race conditions possibles ?
- [ ] Memory leaks potentiels ?
- [ ] Erreurs silencieuses (catch vide) ?

**Coherence:**
- [ ] Nommage inconsistant ?
- [ ] Conventions du projet non respectees ?
- [ ] Code duplique ?
- [ ] Patterns non suivis ?

**Tests:**
- [ ] Cas limites non testes ?
- [ ] Comportement d'erreur non teste ?
- [ ] Mocks incomplets ?
- [ ] Tests trop couples a l'implementation ?

#### 3.2 Document Findings

**Output format:**

```markdown
## REVIEW ADVERSARIALE - Oneshot: {description}

### PROBLEMES IDENTIFIES:

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
- **CRITIQUE**: Securite, bugs bloquants, perte de donnees
- **IMPORTANT**: Logique incorrecte, edge cases, maintenabilite
- **MINEUR**: Style, nommage, optimisations possibles

**REGLE D'OR**: Si 0 probleme trouve → C'est suspect. Re-examiner avec plus d'attention.

**Mark todo in_progress: "EXAMINE: Review Adversariale"**

### 4. RESOLVE (Fix Review Issues)

Pour chaque probleme identifie dans EXAMINE:

#### 4.1 For CRITIQUE and IMPORTANT issues:

1. Ecrire test qui expose le probleme (si pas deja teste)
2. Corriger le code
3. Verifier que le test passe
4. Re-run VALIDATE (tests + analyze)

#### 4.2 For MINEUR issues:

1. Fix if quick (<5 min)
2. Or document as acceptable technical debt

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
- No CRITIQUE issues
- No IMPORTANT issues (or all fixed)
- MINEUR issues documented or fixed

**Mark todo complete: "EXAMINE: Review Adversariale"**

**Output**: `{review_results}`
```yaml
review_results:
  iterations: N
  final_verdict: APPROVE | NEEDS_WORK
  issues_found: X
  issues_fixed: Y
  remaining_issues:
    - severity: MINEUR
      description: "..."
      status: documented
```

### 5. Update Session File - Execution & Problems

**CRITICAL**: Mettre a jour le fichier de session avec l'execution et les problemes.

**Update section "4. Execution" in `{session_file}`:**

```markdown
## 4. Execution

### Fichiers Crees
- `{path}` - {purpose}
  ```dart
  // Key snippet (max 20 lines)
  {code_snippet}
  ```
[... pour chaque fichier cree ...]

### Fichiers Modifies
- `{path}` - {change_description}
  ```dart
  // Key change (max 20 lines)
  {code_snippet}
  ```
[... pour chaque fichier modifie ...]

### Tests Ecrits
- `{test_path}` - {test_coverage}
[... liste des tests ...]

### Review Adversariale
- **Verdict**: {APPROVE | NEEDS_WORK}
- **Issues trouvees**: {count}
- **Issues corrigees**: {count}
```

**Update section "5. Problems & Solutions" if issues found:**

```markdown
## 5. Problems & Solutions

### Problem 1: {problem_title}
**Symptome**: {what_went_wrong}
**Cause**: {root_cause}
**Solution**: {how_fixed}
```

**Also update Status checklist:**
```markdown
## Status

- [x] Exploration
- [x] Plan
- [x] Execution
- [ ] Verification
- [ ] Commit
```

**Fallback**: Si Edit echoue, continuer (non-bloquant).

---

## AUTO-VALIDATION (APEX SELF-CRITIQUE)

**Before proceeding to next step, validate:**

✅ All TDD cycles completed (RED-GREEN-REFACTOR for each item)
✅ All tests pass ({{TEST_CMD}})
✅ 0 warnings ({{LINT_CMD}})
✅ Review Adversariale completed
✅ Final verdict is APPROVE (or escalated with justification)
✅ No debug code left (print statements, TODO comments)
✅ All execution todos marked complete
✅ `{session_file}` sections "4. Execution" and "5. Problems" updated

**Self-Critique Questions:**
- Did I truly write tests BEFORE implementation (not after)?
- Did I change role for Review (became a Critic, not defending my code)?
- Are there any edge cases I didn't test?
- Would I be comfortable if a teammate reviewed this code?

**If validation fails:**
1. If tests fail: Return to TDD cycle, fix
2. If analyze has warnings: Fix each warning
3. If review finds issues: RESOLVE loop
4. Max 5 overall iterations
5. Si echec persistant: Escalate with detailed report

---

## SUCCESS METRICS

✅ All code written according to plan
✅ All tests written and passing
✅ 0 warnings in {{LINT_CMD}}
✅ Review Adversariale verdict: APPROVE
✅ No CRITIQUE issues remaining
✅ Ready for final verification

## FAILURE MODES

❌ Tests keep failing → Fallback: Analyze root cause, try different approach, max 5
❌ Analyze has persistent warnings → Fallback: Fix or explicitly suppress with justification
❌ Review keeps finding issues → Fallback: Max 5 RESOLVE iterations, then escalate
❌ Can't achieve APPROVE → Fallback: Proceed with MINEUR only, document IMPORTANT in commit
❌ Self-healing exhausted → Escalate: Detailed report of all 5 attempts

## NEXT STEP

After validation passes, load `steps/step-04-verify.md`

<critical>
TDD is NON-NEGOTIABLE: RED → GREEN → REFACTOR.
VALIDATE (technique) comes BEFORE EXAMINE (review).
Review Adversariale requires ROLE CHANGE - you are a CRITIC now.
If 0 problems found, RE-EXAMINE - that's suspicious.
Self-healing must LEARN from each failure - don't repeat same approach.
Max 5 iterations total before escalation.
</critical>
