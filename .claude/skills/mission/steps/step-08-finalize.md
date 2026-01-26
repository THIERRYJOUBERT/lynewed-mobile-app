# Step 08: Finalize

> Purpose: Generer le rapport final et proposer sync/documentation.

---

## MANDATORY RULES

- 🎯 ALWAYS generer un rapport complet
- 📊 ALWAYS proposer next steps
- ✅ ALWAYS offrir sync/documentation
- 🚫 NEVER terminer sans resume

## PROTOCOLS

- 🎯 **Goal**: Conclure le workflow avec rapport
- 💾 **Output**: `{final_report}`
- ⚡ **Performance**: Summary + optional actions

---

## CONTEXT

**Available from previous steps:**
- `{mission_file_path}` - MISSION.md cree (step-05)
- `{generated_epics}` - Epics crees (step-06)
- `{generated_stories}` - Stories creees (step-07)

**Produced by this step:**
- `{final_report}` - Resume final

---

## TASK

### 1. Compiler les statistiques

```yaml
statistics:
  mission:
    path: {mission_file_path}
    name: {mission_document.metadata.name}

  epics:
    count: {generated_epics.length}
    total_points: {sum of epic points}
    by_domain:
      INFRA: {count}
      DATA: {count}
      UI: {count}
      API: {count}

  stories:
    total: {sum across all epics}
    total_points: {sum of all story points}
    by_epic:
      EPIC-XX: {count}
      EPIC-YY: {count}

  files_created:
    - {mission_file_path}
    - For each epic:
      - {epic_path}/EPIC.md
      - {epic_path}/TRACKING.md
      - {epic_path}/stories/*.md
    - docs/epics/CROSS-EPIC.md (updated)
```

### 2. Generer le rapport final

```markdown
# Mission Complete: {mission_name}

## Resume

| Metrique | Valeur |
|----------|--------|
| MISSION.md | ✅ Cree |
| Epics | {count} |
| Stories | {count} |
| Points totaux | {points} |
| Fichiers crees | {count} |

## Fichiers Generes

### MISSION.md
- `{mission_file_path}`

### Epics
{for each epic}
- `{epic_path}/`
  - EPIC-{id}.md
  - TRACKING.md
  - stories/ ({story_count} stories)
{/for}

### CROSS-EPIC.md
- `docs/epics/CROSS-EPIC.md` (updated)

## Plan d'Execution Recommande

### Phase 1
- {epics in phase 1}

### Phase 2
- {epics in phase 2}

...

## Prochaines Etapes

1. **Reviser les Stories** - Affiner les criteres Gherkin si besoin
2. **Lancer le dev** - `/launch-epic EPIC-XX` ou `/dev-story STORY-XX-01`
3. **Tracker le progress** - Mettre a jour TRACKING.md

## Risques a Surveiller

{top 3 risks from mission_document}
```

### 3. Proposer sync/documentation

**Intelligent Finalization Pattern**:

```yaml
AskUserQuestion:
  question: "Mission terminee. Actions supplementaires ?"
  header: "Finalisation"
  options:
    - label: "Sync + Doc (Recommande)"
      description: "Synchroniser refs et documenter la session"
    - label: "Sync uniquement"
      description: "Mettre a jour INDEX, README, CLAUDE.md"
    - label: "Terminer"
      description: "Finir sans actions supplementaires"
```

**Si Sync + Doc ou Sync:**
```yaml
actions:
  - Execute /sync-project --silent
  - If Doc: Execute /documentation --auto
```

### 4. Message de cloture

```markdown
---

## Mission Terminee

**{mission_name}** prete pour implementation.

- {epic_count} Epics structures
- {story_count} Stories INVEST
- {points} points estimes

**Commencer par:** `/launch-epic EPIC-{first_epic_id}` ou `/dev-story STORY-{first_story_id}`

---
```

---

## OUTPUT

```yaml
step_output:
  final_report: "..."
  statistics:
    mission_path: "..."
    epics_created: N
    stories_created: M
    total_points: P
    files_created: F
  user_choice: "sync+doc" | "sync" | "done"
  sync_executed: true | false
  doc_executed: true | false
```

---

## AUTO-VALIDATION

**Before completing, verify:**
- [ ] Report includes all statistics
- [ ] All files accounted for
- [ ] Next steps are clear
- [ ] User choice captured

---

## SUCCESS

✅ Workflow complete
✅ Mission + Epics + Stories created
✅ User informed of next steps

---

## WORKFLOW COMPLETE

Le workflow `/mission` est termine.

**Output final:**
- `{mission_file_path}` - Document de mission
- `docs/epics/EPIC-XX-*/` - Dossiers Epic avec Stories
- `docs/epics/CROSS-EPIC.md` - Dependencies mises a jour

**Pour continuer:**
- `/launch-epic EPIC-XX` - Lancer implementation d'un Epic
- `/dev-story STORY-XX-YY` - Implementer une Story specifique
- `/create-story EPIC-XX` - Regenerer Stories si besoin
