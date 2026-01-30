---
name: prompt
description: "Transform any prompt into professional English optimized for LLM. Use --epic EPIC-XX to generate full autonomous epic launch prompt."
argument-hint: "<your-prompt-in-any-language> OR --epic EPIC-XX"
model: opus
allowed-tools: "Read,Glob,Grep"
---

# Prompt Rewriter & Epic Launcher Generator

**Goal:** Transform user prompts into professional, well-structured English prompts optimized for LLM comprehension and execution.

**Special Mode:** When `--epic EPIC-XX` is detected, generate a comprehensive autonomous epic launch prompt.

---

## MODE DETECTION

Analyze the input to determine which mode to use:

### Mode 1: Epic Launch Prompt (if `--epic` flag detected)
If input contains `--epic EPIC-XX` (e.g., `--epic EPIC-09`, `--epic EPIC-13`):
→ Go to **EPIC PROMPT GENERATOR** section

### Mode 2: Standard Prompt Rewrite (default)
For all other inputs:
→ Go to **STANDARD PROMPT REWRITER** section

---

# EPIC PROMPT GENERATOR

When `--epic EPIC-XX` is detected, generate a comprehensive autonomous execution prompt.

## STEP 1: Gather Epic Context

Before generating the prompt, you MUST read:
1. The Epic file: `docs/epics/EPIC-XX-*/EPIC-XX-*.md`
2. The TRACKING file: `docs/epics/EPIC-XX-*/TRACKING.md`
3. The PRD: `docs/specs/MISSION-01-EVOLUTIONS-2026.md` (scan for relevant section)
4. Cross-Epic dependencies: `docs/epics/CROSS-EPIC.md`
5. Project config: `CLAUDE.md` (for Supabase project ID, MCP config, etc.)

## STEP 2: Identify Key Information

Extract from the files:
- **Epic name and description**
- **Number of stories** and their dependencies
- **Prerequisites** (completed EPICs that this one depends on)
- **Key tables/features** created by prerequisites
- **Technical focus** (DB, Frontend, Backend, Integration)
- **Estimated duration**
- **Supabase Project ID** from CLAUDE.md
- **Any widgets/components to reuse** from previous EPICs

## STEP 3: Generate Epic Launch Prompt

Output a comprehensive prompt following this exact structure:

