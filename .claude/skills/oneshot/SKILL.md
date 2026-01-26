---
name: oneshot
description: "Dev rapide APEX sans structure Epic/Story. Pour features < 1 jour."
model: opus
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite, Skill
argument-hint: "<description> [--mode=supervised|auto]"
---

<objective>
Implementer rapidement une feature avec qualite APEX (TDD, Review Adversariale, Self-Healing) sans formalisme Epic/Story. Pour features < 1 jour qui ne necessitent pas de tracking formel.
</objective>

<critical_rule>
🛑 NEVER code without exploring context first (step-01)
🛑 NEVER skip plan checkpoint in SUPERVISED mode
🛑 NEVER write implementation before test (TDD obligatoire)
🛑 NEVER skip Review Adversariale (EXAMINE step)
🛑 NEVER commit with failing tests or warnings
🛑 NEVER use AskUserQuestion after step-00 in AUTO mode
✅ ALWAYS launch 3 exploration agents in SINGLE message (parallel)
✅ ALWAYS use model: sonnet for exploration agents
✅ ALWAYS present synthesis before plan
✅ ALWAYS follow TDD cycle: RED → GREEN → REFACTOR
✅ ALWAYS do Review Adversariale on validated code
✅ ALWAYS invoke /commit for finalization
</critical_rule>

<when_to_use>
**Use this skill when:**
- Quick feature implementation (< 1 day estimated)
- No formal story structure needed
- Still requires production quality (TDD, Review, 0 warnings)
- Feature scope is clear and bounded

**Don't use for:**
- Complex features needing Epic decomposition → use /create-epic
- Formal story-driven development → use /dev-story
- Bug investigation → use /debug
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
| {description} | string | What to implement |
| {mode} | enum | auto or supervised (default: supervised) |
| {complexity} | enum | S, M, L (estimated) |
| {patterns_found} | array | Existing patterns in codebase |
| {files_impacted} | array | Files to create/modify |
| {docs_relevant} | array | Relevant documentation found |
| {exploration_synthesis} | object | Consolidated exploration results |
| {implementation_plan} | object | Detailed implementation plan |
| {risks} | array | Identified risks with mitigations |
| {code_written} | array | Files created/modified |
| {tests_written} | array | Tests written (TDD) |
| {review_results} | object | Review Adversariale results |
| {validation_status} | enum | PASS or FAIL |
| {commit_hash} | string | Hash of final commit |
</state_variables>

<entry_point>
Load `steps/step-00-prerequis.md`
</entry_point>

<step_files>
| Step | File | Purpose | Auto-Validation |
|------|------|---------|------------------|
| 00 | step-00-prerequis.md | Clarify request + detect mode | ✓ Mode and description captured |
| 01 | step-01-explore.md | 3 Sonnet agents parallel exploration | ✓ Context collected |
| 02 | step-02-plan.md | Generate plan + checkpoint (if supervised) | ✓ Plan complete |
| 03 | step-03-execute.md | APEX Engine: TDD + Review Adversariale | ✓ Code + tests + review |
| 04 | step-04-verify.md | Final validation (tests + analyze) | ✓ All pass |
| 05 | step-05-commit.md | Finalization via /commit | ✓ Commit created |
| 06 | (inline) | Finalization intelligente | Propose sync/doc selon mode |
</step_files>

