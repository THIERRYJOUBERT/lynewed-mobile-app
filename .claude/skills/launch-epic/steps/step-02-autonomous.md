# Step 02: Mode Autonomous (Automatique)

> Purpose: Exécuter l'Epic automatiquement sans interruption utilisateur, avec self-healing et review adversariale.

---

## MANDATORY RULES (READ FIRST)

- 🚀 **PAS D'INTERRUPTION** : L'utilisateur ne fait RIEN après le lancement
- 🔄 **SELF-HEALING** : Max 5 tentatives intelligentes par story
- 🎯 **TASK TOOL** : Utiliser subagent story-executor pour chaque story
- 📊 **DOCUMENTATION** : Tracker progression dans TRACKING.md

## PROTOCOLS

- 🎯 **Goal**: Implémenter toutes les stories automatiquement
- 💾 **Output**: Epic complète ou rapport de blocage
- 📖 **Reference**: story-executor (.claude/agents/story-executor.md)
- ⚡ **Performance**: Exécution parallèle quand possible

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

---

## EXECUTION

### 1. Principe Fondamental

**L'utilisateur ne fait RIEN.** Tu travailles seul jusqu'à:
- Epic complète (succès)
- Blocage critique après 5 tentatives (escalade)
- Interruption manuelle par l'utilisateur

---

### 2. Cycle par Story

```
┌──────────────────────────────────────────────────────────────────┐
│                    CYCLE AUTOMATIQUE PAR STORY                   │
│                                                                  │
│  01. PREPARE    → Lire story, préparer contexte                  │
│       ↓                                                          │
│  02. EXECUTE    → Lancer story-executor via Task                 │
│       ↓                                                          │
│  03. VALIDATE   → {{TEST_CMD}} + analyze (AVANT review!)        │
│       ↓                                                          │
│  04. EXAMINE    → REVIEW ADVERSARIALE (toi-même)                │
│       ↓                                                          │
│  05. RESOLVE    → Si problèmes → Corriger                        │
│       ↓                                                          │
│  06. LOOP       → Self-healing si échec (max 5, intelligent)     │
│       ↓                                                          │
│  07. COMMIT     → Update TRACKING.md → Story suivante           │
└──────────────────────────────────────────────────────────────────┘
```

---

### 3. Lancer Story-Executor via Task

**SYNTAXE EXACTE du Task tool:**

> **Note Timeout**: Les tâches complexes peuvent prendre du temps. Si le Task semble bloqué après 10+ minutes sans output, vérifier le log et considérer une relance.

```yaml
Task:
  description: "Implémenter {story_id}"
  subagent_type: "story-executor"
  prompt: |
    # Story à implémenter

    **Story path:** docs/epics/{epic_id}/stories/{story_id}.md

    ## Instructions

    1. Lire la story complètement
    2. Suivre le workflow 8 étapes:
       ANALYZE → PLAN → EXECUTE (TDD) → VALIDATE → EXAMINE → RESOLVE → TEST LOOP → OUTPUT

    3. Pour chaque critère d'acceptation:
       - RED: Écrire test qui échoue
       - GREEN: Code minimal qui passe
       - REFACTOR: Nettoyer

    4. VALIDATE technique ({{TEST_CMD}} + analyze) AVANT la self-critique

    5. Self-critique obligatoire

    6. Retourner résumé structuré:
       ```
       STORY-XX-YY: [Titre]
       Status: COMPLETE | PARTIAL | BLOCKED
       Critères: X/Y satisfaits
       Tests: X passants
       Analyze: X warnings
       Fichiers modifiés: [liste]
       Notes: [observations]
       ```

    ## Contraintes

    - TDD OBLIGATOIRE: Pas de code avant test
    - VALIDATE avant EXAMINE: Pas de review sur code qui ne compile pas
    - SELF-HEALING: Max 5 tentatives si tests échouent
    - SCOPE STRICT: Ne modifier que les fichiers de cette story
```

---

### 4. Traitement du Résultat

#### 4.1 Parser le Output

```yaml
result_parsing:
  extract:
    - status: "COMPLETE" | "PARTIAL" | "BLOCKED"
    - criteria_met: X/Y
    - tests_passing: X
    - warnings: X
    - files_modified: [list]
    - notes: "..."
    - blocking_reason: "..." (si BLOCKED)
```

#### 4.2 Décision

```yaml
decision_tree:
  IF status == "COMPLETE" AND criteria_met == "Y/Y":
    → APPROVE: Passer à la story suivante

  IF status == "PARTIAL":
    → RETRY: Relancer avec feedback
    → attempt_count += 1

  IF status == "BLOCKED":
    → ANALYZE: Comprendre pourquoi
    → IF attempt_count < 5:
        → RETRY avec approche ajustée
    → ELSE:
        → ESCALATE: AskUserQuestion
```

---

### 5. Self-Healing Intelligent

