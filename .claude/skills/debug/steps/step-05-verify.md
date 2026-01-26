---
name: step-05-verify
description: "Validation complete et decision: succes ou nouvelle iteration"
prev_step: steps/step-04-fix.md
next_step: null
---

# Step 05: VERIFY (The QA)

## MANDATORY RULES (READ FIRST)

- 🚫 **INTERDIT**: Declarer succes sans avoir execute TOUS les tests
- 🚫 **INTERDIT**: Ignorer les warnings
- ✅ **OBLIGATOIRE**: Executer la suite complete de tests
- ✅ **OBLIGATOIRE**: Executer l'analyse statique
- ✅ **OBLIGATOIRE**: Si echec, documenter et retourner a step-00

## PROTOCOLS

- 🎯 **Goal**: Confirmer que le bug est resolu SANS regression
- 💾 **Output**: Verdict final ou nouvelle iteration
- ⚡ **Performance**: Prendre le temps de tout verifier - un bug "resolu" qui revient coute cher

## CONTEXT

**Available from previous steps:**
- `{symptom}` - Description du bug original (from step-00)
- `{hypothesis}` - Cause racine prouvee (from step-02)
- `{chosen_solution}` - Solution appliquee (from step-03)
- `{fix_applied}` - Details du fix (from step-04)
- `{regression_test}` - Test de regression (from step-04)
- `{iteration}` - Numero d'iteration actuelle (from step-00)

**Produced by this step:**
- `{verification_result}` - PASS ou FAIL avec details
- `{final_report}` - Rapport de debugging (si succes)
- `{next_iteration}` - Infos pour iteration suivante (si echec)

## TASK

1. Executer la verification complete
2. Si succes: generer rapport final
3. Si echec: preparer nouvelle iteration ou escalader

---

## EXECUTION

### 1. Run Full Test Suite

```bash
{{TEST_CMD}}
```

**Criteres:**
- ✅ TOUS les tests passent
- ✅ Le test de regression passe
- ✅ Aucun test echoue

**Si tests echouent:**
```yaml
test_failure:
  failed_tests:
    - test: "test/widget_test.dart"
      error: "[message d'erreur]"
      type: "regression" | "new_failure" | "flaky"

  analysis: |
    [Analyse de pourquoi le test echoue]
    [Est-ce lie au fix ou autre chose ?]
```

### 2. Run Static Analysis

```bash
{{LINT_CMD}}nfos
```

**Criteres:**
- ✅ Zero erreurs
- ✅ Zero warnings
- ✅ Zero infos (avec --fatal-infos)

**Si warnings:**
```yaml
warnings:
  - file: "lib/services/user.dart"
    line: 42
    message: "[warning message]"
    action: "fix" | "acceptable"
```

### 3. Verify Original Symptom

Reproduire le scenario original:

```yaml
symptom_verification:
  original_symptom: "{symptom}"

  verification_method: |
    [Comment reproduire le scenario original]

  result: "RESOLVED" | "STILL_PRESENT" | "PARTIALLY_RESOLVED"

  evidence: |
    [Preuve que le symptome est resolu]
```

### 4. Check for Regressions

Verifier qu'aucun comportement existant n'a ete casse:

```yaml
regression_check:
  areas_tested:
    - area: "User authentication"
      status: "OK"
    - area: "API calls"
      status: "OK"

  unexpected_changes: []  # Doit etre vide
```

---

## DECISION TREE

```
Tests passent ?
├── OUI → Analyse propre ?
│         ├── OUI → Symptome resolu ?
│         │         ├── OUI → SUCCESS ✅
│         │         └── NON → LOOP (retour step-00)
│         └── NON → Fix warnings, re-verifier
└── NON → Regression ?
          ├── OUI → Rollback fix, LOOP
          └── NON (autre cause) → Fix separement, re-verifier
```

---

## IF VERIFICATION FAILS

### Iteration < 5: New Loop

```yaml
next_iteration:
  iteration_number: {iteration + 1}

  learnings:
    - "[Ce qu'on a appris de cette iteration]"
    - "[Ce qui a fonctionne]"
    - "[Ce qui n'a pas fonctionne]"

  new_direction: |
    [Comment on va aborder la prochaine iteration differemment]

  preserved_facts:
    - "[Faits toujours valides]"

  invalidated_facts:
    - "[Faits qui se sont averes faux]"
```

**Action:** Retourner a `steps/step-00-capture.md` avec `{iteration}` incremente.

### Iteration = 5: Escalation

```yaml
escalation_report:
  bug_id: "[identifiant]"
  symptom: "{symptom}"

  iterations:
    - iteration: 1
      hypothesis: "[hypothese 1]"
      result: "[resultat]"
      learning: "[apprentissage]"

    - iteration: 2
      hypothesis: "[hypothese 2]"
      result: "[resultat]"
      learning: "[apprentissage]"

    # ... jusqu'a 5

  knowledge_gained:
    - "[Ce qu'on sait maintenant]"
    - "[Zones explorees]"
    - "[Zones non explorees]"

  blockers:
    - "[Ce qui empeche la resolution]"

  recommended_actions:
    - "[Action 1 - ex: aide externe]"
    - "[Action 2 - ex: plus de contexte]"
```