<execution_rules>
1. **Progressive Loading**: Load one step at a time, complete fully before next
2. **Single User Interaction**: Only step-00 uses AskUserQuestion; AUTO mode = 0 after that
3. **Parallel Exploration**: 3 agents in SINGLE message for step-01 (Pattern #6)
4. **Model Strategy**: opus for orchestration, sonnet for exploration (Pattern #2)
5. **Mode-Conditional Checkpoint**: step-02 has checkpoint ONLY in SUPERVISED mode
6. **TDD Cycle**: RED → GREEN → REFACTOR for each implementation unit
7. **VALIDATE before EXAMINE**: Technical validation BEFORE Review Adversariale
8. **Self-Healing**: Max 5 attempts with learning between each
9. **Quality = /dev-story**: Same standards, less formalism
10. **/commit Integration**: Always finalize via /commit skill
11. **Intelligent Finalization**: After commit, propose sync/doc based on mode (see workflow-finalization pattern)
</execution_rules>

<success_criteria>
✅ Feature implemented matching description
✅ All tests pass ({{TEST_CMD}})
✅ 0 warnings ({{LINT_CMD}}nfos)
✅ Review Adversariale completed with APPROVE verdict
✅ Commit created with proper message
✅ No debug code or TODOs left behind
</success_criteria>

<failure_modes>
❌ Description too vague → Fallback: AskUserQuestion for clarification (step-00)
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
│                    /oneshot v2 WORKFLOW                          │
│         "Dev rapide APEX sans Epic/Story"                        │
│                                                                  │
│  00. PREREQUIS    → Clarifier demande + detecter mode            │
│       ↓            ✓ Mode AUTO ou SUPERVISED defini              │
│                                                                  │
│  01. EXPLORE      → 3 Sonnet agents en PARALLELE                 │
│       ↓            ✓ Patterns, fichiers, docs identifies         │
│                                                                  │
│  02. PLAN         → Generer plan d'implementation                │
│       ↓            ✓ Plan complet + risques identifies           │
│       │            [si SUPERVISED: CHECKPOINT utilisateur]       │
│       ↓                                                          │
│  03. EXECUTE      → APEX Engine                                  │
│       │            ├── TDD: RED → GREEN → REFACTOR               │
│       │            ├── VALIDATE: tests + analyze                 │
│       │            ├── EXAMINE: Review Adversariale              │
│       │            └── RESOLVE: corrections (max 5)              │
│       ↓            ✓ Code, tests, review OK                      │
│                                                                  │
│  04. VERIFY       → Validation finale                            │
│       ↓            ✓ {{TEST_CMD}} + analyze = 0 warnings         │
│       │            Self-healing: max 5 tentatives                │
│       ↓                                                          │
│  05. COMMIT       → Finalisation via /commit                     │
│       ↓            ✓ Commit cree avec resume                     │
│                                                                  │
│  06. FINALIZE     → Propose sync/doc (intelligent)               │
│                     SI SUPERVISED: AskUserQuestion               │
│                     SI AUTO: Agent Sonnet pour sync/doc          │
│                                                                  │
│  OUTPUT: Code implemente + tests + commit propre                 │
└──────────────────────────────────────────────────────────────────┘
```
</workflow_diagram>

<finalization_pattern>
## Étape 06 - Finalization Intelligente

Référence: `.claude/skills/sync-project/references/workflow-finalization.md`

### Logique

Après step-05 COMMIT, évaluer le travail effectué :

**Travail significatif détecté ?** (oneshot terminé = TOUJOURS OUI car c'est une feature complète)
- Code implémenté avec TDD
- Tests créés
- Feature terminée

### Exécution selon le mode

**SI mode = SUPERVISED :**

Proposer via AskUserQuestion :

```
question: "Feature implémentée avec succès. Voulez-vous synchroniser les références et/ou documenter ce travail ?"
header: "Finalisation"
options:
  - label: "Sync + Documentation (Recommandé)"
    description: "Met à jour les références + documente l'implémentation"
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
description: "Oneshot finalization sync/doc"
prompt: |
  Feature oneshot terminée: {description}

  1. Execute /sync-project --silent (si nouveaux fichiers structurels)
  2. Execute /documentation --auto --scope=workspace pour documenter le travail

  Fichiers modifiés: {code_written}
  Tests créés: {tests_written}

  Exécute silencieusement, pas besoin de rapport détaillé.
```
</finalization_pattern>

<begin>
Load `steps/step-00-prerequis.md` to start the workflow.
</begin>
