#!/bin/bash

# ==============================================
# Build & Run Android - Simple & Fast
# ==============================================
# Usage:
#   ./scripts/build_and_run_android.sh          # Run app (incremental)
#   ./scripts/build_and_run_android.sh --clean  # Clean build
# ==============================================

set -e

PROJECT_DIR="/Users/leoberthet/Desktop/lynewed_v1"
EMULATOR_NAME="Medium_Phone_API_36.0"

cd "$PROJECT_DIR"

# Parse arguments
CLEAN_BUILD=false
for arg in "$@"; do
    case $arg in
        --clean)
            CLEAN_BUILD=true
            ;;
    esac
done

# Set environment
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

echo ""
echo "=============================================="
echo "🤖 Build & Run Android - Lynewed"
echo "=============================================="

# Check if emulator is running
if ! adb devices | grep -q "emulator"; then
    echo ""
    echo "🚀 Démarrage de l'émulateur..."
    $ANDROID_HOME/emulator/emulator -avd "$EMULATOR_NAME" -no-snapshot-load &
    
    echo "⏳ Attente du boot..."
    adb wait-for-device
    sleep 8
fi

DEVICE_ID=$(adb devices | grep "emulator" | head -1 | cut -f1)
echo "📱 Device: $DEVICE_ID"

# Clean if requested
if [ "$CLEAN_BUILD" = true ]; then
    echo ""
    echo "🧹 Nettoyage..."
    flutter clean
    flutter pub get
fi

# Run app (flutter run handles incremental builds automatically)
echo ""
echo " Lancement de l'app..."
flutter run -d "$DEVICE_ID"
