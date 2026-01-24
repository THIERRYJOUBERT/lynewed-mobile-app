# Step 03: Synthesize

> Opus génère la documentation LLM-optimized à partir des analyses.

---

## Objectif

Transformer les résultats d'analyse en documentation dense, bien organisée, et parfaitement adaptée pour la relecture par Claude.

---

## Input from Previous Steps

```yaml
Available:
  from_scan:
    - file_list: Fichiers prioritisés
    - structure_map: Organisation
    - dependency_graph: Dépendances

  from_understand:
    - impl_analysis: Analyse d'implémentation détaillée
    - patterns: Patterns et conventions extraits
    - gotchas: Edge cases et pièges identifiés
    - comprehension_level: Score de compréhension
```

---

## Output Structure

Créer le dossier `workspace/current/{topic_sanitized}/` avec :

```
workspace/current/{topic_sanitized}/
├── INDEX.md              # Navigation et résumé exécutif
├── architecture.md       # Structure et design decisions
├── key-files.md          # Fichiers clés avec explications
├── gotchas.md            # Pièges et edge cases
└── context.md            # Contexte pour future sessions Claude
```

---

## Documentation Guidelines

### Format LLM-Optimized

```yaml
Principles:
  - Dense: Maximum d'information par ligne
  - Sourcé: Chaque statement a une référence `file:line`
  - Structuré: Headers hiérarchiques pour navigation rapide
  - Scannable: Listes, tableaux, code blocks
  - Daté: Date de génération pour fraîcheur

Avoid:
  - Prose verbose
  - Explications redondantes
  - Généralités évidentes
  - Commentaires subjectifs sans source
```

### Templates par Fichier

#### INDEX.md

```markdown
# {Topic} - Knowledge Base

> Generated: {date} | Depth: {depth} | Comprehension: {score}%

## Quick Reference

| Aspect | Location | Key Insight |
|--------|----------|-------------|
| Entry point | `path/file.dart:line` | What it does |
| Core logic | `path/file.dart:line` | How it works |
| Data model | `path/file.dart:line` | Structure |

## Files in This Knowledge Base

| File | Purpose | When to Read |
|------|---------|--------------|
| architecture.md | Design decisions | Understanding WHY |
| key-files.md | File-by-file breakdown | Finding WHERE |
| gotchas.md | Pitfalls and edge cases | Avoiding BUGS |
| context.md | Session context | Starting NEW CONVERSATION |

## Summary

[3-5 bullet points capturing the essence of {topic}]

## Quick Navigation

- Need to understand data flow? → architecture.md#data-flow
- Looking for specific file? → key-files.md
- Debugging an issue? → gotchas.md
- Starting fresh? → context.md
```

#### architecture.md

```markdown
# {Topic} - Architecture

> Source: Codebase analysis | Generated: {date}

## Overview

[2-3 sentences describing the architecture]

## Component Diagram

```
[ASCII diagram showing relationships]
```

## Design Decisions

### Decision 1: {What}
- **Choice**: {What was chosen}
- **Why**: {Reasoning} (`file.dart:line`)
- **Trade-offs**: {What was sacrificed}

### Decision 2: ...

## Data Flow

```
[Flow diagram with file:line references]
Input → Component A (file:10) → Component B (file:50) → Output
```

## Dependencies

| Internal | External |
|----------|----------|
| `package:x` - purpose | `pub:y` - purpose |

## Extension Points

Where to add new functionality:
- For X: modify `file.dart:line`
- For Y: extend `class` at `file.dart:line`
```

#### key-files.md

```markdown
# {Topic} - Key Files Reference

> Total files: N | Primary: N | Secondary: N

## Primary Files (Must Understand)

### `path/to/file.dart`

**Purpose**: One-line description

**Key Components**:
| Line | Component | Role |
|------|-----------|------|
| 15-45 | `ClassName` | What it does |
| 50-80 | `functionName()` | What it does |

**Data Structures**:
```dart
// From line 20
class Example {
  final String key;  // Purpose
}
```

**Entry Points**:
- `main()` at line 10 - Called when...
- `initialize()` at line 25 - Called by...

**Dependencies**:
- Imports: `package:x`, `../relative`
- Imported by: `other_file.dart`

---

### `path/to/another_file.dart`
[Same structure]

## Secondary Files (Reference)

| File | Purpose | Key Lines |
|------|---------|-----------|
| `file.dart` | Brief purpose | 10-50 |
```

