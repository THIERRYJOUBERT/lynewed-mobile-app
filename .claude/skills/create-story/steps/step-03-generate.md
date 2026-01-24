# Step 03: Generate Story Files

> Purpose: Create story files from approved stories using the template.

---

## MANDATORY RULES (READ FIRST)

- 📄 USE templates/story-template.md for every story
- 📁 CREATE files in docs/epics/{epic_id}/stories/
- 🔢 FOLLOW naming convention STORY-XX-YY.md
- ✅ INCLUDE all required sections

## PROTOCOLS

- 🎯 **Goal**: All approved stories as .md files
- 💾 **Output**: `{stories_created}` list of created files
- 📖 **Reference**: templates/story-template.md (JIT load)
- ⚡ **Performance**: Batch creation for efficiency

---

## CONTEXT

**Available from previous steps:**
- `{epic_id}` - Epic identifier (from step-00)
- `{epic_path}` - Path to Epic file (from step-00)
- `{approved_stories}` - User-validated stories (from step-02)
- `{file_conflicts}` - Detected conflicts (from step-02)

**Produced by this step:**
- `{stories_created}` - List of created story files
- `{generation_errors}` - Any errors during creation

**NOT available (do not use):**
- N/A - This is generation step

---

## TASK

Generate .md files for all approved stories.

---

## EXECUTION

### 1. JIT Load Template

Read the story template:

```
Read .claude/skills/create-story/templates/story-template.md
```

Store template for use in generation.

### 2. Create Stories Directory (if needed)

Ensure the stories directory exists:

```
docs/epics/{epic_id}-{epic_name}/stories/
```

If it doesn't exist, create it.

### 3. Generate Each Story File

For each story in `{approved_stories}`:

**File path:**
```
docs/epics/{epic_id}-{epic_name}/stories/{story_id}.md
```

**Content generation:**
1. Fill template placeholders with story data
2. Format Gherkin criteria properly
3. Include all technical tasks
4. List files to create/modify
5. Document dependencies

**Template variable mapping:**
```yaml
{{STORY_ID}}: story.id
{{EPIC_ID}}: {epic_id}
{{TITLE}}: story.title
{{POINTS}}: story.points
{{STATUS}}: "A faire"
{{PERSONA}}: story.persona
{{ACTION}}: story.action
{{BENEFIT}}: story.benefit
{{ACCEPTANCE_CRITERIA}}: story.acceptance_criteria (formatted)
{{TECHNICAL_TASKS}}: story.technical_tasks (formatted)
{{FILES_TO_CREATE}}: story.files_to_modify (filtered CREATE)
{{FILES_TO_MODIFY}}: story.files_to_modify (filtered MODIFY)
{{DEPENDENCIES}}: story.dependencies (formatted)
{{TESTS}}: story.files_to_test (formatted)
```

### 4. Write Files

For each story:

```
Write docs/epics/{epic_id}-{name}/stories/{story_id}.md
```

Track in `{stories_created}`:

```yaml
stories_created:
  - id: "STORY-XX-01"
    path: "docs/epics/EPIC-XX-NAME/stories/STORY-XX-01.md"
    status: "created"

  - id: "STORY-XX-02"
    path: "docs/epics/EPIC-XX-NAME/stories/STORY-XX-02.md"
    status: "created"
```

### 5. Handle Errors

If file creation fails:

```yaml
generation_errors:
  - story_id: "STORY-XX-03"
    error: "Permission denied"
    fallback: "Manual creation needed"
```

**Self-healing:**
1. Retry with different approach
2. Check directory permissions
3. Verify path correctness
4. Max 3 attempts per file

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ All approved stories have files created
✅ Files are in correct directory structure
✅ Each file contains all required sections
✅ Gherkin criteria are properly formatted
✅ No placeholder text remaining ({{...}})

**Self-Critique Questions:**
- Did I create files for ALL approved stories?
- Are the file paths correct?
- Is the Gherkin syntax valid?
- Are technical tasks specific enough?
- Did any files fail to create?

**If validation fails:**
1. Identify missing/failed files
2. Retry creation with error handling
3. If persistent: note error and continue with successful files

---

## SUCCESS / FAILURE

**Success:**
✅ All story files created
✅ Files in correct location
✅ No generation errors
✅ Ready for final validation

**Failure modes:**
❌ Directory creation fails → Check permissions, escalate
❌ File write fails → Retry, then note error
❌ Template not found → Use inline fallback template
❌ Some stories fail → Continue with successful, report failures

## NEXT

After validation passes, load `steps/step-04-validate.md`

<critical>
If some stories fail to generate, CONTINUE with successful ones.
Document failures in {generation_errors}.
Do NOT stop entire workflow for partial failures.
User can retry failed stories manually.
</critical>
