# Référence: Workflows pour Subagents

> Guide pour utiliser les workflows réels dans les subagents Task du mode autonomous.

---

## Vue d'ensemble

Les subagents lancés via Task peuvent utiliser l'outil **Skill** pour invoquer les workflows du projet. Cela leur donne accès à des capacités avancées :

| Workflow | Skill Name | Arguments | Capacité |
|----------|------------|-----------|----------|
| `/dev-story` | `dev-story` | `{story_id} --auto` | TDD, Review, Commit |
| `/debug` | `debug` | `--auto {symptom}` | Investigation scientifique |
| `/oneshot` | `oneshot` | `--auto {description}` | Dev rapide APEX |
| `/exploration:explore` | `exploration:explore` | `{topic}` | Multi-agent exploration |
| Mode Plan | `EnterPlanMode` (tool) | - | Planification structurée |

---

## Pattern d'Invocation

### Dans le prompt du subagent

```yaml
Task:
  subagent_type: "general-purpose"
  model: opus
  prompt: |
    # Ta mission

    ...

    ## Workflows disponibles

    Tu peux utiliser ces workflows via l'outil Skill :

    **Pour implémenter avec TDD:**
    ```
    Skill: dev-story
    args: "STORY-01-01 --auto"
    ```

    **Pour débugger:**
    ```
    Skill: debug
    args: "--auto {description du bug}"
    ```

    **Pour explorer le contexte:**
    ```
    Skill: exploration:explore
    args: "{ce que tu cherches}"
    ```

    **Pour une tâche rapide:**
    ```
    Skill: oneshot
    args: "--auto {description}"
    ```

    **Pour planifier (si complexe):**
    Utilise l'outil `EnterPlanMode` directement
```

---

## Détails par Workflow

### /dev-story

**Quand l'utiliser:** Pour implémenter une story formelle avec acceptance criteria.

**Ce qu'il fait:**
1. Charge la story depuis `docs/epics/EPIC-XX/stories/STORY-XX-YY.md`
2. Lance 3 agents d'exploration en parallèle
3. Génère un plan TDD par critère
4. Exécute RED → GREEN → REFACTOR
5. Review adversariale
6. Commit automatique

**Output typique:**
```
Status: COMPLETE
Critères: 5/5 satisfaits
Tests: 12 passants
Warnings: 0
```

---

### /debug

**Quand l'utiliser:** Quand un bug est détecté pendant l'implémentation.

**Ce qu'il fait:**
1. Capture le symptôme et contexte
2. Collecte les FAITS (pas de suppositions)
3. Formule et PROUVE une hypothèse
4. Propose 3 solutions avec scoring
5. Applique la solution recommandée
6. Valide la résolution

**Output typique:**
```
Status: RESOLVED
Cause racine: Race condition dans le state manager
Solution: Ajout de mutex sur la méthode updateState()
Tests: PASS
```

---

### /oneshot

**Quand l'utiliser:** Pour des tâches rapides hors scope story mais nécessaires.

**Ce qu'il fait:**
1. Explore le contexte
2. Planifie l'implémentation
3. Exécute avec TDD
4. Review adversariale
5. Commit

**Output typique:**
```
Status: COMPLETE
Fichiers: lib/utils/helper.dart (CREATE)
Tests: 3 passants
```

---

### /exploration:explore

**Quand l'utiliser:** Pour comprendre le contexte avant d'agir.

**Ce qu'il fait:**
1. Lance des agents parallèles (codebase, docs, web)
2. Recherche patterns existants
3. Trouve fichiers pertinents
4. Synthétise les résultats

**Output typique:**
```
Key Files:
- lib/features/auth/data/repositories/auth_repository.dart:42
- lib/core/network/api_client.dart:128

Patterns:
- Repository pattern avec Either<Failure, Success>
- Dependency injection via get_it

Recommendations:
- Suivre le pattern existant dans auth_repository
```

---

### EnterPlanMode

**Quand l'utiliser:** Quand l'implémentation est complexe et nécessite une planification structurée.

**Ce qu'il fait:**
1. Permet d'explorer le codebase
2. Concevoir une approche
3. Valider le plan (en interne pour subagent)
4. Sortir avec un plan structuré

**Comment l'utiliser dans subagent:**
```
1. Appeler l'outil EnterPlanMode
2. Explorer et concevoir
3. Appeler ExitPlanMode avec le plan
4. Exécuter le plan
```

---

## Stratégie de Choix

```yaml
decision_matrix:
  situation: "Implémenter une story formelle"
  → workflow: /dev-story

  situation: "Bug détecté pendant implémentation"
  → workflow: /debug

  situation: "Besoin de contexte sur le codebase"
  → workflow: /exploration:explore

  situation: "Tâche rapide hors story"
  → workflow: /oneshot

  situation: "Implémentation complexe nécessitant planification"
  → tool: EnterPlanMode
```

---

## Self-Healing avec Workflows

Quand un subagent échoue, le Chef d'Epic choisit le workflow approprié :

```yaml
failure_type: "test_failure"
→ Analyser les tests, réessayer /dev-story avec erreurs spécifiques

failure_type: "bug_detected"
→ Lancer /debug pour résoudre, puis reprendre

failure_type: "context_missing"
→ Lancer /exploration:explore, enrichir le prompt

failure_type: "complexity"
→ Lancer avec EnterPlanMode, obtenir un plan structuré

failure_type: "repeated_same_failure"
→ Changer de stratégie complètement
```

---

## Bonnes Pratiques

1. **Model Opus par défaut** - Tous les subagents utilisent Opus sauf pour sync/doc (Sonnet)

2. **Un workflow à la fois** - Le subagent ne devrait pas chaîner trop de workflows

3. **Context suffisant** - Toujours fournir assez de contexte dans le prompt

4. **Output structuré** - Demander un format de sortie clair pour faciliter le parsing

5. **Escalade rapide** - Si un workflow échoue 2 fois, essayer un autre avant d'épuiser les 5 tentatives
