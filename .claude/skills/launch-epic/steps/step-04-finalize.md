# Step 04: Finalisation Epic

> Purpose: Générer le rapport final, mettre à jour la documentation, et demander validation de l'Epic.

---

## MANDATORY RULES (READ FIRST)

- 📊 **RAPPORT COMPLET** : Résumer toutes les stories et leur status
- 📝 **TRACKING.MD** : Mise à jour finale
- ✅ **VALIDATION USER** : Toujours demander confirmation avant de clôturer
- 🎉 **CÉLÉBRATION** : L'Epic est terminée!

## PROTOCOLS

- 🎯 **Goal**: Clôturer l'Epic proprement avec documentation complète
- 💾 **Output**: Rapport final et Epic marquée comme Done
- ⚡ **Performance**: Résumé clair pour l'utilisateur

---

## CONTEXT

**Available from previous steps:**
- `{epic_id}` - ID de l'Epic
- `{mode}` - Mode utilisé (supervised/autonomous)
- `{completed_stories}` - Stories terminées avec succès
- `{failed_stories}` - Stories en échec (si applicable)
- `{execution_log}` - Log détaillé de l'exécution

**Produced by this step:**
- `{final_report}` - Rapport final de l'Epic
- `{epic_status}` - Status final (COMPLETE/PARTIAL)

---

## EXECUTION

### 1. Collecter les Métriques

```yaml
metrics_collection:
  stories:
    total: {count from {stories}}
    completed: {count from {completed_stories}}
    failed: {count from {failed_stories}}
    skipped: {total - completed - failed}

  tests:
    total: {sum of all test counts}
    passing: {sum of passing tests}

  code:
    files_created: {count}
    files_modified: {count}
    lines_added: {estimate or count}

  execution:
    mode: {supervised/autonomous}
    total_attempts: {sum of all attempts}
    self_healing_triggered: {count of retries}
```

---

### 2. Générer le Rapport Final

```yaml
final_report:
  format: |
    # 📋 Rapport Final - {epic_id}

    **Date:** {date}
    **Mode:** {mode}
    **Status:** {COMPLETE/PARTIAL}

    ---

    ## 📊 Résumé

    | Métrique | Valeur |
    |----------|--------|
    | Stories complétées | {X}/{Y} |
    | Tests passants | {X}/{Y} |
    | Fichiers modifiés | {X} |
    | Tentatives totales | {X} |

    ---

    ## ✅ Stories Complétées

    | Story | Titre | Tentatives | Notes |
    |-------|-------|------------|-------|
    | STORY-XX-01 | ... | 1 | APPROVE |
    | STORY-XX-02 | ... | 2 | APPROVE après fix |

    ---

    ## ❌ Stories Non Complétées (si applicable)

    | Story | Titre | Raison | Action Requise |
    |-------|-------|--------|----------------|
    | STORY-XX-05 | ... | Blocage technique | Review manuelle |

    ---

    ## 📁 Fichiers Modifiés

    ### Créés
    - lib/features/xxx/xxx.dart
    - test/xxx_test.dart

    ### Modifiés
    - lib/core/xxx.dart
    - lib/shared/xxx.dart

    ---

    ## 🔍 Observations

    - {observation 1}
    - {observation 2}
    - {leçons apprises}

    ---

    ## ✅ Validation Technique

    - **Tests:** Tous passants ✅
    - **Analyze:** 0 warnings ✅
    - **Review:** Toutes stories APPROVE ✅
```

---

### 3. Mettre à Jour TRACKING.md

```yaml
tracking_update:
  action: Edit docs/epics/{epic_id}/TRACKING.md

  content_to_add: |
    ---

    ## 🎉 Epic Complétée

    **Date de completion:** {date}
    **Mode d'exécution:** {mode}

    ### Résumé Final

    - Stories: {X}/{Y} complétées
    - Durée totale: {estimate}
    - Observations: {notes}

    ### Status Final: DONE ✅
```

---

### 4. Mettre à Jour l'Epic.md

```yaml
epic_update:
  action: Edit docs/epics/{epic_id}/{epic_id}.md

  change:
    old: "Status: En cours" (ou équivalent)
    new: "Status: ✅ Done ({date})"
```

---

### 5. Demander Validation Utilisateur

