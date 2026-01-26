# {{EPIC_ID}}-{{EPIC_NAME}}

> **Resume** : {{OBJECTIVE}}
> **Status** : 📋 {{STATUS}}
> **Domaine** : {{DOMAIN}}
> **Points estimes** : {{ESTIMATED_POINTS}}
> **Cree le** : {{DATE}}

---

## Contexte

### Pourquoi cet Epic

{{WHY_CONTEXT}}

### Source Mission

Cet Epic fait partie de la mission : `{{MISSION_REF}}`

---

## Scope

### Inclus

{{SCOPE}}

### Requirements source

{{SOURCE_REQUIREMENTS}}

---

## Stories

| # | Story | Domaine | Points | Status | Dependances |
|---|-------|---------|--------|--------|-------------|
{{STORIES_TABLE}}

**Total** : {{TOTAL_STORIES}} stories, {{TOTAL_POINTS}} points

---

## Dependances

### Bloque

{{BLOCKS}}

### Bloque par

{{BLOCKED_BY}}

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
{{RISKS}}

---

## Criteres de Completion

- [ ] Toutes les Stories completees
- [ ] Tests passants
- [ ] 0 warnings (`{{LINT_CMD}}`)
- [ ] Documentation a jour
- [ ] Review effectuee

---

## References

### Mission

- [{{MISSION_REF}}](../../specs/{{MISSION_FILE}})

### FDs (si applicable)

{{FD_REFERENCES}}

---

## Prochaine Etape

→ `/create-story {{EPIC_ID}}` pour decomposer en Stories (si pas deja fait)
→ `/dev-story STORY-{{EPIC_NUMBER}}-01` pour commencer l'implementation
