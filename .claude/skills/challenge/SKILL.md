---
name: challenge
description: "Challenger un livrable (code, plan, Epic, Story, decision) avec auto-critique iterative jusqu'a perfection. Utiliser apres creation ou pour valider avant commit."
model: opus
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite
argument-hint: "[target] [--deep] - fichier/concept + mode deep optionnel"
---

<objective>
Challenger rigoureusement n'importe quel livrable (code, decision, plan, Epic, Story, architecture) via des boucles d'auto-critique iteratives. L'objectif est d'atteindre la perfection en identifiant et corrigeant toutes les failles, incoherences et faiblesses AVANT que le travail soit considere comme termine. Itere jusqu'a certitude ou escalade vers l'utilisateur.
</objective>

<critical_rule>
🛑 NEVER consider work "done" after first pass - ALWAYS iterate
🛑 NEVER repeat the same fix without learning (each iteration must be different)
🛑 NEVER be complacent - "0 issues found" on first pass is SUSPICIOUS
🛑 NEVER skip any dimension of the critique checklist
🛑 NEVER iterate more than 3 times without concrete progress
✅ ALWAYS change perspective between iterations (implementer → reviewer → user → attacker)
✅ ALWAYS document what was found AND what was fixed
✅ ALWAYS justify why something is NOT a problem (prove the negative)
✅ ALWAYS track confidence level per dimension
✅ ALWAYS escalate with structured options if stuck after 3 iterations
</critical_rule>

<when_to_use>
**Use this skill when:**
- After creating an Epic, Story, or PRD (quality gate)
- After writing significant code or making architectural decisions
- Before committing important changes
- When something "feels off" but you're not sure what
- When user asks to "challenge", "critique", "review", or "validate"
- Proactively after any complex generation task

**Don't use for:**
- Simple typo fixes (overkill)
- Pure exploration/research tasks
- When user explicitly says "don't review"
</when_to_use>

<invocation_modes>
| Trigger | Behavior |
|---------|----------|
| `/challenge <file>` | Challenge a specific file |
| `/challenge <file> --deep` | Force deep mode with parallel subagents |
| `/challenge last` | Challenge the last significant output |
| `/challenge` (no arg) | Auto-detect what to challenge from context |
| Auto-invoked by Claude | After Epic/Story/Plan creation |

**Mode --deep**: Force l'utilisation de 3 subagents Sonnet en parallèle pour une analyse plus profonde. Sinon, le workflow détecte automatiquement la complexité et décide.
</invocation_modes>

<state_variables>
| Variable | Type | Description |
|----------|------|-------------|
| `{target}` | string | What is being challenged (file path, concept, or "last") |
| `{target_type}` | enum | code, plan, epic, story, decision, architecture, workflow, doc |
| `{target_content}` | string | The actual content to challenge |
| `{deep_mode}` | boolean | True if --deep flag or auto-detected high complexity |
| `{complexity}` | enum | LOW, MEDIUM, HIGH (auto-detected) |
| `{iteration}` | number | Current iteration (1-3) |
| `{dimensions_status}` | object | Status per critique dimension |
| `{findings}` | array | Issues found (with severity) |
| `{fixes_applied}` | array | Corrections made |
| `{confidence_score}` | object | Confidence per dimension (0-100) |
| `{overall_verdict}` | enum | PERFECT, GOOD_ENOUGH, NEEDS_USER_INPUT |
</state_variables>

<entry_point>
Load `steps/step-01-analyze.md`
</entry_point>

<step_files>
| Step | File | Purpose | Output |
|------|------|---------|--------|
| 01 | step-01-analyze.md | Detect target, load content, classify type | Target identified and loaded |
| 02 | step-02-challenge.md | Multi-dimensional critique with checklist | Findings list + severity |
| 03 | step-03-iterate.md | Apply fixes, re-challenge, track progress | Improved output + delta |
| 04 | step-04-finalize.md | Final verdict, report, optional corrections | Report + confidence score |
</step_files>

<execution_rules>
1. **Progressive Depth**: Each iteration goes DEEPER, not just wider
2. **Perspective Rotation**: Iteration 1=Implementer, 2=Critic, 3=User/Attacker
3. **Learning Loop**: Each iteration explicitly states what was LEARNED from previous
4. **Confidence Tracking**: Every dimension gets a confidence score (0-100)
5. **Threshold**: Overall confidence must reach 90%+ to auto-approve
6. **Escalation**: At iteration 3 with <90% confidence → AskUserQuestion
7. **Anti-Complacency**: Finding nothing on iteration 1 triggers DEEPER investigation
</execution_rules>

<critique_dimensions>
The challenge covers 6 dimensions, adapted to target type:

| Dimension | Code | Plan/Decision | Epic/Story | Workflow |
|-----------|------|---------------|------------|----------|
| **Correctness** | Logic errors, edge cases | Feasibility, completeness | Criteria clarity | Step logic, exit conditions |
| **Security** | OWASP, injection, secrets | Risk exposure, compliance | Privacy, data exposure | Tool restrictions, escalation |
| **Coherence** | Architecture fit, patterns | Project alignment | PRD alignment | Pattern adherence |
| **Robustness** | Error handling, failures | Contingencies, rollback | Dependencies, blockers | Fallbacks, self-healing |
| **Clarity** | Readability, naming | Unambiguous steps | Testability | Instructions clarity |
| **Efficiency** | Performance, complexity | Time/resource | Minimal scope | Step count, overhead |
</critique_dimensions>

<subagent_strategy>
## Deep Mode: Parallel Subagents

When `{deep_mode}` is true (--deep flag OR auto-detected HIGH complexity), launch 3 Sonnet agents in SINGLE message:

