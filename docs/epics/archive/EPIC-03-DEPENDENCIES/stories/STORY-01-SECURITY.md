# Story STORY-01: Mise a Jour des Packages de Securite

## Description

Mettre a jour les packages lies a la securite et au stockage securise pour beneficier des dernieres corrections de securite.

| Package | Actuel | Cible | Changelog |
|---------|--------|-------|-----------|
| crypto | 3.0.6 | 3.0.7 | [pub.dev](https://pub.dev/packages/crypto/changelog) |
| flutter_secure_storage | 10.0.0-beta.4 | 10.0.0 | [pub.dev](https://pub.dev/packages/flutter_secure_storage/changelog) |

## Criteres d'Acceptance

- [ ] `crypto` mis a jour de 3.0.6 a 3.0.7
- [ ] `flutter_secure_storage` mis a jour de 10.0.0-beta.4 a 10.0.0 (version stable)
- [ ] `flutter pub get` reussit sans erreur
- [ ] `flutter analyze --fatal-infos` passe sans warnings
- [ ] App compile sur iOS (`flutter build ios --no-codesign`)
- [ ] App compile sur Android (`flutter build apk --debug`)
- [ ] Login/Logout fonctionne (stockage token)
- [ ] Donnees sensibles accessibles apres redemarrage app

## Breaking Changes Potentiels

### crypto 3.0.7
- Aucun breaking change - bug fixes uniquement

### flutter_secure_storage 10.0.0
- Passage de beta a stable
- Verifier que les options de configuration restent compatibles
- iOS: Verifier keychain access
- Android: Verifier encrypted shared preferences

## Tests Manuels Requis

1. **Test Login**
   - Se deconnecter
   - Se reconnecter
   - Verifier que le token est stocke

2. **Test Persistence**
   - Fermer completement l'app
   - Rouvrir
   - Verifier que l'utilisateur reste connecte

3. **Test Clear Data**
   - Se deconnecter
   - Verifier que les donnees securisees sont effacees

## Rollback

```bash
# Dans pubspec.yaml, revenir a:
crypto: 3.0.6
flutter_secure_storage: 10.0.0-beta.4

# Puis:
flutter pub get
```

## Estimation

- **Effort**: XS (< 1h)
- **Risque**: Faible

## Notes

- flutter_secure_storage 10.0.0 est la version stable de la beta actuellement utilisee
- La migration devrait etre transparente
