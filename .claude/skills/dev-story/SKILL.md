---
name: dev-story
description: "Implementer une story avec TDD strict Red-Green-Refactor. Utiliser pour developper une story validee."
model: opus
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite, Skill
argument-hint: "<story-id> [--mode=supervised|auto]"
---

<objective>
Implementer une story formelle avec qualite APEX (TDD, Review Adversariale, Self-Healing). Charge le fichier story, explore le contexte, planifie l'implementation, et execute avec rigueur.
</objective>

<critical_rule>
🛑 NEVER code without loading and understanding the story first (step-00)
🛑 NEVER code without exploring context (step-01)
🛑 NEVER skip plan checkpoint in SUPERVISED mode
🛑 NEVER write implementation before test (TDD obligatoire)
🛑 NEVER skip Review Adversariale (EXAMINE step)
🛑 NEVER commit with failing tests or warnings
🛑 NEVER use AskUserQuestion after step-00 in AUTO mode
✅ ALWAYS load story file and validate prerequisites first
✅ ALWAYS launch 3 exploration agents in SINGLE message (parallel)
✅ ALWAYS use model: sonnet for exploration agents
✅ ALWAYS present synthesis before plan
✅ ALWAYS follow TDD cycle: RED → GREEN → REFACTOR
✅ ALWAYS do Review Adversariale on validated code
✅ ALWAYS update story status and TRACKING.md at end
✅ ALWAYS invoke /commit for finalization
</critical_rule>

<when_to_use>
**Use this skill when:**
- Implementing a formal story from an Epic
- Story file exists in docs/epics/EPIC-XX/stories/
- TDD and quality tracking required
- Story has acceptance criteria (Gherkin)

**Don't use for:**
- Quick features without story → use /oneshot
- Bug investigation → use /debug
- Epic decomposition → use /create-story
- Simple single-line fixes → direct edit
</when_to_use>

<modes>
| Mode | Flag | Behavior |
|------|------|----------|
| **SUPERVISED** | default | Checkpoint after PLAN (user validates before coding) |
| **AUTO** | `--auto` | 100% autonomous after step-00 (no plan checkpoint) |

**Note**: Both modes maintain same quality standards (TDD, Review, 0 warnings).
</modes>

<state_variables>
| Variable | Type | Description |
|----------|------|-------------|
| {story_id} | string | Story identifier (e.g., STORY-01-01) |
| {mode} | enum | auto or supervised (default: supervised) |
| {story_path} | string | Path to story file |
| {story_content} | object | Parsed story (criteria, files, tests) |
| {patterns_found} | array | Existing patterns in codebase |
| {files_impacted} | array | Files to create/modify |
| {exploration_synthesis} | object | Consolidated exploration results |
| {implementation_plan} | object | Detailed TDD plan |
| {code_written} | array | Files created/modified |
| {tests_written} | array | Tests written (TDD) |
| {review_results} | object | Review Adversariale results |
| {validation_status} | enum | PASS or FAIL |
| {commit_hash} | string | Hash of final commit |
</state_variables>

<entry_point>
Load `steps/step-00-load.md`
</entry_point>

<step_files>
| Step | File | Purpose | Auto-Validation |
|------|------|---------|------------------|
| 00 | step-00-load.md | Load story + validate prerequisites | ✓ Story loaded, criteria parsed |
| 01 | step-01-explore.md | 3 Sonnet agents parallel exploration | ✓ Context collected |
| 02 | step-02-plan.md | Generate TDD plan + checkpoint (if supervised) | ✓ Plan complete |
| 03 | step-03-execute.md | APEX Engine: TDD + Review Adversariale | ✓ Code + tests + review |
| 04 | step-04-verify.md | Final validation (tests + analyze) | ✓ All pass |
| 05 | step-05-commit.md | Finalization + story status update | ✓ Commit + tracking updated |
| 06 | (inline) | Finalization intelligente | Propose sync/doc selon mode |
</step_files>

