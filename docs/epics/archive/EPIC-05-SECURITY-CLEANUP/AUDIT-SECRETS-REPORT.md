# Rapport d'Audit de Securite - Secrets Exposes

**Date**: 2026-01-24
**Auditeur**: Claude Code (S-01)
**Statut**: CRITIQUE - Remediation Requise

---

## Resume Executif

L'audit a identifie **11 secrets exposes** dans le codebase, repartis sur 8 fichiers differents. Le risque global est **CRITIQUE** car plusieurs API keys sont commitees dans git et le fichier `.env` est bundle comme asset dans l'application.

---

## Secrets Identifies

### 1. Firebase API Keys (CRITIQUE)

| Fichier | Ligne | Secret | Risque |
|---------|-------|--------|--------|
| `lib/firebase_options.dart` | 53 | `AIzaSyAXDspp3RSvw234OfrfSHvkXgbvbsliedg` | CRITIQUE |
| `lib/firebase_options.dart` | 62 | `AIzaSyAXDspp3RSvw234OfrfSHvkXgbvbsliedg` | CRITIQUE |
| `android/app/google-services.json` | 18 | `AIzaSyAXDspp3RSvw234OfrfSHvkXgbvbsliedg` | CRITIQUE |
| `ios/Runner/GoogleService-Info.plist` | 6 | `AIzaSyAXDspp3RSvw234OfrfSHvkXgbvbsliedg` | CRITIQUE |

**Impact**: Ces cles sont visibles dans le binaire APK/IPA et commitees dans l'historique git.

### 2. Google Places/Maps API Keys (HAUTE)

| Fichier | Ligne | Secret | Risque |
|---------|-------|--------|--------|
| `ios/Runner/AppDelegate.swift` | 15-17 | `AIzaSyCLOe2yCKXS-yoxq4E4pHt2NTxG8OUbhuY` | HAUTE |
| `android/app/src/main/AndroidManifest.xml` | 70 | `AIzaSyDqLPWBmKcHCSuOp5Ikz6LU5wfqdf2ZSNg` | HAUTE |
| `.env` | 6-9 | Google Places API Keys | HAUTE |

**Impact**: Ces cles sont hardcodees dans les fichiers de configuration natifs.

### 3. Supabase Credentials (HAUTE)

| Fichier | Ligne | Secret | Risque |
|---------|-------|--------|--------|
| `.env` | 2 | `SUPABASE_URL` | HAUTE |
| `.env` | 3 | `SUPABASE_ANON_KEY` (JWT) | HAUTE |

**Impact**: Bien que charges via dotenv, le `.env` est bundle comme asset.

### 4. Agora App ID (MOYENNE)

| Fichier | Ligne | Secret | Risque |
|---------|-------|--------|--------|
| `.env` | 12 | `AGORA_APP_ID` | MOYENNE |

**Impact**: Bundle avec l'app via `.env` comme asset.

### 5. Configuration Critique - pubspec.yaml (CRITIQUE)

| Fichier | Ligne | Probleme |
|---------|-------|----------|
| `pubspec.yaml` | 160 | `.env` liste comme asset - bundle les secrets dans l'APK/IPA |

---

## Analyse des Risques

### Niveau CRITIQUE

1. **Secrets dans historique git**: Les API keys Firebase sont commitees depuis la creation du projet. Meme apres remediation, elles restent dans l'historique.

2. **.env comme asset**: Le fichier `.env` est inclus dans `pubspec.yaml` sous `assets:`, ce qui signifie que tous les secrets sont bundles dans l'application distribuee et extractibles par reverse engineering.

3. **Cles natives hardcodees**: Les API keys Google dans `AppDelegate.swift` et `AndroidManifest.xml` sont en dur.

### Niveau HAUTE

1. **Exposition JWT Supabase**: Le SUPABASE_ANON_KEY est un JWT qui, bien que "anonyme", expose des informations sur le projet.

2. **Pas de restriction d'API keys**: Les Google API keys semblent ne pas avoir de restrictions d'application configurees.

