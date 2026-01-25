# Session iOS Build Fix - 2026-01-25

**Date**: 2026-01-25
**Branche**: fix/project-cleanup
**Statut**: RESOLVED

---

## Contexte

Après EPIC-01 (Clean Architecture migration 69%), l'app iOS crashait ou affichait un écran blanc.
Cette session documente le debugging et les corrections appliquées.

---

## Problèmes Identifiés et Solutions

### 1. Crash Firebase SIGABRT

**Symptôme**: `EXC_CRASH (SIGABRT)` dans `FIRInstallations validateAppOptions`

**Cause**: `GoogleService-Info.plist` existait dans `ios/Runner/` mais n'était pas référencé dans le projet Xcode.

**Solution**: Ajout au `project.pbxproj`:
```
// PBXBuildFile
F2B3A1E52B5F8C0100A1B2C3 /* GoogleService-Info.plist in Resources */

// PBXFileReference
F2B3A1E42B5F8C0100A1B2C3 /* GoogleService-Info.plist */

// Runner group children
F2B3A1E42B5F8C0100A1B2C3 /* GoogleService-Info.plist */

// PBXResourcesBuildPhase files
F2B3A1E52B5F8C0100A1B2C3 /* GoogleService-Info.plist in Resources */
```

**Fichier**: `ios/Runner.xcodeproj/project.pbxproj`

---

### 2. Écran Blanc (White Screen)

**Symptôme**: App lance mais affiche un écran blanc sans contenu.

**Cause Racine**:
- EPIC-05 avait migré les secrets de `flutter_dotenv` (runtime .env) vers `AppSecrets` (compile-time `--dart-define-from-file`)
- Le script de build `build_and_run.sh` n'utilise PAS `--dart-define-from-file`
- Résultat: `SUPABASE_URL` et autres secrets sont vides à runtime
- `Supabase.initialize()` échoue silencieusement → app bloquée

**Solution**: Restaurer `flutter_dotenv` pour le chargement runtime des secrets.

**Fichiers modifiés**:

| Fichier | Changement |
|---------|------------|
| `lib/main.dart` | Restauré `import 'package:flutter_dotenv/flutter_dotenv.dart'` et `await dotenv.load(fileName: ".env")` |
| `lib/backend/supabase/supabase.dart` | Restauré `dotenv.env['SUPABASE_URL']` et `dotenv.env['SUPABASE_ANON_KEY']` |
| `lib/app_constants.dart` | Restauré `dotenv.env['GOOGLE_PLACES_API_KEY_*']` et `dotenv.env['AGORA_APP_ID']` |
| `lib/firebase_options.dart` | Restauré clés Firebase hardcodées (public client keys, safe) |

---

### 3. Pod Install Failure - Firebase Version

**Symptôme**: Conflit de version Firebase lors de `pod install`

**Cause**: `Podfile.lock` avait Firebase 11.15.0 mais les plugins nécessitaient 12.8.0.
Firebase 12.8.0 requiert iOS 15.0 minimum.

**Solution**:
```ruby
# ios/Podfile
platform :ios, '15.0'  # Était 14.0
config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
```

Puis `rm Podfile.lock && pod install --repo-update`

---

## Décision Technique

### flutter_dotenv vs --dart-define-from-file

| Approche | Avantages | Inconvénients |
|----------|-----------|---------------|
| **flutter_dotenv** (runtime) | Compatible avec tous les scripts de build, flexible | Fichier .env doit être présent, légèrement plus lent |
| **--dart-define** (compile-time) | Secrets non dans bundle, tree-shaking | Requiert modification de TOUS les scripts build/CI |

**Choix**: Restaurer `flutter_dotenv` car:
1. Production app avec 248 utilisateurs actifs - stabilité prioritaire
2. Script `build_and_run.sh` utilisé pour tests manuels
3. Migration `--dart-define` nécessiterait mise à jour CI/CD complète

**Note**: `AppSecrets` classe reste dans le code pour future migration quand CI/CD sera prêt.

---

## Fichiers Modifiés (non commités)

```
modified:   ios/Podfile (iOS 14→15)
modified:   ios/Podfile.lock (regenerated)
modified:   ios/Runner.xcodeproj/project.pbxproj (GoogleService-Info.plist)
modified:   lib/app_constants.dart (dotenv restored)
modified:   lib/backend/supabase/supabase.dart (dotenv restored)
modified:   lib/firebase_options.dart (hardcoded keys restored)
modified:   lib/main.dart (dotenv.load restored)
```

---

## Bug Restant

**Page Notifications**: Erreur `Provider<NotificationsNotifier> not found`

La page centre de notifications affiche une erreur Provider. À investiguer séparément.

---

## Validation

- [x] App build iOS réussie
- [x] App lance sur simulateur iPhone 16e
- [x] Pages principales fonctionnelles (testées par user)
- [ ] Page Notifications - bug Provider à corriger
