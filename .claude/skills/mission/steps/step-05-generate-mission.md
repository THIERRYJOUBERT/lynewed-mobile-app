# Step 05: Generate Mission

> Purpose: Ecrire le fichier MISSION.md dans docs/specs/.

---

## MANDATORY RULES

- 🎯 ALWAYS utiliser le template mission-template.md
- 📊 ALWAYS inclure toutes les sections
- ✅ ALWAYS valider le fichier apres ecriture
- 🚫 NEVER generer les Epics ici (step-06)

## PROTOCOLS

- 🎯 **Goal**: Creer le fichier MISSION.md
- 💾 **Output**: `{mission_file_path}`
- ⚡ **Performance**: Write simple

---

## CONTEXT

**Available from previous steps:**
- `{mission_document}` - Mission validee (step-03, approuvee step-04)

**Produced by this step:**
- `{mission_file_path}` - Path du fichier cree

---

## TASK

### 1. Determiner le path

```yaml
path_calculation:
  name_sanitized: lowercase, replace spaces with dashes
  path: "docs/specs/MISSION-{name_sanitized}.md"
```

### 2. Charger le template

Read `templates/mission-template.md`

### 3. Remplir le template

Remplacer tous les placeholders avec les donnees de `{mission_document}`:

```yaml
placeholders:
  {{MISSION_NAME}}: mission_document.metadata.name
  {{DATE}}: current date
  {{OBJECTIVE}}: mission_document.executive_summary.objective
  {{SCOPE}}: mission_document.executive_summary.scope
  {{TIMELINE}}: mission_document.executive_summary.timeline
  {{IN_SCOPE}}: formatted list
  {{OUT_OF_SCOPE}}: formatted list
  {{ASSUMPTIONS}}: formatted list
  {{CONSTRAINTS}}: formatted list
  {{EPICS_TABLE}}: formatted table of epics
  {{EXECUTION_PLAN}}: formatted phases
  {{DEPENDENCIES_GRAPH}}: mermaid diagram
  {{RISKS_TABLE}}: formatted risks
  {{GAPS}}: formatted gaps section
  {{TECHNICAL}}: technical considerations
  {{METRICS}}: success metrics
```

### 4. Ecrire le fichier

```yaml
Write:
  path: docs/specs/MISSION-{name}.md
  content: filled template
```

### 5. Valider l'ecriture

```yaml
validation:
  - Read the file back
  - Check all sections present
  - Verify no {{PLACEHOLDER}} remain
```

---

## OUTPUT

```yaml
step_output:
  mission_file_path: "docs/specs/MISSION-{name}.md"
  validation:
    file_exists: true
    sections_complete: true
    placeholders_remaining: 0
```

---

## AUTO-VALIDATION

**Before proceeding, verify:**
- [ ] File written successfully
- [ ] All sections present
- [ ] No placeholders remaining
- [ ] Markdown is valid

**Self-Critique Questions:**
- Le fichier est-il complet?
- Le format est-il coherent avec les autres docs?
- Les liens internes sont-ils corrects?

---

## SUCCESS / FAILURE

**Success:**
✅ MISSION.md created
✅ All sections present
✅ Ready for Epic generation

**Failure modes:**
❌ Write fails → Check permissions, retry
❌ Template missing → Use inline default
❌ Validation fails → Fix and rewrite

---

## NEXT

When validation passes, load `steps/step-06-generate-epics.md`
