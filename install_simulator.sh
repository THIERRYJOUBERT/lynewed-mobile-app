#!/bin/bash
# Script d'installation sur simulateur iOS
# Usage: ./install_simulator.sh

set -e

echo "🚀 Installation de Lynewed Alpha sur simulateur iOS"
echo "=================================================="

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. Vérifier que le simulateur est démarré
echo -e "${BLUE}📱 Vérification du simulateur...${NC}"
SIMULATOR_ID="53D436C5-C951-4341-B4B4-A3206DBD2D22"
SIMULATOR_STATE=$(xcrun simctl list devices | grep "$SIMULATOR_ID" | grep -o "Booted\|Shutdown")

if [ "$SIMULATOR_STATE" != "Booted" ]; then
    echo -e "${BLUE}🔄 Démarrage du simulateur iPhone 16e...${NC}"
    xcrun simctl boot "$SIMULATOR_ID"
    open -a Simulator
    sleep 5
fi

echo -e "${GREEN}✅ Simulateur prêt${NC}"

# 2. Build l'application
echo -e "${BLUE}🔨 Build de l'application...${NC}"
cd "$(dirname "$0")"

xcodebuild \
    -workspace ios/Runner.xcworkspace \
    -scheme Runner \
    -configuration Debug \
    -sdk iphonesimulator \
    -destination "id=$SIMULATOR_ID" \
    -derivedDataPath ios/build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    | xcpretty || true

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo -e "${RED}❌ Build échoué${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build réussi${NC}"

# 3. Trouver l'app
APP_PATH=$(find ios/build/Build/Products/Debug-iphonesimulator -name "*.app" -type d | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}❌ Application non trouvée${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Application trouvée: $APP_PATH${NC}"

# 4. Installer sur le simulateur
echo -e "${BLUE}📲 Installation sur le simulateur...${NC}"
xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"

echo -e "${GREEN}✅ Installation réussie${NC}"

# 5. Lancer l'application
echo -e "${BLUE}🚀 Lancement de l'application...${NC}"
BUNDLE_ID="com.lynewed.app"
xcrun simctl launch "$SIMULATOR_ID" "$BUNDLE_ID"

echo -e "${GREEN}✅ Application lancée !${NC}"
echo ""
echo "=================================================="
echo -e "${GREEN}🎉 Lynewed Alpha est maintenant en cours d'exécution${NC}"
echo "=================================================="
