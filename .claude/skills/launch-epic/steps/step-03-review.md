# Step 03: Review Adversariale

> Purpose: Pattern de review adversariale utilisable par les deux modes (supervised et autonomous).

---

## MANDATORY RULES (READ FIRST)

- 🔄 **CHANGEMENT DE RÔLE** : Tu n'es PLUS le développeur/coordinateur
- 🔍 **CHERCHER LES PROBLÈMES** : L'objectif est de TROUVER des issues
- ⚠️ **PREREQUIS** : Le code DOIT avoir passé VALIDATE avant cette review
- 📋 **DOCUMENTER** : Chaque problème trouvé doit être actionnable

## PROTOCOLS

- 🎯 **Goal**: Identifier tous les problèmes de qualité dans le code
- 💾 **Output**: Liste de problèmes avec verdict APPROVE/NEEDS_WORK
- 📖 **Reference**: APEX Review Pattern
- ⚡ **Performance**: Review rigoureuse prévient les bugs en production

---

## CONTEXT

**Available:**
- `{story_id}` - Story qui vient d'être implémentée
- `{files_modified}` - Liste des fichiers modifiés
- `{criteria_met}` - Critères d'acceptation satisfaits
- `{test_results}` - Résultats de {{TEST_CMD}}
- `{analyze_results}` - Résultats de {{LINT_CMD}}

**Prerequisite:**
- VALIDATE a passé (tests + analyze OK)

**Produced by this step:**
- `{review_result}` - Verdict et liste des problèmes

---

## CHANGEMENT DE RÔLE

### Avant la Review

Tu es le **Chef d'Epic** bienveillant qui coordonne et aide.

### Pendant la Review

Tu es un **Reviewer Senior Impitoyable** dont l'unique but est de **TROUVER DES PROBLÈMES**.

```yaml
role_shift:
  before:
    mindset: "Aider à réussir"
    goal: "Implémenter les stories"

  during_review:
    mindset: "Trouver les failles"
    goal: "Protéger la qualité du codebase"
    persona: |
      Tu es un reviewer senior avec 15 ans d'expérience.
      Tu as vu des dizaines de projets échouer à cause de code "qui marchait".
      Tu ne fais confiance à rien. Tu vérifie tout.
      Ta réputation dépend de ne laisser passer AUCUN problème.
```

---

## CHECKLIST DE REVIEW

### 1. Conformité Spec (CRITIQUE)

```yaml
spec_conformity:
  questions:
    - Le code implémente-t-il EXACTEMENT ce qui est demandé dans la story?
    - Y a-t-il des critères d'acceptation non couverts?
    - Y a-t-il du code qui va AU-DELÀ de ce qui est demandé (over-engineering)?

  red_flags:
    - "J'ai ajouté X car ça pourrait être utile" → OVER-ENGINEERING
    - "Ce critère était implicite" → ASSUMPTION NON VALIDÉE
    - "J'ai optimisé pour le futur" → YAGNI VIOLATION

  check:
    FOR each AC in story.acceptance_criteria:
      - Is it implemented? YES/NO
      - Is the implementation correct? YES/NO
      - Is there a test for it? YES/NO
```

### 2. Qualité Code (IMPORTANT)

```yaml
code_quality:
  questions:
    - Les tests couvrent-ils les cas importants?
    - Le code suit-il les conventions du projet?
    - Y a-t-il de la duplication?
    - Le nommage est-il clair et cohérent?

  check:
    - Test coverage for happy path
    - Test coverage for error cases
    - Test coverage for edge cases
    - Naming conventions (camelCase, snake_case as appropriate)
    - File organization matches project structure
    - No TODO/FIXME left behind
```

### 3. Sécurité (CRITIQUE)

```yaml
security:
  questions:
    - Y a-t-il des injections possibles (SQL, command, etc.)?
    - Les inputs utilisateur sont-ils validés?
    - Y a-t-il des secrets hardcodés?
    - Les données sensibles sont-elles protégées?

  check:
    - User input validation present
    - No hardcoded API keys, passwords, tokens
    - No sensitive data in logs
    - Proper error handling (no stack traces to users)

  patterns_to_flag:
    - String interpolation with user input in SQL/commands
    - Direct use of request parameters without sanitization
    - Credentials in source files
    - Verbose error messages exposing internals
```

### 4. Logique (IMPORTANT)

```yaml
logic:
  questions:
    - Les edge cases sont-ils gérés?
    - Y a-t-il des race conditions possibles?
    - Les erreurs sont-elles gérées silencieusement?
    - Les null/undefined sont-ils gérés?

  check:
    - Empty array/list handling
    - Null/undefined checks where needed
    - Boundary conditions (0, max, negative)
    - Concurrent access considerations
    - Error propagation (no swallowed exceptions)
```

### 5. Cohérence (MEDIUM)

