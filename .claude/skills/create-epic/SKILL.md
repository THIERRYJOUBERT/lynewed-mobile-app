---
name: create-epic
description: "Create Epic from PRD-MASTER with autonomous quality validation"
model: opus
---

<objective>
Transform a PRD-MASTER Epic into production-ready Epic documentation through autonomous exploration and APEX-style self-validation. Creates enriched stories with acceptance criteria extracted from FD sources.
</objective>

<critical_rule>
🛑 NEVER create Epic without PRD-MASTER validation
🛑 NEVER skip exploration phase - all 3 agents must run
🛑 NEVER generate stories without technical criteria from FDs
🛑 NEVER use "TBD", "...", or "a definir" in stories
🛑 NEVER skip AUTO-VALIDATION sections in steps
🛑 NEVER use AskUserQuestion after Epic selection (100% autonomous)
✅ ALWAYS use autonomous APEX-style self-validation (no user checkpoints)
✅ ALWAYS launch 3 exploration agents in SINGLE message (parallel execution)
✅ ALWAYS enrich EVERY story with acceptance criteria from FDs
✅ ALWAYS use model: sonnet for exploration agents (quality over cost)
✅ ALWAYS create sources.yaml to document discovery
✅ ALWAYS estimate complexity S/M/L for each story
✅ ALWAYS challenge story completeness against PRD-MASTER scope
✅ ALWAYS add adaptive sections based on Epic context
</critical_rule>

<when_to_use>
**Use this skill when:**
- Starting a new Epic from PRD-MASTER
- Need to decompose high-level Epic into Stories
- Want auto-validated, production-ready Epic documentation

**Don't use for:**
- Single stories (use /create-story instead)
- Exploratory work without PRD (use /explore instead)
- Quick features without Epic structure (use /oneshot instead)
</when_to_use>

<state_variables>
| Variable | Type | Description |
|----------|------|-------------|
| {epic_id} | string | e.g., EPIC-00-FOUNDATION |
| {epic_name} | string | Full Epic name from PRD-MASTER |
| {domain} | enum | INFRA, DATA, UI, API (detected or user-specified) |
| {sources_mapping} | object | primary FD, secondary FDs, detailed docs |
| {exploration_results} | array | Results from 3 parallel Sonnet agents |
| {stories} | array | Enriched stories with criteria |
| {stories_count} | int | Number of stories identified |
| {gaps} | array | Missing information discovered |
| {discovery_method} | enum | auto, manual |
</state_variables>

<entry_point>
Load `steps/step-00-prerequis.md`
</entry_point>

<step_files>
| Step | File | Purpose | Auto-Validation |
|------|------|---------|------------------|
| 00 | step-00-prerequis.md | Verify PRD-MASTER exists + valid | File exists + status check |
| 01 | step-01-select.md | Select Epic via AskUserQuestion | User selection required |
| 02 | step-02-discovery.md | Scan PRD-MASTER for sources | ✓ Mapping completeness |
| 03 | step-03-explore.md | 3 parallel Sonnet agents | ✓ Each agent output validated |
| 04 | step-04-synthesize.md | Consolidate + enrich stories | ✓ All stories have criteria |
| 05 | step-05-generate.md | Generate files using templates | ✓ Required sections present |
| 06 | step-06-confirm.md | Output summary + next steps | Final report |
| 07 | (inline) | Finalization intelligente | Propose sync/doc si pertinent |
</step_files>

<templates>
| Template | File | Purpose |
|----------|------|---------|
| Epic | templates/epic.md | EPIC-XX.md structure with placeholders |
| Tracking | templates/tracking.md | TRACKING.md structure |
| Sources | templates/sources.yaml | sources.yaml format |
</templates>

<execution_rules>
1. **Progressive Loading**: Load one step at a time, complete fully before next
2. **Autonomous Validation**: Each step validates its output via APEX self-critique before proceeding
3. **Parallel Agents**: Use SINGLE message with 3 Task calls for exploration (step-03)
4. **State Persistence**: Track all variables through steps
5. **Template Usage**: Load templates from templates/ directory for generation
6. **Domain Detection**: Auto-detect domain from Epic name (no AskUserQuestion)
7. **Gap Documentation**: Any missing info documented in sources.yaml and Epic.md
8. **Story Challenge**: Validate ALL stories against PRD-MASTER scope before generation
9. **Adaptive Template**: Add context-specific sections beyond base template
10. **Single User Interaction**: Only ONE AskUserQuestion in step-01 for Epic selection, then 100% autonomous
11. **Intelligent Finalization**: After step-06, propose sync/doc based on work done (see workflow-finalization pattern)
</execution_rules>

