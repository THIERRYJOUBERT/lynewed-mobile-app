---
name: step-02-discovery
description: Autonomously scan PRD-MASTER to discover FD sources for selected Epic
prev_step: steps/step-01-select.md
next_step: steps/step-03-explore.md
---

# Step 02: Autonomous Source Discovery

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER use AskUserQuestion in this step (100% autonomous after Epic selection)
- 🛑 NEVER skip discovery - it runs for ALL Epics, no shortcuts
- 🛑 NEVER proceed without attempting discovery
- ✅ ALWAYS scan PRD-MASTER AND docs/specs/ for FD mentions
- ✅ ALWAYS use Task with model:sonnet for discovery agent (better accuracy)
- ✅ ALWAYS auto-detect domain from Epic name
- ✅ ALWAYS proceed even with partial results (document gaps)
- 📋 YOU ARE an autonomous source discoverer
- 💬 FOCUS on identifying FD documents, not reading them yet
- 🚫 FORBIDDEN to ask user for mapping confirmation
- 🚫 FORBIDDEN to explore FD content in this step (that's step-03)

## EXECUTION PROTOCOLS:

- 🎯 Launch discovery agent with comprehensive prompt
- 💾 Store discovered mapping in state
- 📖 Self-validate mapping completeness
- 🚫 FORBIDDEN to load next step without source mapping (even if minimal)

## CONTEXT BOUNDARIES:

**Available from previous steps:**
- `{epic_id}` - Selected Epic ID (e.g., EPIC-00-FOUNDATION)
- `{epic_name}` - Full Epic name
- `{epic_path}` - Target path for Epic files

## YOUR TASK:

Autonomously discover which FD documents are sources for the selected Epic by scanning PRD-MASTER and docs/specs/.

---

## EXECUTION SEQUENCE:

### 1. Launch Discovery Agent (Sonnet)

Use Task tool with Sonnet model for accurate discovery:

```
Task:
  description: "Discover FDs for {epic_id}"
  model: sonnet
  subagent_type: Explore
  prompt: |
    MISSION: Find ALL FD sources for {epic_id} ({epic_name}).

    SEARCH LOCATIONS:
    1. docs/specs/PRD-MASTER.md - Primary reference
    2. docs/specs/FD-*.md - All Foundation Documents
    3. docs/detailed/ - Technical documentation

    SEARCH STRATEGY:
    1. In PRD-MASTER.md:
       - Find section §7 (Roadmap) for Epic mentions
       - Find any paragraph mentioning {epic_name} or keywords
       - Extract FD-XX references near these mentions

    2. In docs/specs/:
       - List ALL FD files
       - Read each FD intro to understand its scope
       - Match FDs to {epic_name} by topic

    3. For {epic_name}, identify:
       - PRIMARY FD: Main technical source (most relevant)
       - SECONDARY FDs: Supporting sources
       - DETAILED DOCS: Any docs/detailed/*.md files

    KEYWORDS TO MATCH (based on Epic name):
    - If "Foundation/Setup": FD-09 (Tech), structure, packages
    - If "Auth": FD-08 (Design), FD-09 (Tech), authentication
    - If "Database/Data": FD-09 (Tech), FD-07 (Exercises), schemas
    - If "UI/Screen": FD-05 (Product), FD-08 (Design), wireframes
    - If "Home": FD-05 (Product), FD-08 (Design), dashboard
    - If "Training/Workout": FD-05 (Product), FD-06 (Engine), FD-07 (Exercises)

    RETURN FORMAT:
    ```yaml
    primary_fd:
      name: "FD-XX-NAME"
      file: "docs/specs/FD-XX-NAME.md"
      relevance: "why this is primary"
      mentions_count: N

    secondary_fds:
      - name: "FD-YY-NAME"
        file: "docs/specs/FD-YY-NAME.md"
        relevance: "what it contributes"
      - ...

    detailed_docs:
      - file: "docs/detailed/FILE.md"
        type: "schema|wireframe|spec"

    all_fds_found:
      - FD-01-CONTEXT
      - FD-02-... (list all discovered)
    ```

    IMPORTANT: Be THOROUGH. Missing an FD means missing stories.
```

### 2. Parse Discovery Results

**Process agent output into structured mapping:**

```yaml
{sources_mapping}:
  primary:
    file: "{agent.primary_fd.file}"
    name: "{agent.primary_fd.name}"
    mentions_count: {agent.primary_fd.mentions_count}
    confidence: high  # Sonnet found it

  secondary:
    # From agent.secondary_fds
    - file: "{secondary.file}"
      relevance: "{secondary.relevance}"
    # ...

  detailed:
    # From agent.detailed_docs
    - file: "{detailed.file}"
      type: "{detailed.type}"
    # ...

{discovery_method}: auto
```

### 3. Handle Discovery Failures (Autonomous)

**If discovery returns 0 FDs:**

DO NOT ask user. Instead:

1. **Fallback Strategy 1: Use Epic name keywords**
   ```
   Keywords = extract_keywords({epic_name})
   For each FD in docs/specs/FD-*.md:
     If FD title contains any keyword → add to mapping
   ```

2. **Fallback Strategy 2: Default FD mapping by domain**
   ```yaml
   DEFAULT_MAPPINGS:
     INFRA: [FD-09-TECHNICAL-FOUNDATION]
     DATA: [FD-09-TECHNICAL-FOUNDATION, FD-07-EXERCISE-LIBRARY]
     UI: [FD-05-PRODUCT, FD-08-DESIGN-SYSTEM]
     API: [FD-09-TECHNICAL-FOUNDATION, FD-08-DESIGN-SYSTEM]
   ```

3. **Document as gap and proceed:**
   ```yaml
   {gaps}:
     - type: "discovery_failure"
       description: "Auto-discovery found no specific FDs for {epic_id}"
       impact: medium
       action: "Using default mapping for {domain} domain"
   ```

### 4. Auto-Detect Domain

**Detect domain from Epic name (no user interaction):**

```python
DOMAINS = {
  "INFRA": ["foundation", "setup", "ci/cd", "config", "structure", "project", "init"],
  "DATA":  ["database", "schema", "storage", "migration", "cache", "drift", "sqlite"],
  "UI":    ["screen", "widget", "design", "ux", "component", "home", "settings", "profile"],
  "API":   ["auth", "endpoint", "service", "integration", "sync", "supabase", "api"]
}

epic_lower = {epic_name}.lower()
for domain, keywords in DOMAINS.items():
  if any(keyword in epic_lower for keyword in keywords):
    {domain} = domain
    break
else:
  # Default based on primary FD
  if "TECHNICAL" in primary_fd: {domain} = "INFRA"
  elif "DESIGN" in primary_fd: {domain} = "UI"
  elif "PRODUCT" in primary_fd: {domain} = "UI"
  else: {domain} = "INFRA"  # Safe default
```

### 5. Display Discovery Summary (Informational Only)

**Show what was discovered (no confirmation needed):**

```
┌─────────────────────────────────────────────────────────────┐
│        🔍 DISCOVERY COMPLETE FOR {epic_id}                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📄 PRIMARY FD                                              │
│  ──────────────                                             │
│  {primary_fd.name}                                          │
│  Confidence: {confidence}                                   │
│                                                             │
│  📎 SECONDARY FDs ({count})                                 │
│  ──────────────                                             │
│  • {secondary_1}                                            │
│  • {secondary_2}                                            │
│                                                             │
│  📁 DETAILED DOCS ({count})                                 │
│  ──────────────                                             │
│  • {detailed_doc_1}                                         │
│                                                             │
│  🏷️  DOMAIN DETECTED: {domain}                              │
│                                                             │
│  → Proceeding to exploration...                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 6. Store Final State

```yaml
{sources_mapping}:
  primary:
    file: "docs/specs/FD-09-TECHNICAL-FOUNDATION.md"
    name: "FD-09-TECHNICAL-FOUNDATION"
    mentions_count: 12
    confidence: high

  secondary:
    - file: "docs/specs/FD-05-PRODUCT.md"
      relevance: "UI/UX specifications"
    - file: "docs/specs/FD-08-DESIGN-SYSTEM.md"
      relevance: "Design tokens and components"

  detailed:
    - file: "docs/detailed/SCHEMA_v3.8.1.md"
      type: schema

{discovery_method}: auto
{domain}: INFRA
```

---

## AUTO-VALIDATION (APEX SELF-CRITIQUE)

**Before proceeding to next step, validate:**

✅ Discovery agent was executed
✅ At least 1 FD in {sources_mapping} (primary or fallback)
✅ {domain} is set (auto-detected)
✅ {discovery_method} is set (auto)
✅ Summary was displayed

**Self-Critique Questions:**
- Did the discovery agent search ALL FD files, not just the obvious ones?
- Is the domain detection reasonable for this Epic?
- Are there any FDs that should obviously be included based on Epic name?

**If validation fails:**
1. If 0 FDs → apply fallback mapping by domain
2. If domain unclear → use INFRA as safe default
3. Document any uncertainty as gap
4. ALWAYS proceed (never block on discovery)

---

## SUCCESS METRICS:

✅ Discovery agent executed with Sonnet model
✅ Primary FD identified (or fallback applied)
✅ Domain auto-detected
✅ Summary displayed
✅ State variables populated
✅ No user interaction required

## FAILURE MODES:

❌ Using AskUserQuestion (FORBIDDEN in this step)
❌ Blocking on discovery failure (should use fallback)
❌ Not detecting domain

## DISCOVERY PROTOCOLS:

- Use Sonnet model for accurate discovery
- NEVER ask user for confirmation
- ALWAYS have fallback strategies
- ALWAYS proceed even with minimal results
- Document gaps, don't block on them

## NEXT STEP:

After source mapping complete, load `steps/step-03-explore.md`

<critical>
This step is 100% AUTONOMOUS.
After user selects Epic in step-01, there is NO MORE user interaction.
Discovery failures are handled with fallbacks, not user questions.
The workflow must proceed without blocking.
</critical>
