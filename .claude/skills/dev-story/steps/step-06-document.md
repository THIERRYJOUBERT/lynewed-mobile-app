---
name: step-06-document
description: "Create story documentation folder with implementation notes"
prev_step: steps/step-05-commit.md
next_step: null
---

# Step 06: Create Story Documentation

## MANDATORY EXECUTION RULES (READ FIRST)

- 🛑 NEVER skip this step - documentation is required
- 🛑 NEVER use AskUserQuestion in AUTO mode
- ✅ ALWAYS create story folder if not exists
- ✅ ALWAYS create implementation.md with real data
- ✅ ALWAYS use actual file paths, commit hash, decisions
- 📋 This step documents the implementation for future reference

## EXECUTION PROTOCOLS

- 🎯 **Goal**: Create story docs folder with implementation.md
- 💾 **Output**: `{story_folder}/implementation.md`
- 📖 **Reference**: Story implementation details from step-03, 04, 05
- ⚡ **Performance**: Single file creation, use real data

## CONTEXT BOUNDARIES

**Available from previous steps:**
- `{story_id}` - Story identifier (from step-00)
- `{mode}` - auto or supervised (from step-00)
- `{story_path}` - Path to story file (from step-00)
- `{epic_path}` - Path to Epic folder (from step-00)
- `{story_content}` - Story details (from step-00)
- `{code_written}` - Files created/modified (from step-03)
- `{tests_written}` - Test files created (from step-03)
- `{implementation_plan}` - TDD plan (from step-02)
- `{review_results}` - Review outcomes (from step-03)
- `{commit_hash}` - Commit hash (from step-05)

**Produced by this step:**
- `{story_folder}` - Path to story docs folder
- `{implementation_doc}` - Path to implementation.md

**NOT available (do not use):**
- All needed variables are available

## YOUR TASK

Create the story documentation folder and write implementation.md with actual implementation details.

---

## EXECUTION SEQUENCE

### 1. Determine Story Folder Path

Calculate the story documentation folder path:

```yaml
# Story file: docs/epics/EPIC-01/stories/STORY-01-03.md
# Story folder: docs/epics/EPIC-01/stories/STORY-01-03/

{story_folder}: "{epic_path}/stories/{story_id}/"
```

Example:
- Story path: `docs/epics/EPIC-01-Foundation/stories/STORY-01-03.md`
- Story folder: `docs/epics/EPIC-01-Foundation/stories/STORY-01-03/`

### 2. Create Story Folder

Create the folder if it doesn't exist:

```bash
mkdir -p {story_folder}
```

### 3. Generate implementation.md Content

**Use ACTUAL data from previous steps - no placeholders!**

```markdown
# Implementation Notes - {story_id}

> Completed: {current_date YYYY-MM-DD}
> Commit: {commit_hash}
> Mode: {mode}

## Summary

{Extract from story_content.description - what this story accomplished}

## Files Changed

### Created
{For each file in code_written where action == "create"}
- `{file_path}`: {brief purpose from implementation_plan or infer from name}

### Modified
{For each file in code_written where action == "modify"}
- `{file_path}`: {what was changed}

## Technical Decisions

| Decision | Rationale |
|----------|-----------|
{Extract from implementation_plan.decisions or review_results.notes}
{If none, write: | Standard implementation | Following existing patterns |}

## Acceptance Criteria Status

{For each criterion in story_content.acceptance_criteria}
- [x] {criterion.id}: {criterion.description}

## Tests

{For each test in tests_written}
- `{test_path}`: {what is tested}

## Challenges

{Extract from review_results if any issues were found and resolved}
{If none: "No significant challenges encountered."}

## Notes for Future

{Any relevant notes:
- Dependencies or assumptions
- Things to consider for related stories
- Potential improvements identified during review}
```

### 4. Write implementation.md

Use Write tool to create the file:

```yaml
file_path: "{story_folder}/implementation.md"
content: {generated content above}
```

### 5. Verify File Created

Confirm the file exists:

```bash
ls {story_folder}/
```

Expected output should include `implementation.md`.

### 6. Update Story File (Optional)

Add reference to documentation in the story file:

```markdown
## Documentation

- Implementation notes: `stories/{story_id}/implementation.md`
```

### 7. Generate Summary

Prepare step summary:

```markdown
## Story Documentation Created

**Story**: {story_id}
**Folder**: `{story_folder}`

### Files Created
- `implementation.md` - Implementation notes and decisions

### Content
- Summary of implementation
- {count} files documented
- {count} technical decisions
- {count} tests documented

### Next Step
Proceed to Step 07 (Finalization) for sync.
```

---

## AUTO-VALIDATION

**Before completing, validate:**

✅ Story folder exists at `{story_folder}`
✅ `implementation.md` created with:
   - [ ] Real commit hash (not placeholder)
   - [ ] Real file paths from {code_written}
   - [ ] Real test paths from {tests_written}
   - [ ] Actual date
✅ All acceptance criteria marked as completed
✅ Summary prepared

**Self-Critique Questions:**
- Did I use ACTUAL data, not placeholders?
- Is the implementation.md useful for future reference?
- Would someone understand what was done from reading it?
- Did I capture important decisions?

**If validation fails:**
1. If folder not created: Retry mkdir
2. If file not written: Retry Write
3. If data missing: Document what's available, note gaps

---

## SUCCESS / FAILURE

**Success:**
✅ Story folder created
✅ implementation.md written with real data
✅ Summary displayed

**Failure modes:**
❌ Cannot create folder → Try alternative path, warn user
❌ Cannot write file → Log error, continue to finalization
❌ Missing data → Document what's available with notes

## PROCEED TO FINALIZATION

After this step, proceed to inline Step 07 (Finalization):

**IF mode = SUPERVISED:**
- Use AskUserQuestion to propose sync

**IF mode = AUTO:**
- Execute /sync-project --silent automatically
- Display final workflow summary

<critical>
This step creates documentation that helps future developers understand what was done.
Use REAL data from previous steps - the documentation should be accurate and useful.
Story documentation is now part of the standard workflow output.
</critical>
