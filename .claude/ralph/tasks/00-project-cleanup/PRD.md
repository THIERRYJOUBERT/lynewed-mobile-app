# Feature: Project Cleanup - Zero Warnings

## Vision
Transform the Lynewed Beta Flutter project from a warning-filled codebase into a clean, production-ready application with zero warnings from `flutter analyze`.

## Problem
The project currently has **370 warnings** from `flutter analyze`, including:
- Critical async context issues that can cause crashes
- Deprecated APIs that will break in future Flutter versions
- Empty catch blocks hiding errors
- Numerous style issues reducing code quality

This technical debt makes the codebase harder to maintain and could cause runtime issues.

## Solution
Systematically fix all warnings in priority order:
1. **Critical warnings first** (async context, deprecated APIs)
2. **Code quality warnings** (empty catches, dead code)
3. **Style warnings** (const constructors, naming)

Each story targets a specific warning type in a specific module, making progress trackable and rollback easy.

## User Stories

See `prd.json` for the complete list of 25 stories.

### Phase 1: Critical (Priority 1-3)
- Fix async context warnings in auth, custom_code, features

### Phase 2: Deprecated APIs (Priority 4-13)
- Fix MaterialState, withOpacity, and other deprecated APIs

### Phase 3: Code Quality (Priority 14-23)
- Fix style warnings (const, unused, naming)

### Phase 4: Verification (Priority 24-25)
- Final verification and documentation

## Technical Notes

### Commands
```bash
# Verify after each change
flutter analyze --no-fatal-infos

# Full check (target)
flutter analyze --fatal-infos
```

### Constraints
- Never break the build
- Work in small batches (max 10 files)
- Commit after each completed story
- Log learnings in progress.txt

### Files by Priority
- **High**: lib/auth/, lib/core/design/
- **Medium**: lib/features/, lib/custom_code/
- **Low**: lib/backend/schema/, test/