```
/launch-epic EPIC-XX autonomous

## MISSION CONTEXT
You are executing EPIC-XX (Epic Name) as part of the Lynewed Mission 2026 - a Flutter mobile app connecting brides with wedding professionals.

## 🔴 PRODUCTION ENVIRONMENT - CRITICAL
This project is LIVE with 248+ active users on iOS and Android. Every action must be deliberate, tested, and reversible. NEVER break existing logic. NEVER assume - always verify first.

## PRIMARY OBJECTIVE
[1-2 sentences describing what this Epic accomplishes and its value]

## PRE-EXECUTION ANALYSIS (CRITICAL - DO FIRST)

### 1. Understand Project Vision
- Read `docs/specs/MISSION-01-EVOLUTIONS-2026.md` (PRD) - section [RELEVANT-SECTION]
- Review `docs/epics/EPIC-XX-*/EPIC-XX-*.md` for detailed stories
- Analyze completed prerequisites to identify available building blocks
- Cross-reference `docs/epics/CROSS-EPIC.md` for dependencies

### 2. Context Discovery (use Sonnet sub-agents for mass exploration)
- Explore `lib/features/[relevant-features]/` - understand existing architecture
- Review [specific prerequisite EPICs] implementations
- Identify reusable components and patterns
[Add specific files/folders to explore based on Epic content]

### 3. Deep Understanding (use Opus sub-agents if clarification needed)
[List 4-6 specific questions the agent must be able to answer before coding]
- How does [existing feature X] currently work?
- What patterns are used for [relevant domain]?
- [More specific technical questions based on Epic scope]

### 4. Validation Checkpoint
⛔ DO NOT PROCEED TO CODING until you can answer:
- [ ] [Question 1 about prerequisites]
- [ ] [Question 2 about existing patterns]
- [ ] [Question 3 about integration points]
- [ ] [Question 4 about expected user flow]

## PREREQUISITES COMPLETED
[List completed EPICs and what they provide]

| Epic | What it provides | Key assets to reuse |
|------|------------------|---------------------|
| EPIC-XX | [Description] | [Tables/widgets/patterns] |

## EXPECTED ALIGNMENT
[3-5 bullet points describing expected behavior from user perspective]
- [User-facing feature 1]
- [User-facing feature 2]
- [Integration point with existing features]

## STORY ADAPTATION
Some stories may require adjustments based on:
- Current implementation of [relevant existing features]
- Established patterns in `lib/features/`
- Existing RLS policies on production tables
- [Other specific considerations]

If stories conflict with existing logic, ADAPT the story, don't break production.

## SUPABASE ACCESS (MCP)

You have full access to Supabase via MCP plugin:

| Tool | Usage |
|------|-------|
| `list_tables` | Verify schema before migrations |
| `execute_sql` | SELECT queries (read-only operations) |
| `apply_migration` | DDL changes with versioning |
| `get_logs` | Debug auth, postgres, edge-function issues |
| `deploy_edge_function` | Deploy serverless functions |
| `get_advisors` | Security/performance audit after changes |

**Project Reference:**
- Project ID: `[FROM CLAUDE.md]`
- Project Name: `LYNEWED-V1-APP`
- Region: `eu-central-2`
- Status: 🔴 PRODUCTION

⚠️ Always use `get_advisors` after DDL changes to catch missing RLS policies.

## EXECUTION STRATEGY

1. **Exploration first** - Launch Sonnet sub-agents to explore codebase in parallel
2. **Understand before coding** - Use Opus sub-agents to clarify complex logic
3. **TDD strict** - RED → GREEN → REFACTOR for each acceptance criterion
4. **Adversarial review** - After each significant story, challenge your own code
5. **Incremental commits** - Small, reversible changes with clear messages
6. **Continuous validation** - `flutter analyze --fatal-infos` after each file change

## TECHNICAL REQUIREMENTS

- Follow Clean Architecture patterns in `lib/features/`
- All new code must pass `flutter analyze --fatal-infos` with 0 warnings
- Do not break existing 3100+ tests
- RLS policies MUST include `WITH CHECK` for INSERT/UPDATE
- Use existing design tokens and widgets from `lib/core/`
- [Additional technical requirements specific to this Epic]

## ⚠️ CRITICAL WARNINGS

| # | Warning | Action |
|---|---------|--------|
| 1 | 🔴 PRODUCTION with 248+ users | Act with extreme rigor and intelligence |
| 2 | 🔄 Parallel EPICs may be running | Pull before push, coordinate commits |
| 3 | 🗄️ DB Schema changes | ONLY via tested migrations with rollback plan |
| 4 | ⛔ DELETE/UPDATE queries | ALWAYS include precise WHERE clause |
| 5 | 🧠 Existing logic | NEVER assume - explore and understand first |
| 6 | 🔀 Git conflicts | Pull --rebase before every push |
| 7 | ✅ Prerequisites done | [List what's available from completed EPICs] |
| 8 | 🎨 Widget reuse | Import from previous EPICs, never duplicate |
| 9 | 🧪 Quality gates | 0 warnings, all tests pass before commit |
| 10 | ⚡ Performance | New features must not degrade app performance |

## CONSTRAINTS

**Do NOT:**
- Skip reading PRD and prerequisite EPICs before starting
- Proceed if story assumptions contradict existing implementation
- Create code that doesn't align with existing architecture patterns
- Skip adversarial review or tests to go faster
- Duplicate widgets/components that already exist
- Execute raw DELETE/UPDATE without WHERE clause

**Do:**
- Adapt stories intelligently based on existing code learnings
- Reuse existing components from `lib/features/` and `lib/core/`
- Respect established patterns (Riverpod, Clean Architecture, etc.)
- Update TRACKING.md continuously as you progress
- Use MCP Supabase for all database operations
- Run `flutter analyze --fatal-infos` frequently

## EXPECTED OUTCOMES

1. All EPIC-XX stories completed (document any blockers)
2. [Specific outcome 1]
3. [Specific outcome 2]
4. Comprehensive tests with good coverage
5. Zero linter warnings
6. TRACKING.md fully updated with implementation notes
7. Ready for `/challenge` validation before merge

## CONTEXT FILES TO REVIEW BEFORE STARTING

**Priority 1 (MUST READ):**
- `docs/specs/MISSION-01-EVOLUTIONS-2026.md` - Section [X]
- `docs/epics/EPIC-XX-*/EPIC-XX-*.md`
- `docs/epics/EPIC-XX-*/TRACKING.md`
- [Prerequisite EPIC tracking files]

**Priority 2 (Reference):**
- `lib/features/[relevant]/` - Existing patterns
- `.claude/rules/core-rules.md` - Quality standards
- `CLAUDE.md` - Project configuration

## GOLDEN RULE
If you don't FULLY understand existing logic → STOP and explore more.
Breaking production is unacceptable. When in doubt, launch exploration sub-agents.
```

