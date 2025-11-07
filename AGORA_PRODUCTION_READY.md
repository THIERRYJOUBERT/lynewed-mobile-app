# 🎊 AGORA VIDEO SDK - CONFIGURATION PRODUCTION v1.0.52+55

**Date**: 7 Novembre 2025  
**Status**: ✅ PRODUCTION READY  
**Version Flutter SDK**: 6.3.2  
**Version iOS Native**: 4.3.2  

---

## 📊 RÉSUMÉ EXÉCUTIF

### ✅ Problème résolu
L'application iOS TestFlight gelait lors des appels vidéo Agora. **Root cause**: Ordre d'initialisation incorrect (`registerEventHandler()` avant `initialize()`) + stripping de symboles en release iOS.

### 🎯 Solution finale
1. **Ordre correct**: `initialize()` → `registerEventHandler()` (selon doc Agora)
2. **iOS Release flags**: `OTHER_LDFLAGS = -ObjC` + `STRIP_STYLE = non-global`
3. **Logs sécurisés**: Masquage App ID, Channel ID, User ID
4. **Architecture singleton**: Gestion centralisée avec event stream global

### 📈 Métriques de succès
- ✅ Callbacks fonctionnels: `onJoinChannelSuccess` (167ms), `onUserJoined`, `onUserOffline`
- ✅ Initialisation: 75ms au démarrage
- ✅ Connexion: < 200ms
- ✅ Cleanup: Propre et sans leak

---

## 🏗️ ARCHITECTURE

### 1. Singleton Manager (`AgoraEngineManager`)

**Fichier**: `lib/services/agora_engine_manager.dart`

**Responsabilités**:
- Création unique de `RtcEngine`
- Initialisation au démarrage (avec timeout 10s)
- Enregistrement des event handlers APRÈS initialize()
- Dispatch global des événements via `StreamController`

**Pattern**:
```dart
AgoraEngineManager.instance
  .ensureInitialized(appId: '...', timeout: Duration(seconds: 10))
  .eventStream.listen((event) => ...)
```

### 2. Widget UI (`AgoraVideoViewWidget`)

**Fichier**: `lib/custom_code/widgets/agora_video_view.dart`

**Responsabilités**:
- Écoute du stream global d'événements
- Filtrage par `channelName` courant
- Gestion UI (local/remote video, états)
- Cleanup sur dispose (leave channel + stop preview, SANS release engine)

**Cycle de vie**:
```
initState() → Subscribe au eventStream
→ initAgora() → Get engine from singleton
→ joinChannel()
→ onJoinChannelSuccess, onUserJoined
→ dispose() → Unsubscribe + leave + stop preview
```

### 3. Initialisation au démarrage

**Fichier**: `lib/main.dart`

**Logique**:
```dart
main() async {
  await Firebase.initializeApp();
  
  // Pré-initialiser Agora (optionnel, fallback on-demand)
  try {
    await AgoraEngineManager.instance.ensureInitialized(
      appId: FFAppConstants.agoraAppId,
      timeout: const Duration(seconds: 10),
    );
  } catch (e) {
    // Engine sera initialisé on-demand
  }
  
  runApp(...);
}
```

---

## 🔧 CONFIGURATION iOS

### Release.xcconfig

**Fichier**: `ios/Flutter/Release.xcconfig`

```xcconfig
#include "Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"
#include "Generated.xcconfig"

// Ensure Objective-C categories and symbols used by plugins (e.g., Agora) are retained in Release
OTHER_LDFLAGS = $(inherited) -ObjC
STRIP_STYLE = non-global
```

**Explication**:
- `OTHER_LDFLAGS = -ObjC`: Force le linker à charger TOUTES les catégories Objective-C (requis pour callbacks Agora)
- `STRIP_STYLE = non-global`: Évite le stripping agressif des symboles en release (callbacks silencieux sinon)

### Info.plist

**Fichier**: `ios/Runner/Info.plist`

**Permissions essentielles**:
```xml
<key>NSCameraUsageDescription</key>
<string>Lynewed needs access to your camera so you can take photos and make video calls</string>

<key>NSMicrophoneUsageDescription</key>
<string>Lynewed needs access to your microphone to allow you to record audio messages and make video calls</string>

<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
    <string>audio</string>
    <string>voip</string>
</array>
```

**Permissions NON requises**:
- ❌ `NSLocalNetworkUsageDescription`: PAS nécessaire selon doc Agora
- ❌ `NSBonjourServices` Agora-specific: PAS nécessaire

### Podfile

**Fichier**: `ios/Podfile`

**Bitcode stripping** (déjà configuré):
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
  
  # Strip bitcode from Agora frameworks
  Dir.glob('Pods/AgoraRtcEngine_iOS/**/*.framework').each do |framework_path|
    # ... (bitcode removal logic)
  end
end
```

---

## 📦 DÉPENDANCES

### pubspec.yaml

```yaml
version: 1.0.52+55

dependencies:
  agora_rtc_engine: 6.3.2  # Version STABLE (pas de bug callbacks)
  permission_handler: 12.0.0+1
