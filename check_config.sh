#!/bin/bash

# Script de vérification de la configuration du projet

echo "🔍 Vérification de la configuration de Lynewed Alpha"
echo "=================================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction de vérification
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✅${NC} $2"
        return 0
    else
        echo -e "${RED}❌${NC} $2"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✅${NC} $2"
        return 0
    else
        echo -e "${RED}❌${NC} $2"
        return 1
    fi
}

# Vérification Flutter
echo "📱 Flutter:"
if command -v flutter &> /dev/null; then
    echo -e "${GREEN}✅${NC} Flutter installé"
    flutter --version | head -n 1
else
    echo -e "${RED}❌${NC} Flutter non installé"
fi
echo ""

# Vérification des fichiers de configuration
echo "📄 Fichiers de configuration:"
check_file "pubspec.yaml" "pubspec.yaml"
check_file "lib/main.dart" "main.dart"
check_file "lib/firebase_options.dart" "firebase_options.dart"
check_file "lib/backend/supabase/supabase.dart" "Configuration Supabase"
echo ""

# Vérification iOS
echo "🍎 Configuration iOS:"
check_file "ios/Runner/Info.plist" "Info.plist (Permissions)"
check_file "ios/Runner/GoogleService-Info.plist" "GoogleService-Info.plist (Firebase)"
check_file "ios/Podfile" "Podfile"
check_dir "ios/Pods" "Pods installés"
echo ""

# Vérification Android
echo "🤖 Configuration Android:"
check_file "android/app/src/main/AndroidManifest.xml" "AndroidManifest.xml (Permissions)"
check_file "android/app/google-services.json" "google-services.json (Firebase)"
check_file "android/app/build.gradle" "app/build.gradle"
check_file "android/build.gradle" "build.gradle (Plugin Firebase)"
echo ""

# Vérification des dépendances
echo "📦 Dépendances:"
if [ -f "pubspec.lock" ]; then
    echo -e "${GREEN}✅${NC} pubspec.lock présent"
else
    echo -e "${YELLOW}⚠️${NC}  pubspec.lock manquant - Exécutez 'flutter pub get'"
fi

if [ -d ".dart_tool" ]; then
    echo -e "${GREEN}✅${NC} .dart_tool présent"
else
    echo -e "${YELLOW}⚠️${NC}  .dart_tool manquant - Exécutez 'flutter pub get'"
fi
echo ""

# Vérification Supabase
echo "🔐 Configuration Supabase:"
if grep -q "odzkhcplevcqbuhzqsmq.supabase.co" lib/backend/supabase/supabase.dart; then
    echo -e "${GREEN}✅${NC} URL Supabase configurée"
else
    echo -e "${RED}❌${NC} URL Supabase non trouvée"
fi

if grep -q "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9" lib/backend/supabase/supabase.dart; then
    echo -e "${GREEN}✅${NC} Anon Key Supabase configurée"
else
    echo -e "${RED}❌${NC} Anon Key Supabase non trouvée"
fi
echo ""

# Vérification Firebase
echo "🔥 Configuration Firebase:"
if grep -q "Firebase.initializeApp" lib/main.dart; then
    echo -e "${GREEN}✅${NC} Firebase initialisé dans main.dart"
else
    echo -e "${RED}❌${NC} Firebase non initialisé dans main.dart"
fi

if grep -q "lynewed-app" lib/firebase_options.dart; then
    echo -e "${GREEN}✅${NC} Projet Firebase configuré"
else
    echo -e "${RED}❌${NC} Projet Firebase non configuré"
fi
echo ""

# Résumé
echo "=================================================="
echo "✨ Vérification terminée !"
echo ""
echo "Pour lancer l'application:"
echo "  ./run_ios.sh"
echo ""
echo "Pour plus d'informations:"
echo "  cat QUICKSTART.md"
echo ""
