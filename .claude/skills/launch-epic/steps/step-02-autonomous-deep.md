# Step 02: Mode Autonomous DEEP (Chef Opus - Garantie Qualite Absolue)

> **Purpose**: Execution autonome avec supervision rigoureuse par un Chef Opus qui garantit que CHAQUE story est parfaitement implementee. Mode critique avec verification approfondie.

---

## DIFFERENCE AVEC MODE AUTONOMOUS STANDARD

| Aspect | Autonomous Standard | Autonomous DEEP |
|--------|---------------------|-----------------|
| **Supervision** | Delegation simple | Chef Opus critique et verifie |
| **Sub-agents** | `/dev-story --auto` | `/dev-story --deep` (iteration jusqu'a perfection) |
| **Verification** | Post-completion | Avant ET apres chaque story |
| **Coordination** | Independante | Fichier partage `COORDINATION.md` |
| **Plan Mode** | Occasionnel | Systematique avant chaque story |
| **Critique** | Review adversariale | Double review: sub-agent + Chef |
| **Design System** | Mentionne | VERIFIE explicitement |

---

## MANDATORY RULES (CHEF OPUS)

- 🎯 **TU ES LE CHEF OPUS** : Tu es le GARANT de la coherence et de la qualite de l'Epic entier
- 🔍 **CRITIQUE SYSTEMATIQUE** : Chaque output de sub-agent doit etre verifie OBJECTIVEMENT
- 🧠 **RAISONNEMENT EXPLICITE** : Toujours expliquer TON raisonnement avant d'agir
- 📋 **PLAN MODE OBLIGATOIRE** : Avant chaque story, entrer en Plan Mode pour reflechir
- 🔄 **ITERATION JUSQU'A PERFECTION** : Relancer les sub-agents si la qualite n'est pas parfaite
- 📝 **COORDINATION.md** : Maintenir un fichier partage pour la coordination inter-agents
- 🎨 **DESIGN SYSTEM** : TOUJOURS verifier le respect de `.claude/rules/ui-design-system.md`
- ⚠️ **ZERO TOLERANCE** : On ne passe PAS a la story suivante si la precedente n'est pas PARFAITE

---

## PROTOCOLS

- 🎯 **Goal**: Implementer l'Epic avec ZERO manquement, ZERO oubli, qualite PARFAITE
- 💾 **Output**: Epic complete avec garantie de coherence et qualite
- 📖 **Reference**: Task tool + COORDINATION.md + Plan Mode
- ⚡ **Performance**: Qualite prime sur vitesse - prendre le temps necessaire

---

## CONTEXT

**Available from step-00:**
- `{epic_id}` - ID de l'Epic
- `{mode}` = "autonomous-deep"
- `{stories}` - Liste des stories a implementer
- `{epic_content}` - Contenu de l'Epic

**Produced by this step:**
- `{completed_stories}` - Stories terminees avec VERIFICATION CHEF
- `{coordination_log}` - Log de coordination entre agents
- `{quality_report}` - Rapport qualite global
- `{design_compliance}` - Conformite au Design System

---

## FICHIER DE COORDINATION

Le Chef Opus maintient un fichier `COORDINATION.md` dans le scratchpad pour la coordination :

```markdown
# COORDINATION EPIC: {epic_id}

## Status Global

| Story | Sub-Agent | Status | Verification Chef | Design System |
|-------|-----------|--------|-------------------|---------------|
| S01 | Opus #1 | DONE | ✅ VERIFIED | ✅ CONFORME |
| S02 | Opus #2 | IN_PROGRESS | ⏳ PENDING | ⏳ PENDING |
| S03 | - | NOT_STARTED | - | - |

## Notes Inter-Agents

### Decisions Partagees
- [DECISION] Pattern X utilise pour Y - valable pour toutes les stories
- [DECISION] Composant Z cree - reutiliser dans stories suivantes

### Problemes Detectes
- [ISSUE] S01: Bug detecte dans X - corrige par sub-agent
- [WARNING] Pattern non-standard dans Y - a surveiller

### Design System Checkpoints
- [CHECK] S01: LynewedButton utilise ✅
- [CHECK] S01: LynewedColors respecte ✅
- [VIOLATION] S02: Material Button utilise - CORRIGER

## Fichiers Crees/Modifies

| Fichier | Story | Type | Notes |
|---------|-------|------|-------|
| lib/features/x/page.dart | S01 | CREATE | Page principale |
| lib/features/x/widget.dart | S01 | CREATE | Widget custom |
```

---

## EXECUTION SEQUENCE

### PHASE 0: PREPARATION CHEF

Avant de commencer l'Epic:

```yaml
preparation:
  1. LIRE integralement:
     - CLAUDE.md (regles projet)
     - .claude/rules/ui-design-system.md (Design System OBLIGATOIRE)
     - L'Epic complet et toutes les stories

  2. CREER COORDINATION.md:
     - Dans le scratchpad
     - Initialiser avec toutes les stories

  3. IDENTIFIER:
     - Dependances entre stories
     - Patterns communs a utiliser
     - Points d'attention Design System

  4. PLANIFIER la sequence:
     - Ordre optimal des stories
     - Stories parallelisables (si independantes)
```

### PHASE 1: CYCLE PAR STORY

Pour CHAQUE story, suivre ce cycle :

```
┌────────────────────────────────────────────────────────────────────────────┐
│                    CYCLE STORY (Chef Opus DEEP)                             │
│                                                                             │
│  A. PLAN MODE CHEF (AVANT delegation)                                       │
│       │                                                                     │
│       │  1. EnterPlanMode                                                   │
│       │  2. Lire story complete                                             │
│       │  3. Analyser:                                                       │
│       │     - Quels criteres d'acceptance ?                                 │
│       │     - Quels fichiers impactes ?                                     │
│       │     - Quels composants Design System utiliser ?                     │
│       │     - Quels patterns existants reutiliser ?                         │
│       │     - Quels risques anticiper ?                                     │
│       │  4. Rediger instructions PRECISES pour sub-agent                    │
│       │  5. ExitPlanMode avec plan valide                                   │
│       ↓                                                                     │
│  B. DELEGATION SUB-AGENT                                                    │
│       │                                                                     │
│       │  Task agent avec /dev-story --deep                                  │
│       │  Instructions enrichies par le plan du Chef                         │
│       ↓                                                                     │
│  C. VERIFICATION CHEF (APRES completion)                                    │
│       │                                                                     │
│       │  1. Lire le rapport du sub-agent                                    │
│       │  2. VERIFIER objectivement:                                         │
│       │     - TOUS les criteres d'acceptance satisfaits ?                   │
│       │     - Design System respecte (widgets Lynewed*) ?                   │
│       │     - Tests ecrits et passants ?                                    │
│       │     - Code quality (0 warnings) ?                                   │
│       │     - Coherence avec stories precedentes ?                          │
│       │  3. Lire les fichiers crees/modifies                                │
│       │  4. Checker Design System compliance                                │
│       ↓                                                                     │
│  D. DECISION CHEF                                                           │
│       │                                                                     │
│       ├── PARFAIT ────► Mettre a jour COORDINATION.md                       │
│       │                  Passer a story suivante                            │
│       │                                                                     │
│       └── INSUFFISANT ─► EnterPlanMode                                      │
│                          Identifier EXACTEMENT les manquements              │
│                          Relancer sub-agent avec instructions correctives   │
│                          (Max 3 iterations par story)                       │
└────────────────────────────────────────────────────────────────────────────┘
```

### A. PLAN MODE CHEF (AVANT delegation)

**OBLIGATOIRE avant chaque story.**

```yaml
chef_plan_mode:
  action: EnterPlanMode

  analyze:
    - story_path: "docs/epics/{epic_id}/stories/{story_id}.md"
    - read_story_completely: true
    - identify:
        acceptance_criteria: "[liste tous les AC]"
        files_impacted: "[prediction des fichiers]"
        design_system_components: "[widgets Lynewed* a utiliser]"
        existing_patterns: "[patterns a reutiliser]"
        risks: "[points d'attention]"
        dependencies: "[stories precedentes dont elle depend]"

  output:
    subagent_instructions: |
      # Instructions Enrichies pour Sub-Agent

      ## Story: {story_id}

      ## Criteres d'Acceptance (TOUS obligatoires)
      - AC1: [description precise]
      - AC2: [description precise]
      ...

      ## Design System (OBLIGATOIRE)
      TOUJOURS utiliser:
      - LynewedButton au lieu de ElevatedButton/TextButton
      - LynewedTextField au lieu de TextField
      - LynewedColors au lieu de couleurs hardcodees
      - LynewedTextStyles au lieu de TextStyle direct
      - LynewedSheet pour les bottom sheets

      Import: `import '/core/design/design.dart';`

      ## Patterns a Reutiliser
      - [pattern X de story Y]
      - [composant Z deja cree]

      ## Points d'Attention
      - [risque 1]
      - [risque 2]

      ## Fichiers Attendus
      - CREATE: [fichiers a creer]
      - MODIFY: [fichiers a modifier]
```

### B. DELEGATION SUB-AGENT

**Lancer un sub-agent Opus avec /dev-story --deep:**

```yaml
Task:
  subagent_type: "general-purpose"
  model: opus  # TOUJOURS Opus pour la qualite
  description: "Implementer {story_id} avec DEEP verification"
  prompt: |
    # MISSION: Implementer {story_id} avec qualite PARFAITE

    Tu es un developpeur senior autonome. Tu DOIS implementer cette story
    avec une qualite PARFAITE - le Chef Opus va VERIFIER ton travail.

    ## Story

    **Path:** docs/epics/{epic_id}/stories/{story_id}.md

    ## Instructions du Chef Opus

    {subagent_instructions}  # Instructions enrichies du plan

    ## EXECUTION OBLIGATOIRE

    1. **Utilise /dev-story --deep** pour implementer:
       ```
       Skill: dev-story
       args: "{story_id} --deep"
       ```

    2. Ce workflow va:
       - Faire TDD STRICT (RED → GREEN → REFACTOR)
       - Review Adversariale APPROFONDIE
       - Verification Design System
       - ITERER jusqu'a perfection

    ## DESIGN SYSTEM (CRITIQUE)

    **OBLIGATOIRE** - Le Chef va VERIFIER:
    - ✅ Utiliser `LynewedButton` (jamais ElevatedButton/TextButton)
    - ✅ Utiliser `LynewedTextField` (jamais TextField)
    - ✅ Utiliser `LynewedColors` (jamais Colors.xxx)
    - ✅ Utiliser `LynewedTextStyles` (jamais TextStyle direct)
    - ✅ Utiliser `LynewedSheet` pour bottom sheets
    - ✅ Import: `import '/core/design/design.dart';`

    **Reference:** `.claude/rules/ui-design-system.md`

    ## OUTPUT ATTENDU

    Retourne un rapport DETAILLE:
    ```
    # Rapport Story {story_id}

    ## Status: COMPLETE | PARTIAL | BLOCKED

    ## Criteres d'Acceptance
    - AC1: ✅ Satisfait | ❌ Non satisfait - [raison]
    - AC2: ✅ Satisfait | ❌ Non satisfait - [raison]
    ...

    ## Design System Compliance
    - LynewedButton: ✅ Utilise (X occurrences)
    - LynewedTextField: ✅ Utilise (Y occurrences)
    - Couleurs hardcodees: ❌ Aucune | ⚠️ Trouvees (details)
    - Styles texte hardcodes: ❌ Aucun | ⚠️ Trouves (details)

    ## Tests
    - Nombre: X tests ecrits
    - Status: PASS | FAIL
    - Couverture AC: X/Y criteres testes

    ## Fichiers
    - CREATED: [liste]
    - MODIFIED: [liste]

    ## Review Adversariale
    - Iterations: X
    - Verdict final: APPROVE
    - Issues fixes: [liste]

    ## Notes pour le Chef
    - [observations importantes]
    - [decisions prises]
    - [questions eventuelles]
    ```
```

### C. VERIFICATION CHEF (APRES completion)

**Le Chef Opus DOIT verifier objectivement:**

```yaml
chef_verification:
  1. PARSER le rapport:
     - Status global
     - Criteres d'acceptance (TOUS doivent etre ✅)
     - Design System compliance (TOUT doit etre ✅)
     - Tests (TOUS doivent PASS)

  2. LIRE les fichiers crees:
     - Verifier physiquement le code
     - Chercher des violations Design System
     - Chercher du code oublie ou bacle

  3. CHECKLIST VERIFICATION:
     questions:
       - "TOUS les AC de la story sont-ils implementes ?"
       - "Le Design System est-il STRICTEMENT respecte ?"
       - "Les tests couvrent-ils TOUS les AC ?"
       - "Le code est-il coherent avec les stories precedentes ?"
       - "Y a-t-il du code debug/TODO laisse ?"
       - "Les imports sont-ils corrects ?"

  4. RAISONNEMENT EXPLICITE:
     - "Je verifie AC1: [observation] → OK/NOK"
     - "Je verifie Design System: [observation] → OK/NOK"
     - ...
```

**Verification Design System (CRITIQUE):**

```yaml
design_system_check:
  search_violations:
    - pattern: "ElevatedButton|TextButton|OutlinedButton"
      should_be: "LynewedButton"

    - pattern: "TextField\\("
      should_be: "LynewedTextField"

    - pattern: "Colors\\.[a-z]+"
      should_be: "LynewedColors.xxx"

    - pattern: "TextStyle\\("
      should_be: "LynewedTextStyles.xxx"

    - pattern: "showModalBottomSheet"
      should_be: "LynewedSheet pattern"

  verification_commands:
    - grep -r "ElevatedButton\\|TextButton" lib/features/{feature}/
    - grep -r "TextField(" lib/features/{feature}/
    - grep -r "Colors\\." lib/features/{feature}/
```

### D. DECISION CHEF

```yaml
decision_tree:
  IF rapport.status == "COMPLETE" AND
     all_ac_satisfied AND
     design_system_compliant AND
     tests_pass:

    → ACTION: APPROVE
    → Update COORDINATION.md
    → Proceed to next story

  ELSE:
    → ACTION: REQUEST_CHANGES
    → EnterPlanMode
    → Identify EXACTLY what's missing/wrong
    → Document specific corrections needed
    → Relaunch sub-agent with corrective instructions
    → iteration_count += 1

  IF iteration_count >= 3:
    → ESCALATE
    → Document all attempts
    → AskUserQuestion for guidance
```

### PHASE 2: RELANCE CORRECTIVE (si necessaire)

Quand le Chef detecte des manquements:

```yaml
corrective_relaunch:
  1. EnterPlanMode:
     - Analyser exactement ce qui manque
     - Comprendre pourquoi le sub-agent a rate
     - Formuler instructions PRECISES

  2. Task corrective:
     prompt: |
       # CORRECTION REQUISE - {story_id}

       Le Chef Opus a detecte les problemes suivants:

       ## MANQUEMENTS IDENTIFIES

       1. [Probleme 1]: [description precise + fichier:ligne]
       2. [Probleme 2]: [description precise + fichier:ligne]
       ...

       ## CORRECTIONS ATTENDUES

       1. [Correction 1]: [instruction precise]
       2. [Correction 2]: [instruction precise]
       ...

       ## EXECUTION

       1. Lis les fichiers concernes
       2. Applique les corrections EXACTES
       3. Re-run tests + analyze
       4. Verifie Design System
       5. Retourne rapport mise a jour

       NE FAIS QUE LES CORRECTIONS DEMANDEES.
       Ne touche pas aux parties qui fonctionnent.
```

---

## COORDINATION INTER-AGENTS

### Fichier COORDINATION.md

Maintenu dans le scratchpad pour que le Chef puisse suivre:

```yaml
coordination_file:
  path: "{scratchpad}/COORDINATION-{epic_id}.md"

  updates:
    after_each_story:
      - Status story
      - Verification Chef (OK/NOK)
      - Design System compliance
      - Fichiers crees/modifies
      - Decisions partagees

    on_issue:
      - Description probleme
      - Story concernee
      - Resolution

    on_design_violation:
      - Type violation
      - Fichier:ligne
      - Correction appliquee
```

### Decisions Partagees

Quand un sub-agent prend une decision importante:

```yaml
shared_decision:
  format:
    - decision: "Utiliser pattern X pour les pages liste"
    - story: "S01"
    - rationale: "Coherence avec pages existantes"
    - applies_to: ["S02", "S03", "S05"]

  usage:
    - Chef inclut dans instructions des stories suivantes
    - Sub-agents suivants respectent ces decisions
```

---

## CHECKLIST FINALE CHEF

Apres TOUTES les stories completees:

```yaml
final_checklist:
  epic_level:
    - [ ] Toutes stories COMPLETE et VERIFIED
    - [ ] Design System respecte dans TOUS les fichiers
    - [ ] Coherence globale entre stories
    - [ ] Pas de patterns contradictoires
    - [ ] Tous tests passent (`flutter test`)
    - [ ] 0 warnings (`flutter analyze --fatal-infos`)

  run_commands:
    - flutter test --reporter compact --no-pub 2>&1 | tail -5
    - flutter analyze --fatal-infos
    - grep -r "ElevatedButton\|TextButton" lib/features/ || echo "OK"
    - grep -r "Colors\." lib/features/{epic_feature}/ | head -20

  if_issues:
    - Identifier quelle story a introduit le probleme
    - Relancer sub-agent correctif pour cette story
```

---

## AUTO-VALIDATION CHEF

**Questions que le Chef DOIT se poser:**

```yaml
self_critique_chef:
  per_story:
    - "Ai-je VRAIMENT verifie TOUS les criteres d'acceptance ?"
    - "Ai-je PHYSIQUEMENT lu les fichiers crees ?"
    - "Ai-je cherche des violations Design System ?"
    - "Le rapport du sub-agent est-il fiable ou dois-je verifier ?"
    - "Cette story est-elle PARFAITE ou ai-je laisse passer des problemes ?"

  per_decision:
    - "Ma decision est-elle OBJECTIVE ou complaisante ?"
    - "Si j'etais le client, serais-je satisfait ?"
    - "Y a-t-il des red flags que j'ignore ?"

  global:
    - "L'Epic entier est-il COHERENT ?"
    - "Toutes les stories s'integrent-elles bien ?"
    - "Le Design System est-il UNIFORMEMENT respecte ?"
```

---

## SUCCESS / FAILURE

**Success:**
✅ TOUTES les stories COMPLETE avec verification Chef
✅ Design System 100% conforme
✅ Coherence globale validee
✅ COORDINATION.md complete
✅ Tests et analyze passent
✅ Zero manquement, zero oubli

**Failure modes:**
❌ Story incomplete apres 3 iterations → ESCALATE avec rapport detaille
❌ Design System viole → CORRIGER AVANT de passer a la suite
❌ Incoherence detectee → Plan Mode pour resoudre
❌ Tests fail → Sub-agent debug + correction
❌ Chef pas convaincu → NE PAS APPROUVER, iterer

---

## NEXT

- Si stories restantes → Cycle PHASE 1 pour story suivante
- Si toutes stories terminees → Charger `steps/step-03-review.md` (review Epic globale)
- Si blocage → Rapport detaille + AskUserQuestion

<critical>
MODE AUTONOMOUS DEEP = CHEF OPUS GARANT DE LA QUALITE
Plan Mode OBLIGATOIRE avant chaque story
Verification OBJECTIVE apres chaque sub-agent
Design System STRICTEMENT respecte (.claude/rules/ui-design-system.md)
ZERO TOLERANCE pour les manquements
On NE PASSE PAS a la story suivante si pas PARFAIT
COORDINATION.md pour suivi inter-agents
Le Chef RAISONNE explicitement avant chaque decision
</critical>
