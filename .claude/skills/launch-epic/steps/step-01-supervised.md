# Step 01: Mode Supervised (Interactif)

> Purpose: Exécuter l'Epic en mode collaboratif avec validation utilisateur à chaque étape.

---

## MANDATORY RULES (READ FIRST)

- 🙋 **DIALOGUE CONSTANT** : Utiliser AskUserQuestion fréquemment
- ✅ **VALIDATION USER** : Attendre confirmation avant chaque action majeure
- 🔀 **FLEXIBILITÉ** : S'adapter aux choix de l'utilisateur
- 📝 **MONTRER AVANT FAIRE** : Présenter le plan/code avant de l'appliquer

## PROTOCOLS

- 🎯 **Goal**: Implémenter stories de façon collaborative et agile
- 💾 **Output**: Stories implémentées avec validation utilisateur
- 📖 **Reference**: Story Workflow 8 étapes (SYSTEM.md)
- ⚡ **Performance**: L'utilisateur garde le contrôle total

---

## CONTEXT

**Available from step-00:**
- `{epic_id}` - ID de l'Epic
- `{mode}` = "supervised"
- `{stories}` - Liste des stories à implémenter
- `{epic_content}` - Contenu de l'Epic

**Produced by this step:**
- `{completed_stories}` - Stories terminées avec succès
- `{current_story}` - Story en cours

---

## EXECUTION

### 1. Configuration Initiale

Au début de la session, demander à l'utilisateur comment il veut travailler:

```yaml
AskUserQuestion:
  question: "Comment veux-tu travailler sur {epic_id}?"
  header: "Workflow"
  options:
    - label: "Story par story avec validation"
      description: "Je présente chaque story, tu valides avant que j'implémente"
    - label: "Guide-moi"
      description: "Tu donnes les instructions, je les exécute"
    - label: "Je propose, tu valides"
      description: "Je propose actions et code, tu approuves avant application"
  multiSelect: false
```

**Enregistrer le choix dans `{work_style}`.**

---

### 2. Présenter les Stories

Montrer la liste des stories à implémenter:

```yaml
story_presentation:
  format: |
    ## Stories de {epic_id}

    | # | ID | Titre | Status | Points |
    |---|-----|-------|--------|--------|
    | 1 | STORY-XX-01 | ... | À faire | X |
    | 2 | STORY-XX-02 | ... | En cours | X |

    Total: {N} stories à implémenter
```

```yaml
AskUserQuestion:
  question: "Par quelle story veux-tu commencer?"
  header: "Story"
  options:
    - label: "STORY-XX-01: {titre}"
      description: "Première story (recommandé)"
    - label: "STORY-XX-02: {titre}"
      description: "Deuxième story"
    - label: "Je choisis une autre"
      description: "Spécifier manuellement"
  multiSelect: false
```

---

### 3. Pour Chaque Story

#### 3.1 Lecture et Présentation

```yaml
story_steps:
  1_read:
    action: "Read docs/epics/{epic_id}/stories/{story_id}.md"
    extract:
      - User Story (En tant que... Je veux... Afin de...)
      - Critères d'acceptation (Gherkin)
      - Fichiers à modifier
      - Definition of Done

  2_present:
    format: |
      ## {story_id}: {titre}

      **User Story:**
      En tant que {persona}, je veux {action}, afin de {bénéfice}.

      **Critères d'acceptation:**
      - AC-1: {description}
      - AC-2: {description}

      **Fichiers concernés:**
      - CREATE: {fichiers à créer}
      - MODIFY: {fichiers à modifier}
```

#### 3.2 Demander Approche

```yaml
AskUserQuestion:
  question: "Comment veux-tu procéder pour {story_id}?"
  header: "Approche"
  options:
    - label: "Je développe avec toi"
      description: "Travail collaboratif, validation à chaque étape"
    - label: "Montre-moi le plan d'abord"
      description: "Je prépare un plan détaillé avant de commencer"
    - label: "Lance un subagent"
      description: "Le story-executor implémente, je review ensuite"
  multiSelect: false
```

---

### 4. Si "Je développe avec toi"

#### 4.1 TDD avec Validation

Pour chaque critère d'acceptation:

**RED Phase:**
```yaml
present_test:
  format: |
    ## Test pour AC-{N}: {description}

    ```dart
    test('should {comportement attendu}', () {
      // Arrange
      ...
      // Act
      ...
      // Assert
      expect(...);
    });
    ```

    Ce test va échouer car le code n'existe pas encore.

AskUserQuestion:
  question: "Ce test est-il correct?"
  header: "Validate"
  options:
    - label: "Oui, écris-le"
    - label: "Non, ajuste..."
```

**GREEN Phase:**
```yaml
present_implementation:
  format: |
    ## Implémentation pour faire passer le test

    ```dart
    // Code minimal qui fait passer le test
    ...
    ```

AskUserQuestion:
  question: "Cette implémentation est-elle correcte?"
  header: "Validate"
  options:
    - label: "Oui, écris-la"
    - label: "Non, ajuste..."
```

