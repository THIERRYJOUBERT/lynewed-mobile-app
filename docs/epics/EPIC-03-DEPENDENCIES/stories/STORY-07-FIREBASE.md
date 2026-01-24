# Story STORY-07: Mise a Jour Firebase (Version Majeure)

## Description

Mettre a jour les packages Firebase vers leurs versions majeures. **ATTENTION**: Version majeure = breaking changes probables.

| Package | Actuel | Cible | Changelog |
|---------|--------|-------|-----------|
| firebase_core | 3.15.2 | 4.4.0 | [pub.dev](https://pub.dev/packages/firebase_core/changelog) |
| firebase_messaging | 15.2.10 | 16.1.1 | [pub.dev](https://pub.dev/packages/firebase_messaging/changelog) |

## Criteres d'Acceptance

- [ ] `firebase_core` mis a jour de 3.x a 4.x
- [ ] `firebase_messaging` mis a jour de 15.x a 16.x
- [ ] `flutter pub get` reussit sans erreur
- [ ] `flutter analyze --fatal-infos` passe sans warnings
- [ ] App compile sur iOS (`flutter build ios --no-codesign`)
- [ ] App compile sur Android (`flutter build apk --debug`)
- [ ] Firebase initialise correctement au demarrage
- [ ] Push notifications recues en foreground (iOS + Android)
- [ ] Push notifications recues en background (iOS + Android)
- [ ] Tap sur notification ouvre le bon ecran
- [ ] Token FCM recuperable

## Breaking Changes Potentiels

### firebase_core 4.x

**VERIFIER LE CHANGELOG OFFICIEL AVANT MISE A JOUR**

Changements possibles:
- Nouvelle methode d'initialisation
- Changements dans `FirebaseOptions`
- Mise a jour des fichiers natifs requise:
  - `ios/Runner/GoogleService-Info.plist`
  - `android/app/google-services.json`
  - Podfile iOS
  - build.gradle Android

### firebase_messaging 16.x

**VERIFIER LE CHANGELOG OFFICIEL AVANT MISE A JOUR**

Changements possibles:
- Nouvelle API pour les handlers de messages
- Changements dans la gestion des permissions iOS
- Nouveau format de payload

## Pre-requis

Avant de commencer:

1. **Lire les changelogs officiels**:
   - [firebase_core changelog](https://pub.dev/packages/firebase_core/changelog)
   - [firebase_messaging changelog](https://pub.dev/packages/firebase_messaging/changelog)

2. **Lire les guides de migration FlutterFire**:
   - [FlutterFire Migration Guides](https://firebase.flutter.dev/docs/overview)

3. **Verifier la compatibilite**:
   - Version minimale de Flutter requise
   - Version minimale d'iOS/Android requise

## Tests Manuels Requis

### Device Physique OBLIGATOIRE

Les push notifications ne fonctionnent PAS sur simulateur iOS.

### 1. Test Initialisation

```
a) Cold start
   - Fermer completement l'app
   - Ouvrir l'app
   - Verifier les logs Firebase: "Firebase initialized successfully"

b) Token FCM
   - Recuperer le token FCM
   - Verifier qu'il est valide (non null, format correct)
```

### 2. Test Push Notifications iOS

```
a) Foreground
   - App ouverte
   - Envoyer une notification via Firebase Console
   - Verifier qu'elle s'affiche (banner)

b) Background
   - App en background
   - Envoyer une notification
   - Verifier qu'elle apparait dans le centre de notifications

c) Terminated
   - App fermee
   - Envoyer une notification
   - Verifier qu'elle apparait

d) Tap
   - Taper sur une notification
   - Verifier que l'app ouvre le bon ecran
```

### 3. Test Push Notifications Android

```
Memes tests que iOS:
a) Foreground
b) Background
c) Terminated
d) Tap
```

### 4. Test Permissions iOS

```
a) Premier lancement
   - Desinstaller l'app
   - Reinstaller
   - Verifier que la demande de permission s'affiche
   - Accepter
   - Verifier que les notifications fonctionnent

b) Permission refusee
   - Refuser la permission
   - Verifier comportement graceful de l'app
```

## Migration Potentielle

### Initialisation (si changee)

```dart
// Ancien code possible
await Firebase.initializeApp();

// Nouveau code possible (verifier changelog)
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Message Handlers (si changes)

```dart
// Ancien code possible
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // ...
});

// Nouveau code possible (verifier changelog)
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Potentiellement nouvelle structure
});
```

## Mise a Jour Fichiers Natifs

### iOS

Verifier/Mettre a jour:
- `ios/Podfile` - Version minimale de la plateforme
- `ios/Runner/Info.plist` - Permissions push
- `ios/Runner/AppDelegate.swift` - Configuration Firebase

```ruby
# ios/Podfile - Verifier la version minimale
platform :ios, '13.0'  # Ou version requise par Firebase 4.x
```

### Android

Verifier/Mettre a jour:
- `android/build.gradle` - classpath Google services
- `android/app/build.gradle` - plugin et minSdkVersion

```groovy
// android/build.gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'  // Verifier version requise
    }
}
```

```groovy
// android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 21  // Verifier version requise
    }
}
```

## Rollback

```bash
# Dans pubspec.yaml, revenir a:
firebase_core: ^3.14.0
firebase_messaging: ^15.2.7

# Puis:
flutter pub get
cd ios && pod install && cd ..
```

## Estimation

- **Effort**: L (1 jour) - Migration potentielle + tests exhaustifs
- **Risque**: Haut (notifications critiques pour l'app)

## Notes

### Points Critiques

1. **APNS Token**: Verifier que le token APNS est bien recupere sur iOS
2. **Background Modes**: Verifier les capabilities iOS
3. **ProGuard**: Verifier les regles ProGuard Android si minification activee

### Debugging

Si les notifications ne fonctionnent pas:

```dart
// Verifier le token
final token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');

// Verifier les permissions iOS
final settings = await FirebaseMessaging.instance.getNotificationSettings();
print('Authorization status: ${settings.authorizationStatus}');
```

### Alternative

Si la migration s'avere trop complexe, envisager de rester sur Firebase 3.x temporairement et planifier la migration dans un sprint dedie.
