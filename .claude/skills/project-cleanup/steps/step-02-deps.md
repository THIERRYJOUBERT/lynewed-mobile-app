# Step 02: Update Dependencies

## Objective
Update dependencies incrementally, testing after each update to ensure stability.

## Strategy

### Update Priority Order
1. **Supabase ecosystem** (backend critical)
2. **Firebase** (notifications)
3. **Minor updates** (low risk)
4. **Major updates** (breaking changes possible)

### Approach
- Update ONE dependency at a time for major updates
- Group minor/patch updates (max 5 at a time)
- Always test build after each update
- Resolve dependency_overrides if possible

## Execution

### Phase 1: Remove dependency_overrides

Check if overrides are still needed:

```bash
# Test removing http override
# In pubspec.yaml, remove http: 1.4.0 from dependency_overrides
flutter pub get
# If success, keep it. If conflict, document why.
```

### Phase 2: Supabase Updates

Update in order:
1. `supabase: 2.7.0 → latest`
2. `supabase_flutter: 2.9.0 → latest`
3. Related packages (gotrue, postgrest, realtime_client, storage_client, functions_client)

After each:
```bash
flutter pub get
flutter analyze --no-fatal-infos
flutter test  # If tests exist
```

### Phase 3: Firebase Updates

1. `firebase_core: ^3.14.0 → latest`
2. `firebase_messaging: ^15.2.7 → latest`

### Phase 4: Major Updates (Careful!)

These have breaking changes - update ONE at a time:

1. **go_router**: 12.1.3 → latest
   - Read changelog for breaking changes
   - Update navigation code if needed
   - Test all navigation paths

2. **google_fonts**: 6.1.0 → latest
   - May have API changes

3. **flutter_lints**: 4.0.0 → 6.0.0
   - Will add new lint rules (more warnings)

### Phase 5: Minor Updates

Group safe updates:
```yaml
# Low-risk updates (patch/minor versions)
flutter_animate: latest
percent_indicator: latest
page_transition: latest
easy_debounce: latest
# etc.
```

## Validation After Each Update

```bash
# Quick validation
flutter pub get && flutter analyze --no-fatal-infos

# Full validation (for major updates)
flutter pub get && flutter analyze --no-fatal-infos && flutter test
```

## Logging

After each update batch:
```markdown
## Dependency Update - {date} {time}

### Updated
| Package | From | To | Status |
|---------|------|-----|--------|
| supabase | 2.7.0 | 2.10.2 | ✅ |

### Validation
- flutter pub get: ✅
- flutter analyze: ✅ (X warnings)
- flutter test: ✅ / ⚠️ / N/A

### Notes
- Any breaking changes or issues noted here
```

## Rollback Strategy

If update breaks build:
1. Revert pubspec.yaml change
2. Run `flutter pub get`
3. Log the issue
4. Continue with next update

## Completion Criteria
- dependency_overrides removed or documented
- Supabase packages updated
- Firebase packages updated
- Major packages updated (or documented if blocked)
- `flutter pub outdated` shows minimal upgrades remaining

## Next Step
Load `steps/step-03-migration.md`
