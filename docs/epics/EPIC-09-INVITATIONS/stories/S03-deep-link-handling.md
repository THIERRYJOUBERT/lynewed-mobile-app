# Story S03: Implementer deep link handling (lynewed.app/join/{code})

## Description
En tant que guest, je veux pouvoir ouvrir l'application directement via un lien d'invitation, afin de rejoindre le mariage sans saisir manuellement le code.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the Lynewed app is installed on iOS When the user taps a link "https://lynewed.app/join/ABCD1234" Then the Lynewed app should open And the JoinWedding page should display with code "ABCD1234" pre-filled And validation should start automatically
- [ ] Given the Lynewed app is installed on Android When the user taps a link "https://lynewed.app/join/ABCD1234" Then the Lynewed app should open And the JoinWedding page should display with code "ABCD1234" pre-filled
- [ ] Given the Lynewed app is NOT installed on iOS When the user taps a link "https://lynewed.app/join/ABCD1234" Then the user should be redirected to the App Store And after installation and first launch, the code should be retrieved And the JoinWedding page should pre-fill the code
- [ ] Given the Lynewed app is NOT installed on Android When the user taps a link "https://lynewed.app/join/ABCD1234" Then the user should be redirected to the Play Store And after installation and first launch, the code should be retrieved
- [ ] Given the user opens the app via deep link with an expired code When validation occurs Then an error "Ce code d'invitation a expire" should be displayed And the user should be able to enter a different code
- [ ] Given the user is already logged in as a Guest for wedding A When the user taps a deep link for wedding B Then a message "Vous etes deja connecte a un mariage" should be displayed And the user should have option to logout and join new wedding

## Fichiers Concernes

### A Creer
- `lib/core/navigation/deep_link_handler.dart`
- `lib/core/services/deferred_deep_link_service.dart`

### A Modifier
- `ios/Runner/Runner.entitlements` (Associated Domains)
- `ios/Runner/Info.plist` (URL Schemes)
- `android/app/src/main/AndroidManifest.xml` (intent-filters)
- `lib/core/navigation/app_router.dart` (deep link routing)
- `lib/main.dart` (initialiser deep link listener)

## Notes Techniques

### iOS Configuration

**ios/Runner/Runner.entitlements:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.associated-domains</key>
    <array>
        <string>applinks:lynewed.app</string>
        <string>applinks:www.lynewed.app</string>
    </array>
</dict>
</plist>
```

**ios/Runner/Info.plist (ajouter):**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>lynewed</string>
        </array>
    </dict>
</array>
```

### Android Configuration

**android/app/src/main/AndroidManifest.xml (dans activity):**
```xml
<!-- Deep Links for Wedding Invitations -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="lynewed.app"
        android:pathPrefix="/join" />
</intent-filter>
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="www.lynewed.app"
        android:pathPrefix="/join" />
</intent-filter>
<!-- Custom scheme fallback -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="lynewed" android:host="join" />
</intent-filter>
```

### Deep Link Handler

```dart
// lib/core/navigation/deep_link_handler.dart
import 'package:app_links/app_links.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();
  final GoRouter _router;

  DeepLinkHandler(this._router);

  Future<void> init() async {
    // Get initial link (app was closed)
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    // Listen for links while app is running
    _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    if (uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'join') {
      final code = uri.pathSegments[1];
      if (code.length == 8) {
        _router.go('/join-wedding?code=$code');
      }
    }
  }
}
```

### Deferred Deep Link (pour app non installee)

```dart
// lib/core/services/deferred_deep_link_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class DeferredDeepLinkService {
  static const _key = 'deferred_invite_code';

  Future<void> saveCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }

  Future<String?> retrieveAndClearCode() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) {
      await prefs.remove(_key);
    }
    return code;
  }
}
```

### Packages requis

```yaml
# pubspec.yaml
dependencies:
  app_links: ^6.0.0  # Universal links / App links handling
```

## Definition of Done

- [ ] Criteres valides
- [ ] Tests unitaires (DeepLinkHandler, parsing URL)
- [ ] Tests integration (flow deep link vers JoinWedding)
- [ ] `flutter analyze --fatal-infos` passe
- [ ] Configuration serveur validee (AASA + assetlinks.json - voir notes)
- [ ] Teste sur device physique iOS
- [ ] Teste sur device physique Android

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (configuration serveur requise, tests sur devices physiques)

## Dependances

- S02 (JoinWedding page - destination du deep link)

## Stories Dependantes

- S04 (guest account creation - flow complet avec deep link)

## Notes Server-Side (a deployer separement)

**IMPORTANT**: Les fichiers suivants doivent etre deployes sur lynewed.app AVANT de tester les deep links.

### iOS: apple-app-site-association
URL: `https://lynewed.app/.well-known/apple-app-site-association`
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.lynewed.app",
        "paths": ["/join/*"]
      }
    ]
  }
}
```

### Android: assetlinks.json
URL: `https://lynewed.app/.well-known/assetlinks.json`
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.lynewed.app",
    "sha256_cert_fingerprints": ["SHA256_FINGERPRINT"]
  }
}]
```

> Ces fichiers sont geres par l'equipe backend/infra, pas par cette story.
