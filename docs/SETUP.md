# Configuration du projet Lynewed Alpha

## Prérequis

- Flutter 3.22.4 ou version compatible (actuellement 3.32.4)
- Xcode (pour iOS)
- Android Studio (pour Android)
- CocoaPods (pour iOS)

## Configuration Supabase

Le projet est configuré pour utiliser Supabase :
- **URL**: https://odzkhcplevcqbuhzqsmq.supabase.co
- **Anon Key**: Configurée dans `lib/backend/supabase/supabase.dart`

## Configuration Firebase

Firebase est configuré pour les notifications push :
- **Projet**: lynewed-app
- **iOS**: Configuration dans `ios/Runner/GoogleService-Info.plist`
- **Android**: Configuration dans `android/app/google-services.json`

## Installation

1. **Cloner le projet** (si ce n'est pas déjà fait)

2. **Installer les dépendances Flutter**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Configuration iOS**
   ```bash
   cd ios
   pod install
   cd ..
   ```

4. **Lancer l'application**
   
   Pour iOS:
   ```bash
   flutter run -d ios
   ```
   
   Pour Android:
   ```bash
   flutter run -d android
   ```

## Permissions configurées

### iOS (Info.plist)
- ✅ Camera (NSCameraUsageDescription)
- ✅ Photo Library (NSPhotoLibraryUsageDescription)
- ✅ Microphone (NSMicrophoneUsageDescription)
- ✅ Location (NSLocationWhenInUseUsageDescription)
- ✅ Bluetooth (NSBluetoothAlwaysUsageDescription)
- ✅ Notifications (UIBackgroundModes: remote-notification)
- ✅ Local Network (NSLocalNetworkUsageDescription)

### Android (AndroidManifest.xml)
- ✅ Internet
- ✅ Camera
- ✅ Microphone (RECORD_AUDIO)
- ✅ Location (ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION)
- ✅ Bluetooth (BLUETOOTH, BLUETOOTH_CONNECT, BLUETOOTH_ADMIN)
- ✅ Notifications (POST_NOTIFICATIONS)
- ✅ Storage (READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE)

## Résolution des problèmes courants

### Erreur de compilation iOS
Si vous rencontrez des erreurs lors de la compilation iOS :
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

### Erreur de compilation Android
Si vous rencontrez des erreurs lors de la compilation Android :
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Problème de version Flutter
Si vous devez utiliser exactement Flutter 3.22.4, utilisez FVM :
```bash
# Installer FVM
dart pub global activate fvm

# Installer Flutter 3.22.4
fvm install 3.22.4

# Utiliser Flutter 3.22.4 pour ce projet
fvm use 3.22.4

# Lancer les commandes avec fvm
fvm flutter pub get
fvm flutter run
```

## Structure du projet

- `lib/` - Code source Dart
  - `main.dart` - Point d'entrée de l'application
  - `backend/supabase/` - Configuration Supabase
  - `auth/supabase_auth/` - Authentification Supabase
  - `flutter_flow/` - Code généré par FlutterFlow
- `ios/` - Configuration iOS
- `android/` - Configuration Android
- `assets/` - Ressources (images, fonts, etc.)

## Notes importantes

1. **Supabase** est déjà configuré et prêt à l'emploi
2. **Firebase** est configuré pour les notifications push iOS et Android
3. Toutes les **permissions** nécessaires sont configurées
4. Le projet utilise **Go Router** pour la navigation
5. L'authentification utilise **Supabase Auth**

## Support

Pour toute question ou problème, vérifiez d'abord :
1. Que toutes les dépendances sont installées (`flutter pub get`)
2. Que les pods iOS sont à jour (`cd ios && pod install`)
3. Que le cache est nettoyé (`flutter clean`)