**Action:** Presenter le rapport a l'utilisateur et demander la direction.

---

## IF VERIFICATION SUCCEEDS

### Generate Final Report

```yaml
debug_report:
  status: "RESOLVED"
  iterations: {iteration}

  symptom: "{symptom}"

  root_cause:
    description: "{hypothesis.statement}"
    location: "{hypothesis.location}"
    proof: "{hypothesis.proof_evidence}"

  solution:
    name: "{chosen_solution.name}"
    approach: "{chosen_solution.approach}"
    files_modified: ["{file1}", "{file2}"]

  verification:
    tests_passed: true
    analysis_clean: true
    symptom_resolved: true

  prevention:
    regression_test: "{regression_test.file}"
    recommendations:
      - "[Recommandation pour eviter bugs similaires]"
```

---

## AUTO-VALIDATION

**Before declaring success, validate:**
✅ Tous les tests passent
✅ Analyse statique propre (0 warnings)
✅ Symptome original resolu
✅ Aucune regression detectee
✅ Rapport de debug genere

**Self-Critique Questions:**
- Le bug est-il vraiment resolu ou juste cache ?
- Y a-t-il des cas limites non testes ?
- Le fix pourrait-il causer des problemes dans d'autres scenarios ?
- La cause racine est-elle vraiment corrigee ?

---

## SUCCESS / FAILURE

**Success:**
✅ Bug resolu definitivement
✅ Test de regression en place
✅ Zero regression
✅ Documentation complete

**Failure modes:**
❌ Tests echouent → Analyser, LOOP ou escalader
❌ Symptome persiste → LOOP avec nouvelle hypothese
❌ 5 iterations atteintes → Escalader avec rapport complet

## OUTPUT FORMAT

### Success Output

```
╔═══════════════════════════════════════════════════════════════╗
║                    BUG RESOLVED ✅                             ║
╠═══════════════════════════════════════════════════════════════╣
║ SYMPTOME: {symptom}                                            ║
║ ITERATIONS: {iteration}/5                                      ║
╠═══════════════════════════════════════════════════════════════╣
║ CAUSE RACINE:                                                  ║
║ {root_cause}                                                   ║
╠═══════════════════════════════════════════════════════════════╣
║ SOLUTION:                                                      ║
║ {solution_name}                                                ║
║ Fichiers: {files_modified}                                     ║
╠═══════════════════════════════════════════════════════════════╣
║ VERIFICATION:                                                  ║
║ Tests: PASS ✅                                                 ║
║ Analyse: CLEAN ✅                                              ║
║ Regression: NONE ✅                                            ║
╠═══════════════════════════════════════════════════════════════╣
║ PREVENTION:                                                    ║
║ Test: {regression_test_file}                                   ║
╚═══════════════════════════════════════════════════════════════╝
```

### Loop Output

```
╔═══════════════════════════════════════════════════════════════╗
║                    NEW ITERATION NEEDED                        ║
╠═══════════════════════════════════════════════════════════════╣
║ ITERATION: {current} → {next}                                  ║
║ RAISON: {failure_reason}                                       ║
╠═══════════════════════════════════════════════════════════════╣
║ APPRENTISSAGES:                                                ║
║ • {learning_1}                                                 ║
║ • {learning_2}                                                 ║
╠═══════════════════════════════════════════════════════════════╣
║ NOUVELLE DIRECTION:                                            ║
║ {new_direction}                                                ║
╚═══════════════════════════════════════════════════════════════╝

Returning to step-00-capture.md with new knowledge...
```

### Escalation Output

```
╔═══════════════════════════════════════════════════════════════╗
║                    ESCALATION REQUIRED                         ║
╠═══════════════════════════════════════════════════════════════╣
║ 5 ITERATIONS COMPLETED WITHOUT RESOLUTION                      ║
╠═══════════════════════════════════════════════════════════════╣
║ HYPOTHESES TESTEES:                                            ║
║ 1. {hyp1} - {result1}                                          ║
║ 2. {hyp2} - {result2}                                          ║
║ ...                                                            ║
╠═══════════════════════════════════════════════════════════════╣
║ BLOCKERS:                                                      ║
║ • {blocker_1}                                                  ║
║ • {blocker_2}                                                  ║
╠═══════════════════════════════════════════════════════════════╣
║ ACTIONS RECOMMANDEES:                                          ║
║ • {action_1}                                                   ║
║ • {action_2}                                                   ║
╚═══════════════════════════════════════════════════════════════╝

Waiting for user guidance...
```

## NEXT

- **If SUCCESS:** Workflow complete. Consider using `/commit` to commit the fix.
- **If LOOP:** Return to `steps/step-00-capture.md` with incremented iteration.
- **If ESCALATE:** Present report and wait for user direction.

<critical>
Ne JAMAIS declarer victoire sans verification complete.
Un bug "resolu" qui revient est pire qu'un bug non resolu.
Chaque iteration DOIT apprendre quelque chose de nouveau.
</critical>
