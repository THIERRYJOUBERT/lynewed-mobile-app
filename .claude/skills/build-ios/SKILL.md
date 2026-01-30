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
- 📍 ALWAYS utiliser des chemins absolus (éviter les cd)
- ⏱️ ALWAYS lancer xcodebuild en background et attendre avec TaskOutput

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
1. Vérifiant/démarrant le simulateur
2. Compilant avec xcodebuild (sans signature) - EN BACKGROUND
3. Copiant .env dans le bundle
4. Signant les frameworks manuellement
5. Installant et lançant l'app

---

## Execution

### 1. Vérifier/démarrer le simulateur

```bash
# Vérifier si un simulateur est lancé
xcrun simctl list devices | grep -i booted
```

**Si aucun résultat** (pas de simulateur lancé):
```bash
xcrun simctl boot 04B822AE-18B4-4BDA-86A5-47AB23CA0E2F && open -a Simulator
```

---

### 2. Build avec xcodebuild (BACKGROUND)

**IMPORTANT**: Lancer en background avec `run_in_background: true` car le build prend 1-3 minutes.

```bash
cd /Users/leoberthet/Desktop/lynewed_v1/ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,id=04B822AE-18B4-4BDA-86A5-47AB23CA0E2F' CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=YES
```

**ATTENDRE**: Utiliser `TaskOutput` avec `block: true` et `timeout: 300000` (5 min).

**Validation**: Le fichier output doit contenir `** BUILD SUCCEEDED **` à la fin.

**Si BUILD FAILED**: Lire les dernières lignes du fichier output pour voir les erreurs.

---

### 3. Copier .env, signer et lancer (une seule commande)

```bash
APP_PATH="/Users/leoberthet/Library/Developer/Xcode/DerivedData/Runner-hetrbdshiimdwtavyfrtbyvcocvp/Build/Products/Debug-iphonesimulator/Runner.app" && \
cp /Users/leoberthet/Desktop/lynewed_v1/.env "$APP_PATH/Frameworks/App.framework/flutter_assets/.env" && \
cd "$APP_PATH/Frameworks" && for fw in *.framework; do codesign --force --sign - --timestamp=none "$fw" 2>/dev/null; done && \
codesign --force --sign - --deep --timestamp=none "$APP_PATH" && \
xcrun simctl uninstall 04B822AE-18B4-4BDA-86A5-47AB23CA0E2F com.lynewed.app 2>/dev/null || true && \
xcrun simctl install 04B822AE-18B4-4BDA-86A5-47AB23CA0E2F "$APP_PATH" && \
xcrun simctl launch 04B822AE-18B4-4BDA-86A5-47AB23CA0E2F com.lynewed.app
```

**Validation**: La commande retourne un PID (ex: `com.lynewed.app: 77963`).

---

## Validation Finale

| Étape | Critère |
|-------|---------|
| ✅ Simulateur | Un simulateur est "Booted" |
| ✅ Build | `** BUILD SUCCEEDED **` dans l'output |
| ✅ Launch | PID retourné (ex: `com.lynewed.app: 83991`) |

---

## Output

```
✅ Build iOS réussi !

| Élément | Détail |
|---------|--------|
| App | Runner.app |
| Simulateur | iPhone 16e |
| PID | {pid} |

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

## Si --clean demandé

Avant l'étape 2, exécuter:
```bash
cd /Users/leoberthet/Desktop/lynewed_v1 && flutter clean && flutter pub get
cd /Users/leoberthet/Desktop/lynewed_v1/ios && pod install
```

---

## Troubleshooting

### Build prend trop de temps
→ C'est normal, 1-3 minutes. Utiliser `run_in_background: true` + `TaskOutput`.

### "Unknown build action ''"
→ S'assurer qu'il n'y a pas de pipe `| grep` dans la commande xcodebuild (masque les erreurs).

### Erreur CodeSign avec flutter build
→ Utiliser xcodebuild directement avec CODE_SIGNING_REQUIRED=NO

### Pods out of sync
→ `cd /Users/leoberthet/Desktop/lynewed_v1/ios && rm Podfile.lock && pod install`

### .env non chargé (écran blanc)
→ Vérifier que .env est copié dans App.framework/flutter_assets/

### Firebase crash (SIGABRT)
→ Vérifier que GoogleService-Info.plist est dans project.pbxproj

### APP_PATH vide ou introuvable
→ Le build a peut-être échoué. Relire l'output du build.