### Niveau MOYENNE

1. **Agora App ID**: Moins critique car Agora utilise des tokens temporaires pour l'authentification, mais devrait quand meme etre protege.

---

## Fichiers Impactes

```
HARDCODED SECRETS (a migrer vers dart-define):
- lib/firebase_options.dart
- ios/Runner/AppDelegate.swift
- android/app/src/main/AndroidManifest.xml

FICHIERS DE CONFIG FIREBASE (standards mais a proteger):
- android/app/google-services.json
- ios/Runner/GoogleService-Info.plist

ENV BUNDLE (a retirer des assets):
- .env
- pubspec.yaml (ligne 160)

LECTURE CORRECTE (mais source non securisee):
- lib/app_constants.dart (lit depuis dotenv)
- lib/backend/supabase/supabase.dart (lit depuis dotenv)
```

---

## Recommandations de Remediation

### Priorite 1: Immediate

1. **Retirer `.env` des assets** dans `pubspec.yaml`
2. **Migrer vers `--dart-define-from-file`** pour le build
3. **Mettre a jour FFAppConstants** pour lire depuis `String.fromEnvironment()`
4. **Mettre a jour firebase_options.dart** pour lire depuis dart-define

### Priorite 2: Court terme

1. **Configurer restrictions d'API keys** dans Google Cloud Console
2. **Creer `secrets.json.example`** avec placeholders
3. **Documenter le processus** pour les nouveaux developpeurs

### Priorite 3: Post-remediation

1. **Rotation des cles** (hors scope code - action manuelle)
   - Firebase API Key dans Firebase Console
   - Google Places API Keys dans GCP Console
   - Considerer rotation Supabase anon key
2. **Audit historique git** pour verifier exposition

---

## Plan de Migration

### Etape 1: Structure des secrets

Creer `/secrets.json` (non commite):
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

### Etape 2: Build avec secrets

```bash
flutter build ios --dart-define-from-file=secrets.json
flutter build apk --dart-define-from-file=secrets.json
flutter run --dart-define-from-file=secrets.json
```

### Etape 3: Code migration

```dart
// AVANT (dotenv)
static String get agoraAppId => dotenv.env['AGORA_APP_ID'] ?? '';

// APRES (dart-define)
static const String agoraAppId = String.fromEnvironment('AGORA_APP_ID');
```

---

## Verification

- [x] `.env` retire des assets pubspec.yaml
- [x] FFAppConstants migre vers dart-define
- [x] firebase_options.dart migre vers dart-define
- [x] supabase.dart migre vers dart-define
- [x] main.dart mis a jour (dotenv.load retire)
- [x] secrets.json.example cree
- [x] .gitignore mis a jour avec secrets.json
- [x] Documentation mise a jour (SECRETS-SETUP.md)
- [ ] Build fonctionne avec --dart-define-from-file (a tester manuellement)
- [x] Tests passent (9/9 tests de securite)

## Limitations Connues (Hors Scope Code)

Les fichiers natifs suivants contiennent toujours des API keys en dur:

| Fichier | Raison | Remediation |
|---------|--------|-------------|
| `ios/Runner/AppDelegate.swift` | SDK Google natif | Utiliser xcconfig (doc fournie) |
| `android/app/src/main/AndroidManifest.xml` | SDK Google natif | Utiliser gradle properties (doc fournie) |
| `google-services.json` | Standard Firebase | Garder, restreindre dans console |
| `GoogleService-Info.plist` | Standard Firebase | Garder, restreindre dans console |

Ces remediations necessitent des modifications de configuration Xcode/Gradle et sont documentees dans `SECRETS-SETUP.md`.

---

## Notes

- Les fichiers `google-services.json` et `GoogleService-Info.plist` sont standards pour Firebase et doivent rester, mais leurs API keys ont ete exposees via l'historique git.
- La rotation des cles est recommandee mais doit etre faite manuellement dans les consoles respectives apres la remediation code.
