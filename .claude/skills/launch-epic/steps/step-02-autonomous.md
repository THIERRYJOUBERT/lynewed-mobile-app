# Step 02: Mode Autonomous v3 (Task-Based Orchestration)

> Purpose: Exécuter l'Epic automatiquement via orchestration Task avec subagents qui peuvent utiliser les workflows réels.

---

## MANDATORY RULES (READ FIRST)

- 🚀 **PAS D'INTERRUPTION** : L'utilisateur ne fait RIEN après le lancement
- 🔄 **TASK ORCHESTRATION** : Utiliser Task pour déléguer aux subagents
- 🛠️ **WORKFLOWS RÉELS** : Les subagents peuvent invoquer `/dev-story`, `/debug`, `/oneshot`, `/exploration:explore`
- 🎯 **MODEL OPUS** : Tous les agents sont Opus par défaut
- 📊 **DOCUMENTATION** : Tracker progression dans TRACKING.md

## PROTOCOLS

- 🎯 **Goal**: Implémenter toutes les stories automatiquement via Task agents
- 💾 **Output**: Epic complète ou rapport de blocage
- 📖 **Reference**: Task tool + Skill tool
- ⚡ **Performance**: Orchestration parallèle quand possible

---

## CONTEXT

**Available from step-00:**
- `{epic_id}` - ID de l'Epic
- `{mode}` = "autonomous"
- `{stories}` - Liste des stories à implémenter
- `{epic_content}` - Contenu de l'Epic

**Produced by this step:**
- `{completed_stories}` - Stories terminées avec succès
- `{failed_stories}` - Stories en échec après 5 tentatives
- `{execution_log}` - Log détaillé de l'exécution
- `{active_agents}` - Agents en cours

---

## NOUVEAUTÉ v3: Workflows Disponibles pour Subagents

Les subagents lancés via Task peuvent utiliser ces workflows réels :

| Workflow | Usage | Invocation dans subagent |
|----------|-------|--------------------------|
| `/dev-story {id} --auto` | Implémenter une story | `Skill: dev-story, args: "{story_id} --auto"` |
| `/debug --auto` | Résoudre un bug détecté | `Skill: debug, args: "--auto {symptom}"` |
| `/oneshot --auto` | Tâche rapide hors story | `Skill: oneshot, args: "--auto {description}"` |
| `/exploration:explore` | Comprendre le contexte | `Skill: exploration:explore, args: "{topic}"` |
| `EnterPlanMode` | Planifier avant d'agir | Tool direct dans le subagent |

---

## EXECUTION

### 1. Principe Fondamental

**L'utilisateur ne fait RIEN.** Tu travailles seul jusqu'à:
- Epic complète (succès)
- Blocage critique après 5 tentatives (escalade)
- Interruption manuelle par l'utilisateur

---

### 2. Stratégie de Délégation

#### 2.1 Pour chaque Story - Agent avec /dev-story

