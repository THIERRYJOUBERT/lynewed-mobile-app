# Build & Run App on Android Emulator

## Purpose
This workflow builds and runs the Flutter app on the Android Emulator.

## Command

// turbo
```bash
cd /Users/leoberthet/Desktop/lynewed_v1 && ./scripts/build_and_run_android.sh
```

## Options

### Standard Build (incremental)
```bash
./scripts/build_and_run_android.sh
```

### Clean Build (full rebuild)
```bash
./scripts/build_and_run_android.sh --clean
```

## What the Script Does

1. **Start Emulator** - Boots Android emulator if not running
2. **Run App** - Uses `flutter run` with incremental builds + hot reload

## Target Emulator
- **Name:** `Medium_Phone_API_36.0`
- **Package:** `com.lynewed.app`

## Hot Reload
Once the app is running, use these keys in the terminal:
- `r` - Hot reload
- `R` - Hot restart
- `q` - Quit

## Viewing Logs
```bash
adb logcat | grep -E "(flutter|com.lynewed.app)"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Emulator won't start | Run `flutter emulators --launch Medium_Phone_API_36.0` |
| Build fails | Run with `--clean` flag |
| App not launching | Check `adb devices` |

## Notes
- Keep emulator running for faster subsequent launches
- Do NOT use for production builds
