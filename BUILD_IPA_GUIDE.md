# 📦 Guide de Build .ipa pour Production (v1.1.0)

**Version:** 1.1.0+56  
**Date:** 7 novembre 2025  
**Team ID:** G234APMW4U

---

## ⚠️ Prérequis

1. **Certificat de Distribution Apple**
   - Certificat de distribution iOS valide
   - Profil de provisioning App Store
   - Accès au compte Apple Developer

2. **Configuration Xcode**
   - Xcode 26.0.1 ou supérieur
   - Compte Apple Developer configuré dans Xcode

3. **Fichier .env**
   - Fichier `.env` avec toutes les clés API
   - Vérifier que toutes les variables sont renseignées

---

## 🚀 Procédure de Build .ipa

### Méthode 1 : Via Xcode (Recommandée)

```bash
# 1. Ouvrir le projet dans Xcode
open ios/Runner.xcworkspace

# 2. Dans Xcode :
# - Sélectionner "Any iOS Device (arm64)" comme destination
# - Product → Archive
# - Attendre la fin du build (~2-3 minutes)
# - Dans Organizer, sélectionner l'archive
# - Distribute App → App Store Connect / Ad Hoc / Enterprise
# - Suivre l'assistant de distribution
```

### Méthode 2 : Via Ligne de Commande

```bash
# 1. Build l'archive
flutter build ipa --release

# 2. Le .ipa sera généré dans:
# build/ios/ipa/lynewed_alpha.ipa

# 3. Upload vers App Store Connect (optionnel)
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/lynewed_alpha.ipa \
  --username "votre-email@apple.com" \
  --password "app-specific-password"
```

### Méthode 3 : Build pour TestFlight

```bash
# 1. Build et upload automatique
flutter build ipa --release --export-method app-store

# 2. Ou manuellement via Xcode
# Product → Archive → Distribute App → App Store Connect
```

---

## 🔐 Configuration Signing

### Vérifier la Configuration

```bash
# Vérifier les certificats disponibles
security find-identity -v -p codesigning

# Vérifier les profils de provisioning
ls ~/Library/MobileDevice/Provisioning\ Profiles/
```

### Configurer dans Xcode

1. Ouvrir `ios/Runner.xcworkspace`
2. Sélectionner le projet "Runner"
3. Onglet "Signing & Capabilities"
4. Cocher "Automatically manage signing"
5. Sélectionner votre Team (G234APMW4U)
6. Vérifier le Bundle ID: `com.lynewed.app`

---

## ✅ Checklist Pre-Build

- [ ] Fichier `.env` créé avec toutes les clés
- [ ] Version mise à jour dans `pubspec.yaml` (1.1.0+56)
- [ ] `flutter pub get` exécuté
- [ ] `cd ios && pod install` exécuté
- [ ] Certificat de distribution valide
- [ ] Profil de provisioning App Store configuré
- [ ] Tests de non-régression passés
- [ ] Aucune erreur dans `flutter analyze`

---

## 🧪 Tests Pre-Production

### Tests Manuels Critiques

```bash
# 1. Build en mode release sur device physique
flutter run --release

# 2. Tester les fonctionnalités critiques:
# - Authentification (sign up, login, logout)
# - Appel vidéo Agora
# - Recherche géographique Google Maps
# - Notifications push FCM
# - Chat temps réel
# - Upload images (portfolio, chat)
```

### Vérification Sécurité

```bash
# 1. Vérifier qu'aucun secret n'est hardcodé
flutter build ios --release --no-codesign
unzip -q build/ios/Release-iphoneos/Runner.app/Frameworks/App.framework/App
strings App | grep -i "supabase_url"
# Résultat attendu: Aucune URL trouvée

# 2. Vérifier la taille du binaire
ls -lh build/ios/ipa/lynewed_alpha.ipa
# Attendu: ~150-200 MB
```

---

## 📤 Upload vers App Store Connect

### Via Xcode Organizer

1. Xcode → Window → Organizer
2. Sélectionner l'archive
3. "Distribute App"
4. Sélectionner "App Store Connect"
5. Upload → Attendre validation (~5-10 min)

### Via Transporter App

1. Télécharger Transporter depuis Mac App Store
2. Ouvrir Transporter
3. Glisser-déposer le .ipa
4. Deliver

### Via Ligne de Commande

```bash
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/lynewed_alpha.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

---

## 🐛 Troubleshooting

### Erreur: "Failed to codesign"

**Solution:**
```bash
# 1. Vérifier les certificats
security find-identity -v -p codesigning

# 2. Nettoyer le build
flutter clean
cd ios && pod install
cd ..

# 3. Rebuild
flutter build ios --release
```

### Erreur: "Provisioning profile doesn't match"

**Solution:**
1. Xcode → Preferences → Accounts
2. Sélectionner votre compte
3. "Download Manual Profiles"
4. Rebuild

### Erreur: "Missing .env file"

**Solution:**
```bash
# Créer le fichier .env à la racine
cp .env.example .env
# Éditer .env avec les vraies valeurs
```

---

## 📊 Informations Build

**Bundle ID:** com.lynewed.app  
**Version:** 1.1.0  
**Build Number:** 56  
**Min iOS Version:** 13.0  
**Supported Devices:** iPhone, iPad  
**Orientations:** Portrait uniquement  

**Permissions requises:**
- Camera (Appels vidéo)
- Microphone (Appels vidéo)
- Location (Recherche géographique)
- Photo Library (Upload images)
- Notifications (Push notifications)

---

## 📞 Support

**Questions techniques:** dev@lynewed.com  
**Apple Developer Support:** https://developer.apple.com/support/

**Dernière mise à jour:** 7 novembre 2025
