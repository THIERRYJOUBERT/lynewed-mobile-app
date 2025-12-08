---
description: Update project documentation after completing work
---

# 📝 UPDATE DOCS AFTER WORK

## Purpose
Keep project documentation up-to-date by recording progress, decisions, and discoveries. Run this command **multiple times** during a conversation to avoid losing track of work done.

---

## Workflow Steps

### STEP 1: Identify What Changed
Analyze the current conversation to identify:
- Tasks completed
- Bugs fixed
- Decisions made
- New discoveries (patterns, gotchas, etc.)
- Files created/modified/deleted

### STEP 2: Determine Which Docs Need Updates
Based on context, identify relevant documents:

| Document | Update When... |
|----------|----------------|
| `docs/PROJECT.md` | Project state changes, modules completed, metrics updated |
| `docs/PROJECT_TODO.md` | Tasks completed, new tasks identified, priorities changed |
| `docs/REFACTORING_REPORT_MVP_TO_V1.md` | Major milestones, significant changes |
| `lib/features/[module]/README.md` | Module-specific changes |

### STEP 3: Read Current State
Read each identified document to understand current content before updating.

### STEP 4: Apply Updates
For each document, apply **minimal, precise updates**:

**DO:**
- Add concise bullet points for completed work
- Update status markers (⏳ → ✅)
- Add dates to completed items
- Record key decisions with brief rationale
- Note discovered gotchas or patterns

**DON'T:**
- Rewrite entire sections
- Add verbose explanations
- Duplicate information across documents
- Add speculative or uncertain information

---

## Update Patterns

### Completed Task
```markdown
## Before
- [ ] Implement feature X

## After  
- [x] Implement feature X ✅ (2025-12-08)
```

### New Discovery
```markdown
## Before
[section content]

## After
[section content]

**Note (2025-12-08):** [Brief discovery description]
```

### Bug Fix
```markdown
## Before
[no mention]

## After
### Bug Fixes
- **[Bug name]** - [One-line description of fix] (2025-12-08)
```

### Decision Made
```markdown
## Before
- [ ] Decide on approach for X

## After
- [x] Decide on approach for X → **Chose [option]** because [brief reason] (2025-12-08)
```

---

## Output Format

After updating docs, provide a summary:

```
📝 Documentation Updated:

**docs/PROJECT.md:**
- Updated [section] with [change]

**docs/PROJECT_TODO.md:**
- Marked [task] as complete
- Added [new task]

**[other file]:**
- [change description]
```

---

## Example Usage

### Scenario 1: After fixing a bug
User: `/update-docs-after-work`
