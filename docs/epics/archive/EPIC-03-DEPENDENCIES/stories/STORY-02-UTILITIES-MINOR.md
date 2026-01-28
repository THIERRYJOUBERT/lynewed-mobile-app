# Story STORY-02: Mise a Jour des Utilities (Minor)

## Description

Mettre a jour les packages utilitaires sans breaking changes pour beneficier des bug fixes et ameliorations.

| Package | Actuel | Cible | Changelog |
|---------|--------|-------|-----------|
| path_provider | 2.1.4 | 2.1.5 | [pub.dev](https://pub.dev/packages/path_provider/changelog) |
| url_launcher | 6.3.1 | 6.3.2 | [pub.dev](https://pub.dev/packages/url_launcher/changelog) |
| webview_flutter | 4.13.0 | 4.13.1 | [pub.dev](https://pub.dev/packages/webview_flutter/changelog) |
| shared_preferences | 2.5.3 | 2.5.4 | [pub.dev](https://pub.dev/packages/shared_preferences/changelog) |
| permission_handler | 12.0.0+1 | 12.0.1 | [pub.dev](https://pub.dev/packages/permission_handler/changelog) |
| provider | 6.1.5 | 6.1.5+1 | [pub.dev](https://pub.dev/packages/provider/changelog) |
| easy_debounce | 2.0.1 | 2.0.3 | [pub.dev](https://pub.dev/packages/easy_debounce/changelog) |
| uuid | 4.5.1 | 4.5.2 | [pub.dev](https://pub.dev/packages/uuid/changelog) |

## Criteres d'Acceptance

- [ ] Tous les packages listes mis a jour
- [ ] `flutter pub get` reussit sans erreur
- [ ] `flutter analyze --fatal-infos` passe sans warnings
- [ ] App compile sur iOS (`flutter build ios --no-codesign`)
- [ ] App compile sur Android (`flutter build apk --debug`)
- [ ] Navigation dans l'app fonctionne (path_provider)
- [ ] Liens externes s'ouvrent (url_launcher)
- [ ] WebViews fonctionnent
- [ ] Preferences utilisateur persistent (shared_preferences)
- [ ] Demandes de permissions fonctionnent (camera, galerie, localisation)

## Breaking Changes Potentiels

Aucun - Toutes ces mises a jour sont des patch versions avec bug fixes uniquement.

## Tests Manuels Requis

1. **Test path_provider**
   - Telecharger/sauvegarder une image
   - Verifier que le cache fonctionne

2. **Test url_launcher**
   - Cliquer sur un lien externe dans l'app
   - Verifier qu'il s'ouvre dans le navigateur

3. **Test webview_flutter**
   - Ouvrir une page web dans l'app (si applicable)

4. **Test shared_preferences**
   - Modifier un parametre utilisateur
   - Fermer et rouvrir l'app
   - Verifier que le parametre est conserve

5. **Test permission_handler**
   - Acceder a la camera
   - Acceder a la galerie
   - Acceder a la localisation

## Rollback

```bash
# Dans pubspec.yaml, revenir a:
path_provider: 2.1.4
url_launcher: 6.3.1
webview_flutter: 4.13.0
shared_preferences: 2.5.3
permission_handler: 12.0.0+1
provider: 6.1.5
easy_debounce: 2.0.1
uuid: ^4.5.1

# Puis:
flutter pub get
```

## Estimation

- **Effort**: S (1-2h)
- **Risque**: Faible

## Notes

- Ces packages sont tres stables et bien maintenus
- Mise a jour groupee car risque minimal
- uuid a un dependency_override qui devra etre verifie
