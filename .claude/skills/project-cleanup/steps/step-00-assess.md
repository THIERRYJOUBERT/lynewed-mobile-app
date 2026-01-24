# Step 00: Assess Current State

## Objective
Analyze the project's current state and create a prioritized cleanup plan.

## Actions

### 1. Run Initial Analysis

Execute in parallel (3 agents):

**Agent 1 - Warnings Analysis** (model: sonnet):
```
Run `flutter analyze 2>&1` and categorize warnings by:
- Type (deprecated, unused, style, potential bugs)
- File location (lib/features/, lib/pages/, lib/flutter_flow/, etc.)
- Severity (error, warning, info)

Return: Summary table with counts per category.
```

**Agent 2 - Dependencies Analysis** (model: sonnet):
```
Run `flutter pub outdated 2>&1` and categorize:
- Critical updates (major version behind)
- Important updates (minor version behind)
- Patch updates (patch version behind)
- Dependencies with overrides

Return: Prioritized list of updates with risk assessment.
```

**Agent 3 - Architecture Analysis** (model: sonnet):
```
Analyze lib/ structure:
- Count FlutterFlow legacy files (imports flutter_flow)
- Count Clean Architecture files (features/*/domain|data|presentation)
- Identify migration candidates

Return: Migration priority list.
```

### 2. Create Cleanup Plan

Based on agent results, create `cleanup-log.md` with:

```markdown
# Cleanup Log - {date}

## Initial Assessment

### Warnings: {count}
| Category | Count | Files |
|----------|-------|-------|
| deprecated | X | ... |
| unused | X | ... |
| style | X | ... |

### Dependencies: {count_outdated}
| Priority | Package | Current | Latest |
|----------|---------|---------|--------|
| critical | go_router | 12.1.3 | 17.0.1 |
| ... | ... | ... | ... |

### Migration Candidates
| Feature | Files | Complexity | Priority |
|---------|-------|------------|----------|
| ... | ... | ... | ... |

## Progress Log
<!-- Append after each batch -->
```

### 3. Initialize TodoWrite

Create initial todo list:
```
- [pending] Phase 1: Fix deprecated API warnings
- [pending] Phase 1: Fix unused code warnings
- [pending] Phase 1: Fix style warnings
- [pending] Phase 2: Update Supabase dependencies
- [pending] Phase 2: Update Firebase dependencies
- [pending] Phase 2: Update go_router
- [pending] Phase 3: Migrate chat feature
- [pending] Phase 3: Migrate notifications feature
- [pending] Phase 4: Add tests for migrated features
- [pending] Phase 5: Update documentation
```

## Validation
- [ ] cleanup-log.md created with initial assessment
- [ ] TodoWrite initialized with prioritized tasks
- [ ] Warnings count documented
- [ ] Dependencies status documented

## Next Step
Load `steps/step-01-warnings.md`
