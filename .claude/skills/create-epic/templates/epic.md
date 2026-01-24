# {{EPIC_ID}}

> Resume : {{EPIC_SUMMARY}}
> Status : 🔵 Draft
> Domaine : {{DOMAIN}}
> Cree le : {{DATE}}

---

## Contexte

### Pourquoi cet Epic

{{WHY_THIS_EPIC}}

### Piliers Techniques Concernes

| Pilier | Implication pour cet Epic |
|--------|---------------------------|
{{TECHNICAL_PILLARS}}

---

## Architecture Cible

{{#if ARCHITECTURE_NEEDED}}
```
{{ARCHITECTURE_DIAGRAM}}
```
{{else}}
> Architecture detaillee disponible dans les specs UI/UX.
> Voir: {{UI_SPECS_REFERENCE}}
{{/if}}

---

## Stories

| # | Story | Domaine | Dep. | Criteres cles | Source FD | Complexite |
|---|-------|---------|------|---------------|-----------|------------|
{{STORIES_TABLE}}

---

## Detail des Stories

{{#each STORIES}}
### {{this.id}} : {{this.name}}

**Criteres cles** :
{{#each this.key_criteria}}
- {{this}}
{{/each}}

**Source** : {{this.source.fd}} {{this.source.sections}}

**Complexite** : {{this.complexity}}

**Details techniques** :
{{#if this.technical_details.tables}}
**Tables** :
{{#each this.technical_details.tables}}
- `{{this.name}}` : {{this.columns}}
{{/each}}
{{/if}}

{{#if this.technical_details.indexes}}
**Indexes** :
{{#each this.technical_details.indexes}}
- {{this}}
{{/each}}
{{/if}}

{{#if this.technical_details.packages}}
**Packages** :
{{#each this.technical_details.packages}}
- {{this}}
{{/each}}
{{/if}}

{{#if this.technical_details.paths}}
**Chemins fichiers** :
{{#each this.technical_details.paths}}
- {{this}}
{{/each}}
{{/if}}

{{#if this.technical_details.pragmas}}
**Pragmas** :
{{#each this.technical_details.pragmas}}
- `{{this}}`
{{/each}}
{{/if}}

{{#if this.technical_details.endpoints}}
**Endpoints** :
{{#each this.technical_details.endpoints}}
- `{{this.method}} {{this.path}}` : {{this.description}}
{{/each}}
{{/if}}

{{#if this.dependencies}}
**Dependances** : {{this.dependencies}}
{{/if}}

---

{{/each}}

## Risques et Mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
{{RISKS_TABLE}}

---

{{#if ADAPTIVE_SECTIONS}}
{{#each ADAPTIVE_SECTIONS}}
## {{this.title}}

{{this.content}}

---

{{/each}}
{{/if}}

{{#if GAPS}}
## Gaps Identifies

| Gap | Source manquante | Impact | Action |
|-----|------------------|--------|--------|
{{GAPS_TABLE}}

---
{{/if}}

## References FD

| FD | Sections utilisees | Contenu principal |
|----|-------------------|-------------------|
{{FD_REFERENCES_TABLE}}

---

## Prochaine Etape

→ `/create-story {{EPIC_ID}}` pour decomposer en stories INVEST
