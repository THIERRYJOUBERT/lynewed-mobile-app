---
name: build-ios
description: "Build et lance l'app iOS sur simulateur. Utiliser pour tester rapidement l'app."
model: sonnet
allowed-tools:
  - Bash
  - Read
argument-hint: "[--clean]"
---

# /build-ios

Build et lance l'app iOS sur le simulateur de manière fiable et rapide.

---

## Rules

- 🚀 ALWAYS utiliser xcodebuild (plus fiable que flutter build ios)
- 🔏 ALWAYS désactiver la signature de code pour simulateur
- 📋 ALWAYS copier .env dans le bundle App.framework
- ⚡ NEVER faire flutter clean sauf si --clean demandé

---

## Variables

```yaml
SIMULATOR_ID: "04B822AE-18B4-4BDA-86A5-47AB23CA0E2F"  # iPhone 16e
BUNDLE_ID: "com.lynewed.app"
PROJECT_DIR: "/Users/leoberthet/Desktop/lynewed_v1"
```

---

## Task

Builder l'app iOS et la lancer sur le simulateur actif en:
1. Vérifiant/installant les dépendances si nécessaire
2. Compilant avec xcodebuild (sans signature)
3. Copiant .env dans le bundle
4. Signant les frameworks manuellement
5. Installant et lançant l'app

---

## Execution

### 0. Nettoyer les fichiers parasites

Avant de commencer, supprimer les fichiers dupliqués/logs qui polluent le projet :

```bash
# Supprimer les copies accidentelles de .flutter-plugins-dependencies
rm -f ".flutter-plugins-dependencies 2" ".flutter-plugins-dependencies 3" 2>/dev/null

# Supprimer les anciens logs Flutter
rm -f flutter_*.log 2>/dev/null

# Supprimer le cache Kotlin Android (si présent et non gitignored)
# Note: devrait être dans .gitignore
```

---

### 1. Vérifier le simulateur

```bash
xcrun simctl list devices | grep -i booted
```

**Validation**: Un simulateur doit être lancé (Booted).

Si aucun simulateur lancé:
```bash
xcrun simctl boot 04B822AE-18B4-4BDA-86A5-47AB23CA0E2F
open -a Simulator
```

---

### 2. Gérer les dépendances (conditionnel)

**Flutter packages** (si pubspec.yaml modifié):
```bash
# Vérifier si nécessaire
if [ "pubspec.lock" -ot "pubspec.yaml" ]; then
  flutter pub get
fi
```

**Pods iOS** (si Podfile modifié ou Pods manquants):
```bash
# Vérifier si nécessaire
if [ ! -d "ios/Pods" ] || [ "ios/Podfile.lock" -ot "ios/Podfile" ]; then
  cd ios && pod install && cd ..
fi
```

**Si --clean demandé:**
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

---

### 3. Build avec xcodebuild

```bash
cd ios
xcodebuild \
  -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,id=04B822AE-18B4-4BDA-86A5-47AB23CA0E2F" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=YES \
  2>&1 | grep -E "(BUILD|SUCCEEDED|FAILED|error:)" || true
cd ..
```

**Validation**: Message "BUILD SUCCEEDED" dans la sortie.

**Si BUILD FAILED**: Afficher les erreurs et s'arrêter.

---

### 4. Localiser et préparer le bundle

```bash
# Trouver l'app buildée
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/Runner-*/Build/Products/Debug-iphonesimulator -name "Runner.app" -type d 2>/dev/null | xargs ls -td | head -1)

# Copier .env dans le bundle
cp .env "$APP_PATH/Frameworks/App.framework/flutter_assets/.env"

# Signer les frameworks
cd "$APP_PATH/Frameworks"
for framework in *.framework; do
  codesign --force --sign - --timestamp=none "$framework" 2>/dev/null
done
cd ..

# Signer l'app
codesign --force --sign - --deep --timestamp=none "$APP_PATH"
```

**Validation**: APP_PATH non vide et .env copié.

---

### 5. Installer et lancer

```bash
# Désinstaller l'ancienne version
xcrun simctl uninstall 04B822AE-18B4-4BDA-86A5-47AB23CA0E2F com.lynewed.app 2>/dev/null || true

# Installer la nouvelle
xcrun simctl install 04B822AE-18B4-4BDA-86A5-47AB23CA0E2F "$APP_PATH"

# Lancer
xcrun simctl launch 04B822AE-18B4-4BDA-86A5-47AB23CA0E2F com.lynewed.app
```

**Validation**: PID retourné par simctl launch.

---

## Validation

**Before completing:**
✅ Simulateur actif
✅ Build succeeded
✅ .env copié dans bundle
✅ App lancée (PID retourné)

**If issues found:**
- Build failed → Afficher erreurs xcodebuild
- App not found → Vérifier DerivedData
- Launch failed → Vérifier bundle ID et simulateur

---

## Output

```
✅ Build iOS réussi !

App: Runner.app
Simulateur: iPhone 16e
PID: {pid}

Pour voir les logs:
xcrun simctl spawn 04B822AE-18B4-4BDA-86A5-47AB23CA0E2F log stream --predicate 'processImagePath contains "Runner"' --level debug
```

---

## Quick Reference

| Commande | Action |
|----------|--------|
| `/build-ios` | Build et lance (incremental) |
| `/build-ios --clean` | Clean complet puis build |

---

## Troubleshooting

### Erreur CodeSign avec flutter build
→ Utiliser xcodebuild directement avec CODE_SIGNING_REQUIRED=NO

### Pods out of sync
→ `cd ios && rm Podfile.lock && pod install`

### .env non chargé (écran blanc)
→ Vérifier que .env est copié dans App.framework/flutter_assets/

### Firebase crash (SIGABRT)
→ Vérifier que GoogleService-Info.plist est dans project.pbxproj
