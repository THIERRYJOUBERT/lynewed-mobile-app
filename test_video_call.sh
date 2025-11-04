#!/bin/bash

# Script de test pour la fonctionnalité d'appel vidéo Agora
# Date: 4 novembre 2025

echo "🎥 =========================================="
echo "   TEST FONCTIONNALITÉ APPEL VIDÉO AGORA"
echo "=========================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Étape 1: Vérifier que nous sommes dans le bon répertoire
echo "📁 Étape 1: Vérification du répertoire..."
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Erreur: pubspec.yaml non trouvé${NC}"
    echo "   Veuillez exécuter ce script depuis la racine du projet"
    exit 1
fi
echo -e "${GREEN}✅ Répertoire correct${NC}"
echo ""

# Étape 2: Vérifier la version d'agora_rtc_engine
echo "📦 Étape 2: Vérification de la version agora_rtc_engine..."
AGORA_VERSION=$(grep "agora_rtc_engine:" pubspec.yaml | awk '{print $2}')
if [ "$AGORA_VERSION" = "^5.3.1" ] || [ "$AGORA_VERSION" = "5.3.1" ]; then
    echo -e "${GREEN}✅ Version Agora correcte: $AGORA_VERSION${NC}"
else
    echo -e "${YELLOW}⚠️  Version Agora: $AGORA_VERSION (attendu: 5.3.1)${NC}"
fi
echo ""

# Étape 3: Vérifier que le fichier corrigé existe
echo "🔍 Étape 3: Vérification du fichier agora_video_view.dart..."
if [ ! -f "lib/custom_code/widgets/agora_video_view.dart" ]; then
    echo -e "${RED}❌ Fichier agora_video_view.dart non trouvé${NC}"
    exit 1
fi

# Vérifier que la correction a été appliquée
if grep -q "RtcEngine.create(widget.appId)" "lib/custom_code/widgets/agora_video_view.dart"; then
    echo -e "${GREEN}✅ Correction API Agora appliquée${NC}"
else
    echo -e "${RED}❌ Correction API Agora NON appliquée${NC}"
    echo "   Le fichier doit contenir: RtcEngine.create(widget.appId)"
    exit 1
fi
echo ""

# Étape 4: Clean build
echo "🧹 Étape 4: Nettoyage du projet..."
echo "   Exécution de: flutter clean"
flutter clean > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Nettoyage réussi${NC}"
else
    echo -e "${RED}❌ Erreur lors du nettoyage${NC}"
    exit 1
fi
echo ""

# Étape 5: Get dependencies
echo "📥 Étape 5: Récupération des dépendances..."
echo "   Exécution de: flutter pub get"
flutter pub get > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dépendances récupérées${NC}"
else
    echo -e "${RED}❌ Erreur lors de la récupération des dépendances${NC}"
    exit 1
fi
echo ""

# Étape 6: Pod install (iOS)
echo "🍎 Étape 6: Installation des pods iOS..."
if [ -d "ios" ]; then
    cd ios
    echo "   Exécution de: pod install"
    pod install > /dev/null 2>&1
    POD_EXIT=$?
    cd ..
    
    if [ $POD_EXIT -eq 0 ]; then
        echo -e "${GREEN}✅ Pods iOS installés${NC}"
    else
        echo -e "${YELLOW}⚠️  Erreur lors de l'installation des pods${NC}"
        echo "   Essayez manuellement: cd ios && pod install"
    fi
else
    echo -e "${YELLOW}⚠️  Dossier ios non trouvé${NC}"
fi
echo ""

# Étape 7: Vérifier les devices connectés
echo "📱 Étape 7: Vérification des devices..."
DEVICES=$(flutter devices 2>/dev/null | grep -c "•")
if [ $DEVICES -gt 0 ]; then
    echo -e "${GREEN}✅ $DEVICES device(s) détecté(s)${NC}"
    echo ""
    echo "Devices disponibles:"
    flutter devices | grep "•" | sed 's/^/   /'
else
    echo -e "${YELLOW}⚠️  Aucun device détecté${NC}"
    echo "   Connectez un iPhone ou lancez un simulateur"
fi
echo ""

# Résumé
echo "=========================================="
echo "📊 RÉSUMÉ"
echo "=========================================="
echo ""
echo -e "${GREEN}✅ Corrections appliquées${NC}"
echo -e "${GREEN}✅ Projet nettoyé et dépendances installées${NC}"
echo ""
echo "🚀 PROCHAINES ÉTAPES:"
echo ""
echo "1. Lancer l'application:"
echo "   ${YELLOW}flutter run -d ios --release${NC}"
echo ""
echo "2. Tester un appel vidéo:"
echo "   - Ouvrir un chat"
echo "   - Appuyer sur l'icône vidéo"
echo "   - Vérifier les logs [AGORA 5.3]"
echo ""
echo "3. Logs attendus:"
echo "   ${GREEN}[AGORA 5.3] 🎥 Initializing Agora...${NC}"
echo "   ${GREEN}[AGORA 5.3] ✅ Engine created successfully${NC}"
echo "   ${GREEN}[AGORA 5.3] 🚀 Joining channel...${NC}"
echo "   ${GREEN}[AGORA 5.3] ✅ joinChannelSuccess...${NC}"
echo ""
echo "=========================================="
echo "✅ Script terminé avec succès!"
echo "=========================================="
