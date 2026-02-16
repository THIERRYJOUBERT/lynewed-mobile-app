# S03 - Deep Links Diagnostic + Fix - Summary of Corrections

> **Date**: 2026-02-16
> **Story**: S03-deep-links-diagnostic-fix.md
> **Phase**: Phase 1 COMPLETE (Phase 2 blocked on server deployment)

---

## Critical Issues Corrected

### 1. Production Files State Documented

**Problem**: The story assumed the `.well-known/` files might not exist or were completely missing.

**Reality Discovered**:
- `apple-app-site-association` EXISTS but served with **wrong Content-Type** (octet-stream instead of json)
- `assetlinks.json` EXISTS but contains **"TODO" placeholder** instead of real SHA-256 fingerprint

**Impact**:
- Android App Links: **BROKEN** (invalid fingerprint)
- iOS Universal Links: **UNCERTAIN** (wrong Content-Type, iOS may be tolerant but not guaranteed)

**Correction Applied**:
- Added critical state documentation section in story
- Updated all AC and templates to reflect actual discovered issues

### 2. SHA-256 Android Extraction Method

**Problem**: Story suggested using `gradlew signingReport` which fails due to missing Agora plugin.

**Solution Applied**:
- Documented that `gradlew signingReport` fails locally (agora_rtc_engine plugin directory missing)
- Used direct `keytool` command successfully:
  ```bash
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
  ```
- Extracted real SHA-256: `A2:5B:89:F6:E9:43:4A:DF:47:F3:2C:7F:72:F7:16:DC:6D:F4:5C:1B:86:06:95:90:88:D5:98:C7:7B:EF:06:44`
- Added note in story about the workaround

### 3. Templates with Placeholders

**Problem**: Original story templates had placeholders like `{APPLE_TEAM_ID}` and `{SHA256_FINGERPRINT}`.

**Issue**: Non-testable without deployment, Thierry would need to manually replace values.

**Solution Applied**:
- Created templates with **REAL values** extracted from the project:
  - `apple-app-site-association`: Team ID = `G234APMW4U`
  - `assetlinks.json`: SHA-256 = actual fingerprint (not "TODO")
- Templates are now **ready to deploy as-is** (no manual replacement needed)

### 4. Story Divided into 2 Phases

**Problem**: Original story was not completable without server access (Thierry).

**Solution Applied**:
- **Phase 1** (Completable immediately): Prepare all files, extract values, fix code, test
- **Phase 2** (Blocked external): Deploy files, test real deep links on devices

**Benefit**: Story can be merged after Phase 1 with clear "blocked by server deployment" status.

### 5. Content-Type Issue Not Mentioned

**Problem**: Story didn't mention the Content-Type issue discovered in production.

**Solution Applied**:
- Added nginx configuration example in DEPLOY-GUIDE.md
- Added specific test step to verify Content-Type after deployment
- Updated AC to check for this issue

---

## Files Delivered

### Templates (Ready to Deploy)

| File | Location | Status |
|------|----------|--------|
| `apple-app-site-association` | `docs/epics/EPIC-15-BUGFIX/deep-links/` | ✅ REAL values |
| `assetlinks.json` | `docs/epics/EPIC-15-BUGFIX/deep-links/` | ✅ REAL values (debug SHA-256) |

**Note**: For production Google Play, Thierry will need to add the release keystore SHA-256 (instructions provided in DEPLOY-GUIDE.md).

### Documentation

| File | Location | Purpose |
|------|----------|---------|
| `DEPLOY-GUIDE.md` | `docs/epics/EPIC-15-BUGFIX/deep-links/` | Complete deployment guide for Thierry |
| `CORRECTIONS-SUMMARY.md` | `docs/epics/EPIC-15-BUGFIX/deep-links/` | This file |

### Code Changes

| File | Change | Status |
|------|--------|--------|
| `lib/core/navigation/routes.dart` | Comments: `lynewed.app` → `lynewed.com` (lines 246, 251) | ✅ Done |

### Verification

| Check | Result |
|-------|--------|
| `FlutterDeepLinkingEnabled` iOS | ✅ `false` (Info.plist line 38) |
| `flutter_deeplinking_enabled` Android | ✅ `false` (AndroidManifest.xml line 51) |
| QR scanner supports both domains | ✅ Regex supports `app\|com` (qr_scanner_sheet.dart line 79) |
| Unit tests | ✅ 39/39 pass (deep_link_handler_test.dart) |
| Lint | ✅ No issues (routes.dart) |

---

## Values Extracted

### iOS (apple-app-site-association)

```
Apple Team ID: G234APMW4U
Bundle ID: com.lynewed.app
Path pattern: /join/*
```

Source: `ios/Runner.xcodeproj/project.pbxproj`

### Android (assetlinks.json)

```
Package name: com.lynewed.app
SHA-256 (debug): A2:5B:89:F6:E9:43:4A:DF:47:F3:2C:7F:72:F7:16:DC:6D:F4:5C:1B:86:06:95:90:88:D5:98:C7:7B:EF:06:44
```

Source: `keytool -list -v -keystore ~/.android/debug.keystore`

**Missing**: SHA-256 release keystore (Thierry needs to provide)

---

## Definition of Done - Phase 1

- [x] Fichiers `.well-known/` diagnostiques (WebFetch)
- [x] Etat critique documente (assetlinks.json = "TODO", AASA = wrong Content-Type)
- [x] Apple Team ID extrait (G234APMW4U)
- [x] SHA-256 debug extrait (A2:5B:89:F6:...)
- [x] FlutterDeepLinkingEnabled verified = false (iOS + Android)
- [x] Templates generated with REAL values (no placeholders)
- [x] Deployment guide created (DEPLOY-GUIDE.md)
- [x] Code comments corrected (routes.dart)
- [x] QR scanner verified (supports both domains)
- [x] Unit tests pass (39/39)

**Phase 1 Status**: ✅ **COMPLETE**

---

## Next Steps (Phase 2 - Blocked)

**Blocker**: Thierry needs to deploy the corrected files on lynewed.com server

**Actions for Thierry**:
1. Deploy `apple-app-site-association` with nginx config for Content-Type
2. Deploy `assetlinks.json` with real SHA-256 (replace "TODO")
3. (Optional) Add release keystore SHA-256 to assetlinks.json
4. Verify files via curl
5. Notify team when deployed

**Actions for Dev Team (after deployment)**:
1. Verify files via curl (Content-Type + content)
2. Test deep link on iOS device: `https://lynewed.com/join/TESTCODE`
3. Test deep link on Android device: `https://lynewed.com/join/TESTCODE`
4. Verify fallback to stores if app not installed
5. Update story status to DONE

---

## References

- Story: `docs/epics/EPIC-15-BUGFIX/stories/S03-deep-links-diagnostic-fix.md`
- Challenge Report: `docs/epics/EPIC-15-BUGFIX/CHALLENGE-REPORT.md`
- Bug Report: `docs/THIERRY-FEEDBACK-2026-02-16.md` (BUG-01c)
- Apple Universal Links: https://developer.apple.com/documentation/xcode/allowing-apps-and-websites-to-link-to-your-content
- Android App Links: https://developer.android.com/training/app-links/verify-android-applinks