```yaml
Task:
  subagent_type: "general-purpose"
  model: opus
  description: "Implémenter {story_id}"
  prompt: |
    # Mission: Implémenter {story_id}

    Tu es un développeur expert autonome. Ta mission est d'implémenter cette story avec qualité APEX.

    ## Story à implémenter

    **Path:** docs/epics/{epic_id}/stories/{story_id}.md

    ## Instructions

    1. **Utilise le workflow /dev-story** pour implémenter:
       ```
       Skill: dev-story
       args: "{story_id} --auto"
       ```

    2. **Si tu rencontres un BUG** pendant l'implémentation:
       ```
       Skill: debug
       args: "--auto {description du bug}"
       ```

    3. **Si tu as besoin de CONTEXTE** sur le codebase:
       ```
       Skill: exploration:explore
       args: "{ce que tu cherches}"
       ```

    4. **Si l'implémentation est COMPLEXE** et nécessite planification:
       - Utilise l'outil `EnterPlanMode` pour concevoir ton approche
       - Sors du mode plan une fois le plan validé
       - Puis exécute le plan

    ## Contraintes Absolues

    - TDD OBLIGATOIRE: RED → GREEN → REFACTOR
    - VALIDATE avant EXAMINE: Tests + analyze AVANT review
    - 0 WARNINGS: `flutter analyze --fatal-infos`
    - SCOPE STRICT: Ne modifier que les fichiers de cette story

    ## Output Attendu

    Retourne un résumé structuré:
    ```
    STORY-XX-YY: [Titre]
    Status: COMPLETE | PARTIAL | BLOCKED
    Critères: X/Y satisfaits
    Tests: X passants
    Analyze: X warnings
    Fichiers modifiés: [liste]
    Workflows utilisés: [dev-story, debug, etc.]
    Notes: [observations]

    Si BLOCKED:
    - Raison: [description]
    - Tentatives: X/5
    - Action requise: [ce qu'il faut faire]
    ```
```

#### 2.2 Pour un Bug Détecté - Agent avec /debug

Quand le story-agent détecte un bug qu'il ne peut pas résoudre simplement :

```yaml
Task:
  subagent_type: "general-purpose"
  model: opus
  description: "Debug {symptom}"
  prompt: |
    # Mission: Résoudre ce bug

    ## Symptôme
    {description_du_bug}

    ## Contexte
    Détecté pendant l'implémentation de {story_id}

    ## Instructions

    1. **Utilise le workflow /debug** pour investiguer:
       ```
       Skill: debug
       args: "--auto {symptom}"
       ```

    2. Le workflow /debug va:
       - Collecter les FAITS (pas de suppositions)
       - Formuler et PROUVER une hypothèse
       - Proposer 3 solutions avec scoring
       - Appliquer la solution recommandée
       - Valider la résolution

    ## Output Attendu

    Retourne:
    ```
    BUG: [description]
    Status: RESOLVED | UNRESOLVED
    Cause racine: [explication]
    Solution appliquée: [description]
    Tests: PASS | FAIL
    ```
```

#### 2.3 Pour Exploration Contexte - Agent avec /exploration:explore

Quand un agent a besoin de comprendre le contexte :

```yaml
Task:
  subagent_type: "general-purpose"
  model: opus
  description: "Explorer {topic}"
  prompt: |
    # Mission: Explorer et comprendre

    ## Topic
    {ce_quon_cherche}

    ## Instructions

    1. **Utilise le workflow /exploration:explore**:
       ```
       Skill: exploration:explore
       args: "{topic}"
       ```

    2. Ce workflow va:
       - Lancer des agents parallèles (codebase, docs, web)
       - Synthétiser les résultats
       - Retourner contexte structuré

    ## Output Attendu

    Retourne une synthèse avec:
    - Fichiers pertinents trouvés
    - Patterns existants
    - Recommandations
```

#### 2.4 Pour Tâche Rapide - Agent avec /oneshot

Pour des tâches hors scope story mais nécessaires :

```yaml
Task:
  subagent_type: "general-purpose"
  model: opus
  description: "Oneshot {description}"
  prompt: |
    # Mission: Tâche rapide

    ## Description
    {ce_quil_faut_faire}

    ## Instructions

    1. **Utilise le workflow /oneshot**:
       ```
       Skill: oneshot
       args: "--auto {description}"
       ```

    2. Ce workflow va:
       - Explorer le contexte
       - Planifier l'implémentation
       - Exécuter avec TDD
       - Review adversariale
       - Commit

    ## Output Attendu

    Retourne:
    ```
    Task: [description]
    Status: COMPLETE | BLOCKED
    Fichiers: [liste]
    Tests: X passants
    ```
```

---

### 3. Safety: Git Branch Strategy

**AVANT de commencer une story:**

```yaml
safety_branch:
  action: |
    1. Créer une branche pour la story:
       git checkout -b story/{story_id}

    2. Ceci permet de rollback facilement si le subagent corrompt des fichiers

    3. Après succès, merge dans la branche Epic
```

**SI un subagent corrompt des fichiers:**

```yaml
rollback:
  action: |
    1. git checkout -- .
    2. Analyser ce qui s'est mal passé
    3. Relancer avec contexte ajusté
```

---

### 4. Cycle Orchestration par Story

```
┌──────────────────────────────────────────────────────────────────┐
│                    CYCLE ORCHESTRATION v3                         │
│                                                                   │
│  00. SAFETY     → Créer branche story (rollback possible)         │
│       ↓                                                           │
│  01. PREPARE    → Lire story, préparer contexte                   │
│       ↓                                                           │
│  02. DELEGATE   → Lancer Task agent avec /dev-story               │
│       ↓          (agent peut utiliser /debug, /explore, etc.)     │
│                                                                   │
│  03. MONITOR    → Attendre résultat du Task agent                 │
│       ↓          (timeout: 15 min par story, check périodique)    │
│                                                                   │
│  04. ANALYZE    → Parser le output, évaluer status                │
│       ↓                                                           │
│  05. DECIDE     → COMPLETE → Next story                           │
│       │          PARTIAL → Retry avec feedback                    │
│       │          BLOCKED → Self-healing ou escalade               │
│       ↓                                                           │
│  06. LOOP       → Max 5 tentatives intelligentes                  │
│       ↓                                                           │
│  07. TRACK      → Update TRACKING.md → Story suivante             │
└──────────────────────────────────────────────────────────────────┘
```

---

### 5. Timeout et Monitoring des Agents

**Timeout Strategy:**

```yaml
timeout_config:
  default_per_story: 15 minutes
  check_interval: 5 minutes

  monitoring:
    - Si agent actif > 10 min sans output → Warning log
    - Si agent actif > 15 min → Consider timeout
    - Utiliser `run_in_background: true` pour les stories longues

  on_timeout:
    - Log l'état actuel
    - Analyser ce qui bloque
    - Relancer avec prompt simplifié ou scope réduit
```

**Pour les agents en background:**

```yaml
background_agent:
  Task:
    run_in_background: true
    ...

  monitoring: |
    1. Le Task retourne un output_file path
    2. Vérifier périodiquement avec Read tool
    3. Ou utiliser Bash avec `tail -f` pour suivre

  retrieval: |
    Utiliser TaskOutput tool avec le task_id pour récupérer le résultat
```

---

### 6. Traitement du Résultat Task

#### 6.1 Parser le Output

```yaml
result_parsing:
  extract:
    - status: "COMPLETE" | "PARTIAL" | "BLOCKED"
    - criteria_met: X/Y
    - tests_passing: X
    - warnings: X
    - files_modified: [list]
    - workflows_used: [list]  # NEW: quels workflows ont été utilisés
    - notes: "..."
    - blocking_reason: "..." (si BLOCKED)
```

#### 6.2 Décision

```yaml
decision_tree:
  IF status == "COMPLETE" AND criteria_met == "Y/Y":
    → APPROVE: Passer à la story suivante

  IF status == "PARTIAL":
    → ANALYZE: Quels critères manquants ?
    → IF bug_detected:
        → Lancer agent /debug dédié
    → IF context_missing:
        → Lancer agent /exploration:explore
    → RETRY: Relancer avec informations additionnelles
    → attempt_count += 1

  IF status == "BLOCKED":
    → ANALYZE: Comprendre pourquoi
    → IF attempt_count < 5:
        → Ajuster stratégie (différent workflow, plus de contexte)
        → RETRY avec approche différente
    → ELSE:
        → ESCALATE: AskUserQuestion
```

---

### 7. Self-Healing Intelligent v3

**Principe clé: Utiliser le bon workflow selon le problème.**

```yaml
self_healing_v3:
  FOR attempt IN 1..5:

    1. EXECUTE:
       - Lancer Task agent avec /dev-story
       - Attendre résultat

    2. ANALYZE failure:
       IF failure_type == "bug":
         → Lancer nouvel agent avec /debug --auto
         → Intégrer le fix et réessayer /dev-story

       IF failure_type == "context_missing":
         → Lancer agent /exploration:explore
         → Enrichir le prompt avec le contexte trouvé
         → Réessayer /dev-story

       IF failure_type == "complexity":
         → Lancer agent avec EnterPlanMode
         → Obtenir un plan structuré
         → Réessayer /dev-story avec le plan

       IF failure_type == "test_failure":
         → Analyser les tests qui échouent
         → Ajuster le prompt avec les erreurs spécifiques
         → Réessayer

    3. LOG:
       execution_log[story_id].attempts.append({
         attempt: N,
         status: "...",
         failure_type: "...",
         workflow_used: "...",
         adjustment: "..."
       })

  IF attempt == 5 AND still_failing:
    → ESCALATE avec rapport complet incluant tous les workflows tentés
```

---

### 8. Parallélisation (Optionnel)

Si des stories sont **indépendantes** (pas de dépendances entre elles), lancer plusieurs agents en parallèle :

```yaml
parallel_execution:
  condition: stories_without_dependencies.count >= 2

  action: |
    Lancer PLUSIEURS Task en SINGLE message:

    Task 1:
      description: "Implémenter STORY-01-01"
      ...

    Task 2:
      description: "Implémenter STORY-01-02"
      ...

  benefit: Réduction significative du temps total
  risk: Conflits si les stories modifient les mêmes fichiers
  mitigation: Vérifier les fichiers impactés AVANT de paralléliser
```

---

### 9. Documentation Continue

**Après chaque story:**

```yaml
tracking_update:
  action: Edit docs/epics/{epic_id}/TRACKING.md
  content: |
    ## Progression

    - [x] {story_id} - {titre} (terminée {date})
      - Mode: autonomous (Task-based v3)
      - Tentatives: {N}
      - Workflows utilisés: {list}
      - Review: APPROVE après {X} iteration(s)
      - Notes: {observations}

    - [ ] {next_story_id} - {titre} (en cours)
```

---

### 10. Escalade (Si Blocage)

Après 5 tentatives échouées:

```yaml
escalation:
  trigger: attempt_count >= 5 AND status != "COMPLETE"

  action: AskUserQuestion
  format:
    question: |
      ⚠️ Story {story_id} bloquée après 5 tentatives.

      **Workflows tentés:**
      - /dev-story: {X} fois
      - /debug: {Y} fois
      - /exploration:explore: {Z} fois

      **Résumé des tentatives:**
      1. {workflow} → {raison_echec_1}
      2. {workflow} → {raison_echec_2}
      3. {workflow} → {raison_echec_3}
      4. {workflow} → {raison_echec_4}
      5. {workflow} → {raison_echec_5}

      **Cause racine probable:** {analyse}

      Comment veux-tu procéder?

    header: "Blocage"
    options:
      - label: "Skip cette story"
        description: "Passer à la suivante, revenir plus tard"
      - label: "Mode supervised"
        description: "Continuer cette story en mode interactif"
      - label: "Abandonner l'Epic"
        description: "Arrêter l'exécution ici"
```

---

### 11. Finalisation Story

Quand une story est COMPLETE et APPROVED:

```yaml
story_completion:
  1. Update TRACKING.md avec workflows utilisés
  2. Add to {completed_stories}
  3. Log success in {execution_log}
  4. Move to next story OR finalize if last
```

---

## AUTO-VALIDATION

**Before moving to next story:**
✅ Task agent a retourné COMPLETE
✅ Tous les critères satisfaits (X/X)
✅ Tests passent ({{TEST_CMD}})
✅ Analyze clean ({{LINT_CMD}})
✅ TRACKING.md mis à jour

**Self-Critique Questions:**
- Ai-je utilisé le bon workflow pour chaque situation ?
- Les agents ont-ils eu assez de contexte ?
- Ai-je vraiment analysé chaque échec avant de réessayer ?

---

## SUCCESS / FAILURE

**Success:**
✅ Toutes les stories COMPLETE
✅ Workflows appropriés utilisés
✅ Prêt pour finalisation (step-04)

**Failure modes:**
❌ Story bloquée après 5 tentatives → ESCALATE avec rapport détaillé
❌ Erreur technique inattendue → Log et tenter recovery
❌ Interruption utilisateur → Sauvegarder état, rapport partiel

---

## NEXT

- Si stories restantes → Continuer avec story suivante (loop)
- Si toutes stories terminées → Charger `steps/step-04-finalize.md`
- Si blocage → Attendre décision utilisateur après escalade

<critical>
MODE AUTONOMOUS v3 = ORCHESTRATION TASK
Les subagents peuvent utiliser les VRAIS workflows: /dev-story, /debug, /oneshot, /exploration:explore
MODEL OPUS par défaut pour tous les agents
SELF-HEALING INTELLIGENT: Choisir le bon workflow selon le type d'échec
Seul AskUserQuestion autorisé: Blocage critique après 5 tentatives
</critical>
