# 🧪 Guide de Test & Dépannage - APIs Certifiées

**Date :** 26 novembre 2025  
**Version :** 1.0  
**Environnement :** Supabase DEV (hekyovgnovhfhmkpfrna)

---

## 📋 **Checklist de Prérequis par API**

### **🎥 Agora Video API**
- ✅ `AGORA_APP_ID` configuré dans dashboard Edge Functions
- ✅ `AGORA_APP_CERTIFICATE` configuré dans dashboard Edge Functions  
- ✅ `AGORA_TOKEN_EXPIRATION_SECONDS=3600` configuré
- ✅ JWT utilisateur valide (1h validité)

### **📱 FCM Notifications API**
- ✅ `SUPABASE_SERVICE_ROLE_KEY` configuré
- ✅ `ENABLE_PUSH=true` configuré
- ✅ `FCM_PROJECT_ID=lynewed-app` configuré
- ✅ `FIREBASE_SERVICE_ACCOUNT` JSON configuré
- ⚠️ **Device tokens enregistrés** (nécessite app Flutter réelle)
- ✅ Permissions service_role appliquées (voir migration SQL)

### **📧 Resend Email API**
- ✅ `RESEND_API_KEY` configuré
- ✅ **Domaine vérifié** : `lynewed.com` (edge functions redéployées)

---

## 🚀 **Commandes de Test Rapide**

### **1. Authentification (prérequis pour tous les tests)**
```bash
# Obtenir JWT token frais
curl -X POST 'https://hekyovgnovhfhmkpfrna.supabase.co/auth/v1/token?grant_type=password' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhla3lvdmdub3ZoZmhta3Bmcm5hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5Nzg1MzQsImV4cCI6MjA3OTU1NDUzNH0.MNxUZAyL_7tSGp-w7MZ6rYx6UiZIMSPOnwC0XhsOHgI' \
  -H 'Content-Type: application/json' \
  -d '{"email":"marie.martin.bride@test.com","password":"Test123456!"}'
```

### **2. Test Agora Token Generation**
```bash
# Remplacer JWT_TOKEN par le token obtenu ci-dessus
curl -X POST 'https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/agora_token_issue' \
  -H 'Authorization: Bearer JWT_TOKEN' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhla3lvdmdub3ZoZmhta3Bmcm5hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5Nzg1MzQsImV4cCI6MjA3OTU1NDUzNH0.MNxUZAyL_7tSGp-w7MZ6rYx6UiZIMSPOnwC0XhsOHgI' \
  -H 'Content-Type: application/json' \
  -d '{"channelName":"test_video_session","agoraUid":12345}'
```

### **3. Test FCM Notifications**
```bash
# Remplacer JWT_TOKEN par le token obtenu ci-dessus
curl -X POST 'https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/notifications_outbox_drain' \
  -H 'Authorization: Bearer JWT_TOKEN' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhla3lvdmdub3ZoZmhta3Bmcm5hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5Nzg1MzQsImV4cCI6MjA3OTU1NDUzNH0.MNxUZAyL_7tSGp-w7MZ6rYx6UiZIMSPOnwC0XhsOHgI' \
  -H 'Content-Type: application/json' \
  -d '{}'
```

### **4. Test Resend Email**
```bash
# Remplacer JWT_TOKEN par le token obtenu ci-dessus
curl -X POST 'https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/send-verification-email' \
  -H 'Authorization: Bearer JWT_TOKEN' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhla3lvdmdub3ZoZmhta3Bmcm5hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5Nzg1MzQsImV4cCI6MjA3OTU1NDUzNH0.MNxUZAyL_7tSGp-w7MZ6rYx6UiZIMSPOnwC0XhsOHgI' \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com","firstName":"Test","lastName":"User","status":"verified"}'
```

---

## 🔧 **Guide de Dépannage**

### **Erreurs Communes & Solutions**

#### **🔐 "Invalid JWT" (Agora/Edge Functions)**
**Cause :** Token JWT expiré (validité 1h)  
**Solution :** Ré-authentifier pour obtenir un nouveau token JWT  
**Commande :** Utiliser la commande d'authentification ci-dessus

#### **🚫 "permission denied for schema public" (FCM)**
**Cause :** Permissions manquantes pour le rôle service_role  
**Solution :** Appliquer la migration SQL des permissions  
**Migration :** `20251126111600_fix_service_role_permissions.sql`

#### **📧 Resend : "Email envoyé avec succès"**
**Statut :** ✅ Fonctionnel après redéploiement  
**Résultat attendu :** `{"success":true,"data":{"data":{"id":"..."},"error":null}}`  
**Note :** Edge functions utilisent maintenant le domaine correct `lynewed.com`

#### **📱 FCM : "Processed X events" mais 0 notifications envoyées**
**Cause :** Aucun device token enregistré dans la base  
**Solution :** Lancer app Flutter réelle, s'authentifier, laisser enregistrer le token FCM  
**Vérification :** `SELECT COUNT(*) FROM device_tokens;`

---

## 📊 **État de Certification**

| API | Statut | Résultat Test | Prochaine Étape |
|-----|--------|---------------|-----------------|
| **Agora** | ✅ 100% fonctionnel | Token généré avec succès | Prêt pour visioconférence |
| **FCM** | ✅ Infrastructure OK | Traite les événements | Attend device tokens réels |
| **Resend** | ✅ 100% fonctionnel | Email ID: `99bd7edc-8bfe-4929-b80d-c57860ce2a3f` | Prêt pour envoi d'emails |

---

## 🔄 **Maintenance Future**

### **Vérifications Périodiques**
1. **Mensuel :** Vérifier l'expiration des tokens Agora/Firebase
2. **Trimestriel :** Rotation des secrets critiques
3. **Après migration DB :** Réappliquer les permissions service_role

### **Points d'Attention**
- **JWT Tokens :** Validité 1h → toujours utiliser des tokens frais pour les tests
- **Device Tokens :** Doivent être enregistrés depuis l'app Flutter réelle
- **Domaine Resend :** Doit correspondre entre dashboard et code

---

## 📞 **Support**

Pour toute question sur ces configurations :
1. Consulter `SECRETS_TRACKING.md` pour les détails des secrets
2. Vérifier `PROJECT.md` pour l'état du projet
3. Utiliser ce guide pour les tests et dépannage

---

*Guide créé le 26 novembre 2025 - APIs certifiées opérationnelles*