<execution_rules>
1. **Progressive Loading**: Load one step at a time, complete fully before next
2. **Story-Driven**: Story file is the source of truth for acceptance criteria
3. **Parallel Exploration**: 3 agents in SINGLE message for step-01 (Pattern #6)
4. **Model Strategy**: opus for orchestration, sonnet for exploration (Pattern #2)
5. **Mode-Conditional Checkpoint**: step-02 has checkpoint ONLY in SUPERVISED mode
6. **TDD Cycle**: RED → GREEN → REFACTOR for each acceptance criterion
7. **VALIDATE before EXAMINE**: Technical validation BEFORE Review Adversariale
8. **Self-Healing**: Max 5 attempts with learning between each
9. **Story Tracking**: Update story status and TRACKING.md at completion
10. **/commit Integration**: Always finalize via /commit skill
11. **Intelligent Finalization**: After commit, propose sync/doc based on mode (see workflow-finalization pattern)
</execution_rules>

<success_criteria>
✅ All acceptance criteria implemented
✅ All tests pass ({{TEST_CMD}})
✅ 0 warnings ({{LINT_CMD}})
✅ Review Adversariale completed with APPROVE verdict
✅ Story status updated to "Done"
✅ TRACKING.md updated with completion
✅ Commit created with proper message
✅ No debug code or TODOs left behind
</success_criteria>

<failure_modes>
❌ Story ID not found → Fallback: List available stories, ask user
❌ Story has unmet dependencies → Fallback: Warn and ask to proceed or abort
❌ Exploration agents fail → Fallback: Manual exploration, document gap
❌ Plan rejected (supervised) → Adjust and re-present plan
❌ Tests fail after implementation → Self-healing loop (max 5)
❌ Review finds critical issues → RESOLVE loop (max 5)
❌ Final validation fails → Return to step-03 for fixes
❌ Commit blocked by /commit → Fix issues and retry
</failure_modes>

<workflow_diagram>
```
┌──────────────────────────────────────────────────────────────────┐
│                    /dev-story v2 WORKFLOW                         │
│         "Story-Driven Development with APEX Quality"              │
│                                                                   │
│  00. LOAD         → Charger story + valider prerequis             │
│       ↓            ✓ Story file loaded, criteria parsed           │
│                                                                   │
│  01. EXPLORE      → 3 Sonnet agents en PARALLELE                  │
│       ↓            ✓ Patterns, fichiers, story-context identifies │
│                                                                   │
│  02. PLAN         → Generer plan TDD par critere                  │
│       ↓            ✓ Plan complet + risques identifies            │
│       │            [si SUPERVISED: CHECKPOINT utilisateur]        │
│       ↓                                                           │
│  03. EXECUTE      → APEX Engine                                   │
│       │            ├── TDD: RED → GREEN → REFACTOR (par critere)  │
│       │            ├── VALIDATE: tests + analyze                  │
│       │            ├── EXAMINE: Review Adversariale               │
│       │            └── RESOLVE: corrections (max 5)               │
│       ↓            ✓ Code, tests, review OK                       │
│                                                                   │
│  04. VERIFY       → Validation finale                             │
│       ↓            ✓ {{TEST_CMD}} + analyze = 0 warnings          │
│       │            Self-healing: max 5 tentatives                 │
│       ↓                                                           │
│  05. COMMIT       → Finalisation via /commit                      │
│       ↓            ✓ Story status "Done" + TRACKING.md updated    │
│                                                                   │
│  06. FINALIZE     → Propose sync/doc (intelligent)                │
│                     SI SUPERVISED: AskUserQuestion                │
│                     SI AUTO: Agent Sonnet pour sync/doc           │
│                                                                   │
│  OUTPUT: Story implementee + tests + tracking mis a jour          │
└──────────────────────────────────────────────────────────────────┘
```
</workflow_diagram>

<finalization_pattern>
## Étape 06 - Finalization Intelligente

Référence: `.claude/skills/sync-project/references/workflow-finalization.md`

### Logique

Après step-05 COMMIT, évaluer le travail effectué :

**Travail significatif détecté ?** (implémentation story = TOUJOURS OUI)
- Code implémenté avec TDD
- Tests créés
- Story terminée

### Exécution selon le mode

**SI mode = SUPERVISED :**

Proposer via AskUserQuestion :

```
question: "Story implémentée avec succès. Voulez-vous synchroniser les références et/ou documenter cette session ?"
header: "Finalisation"
options:
  - label: "Sync + Documentation (Recommandé)"
    description: "Met à jour TRACKING.md + documente l'implémentation"
  - label: "Sync uniquement"
    description: "Met à jour les fichiers de référence"
  - label: "Documentation uniquement"
    description: "Documente cette session de travail"
  - label: "Terminer sans"
    description: "Le commit est fait, pas besoin de plus"
```

**SI mode = AUTO :**

Lancer un agent Sonnet pour exécuter sync/doc sans polluer le contexte principal :

```
{Task tool}
subagent_type: general-purpose
model: sonnet
description: "Finalization sync/doc"
prompt: |
  Story {story_id} implémentée avec succès.

  1. Execute /sync-project --silent pour mettre à jour TRACKING.md
  2. Execute /documentation --auto --scope=epics pour documenter l'implémentation

  Fichiers modifiés: {code_written}
  Tests créés: {tests_written}

  Exécute silencieusement, pas besoin de rapport détaillé.
```
</finalization_pattern>

<begin>
Load `steps/step-00-load.md` to start the workflow.
</begin>
