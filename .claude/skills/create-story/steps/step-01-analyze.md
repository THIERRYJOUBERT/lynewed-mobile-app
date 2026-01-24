# Step 01: Analyze Epic Content

> Purpose: Read and understand Epic content to prepare for story decomposition.

---

## MANDATORY RULES (READ FIRST)

- 📖 READ the entire Epic file
- 🎯 EXTRACT scope, objectives, and features
- 📋 IDENTIFY existing stories (if any)
- 🔗 NOTE dependencies and constraints

## PROTOCOLS

- 🎯 **Goal**: Complete understanding of Epic scope for decomposition
- 💾 **Output**: `{epic_content}` with structured analysis
- 📖 **Reference**: Epic file and related FDs if mentioned
- ⚡ **Performance**: Thorough reading prevents rework

---

## CONTEXT

**Available from previous steps:**
- `{epic_id}` - Epic identifier (from step-00)
- `{epic_path}` - Path to Epic file (from step-00)

**Produced by this step:**
- `{epic_content}` - Parsed Epic content
- `{existing_stories}` - Already created stories (if any)
- `{features_to_decompose}` - Features needing stories

**NOT available (do not use):**
- `{proposed_stories}` - Created in step-02
- `{approved_stories}` - Created in step-02

---

## TASK

Read the Epic file and extract all information needed to create INVEST stories.

---

## EXECUTION

### 1. Read Epic File

```
Read {epic_path}
```

Store the full content for reference.

### 2. Extract Key Information

Parse and structure the Epic content:

```yaml
epic_content:
  id: "{epic_id}"
  title: "..."
  status: "..."

  objective: |
    What this Epic aims to achieve

  scope:
    in_scope:
      - Feature 1
      - Feature 2
    out_of_scope:
      - Not included 1
      - Not included 2

  dependencies:
    - External dependencies
    - Other Epics

  constraints:
    - Technical constraints
    - Business constraints

  acceptance_criteria:
    - Epic-level acceptance criteria

  referenced_fds:
    - FD-01
    - FD-02
```

### 3. Check Existing Stories

Look for already created stories:

```
Glob docs/epics/{epic_id}-*/stories/STORY-*.md
```

**If stories exist:**
```yaml
existing_stories:
  - id: "STORY-XX-01"
    status: "..."
    summary: "..."
  - id: "STORY-XX-02"
    status: "..."
    summary: "..."
```

**Consider:**
- Are these stories still valid?
- What features still need stories?
- Are there gaps in coverage?

### 4. Identify Features Needing Stories

Based on scope and existing stories:

```yaml
features_to_decompose:
  - feature: "Feature A"
    description: "..."
    has_story: false
    complexity_hint: "S|M|L"

  - feature: "Feature B"
    description: "..."
    has_story: true
    story_id: "STORY-XX-01"

  - feature: "Feature C"
    description: "..."
    has_story: false
    complexity_hint: "M"
```

### 5. Read Related FDs (if referenced)

If Epic references FDs, read them for additional context:

```
FOR each FD in referenced_fds:
    Read docs/specs/FD-{id}.md
    Extract relevant requirements
```

This ensures stories align with foundation documents.

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ Epic file fully read and parsed
✅ Scope is clear (in/out of scope identified)
✅ Features needing stories identified
✅ Existing stories noted (if any)
✅ Dependencies and constraints captured

**Self-Critique Questions:**
- Did I read the ENTIRE Epic, or just skim?
- Are there any ambiguous features that need clarification?
- Do I understand WHY each feature is needed?
- Are the complexity hints reasonable?

**If validation fails:**
1. Re-read sections that were unclear
2. Note specific questions for user clarification
3. If Epic is fundamentally unclear: escalate to user

---

## SUCCESS / FAILURE

**Success:**
✅ `{epic_content}` fully populated
✅ `{features_to_decompose}` identified
✅ Ready to propose story decomposition

**Failure modes:**
❌ Epic file empty → Report error, stop workflow
❌ Scope unclear → Document gaps, ask user in step-02
❌ Referenced FDs missing → Note gap, proceed with Epic info
❌ Epic too vague → Collect questions, ask user before proposing

## NEXT

After validation passes, load `steps/step-02-propose.md`

<critical>
Do NOT propose stories without understanding the Epic.
If scope is unclear, document questions to ask in step-02.
The quality of stories depends on understanding the Epic.
</critical>
