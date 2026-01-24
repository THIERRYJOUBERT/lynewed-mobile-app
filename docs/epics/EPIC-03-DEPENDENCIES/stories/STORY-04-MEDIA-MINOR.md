# Story STORY-04: Mise a Jour des Packages Media (Minor)

## Description

Mettre a jour les packages de gestion d'images et videos sans breaking changes.

| Package | Actuel | Cible | Changelog |
|---------|--------|-------|-----------|
| image_picker | 1.2.0 | 1.2.1 | [pub.dev](https://pub.dev/packages/image_picker/changelog) |
| video_player | 2.10.0 | 2.10.1 | [pub.dev](https://pub.dev/packages/video_player/changelog) |

## Criteres d'Acceptance

- [ ] `image_picker` mis a jour de 1.2.0 a 1.2.1
- [ ] `video_player` mis a jour de 2.10.0 a 2.10.1
- [ ] `flutter pub get` reussit sans erreur
- [ ] `flutter analyze --fatal-infos` passe sans warnings
- [ ] App compile sur iOS (`flutter build ios --no-codesign`)
- [ ] App compile sur Android (`flutter build apk --debug`)
- [ ] Selection d'image depuis galerie fonctionne
- [ ] Prise de photo avec camera fonctionne
- [ ] Lecture de videos fonctionne

## Breaking Changes Potentiels

Aucun - Ces mises a jour sont des patch versions.

## Tests Manuels Requis

### Test image_picker (sur device physique)

1. **Selection depuis galerie**
   - Ouvrir le picker d'images
   - Selectionner une image depuis la galerie
   - Verifier qu'elle s'affiche correctement

2. **Prise de photo**
   - Ouvrir la camera via l'app
   - Prendre une photo
   - Verifier qu'elle est capturee correctement

3. **Selection multiple** (si applicable)
   - Selectionner plusieurs images
   - Verifier qu'elles sont toutes recuperees

### Test video_player

1. **Lecture video locale**
   - Lire une video stockee localement

2. **Lecture video distante**
   - Lire une video depuis une URL

3. **Controles**
   - Pause/Play
   - Seek
   - Mute/Unmute

## Rollback

```bash
# Dans pubspec.yaml, revenir a:
image_picker: ^1.0.7
video_player: ^2.9.1

# Puis:
flutter pub get
```

## Estimation

- **Effort**: S (1-2h) - Tests manuels sur device
- **Risque**: Faible

## Notes

- Tests sur device physique obligatoires (simulateur limite pour camera)
- Tester sur iOS ET Android
- Verifier les permissions camera/galerie
