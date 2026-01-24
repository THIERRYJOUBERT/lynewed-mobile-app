# Story STORY-08: Mise a Jour Google Maps

## Description

Mettre a jour les packages Google Maps et Places.

| Package | Actuel | Cible | Changelog |
|---------|--------|-------|-----------|
| google_maps_flutter | 2.13.1 | 2.14.0 | [pub.dev](https://pub.dev/packages/google_maps_flutter/changelog) |
| flutter_google_places_sdk | 0.4.2+1 | 0.4.3 | [pub.dev](https://pub.dev/packages/flutter_google_places_sdk/changelog) |

## Criteres d'Acceptance

- [ ] `google_maps_flutter` mis a jour de 2.13.1 a 2.14.0
- [ ] `flutter_google_places_sdk` mis a jour de 0.4.2+1 a 0.4.3
- [ ] `flutter pub get` reussit sans erreur
- [ ] `flutter analyze --fatal-infos` passe sans warnings
- [ ] App compile sur iOS (`flutter build ios --no-codesign`)
- [ ] App compile sur Android (`flutter build apk --debug`)
- [ ] Carte s'affiche correctement
- [ ] Markers s'affichent
- [ ] Interactions carte (zoom, pan, tap) fonctionnent
- [ ] Recherche de lieux fonctionne (Places API)
- [ ] Autocomplete fonctionne
- [ ] Geolocalisation utilisateur fonctionne

## Breaking Changes Potentiels

### google_maps_flutter 2.14.0
- Minor version: possibles nouvelles fonctionnalites
- Verifier les changements d'API des markers/polylines

### flutter_google_places_sdk 0.4.3
- Patch version: bug fixes principalement
- Verifier la compatibilite avec Google Places API

## Tests Manuels Requis

### 1. Test Carte (google_maps_flutter)

```
a) Affichage
   - Ouvrir un ecran avec une carte
   - Verifier que la carte se charge
   - Verifier que les tuiles s'affichent correctement

b) Interactions
   - Zoomer (pinch)
   - Dezoomer
   - Pan (glisser)
   - Tap sur la carte

c) Markers
   - Verifier que les markers s'affichent
   - Tap sur un marker
   - Verifier le comportement (info window, navigation, etc.)

d) Position utilisateur
   - Activer la localisation
   - Verifier que le point bleu s'affiche
   - Verifier que la carte se centre sur l'utilisateur
```

### 2. Test Places (flutter_google_places_sdk)

```
a) Recherche de lieu
   - Ouvrir la recherche de lieu
   - Taper un nom de lieu
   - Verifier que les suggestions apparaissent

b) Autocomplete
   - Taper quelques lettres
   - Verifier que l'autocomplete propose des resultats

c) Selection de lieu
   - Selectionner un lieu dans les suggestions
   - Verifier que les coordonnees sont recuperees
   - Verifier que la carte se centre sur le lieu
```

### 3. Test Integration

```
a) Flow complet
   - Rechercher un lieu
   - Le selectionner
   - Verifier l'affichage sur la carte
   - Verifier que le marker est place correctement
```

## Configuration Requise

### API Keys

Verifier que les API keys sont configurees:

**iOS** (`ios/Runner/AppDelegate.swift`):
```swift
GMSServices.provideAPIKey("YOUR_API_KEY")
GMSPlacesClient.provideAPIKey("YOUR_API_KEY")
```

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
```

### APIs a activer dans Google Cloud Console

- Maps SDK for iOS
- Maps SDK for Android
- Places API
- Geocoding API (si utilise)

## Rollback

```bash
# Dans pubspec.yaml, revenir a:
google_maps_flutter: ^2.12.2
flutter_google_places_sdk: ^0.4.2+1

# Puis:
flutter pub get
cd ios && pod install && cd ..
```

## Estimation

- **Effort**: S (2-3h) - Tests sur carte et places
- **Risque**: Moyen (fonctionnalite visible importante)

## Notes

### Points d'Attention

1. **iOS Simulator**: La carte fonctionne mais peut etre lente
2. **Android Emulator**: Necessite Google Play Services
3. **API Quotas**: Verifier les quotas Google Maps/Places
4. **Billing**: S'assurer que le billing est active sur Google Cloud

### Debugging

Si la carte ne s'affiche pas:

```dart
// Verifier les logs pour les erreurs d'API key
// iOS: Xcode console
// Android: logcat

// Erreurs communes:
// - "API key not found" -> Verifier AppDelegate/Manifest
// - "API not enabled" -> Activer l'API dans Cloud Console
// - "Billing not enabled" -> Activer le billing
```

### Mise a Jour Native SDK

Si necessaire, mettre a jour les SDK natifs:

**iOS** (`ios/Podfile`):
```ruby
# Verifier la version minimale de GoogleMaps
pod 'GoogleMaps', '~> 8.0'
```

**Android** (`android/app/build.gradle`):
```groovy
// Verifier la version play-services-maps
implementation 'com.google.android.gms:play-services-maps:18.2.0'
```
