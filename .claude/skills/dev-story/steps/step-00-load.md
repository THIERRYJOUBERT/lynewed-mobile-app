---
name: step-00-load
description: "Charger la story et valider les prerequis"
prev_step: null
next_step: steps/step-01-explore.md
---

# Step 00: Load Story

## MANDATORY EXECUTION RULES (READ FIRST)

- 🛑 NEVER proceed without loading the story file
- 🛑 NEVER assume story content without reading it
- 🛑 NEVER proceed if story has unmet dependencies
- 🛑 NEVER use AskUserQuestion after this step in AUTO mode
- ✅ ALWAYS parse story ID from CLI arguments
- ✅ ALWAYS read and parse the full story file
- ✅ ALWAYS extract acceptance criteria (Gherkin)
- ✅ ALWAYS detect mode from argument flags (--auto or default supervised)
- ✅ ALWAYS validate prerequisites before proceeding
- 📋 YOU ARE a Story Analyst preparing for implementation
- 💬 FOCUS on understanding what needs to be built from the story
- 🚫 FORBIDDEN: Coding anything in this step - loading only

## EXECUTION PROTOCOLS

- 🎯 **Goal**: Load story and extract implementation requirements
- 💾 **Output**: {story_id}, {mode}, {story_path}, {story_content}, {epic_path}
- 📖 **Reference**: Pattern #7 (Single User Interaction)
- ⚡ **Performance**: Single user interaction if clarification needed

## CONTEXT BOUNDARIES

**Available from previous steps:**
- None (this is the first step)
- `$ARGUMENTS` - CLI argument passed to /dev-story

**Produced by this step:**
- `{story_id}` - Story identifier (e.g., STORY-01-01)
- `{mode}` - auto or supervised (default: supervised)
- `{story_path}` - Full path to story file
- `{story_content}` - Parsed story with all sections
- `{epic_path}` - Path to parent Epic folder

**NOT available (do not use):**
- `{patterns_found}` - Produced in step-01
- `{implementation_plan}` - Produced in step-02
- `{code_written}` - Produced in step-03

## YOUR TASK

Parse CLI argument to find story, load the file, extract criteria, and validate prerequisites.

---

## EXECUTION SEQUENCE

### 1. Parse CLI Argument

Extract story ID and mode flag from `$ARGUMENTS`.

**Input**: `$ARGUMENTS` (e.g., "STORY-01-03 --auto")

**Parsing logic:**
```
if contains "--auto":
    mode = auto
    story_id = ARGUMENTS without "--auto"
else if contains "--mode=auto":
    mode = auto
    story_id = ARGUMENTS without "--mode=auto"
else:
    mode = supervised (default)
    story_id = ARGUMENTS
```

**Story ID formats accepted:**
- `STORY-01-03` - Full format
- `01-03` - Short format (assume STORY- prefix)
- `3` - Number only (search in current epic)

**Output**: `{story_id}` (normalized), `{mode}`

### 2. Locate Story File

Find the story file in the project.

**Search paths:**
1. `docs/epics/EPIC-*/stories/STORY-{id}.md` - Standard location
2. `docs/epics/EPIC-*/stories/{id}.md` - Alternate naming
3. Search by ID pattern in all stories

**Using Glob:**
```bash
# Pattern to search
docs/epics/*/stories/*{story_id}*.md
```

**If story not found:**
```yaml
AskUserQuestion:
  question: "Story '{story_id}' non trouvee. Quelle story veux-tu implementer ?"
  header: "Story"
  options:
    - label: "[Liste stories disponibles]"
      description: "Afficher toutes les stories disponibles"
    - label: "Specifier un chemin"
      description: "Donner le chemin complet du fichier"
```

**Output**: `{story_path}`, `{epic_path}`

### 3. Read Story File

Load and parse the complete story content.

**Read the file and extract:**
```yaml
story_content:
  title: "Story title"
  status: "To Do | In Progress | Done"
  priority: "P0 | P1 | P2"

  acceptance_criteria:
    - id: AC1
      description: "Given... When... Then..."
      gherkin: true
    - id: AC2
      description: "..."

  files_to_create:
    - path: "lib/..."
      purpose: "..."

  files_to_modify:
    - path: "lib/..."
      purpose: "..."

  tests_required:
    - path: "test/..."
      covers: ["AC1", "AC2"]

  dependencies:
    - story_id: "STORY-01-02"
      status: "Done" | "Not Done"

  notes: "..."
```

