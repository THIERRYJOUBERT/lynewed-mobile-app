# Step 06: Generate Epics

> Purpose: Creer les dossiers Epic avec fichiers EPIC.md et TRACKING.md.

---

## MANDATORY RULES

- 🎯 ALWAYS verifier les IDs existants avant creation
- 📊 ALWAYS creer EPIC.md + TRACKING.md pour chaque Epic
- ✅ ALWAYS mettre a jour CROSS-EPIC.md
- 🚫 NEVER ecraser des Epics existants

## PROTOCOLS

- 🎯 **Goal**: Creer tous les dossiers Epic
- 💾 **Output**: `{generated_epics}` - liste des paths crees
- ⚡ **Performance**: Write multiple files

---

## CONTEXT

**Available from previous steps:**
- `{mission_document}` - Mission avec Epics proposes (step-03)
- `{project_context}` - Avec existing_epics et next_epic_id (step-00)

**Produced by this step:**
- `{generated_epics}` - Array des Epic paths crees

---

## TASK

### 1. Verifier les IDs disponibles

```yaml
id_check:
  existing: {project_context.epic_ids}
  proposed: Extract IDs from mission_document.epics
  conflicts: Find overlaps
  resolution: Increment conflicting IDs
```

### 2. Pour chaque Epic propose

```yaml
for_each_epic:
  epic: mission_document.epics[i]

  # Create folder
  folder_path: "docs/epics/EPIC-{id}-{name}/"
  create: mkdir -p {folder_path}/stories

  # Create EPIC.md from template
  epic_file:
    path: "{folder_path}/EPIC-{id}-{name}.md"
    template: templates/epic-template.md
    placeholders:
      {{EPIC_ID}}: epic.id
      {{EPIC_NAME}}: epic.name
      {{OBJECTIVE}}: epic.objective
      {{DOMAIN}}: epic.domain
      {{STATUS}}: "Draft"
      {{DATE}}: current date
      {{SCOPE}}: formatted scope list
      {{DEPENDENCIES}}: formatted deps
      {{RISKS}}: formatted risks
      {{ESTIMATED_POINTS}}: epic.estimated_points
      {{SOURCE_REQUIREMENTS}}: epic.source_requirements
      {{MISSION_REF}}: mission_file_path

  # Create TRACKING.md from template
  tracking_file:
    path: "{folder_path}/TRACKING.md"
    template: templates/tracking-template.md
    placeholders:
      {{EPIC_ID}}: epic.id
      {{EPIC_NAME}}: epic.name
      {{STATUS}}: "Draft"
      {{STORIES}}: "0/0"
      {{DATE}}: current date
```

### 3. Mettre a jour CROSS-EPIC.md

```yaml
cross_epic_update:
  path: "docs/epics/CROSS-EPIC.md"

  add_dependencies:
    For each epic with dependencies:
      Add row to Dependencies table

  add_new_epics:
    For each created epic:
      Add to Epic Registry table

  update_timeline:
    Add creation event with date
```

### 4. Valider les creations

```yaml
validation:
  For each epic:
    - Check folder exists
    - Check EPIC.md exists and valid
    - Check TRACKING.md exists and valid
    - Check stories/ folder exists
```

---

## OUTPUT

```yaml
step_output:
  generated_epics:
    - path: "docs/epics/EPIC-04-FEATURE-A/"
      id: "EPIC-04"
      name: "EPIC-04-FEATURE-A"
      files:
        - "EPIC-04-FEATURE-A.md"
        - "TRACKING.md"
    - path: "docs/epics/EPIC-05-FEATURE-B/"
      ...

  cross_epic_updated: true
  total_epics_created: {count}
```

---

## AUTO-VALIDATION

**Before proceeding, verify:**
- [ ] All Epic folders created
- [ ] All EPIC.md files valid
- [ ] All TRACKING.md files valid
- [ ] CROSS-EPIC.md updated
- [ ] No ID conflicts

**Self-Critique Questions:**
- Tous les Epics proposes ont-ils ete crees?
- Les IDs sont-ils uniques?
- CROSS-EPIC.md reflete-t-il les nouvelles deps?

---

## SUCCESS / FAILURE

**Success:**
✅ All Epic folders created
✅ All files valid
✅ CROSS-EPIC.md updated

**Failure modes:**
❌ ID conflict → Increment and retry
❌ Write fails → Check permissions
❌ CROSS-EPIC missing → Create it

---

## NEXT

When validation passes, load `steps/step-07-generate-stories.md`
