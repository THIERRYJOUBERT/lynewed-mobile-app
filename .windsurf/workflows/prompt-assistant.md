---
description: Generate a master prompt for a new AI assistant conversation
---

# 🎯 PROMPT ASSISTANT - Generate Continuation Prompt

## Purpose
When the current conversation becomes too long or context-heavy, generate a **master prompt** for a fresh AI assistant conversation. This ensures the new assistant starts with clear context, specific expertise, and actionable instructions.

---

## Workflow Steps

### STEP 1: Analyze Current Context
Read and understand:
1. What work has been done in this conversation
2. What tasks are in progress or pending
3. What decisions have been made
4. What files/modules are involved

### STEP 2: Read Project Documentation
```
docs/PROJECT.md          # Current project state
docs/PROJECT_TODO.md     # Pending tasks
```

### STEP 3: Generate Master Prompt
Create a new file in `docs/prompts/` with naming convention:
```
docs/prompts/YYYY-MM-DD_[task-name].md
```

---

## Master Prompt Template

The generated prompt MUST follow this structure:

```markdown
# 🎯 MISSION: [Clear Task Title]

## 👤 ASSISTANT SPECIALTY
You are a **[specific role]** expert in:
- [Skill 1]
- [Skill 2]
- [Skill 3]

Your approach: [Brief methodology description]

---

## 📚 CONTEXT

### Project State
- **App:** LYNEWED - Wedding professionals marketplace
- **Version:** [current version]
- **Branch:** develop
- **Supabase Project ID:** hekyovgnovhfhmkpfrna (DEV)

### Current Situation
[2-3 sentences describing where we are]

### What Has Been Done
- [Completed item 1]
- [Completed item 2]

### What Remains
- [Pending item 1]
- [Pending item 2]

---

## 📁 KEY FILES TO READ FIRST

**MANDATORY - Read before any action:**
1. `docs/PROJECT.md` - Project state
2. `docs/PROJECT_TODO.md` - Task list
3. [Specific file relevant to task]
4. [Another specific file]

**Module code (if applicable):**
- `lib/features/[module]/` - [Description]

---

## 🎯 TASKS TO COMPLETE

### Task 1: [Title]
**Priority:** 🔴 HIGH / 🟡 MEDIUM / 🟢 LOW
**Estimated:** [X hours]

**Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Acceptance criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]

### Task 2: [Title]
[Same structure...]

---

## ⚠️ CRITICAL RULES

1. **Option B ALWAYS** - Never reuse FlutterFlow components
2. **Design System** - Use `lib/core/design/` for all UI
3. **Clean Architecture** - domain/data/presentation layers
4. **No print()** - Use SecureLogger for debugging
5. [Task-specific rule]

---

## 🚫 PITFALLS TO AVOID

- [Specific pitfall 1]
- [Specific pitfall 2]
- [Specific pitfall 3]

---

## ✅ VALIDATION

When tasks are complete:
1. Run `flutter analyze` - Should have no new errors
2. Test on iOS simulator
3. Update `docs/PROJECT.md` if needed
4. Use `/update-docs-after-work` to document progress

---

## 🚀 START HERE

1. Read the mandatory files listed above
2. Confirm your understanding of the tasks
3. Propose your action plan
4. Wait for validation before executing
```

---

## Output Format

After generating the prompt:
1. Save to `docs/prompts/YYYY-MM-DD_[task-name].md`
2. Display the file path to the user
3. Provide a brief summary of what the prompt covers

---

## Example Usage

User: `/prompt-assistant`

Assistant actions:
1. Analyzes current conversation context
2. Reads PROJECT.md and PROJECT_TODO.md
3. Identifies the main task(s) in progress
4. Generates a comprehensive master prompt
5. Saves to `docs/prompts/2025-12-08_prodetails-refactoring.md`
6. Confirms: "Master prompt generated for ProDetails refactoring task"