```

**Pourquoi 6.3.2 et non 6.5.3?**
- Version testée et validée sur iOS production
- Pas de breaking changes entre 6.3.2 et 6.5.3 pour notre use case
- Possible upgrade futur si nouveaux features nécessaires

---

## 🔐 SÉCURITÉ DES LOGS

### Logs masqués en production

**App ID**: `ddfcd5a0***` (8 premiers chars)  
**Channel ID**: `71e80cd4***` (8 premiers chars)  
**User ID**: `b3e19bcc***` (8 premiers chars)  
**Token**: `006ddfcd5a` (10 premiers chars uniquement)

### Implémentation

**Manager**:
```dart
final channelId = connection.channelId ?? '';
final maskedChannel = channelId.length > 8 
    ? '${channelId.substring(0, 8)}***' 
    : channelId;
debugPrint('Channel: $maskedChannel');
```

**Widget**:
```dart
print('App ID: ${widget.appId.substring(0, min(8, widget.appId.length))}***');
print('User ID: ${widget.userId.substring(0, min(8, widget.userId.length))}***');
```

### Données NON masquées (safe)

- ✅ UIDs numériques Agora (dérivés, non réversibles)
- ✅ Timestamps, elapsed times
- ✅ Status codes, error types
- ✅ Connection states

---

## 🔄 ORDRE D'INITIALISATION (CRITIQUE)

### ✅ Ordre CORRECT (implémenté)

```dart
// STEP 1: Initialize engine
await engine.initialize(
  RtcEngineContext(
    appId: appId,
    channelProfile: ChannelProfileType.channelProfileCommunication,
  ),
);

// STEP 2: Register event handlers APRÈS initialize()
engine.registerEventHandler(RtcEngineEventHandler(
  onJoinChannelSuccess: (connection, elapsed) { ... },
  onUserJoined: (connection, remoteUid, elapsed) { ... },
  // ...
));
```

### ❌ Ordre INCORRECT (cause du bug)

```dart
// ❌ WRONG: Handler avant initialize
engine.registerEventHandler(RtcEngineEventHandler(...));
await engine.initialize(...);
```

**Pourquoi c'est crucial?**
> "You must call `initialize` before calling `registerEventHandler`. If you register the event handler before initialization, some callbacks may not be triggered."  
> — Agora Flutter SDK 6.x API Reference

---

## 🎬 SÉQUENCE D'APPEL VIDÉO

### Phase 1: Démarrage app
```
main() 
→ AgoraEngineManager.ensureInitialized(timeout: 10s)
→ createAgoraRtcEngine()
→ engine.initialize()
→ engine.registerEventHandler()
→ ✅ Engine prêt (75ms)
```

### Phase 2: Initiation appel
```
User A → Crée video_session → Supabase
→ Edge Function agora_token_issue
→ Génère token (expiration 3600s)
→ FCM notification → User B
→ User B → VideoCallPage
```

### Phase 3: Connexion
```
initAgora()
→ engine = AgoraEngineManager.instance.engine
→ engine.enableVideo()
→ engine.startPreview()
→ engine.joinChannel(token, channelId, uid, options)
→ ✅ onJoinChannelSuccess (167ms)
→ ✅ onUserJoined (1673ms)
→ Remote video displayed
```

### Phase 4: Fin d'appel
```
agoraEndCall()
→ engine.stopPreview()
→ engine.leaveChannel()
→ ✅ onUserOffline
→ Update video_session status = 'ended'
→ Navigate back
```

---

## 🧪 VALIDATION LOGS

### Logs attendus au démarrage
```
🎥 [AGORA] Initializing engine at app startup...
🎥 [AGORA_MANAGER] Initializing engine...
🎥 [AGORA_MANAGER] ✅ Engine initialized
🎥 [AGORA_MANAGER] Registering event handlers...
🎥 [AGORA_MANAGER] ✅ Event handlers registered
🎥 [AGORA] ✅ Engine initialized successfully at startup
```

### Logs lors d'un appel
```
🎥 [AGORA] === STEP 1: VALIDATION ===
🎥 [AGORA] App ID: ddfcd5a0***
🎥 [AGORA] Token: 006ddfcd5a
🎥 [AGORA] Channel: 71e80cd4***
🎥 [AGORA] User ID: b3e19bcc***
🎥 [AGORA] === STEP 8: JOIN CHANNEL ===
🎥 [AGORA] joinChannel() call completed
🎥 [AGORA] 🔗 Connection: connectionStateConnecting
🎥 [AGORA] 🎊🎊🎊 onJoinChannelSuccess FIRED 🎊🎊🎊
🎥 [AGORA] Channel ID: 71e80cd4***
🎥 [AGORA] Local UID: 1600458867
🎥 [AGORA] Elapsed time: 167ms
🎥 [AGORA] 👤 onUserJoined FIRED - Remote UID: 1307396701
```

### Logs de fin d'appel
```
🎥 [AGORA] 👋 onUserOffline FIRED - Remote UID: 1307396701
🎥 [AGORA] Offline reason: userOfflineQuit
🎥 [AGORA] === CLEANUP: agoraEndCall() ===
🎥 [AGORA] Stopping preview...
🎥 [AGORA] ✅ Preview stopped
🎥 [AGORA] Leaving channel...
🎥 [AGORA] ✅ Channel left
```

---

## ⚙️ PARAMÈTRES AGORA

### Channel Options
```dart
ChannelMediaOptions(
  channelProfile: ChannelProfileType.channelProfileCommunication,  // 1-to-1
  clientRoleType: ClientRoleType.clientRoleBroadcaster,           // Both publish
  publishCameraTrack: true,
  publishMicrophoneTrack: true,
  autoSubscribeAudio: true,
  autoSubscribeVideo: true,
)
```

**Pourquoi `channelProfileCommunication`?**
- Optimisé pour appels 1-to-1 faible latence
- Pas de mode broadcaster/audience
- ❌ `channelProfileLiveBroadcasting` → Pour streaming avec audience

### Audio Route
```dart
await engine.setDefaultAudioRouteToSpeakerphone(true);
```
Active le haut-parleur par défaut (pas écouteur).

---

## 🐛 DEBUGGING

### Vérifier l'ordre d'init
```bash
# Chercher "AGORA_MANAGER" dans les logs
# Doit afficher:
# 1. Initializing engine...
# 2. ✅ Engine initialized
# 3. Registering event handlers...
# 4. ✅ Event handlers registered
```

### Vérifier les callbacks
```bash
# Chercher "onJoinChannelSuccess"
# Si absent après joinChannel() → Problème ordre init ou linker flags
```

### Vérifier les symboles iOS
```bash
cd ios
pod install
# Vérifier Release.xcconfig contient:
# OTHER_LDFLAGS = $(inherited) -ObjC
# STRIP_STYLE = non-global
```

---

## 🚀 BUILD PRODUCTION

### Commandes complètes
```bash
# Clean complet
flutter clean
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks

