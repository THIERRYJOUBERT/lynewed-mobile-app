---
description: Build and run the app on iOS Simulator (bypasses codesign issues)
---

# Build & Run App on iOS Simulator

## Purpose
This workflow builds and runs the Flutter app on the iOS Simulator using a custom script that bypasses codesign issues that occur with standard `flutter run`.

## Why This Script?
- **Codesign Problem:** Standard `flutter run` fails due to codesign issues on this machine
- **Solution:** The script uses `xcodebuild` directly with `CODE_SIGNING_REQUIRED=NO` and manually signs frameworks
- **Benefit:** Reliable builds every time, faster than full clean builds

## Command

// turbo
```bash
cd /Users/leoberthet/Desktop/lynewed_v1 && ./scripts/build_and_run.sh
```

## Options

### Standard Build (incremental, faster)
```bash
./scripts/build_and_run.sh
```

### Clean Build (full rebuild)
```bash
./scripts/build_and_run.sh --clean
```

## What the Script Does

1. **Conditional Cleanup** - Only cleans if `--clean` flag is passed
2. **Dependencies Check** - Updates Flutter packages and CocoaPods only if needed
3. **Build** - Uses `xcodebuild` with codesign disabled
4. **Sign Frameworks** - Manually signs all frameworks in the app bundle
5. **Install** - Installs the app on the simulator
6. **Launch** - Starts the app automatically

## Target Simulator
- **ID:** `04B822AE-18B4-4BDA-86A5-47AB23CA0E2F`
- **Bundle ID:** `com.lynewed.app`

## Viewing Logs
After the app launches, view logs with:
```bash
xcrun simctl spawn 04B822AE-18B4-4BDA-86A5-47AB23CA0E2F log stream --predicate 'processImagePath contains "Runner"' --level debug
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| App not found after build | Run with `--clean` flag |
| Simulator not booted | Run `xcrun simctl boot 04B822AE-18B4-4BDA-86A5-47AB23CA0E2F` first |
| Pod issues | Delete `ios/Pods` and `ios/Podfile.lock`, then run script |

## Notes
- This script is specific to this development machine
- Do NOT use for production builds
- For TestFlight/App Store builds, use proper signing through Xcode