```
**Agent 1 - Devil's Advocate** (model: sonnet):
Role: Find every possible way this could fail or be wrong.
Focus: Correctness + Robustness dimensions.
Return: List of potential failures with severity.

**Agent 2 - Security Auditor** (model: sonnet):
Role: Examine from attacker/misuse perspective.
Focus: Security + Coherence dimensions.
Return: Vulnerabilities and inconsistencies found.

**Agent 3 - User Advocate** (model: sonnet):
Role: Challenge from end-user and maintainer perspective.
Focus: Clarity + Efficiency dimensions.
Return: Confusion points and unnecessary complexity.
```

### Complexity Auto-Detection

| Indicator | Complexity |
|-----------|------------|
| Single file < 200 lines | LOW |
| Single file 200-500 lines | MEDIUM |
| Multiple files OR > 500 lines | HIGH |
| Codebase-wide OR architecture | HIGH |
| Epic with 5+ stories | HIGH |
| Decision with 3+ alternatives | MEDIUM |

**Rule**: If HIGH complexity detected AND --deep not specified, RECOMMEND deep mode to user via brief note (don't force).
</subagent_strategy>

<confidence_thresholds>
| Score | Meaning | Action |
|-------|---------|--------|
| 95-100% | Perfect | Auto-approve, brief report |
| 90-94% | Excellent | Auto-approve with notes |
| 80-89% | Good | User choice: approve or iterate |
| 60-79% | Needs Work | More iterations or user input |
| <60% | Major Issues | Must escalate with findings |
</confidence_thresholds>

<iteration_protocol>
```
ITERATION 1: "The Implementer View"
├── Am I solving the right problem?
├── Is the solution complete?
├── Are there obvious errors?
└── What did I assume?

ITERATION 2: "The Critic View"
├── What are the weakest points?
├── What edge cases are missed?
├── What would break this?
└── What's the most clever attack?

ITERATION 3: "The User/Attacker View"
├── Would a user be confused?
├── Could this be exploited?
├── Is this over-engineered?
└── What's the simplest fix for each issue?
```
</iteration_protocol>

<anti_complacency>
## Suspicion Triggers

If ANY of these occur, INCREASE scrutiny:

1. **Zero findings on first pass** → Re-examine with attacker mindset
2. **All confidence scores at 100%** → Something was overlooked
3. **No fix needed** → Did you actually understand the target deeply?
4. **"Looks good to me"** → Ban this phrase, find something specific

## Mandatory Deep Dive

Even if everything seems perfect, MUST check:
- [ ] One potential security issue (even theoretical)
- [ ] One edge case (even unlikely)
- [ ] One clarity improvement (even minor)
- [ ] One efficiency question (even small)
</anti_complacency>

<success_criteria>
✅ All 6 dimensions evaluated with justification
✅ Confidence score >= 90% overall
✅ All HIGH severity findings addressed
✅ Report generated with findings + fixes + confidence
✅ Target improved OR justified why no change needed
✅ No "it looks fine" without specific evidence
</success_criteria>

<failure_modes>
❌ Target not found → Ask user to specify
❌ Target type unclear → Show options, ask user
❌ Stuck at <80% after 3 iterations → Escalate with structured report
❌ Cannot apply fixes (read-only) → Report only mode
❌ Circular findings (same issue returning) → Escalate, likely architectural issue
</failure_modes>

<output_format>
## Challenge Report: {target}

**Type**: {target_type}
**Iterations**: {iteration_count}
**Overall Confidence**: {confidence_score}%

### Dimension Scores

| Dimension | Score | Key Finding |
|-----------|-------|-------------|
| Correctness | XX% | {summary} |
| Security | XX% | {summary} |
| Coherence | XX% | {summary} |
| Robustness | XX% | {summary} |
| Clarity | XX% | {summary} |
| Efficiency | XX% | {summary} |

### Findings

#### HIGH Severity
- {finding + fix applied}

#### MEDIUM Severity
- {finding + fix or justification}

#### LOW Severity
- {finding + recommendation}

### Verdict: {PERFECT | GOOD_ENOUGH | NEEDS_USER_INPUT}

{Brief justification}
</output_format>

<workflow_diagram>
```
┌──────────────────────────────────────────────────────────────────┐
│                    /challenge WORKFLOW                           │
│           "Iterative Self-Critique Until Perfection"             │
│                                                                  │
│  01. ANALYZE      → Detect target, load content, classify        │
│       ↓            ✓ Target identified and understood            │
│                                                                  │
│  02. CHALLENGE    → Multi-dimensional critique (6 dimensions)    │
│       ↓            ✓ Findings list with severity                 │
│       │                                                          │
│       ▼            ┌─────────────────────────────────────┐       │
│  03. ITERATE   ───▶│ Apply fixes, re-challenge, learn    │       │
│       │            │ Max 3 iterations, perspective shift │       │
│       │            │                                     │       │
│       │            │ Confidence < 90%? ─────────────────▶│ Loop  │
│       │            │ Confidence >= 90%? ────────────────▶│ Exit  │
│       │            │ Iteration 3 + stuck? ──────────────▶│ Ask   │
│       │            └─────────────────────────────────────┘       │
│       ↓                                                          │
│  04. FINALIZE     → Generate report + verdict                    │
│                    ✓ Report + confidence + improvements          │
│                                                                  │
│  OUTPUT: Challenged deliverable + confidence score + report      │
└──────────────────────────────────────────────────────────────────┘
```
</workflow_diagram>

<begin>
Load `steps/step-01-analyze.md` to start the workflow.
</begin>