<domain_detection>
```
DOMAINS = {
  "INFRA": ["foundation", "setup", "ci/cd", "config", "structure", "project"],
  "DATA":  ["database", "schema", "storage", "migration", "cache", "drift"],
  "UI":    ["screen", "widget", "design", "ux", "component", "home", "settings"],
  "API":   ["auth", "endpoint", "service", "integration", "sync", "supabase"]
}
```
</domain_detection>

<success_criteria>
✅ Epic.md with ALL required sections:
   - Context (Why this Epic + Technical Pillars)
   - Architecture diagram (if INFRA or DATA)
   - Stories table with criteria, source FD, complexity
   - Story details with COMPLETE fields (no "...")
   - Risks and Mitigations
   - References FD summary
✅ TRACKING.md with Timeline, Problems, Decisions, Retrospective sections
✅ sources.yaml documenting discovery method and all sources
✅ ALL stories have acceptance criteria from FDs
✅ Domain-specific prompts applied correctly
✅ Templates followed exactly (no deviations)
</success_criteria>

<failure_modes>
❌ PRD-MASTER missing or not VALIDE status
❌ Discovery returns 0 sources and user doesn't provide manual mapping
❌ Stories without acceptance criteria from FDs
❌ Missing required Epic.md sections
❌ Vague content ("TBD", "...", "voir FD pour details")
❌ Templates not followed
</failure_modes>

<output_structure>
```
docs/epics/EPIC-XX-NAME/
├── EPIC-XX-NAME.md       # Enriched Epic definition
├── TRACKING.md           # Progress tracking
├── sources.yaml          # Source mapping (v5 feature)
└── stories/              # Empty (populated by /create-story)
```
</output_structure>

<workflow_diagram>
```
┌──────────────────────────────────────────────────────────────────┐
│                    /create-epic v6 WORKFLOW                      │
│                                                                  │
│  00. PREREQUIS      → Verify PRD-MASTER exists + VALIDE          │
│       ↓                                                          │
│  01. SELECT         → User selects Epic (AskUserQuestion)        │
│       ↓                                                          │
│  02. DISCOVERY      → Scan PRD-MASTER for sources                │
│       ↓              ✓ AUTO-VALIDATE: mapping complete?          │
│                                                                  │
│  03. EXPLORE        → 3 Sonnet agents in PARALLEL                │
│       ↓              ✓ AUTO-VALIDATE: each output valid?         │
│                                                                  │
│  04. SYNTHESIZE     → Consolidate + enrich ALL stories           │
│       ↓              ✓ AUTO-VALIDATE: all stories have criteria? │
│                                                                  │
│  05. GENERATE       → Create files using templates               │
│       ↓              ✓ AUTO-VALIDATE: all sections present?      │
│                                                                  │
│  06. CONFIRM        → Summary + next steps                       │
│       ↓                                                          │
│                                                                  │
│  07. FINALIZE       → Propose sync/doc (intelligent)             │
│                       SI travail significatif détecté:           │
│                         → AskUserQuestion: sync + doc options    │
│                                                                  │
│  OUTPUT: docs/epics/EPIC-XX-NAME/                                │
│          ├── EPIC-XX-NAME.md                                     │
│          ├── TRACKING.md                                         │
│          ├── sources.yaml                                        │
│          └── stories/                                            │
└──────────────────────────────────────────────────────────────────┘
```
</workflow_diagram>

<finalization_pattern>
## Étape 07 - Finalization Intelligente

Référence: `.claude/skills/sync-project/references/workflow-finalization.md`

### Logique

Après step-06 CONFIRM, évaluer le travail effectué :

**Travail significatif détecté ?** (création Epic = TOUJOURS OUI)
- Nouveaux fichiers créés dans docs/epics/
- Structure projet modifiée
- Décisions documentées

### Exécution

**Ce workflow est 100% autonome après step-01** (pas de mode supervised/auto distinct)

→ Proposer via AskUserQuestion :

```
question: "Epic créé avec succès. Voulez-vous synchroniser les références projet ?"
header: "Finalisation"
options:
  - label: "Sync références (Recommandé)"
    description: "Met à jour INDEX.md et CROSS-EPIC.md"
  - label: "Non merci"
    description: "L'Epic est prêt, pas besoin de sync maintenant"
```

SI utilisateur choisit Sync → Invoke `/sync-project --silent`
SI utilisateur decline → Fin du workflow
</finalization_pattern>

<begin>
Load `steps/step-00-prerequis.md` to start the workflow.
</begin>
