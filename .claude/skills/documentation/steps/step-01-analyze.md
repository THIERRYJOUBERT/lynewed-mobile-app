# Step 01: Analyze

> Purpose: Lancer 3 agents Sonnet en parallele pour explorer conversation, git, et documentation existante.

---

## MANDATORY RULES (READ FIRST)

- 🚀 ALWAYS lancer les 3 agents dans UN SEUL message (parallele)
- 🎯 ALWAYS utiliser model: sonnet pour les agents (cout optimise)
- 📊 ALWAYS consolider les resultats en synthese exploitable
- ⚠️ NEVER bloquer si un agent echoue - utiliser les donnees disponibles

## PROTOCOLS

- 🎯 **Goal**: Collecter contexte pour documentation intelligente
- 💾 **Output**: {conversation_insights}, {git_changes}, {existing_docs}
- 📖 **Reference**: None - agents explorent directement
- ⚡ **Performance**: 3 agents paralleles = exploration rapide

---

## CONTEXT

**Available from previous steps:**
- `{mode}` - interactive ou auto (from step-00)
- `{scope}` - workspace, detailed, epics, ou all (from step-00)
- `{archive_after}` - boolean (from step-00)

**Produced by this step:**
- `{conversation_insights}` - Decisions, problemes resolus, choix techniques
- `{git_changes}` - Fichiers modifies avec resume des changements
- `{existing_docs}` - Documentation existante pertinente

**NOT available (do not use):**
- `{documentation_plan}` - Pas encore cree (step-02)
- `{files_created}` - Pas encore cree (step-03)

---

## TASK

Lancer 3 agents Sonnet en parallele pour explorer:
1. Agent 1: Analyser la conversation pour extraire insights
2. Agent 2: Analyser git pour identifier changements
3. Agent 3: Scanner documentation existante pour eviter duplication

---

## EXECUTION

### Launch All 3 Agents (SINGLE MESSAGE)

**CRITICAL**: Utiliser UN message avec 3 appels Task tool.

---

### Agent 1: Conversation Analyzer

**Configuration:**
```yaml
subagent_type: Explore
model: sonnet
description: "Analyze conversation for insights"
```

**Prompt:**
```
Analyze the current conversation to extract documentation-worthy content.

Focus on:
1. TECHNICAL DECISIONS - Architecture choices, library selections, design patterns chosen
2. PROBLEMS SOLVED - Bugs fixed, issues resolved, challenges overcome
3. IMPLEMENTATION DETAILS - How features were implemented, key code patterns
4. USER PREFERENCES - Explicit preferences expressed by user
5. DISCOVERIES - Insights gained, learnings, things that didn't work

Return structured analysis:
```yaml
conversation_insights:
  decisions:
    - topic: "Decision topic"
      choice: "What was decided"
      reason: "Why (if stated)"
      timestamp_hint: "Approximate when in conversation"
  problems_solved:
    - problem: "What was the issue"
      solution: "How it was fixed"
      files_affected: ["file1.dart", "file2.dart"]
  implementations:
    - feature: "Feature name"
      approach: "How implemented"
      key_patterns: ["pattern1", "pattern2"]
  preferences:
    - preference: "User preference"
      context: "When/why expressed"
  discoveries:
    - insight: "What was learned"
      impact: "How it affects project"
```

Be concise. Only include truly significant items, not minor details.
```

---

### Agent 2: Git Analyzer

**Configuration:**
```yaml
subagent_type: Explore
model: sonnet
description: "Analyze git changes"
```

**Prompt:**
```
Analyze the current git state to identify changes worth documenting.

Run these commands:
- git diff --stat HEAD~10 (recent changes)
- git status --porcelain (current modifications)
- git log --oneline -10 (recent commits)

Return structured analysis:
```yaml
git_changes:
  modified_files:
    - path: "path/to/file.dart"
      change_type: "modified|added|deleted"
      summary: "Brief description of changes"
      significance: "high|medium|low"
  recent_commits:
    - hash: "abc1234"
      message: "Commit message"
      files_count: N
  uncommitted:
    - path: "path/to/file.dart"
      status: "modified|untracked|staged"
  areas_affected:
    - area: "features/auth"
      description: "Authentication system changes"
```

Focus on significant changes. Ignore trivial modifications.
```

---

### Agent 3: Documentation Checker

**Configuration:**
```yaml
subagent_type: Explore
model: sonnet
description: "Check existing documentation"
```

**Prompt:**
```
Scan existing documentation to understand what's already documented.

Check these locations based on scope {scope}:
- workspace/current/ - Active session documentation
- workspace/archive/ - Archived sessions
- docs/detailed/ - Technical specifications
- docs/epics/ - Epic and story tracking

For each relevant file found:
1. Note its path and purpose
2. Identify what topics it covers
3. Check last modification date
4. Note if it needs updating

Return structured analysis:
```yaml
existing_docs:
  workspace_current:
    - path: "workspace/current/session.md"
      topics: ["topic1", "topic2"]
      last_modified: "date"
      status: "current|outdated|empty"
  workspace_archive:
    count: N
    recent_topics: ["topic1", "topic2"]
  detailed:
    - path: "docs/detailed/area/file.md"
      covers: "What it documents"
      needs_update: true|false
  epics:
    - path: "docs/epics/EPIC-XX/TRACKING.md"
      status: "What's tracked"
      needs_update: true|false
  gaps:
    - area: "Area not documented"
      should_document: "What should be added"
```

Be thorough but concise. Note gaps that should be filled.
```

---

### Consolidate Results

After all 3 agents complete, merge their outputs:

```yaml
exploration_synthesis:
  conversation_insights: {from Agent 1}
  git_changes: {from Agent 2}
  existing_docs: {from Agent 3}

  cross_analysis:
    - Decisions from conversation that match git changes
    - Areas with git changes but no documentation
    - Documentation that references outdated content

  documentation_candidates:
    - topic: "Topic to document"
      source: "conversation|git|both"
      target_type: "workspace|detailed|epics"
      priority: "high|medium|low"
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ Au moins un agent a retourne des donnees utiles
✅ Les resultats sont structures et exploitables
✅ Pas de gaps critiques (si les 3 agents ont echoue → probleme)

**Self-Critique Questions:**
- Les insights sont-ils vraiment significatifs?
- Les changements git sont-ils correctement categorises?
- Ai-je identifie les gaps de documentation?

**If validation fails:**
1. Si Agent 1 echoue → Utiliser git-only
2. Si Agent 2 echoue → Utiliser conversation-only
3. Si tous echouent → Reporter "rien a documenter"

---

## SUCCESS / FAILURE

**Success:**
✅ {conversation_insights} disponible (meme si partiel)
✅ {git_changes} disponible (meme si partiel)
✅ {existing_docs} disponible
✅ Synthese exploitable pour categorization

**Failure modes:**
❌ Git non disponible → Fallback conversation-only avec warning
❌ Conversation vide → Fallback git-only
❌ Les 3 agents echouent → Rapport "rien a documenter", fin workflow

## NEXT

After validation passes, load `steps/step-02-categorize.md`

<critical>
Les 3 agents DOIVENT etre lances dans UN SEUL message.
Execution sequentielle = lente et inefficace.
Pattern E2 (Parallel Agent Execution) est obligatoire.
</critical>
