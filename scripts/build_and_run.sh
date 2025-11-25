#!/bin/bash
# Script de build, signature et lancement automatique
# Usage: ./build_and_run.sh

set -e

SIMULATOR_ID="04B822AE-18B4-4BDA-86A5-47AB23CA0E2F"
BUNDLE_ID="com.lynewed.app"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

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

# 4. Trouver l'app la plus récente
echo "🔍 Recherche du bundle le plus récent..."
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/Runner-*/Build/Products/Debug-iphonesimulator -name "Runner.app" -type d 2>/dev/null | xargs ls -td | head -1)

if [ -z "$APP_PATH" ]; then
  echo "❌ App non trouvée !"
  exit 1
fi

echo "✅ App trouvée: $APP_PATH"

# 4.5 Copier le .env dans le bundle AVANT signature
echo "📋 Copie du .env dans le bundle..."
cp "$PROJECT_DIR/.env" "$APP_PATH/Frameworks/App.framework/flutter_assets/.env"
if [ $? -eq 0 ]; then
  echo "✅ .env copié avec succès dans le bundle"
else
  echo "❌ Erreur lors de la copie du .env"
  exit 1
fi

# 5. Signature de TOUS les frameworks (APRÈS copie du .env)
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
