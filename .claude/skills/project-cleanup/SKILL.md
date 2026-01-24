---
name: project-cleanup
description: "Nettoyer, optimiser et moderniser un projet Flutter. Corriger warnings, mettre a jour deps, migrer vers Clean Architecture, ajouter tests. Optimise pour execution autonome longue duree."
model: opus
context: fork
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - TodoWrite
argument-hint: "[--phase=warnings|deps|migration|tests|docs] [--auto]"
---

<objective>
Remettre un projet Flutter sur de bons rails en corrigeant systematiquement les problemes identifies : warnings, dependances outdated, code legacy, manque de tests, documentation incomplete. Concu pour etre execute par Ralph en mode autonome pendant plusieurs heures.
</objective>

<critical_rule>
🛑 NEVER break the production build (test compile after each batch)
🛑 NEVER modify files outside current phase scope
🛑 NEVER skip validation between batches
🛑 NEVER update major dependencies without testing
🛑 NEVER commit without `flutter analyze` passing
✅ ALWAYS work in small batches (max 10 files per batch)
✅ ALWAYS verify build after each batch
✅ ALWAYS track progress in TodoWrite
✅ ALWAYS document changes in cleanup-log.md
✅ ALWAYS use model: sonnet for exploration agents
</critical_rule>

<when_to_use>
**Use this skill when:**
- Project has accumulated technical debt
- Many warnings from `flutter analyze`
- Dependencies are outdated
- Code needs migration to Clean Architecture
- Test coverage is insufficient

**Don't use for:**
- Feature development (use /dev-story)
- Bug fixes (use /debug)
- Quick cleanup (just fix manually)
</when_to_use>

<phases>
| Phase | Focus | Entry Condition |
|-------|-------|-----------------|
| **warnings** | Fix all `flutter analyze` warnings | Default starting phase |
| **deps** | Update dependencies incrementally | warnings phase complete |
| **migration** | Migrate FlutterFlow code to Clean Architecture | deps phase complete |
| **tests** | Add unit tests for migrated features | migration in progress |
| **docs** | Update documentation | Any phase (can run parallel) |
</phases>

<state_variables>
| Variable | Type | Description |
|----------|------|-------------|
| {current_phase} | enum | Current cleanup phase |
| {warnings_count} | number | Remaining warnings |
| {warnings_fixed} | number | Warnings fixed this session |
| {deps_updated} | array | Dependencies updated |
| {files_migrated} | array | Files migrated to Clean |
| {tests_added} | number | Tests added |
| {batch_number} | number | Current batch in phase |
</state_variables>

<entry_point>
Load `steps/step-00-assess.md`
</entry_point>

<step_files>
| Step | File | Purpose | Auto-Validation |
|------|------|---------|-----------------|
| 00 | step-00-assess.md | Assess current state, prioritize work | ✓ State documented |
| 01 | step-01-warnings.md | Fix warnings in batches | ✓ Warnings reduced |
| 02 | step-02-deps.md | Update dependencies incrementally | ✓ Deps updated, tests pass |
| 03 | step-03-migration.md | Migrate legacy code to Clean Architecture | ✓ Feature migrated |
| 04 | step-04-tests.md | Add tests for migrated features | ✓ Tests pass |
| 05 | step-05-docs.md | Update documentation | ✓ Docs updated |
</step_files>

<execution_rules>
1. **Batch Processing**: Work in batches of max 10 files
2. **Continuous Validation**: `flutter analyze` after each batch
3. **Progress Tracking**: Update TodoWrite after each batch
4. **Logging**: Append to cleanup-log.md after each batch
5. **Self-Healing**: Max 3 attempts per batch, then skip and log
6. **Phase Completion**: Move to next phase when current phase criteria met
7. **Autonomous Mode**: No user interaction after step-00 (Ralph mode)
</execution_rules>

<success_criteria>
✅ 0 warnings from `flutter analyze --fatal-infos`
✅ All dependencies updated to compatible versions
✅ Critical features migrated to Clean Architecture
✅ Tests added for migrated features (Map-level coverage)
✅ Documentation up to date
</success_criteria>

<failure_modes>
❌ Build fails after changes → Rollback batch, log issue, continue
❌ Dependency conflict → Skip dependency, log for manual review
❌ Migration breaks feature → Revert, log, escalate
❌ 3+ consecutive failures → Pause and generate report
</failure_modes>

<workflow_diagram>
```
┌──────────────────────────────────────────────────────────────────┐
│                    /project-cleanup WORKFLOW                      │
│         "Systematic Project Rehabilitation"                       │
│                                                                   │
│  00. ASSESS       → Analyze current state                         │
│       ↓            ✓ Warnings count, deps status, migration needs │
│                                                                   │
│  ┌──────────────── PHASE LOOP ────────────────────────┐          │
│  │                                                     │          │
│  │  01. WARNINGS   → Fix in batches of 10             │          │
│  │       │          ✓ flutter analyze after each       │          │
│  │       ↓                                             │          │
│  │  02. DEPS       → Update incrementally             │          │
│  │       │          ✓ Test after each update          │          │
│  │       ↓                                             │          │
│  │  03. MIGRATION  → Migrate feature by feature        │          │
│  │       │          ✓ Use Map module as template      │          │
│  │       ↓                                             │          │
│  │  04. TESTS      → Add tests for migrated code      │          │
│  │       │          ✓ Domain + Data + Widget tests    │          │
│  │       ↓                                             │          │
│  │  05. DOCS       → Update documentation             │          │
│  │       │          ✓ /documentation --auto           │          │
│  │                                                     │          │
│  └─────────────────────────────────────────────────────┘          │
│                                                                   │
│  OUTPUT: Clean, optimized, documented project                     │
└──────────────────────────────────────────────────────────────────┘
```
</workflow_diagram>

<ralph_mode>
## Execution Autonome (Ralph)

Ce workflow est optimise pour Ralph (Claude headless) :

### Caracteristiques
- **Pas d'interaction utilisateur** apres step-00
- **Progress tracking** via TodoWrite (visible dans logs)
- **Logging continu** dans cleanup-log.md
- **Auto-recovery** sur erreurs (max 3 tentatives)
- **Batches petits** pour limiter l'impact des erreurs

### Commande de lancement
```bash
# Mode complet (toutes les phases)
ralph "/project-cleanup --auto"

# Phase specifique
ralph "/project-cleanup --phase=warnings --auto"
```

### Monitoring
- Suivre cleanup-log.md pour voir la progression
- Consulter le TodoWrite dans les logs Ralph
- `flutter analyze` pour voir les warnings restants
</ralph_mode>

<begin>
Load `steps/step-00-assess.md` to start the workflow.
</begin>
