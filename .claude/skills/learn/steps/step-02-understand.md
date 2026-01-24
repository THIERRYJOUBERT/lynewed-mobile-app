# Step 02: Understand

> Analyser en profondeur via 3 agents Sonnet en parallele.

---

## Objectif

Atteindre une comprehension de 100% du topic en analysant les fichiers decouverts en profondeur.

---

## CRITICAL: Parallel Execution

**Lancer les 3 agents dans UN SEUL message avec 3 appels Task tool.**

Les agents Sonnet sont plus chers mais produisent une analyse de qualite superieure.

---

## Input from Step-01

```yaml
Available:
  - file_list: Fichiers prioritises par importance
  - structure_map: Organisation et relations
  - dependency_graph: Dependances internes/externes
```

---

## Agents Configuration

### Agent 1: Implementation Analysis

```yaml
Task tool:
  subagent_type: Explore
  model: sonnet
  description: "Deep analyze impl for {topic}"
  prompt: |
    Deeply analyze the implementation of "{topic}".

    Files to analyze (from scan):
    {file_list.primary}

    For each key file, extract:
    1. **Purpose**: What does this file do?
    2. **Key Functions/Classes**: Main exports with signatures
    3. **Data Flow**: How data moves through
    4. **State Management**: How state is handled
    5. **Design Decisions**: Why is it built this way?

    Return STRUCTURED output with file:line references:

    ## Core Implementation

    ### {filename}
    **Purpose**: ...
    **Location**: `lib/path/file.dart:1-150`

    **Key Components**:
    - `ClassName` (line 15): Description
    - `functionName()` (line 45): What it does

    **Data Flow**:
    ```
    Input → Transform → Output
    ```

    **Design Decisions**:
    - Why X instead of Y (line 30)

    IMPORTANT: Every statement must have file:line reference.
```

### Agent 2: Pattern Extraction

```yaml
Task tool:
  subagent_type: Explore
  model: sonnet
  description: "Extract patterns for {topic}"
  prompt: |
    Extract patterns and conventions used in "{topic}".

    Files to analyze:
    {file_list.primary + file_list.secondary}

    Identify:
    1. **Naming Conventions**: How things are named
    2. **Code Patterns**: Recurring structures
    3. **Architecture Patterns**: Design patterns used
    4. **Error Handling**: How errors are managed
    5. **Testing Patterns**: How it's tested

    Return STRUCTURED output:

    ## Patterns Catalog

    ### Naming Conventions
    - Pattern: description (`file.dart:line` example)

    ### Code Patterns
    - **Pattern Name**
      - Where: `file.dart:line`
      - What: Description
      - Example:
        ```dart
        // code snippet
        ```

    ### Architecture
    - Pattern used (with justification from code)

    ### Error Handling
    - Strategy: Description with source

    ### Testing
    - Approach: How this is tested
```

### Agent 3: Gotchas Extraction

```yaml
Task tool:
  subagent_type: Explore
  model: sonnet
  description: "Find gotchas for {topic}"
  prompt: |
    Find edge cases, pitfalls, and non-obvious behaviors in "{topic}".

    Files to analyze:
    {file_list.primary + file_list.tests}

    Look for:
    1. **Edge Cases**: Boundary conditions, null handling
    2. **Hidden Behaviors**: Non-obvious side effects
    3. **Gotchas**: Things that could surprise developers
    4. **Technical Debt**: TODO, FIXME, workarounds
    5. **Inconsistencies**: Things that don't match expectations

    Return STRUCTURED output:

    ## Gotchas & Edge Cases

    ### Critical (must know)
    - **Issue**: Description
      - Location: `file.dart:line`
      - Impact: What goes wrong
      - Mitigation: How to handle

    ### Important (should know)
    - ...

    ### Minor (nice to know)
    - ...

    ### Technical Debt
    - TODO at `file.dart:line`: What needs to be done
    - Workaround at `file.dart:line`: Why it exists

    ### Inconsistencies
    - X at `file_a.dart:10` vs Y at `file_b.dart:20`
```

---

## Compile Results

```yaml
understand_results:
  impl_analysis:
    files_analyzed: N
    core_components:
      - name: "ComponentName"
        file: "path/file.dart"
        lines: "15-45"
        purpose: "..."
        design_decisions: [...]
    data_flows:
      - description: "..."
        source: "file:line"

  patterns:
    naming: [...]
    code: [...]
    architecture: [...]
    error_handling: [...]
    testing: [...]

  gotchas:
    critical:
      - issue: "..."
        location: "file:line"
        impact: "..."
        mitigation: "..."
    important: [...]
    minor: [...]
    technical_debt: [...]
    inconsistencies: [...]

  comprehension_level:
    score: 0-100
    gaps: ["Areas not fully understood"]
    confidence: "high" | "medium" | "low"
```

---

## Deep Mode: Second Pass

Si `depth = deep` et `comprehension_level.confidence != high`:

Relancer 3 agents avec focus sur les gaps identifies:

```yaml
prompt_adjustment: |
  Previous analysis had gaps in: {gaps}
  Focus specifically on understanding these areas.
  Files to re-examine: {files_related_to_gaps}
```

---

## Fallback: Incomplete Understanding

Si comprehension reste incomplete apres 2 passes:

1. **Documenter gaps**: Explicitement noter ce qui n'est pas compris
2. **Continuer**: Generer doc avec sections "A approfondir"
3. **Ne pas inventer**: Jamais fabriquer d'information

---

## Auto-Validation

✅ Tous fichiers primaires analyses
✅ Patterns extraits avec exemples
✅ Gotchas identifies avec sources
✅ Niveau de comprehension evalue

**Si comprehension < 70%**: Considerer re-analyse ou gap documentation.

---

## Next

Charger `steps/step-03-synthesize.md` pour generer la documentation.
