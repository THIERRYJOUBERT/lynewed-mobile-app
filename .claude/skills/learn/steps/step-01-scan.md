# Step 01: Scan

> Decouvrir fichiers et structure via 3 agents Haiku en parallele.

---

## Objectif

Scan rapide et cheap du codebase pour identifier tous les fichiers et structures lies au topic.

---

## CRITICAL: Parallel Execution

**Lancer les 3 agents dans UN SEUL message avec 3 appels Task tool.**

```
// CORRECT - Un message, 3 Task calls
Message 1: [Task1, Task2, Task3]

// INCORRECT - Messages sequentiels
Message 1: [Task1]
Message 2: [Task2]
Message 3: [Task3]
```

---

## Agents Configuration

### Agent 1: File Discovery

```yaml
Task tool:
  subagent_type: Explore
  model: haiku
  description: "Scan files for {topic}"
  prompt: |
    Find all files related to "{topic}" in this codebase.

    Search strategies:
    1. Glob for filenames containing topic keywords
    2. Grep for imports/exports related to topic
    3. Check typical locations (lib/features/, lib/core/, etc.)

    Return STRUCTURED output:

    ## Primary Files (core implementation)
    - path/to/file.dart (reason: "main implementation")

    ## Secondary Files (related/supporting)
    - path/to/other.dart (reason: "uses this feature")

    ## Test Files
    - test/path/test.dart (reason: "tests this feature")

    Priority order: Most important files first.
    Include line count estimates if relevant.
```

### Agent 2: Structure Mapping

```yaml
Task tool:
  subagent_type: Explore
  model: haiku
  description: "Map structure for {topic}"
  prompt: |
    Map the organization and relationships for "{topic}".

    Analyze:
    1. Directory structure (where does this live?)
    2. File relationships (what imports what?)
    3. Component hierarchy (parent/child relationships)
    4. Module boundaries (what's internal vs exported?)

    Return STRUCTURED output:

    ## Directory Structure
    ```
    lib/
    └── features/
        └── {topic}/
            ├── providers/
            ├── models/
            └── widgets/
    ```

    ## Key Relationships
    - file_a.dart → imports → file_b.dart (why)

    ## Module Boundaries
    - Public API: [files/exports]
    - Internal: [files that shouldn't be accessed directly]
```

### Agent 3: Dependency Analysis

```yaml
Task tool:
  subagent_type: Explore
  model: haiku
  description: "Analyze deps for {topic}"
  prompt: |
    Identify dependencies and integrations for "{topic}".

    Analyze:
    1. External packages used (from pubspec.yaml)
    2. Internal dependencies (other features/modules)
    3. Database/API integrations
    4. State management connections

    Return STRUCTURED output:

    ## External Dependencies
    - package_name: version (purpose for this topic)

    ## Internal Dependencies
    - lib/core/... (what it provides)
    - lib/shared/... (shared utilities used)

    ## Integrations
    - Supabase tables: [table names]
    - API endpoints: [if applicable]
    - Providers: [Riverpod providers used]
```

---

## Compile Results

Apres les 3 agents, compiler en structure unifiee:

```yaml
scan_results:
  file_list:
    primary:
      - path: "lib/features/auth/..."
        priority: 1
        reason: "Core implementation"
    secondary:
      - path: "lib/shared/..."
        priority: 2
        reason: "Supporting utilities"
    tests:
      - path: "test/..."
        priority: 3
        reason: "Test coverage"

  structure_map:
    root_directory: "lib/features/{topic}/"
    subdirectories: [...]
    relationships: [...]

  dependency_graph:
    external: [...]
    internal: [...]
    integrations: [...]

  stats:
    total_files: N
    primary_files: N
    estimated_complexity: "low" | "medium" | "high"
```

---

## Fallback: No Files Found

Si aucun fichier trouve:

1. **Elargir recherche**: Patterns plus generiques
2. **Suggerer alternatives**: Topics similaires detectes
3. **Si toujours rien**: Documenter gap, demander clarification

```yaml
AskUserQuestion:
  question: "Aucun fichier trouve pour '{topic}'. Le topic existe-t-il dans ce codebase ?"
  header: "Topic inconnu"
  options:
    - label: "Reformuler"
      description: "Je vais preciser le topic"
    - label: "Annuler"
      description: "Arreter l'exploration"
```

---

## Auto-Validation

✅ Au moins 1 fichier primaire trouve
✅ Structure mappee (meme partielle)
✅ Dependances identifiees
✅ Resultats compiles et structures

---

## Depth Behavior

| Depth | Scan Behavior |
|-------|---------------|
| `quick` | Arreter apres scan, passer directement a step-03 |
| `standard` | Continuer vers step-02 |
| `deep` | Continuer vers step-02 avec plus de fichiers |

---

## Next

- Si `depth = quick` → Charger `steps/step-03-synthesize.md`
- Sinon → Charger `steps/step-02-understand.md`
