# Step 01: Fix Warnings

## Objective
Fix all `flutter analyze` warnings in batches, validating after each batch.

## Strategy

### Warning Priority Order
1. **Critical**: `use_build_context_synchronously` (can cause crashes)
2. **Deprecated**: `deprecated_member_use` (will break in future)
3. **Dead code**: `dead_null_aware_expression`, `unused_*`
4. **Style**: `prefer_const_*`, `unnecessary_*`

### Batch Processing

For each batch of max 10 files:

1. **Select batch**: Pick 10 files with same warning type
2. **Fix warnings**: Apply appropriate fixes
3. **Validate**: Run `flutter analyze --no-fatal-infos 2>&1 | grep -c "issues found"`
4. **Log progress**: Append to cleanup-log.md
5. **Update todo**: Mark batch complete

## Fix Patterns

### use_build_context_synchronously
```dart
// BEFORE
await someAsyncOperation();
Navigator.of(context).pop(); // Warning!

// AFTER
await someAsyncOperation();
if (!context.mounted) return;
Navigator.of(context).pop();
```

### deprecated_member_use (MaterialState)
```dart
// BEFORE
MaterialStateProperty.all(...)
MaterialState.hovered

// AFTER
WidgetStateProperty.all(...)
WidgetState.hovered
```

### deprecated_member_use (withOpacity)
```dart
// BEFORE
color.withOpacity(0.5)

// AFTER
color.withValues(alpha: 0.5)
```

### empty_catches
```dart
// BEFORE
} catch (e) {}

// AFTER
} catch (e) {
  debugPrint('Error: $e');
}
```

### prefer_const_constructors
```dart
// BEFORE
Container()
SizedBox()

// AFTER
const Container()
const SizedBox()
```

### unnecessary_getters_setters
```dart
// BEFORE
String _name;
String get name => _name;
set name(String value) => _name = value;

// AFTER
String name;
```

## Execution Loop

```
WHILE warnings_count > 0:
    batch = select_next_batch(priority_order, max=10)

    FOR file IN batch:
        Read file
        Apply fixes for warning type
        Edit file

    result = run `flutter analyze --no-fatal-infos`
    new_count = parse_warning_count(result)

    IF new_count > previous_count:
        ROLLBACK batch
        LOG "Batch caused more warnings, skipping"
        CONTINUE

    LOG to cleanup-log.md:
        "Batch {n}: Fixed {count} {type} warnings in {files}"

    UPDATE TodoWrite progress

    IF 3 consecutive failures:
        LOG "Multiple failures, pausing for review"
        BREAK
```

## Validation
- [ ] Warning count decreased
- [ ] `flutter analyze --no-fatal-infos` still works
- [ ] No new errors introduced
- [ ] Progress logged

## Completion Criteria
- All critical warnings fixed (`use_build_context_synchronously`)
- All deprecated warnings fixed (`deprecated_member_use`)
- Remaining warnings are style-only

## Next Step
When warning count < 50 (style only):
Load `steps/step-02-deps.md`
