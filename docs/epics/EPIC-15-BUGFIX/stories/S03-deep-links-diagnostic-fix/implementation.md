# Implementation Notes - S03 Deep Links Diagnostic + Fix

> Completed: 2026-02-16
> Mode: auto

## Summary

Phase 1 of deep links diagnostic and fix. Diagnosed server-side `.well-known/` file issues, created corrected templates with real values (Apple Team ID, Android SHA-256), fixed domain inconsistencies in code comments, and created a complete deployment guide for Thierry.

Phase 2 (actual server deployment) is blocked pending Thierry's access to lynewed.com server.

## Files Changed

### Created
- `docs/epics/EPIC-15-BUGFIX/deep-links/apple-app-site-association`: iOS Universal Links config with real Team ID `G234APMW4U`
- `docs/epics/EPIC-15-BUGFIX/deep-links/assetlinks.json`: Android App Links config with real SHA-256 debug fingerprint
- `docs/epics/EPIC-15-BUGFIX/deep-links/DEPLOY-GUIDE.md`: Complete deployment guide for Thierry (nginx config, tests, troubleshooting)
- `docs/epics/EPIC-15-BUGFIX/deep-links/CORRECTIONS-SUMMARY.md`: Summary of corrections applied

### Modified
- `lib/core/navigation/routes.dart`: Comments updated `lynewed.app` -> `lynewed.com` (lines 246, 251)
- `lib/features/auth/presentation/widgets/qr_scanner_sheet.dart`: Comment updated `lynewed.app` -> `lynewed.com` (line 76)

## Technical Decisions

| Decision | Rationale |
|----------|-----------|
| Use `lynewed.com` as canonical domain | All runtime code and entitlements already use it; EPIC-09/S06 spec was incorrect |
| Keep regex support for both `app` and `com` | Backward compatibility for any existing QR codes |
| Debug SHA-256 only in assetlinks.json | Release keystore not available locally; Thierry will add production fingerprint |
| Phase 1/Phase 2 split | Server deployment requires external access (Thierry) |

## Challenges

- `gradlew signingReport` failed due to missing Agora plugin locally; used `keytool` directly instead
- Server files exist but are misconfigured: `assetlinks.json` has "TODO" as SHA-256, AASA served with wrong Content-Type

## Tests

- `test/core/navigation/deep_link_handler_test.dart`: 39 tests covering HTTPS links, custom scheme, edge cases (all pass)

## Notes for Future

- Phase 2 requires Thierry to deploy files from `docs/epics/EPIC-15-BUGFIX/deep-links/` to `lynewed.com/.well-known/`
- Release keystore SHA-256 must be added to `assetlinks.json` for production Android App Links
- S05 (Edge Function invitation) must use `lynewed.com` not `lynewed.app`
