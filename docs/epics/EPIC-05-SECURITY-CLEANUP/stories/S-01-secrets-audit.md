# Story S-01: Audit et Remediation Secrets Exposes

## Metadata
| Champ | Valeur |
|-------|--------|
| **ID** | S-01 |
| **Epic** | EPIC-05-SECURITY-CLEANUP |
| **Priorite** | P0 - CRITIQUE |
| **Estimation** | 4h |
| **Statut** | NOT_STARTED |

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

- [ ] Audit complet de tous les secrets dans le codebase
- [ ] Rapport des findings documente (fichier, ligne, type de secret)
- [ ] Firebase API key migree vers solution securisee
- [ ] .env retire des assets du pubspec.yaml
- [ ] Secrets migres vers `--dart-define-from-file` pour le build
- [ ] Anciennes cles rotees (Firebase, Google, Agora)
- [ ] Tests de regression passent
- [ ] Documentation de la nouvelle approche secrets

---

## Checklist Securite

### Audit
- [ ] Grep exhaustif pour patterns: `api_key`, `apikey`, `secret`, `password`, `token`, `credential`, `private_key`
- [ ] Verification `.env` non commite (dans .gitignore)
- [ ] Verification historique git pour secrets leakes
- [ ] Scan des fichiers de config (Info.plist, AndroidManifest.xml)

### Remediation
- [ ] Creer fichier `secrets.json` local (non commite)
- [ ] Configurer `--dart-define-from-file=secrets.json` dans build scripts
- [ ] Mettre a jour `FFAppConstants` pour lire depuis dart-define
- [ ] Retirer `.env` de `pubspec.yaml` assets
- [ ] Ajouter `secrets.json` a `.gitignore`
- [ ] Documenter process pour nouveaux devs

### Post-Remediation
- [ ] Rotation Firebase API Key dans console Firebase
- [ ] Rotation Google Places API Keys dans GCP Console
- [ ] Rotation Agora App ID si possible
- [ ] Invalider/supprimer anciennes cles

---

## Implementation

### Etape 1: Audit
```bash
# Scanner tout le codebase
grep -rn "api_key\|apikey\|secret\|password\|token" lib/

# Verifier historique git
git log -p --all -S 'api_key' -- '*.dart'
```

### Etape 2: Creer secrets.json
```json
{
  "SUPABASE_URL": "https://xxx.supabase.co",
  "SUPABASE_ANON_KEY": "xxx",
  "GOOGLE_PLACES_API_KEY_IOS": "xxx",
  "GOOGLE_PLACES_API_KEY_ANDROID": "xxx",
  "AGORA_APP_ID": "xxx",
  "FIREBASE_API_KEY_IOS": "xxx",
  "FIREBASE_API_KEY_ANDROID": "xxx"
}
```

### Etape 3: Modifier FFAppConstants
```dart
abstract class FFAppConstants {
  static String get googlePlacesApiKey {
    const key = String.fromEnvironment('GOOGLE_PLACES_API_KEY_${Platform.isIOS ? "IOS" : "ANDROID"}');
    return key;
  }
  // ...
}
```

### Etape 4: Build avec secrets
```bash
flutter build ios --dart-define-from-file=secrets.json
flutter build apk --dart-define-from-file=secrets.json
```

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Build casse apres migration | HAUT | Tester build complet avant merge |
| Secrets deja compromis | CRITIQUE | Rotation immediate apres remediation |
| Devs sans secrets.json | MOYEN | README avec instructions setup |

---

## Definition of Done

- [ ] Tous les secrets migres hors du code source
- [ ] .env retire des assets
- [ ] Build fonctionne avec --dart-define-from-file
- [ ] Documentation mise a jour
- [ ] Anciennes cles rotees
- [ ] PR reviewee et mergee