**Output**: `{story_content}`

### 4. Validate Prerequisites

Check that story is ready for implementation.

**Validation checks:**

| Check | Condition | Action if Failed |
|-------|-----------|------------------|
| Story exists | File found | Ask user for path |
| Status | Not "Done" | Warn if already done, ask to proceed |
| Dependencies | All dependencies "Done" | Warn, ask to proceed or abort |
| Criteria present | At least 1 AC | Error: story not ready |

**If status = "Done":**
```yaml
AskUserQuestion:
  question: "Cette story est deja marquee 'Done'. Veux-tu la re-implementer ?"
  header: "Attention"
  options:
    - label: "Oui, re-implementer"
      description: "Recommencer l'implementation"
    - label: "Non, annuler"
      description: "Choisir une autre story"
```

**If dependencies not done:**
```yaml
AskUserQuestion:
  question: "Cette story depend de {dependency} qui n'est pas terminee. Continuer ?"
  header: "Dependance"
  options:
    - label: "Continuer quand meme"
      description: "Implementer sans la dependance (risque)"
    - label: "Implementer la dependance d'abord"
      description: "Lancer /dev-story sur {dependency}"
    - label: "Annuler"
      description: "Choisir une autre story"
```

### 5. Extract Implementation Scope

Summarize what needs to be implemented.

**Create scope summary:**
```yaml
implementation_scope:
  total_criteria: N
  criteria_list:
    - id: AC1
      summary: "Brief description"
    - id: AC2
      summary: "..."

  files_to_touch:
    create: [list]
    modify: [list]

  tests_needed: N

  estimated_complexity: S | M | L
```

**Complexity estimation:**
| Factor | S (Simple) | M (Medium) | L (Large) |
|--------|------------|------------|-----------|
| Criteria | 1-2 | 3-4 | 5+ |
| Files | 1-3 | 4-6 | 7+ |
| Dependencies | 0 | 1-2 | 3+ |

### 6. Present Story Summary

Display what will be implemented.

**Format:**
```markdown
## Story Chargee: {story_id}

### Titre
{title}

### Criteres d'Acceptation
| # | Description | Gherkin |
|---|-------------|---------|
| AC1 | Given... When... Then... | ✓ |
| AC2 | ... | ✓ |

### Fichiers Concernes
**A creer:** {list}
**A modifier:** {list}

### Tests Requis
{count} fichiers de test

### Complexite Estimee
{S | M | L}

### Mode
{SUPERVISED | AUTO}
```

---

## AUTO-VALIDATION (APEX SELF-CRITIQUE)

**Before proceeding to next step, validate:**

✅ `{story_id}` is normalized and valid
✅ `{mode}` is explicitly set (auto or supervised)
✅ `{story_path}` points to existing file
✅ `{story_content}` has at least 1 acceptance criterion
✅ All dependencies are "Done" (or user accepted risk)
✅ Story status is not "Done" (or user confirmed re-implementation)
✅ Implementation scope is clear

**Self-Critique Questions:**
- Did I read the FULL story file, not just the title?
- Are all acceptance criteria extracted with Gherkin format?
- Did I check ALL dependencies, not just the first one?
- Is the complexity estimation reasonable?

**If validation fails:**
1. If story not found: Ask user for clarification
2. If criteria missing: Error - story not ready for implementation
3. If dependencies unmet: Ask user to decide
4. Max 1 round of clarification, then proceed with best interpretation

---

## SUCCESS METRICS

✅ Story file loaded completely
✅ All acceptance criteria extracted
✅ Files to create/modify identified
✅ Dependencies validated (or risk accepted)
✅ Mode determined (supervised/auto)
✅ Summary presented to user
✅ Ready for context exploration

## FAILURE MODES

❌ No argument provided → Fallback: List available stories, ask user
❌ Story ID not found → Fallback: Search by pattern, show matches
❌ Story file empty → Error: Story not ready for implementation
❌ No acceptance criteria → Error: Cannot implement without criteria
❌ All dependencies blocked → Suggest implementing dependencies first

## NEXT STEP

After validation passes, load `steps/step-01-explore.md`

<critical>
This is the ONLY step with AskUserQuestion (unless mode=supervised has checkpoint in step-02).
In AUTO mode: After this step, ZERO user interaction until completion.
In SUPERVISED mode: One checkpoint at step-02 (plan validation), that's it.
Story file is the SOURCE OF TRUTH for what to implement.
Capture EVERYTHING from the story NOW.
</critical>