```yaml
validation_request:
  # Mode Supervised
  if mode == "supervised":
    present: |
      ## 🎉 Epic {epic_id} Complétée!

      {rapport_final condensé}

      Toutes les stories ont été implémentées et validées.

    AskUserQuestion:
      question: "Valider la clôture de l'Epic?"
      header: "Finalize"
      options:
        - label: "Oui, clôturer"
          description: "Marquer l'Epic comme Done"
        - label: "Non, il reste du travail"
          description: "Revenir sur certaines stories"
        - label: "Voir le détail"
          description: "Afficher le rapport complet"

  # Mode Autonomous
  if mode == "autonomous":
    present: |
      ## 🎉 Epic {epic_id} Complétée!

      **Résumé:**
      - Stories: {X}/{Y} complétées
      - Tests: Tous passants
      - Analyze: 0 warnings
      - Reviews: Toutes APPROVE

      {Si stories échouées: détail}

    AskUserQuestion:
      question: "Valider l'Epic {epic_id}?"
      header: "Validate"
      options:
        - label: "Valider"
          description: "L'Epic est complète et prête"
        - label: "Voir le rapport complet"
          description: "Afficher tous les détails"
        - label: "Il y a des problèmes"
          description: "Discuter des issues"
```

---

### 6. Gestion des Cas Partiels

Si certaines stories n'ont pas été complétées:

```yaml
partial_completion:
  if failed_stories.count > 0:
    status: "PARTIAL"

    report_addition: |
      ## ⚠️ Completion Partielle

      {X} stories n'ont pas pu être complétées:

      | Story | Raison | Recommandation |
      |-------|--------|----------------|
      | ... | ... | ... |

      **Options:**
      1. Continuer en mode supervised pour les stories restantes
      2. Créer des tickets pour traitement ultérieur
      3. Accepter l'état actuel et clôturer

    AskUserQuestion:
      question: "Comment traiter les stories non complétées?"
      header: "Partial"
      options:
        - label: "Continuer en supervised"
          description: "Reprendre les stories échouées interactivement"
        - label: "Clôturer quand même"
          description: "Accepter l'état partiel, documenter le reste"
        - label: "Créer des tickets"
          description: "Transformer en nouvelles stories pour plus tard"
```

---

### 7. Actions Post-Validation

```yaml
post_validation:
  if user_validates:
    1. Mettre à jour TRACKING.md avec status final
    2. Mettre à jour Epic.md avec status Done
    3. Afficher message de succès

    success_message: |
      ## ✅ Epic {epic_id} Clôturée

      Toutes les modifications ont été commitées.
      L'Epic est maintenant marquée comme Done.

      **Prochaines étapes suggérées:**
      - Review globale du code
      - Test sur device réel
      - Merge vers main si applicable

  if user_declines:
    1. Proposer de revenir sur les stories problématiques
    2. Ou reprendre en mode supervised
    3. Sauvegarder l'état actuel pour reprise ultérieure
```

---

## AUTO-VALIDATION

**Before finalizing:**
✅ Toutes les stories terminées ont été documentées
✅ TRACKING.md mis à jour
✅ Rapport final généré
✅ Utilisateur a validé (ou a été informé en autonomous)
✅ Métriques collectées

**Self-Critique Questions:**
- Le rapport est-il clair et complet?
- Toutes les observations importantes sont-elles documentées?
- L'utilisateur a-t-il toutes les informations pour décider?

---

## SUCCESS / FAILURE

**Success:**
✅ Epic marquée comme DONE
✅ Documentation complète
✅ Utilisateur satisfait

**Failure modes:**
❌ Utilisateur refuse validation → Proposer alternatives
❌ Documentation incomplète → Compléter avant clôture
❌ Problèmes non résolus → Documenter clairement

---

## OUTPUT FINAL

```yaml
epic_completion:
  epic_id: "{epic_id}"
  status: "COMPLETE" | "PARTIAL"
  completion_date: "{date}"
  mode: "{supervised/autonomous}"

  stories:
    completed: [list]
    failed: [list]

  metrics:
    tests_passing: X
    files_modified: X
    total_attempts: X

  documentation:
    tracking_updated: true
    epic_updated: true
    report_generated: true

  user_validation: "APPROVED" | "DECLINED" | "PARTIAL"
```

<critical>
TOUJOURS demander validation utilisateur avant de marquer l'Epic comme Done.
DOCUMENTER même les échecs - c'est de l'information précieuse.
CÉLÉBRER le succès - un Epic terminé est une vraie accomplissement!
</critical>