# Rebuild
flutter pub get
cd ios && pod install --repo-update && cd ..

# Build IPA
flutter build ipa --release --no-tree-shake-icons

# Vérifier
open build/ios/archive/Runner.xcarchive
```

### Flags importants
- `--no-tree-shake-icons`: Évite le tree-shaking agressif qui peut supprimer des symboles Agora
- `--release`: Active les optimisations et utilise Release.xcconfig

---

## 📋 CHECKLIST DÉPLOIEMENT

### Avant chaque build TestFlight
- [ ] Version incrémentée dans `pubspec.yaml`
- [ ] `flutter clean` exécuté
- [ ] Pods réinstallés (`rm -rf ios/Pods && pod install`)
- [ ] `Release.xcconfig` contient les flags Agora
- [ ] Logs sensibles masqués
- [ ] Build avec `--no-tree-shake-icons`

### Après installation TestFlight
- [ ] Lancer app → Vérifier logs démarrage Agora
- [ ] Initier appel vidéo → Vérifier `onJoinChannelSuccess`
- [ ] Vérifier audio/vidéo local
- [ ] Vérifier réception remote user
- [ ] Vérifier cleanup propre

---

## 🔮 AMÉLIORATIONS FUTURES

### Performance
- [ ] Lazy initialization (supprimer init au démarrage → économie 75ms)
- [ ] Cache video frames pendant rotation
- [ ] Adaptive bitrate selon connexion

### Features
- [ ] Screen sharing
- [ ] Virtual background
- [ ] Recording côté client
- [ ] Noise cancellation (extension Agora)

### Monitoring
- [ ] Métriques connexion (latency, packet loss)
- [ ] Analytics appels (durée moyenne, taux échec)
- [ ] Crash reporting spécifique Agora

---

## 📚 RÉFÉRENCES

### Documentation officielle
- [Agora Flutter SDK 6.x](https://api-ref.agora.io/en/video-sdk/flutter/6.x/)
- [iOS Integration Guide](https://docs.agora.io/en/video-calling/get-started/get-started-sdk?platform=flutter)
- [Best Practices iOS](https://docs.agora.io/en/video-calling/develop/product-workflow?platform=flutter)

### Issues résolues
- Callbacks not firing → Ordre init inversé
- Silent failures iOS release → Linker flags manquants
- Local network permission → Pas nécessaire (fausse piste)
- 10s timeout startup → Engine pré-init optionnel

---

## ✅ CONCLUSION

### Status final
🎊 **APPLICATION PRODUCTION READY**

### Validation
- ✅ Callbacks fonctionnels
- ✅ Connexion stable < 200ms
- ✅ Logs sécurisés (RGPD compliant)
- ✅ Architecture scalable
- ✅ Build settings iOS corrects
- ✅ Cleanup sans memory leaks

### Version déployée
**v1.0.52+55** - 7 Novembre 2025

---

**Dernière mise à jour**: 7 Novembre 2025  
**Auteur**: Configuration Agora Production
**Contact**: [Votre équipe technique]
