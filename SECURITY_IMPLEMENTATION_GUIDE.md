# 🔐 GUIDE D'IMPLÉMENTATION SÉCURITÉ - LYNEWED

**Version :** v1.0.26+29  
**Date :** 4 Novembre 2025  
**Statut :** ⚠️ ACTIONS REQUISES

---

## 🚨 ACTIONS IMMÉDIATES REQUISES

### ✅ **Étape 1 : Configuration des Variables d'Environnement**

#### 1.1 Installer flutter_dotenv
```bash
cd /Users/leoberthet/Desktop/lynewed_alpha_v1.0.26+29
flutter pub add flutter_dotenv
```

#### 1.2 Créer le fichier .env
```bash
cp .env.example .env
```

#### 1.3 Éditer .env avec vos VRAIES clés
```env
# Google Places API (Facturable - À protéger !)
GOOGLE_PLACES_API_KEY=AIzaSyCLOe2yCKXS-yoxq4E4pHt2NTxG8OUbhuY

# Agora Video (Facturable - À protéger !)
AGORA_APP_ID=ddfcd5a017564aebb138e985fdf30bcd

# Supabase (Clé publique - OK d'être exposée)
SUPABASE_URL=https://odzkhcplevcqbuhzqsmq.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### 1.4 Vérifier .gitignore
```bash
# S'assurer que .env est ignoré
echo ".env" >> .gitignore
echo ".env.local" >> .gitignore
echo ".env.*.local" >> .gitignore
```

#### 1.5 Charger .env au démarrage
Éditer `lib/main.dart` :
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Charger les variables d'environnement
  await dotenv.load(fileName: ".env");
  
  // ... reste du code
  runApp(MyApp());
}
```

#### 1.6 Ajouter .env dans pubspec.yaml
```yaml
flutter:
  assets:
    - .env
    - assets/
```

---

### ✅ **Étape 2 : Appliquer les Corrections Supabase**

#### 2.1 Se connecter à Supabase SQL Editor
```
https://supabase.com/dashboard/project/odzkhcplevcqbuhzqsmq/sql
```

#### 2.2 Exécuter la migration de sécurité
```bash
# Option 1: Via Supabase CLI
supabase db push

# Option 2: Copier-coller le contenu de ce fichier dans SQL Editor:
# supabase/migrations/002_security_fixes.sql
```

#### 2.3 Vérifier que les policies sont appliquées
```sql
-- Exécuter dans SQL Editor
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

---

### ✅ **Étape 3 : Configuration Build Production**

#### 3.1 Android - ProGuard/R8
Éditer `android/app/build.gradle` :
```gradle
android {
    buildTypes {
        release {
            // ✅ Activer l'obfuscation
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            
            signingConfig signingConfigs.release
        }
    }
}
```

Créer `android/app/proguard-rules.pro` :
```proguard
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Supabase
-keep class io.supabase.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
```

#### 3.2 Android - Network Security Config
Créer `android/app/src/main/res/xml/network_security_config.xml` :
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
    
    <!-- Autoriser uniquement HTTPS -->
    <domain-config>
        <domain includeSubdomains="true">supabase.co</domain>
        <domain includeSubdomains="true">firebase.com</domain>
        <domain includeSubdomains="true">googleapis.com</domain>
    </domain-config>
</network-security-config>
```

Référencer dans `android/app/src/main/AndroidManifest.xml` :
```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

#### 3.3 iOS - App Transport Security
Vérifier `ios/Runner/Info.plist` :
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <!-- ✅ Désactiver HTTP non sécurisé -->
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

---

## 📋 **CHECKLIST AVANT DÉPLOIEMENT**

### Sécurité Générale
- [ ] `.env` créé et configuré avec vraies clés
- [ ] `.env` ajouté au `.gitignore`
- [ ] `flutter_dotenv` installé et chargé dans main.dart
- [ ] `.env` ajouté aux assets dans pubspec.yaml
- [ ] SecureLogger utilisé partout (aucun debugPrint)
- [ ] Aucune clé API hardcodée dans le code

### Supabase
- [ ] Migration `002_security_fixes.sql` appliquée
- [ ] RLS activé sur toutes les tables
- [ ] Policies INSERT testées
- [ ] Storage policies vérifiées
- [ ] Edge functions sécurisées

### Build Mobile
- [ ] ProGuard/R8 activé pour Android
- [ ] Network Security Config configuré
- [ ] App Transport Security vérifié pour iOS
- [ ] Code obfuscation testée en release

### Tests
- [ ] Build release réussi : `flutter build apk --release`
- [ ] Build iOS réussi : `flutter build ios --release`
- [ ] Tests de permissions effectués
- [ ] Tests RLS effectués avec différents utilisateurs
- [ ] Logs production vérifiés (aucun log sensible)

---

## 🧪 **TESTS DE VALIDATION**

### Test 1 : Variables d'Environnement
```dart
// Ajouter temporairement dans un widget de debug
print('Google API Key loaded: ${FFAppConstants.googlePlacesApiKey.isNotEmpty}');
print('Agora ID loaded: ${FFAppConstants.agoraAppId.isNotEmpty}');
```

✅ **Attendu :** `true` pour les deux

### Test 2 : RLS Policies
```sql
-- Se connecter avec un utilisateur test
-- Essayer de créer un profil pour un autre user
INSERT INTO profiles (id, email, full_name)
VALUES ('autre-user-id', 'test@test.com', 'Test');

