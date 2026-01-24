# Cleanup Strategy Reference

> Strategy document for the project-cleanup workflow.
> Contains specific decisions and context for this project.

## Project Context

### Lynewed Beta - Flutter App
- **Type**: Wedding planning app
- **Backend**: Supabase
- **Origin**: FlutterFlow → Custom Flutter
- **Status**: Production (iOS + Android)

### Initial State (2026-01-24)
- **Warnings**: 370 (flutter analyze)
- **Outdated deps**: 55+
- **FlutterFlow files**: 186 (60% of codebase)
- **Clean Architecture**: 40% (Map module 100%)
- **Tests**: Only Map module (7 test files)

## Strategic Decisions

### 1. Migration Approach
**Decision**: Total migration to Clean Architecture
**Reason**: User wants professional-grade project for ongoing client work
**Template**: Use Map module as reference (100% complete)

### 2. Dependency Updates
**Decision**: Incremental by priority
**Reason**: Minimize risk of breaking changes
**Order**: Supabase → Firebase → Minor → Major (go_router last)

### 3. Test Level
**Decision**: Map-level coverage (domain + data + some widget)
**Reason**: Good balance of coverage and effort

### 4. Execution Mode
**Decision**: Ralph (autonomous headless)
**Reason**: Long-running task, can run overnight

## Warning Categories (370 total)

| Category | Count | Priority | Fix Pattern |
|----------|-------|----------|-------------|
| use_build_context_synchronously | ~25 | CRITICAL | Add mounted check |
| deprecated_member_use | ~50 | HIGH | Update APIs |
| empty_catches | ~15 | HIGH | Add logging |
| prefer_const_constructors | ~100 | MEDIUM | Add const |
| unnecessary_* | ~50 | LOW | Remove |
| constant_identifier_names | ~20 | LOW | Rename or ignore |
| type_literal_in_constant_pattern | ~20 | LOW | Update pattern |

## Dependency Update Plan

### Phase 1: Remove Overrides (if possible)
- http: 1.4.0 (try removing)
- rxdart: 0.27.7 (try removing)
- uuid: ^4.0.0 (try removing)

### Phase 2: Supabase (Critical)
- supabase: 2.7.0 → 2.10.2
- supabase_flutter: 2.9.0 → 2.12.0
- gotrue: 2.12.0 → 2.18.0
- postgrest: 2.4.2 → 2.6.0
- realtime_client: 2.5.0 → 2.7.0

### Phase 3: Firebase
- firebase_core: 3.15.2 → 4.4.0
- firebase_messaging: 15.2.10 → 16.1.1

### Phase 4: Careful Updates
- go_router: 12.1.3 → 17.0.1 (5 major versions!)
- google_fonts: 6.1.0 → 8.0.0
- flutter_lints: 4.0.0 → 6.0.0

## Migration Targets

### Priority 1: Complete Partial Migrations
- lib/features/chat/ (has domain/data/presentation but needs cleanup)
- lib/features/notifications/ (has domain/presentation)

### Priority 2: Migrate Critical Pages
- lib/pages/shared/ (11 pages)
- lib/pages/bride/ (5 pages)
- lib/pages/pro/ (4 pages)

### Keep As-Is (Low Priority)
- lib/flutter_flow/ (utilities, keep for now)
- lib/backend/schema/ (Supabase integration)

## Quality Gates

### After Each Batch
```bash
flutter analyze --no-fatal-infos
# Must not increase warning count
```

### After Each Feature Migration
```bash
flutter analyze --no-fatal-infos
flutter test test/features/{feature}/
# All tests must pass
```

### Before Completion
```bash
flutter analyze --fatal-infos  # Target: 0 warnings
flutter test                   # All tests pass
flutter build apk --release    # Build succeeds
```

## Ralph Execution Parameters

### Session Configuration
- **Max duration**: 8 hours (overnight)
- **Batch size**: 10 files max
- **Retry limit**: 3 per batch
- **Break condition**: 3+ consecutive failures

### Progress Indicators
- TodoWrite updates
- cleanup-log.md entries
- Warning count reduction

### Monitoring
```bash
# Check progress
tail -f cleanup-log.md

# Check warnings
flutter analyze 2>&1 | tail -5

# Check todos
# (visible in Ralph logs)
```

## Files Created/Modified by Cleanup

### New Files
- cleanup-log.md (progress log)
- lib/features/*/README.md (feature docs)
- test/features/*/*.dart (new tests)

### Modified Files
- pubspec.yaml (dependencies)
- CLAUDE.md (updated docs)
- README.md (updated docs)
- lib/**/*.dart (warning fixes, migrations)
