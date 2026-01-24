# TRACKING - {{EPIC_ID}}

> Status : 🔵 Draft | 🟡 In Progress | 🟢 Done
> Stories : 0/{{STORIES_COUNT}} completees
> Derniere MAJ : {{DATE}}

---

## Timeline

| Date | Evenement |
|------|-----------|
| {{DATE}} | Epic cree avec /create-epic v6 |
| - | - |

---

## Progression Stories

| Story | Status | Assignee | Date Start | Date Done |
|-------|--------|----------|------------|-----------|
{{#each STORIES}}
| {{this.id}} | 🔵 Todo | - | - | - |
{{/each}}

---

## Problemes Rencontres

| Date | Probleme | Resolution | Status |
|------|----------|------------|--------|
| - | *Aucun pour l'instant* | - | - |

---

## Decisions Techniques

| Date | Decision | Contexte | Impact |
|------|----------|----------|--------|
| {{DATE}} | *Decisions documentees ici pendant l'implementation* | - | - |

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
- [ ] {{LINT_CMD}} passe

---

## Metriques

| Metrique | Valeur |
|----------|--------|
| Stories totales | {{STORIES_COUNT}} |
| Stories completees | 0 |
| Lignes de code ajoutees | - |
| Tests ajoutes | - |
| Couverture | - |

---

## Retrospective

### Ce qui a bien marche

- *A completer en fin d'Epic*

### A ameliorer

- *A completer en fin d'Epic*

### Lecons apprises

- *A completer en fin d'Epic*