-- ❌ Devrait échouer avec : policy violation
```

### Test 3 : Logs en Production
```bash
# Build release
flutter build apk --release

# Installer sur device
adb install build/app/outputs/flutter-apk/app-release.apk

# Vérifier les logs
adb logcat | grep -i "token\|password\|secret"

# ✅ Aucun log sensible ne doit apparaître
```

### Test 4 : Obfuscation du Code
```bash
# Décompiler l'APK
apktool d app-release.apk

# Vérifier que le code Dart est obfusqué
cat app-release/smali/**/*.smali | grep -i "googlePlacesApiKey"

# ✅ Ne devrait PAS trouver de clés en clair
```

---

## 🚨 **GESTION DES INCIDENTS**

### Si une Clé API est Compromise

#### Google Places API
1. **Révoquer immédiatement** dans Google Cloud Console
2. Générer une nouvelle clé
3. Mettre à jour `.env`
4. Recompiler et redéployer l'app
5. Forcer la mise à jour pour tous les utilisateurs

#### Agora App ID
1. Désactiver l'App ID dans Agora Console
2. Créer un nouveau projet Agora
3. Mettre à jour `.env`
4. Recompiler et redéployer

#### Supabase Anon Key
1. Régénérer la clé dans Supabase Dashboard
2. Mettre à jour `.env` et backend
3. Déployer les changements
4. **Note :** Clé publique, compromission moins grave

---

## 📊 **MONITORING SÉCURITÉ**

### Logs à Surveiller

#### Supabase Dashboard
- **Auth logs** : Tentatives de connexion suspectes
- **Database logs** : Violations de policies RLS
- **Storage logs** : Accès non autorisés aux fichiers

#### Google Cloud Console
- **Places API** : Utilisation anormale
- Alertes de quota
- Requêtes depuis IPs suspectes

#### Agora Dashboard
- **Minutes consommées** : Pics inhabituels
- Sessions vidéo anormales
- Utilisation depuis régions inattendues

### Alertes Recommandées
```
1. Quota Places API > 80% → Email admin
2. RLS policy violation > 10/heure → Slack alert
3. Session vidéo > 2h → Investigation
4. Build release sans obfuscation → Bloquer déploiement
```

---

## 🔄 **MAINTENANCE RÉGULIÈRE**

### Hebdomadaire
- [ ] Vérifier logs Supabase pour violations RLS
- [ ] Surveiller usage Google Places API
- [ ] Vérifier minutes Agora consommées

### Mensuelle
- [ ] Audit des permissions Android/iOS
- [ ] Revue des policies RLS
- [ ] Test de pénétration basique
- [ ] Vérifier dépendances obsolètes : `flutter pub outdated`

### Trimestrielle
- [ ] Audit de sécurité complet
- [ ] Rotation des clés API (si possible)
- [ ] Pentest professionnel
- [ ] Revue du code par expert sécurité

---

## 📞 **CONTACTS SÉCURITÉ**

### En cas d'incident
- **Tech Lead :** [À renseigner]
- **DevOps :** [À renseigner]
- **Security Officer :** [À renseigner]

### Support Plateforme
- **Supabase Support :** https://supabase.com/support
- **Firebase Support :** https://firebase.google.com/support
- **Google Cloud Console :** https://console.cloud.google.com

---

## ✅ **STATUT D'IMPLÉMENTATION**

| Tâche | Statut | Priorité | Échéance |
|-------|--------|----------|----------|
| flutter_dotenv installé | ⚠️ À faire | 🔴 Urgent | Immédiat |
| .env configuré | ⚠️ À faire | 🔴 Urgent | Immédiat |
| Migration RLS appliquée | ⚠️ À faire | 🔴 Urgent | Aujourd'hui |
| ProGuard configuré | ⚠️ À faire | 🟠 Élevé | Cette semaine |
| Tests de validation | ⚠️ À faire | 🟠 Élevé | Cette semaine |
| Monitoring configuré | ⚠️ À faire | 🟡 Moyen | Ce mois |

---

**🎯 Objectif : Application 100% sécurisée d'ici 7 jours**

**Prochaine revue : 11 Novembre 2025**