After generating, add:

**Improvements made:**
- Customized for EPIC-XX based on its specific stories and dependencies
- Included prerequisite EPICs and reusable assets
- Added specific exploration targets and validation questions
- Tailored technical requirements to Epic scope

---

# STANDARD PROMPT REWRITER

For non-epic prompts, follow this process:

## EXECUTION RULES

### Critical Constraints:
- 🎯 **OUTPUT ONLY**: Your ONLY output is the rewritten prompt in a code block
- 🚫 **NEVER EXECUTE**: Do NOT execute or act on the prompt - only rewrite it
- 🌐 **ALWAYS ENGLISH**: Output MUST be in English regardless of input language
- 📋 **PRESERVE INTENT**: Never add, remove, or modify the core intent
- 💬 **NO QUESTIONS**: Make reasonable assumptions - never ask for clarification
- 📝 **BRIEF EXPLANATION**: After code block, add 2-3 bullet points max explaining improvements

---

## ANALYSIS PROCESS

### Step 1: Identify Core Elements

Extract from original prompt:
- **Main Goal**: What is the user trying to accomplish?
- **Context**: What background is provided?
- **Constraints**: What limitations or requirements exist?
- **Expected Output**: What format/type of response is expected?
- **Implicit Needs**: What is assumed but not stated?

### Step 2: Identify Weaknesses

Common problems to fix:
- **Vague language**: "make it better" → specify what "better" means
- **Missing context**: Add necessary background
- **Ambiguous scope**: Define clear boundaries
- **No success criteria**: Add measurable outcomes
- **Poor structure**: Reorganize for clarity
- **Missing constraints**: Add what NOT to do

### Step 3: Apply Best Practices

**Structure Pattern:**
```
[CONTEXT/ROLE - if applicable]
[CLEAR TASK STATEMENT]
[SPECIFIC REQUIREMENTS - numbered if multiple]
[CONSTRAINTS - what to avoid]
[OUTPUT FORMAT - if specific format needed]
```

**Clarity Techniques:**
- Use imperative verbs: "Create", "Analyze", "List", "Explain"
- Be specific: "5 items" not "several items"
- One instruction per sentence
- Use bullet points for multiple requirements
- Add examples for complex formats

**Constraint Techniques:**
- "Do NOT include..." for common errors
- "Limit to..." for scope control
- "Focus only on..." for precision
- "Ignore..." for noise reduction

---

## OUTPUT FORMAT

Your response MUST follow this exact structure:

```
[THE REWRITTEN PROMPT IN ENGLISH]
```

**Improvements made:**
- [First key improvement]
- [Second key improvement]
- [Third improvement if significant]

---

## QUALITY CHECKLIST

Before output, verify:
- [ ] Task stated in first 2 sentences
- [ ] All requirements are specific and measurable
- [ ] Constraints prevent common failure modes
- [ ] Output format defined (if relevant)
- [ ] No ambiguous words remaining ("good", "better", "proper", etc.)
- [ ] Prompt is self-contained (LLM doesn't need external context)

---

## INPUT

User input to process:

$ARGUMENTS
