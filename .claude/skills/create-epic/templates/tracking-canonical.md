# TRACKING - {{EPIC_ID}}

> Status : 🔵 Draft | 🟡 In Progress | 🟢 Done
> Stories : 0/{{STORIES_COUNT}} completees
> Derniere MAJ : {{DATE}}

---

## Timeline

| Date | Evenement |
|------|-----------|
| {{DATE}} | Epic cree avec /create-epic |
| - | - |

---

## Progression Stories

| Story | Status | Assignee | Date Start | Date Done | Points |
|-------|--------|----------|------------|-----------|--------|
{{#each STORIES}}
| {{this.id}} | 🔵 Todo | - | - | - | {{this.points}} |
{{/each}}

**Total**: {{TOTAL_POINTS}} points

---

## Story Dependencies

### Dependency Graph

```mermaid
graph TD
    subgraph Phase1[Phase 1 - Foundation]
        {{#each PHASE1_STORIES}}
        S{{this.num}}[{{this.id}}<br/>"{{this.title}}"]
        {{/each}}
    end
    subgraph Phase2[Phase 2 - Core]
        {{#each PHASE2_STORIES}}
        S{{this.num}}[{{this.id}}<br/>"{{this.title}}"]
        {{/each}}
    end
    %% Dependencies
    {{#each DEPENDENCIES}}
    S{{this.from}} --> S{{this.to}}
    {{/each}}
```

### Execution Order

| Order | Story | Depends On | Rationale |
|-------|-------|------------|-----------|
{{#each STORIES_ORDERED}}
| {{@index}} | {{this.id}} | {{this.depends_on}} | {{this.rationale}} |
{{/each}}

---

## File Conflicts

{{#if FILE_CONFLICTS}}
⚠️ The following files are modified by multiple stories:

| File | Stories | Conflict Type | Resolution |
|------|---------|---------------|------------|
{{#each FILE_CONFLICTS}}
| {{this.file}} | {{this.stories}} | {{this.type}} | {{this.resolution}} |
{{/each}}

**Recommended**: Execute conflicting stories sequentially.
{{else}}
✅ No file conflicts detected.
{{/if}}

---

## Problemes Rencontres

| Date | Probleme | Resolution | Status |
|------|----------|------------|--------|
| - | *Aucun pour l'instant* | - | - |

---

## Decisions Techniques

| Date | Decision | Contexte | Impact |
|------|----------|----------|--------|
| {{DATE}} | *Decisions documentees pendant l'implementation* | - | - |

---

## Ce qui reste pour 100%

{{#each DOMAIN_GROUPS}}
### {{this.domain}} (Stories {{this.story_ids}})

{{#each this.checklist}}
- [ ] {{this}}
{{/each}}

{{/each}}

### TEST (Transversal)

- [ ] Tests unitaires pour chaque story
- [ ] Tests integration
- [ ] {{LINT_CMD}}nfos passe

---

## Metriques

| Metrique | Valeur |
|----------|--------|
| Stories totales | {{STORIES_COUNT}} |
| Stories completees | 0 |
| Points totaux | {{TOTAL_POINTS}} |
| Points completes | 0 |
| Fichiers crees | - |
| Fichiers modifies | - |
| Tests ajoutes | - |

---

## Retrospective

### Ce qui a bien marche

- *A completer en fin d'Epic*

### A ameliorer

- *A completer en fin d'Epic*

### Lecons apprises

- *A completer en fin d'Epic*

---

## Status Updates Log

| Date | Event | By |
|------|-------|-----|
| {{DATE}} | Epic created | /create-epic |

<!--
CANONICAL FORMAT v1.0
Updated by workflows:
- /create-epic: Creates initial file
- /create-story: Adds stories to table + dependencies
- /dev-story: Updates story status to Done + metrics
- /launch-epic: Updates Epic status + retrospective + completion

IMPORTANT: This format must be maintained across all workflows.
-->
