# Story STORY-03: Mise a Jour des Packages UI (Minor)

## Description

Mettre a jour les packages UI/UX sans breaking changes pour beneficier des ameliorations et bug fixes.

| Package | Actuel | Cible | Changelog |
|---------|--------|-------|-----------|
| flutter_animate | 4.5.0 | 4.5.2 | [pub.dev](https://pub.dev/packages/flutter_animate/changelog) |
| percent_indicator | 4.2.2 | 4.2.5 | [pub.dev](https://pub.dev/packages/percent_indicator/changelog) |
| aligned_dialog | 0.0.6 | 0.0.7 | [pub.dev](https://pub.dev/packages/aligned_dialog/changelog) |
| page_transition | 2.1.0 | 2.2.1 | [pub.dev](https://pub.dev/packages/page_transition/changelog) |

## Criteres d'Acceptance

- [ ] Tous les packages listes mis a jour
- [ ] `flutter pub get` reussit sans erreur
- [ ] `flutter analyze --fatal-infos` passe sans warnings
- [ ] App compile sur iOS (`flutter build ios --no-codesign`)
- [ ] App compile sur Android (`flutter build apk --debug`)
- [ ] Animations fonctionnent correctement (flutter_animate)
- [ ] Indicateurs de progression s'affichent (percent_indicator)
- [ ] Dialogs s'affichent correctement (aligned_dialog)
- [ ] Transitions de pages sont fluides (page_transition)

## Breaking Changes Potentiels

### page_transition 2.2.1
- Possibles nouveaux parametres optionnels
- Verifier les transitions custom existantes

### Autres packages
- Aucun breaking change attendu

## Tests Manuels Requis

1. **Test Animations**
   - Naviguer dans l'app
   - Verifier que les animations de liste, fade-in, etc. fonctionnent

2. **Test Progress Indicators**
   - Verifier les barres de progression (onboarding, upload, etc.)
   - Verifier les indicateurs circulaires

3. **Test Dialogs**
   - Ouvrir differents dialogs dans l'app
   - Verifier positionnement et comportement

4. **Test Page Transitions**
   - Naviguer entre plusieurs ecrans
   - Verifier que les transitions sont fluides et correctes

## Rollback

```bash
# Dans pubspec.yaml, revenir a:
flutter_animate: 4.5.0
percent_indicator: 4.2.2
aligned_dialog: 0.0.6
page_transition: 2.1.0

# Puis:
flutter pub get
```

## Estimation

- **Effort**: XS (< 1h)
- **Risque**: Faible

## Notes

- Ces packages sont principalement visuels
- Regressions faciles a detecter
- Aucune logique metier impactee
