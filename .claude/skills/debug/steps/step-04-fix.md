---
name: step-04-fix
description: "Appliquer la correction chirurgicalement et nettoyer"
prev_step: steps/step-03-strategize.md
next_step: steps/step-05-verify.md
---

# Step 04: FIX (The Surgeon)

## MANDATORY RULES (READ FIRST)

- 🚫 **INTERDIT**: Modifier plus que necessaire (pas de refactoring opportuniste)
- 🚫 **INTERDIT**: Laisser des logs de debug (`// DEBUG - A RETIRER`)
- 🚫 **INTERDIT**: Appliquer une solution differente de celle choisie
- ✅ **OBLIGATOIRE**: Ecrire un test qui reproduit le bug AVANT de fixer
- ✅ **OBLIGATOIRE**: Suivre strictement le plan de la solution choisie
- ✅ **OBLIGATOIRE**: Nettoyer TOUTE l'instrumentation de debug

## PROTOCOLS

- 🎯 **Goal**: Appliquer la correction de maniere chirurgicale
- 💾 **Output**: Code corrige + test de regression + cleanup
- ⚡ **Performance**: Precision > Vitesse - une correction propre evite les regressions

## CONTEXT

**Available from previous steps:**
- `{symptom}` - Description du bug (from step-00)
- `{hypothesis}` - Cause racine prouvee (from step-02)
- `{chosen_solution}` - Solution selectionnee (from step-03)
- `{instrumentation}` - Logs de debug a nettoyer (from step-01)

**Produced by this step:**
- `{fix_applied}` - Description des modifications
- `{regression_test}` - Test ecrit pour prevenir regression
- `{cleanup_done}` - Confirmation que debug est nettoye

## TASK

1. Ecrire un test reproduisant le bug
2. Appliquer la correction selon le plan
3. Nettoyer les logs de debug
4. Verifier que le test passe maintenant

---

## EXECUTION

### 1. Write Regression Test FIRST

**AVANT** de modifier le code, ecrire un test qui reproduit le bug:

```dart
// test/regression/bug_xyz_test.dart
test('should not have undefined userId when calling API', () {
  // GIVEN: [setup qui reproduit les conditions du bug]

  // WHEN: [action qui declenche le bug]

  // THEN: [assertion qui echoue avec le bug present]
});
```

**Executer le test:**

```bash
{{TEST_CMD}} test/regression/bug_xyz_test.dart
```

**Le test DOIT echouer** - sinon:
- Le bug n'est pas correctement reproduit
- Ou le bug a deja ete corrige ailleurs
- Ou le test ne teste pas la bonne chose

### 2. Apply Fix

Suivre **STRICTEMENT** le plan de `{chosen_solution}`:

```yaml
fix_checklist:
  - file: "{file1}"
    changes:
      - line: {ligne}
        before: "{code avant}"
        after: "{code apres}"
    applied: ✓

  - file: "{file2}"
    changes:
      - line: {ligne}
        before: "{code avant}"
        after: "{code apres}"
    applied: ✓
```

**Regles:**
- Modifier UNIQUEMENT les fichiers listes dans la solution
- Ne PAS ajouter de fonctionnalites
- Ne PAS refactorer "tant qu'on y est"
- Chaque modification doit etre traceable a la solution

### 3. Verify Test Now Passes

Executer le test de regression:

```bash
{{TEST_CMD}} test/regression/bug_xyz_test.dart
```

**Le test DOIT passer** - sinon:
- Le fix n'est pas correct
- Reviser la solution
- Ou l'hypothese etait fausse (retour step-01)

### 4. Cleanup Instrumentation

**CRITIQUE: Nettoyer TOUS les logs de debug**

Chercher tous les marqueurs:

```bash
grep -rn "DEBUG - A RETIRER" lib/ test/
```

Pour chaque occurrence:
1. Verifier que c'est bien un log temporaire
2. Supprimer la ligne complete
3. Confirmer que ca n'affecte pas le code

**Checklist cleanup:**

```yaml
cleanup:
  files_cleaned:
    - path: "lib/services/user_service.dart"
      lines_removed: [42, 67]

    - path: "lib/widgets/user_widget.dart"
      lines_removed: [15]

  total_debug_lines_removed: 3
  remaining_debug_markers: 0  # DOIT etre 0
```

---

## FIX DOCUMENTATION

Documenter le fix pour reference:

```yaml
fix_applied:
  solution_used: "S{n} - {name}"

  changes:
    - file: "lib/services/user_service.dart"
      description: "Ajoute await pour attendre le chargement du user"
      lines_modified: [42-45]

  regression_test:
    file: "test/regression/bug_xyz_test.dart"
    description: "Verifie que userId est present avant l'appel API"

  cleanup:
    debug_lines_removed: 3
    files_cleaned: 2
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ Test de regression ecrit et echoue avant fix
✅ Fix applique selon le plan de la solution
✅ Test de regression passe apres fix
✅ Aucun marqueur `// DEBUG - A RETIRER` restant
✅ Aucune modification hors scope

**Self-Critique Questions:**
- Le fix resout-il vraiment la CAUSE RACINE ?
- Ai-je modifie quelque chose qui n'etait pas dans le plan ?
- Le test de regression est-il robuste ?
- Ai-je nettoye TOUS les logs de debug ?

**If validation fails:**
1. Si test ne passe pas → Reviser le fix ou l'hypothese
2. Si debug restant → Chercher et nettoyer
3. Si modification hors scope → Rollback les extras

---

## SUCCESS / FAILURE

**Success:**
✅ Test de regression ecrit et passe
✅ Fix applique proprement
✅ Zero log de debug restant
✅ Code pret pour verification complete

**Failure modes:**
❌ Test de regression ne passe pas → Reviser fix ou retour step-02
❌ Logs debug restants → Nettoyer avant de continuer
❌ Regression introduite → Rollback et nouvelle approche

## OUTPUT FORMAT

```
╔═══════════════════════════════════════════════════════════════╗
║                    FIX APPLIED                                 ║
╠═══════════════════════════════════════════════════════════════╣
║ SOLUTION: {solution_name}                                      ║
╠═══════════════════════════════════════════════════════════════╣
║ MODIFICATIONS:                                                 ║
║ • {file1}:{lines} - {description}                              ║
║ • {file2}:{lines} - {description}                              ║
╠═══════════════════════════════════════════════════════════════╣
║ TEST DE REGRESSION:                                            ║
║ {test_file} - {status: PASS}                                   ║
╠═══════════════════════════════════════════════════════════════╣
║ CLEANUP:                                                       ║
║ {n} debug lines removed from {m} files                         ║
║ Remaining debug markers: 0 ✓                                   ║
╚═══════════════════════════════════════════════════════════════╝
```

## NEXT

After validation passes, load `steps/step-05-verify.md`

<critical>
Le fix doit etre CHIRURGICAL - pas une seule ligne de plus que necessaire.
TOUJOURS ecrire le test AVANT le fix pour prouver que le fix fonctionne.
JAMAIS laisser de logs de debug - c'est de la dette technique immediate.
</critical>
