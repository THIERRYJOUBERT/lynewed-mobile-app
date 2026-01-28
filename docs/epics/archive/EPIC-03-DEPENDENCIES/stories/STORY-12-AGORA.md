# Story STORY-12: Mise a Jour Agora RTC Engine

## Description

Mettre a jour le SDK Agora pour les appels video en temps reel.

| Package | Actuel | Cible | Changelog |
|---------|--------|-------|-----------|
| agora_rtc_engine | 6.3.2 | 6.5.3 | [pub.dev](https://pub.dev/packages/agora_rtc_engine/changelog) |

## Criteres d'Acceptance

- [ ] `agora_rtc_engine` mis a jour de 6.3.2 a 6.5.3
- [ ] `flutter pub get` reussit sans erreur
- [ ] `flutter analyze --fatal-infos` passe sans warnings
- [ ] App compile sur iOS (`flutter build ios --no-codesign`)
- [ ] App compile sur Android (`flutter build apk --debug`)
- [ ] Initialisation Agora reussit
- [ ] Rejoindre un channel fonctionne
- [ ] Video locale s'affiche
- [ ] Video distante s'affiche
- [ ] Audio fonctionne (microphone + speaker)
- [ ] Quitter le channel fonctionne proprement

## Breaking Changes Potentiels

### agora_rtc_engine 6.5.3

Version mineure - changements possibles:
- Nouvelles APIs ajoutees
- Bug fixes
- Ameliorations de performance
- Possibles deprecations (a verifier dans changelog)

**Points d'attention**:
- Verifier la compatibilite avec la version du Agora Console
- Verifier les SDK natifs iOS/Android

## Pre-requis

### Configuration Agora

Verifier dans le Agora Console (console.agora.io):
- App ID valide
- Temporary Token (si utilise)
- Project settings

### Permissions

S'assurer que les permissions sont configurees:

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access for video calls</string>
```

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

## Tests Manuels Requis

### ATTENTION: Tests sur Devices Physiques OBLIGATOIRES

Les appels video ne fonctionnent PAS sur simulateur/emulateur.

### 1. Test Initialisation

```
a) Engine init
   - Demarrer l'app
   - Initialiser l'engine Agora
   - Verifier les logs: "Engine created successfully"

b) Permissions
   - Verifier que les permissions camera/micro sont demandees
   - Accepter les permissions
   - Verifier l'acces
```

### 2. Test Video Call (necessite 2 devices)

```
a) Rejoindre un channel
   - Device 1: Rejoindre channel "test-channel"
   - Verifier que la video locale s'affiche

b) Second participant
   - Device 2: Rejoindre le meme channel
   - Verifier que les 2 videos s'affichent sur chaque device

c) Audio
   - Parler sur Device 1
   - Verifier que Device 2 entend
   - Et vice versa

d) Mute/Unmute Video
   - Couper la video
   - Verifier que l'autre participant voit un placeholder
   - Reactiver
   - Verifier le retour de la video

e) Mute/Unmute Audio
   - Couper le micro
   - Verifier que l'autre n'entend plus
   - Reactiver
   - Verifier le retour de l'audio

f) Switch camera
   - Basculer front/back camera
   - Verifier que ca fonctionne des 2 cotes

g) Quitter le channel
   - Un participant quitte
   - Verifier que l'autre est notifie
   - Verifier pas de crash
```

### 3. Test Edge Cases

```
a) Mauvaise connexion
   - Simuler mauvaise connexion (mode 3G)
   - Verifier la degradation graceful

b) Reconnection
   - Couper le wifi pendant un call
   - Reconnecter
   - Verifier la reprise de l'appel

c) Mise en background
   - Mettre l'app en background pendant un call
   - Revenir au foreground
   - Verifier l'etat du call
```

## Migration Guide

```dart
// Verifier si l'API a change
// Ancien code possible
final engine = createAgoraRtcEngine();
await engine.initialize(RtcEngineContext(appId: appId));

// Nouveau code possible (verifier changelog)
final engine = createAgoraRtcEngine();
await engine.initialize(RtcEngineContext(
  appId: appId,
  // Potentiellement nouvelles options
));
```

### Event Handlers

```dart
// Verifier les event handlers
engine.registerEventHandler(RtcEngineEventHandler(
  onJoinChannelSuccess: (connection, elapsed) {
    // ...
  },
  onUserJoined: (connection, remoteUid, elapsed) {
    // ...
  },
  // Verifier si nouveaux events disponibles
));
```

## Rollback

```bash
# Dans pubspec.yaml, revenir a:
agora_rtc_engine: 6.3.2

# Puis:
flutter pub get
cd ios && pod install && cd ..
```

## Estimation

- **Effort**: M (4-6h) - Tests video call complexes
- **Risque**: Moyen (fonctionnalite critique si video calls utilises)

## Notes

### Points Critiques

1. **SDK Natifs**: Agora met a jour ses SDK natifs - verifier la compatibilite
2. **Token**: Si le projet utilise des tokens, verifier la generation
3. **Channel naming**: Verifier que les channels existants fonctionnent

### Debugging

Si les calls ne fonctionnent pas:

```dart
// Activer les logs verbose
engine.setLogLevel(LogLevel.logLevelInfo);

// Verifier les erreurs
engine.registerEventHandler(RtcEngineEventHandler(
  onError: (err, msg) {
    print('Agora error: $err - $msg');
  },
));
```

### Documentation Agora

- [Agora Flutter SDK Docs](https://docs.agora.io/en/video-calling/develop/get-started/get-started-sdk?platform=flutter)
- [API Reference](https://api-ref.agora.io/en/video-sdk/flutter/6.x/index.html)

### iOS Specifique

Si problemes sur iOS, verifier le Podfile:

```ruby
# Forcer la bonne version du SDK
pod 'AgoraRtcEngine_iOS', '~> 4.2.0'  # Verifier version requise
```

### Android Specifique

Si problemes sur Android, verifier le build.gradle:

```groovy
// Verifier minSdkVersion
android {
    defaultConfig {
        minSdkVersion 24  // Agora peut avoir des requirements specifiques
    }
}
```