**REFACTOR Phase:**
```yaml
present_refactor:
  format: |
    ## Refactoring suggéré

    Changements proposés:
    - {amélioration 1}
    - {amélioration 2}

AskUserQuestion:
  question: "Dois-je appliquer ce refactoring?"
  header: "Refactor"
  options:
    - label: "Oui"
    - label: "Non, passe au suivant"
    - label: "Autre suggestion..."
```

#### 4.2 Validation Technique

Après tous les critères:

```bash
{{TEST_CMD}}
{{LINT_CMD}}
```

Présenter résultats:

```yaml
validation_report:
  format: |
    ## Validation Technique

    **Tests:** {X} passants / {Y} total
    **Analyze:** {Z} warnings

    {Si warnings ou échecs: détailler}
```

---

### 5. Si "Lance un subagent"

```yaml
subagent_launch:
  confirm: |
    Je vais lancer le story-executor pour implémenter {story_id}.

    Il va:
    1. Lire la story
    2. Implémenter en TDD strict
    3. Faire sa propre self-critique
    4. Retourner un résumé

    Tu pourras review le résultat ensuite.

AskUserQuestion:
  question: "Confirmer le lancement du subagent?"
  header: "Confirm"
  options:
    - label: "Oui, lance"
    - label: "Non, je préfère développer ensemble"
```

Si confirmé:
```yaml
Task:
  subagent_type: "story-executor"
  description: "Implémenter {story_id}"
  prompt: |
    Implémenter la story suivante en TDD strict:

    Story path: docs/epics/{epic_id}/stories/{story_id}.md

    Suivre le workflow:
    ANALYZE → PLAN → EXECUTE (TDD) → VALIDATE → EXAMINE → RESOLVE → TEST LOOP → OUTPUT

    Retourner un résumé structuré à la fin.
```

---

### 6. Review Interactive

Après implémentation (manuelle ou subagent):

```yaml
review_presentation:
  format: |
    ## Review de {story_id}

    **Critères satisfaits:** {X}/{Y}
    **Tests:** {passants/total}
    **Analyze:** {warnings}

    **Fichiers modifiés:**
    - {fichier1} (CREATE/MODIFY)
    - {fichier2} (CREATE/MODIFY)

    **Points d'attention:**
    - {observation 1}
    - {observation 2}

AskUserQuestion:
  question: "Que veux-tu faire?"
  header: "Review"
  options:
    - label: "Valider et continuer"
      description: "Story OK, passer à la suivante"
    - label: "Voir le code en détail"
      description: "Je te montre les fichiers modifiés"
    - label: "Corrections nécessaires"
      description: "Il y a des problèmes à corriger"
```

---

### 7. Passage à la Story Suivante

```yaml
next_story:
  update_tracking: |
    Mettre à jour TRACKING.md:
    - [x] {story_id} - {titre} (terminée {date})
      - Mode: supervised
      - Review: APPROVE

AskUserQuestion:
  question: "{completed}/{total} stories terminées. Continuer?"
  header: "Continue"
  options:
    - label: "Oui, story suivante"
    - label: "Non, pause pour aujourd'hui"
    - label: "Changer d'approche"
```

---

### 8. Flexibilité Utilisateur

L'utilisateur peut à TOUT MOMENT:

- **Changer d'approche** → Re-poser la question d'approche
- **Prendre le contrôle** → Donner des instructions directes
- **Modifier le scope** → Skip une story, réordonner
- **Demander explications** → Clarifier le code ou les décisions

**Toujours s'adapter à ce qu'il veut.**

---

## AUTO-VALIDATION

**Before proceeding to next story:**
✅ Tous les critères d'acceptation validés
✅ Tests passent ({{TEST_CMD}})
✅ Analyze clean ({{LINT_CMD}}
✅ Utilisateur a validé
✅ TRACKING.md mis à jour

**Self-Critique Questions:**
- Ai-je bien attendu la validation avant chaque action?
- L'utilisateur a-t-il eu toutes les informations nécessaires?
- Ai-je respecté ses choix même s'ils diffèrent de mes suggestions?

---

## SUCCESS / FAILURE

**Success:**
✅ Story implémentée avec validation utilisateur
✅ Tests passent
✅ Code clean
✅ Prêt pour la story suivante ou finalisation

**Failure modes:**
❌ Tests échouent → Proposer corrections, demander guidance
❌ Utilisateur refuse → Demander ce qu'il préfère
❌ Blocage technique → Expliquer le problème, proposer alternatives

---

## NEXT

- Si stories restantes → Continuer avec story suivante
- Si toutes stories terminées → Charger `steps/step-04-finalize.md`

<critical>
MODE SUPERVISED = INTERACTIF
Ne JAMAIS faire d'action majeure sans validation utilisateur.
Toujours MONTRER avant de FAIRE.
S'ADAPTER aux choix de l'utilisateur, même s'ils diffèrent de tes recommandations.
</critical>
