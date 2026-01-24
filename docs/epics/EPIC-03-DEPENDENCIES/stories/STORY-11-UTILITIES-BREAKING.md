# Story STORY-11: Mise a Jour Utilities avec Breaking Changes

## Description

Mettre a jour les packages utilitaires qui ont des breaking changes significatifs.

| Package | Actuel | Cible | Saut | Changelog |
|---------|--------|-------|------|-----------|
| device_info_plus | 11.5.0 | 12.3.0 | 11 -> 12 | [pub.dev](https://pub.dev/packages/device_info_plus/changelog) |
| flutter_dotenv | 5.2.1 | 6.0.0 | 5 -> 6 | [pub.dev](https://pub.dev/packages/flutter_dotenv/changelog) |
| json_path | 0.7.2 | 0.9.0 | 0.7 -> 0.9 | [pub.dev](https://pub.dev/packages/json_path/changelog) |
| file_picker | 8.3.7 | 10.3.8 | 8 -> 10 | [pub.dev](https://pub.dev/packages/file_picker/changelog) |

## Criteres d'Acceptance

- [ ] `device_info_plus` mis a jour de 11.x a 12.x
- [ ] `flutter_dotenv` mis a jour de 5.x a 6.x
- [ ] `json_path` mis a jour de 0.7.x a 0.9.x
- [ ] `file_picker` mis a jour de 8.x a 10.x
- [ ] `flutter pub get` reussit sans erreur
- [ ] `flutter analyze --fatal-infos` passe sans warnings
- [ ] App compile sur iOS (`flutter build ios --no-codesign`)
- [ ] App compile sur Android (`flutter build apk --debug`)
- [ ] Info device recuperables (device_info_plus)
- [ ] Variables d'environnement chargees (.env)
- [ ] Selection de fichiers fonctionne
- [ ] Parsing JSON avec paths fonctionne (si utilise)

## Breaking Changes Potentiels

### device_info_plus 12.x (MAJEUR)

Changements possibles:
- Nouvelle API pour recuperer les infos device
- Nouvelles proprietes disponibles
- Proprietes renommees/supprimees
- Changements dans `DeviceInfoPlugin`

### flutter_dotenv 6.x (MAJEUR)

Changements possibles:
- Nouvelle methode de chargement
- Changement dans `dotenv.env`
- Nouvelle gestion des fichiers .env multiples

### json_path 0.9.x

Changements possibles:
- API de query modifiee
- Nouveau format de resultats
- Comportement different sur edge cases

### file_picker 10.x (MAJEUR - saut de 2 versions)

**ATTENTION**: Saut de version important (8 -> 10)

Changements possibles:
- Nouvelle API de selection
- Changements dans `FilePickerResult`
- Nouvelles options de plateforme
- Gestion differente des permissions

## Tests Manuels Requis

### 1. Test device_info_plus

```
a) iOS
   - Recuperer les infos device iOS
   - Verifier: model, systemVersion, name, etc.

b) Android
   - Recuperer les infos device Android
   - Verifier: model, version, brand, etc.
```

### 2. Test flutter_dotenv

```
a) Chargement
   - Demarrer l'app
   - Verifier que les variables .env sont chargees

b) Acces aux variables
   - Acceder a dotenv.env['SUPABASE_URL']
   - Verifier les valeurs

c) Variables manquantes
   - Verifier le comportement si variable manquante
```

### 3. Test file_picker

```
a) Selection fichier unique
   - Ouvrir le picker
   - Selectionner un fichier
   - Verifier qu'il est recupere

b) Selection multiple
   - Ouvrir le picker en mode multiple
   - Selectionner plusieurs fichiers
   - Verifier qu'ils sont tous recuperes

c) Types de fichiers
   - Images
   - Documents
   - Tous fichiers

d) Annulation
   - Ouvrir le picker
   - Annuler
   - Verifier le comportement graceful
```

### 4. Test json_path (si utilise)

```
a) Queries basiques
   - Query simple: $.data
   - Verifier le resultat

b) Queries complexes
   - Query avec filtres
   - Query avec arrays
```

## Migration Guide

### device_info_plus

```dart
// Ancien code possible (11.x)
final deviceInfo = DeviceInfoPlugin();
final iosInfo = await deviceInfo.iosInfo;
print(iosInfo.model);

// Nouveau code possible (12.x) - Verifier changelog
final deviceInfo = DeviceInfoPlugin();
final iosInfo = await deviceInfo.iosInfo;
print(iosInfo.model);  // Probablement similaire, verifier proprietes
```

### flutter_dotenv

```dart
// Ancien code possible (5.x)
await dotenv.load(fileName: '.env');
final value = dotenv.env['MY_VAR'];

// Nouveau code possible (6.x) - Verifier changelog
await dotenv.load(fileName: '.env');
final value = dotenv.env['MY_VAR'];  // Verifier si API changee
```

### file_picker

```dart
// Ancien code possible (8.x)
FilePickerResult? result = await FilePicker.platform.pickFiles();
if (result != null) {
  File file = File(result.files.single.path!);
}

// Nouveau code possible (10.x) - Verifier changelog
FilePickerResult? result = await FilePicker.platform.pickFiles();
if (result != null) {
  // Potentiellement nouvelle API pour acceder aux fichiers
  // Verifier result.files structure
}
```

## Recherche d'Usages

Avant la mise a jour, identifier tous les usages:

```bash
# device_info_plus
grep -r "DeviceInfoPlugin\|deviceInfo" lib/

# flutter_dotenv
grep -r "dotenv\|DotEnv" lib/

# file_picker
grep -r "FilePicker\|pickFiles" lib/

# json_path
grep -r "JsonPath\|jsonPath" lib/
```

## Rollback

```bash
# Dans pubspec.yaml, revenir a:
device_info_plus: 11.5.0
flutter_dotenv: ^5.1.0
json_path: 0.7.2
file_picker: ^8.0.0

# Puis:
flutter pub get
```

## Estimation

- **Effort**: M (4-6h) - Migration code + tests
- **Risque**: Moyen (utilities critiques)

## Notes

### Points Critiques

1. **flutter_dotenv**: Utilise au demarrage de l'app - tester le cold start
2. **file_picker**: Permissions iOS/Android a verifier
3. **device_info_plus**: Utilise potentiellement pour analytics/debugging

### Fichiers Potentiellement Impactes

- `main.dart` (dotenv loading)
- Services d'upload
- Analytics/tracking services
- Device identification logic

### Ordre de Migration Recommande

1. `flutter_dotenv` (critique pour le demarrage)
2. `device_info_plus`
3. `file_picker`
4. `json_path` (si peu utilise)
