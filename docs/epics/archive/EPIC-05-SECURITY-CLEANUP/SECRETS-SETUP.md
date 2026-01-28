# Configuration des Secrets - Lynewed

> Guide pour configurer les secrets de l'application de maniere securisee.

---

## Architecture Securisee

Depuis la remediation S-01, les secrets sont geres via **--dart-define-from-file** au lieu de `.env` comme asset. Cette approche offre:

- **Securite**: Les secrets ne sont pas dans le code source ni dans git
- **Compile-time**: Les secrets sont des constantes de compilation (tree-shaken si non utilises)
- **Pas de runtime**: Pas de lecture de fichier au demarrage

---

## Setup pour Nouveaux Developpeurs

### 1. Creer le fichier secrets.json

Copier l'exemple et remplir avec les vraies valeurs:

```bash
cp secrets.json.example secrets.json
```

Editer `secrets.json` avec vos credentials (demandez-les a l'equipe):

```json
{
  "SUPABASE_URL": "https://xxx.supabase.co",
  "SUPABASE_ANON_KEY": "eyJ...",
  "GOOGLE_PLACES_API_KEY_IOS": "AIza...",
  "GOOGLE_PLACES_API_KEY_ANDROID": "AIza...",
  "AGORA_APP_ID": "xxx",
  "FIREBASE_API_KEY_IOS": "AIza...",
  "FIREBASE_API_KEY_ANDROID": "AIza..."
}
```

### 2. Executer l'application

Toujours utiliser `--dart-define-from-file`:

```bash
# Development
flutter run --dart-define-from-file=secrets.json

# iOS build
flutter build ios --dart-define-from-file=secrets.json

# Android build
flutter build apk --dart-define-from-file=secrets.json
```

---

## Ou Trouver les Secrets

| Secret | Source |
|--------|--------|
| SUPABASE_URL | Supabase Dashboard > Settings > API |
| SUPABASE_ANON_KEY | Supabase Dashboard > Settings > API |
| GOOGLE_PLACES_API_KEY_IOS | Google Cloud Console > Credentials (restreint au bundle iOS) |
| GOOGLE_PLACES_API_KEY_ANDROID | Google Cloud Console > Credentials (restreint au package Android) |
| AGORA_APP_ID | Agora Console > Project Management |
| FIREBASE_API_KEY_IOS | Firebase Console > Project Settings > iOS app |
| FIREBASE_API_KEY_ANDROID | Firebase Console > Project Settings > Android app |

---

## Architecture Code

```
lib/
├── config/
│   └── app_secrets.dart       # Classe abstraite avec String.fromEnvironment
├── app_constants.dart          # Utilise AppSecrets
├── firebase_options.dart       # Utilise AppSecrets
└── backend/supabase/
    └── supabase.dart           # Utilise AppSecrets
```

### Exemple d'utilisation

```dart
// Dans app_secrets.dart
abstract class AppSecrets {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  // ...
}

// Dans le code
final url = AppSecrets.supabaseUrl;
```

---

## CI/CD

Pour les builds automatises (GitHub Actions, Codemagic, etc.):

1. Stocker les secrets dans les variables d'environnement du CI
2. Generer `secrets.json` au runtime avant le build

Exemple GitHub Actions:

```yaml
- name: Create secrets.json
  run: |
    echo '{
      "SUPABASE_URL": "${{ secrets.SUPABASE_URL }}",
      "SUPABASE_ANON_KEY": "${{ secrets.SUPABASE_ANON_KEY }}",
      "GOOGLE_PLACES_API_KEY_IOS": "${{ secrets.GOOGLE_PLACES_API_KEY_IOS }}",
      "GOOGLE_PLACES_API_KEY_ANDROID": "${{ secrets.GOOGLE_PLACES_API_KEY_ANDROID }}",
      "AGORA_APP_ID": "${{ secrets.AGORA_APP_ID }}",
      "FIREBASE_API_KEY_IOS": "${{ secrets.FIREBASE_API_KEY_IOS }}",
      "FIREBASE_API_KEY_ANDROID": "${{ secrets.FIREBASE_API_KEY_ANDROID }}"
    }' > secrets.json

- name: Build
  run: flutter build apk --dart-define-from-file=secrets.json
```

---

## Erreurs Courantes

### "SUPABASE_URL is not configured"

Vous n'avez pas utilise `--dart-define-from-file`:

```bash
# Incorrect
flutter run

# Correct
flutter run --dart-define-from-file=secrets.json
```

### secrets.json non trouve

Verifiez que le fichier existe a la racine du projet:

```bash
ls -la secrets.json
```

---

## Securite

- **JAMAIS** commiter `secrets.json` (deja dans `.gitignore`)
- **TOUJOURS** utiliser des API keys avec restrictions (bundle ID, package name)
- **REGULIEREMENT** rotater les cles si elles ont ete exposees

---

## Fichiers Natifs (iOS/Android) - Remediation Manuelle Requise

### Limitation Connue

Les fichiers suivants contiennent encore des API keys en dur car ils sont requis par les SDKs natifs:

| Fichier | Secret | Action |
|---------|--------|--------|
| `ios/Runner/AppDelegate.swift` | Google Maps/Places API Key | Utiliser xcconfig |
| `android/app/src/main/AndroidManifest.xml` | Google Maps API Key | Utiliser gradle properties |
| `android/app/google-services.json` | Firebase config | Standard Firebase (garde) |
| `ios/Runner/GoogleService-Info.plist` | Firebase config | Standard Firebase (garde) |

### Remediation iOS (xcconfig)

1. Creer `ios/Config/Secrets.xcconfig`:
```
GOOGLE_MAPS_API_KEY = AIza-your-key
```

2. Ajouter a `.gitignore`:
```
ios/Config/Secrets.xcconfig
```

3. Modifier `ios/Runner/AppDelegate.swift`:
```swift
// Lire depuis Info.plist qui herite de xcconfig
let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String ?? ""
GMSServices.provideAPIKey(apiKey)
GMSPlacesClient.provideAPIKey(apiKey)
```

### Remediation Android (gradle properties)

1. Ajouter dans `android/local.properties` (non commite):
```
GOOGLE_MAPS_API_KEY=AIza-your-key
```

2. Modifier `android/app/build.gradle`:
```groovy
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader { localProperties.load(it) }
}

android {
    defaultConfig {
        manifestPlaceholders = [
            googleMapsApiKey: localProperties['GOOGLE_MAPS_API_KEY'] ?: ''
        ]
    }
}
```

3. Modifier `AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${googleMapsApiKey}" />
```

### Note sur Firebase

Les fichiers `google-services.json` et `GoogleService-Info.plist` sont des fichiers de configuration Firebase standards. Ils contiennent des API keys mais:

1. Ces cles sont restreintes par package/bundle ID
2. Firebase les requiert pour l'initialisation
3. Ils sont generes par Firebase CLI

**Recommandation**: Garder ces fichiers mais s'assurer que les restrictions d'API sont configurees dans Firebase Console.

---

## Migration depuis .env

Si vous aviez un ancien setup avec `.env`:

1. Les valeurs de `.env` sont maintenant dans `secrets.json`
2. Le format change de `KEY=value` a JSON `{"KEY": "value"}`
3. Plus besoin de `flutter_dotenv` (peut etre retire des deps si non utilise ailleurs)
