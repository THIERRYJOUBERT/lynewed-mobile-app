---
name: step-06-confirm
description: Display summary and provide next steps
prev_step: steps/step-05-generate.md
next_step: null
---

# Step 06: Confirm & Complete

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER skip showing the summary
- 🛑 NEVER suggest running implementation commands
- ✅ ALWAYS show what was created
- ✅ ALWAYS provide clear next step
- ✅ ALWAYS mention gaps if any exist
- 📋 YOU ARE a summarizer providing closure
- 💬 FOCUS on clear communication of results
- 🚫 FORBIDDEN to modify any files in this step
- 🚫 FORBIDDEN to start implementation

## EXECUTION PROTOCOLS:

- 🎯 Summarize everything created
- 💾 No file operations
- 📖 Provide actionable next step
- 🚫 FORBIDDEN to proceed to implementation

## CONTEXT BOUNDARIES:

**Available from previous steps:**
- `{epic_id}` - Epic ID
- `{epic_name}` - Epic name
- `{epic_path}` - Path where files were created
- `{domain}` - Epic domain
- `{stories}` - Enriched stories
- `{stories_count}` - Number of stories
- `{gaps}` - Identified gaps (if any)
- `{sources_mapping}` - Sources explored
- `{discovery_method}` - How sources were found

## YOUR TASK:

Display a comprehensive summary of what was created and provide the clear next step.

---

## EXECUTION SEQUENCE:

### 1. Display Creation Summary

```
╔════════════════════════════════════════════════════════════════╗
║                  ✅ EPIC CREATED SUCCESSFULLY                   ║
╠════════════════════════════════════════════════════════════════╣
║                                                                 ║
║  📌 Epic: {epic_id}                                            ║
║  📝 Name: {epic_name}                                          ║
║  🏷️  Domain: {domain}                                          ║
║                                                                 ║
║  📊 Stories: {stories_count} stories enriched                   ║
║  📁 Path: {epic_path}/                                         ║
║                                                                 ║
╚════════════════════════════════════════════════════════════════╝
```

### 2. Show Files Created

```
📁 Files Created:

{epic_path}/
├── {epic_id}.md          # Epic definition ({stories_count} stories)
├── TRACKING.md           # Progress tracking
├── sources.yaml          # Source mapping
└── stories/              # Ready for /create-story
```

### 3. Show Sources Explored

```
📚 Sources Explored:

Primary FD:
  • {sources_mapping.primary.file}
    Sections: {sections}

Secondary FDs:
  • {secondary_fd_1}
  • {secondary_fd_2}

Detailed Docs:
  • {detailed_doc_1}

Discovery Method: {discovery_method}
```

### 4. Show Stories Summary

```
📋 Stories Created:

| # | Story | Complexity |
|---|-------|------------|
| 01 | {story_1_name} | {complexity} |
| 02 | {story_2_name} | {complexity} |
| 03 | {story_3_name} | {complexity} |
| ... | ... | ... |

Total: {stories_count} stories
  - Small (S): {count_s}
  - Medium (M): {count_m}
  - Large (L): {count_l}
```

### 5. Show Gaps (if any)

**If {gaps} is not empty:**

```
⚠️  Gaps Identified:

| Gap | Impact | Action Needed |
|-----|--------|---------------|
| {gap_1_description} | {impact} | {action} |
| {gap_2_description} | {impact} | {action} |

These gaps are documented in:
- {epic_id}.md → Section "Gaps Identifies"
- sources.yaml → gaps section

Address these before implementing related stories.
```

### 6. Provide Next Step

```
┌─────────────────────────────────────────────────────────────┐
│                      NEXT STEP                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Run /create-story to decompose stories into INVEST format: │
│                                                             │
│  /create-story {epic_id}                                    │
│                                                             │
│  This will:                                                 │
│  • Create detailed STORY-XX.md files in stories/           │
│  • Add INVEST criteria                                      │
│  • Add Gherkin acceptance tests                            │
│  • Prepare for /dev-story implementation                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 7. Optional: Quick Reference

```
📖 Quick Reference:

# View Epic
cat {epic_path}/{epic_id}.md

# View Stories summary
head -100 {epic_path}/{epic_id}.md | grep -A 20 "## Stories"

# View Progress
cat {epic_path}/TRACKING.md

# View Sources
cat {epic_path}/sources.yaml

# Create Stories (next step)
/create-story {epic_id}

# Implement a Story (after /create-story)
/dev-story {story_id}
```

---

## WORKFLOW COMPLETE

This is the final step of /create-epic.

**What was achieved:**
- Epic definition with enriched stories
- Progress tracking setup
- Source documentation
- Ready for /create-story

**What's next:**
- User runs `/create-story {epic_id}`
- Then `/dev-story {story_id}` for implementation

---

## SUCCESS METRICS:

✅ Summary displayed clearly
✅ All created files listed
✅ Sources explored shown
✅ Stories summary with complexity breakdown
✅ Gaps highlighted (if any)
✅ Clear next step provided
✅ Quick reference commands shown

## FAILURE MODES:

❌ Summary missing key information
❌ No next step provided
❌ Gaps not mentioned when they exist

## CONFIRMATION PROTOCOLS:

- Always show complete summary
- Always highlight gaps if present
- Always provide clear, copy-able next command
- Never start implementation in this workflow

## WORKFLOW END

The /create-epic workflow is now complete.

<critical>
This workflow ENDS here.
Implementation happens in /create-story and /dev-story.
/create-epic is for PLANNING, not IMPLEMENTING.
</critical>
