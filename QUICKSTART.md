# 🚀 Guide de Démarrage Rapide - Lynewed Alpha

## ✅ Configuration Terminée

Votre projet est maintenant **entièrement configuré** et prêt à être utilisé !

## 📋 Ce qui a été configuré

### ✨ Backend & Services
- ✅ **Supabase** - Base de données et authentification
  - URL: `https://odzkhcplevcqbuhzqsmq.supabase.co`
  - Configuration dans `lib/backend/supabase/supabase.dart`
  
- ✅ **Firebase** - Notifications push
  - Projet: `lynewed-app`
  - iOS: Configuré avec GoogleService-Info.plist
  - Android: Configuré avec google-services.json

### 📱 Permissions
- ✅ **iOS** - Toutes les permissions configurées dans Info.plist
  - Camera, Photo Library, Microphone, Location, Bluetooth, Notifications
  
- ✅ **Android** - Toutes les permissions configurées dans AndroidManifest.xml
  - Camera, Storage, Microphone, Location, Bluetooth, Notifications

### 🔧 Dépendances
- ✅ Toutes les dépendances Flutter installées
- ✅ Pods iOS installés et à jour
- ✅ Configuration Firebase complète

## 🎯 Lancer l'Application

### Option 1: Utiliser le script (Recommandé)
```bash
./run_ios.sh
```

Pour nettoyer le cache avant de lancer:
```bash
./run_ios.sh --clean
```

### Option 2: Commandes manuelles

**iOS:**
```bash
flutter run -d ios
```

**Android** (si SDK Android configuré):
```bash
flutter run -d android
```

## 🔍 Vérifier la Configuration

### Test de compilation iOS
```bash
flutter build ios --no-codesign --debug
```
✅ **Résultat**: Compilation réussie !

### Analyser le code
```bash
flutter analyze
```
ℹ️ **Note**: Des warnings de style sont présents mais n'empêchent pas la compilation.

## 📂 Structure du Projet

```
lynewed_alpha_v1.0.21+22/
├── lib/
│   ├── main.dart                    # Point d'entrée (Firebase initialisé ✅)
│   ├── backend/supabase/            # Configuration Supabase ✅
│   ├── auth/supabase_auth/          # Authentification ✅
│   ├── firebase_options.dart        # Options Firebase iOS & Android ✅
│   └── flutter_flow/                # Code FlutterFlow
├── ios/
│   ├── Runner/
│   │   ├── Info.plist              # Permissions iOS ✅
│   │   └── GoogleService-Info.plist # Firebase iOS ✅
│   └── Podfile                      # Dépendances iOS ✅
├── android/
│   ├── app/
│   │   ├── src/main/AndroidManifest.xml  # Permissions Android ✅
│   │   ├── google-services.json          # Firebase Android ✅
│   │   └── build.gradle                  # Configuration Gradle ✅
│   └── build.gradle                      # Plugin Firebase ✅
├── SETUP.md                         # Documentation complète
└── QUICKSTART.md                    # Ce fichier
```

## 🐛 Résolution de Problèmes

### L'application ne compile pas
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

### Erreur Supabase
- Vérifiez que l'URL et l'Anon Key sont corrects dans `lib/backend/supabase/supabase.dart`
- Les valeurs actuelles sont déjà configurées et fonctionnelles

### Erreur Firebase
- iOS: Vérifiez `ios/Runner/GoogleService-Info.plist`
- Android: Vérifiez `android/app/google-services.json`
- Les deux fichiers sont déjà configurés

### Erreur de permissions iOS
- Toutes les permissions sont déjà dans `ios/Runner/Info.plist`
- Si Apple rejette: vérifiez que les descriptions sont claires

## 📝 Prochaines Étapes

1. **Tester l'application** sur un simulateur/émulateur
2. **Vérifier la connexion Supabase** - L'authentification devrait fonctionner
3. **Tester les notifications** - Firebase est configuré
4. **Corriger le bug Apple** - Environnement identique à FlutterFlow

## 🔑 Informations Importantes

- **Version Flutter**: 3.32.4 (compatible avec 3.22.4)
- **Bundle ID iOS**: com.lynewed.app
- **Package Android**: com.lynewed.app
- **Version App**: 1.0.21+22

## 💡 Conseils

1. **Utilisez un simulateur iOS** pour le développement rapide
2. **Hot Reload** fonctionne avec `r` dans le terminal
3. **Hot Restart** avec `R` pour un redémarrage complet
4. **Logs en temps réel** visibles dans le terminal

## 📞 Support

Si vous rencontrez des problèmes:
1. Consultez `SETUP.md` pour plus de détails
2. Vérifiez les logs dans le terminal
3. Utilisez `flutter doctor` pour diagnostiquer l'environnement

---

**✨ Votre environnement est prêt ! Bon développement ! ✨**