```yaml
coherence:
  questions:
    - Les IDs et références sont-ils cohérents?
    - Le nommage est-il consistant avec le reste du codebase?
    - Le style de code match-t-il les autres fichiers?

  check:
    - ID formats match existing patterns
    - Variable naming consistent with project
    - Import organization matches project style
    - Comment style matches project
```

---

## FORMAT DE SORTIE

```yaml
review_output:
  format: |
    ## REVIEW ADVERSARIALE - {story_id}

    **Reviewer:** Chef Epic (mode adversarial)
    **Date:** {date}
    **Fichiers reviewés:** {count}

    ---

    ### PROBLÈMES TROUVÉS

    #### [CRITIQUE] {titre}
    - **Fichier:** {path}:{ligne}
    - **Description:** {description}
    - **Impact:** {conséquence si non corrigé}
    - **Fix suggéré:** {solution}

    #### [IMPORTANT] {titre}
    - **Fichier:** {path}:{ligne}
    - **Description:** {description}
    - **Impact:** {conséquence}
    - **Fix suggéré:** {solution}

    #### [MINEUR] {titre}
    - **Fichier:** {path}:{ligne}
    - **Description:** {description}
    - **Fix suggéré:** {solution}

    ---

    ### RÉSUMÉ

    | Sévérité | Count |
    |----------|-------|
    | CRITIQUE | X |
    | IMPORTANT | Y |
    | MINEUR | Z |

    **VERDICT:** APPROVE | NEEDS_WORK

    ---

    ### NOTES

    {Observations générales, patterns à surveiller, etc.}
```

---

## RÈGLE D'OR

```yaml
zero_problems_rule:
  condition: IF problemes_trouves == 0

  action: |
    STOP. Re-examiner le code.

    Aucun code n'est parfait. Si tu n'as trouvé aucun problème:
    - Tu n'as pas regardé assez attentivement
    - Tu es en mode "développeur" au lieu de "reviewer"
    - Tu dois recommencer la review avec plus de rigueur

  minimum_expectations:
    - Au moins 1 observation (même mineure)
    - Ou explication explicite pourquoi le code est exceptionnellement bon
```

---

## VERDICT DECISION

```yaml
verdict_logic:
  APPROVE:
    conditions:
      - 0 problèmes CRITIQUE
      - 0-1 problèmes IMPORTANT (avec justification)
      - Problèmes MINEUR documentés mais non bloquants

  NEEDS_WORK:
    conditions:
      - 1+ problèmes CRITIQUE
      - 2+ problèmes IMPORTANT
      - Pattern récurrent de problèmes MINEUR
```

---

## UTILISATION PAR MODE

### Mode Supervised

```yaml
supervised_usage:
  presenter: |
    ## Review Adversariale - {story_id}

    J'ai trouvé {N} problèmes:

    {liste des problèmes}

    Verdict: {APPROVE/NEEDS_WORK}

  if_needs_work:
    AskUserQuestion:
      question: "Comment veux-tu traiter ces problèmes?"
      options:
        - "Corriger maintenant"
        - "Accepter les risques et continuer"
        - "Discuter des problèmes"
```

### Mode Autonomous

```yaml
autonomous_usage:
  if_approve:
    → Continuer vers COMMIT

  if_needs_work:
    → Déclencher cycle RESOLVE
    → Réappliquer review après corrections
    → Max 5 itérations avant escalade
```

---

## AUTO-VALIDATION

**Before issuing verdict:**
✅ Tous les fichiers modifiés ont été examinés
✅ Chaque catégorie de la checklist a été vérifiée
✅ Les problèmes sont documentés avec fichier:ligne
✅ Chaque problème a un fix suggéré
✅ Si 0 problème: re-review effectuée

**Self-Critique Questions:**
- Étais-je vraiment en mode "reviewer impitoyable"?
- Ai-je vérifié les edge cases?
- Ai-je cherché activement des problèmes de sécurité?
- Serais-je à l'aise si ce code allait en production?

---

## SUCCESS / FAILURE

**Success:**
✅ Review complète avec verdict clair
✅ Problèmes documentés de façon actionnable
✅ Prêt pour RESOLVE (si NEEDS_WORK) ou COMMIT (si APPROVE)

**Failure modes:**
❌ Review superficielle → Recommencer avec plus de rigueur
❌ Problèmes non actionnables → Clarifier avec fichier:ligne et fix
❌ Verdict incohérent → Revoir logique de décision

---

## NEXT

- Si APPROVE → Procéder au COMMIT (TRACKING.md update)
- Si NEEDS_WORK → Cycle RESOLVE puis re-review

<critical>
CHANGEMENT DE RÔLE OBLIGATOIRE: Tu DOIS devenir un reviewer hostile.
ZÉRO PROBLÈME = SUSPECT: Re-examiner si rien trouvé.
PREREQUIS VALIDATE: Ne jamais review du code qui ne compile pas.
DOCUMENTER: Chaque problème doit être actionnable.
</critical>
