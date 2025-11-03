#!/bin/bash

# Script pour lancer l'application iOS en mode debug

echo "🚀 Lancement de Lynewed Alpha sur iOS..."
echo ""

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null
then
    echo "❌ Flutter n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

# Afficher la version de Flutter
echo "📱 Version de Flutter:"
flutter --version
echo ""

# Nettoyer le cache si demandé
if [ "$1" == "--clean" ]; then
    echo "🧹 Nettoyage du cache..."
    flutter clean
    cd ios
    rm -rf Pods Podfile.lock
    pod install
    cd ..
    flutter pub get
    echo ""
fi

# Lancer l'application
echo "▶️  Lancement de l'application..."
flutter run -d ios

