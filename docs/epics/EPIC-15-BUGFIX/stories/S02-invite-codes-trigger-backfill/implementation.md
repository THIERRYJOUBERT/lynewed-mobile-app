# Implementation Notes - S02 Invite Codes Trigger + Backfill

> Completed: 2026-02-16
> Mode: autonomous

## Summary

Fixed invite code generation for all weddings in production. The trigger and functions were already deployed but the `regenerate_wedding_invite_code()` function was missing a retry loop for uniqueness. Applied the fix and backfilled 7 weddings with NULL codes. Also regenerated 1 invalid test code (`TEST1234`).

## Actions Performed

### 1. Diagnostic (READ-ONLY)

| Check | Result |
|-------|--------|
| Trigger `trg_generate_invite_code` | Present, active (`tgenabled = 'O'`) |
| 3 SQL functions | All present |
| Weddings state | 7/9 with `invite_code = NULL`, 1 with invalid `TEST1234` |

### 2. Migration Applied

**Name**: `fix_regenerate_invite_code_retry_loop`

Updated `regenerate_wedding_invite_code()` to include:
- Retry loop (max 10 attempts)
- Uniqueness check before UPDATE
- RAISE EXCEPTION if max attempts exceeded

The production version was the old single-attempt version despite the local migration file having the fix.

### 3. Backfill Executed

- 7 weddings with NULL codes processed
- Advisory lock (`pg_try_advisory_lock(8675309)`) acquired
- Exception handling per wedding (subtransaction)
- All 7 succeeded, 0 errors

### 4. Invalid Code Fixed

- Wedding `154e27f6` had `TEST1234` (contains `1` - excluded char)
- Regenerated to valid code `7U48GNA8`

### 5. Trigger Test

- INSERT + ROLLBACK confirmed trigger generates code automatically
- Test wedding received `R2T8WKVN` with 30-day expiration

## Validation Results

| Check | Expected | Actual | Status |
|-------|----------|--------|--------|
| NULL codes | 0 | 0 | PASS |
| Duplicate codes | 0 rows | 0 rows | PASS |
| Invalid format | 0 rows | 0 rows | PASS |
| Invalid expiration | 0 rows | 0 rows | PASS |
| Trigger fires on INSERT | code generated | `R2T8WKVN` | PASS |

## Technical Decisions

| Decision | Rationale |
|----------|-----------|
| Applied migration via MCP (not local file) | Function already existed in prod but was old version. `CREATE OR REPLACE` updates in-place. |
| Regenerated `TEST1234` | Code contained excluded character `1`, would fail format validation |
| Used advisory lock in backfill | Prevents concurrent execution if accidentally run twice |

## Files Changed

### Database (Production)
- **Function `regenerate_wedding_invite_code`**: Updated with retry loop (via `apply_migration`)
- **Table `weddings`**: 8 rows updated (7 backfill + 1 regeneration)

### Documentation
- `docs/epics/EPIC-15-BUGFIX/stories/S02-invite-codes-trigger-backfill.md`: Status → Done
- `docs/epics/EPIC-15-BUGFIX/TRACKING.md`: S02 marked Done, metrics updated

### No Flutter Changes
The UI already handles both states correctly (`hasCode` → show code, `!hasCode` → show "Generating..."). Now that all codes exist, the UI works as expected.

## Notes for Future

- Invite codes expire after 30 days. The `regenerate_wedding_invite_code()` function can be called to renew.
- The backfill set all expirations to 30 days from 2026-02-16. Monitor around 2026-03-18.
- If new weddings are created, the trigger handles code generation automatically.
