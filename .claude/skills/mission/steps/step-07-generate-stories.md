# Step 07: Generate Stories

> Purpose: Generer les Stories INVEST pour chaque Epic.

---

## MANDATORY RULES

- 🎯 ALWAYS suivre criteres INVEST pour chaque Story
- 📊 ALWAYS inclure criteres Gherkin
- ✅ ALWAYS estimer en points (1-8, jamais plus)
- 🚫 NEVER creer de Story > 8 points (decomposer)

## PROTOCOLS

- 🎯 **Goal**: Creer toutes les Stories pour chaque Epic
- 💾 **Output**: `{generated_stories}` - stories par Epic
- ⚡ **Performance**: Write multiple files

---

## CONTEXT

**Available from previous steps:**
- `{mission_document}` - Avec details des Epics (step-03)
- `{generated_epics}` - Epics crees (step-06)
- `{analysis_results}` - Avec validation criteria (step-02)

**Produced by this step:**
- `{generated_stories}` - Array des Stories creees par Epic

---

## TASK

### 1. Pour chaque Epic genere

```yaml
for_each_epic:
  epic: generated_epics[i]
  epic_details: mission_document.epics[matching id]

  # Decomposer en Stories
  stories_needed:
    Based on:
      - epic_details.scope (requirements)
      - epic_details.estimated_size
      - analysis_results.validation.criteria_per_feature

  # Estimation guideline
  points_budget:
    S epic: 3-5 stories, total ~8 points
    M epic: 5-8 stories, total ~21 points
    L epic: 8-13 stories, total ~34 points
```

### 2. Decomposition en Stories INVEST

Pour chaque requirement dans l'Epic scope:

```yaml
story_decomposition:
  requirement: "..."

  # Appliquer INVEST
  invest_check:
    I: Can be developed independently?
    N: Details negotiable?
    V: Delivers clear value?
    E: Can be estimated?
    S: 1-8 points max?
    T: Has testable criteria?

  # Si trop gros (>8 points), decomposer
  if_too_large:
    Split by:
      - User action (create, read, update, delete)
      - Component (frontend, backend, data)
      - Scenario (happy path, error cases)
```

### 3. Generer chaque Story

```yaml
for_each_story:
  story:
    id: "STORY-{epic_number}-{story_number}"
    title: "..."

  # Create file from template
  story_file:
    path: "{epic_path}/stories/STORY-{epic_number}-{story_number}.md"
    template: templates/story-template.md
    placeholders:
      {{STORY_ID}}: story.id
      {{STORY_TITLE}}: story.title
      {{STATUS}}: "A faire"
      {{POINTS}}: story.estimated_points
      {{EPIC_REF}}: epic.id

      {{USER_STORY}}:
        En tant que: {persona}
        Je veux: {action}
        Afin de: {benefit}

      {{GHERKIN_CRITERIA}}: |
        ```gherkin
        Scenario: {name}
          Given {context}
          When {action}
          Then {result}
        ```

      {{TECHNICAL_TASKS}}: formatted list
      {{FILES_TO_MODIFY}}: formatted table
      {{DEPENDENCIES}}: formatted deps
      {{TESTS_REQUIRED}}: formatted test list
      {{DEFINITION_OF_DONE}}: standard checklist
```

### 4. Mettre a jour TRACKING.md de chaque Epic

```yaml
tracking_update:
  path: "{epic_path}/TRACKING.md"

  update_stories_table:
    Add row for each story:
      | Story | Status | Points | Dependencies |

  update_stories_count:
    "Stories: 0/{total_created}"

  update_execution_order:
    Order by dependencies
```

### 5. Valider les Stories

```yaml
validation:
  For each story:
    INVEST_check:
      - [ ] Independent: No hard coupling
      - [ ] Negotiable: Details can be refined
      - [ ] Valuable: Clear value delivery
      - [ ] Estimable: Points assigned (1-8)
      - [ ] Small: Not too large (<=8 points)
      - [ ] Testable: Gherkin criteria present

    If fails:
      - Decompose further
      - Max 3 iterations
```

---

## OUTPUT

```yaml
step_output:
  generated_stories:
    - epic_id: "EPIC-04"
      epic_path: "docs/epics/EPIC-04-FEATURE-A/"
      stories:
        - id: "STORY-04-01"
          title: "..."
          points: 3
          path: "docs/epics/EPIC-04-FEATURE-A/stories/STORY-04-01.md"
        - id: "STORY-04-02"
          ...
      total_stories: 5
      total_points: 13

  totals:
    epics_with_stories: {count}
    total_stories: {sum}
    total_points: {sum}
```

---

## AUTO-VALIDATION

**Before proceeding, verify:**
- [ ] All Epics have Stories
- [ ] All Stories pass INVEST
- [ ] All Stories have Gherkin criteria
- [ ] All Stories <= 8 points
- [ ] TRACKING.md updated for each Epic

**Self-Critique Questions:**
- Les Stories couvrent-elles tout le scope de l'Epic?
- Les estimations sont-elles coherentes?
- Les dependencies sont-elles correctes?

---

## SUCCESS / FAILURE

**Success:**
✅ All Stories created
✅ All pass INVEST
✅ All TRACKING.md updated

**Failure modes:**
❌ Story too large → Decompose
❌ Missing Gherkin → Add criteria
❌ Dependency cycle → Break cycle

---

## NEXT

When validation passes, load `steps/step-08-finalize.md`

<critical>
JAMAIS de Story > 8 points.
TOUJOURS des criteres Gherkin.
INVEST n'est pas optionnel.
</critical>