#### gotchas.md

```markdown
# {Topic} - Gotchas & Edge Cases

> Critical: N | Important: N | Minor: N

## Critical (Must Know)

### 1. {Issue Title}

- **Location**: `file.dart:line`
- **Symptom**: What goes wrong
- **Cause**: Why it happens
- **Fix/Mitigation**: How to handle

```dart
// Wrong
badCode();

// Correct
goodCode();
```

### 2. ...

## Important (Should Know)

| Issue | Location | Impact | Mitigation |
|-------|----------|--------|------------|
| Brief | `file:line` | What breaks | How to fix |

## Minor (Nice to Know)

- At `file:line`: Minor quirk description

## Technical Debt

| Location | Issue | Priority |
|----------|-------|----------|
| `file:line` | TODO: description | High/Med/Low |

## Inconsistencies

| Location A | Location B | Inconsistency |
|------------|------------|---------------|
| `file_a:10` | `file_b:20` | X vs Y |
```

#### context.md

```markdown
# {Topic} - Session Context

> Use this file to quickly onboard a new Claude conversation about {topic}.

## Copy-Paste Context

```
I'm working on {topic} in the {{PROJECT_NAME}} app.

Key files:
- `path/main_file.dart` - Main logic
- `path/model.dart` - Data structures

Current understanding:
- [Key point 1]
- [Key point 2]

Known gotchas:
- [Gotcha 1 with file:line]
```

## Key Concepts

| Concept | Definition | Source |
|---------|------------|--------|
| Term | What it means | `file:line` |

## Common Tasks

### Task: Add new X

1. Modify `file.dart:line` to...
2. Update `other.dart:line` to...
3. Test with...

### Task: Debug Y

1. Check `file.dart:line` for...
2. Verify state at...

## Related Documentation

- FD-XX: Related functional doc
- Epic-YY: Related epic
- PRD Section: Related PRD section
```

---

## Generation Process

```yaml
For each output file:
  1. Select relevant data from understand_results
  2. Apply template structure
  3. Fill with dense, sourced content
  4. Validate all file:line references exist
  5. Write to workspace/current/{topic_sanitized}/
```

### Execution Order

```
1. Create directory: workspace/current/{topic_sanitized}/
2. Generate INDEX.md (needs overview of all content)
3. Generate architecture.md (design decisions)
4. Generate key-files.md (file breakdown)
5. Generate gotchas.md (edge cases)
6. Generate context.md (session starter)
```

---

## Quality Criteria

```yaml
Each file must have:
  - [ ] Date de génération
  - [ ] Toutes références file:line vérifiables
  - [ ] Structure scannable (headers, tables, lists)
  - [ ] Contenu dense (pas de fluff)
  - [ ] Navigation claire

INDEX.md specifically:
  - [ ] Summary captures essence in <5 bullets
  - [ ] Quick reference table with key locations
  - [ ] Links to other files with purpose

context.md specifically:
  - [ ] Copy-paste ready context block
  - [ ] Common tasks with step-by-step
```

---

## Compile Results

```yaml
synthesis_results:
  output_dir: "workspace/current/{topic_sanitized}/"
  files_created:
    - name: "INDEX.md"
      size_lines: N
      key_sections: [...]
    - name: "architecture.md"
      size_lines: N
      decisions_documented: N
    - name: "key-files.md"
      size_lines: N
      files_documented: N
    - name: "gotchas.md"
      size_lines: N
      issues_documented: N
    - name: "context.md"
      size_lines: N
      tasks_documented: N

  quality_metrics:
    total_references: N
    verified_references: N
    density_score: "high" | "medium" | "low"
```

---

## Next

Charger `steps/step-04-validate.md` pour la review adversariale.
