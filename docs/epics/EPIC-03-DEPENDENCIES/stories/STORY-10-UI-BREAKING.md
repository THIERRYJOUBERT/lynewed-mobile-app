# Story STORY-10: Mise a Jour UI avec Breaking Changes

## Description

Mettre a jour les packages UI qui ont des breaking changes entre les versions.

| Package | Actuel | Cible | Saut | Changelog |
|---------|--------|-------|------|-----------|
| google_fonts | 6.1.0 | 8.0.0 | 6 -> 8 | [pub.dev](https://pub.dev/packages/google_fonts/changelog) |
| font_awesome_flutter | 10.7.0 | 10.12.0 | Minor | [pub.dev](https://pub.dev/packages/font_awesome_flutter/changelog) |
| smooth_page_indicator | 1.1.0 | 2.0.1 | 1 -> 2 | [pub.dev](https://pub.dev/packages/smooth_page_indicator/changelog) |

## Criteres d'Acceptance

- [ ] `google_fonts` mis a jour de 6.x a 8.x
- [ ] `font_awesome_flutter` mis a jour de 10.7.0 a 10.12.0
- [ ] `smooth_page_indicator` mis a jour de 1.x a 2.x
- [ ] `flutter pub get` reussit sans erreur
- [ ] `flutter analyze --fatal-infos` passe sans warnings
- [ ] App compile sur iOS (`flutter build ios --no-codesign`)
- [ ] App compile sur Android (`flutter build apk --debug`)
- [ ] Toutes les polices s'affichent correctement
- [ ] Tous les icones FontAwesome s'affichent
- [ ] Page indicators (onboarding, carousels) fonctionnent

## Breaking Changes Potentiels

### google_fonts 8.0.0 (MAJEUR)

**Changements de 6.x a 8.x**:
- Possibles changements dans l'API de chargement des fonts
- Nouvelles polices disponibles
- Potentiel changement de cache
- Verifier `GoogleFonts.config` si utilise

### font_awesome_flutter 10.12.0

- Nouvelles icones ajoutees
- Possibles icones renommees/supprimees
- Verifier les icones utilisees dans l'app

### smooth_page_indicator 2.0.1 (MAJEUR)

- **API significativement changee**
- Nouveaux types d'indicateurs
- Proprietes renommees possibles

## Tests Manuels Requis

### 1. Test Google Fonts

```
a) Polices custom
   - Verifier toutes les polices Google utilisees
   - Texte normal
   - Texte bold
   - Texte italic

b) Fallback
   - Mode avion
   - Verifier que les polices en cache fonctionnent
   - Verifier le fallback si police non disponible

c) Differents ecrans
   - Home
   - Profile
   - Settings
   - Details
   - Verifier la consistance des polices
```

### 2. Test FontAwesome

```
a) Icones utilisees
   - Lister tous les icones FA utilises dans l'app
   - Verifier qu'ils s'affichent tous

b) Differents styles
   - Solid icons
   - Regular icons
   - Brands icons (si utilises)

c) Tailles
   - Petites icones
   - Grandes icones
```

### 3. Test Smooth Page Indicator

```
a) Onboarding
   - Parcourir toutes les pages d'onboarding
   - Verifier l'animation des dots
   - Verifier le style des dots

b) Carousels
   - Parcourir les carousels (si utilises)
   - Verifier les indicateurs

c) Custom styles
   - Verifier les indicateurs personnalises
```

## Migration Guide

### google_fonts

```dart
// Ancien code possible (6.x)
Text(
  'Hello',
  style: GoogleFonts.lato(fontSize: 16),
)

// Nouveau code possible (8.x) - Verifier changelog
Text(
  'Hello',
  style: GoogleFonts.lato(fontSize: 16),  // Probablement identique
)

// Configuration possible (si changee)
// Ancien
GoogleFonts.config.allowRuntimeFetching = false;
// Nouveau (verifier)
// ...
```

### smooth_page_indicator

```dart
// Ancien code possible (1.x)
SmoothPageIndicator(
  controller: pageController,
  count: 4,
  effect: WormEffect(),
)

// Nouveau code possible (2.x) - VERIFIER CHANGELOG
SmoothPageIndicator(
  controller: pageController,
  count: 4,
  effect: WormEffect(
    // Nouvelles proprietes possibles
  ),
)
```

### font_awesome_flutter

```dart
// Verifier les icones renommees
// Exemple possible:
// Ancien
FaIcon(FontAwesomeIcons.someIcon)
// Nouveau
FaIcon(FontAwesomeIcons.someIconRenamed)  // Si renomme
```

## Recherche d'Icones a Verifier

Avant la mise a jour, lister tous les usages de FontAwesome:

```bash
# Rechercher dans le code
grep -r "FontAwesomeIcons\." lib/
grep -r "FaIcon" lib/
```

## Rollback

```bash
# Dans pubspec.yaml, revenir a:
google_fonts: 6.1.0
font_awesome_flutter: 10.7.0
smooth_page_indicator: 1.1.0

# Puis:
flutter pub get
```

## Estimation

- **Effort**: M (4-6h) - Migration UI + verification visuelle
- **Risque**: Moyen (visible mais non critique)

## Notes

### Points d'Attention

1. **Google Fonts**: Les polices sont telechargees au runtime par defaut
2. **Cache**: Verifier le comportement de cache des polices
3. **Taille du bundle**: google_fonts 8.x peut avoir un impact sur la taille

### Verification Visuelle

Faire une verification visuelle complete de l'app:
- Parcourir tous les ecrans principaux
- Verifier la consistance typographique
- Verifier les icones dans les boutons, menus, etc.

### Screenshots

Avant la mise a jour, prendre des screenshots des ecrans cles pour comparaison apres.
