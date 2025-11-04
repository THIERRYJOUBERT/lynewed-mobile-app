#!/bin/bash

# Script de configuration des secrets pour les notifications push
# Usage: ./configure_notification_secrets.sh

set -e

echo "🔔 Configuration des secrets de notification Lynewed"
echo "=================================================="
echo ""

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Erreur: Ce script doit être exécuté depuis la racine du projet Flutter${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Étape 1: Vérification des secrets actuels${NC}"
echo ""
npx supabase secrets list
echo ""

# Demander confirmation
read -p "Voulez-vous reconfigurer ENABLE_PUSH ? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}✅ Configuration de ENABLE_PUSH=true${NC}"
    npx supabase secrets set ENABLE_PUSH=true
    echo ""
fi

# FCM_PROJECT_ID
read -p "Voulez-vous reconfigurer FCM_PROJECT_ID ? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}📝 Entrez le FCM_PROJECT_ID (défaut: lynewed-app):${NC}"
    read -r fcm_project_id
    fcm_project_id=${fcm_project_id:-lynewed-app}
    npx supabase secrets set FCM_PROJECT_ID="$fcm_project_id"
    echo -e "${GREEN}✅ FCM_PROJECT_ID configuré${NC}"
    echo ""
fi

# FIREBASE_SERVICE_ACCOUNT
read -p "Voulez-vous reconfigurer FIREBASE_SERVICE_ACCOUNT ? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}📝 Chemin vers le fichier JSON du Service Account Firebase:${NC}"
    echo "   (Téléchargez-le depuis Firebase Console → Project Settings → Service Accounts)"
    read -r service_account_path
    
    if [ -f "$service_account_path" ]; then
        service_account_json=$(cat "$service_account_path")
        npx supabase secrets set FIREBASE_SERVICE_ACCOUNT="$service_account_json"
        echo -e "${GREEN}✅ FIREBASE_SERVICE_ACCOUNT configuré${NC}"
    else
        echo -e "${RED}❌ Fichier non trouvé: $service_account_path${NC}"
        echo -e "${YELLOW}💡 Vous pouvez aussi copier-coller le JSON directement:${NC}"
        read -p "Voulez-vous coller le JSON maintenant ? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Collez le JSON complet (Ctrl+D quand terminé):"
            service_account_json=$(cat)
            npx supabase secrets set FIREBASE_SERVICE_ACCOUNT="$service_account_json"
            echo -e "${GREEN}✅ FIREBASE_SERVICE_ACCOUNT configuré${NC}"
        fi
    fi
    echo ""
fi

echo ""
echo -e "${GREEN}🎉 Configuration terminée !${NC}"
echo ""
echo -e "${YELLOW}📋 Vérification finale des secrets:${NC}"
npx supabase secrets list
echo ""

echo -e "${YELLOW}🔍 Prochaines étapes:${NC}"
echo "1. Vérifiez que les 3 secrets sont présents ci-dessus"
echo "2. Consultez NOTIFICATION_SYSTEM_COMPLETE_TEST.md pour les tests"
echo "3. Exécutez les requêtes SQL de test dans le dashboard Supabase"
echo "4. Testez l'envoi d'un message pour vérifier la réception de notification"
echo ""
echo -e "${GREEN}✅ Les secrets sont maintenant disponibles pour l'Edge Function${NC}"
echo "   (Pas besoin de redéployer, ils sont actifs immédiatement)"
echo ""
