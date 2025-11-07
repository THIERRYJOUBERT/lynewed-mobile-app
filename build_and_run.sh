#!/bin/bash
# Script de build, signature et lancement automatique
# Usage: ./build_and_run.sh

set -e

SIMULATOR_ID="53D436C5-C951-4341-B4B4-A3206DBD2D22"
BUNDLE_ID="com.lynewed.app"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🚀 Lynewed Alpha - Build & Run Script"
echo "======================================"

# 1. Nettoyage
echo "🧹 Nettoyage..."
cd "$PROJECT_DIR"
flutter clean

# 2. Installation dépendances
echo "📦 Installation des dépendances..."
flutter pub get
cd ios
pod install
cd ..

# 3. Build
echo "🔨 Build de l'application..."
cd ios
xcodebuild \
  -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=YES \
  | grep -E "(BUILD|SUCCEEDED|FAILED|error:)" || true
cd ..

# 4. Trouver l'app
echo "🔍 Recherche du bundle..."
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/Runner-*/Build/Products/Debug-iphonesimulator -name "Runner.app" -type d 2>/dev/null | head -1)

if [ -z "$APP_PATH" ]; then
  echo "❌ App non trouvée !"
  exit 1
fi

echo "✅ App trouvée: $APP_PATH"

# 5. Signature de TOUS les frameworks
echo "🔏 Signature de tous les frameworks..."
cd "$APP_PATH/Frameworks"
for framework in *.framework; do
  if [ -d "$framework" ]; then
    echo "  → Signing: $framework"
    codesign --force --sign - --timestamp=none "$framework" > /dev/null 2>&1 || true
  fi
done

# 6. Signature de l'app
echo "🔏 Signature de l'application..."
codesign --force --sign - --deep --timestamp=none "$APP_PATH" > /dev/null 2>&1

# 7. Installation
echo "📲 Installation sur le simulateur..."
xcrun simctl uninstall "$SIMULATOR_ID" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"

# 8. Lancement
echo "🚀 Lancement de l'application..."
xcrun simctl launch "$SIMULATOR_ID" "$BUNDLE_ID"

echo ""
echo "======================================"
echo "✅ Application lancée avec succès !"
echo "======================================"
echo ""
echo "Pour voir les logs :"
echo "xcrun simctl spawn $SIMULATOR_ID log stream --predicate 'processImagePath contains \"Runner\"' --level debug"
