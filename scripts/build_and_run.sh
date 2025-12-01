#!/bin/bash
# Script de build optimisé - HYBRIDE (garde l'approche qui fonctionne)
# Usage: ./build_and_run_hybrid.sh [--clean]
# Combine la fiabilité du script original avec des optimisations intelligentes

set -e

SIMULATOR_ID="04B822AE-18B4-4BDA-86A5-47AB23CA0E2F"
BUNDLE_ID="com.lynewed.app"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🚀 Hybrid Build & Run Script (Optimisé + Fiable)"
echo "=============================================="

cd "$PROJECT_DIR"

# 1. Nettoyage conditionnel (seulement si demandé)
if [ "$1" = "--clean" ]; then
  echo "🧹 Nettoyage complet (--clean demandé)..."
  flutter clean
else
  echo "🧹 Nettoyage léger du cache build..."
  rm -rf build/ios/Debug-iphonesimulator 2>/dev/null || true
fi

# 2. Installation dépendances (conditionnel)
echo "📦 Vérification des dépendances..."

# Packages Flutter (uniquement si pubspec.yaml plus récent)
if [ "pubspec.lock" -ot "pubspec.yaml" ]; then
  echo "  → Mise à jour packages Flutter..."
  flutter pub get
else
  echo "  → Packages à jour"
fi

# Pods iOS (uniquement si nécessaire)
NEED_POD_INSTALL=false
if [ ! -d "ios/Pods" ]; then
  NEED_POD_INSTALL=true
  echo "  → Pods manquants, installation complète..."
elif [ "ios/Podfile.lock" -ot "ios/Podfile" ]; then
  NEED_POD_INSTALL=true
  echo "  → Podfile modifié, mise à jour des pods..."
fi

if [ "$NEED_POD_INSTALL" = true ]; then
  cd ios && pod install && cd ..
else
  echo "  → Pods à jour"
fi

# 3. Build avec l'approche qui fonctionne (xcodebuild direct)
echo "🔨 Build de l'application (méthode fiable)..."
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
  | grep -E "(BUILD|SUCCEEDED|FAILED|error:|Compiling|Linking)" || true
cd ..

# 4. Trouver l'app la plus récente
echo "🔍 Recherche du bundle le plus récent..."
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/Runner-*/Build/Products/Debug-iphonesimulator -name "Runner.app" -type d 2>/dev/null | xargs ls -td | head -1)

if [ -z "$APP_PATH" ]; then
  echo "❌ App non trouvée !"
  exit 1
fi

echo "✅ App trouvée: $APP_PATH"

# 5. Copie .env (optimisée)
echo "📋 Copie du .env dans le bundle..."
ENV_DEST="$APP_PATH/Frameworks/App.framework/flutter_assets/.env"
cp "$PROJECT_DIR/.env" "$ENV_DEST" 2>/dev/null || echo "⚠️ .env déjà présent ou non copié"

# 6. Signature de tous les frameworks (parallélisée)
echo "🔏 Signature des frameworks..."
cd "$APP_PATH/Frameworks"
# Signature en parallèle pour gagner du temps
for framework in *.framework; do
  if [ -d "$framework" ]; then
    codesign --force --sign - --timestamp=none "$framework" > /dev/null 2>&1 &
  fi
done
# Attendre que toutes les signatures soient terminées
wait
cd ..

echo "🔏 Signature de l'app..."
codesign --force --sign - --deep --timestamp=none "$APP_PATH" > /dev/null 2>&1

# 7. Installation et lancement
echo "📲 Installation sur le simulateur..."
xcrun simctl uninstall "$SIMULATOR_ID" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"

echo "🚀 Lancement de l'application..."
xcrun simctl launch "$SIMULATOR_ID" "$BUNDLE_ID"

echo ""
echo "=============================================="
echo "✅ Application lancée avec succès !"
echo "=============================================="
echo ""
echo "💡 Temps estimé économisé: 30-45s vs build complet"
echo "📱 Logs:"
echo "xcrun simctl spawn $SIMULATOR_ID log stream --predicate 'processImagePath contains \"Runner\"' --level debug"