**Principe clé: Chaque tentative doit APPRENDRE de la précédente.**

```yaml
self_healing_loop:
  FOR attempt IN 1..5:

    1. EXECUTE:
       - Lancer story-executor
       - Attendre résultat

    2. ANALYZE:
       IF échec:
         - Identifier la cause racine
         - Documenter: "Tentative {N} échouée car {raison}"
         - Déterminer ajustement pour prochaine tentative

    3. ADJUST:
       - Modifier le prompt/contexte basé sur l'analyse
       - NE PAS répéter la même approche

    4. LOG:
       execution_log[story_id].attempts.append({
         attempt: N,
         status: "...",
         failure_reason: "...",
         adjustment: "..."
       })

  IF attempt == 5 AND still_failing:
    → ESCALATE avec rapport complet
```

**Règle d'or:**
> "Chaque tentative doit APPRENDRE de la précédente. Répéter la même chose 5 fois = échec du self-healing."

---

### 6. Review Adversariale (Toi-même)

**CHANGEMENT DE RÔLE**

Tu n'es PLUS le coordinateur bienveillant. Tu es maintenant un **Reviewer Senior Impitoyable**.

```yaml
adversarial_review:
  prerequisite:
    - Code compile (VALIDATE passé)
    - Tests passent

  checklist:
    conformite_spec:
      - Implémente EXACTEMENT ce qui est demandé?
      - Rien de manquant?
      - Rien en trop (over-engineering)?

    qualite_code:
      - Tests couvrent les cas importants?
      - Conventions respectées?
      - Pas de code dupliqué?

    securite:
      - Pas d'injection possible?
      - Validation inputs présente?
      - Pas de secrets hardcodés?

  output:
    format: |
      REVIEW ADVERSARIALE - {story_id}

      PROBLÈMES TROUVÉS:
      1. [CRITIQUE] {description} - {fichier}:{ligne}
      2. [IMPORTANT] {description} - {fichier}:{ligne}

      VERDICT: APPROVE | NEEDS_WORK

  rule:
    IF problemes_trouves == 0:
      → Re-examiner. C'est suspect.
```

---

### 7. Documentation Continue

**Après chaque story:**

```yaml
tracking_update:
  action: Edit docs/epics/{epic_id}/TRACKING.md
  content: |
    ## Progression

    - [x] {story_id} - {titre} (terminée {date})
      - Mode: autonomous
      - Tentatives: {N}
      - Review: APPROVE après {X} iteration(s)
      - Notes: {observations}

    - [ ] {next_story_id} - {titre} (en cours)
```

---

### 8. Escalade (Si Blocage)

Après 5 tentatives échouées:

```yaml
escalation:
  trigger: attempt_count >= 5 AND status != "COMPLETE"

  action: AskUserQuestion
  format:
    question: |
      ⚠️ Story {story_id} bloquée après 5 tentatives.

      **Résumé des tentatives:**
      1. {raison_echec_1}
      2. {raison_echec_2}
      3. {raison_echec_3}
      4. {raison_echec_4}
      5. {raison_echec_5}

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

### 9. Finalisation Story

Quand une story est COMPLETE et APPROVED:

```yaml
story_completion:
  1. Update TRACKING.md
  2. Add to {completed_stories}
  3. Log success in {execution_log}
  4. Move to next story OR finalize if last
```

---

## AUTO-VALIDATION

**Before moving to next story:**
✅ Story-executor a retourné COMPLETE
✅ Tous les critères satisfaits (X/X)
✅ Tests passent ({{TEST_CMD}})
✅ Analyze clean ({{LINT_CMD}}
✅ Review adversariale APPROVE
✅ TRACKING.md mis à jour

**Self-Critique Questions:**
- Ai-je vraiment analysé chaque échec avant de réessayer?
- Mes ajustements étaient-ils basés sur des données ou des intuitions?
- La review adversariale était-elle rigoureuse ou complaisante?

---

## SUCCESS / FAILURE

**Success:**
✅ Toutes les stories COMPLETE
✅ Prêt pour finalisation (step-04)

**Failure modes:**
❌ Story bloquée après 5 tentatives → ESCALATE avec rapport
❌ Erreur technique inattendue → Log et tenter recovery
❌ Interruption utilisateur → Sauvegarder état, rapport partiel

---

## NEXT

- Si stories restantes → Continuer avec story suivante (loop)
- Si toutes stories terminées → Charger `steps/step-04-finalize.md`
- Si blocage → Attendre décision utilisateur après escalade

<critical>
MODE AUTONOMOUS = PAS D'INTERRUPTION
Seul AskUserQuestion autorisé: Blocage critique après 5 tentatives.
SELF-HEALING INTELLIGENT: Analyser AVANT de réessayer.
TASK TOOL: Utiliser la syntaxe exacte documentée ci-dessus.
</critical>
