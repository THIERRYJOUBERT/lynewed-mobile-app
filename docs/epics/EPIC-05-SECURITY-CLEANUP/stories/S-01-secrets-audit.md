# Story S-01: Audit et Remediation Secrets Exposes

## Metadata
| Champ | Valeur |
|-------|--------|
| **ID** | S-01 |
| **Epic** | EPIC-05-SECURITY-CLEANUP |
| **Priorite** | P0 - CRITIQUE |
| **Estimation** | 4h |
| **Statut** | COMPLETE |
| **Date completion** | 2026-01-24 |

---

## Description

En tant que **security engineer**, je veux auditer et remedier tous les secrets exposes dans le codebase afin de **securiser l'application contre les fuites de credentials**.

---

## Contexte

L'audit initial a revele plusieurs secrets exposes:

### Secrets Identifies

| Fichier | Secret | Risque |
|---------|--------|--------|
| `lib/firebase_options.dart` | Firebase API Key (`AIzaSyAXDspp3RSvw234OfrfSHvkXgbvbsliedg`) | CRITIQUE |
| `.env` (asset) | Supabase URL + Anon Key | HAUTE |
| `.env` (asset) | Google Places API Keys (iOS/Android) | HAUTE |
| `.env` (asset) | Agora App ID | MOYENNE |
| `pubspec.yaml` | Reference `.env` comme asset bundled | CRITIQUE |

### Pourquoi c'est critique

- **Firebase API Key en dur**: Commite dans git, visible dans le binaire APK/IPA
- **.env comme asset**: Bundle les secrets dans l'app distribuee
- **Pas de rotation**: Ces cles n'ont probablement jamais ete rotees

---

## Criteres d'Acceptance

- [x] Audit complet de tous les secrets dans le codebase
- [x] Rapport des findings documente (fichier, ligne, type de secret)
- [x] Firebase API key migree vers solution securisee
- [x] .env retire des assets du pubspec.yaml
- [x] Secrets migres vers `--dart-define-from-file` pour le build
- [ ] Anciennes cles rotees (Firebase, Google, Agora) - HORS SCOPE CODE
- [x] Tests de regression passent
- [x] Documentation de la nouvelle approche secrets

---

## Checklist Securite

### Audit
- [x] Grep exhaustif pour patterns: `api_key`, `apikey`, `secret`, `password`, `token`, `credential`, `private_key`
- [x] Verification `.env` non commite (dans .gitignore)
- [x] Verification historique git pour secrets leakes
- [x] Scan des fichiers de config (Info.plist, AndroidManifest.xml)

### Remediation
- [x] Creer fichier `secrets.json` local (non commite)
- [x] Configurer `--dart-define-from-file=secrets.json` dans build scripts
- [x] Mettre a jour `FFAppConstants` pour lire depuis dart-define
- [x] Retirer `.env` de `pubspec.yaml` assets
- [x] Ajouter `secrets.json` a `.gitignore`
- [x] Documenter process pour nouveaux devs

### Post-Remediation (Action Manuelle Requise)
- [ ] Rotation Firebase API Key dans console Firebase
- [ ] Rotation Google Places API Keys dans GCP Console
- [ ] Rotation Agora App ID si possible
- [ ] Invalider/supprimer anciennes cles

---

## Implementation Realisee

### Fichiers Crees
- `lib/config/app_secrets.dart` - Classe abstraite avec String.fromEnvironment
- `secrets.json.example` - Template pour les developpeurs
- `test/security/secrets_config_test.dart` - 9 tests de validation
- `docs/epics/EPIC-05-SECURITY-CLEANUP/AUDIT-SECRETS-REPORT.md` - Rapport d'audit
- `docs/epics/EPIC-05-SECURITY-CLEANUP/SECRETS-SETUP.md` - Documentation setup

### Fichiers Modifies
- `lib/app_constants.dart` - Migration vers AppSecrets
- `lib/firebase_options.dart` - Migration vers AppSecrets
- `lib/backend/supabase/supabase.dart` - Migration vers AppSecrets
- `lib/main.dart` - Suppression dotenv.load()
- `pubspec.yaml` - Suppression .env des assets
- `.gitignore` - Ajout secrets.json

### Architecture Secrets

```
secrets.json (non commite)
    |
    v
--dart-define-from-file=secrets.json
    |
    v
AppSecrets (String.fromEnvironment)
    |
    +-- FFAppConstants.googlePlacesApiKey
    +-- FFAppConstants.agoraAppId
    +-- DefaultFirebaseOptions.ios/android
    +-- SupaFlow._kSupabaseUrl/_kSupabaseAnonKey
```

---

## Limitations Connues

Les fichiers natifs suivants contiennent toujours des API keys en dur:

| Fichier | Raison | Documentation |
|---------|--------|---------------|
| `ios/Runner/AppDelegate.swift` | SDK Google natif | SECRETS-SETUP.md |
| `android/app/src/main/AndroidManifest.xml` | SDK Google natif | SECRETS-SETUP.md |

Ces fichiers necessitent une remediation manuelle via xcconfig (iOS) et gradle properties (Android). Instructions detaillees dans SECRETS-SETUP.md.

---

## Definition of Done

- [x] Tous les secrets Dart migres hors du code source
- [x] .env retire des assets
- [x] Build fonctionne avec --dart-define-from-file
- [x] Documentation mise a jour
- [ ] Anciennes cles rotees - ACTION MANUELLE POST-MERGE
- [x] flutter analyze: 0 warnings
- [x] flutter test (security): 9/9 tests passent
