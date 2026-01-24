# Story STORY-09: Mise a Jour Navigation (Versions Majeures)

## Description

Mettre a jour go_router et app_links vers leurs versions majeures. **ATTENTION**: Sauts de version majeurs importants - migration significative attendue.

| Package | Actuel | Cible | Saut | Changelog |
|---------|--------|-------|------|-----------|
| go_router | 12.1.3 | 17.0.1 | 12 -> 17 | [pub.dev](https://pub.dev/packages/go_router/changelog) |
| app_links | 6.3.2 | 7.0.0 | 6 -> 7 | [pub.dev](https://pub.dev/packages/app_links/changelog) |

## Criteres d'Acceptance

- [ ] `go_router` mis a jour de 12.x a 17.x
- [ ] `app_links` mis a jour de 6.x a 7.x
- [ ] `flutter pub get` reussit sans erreur
- [ ] `flutter analyze --fatal-infos` passe sans warnings
- [ ] App compile sur iOS (`flutter build ios --no-codesign`)
- [ ] App compile sur Android (`flutter build apk --debug`)
- [ ] Navigation entre tous les ecrans fonctionne
- [ ] Deep links fonctionnent (iOS Universal Links + Android App Links)
- [ ] Bottom navigation fonctionne
- [ ] Back button fonctionne (Android)
- [ ] Swipe back fonctionne (iOS)
- [ ] Routes protegees fonctionnent (redirect si non connecte)
- [ ] Parametres de route passes correctement

## Breaking Changes Potentiels

### go_router 12.x -> 17.x (MAJEUR)

**LIRE IMPERATIVEMENT LES CHANGELOGS DE CHAQUE VERSION MAJEURE**:
- 12.x -> 13.x
- 13.x -> 14.x
- 14.x -> 15.x
- 15.x -> 16.x
- 16.x -> 17.x

Changements probables:
- **Route definition syntax**: Nouvelle syntaxe possible
- **GoRouterState**: API modifiee
- **Redirect logic**: Changements dans la logique de redirection
- **ShellRoute**: Modifications possibles
- **Query parameters**: Nouveau handling possible
- **Error handling**: Nouvelle gestion des erreurs 404

### app_links 7.x (MAJEUR)

Changements probables:
- **Initialization**: Nouvelle methode d'initialisation
- **Stream handling**: Changements dans le stream de liens
- **Platform specifics**: iOS/Android handling modifie

## Pre-requis

**OBLIGATOIRE**: Lire tous les changelogs avant de commencer:

1. [go_router 13.0.0](https://pub.dev/packages/go_router/changelog#1300)
2. [go_router 14.0.0](https://pub.dev/packages/go_router/changelog#1400)
3. [go_router 15.0.0](https://pub.dev/packages/go_router/changelog#1500)
4. [go_router 16.0.0](https://pub.dev/packages/go_router/changelog#1600)
5. [go_router 17.0.0](https://pub.dev/packages/go_router/changelog#1700)
6. [app_links 7.0.0](https://pub.dev/packages/app_links/changelog)

## Tests Manuels Requis

### 1. Navigation Basique

```
a) Navigation push
   - Aller sur Home
   - Naviguer vers un detail
   - Verifier l'animation de transition

b) Navigation pop
   - Etre sur un ecran detail
   - Appuyer sur back
   - Verifier le retour

c) Back button Android
   - Naviguer dans plusieurs ecrans
   - Appuyer sur back hardware
   - Verifier le comportement

d) Swipe back iOS
   - Naviguer dans un ecran
   - Swipe depuis le bord gauche
   - Verifier le retour
```

### 2. Routes Proteges

```
a) Utilisateur non connecte
   - Se deconnecter
   - Essayer d'acceder a une route protegee
   - Verifier la redirection vers login

b) Utilisateur connecte
   - Se connecter
   - Acceder a une route protegee
   - Verifier l'acces
```

### 3. Deep Links

```
a) iOS Universal Links
   - Fermer l'app
   - Ouvrir un lien universel (ex: lynewed://wedding/123)
   - Verifier que l'app ouvre le bon ecran

b) Android App Links
   - Meme test sur Android

c) App en foreground
   - App ouverte
   - Cliquer sur un deep link depuis une autre app
   - Verifier la navigation

d) App terminee
   - Fermer completement l'app
   - Cliquer sur un deep link
   - Verifier que l'app s'ouvre sur le bon ecran
```

### 4. Bottom Navigation (ShellRoute)

```
a) Tabs
   - Cliquer sur chaque tab
   - Verifier que le bon ecran s'affiche

b) State preservation
   - Aller sur Tab 1, scroller
   - Aller sur Tab 2
   - Revenir sur Tab 1
   - Verifier que le scroll est preserve (ou non selon le comportement voulu)
```

### 5. Parametres

```
a) Path parameters
   - Naviguer vers /wedding/123
   - Verifier que l'ID est recupere

b) Query parameters
   - Naviguer vers /search?query=test
   - Verifier que le query est recupere

c) Extra data
   - Passer des donnees via extra
   - Verifier qu'elles sont recues
```

## Migration Guide

### Syntaxe Routes (exemple)

```dart
// Ancien code possible (go_router 12.x)
GoRoute(
  path: '/wedding/:id',
  builder: (context, state) {
    final id = state.params['id']!;
    return WeddingScreen(id: id);
  },
)

// Nouveau code possible (go_router 17.x)
GoRoute(
  path: '/wedding/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;  // params -> pathParameters
    return WeddingScreen(id: id);
  },
)
```

### Redirect (exemple)

```dart
// Ancien code possible
redirect: (context, state) {
  final isLoggedIn = authService.isLoggedIn;
  if (!isLoggedIn) return '/login';
  return null;
}

// Nouveau code possible (verifier changelog)
redirect: (context, state) async {  // Peut etre async maintenant
  final isLoggedIn = authService.isLoggedIn;
  if (!isLoggedIn) return '/login';
  return null;
}
```

### App Links (exemple)

```dart
// Ancien code possible (app_links 6.x)
final appLinks = AppLinks();
appLinks.uriLinkStream.listen((Uri uri) {
  // Handle link
});

// Nouveau code possible (app_links 7.x)
final appLinks = AppLinks();
appLinks.uriLinkStream.listen((Uri uri) {
  // Potentiellement nouvelle API
});
```

## Rollback

```bash
# Dans pubspec.yaml, revenir a:
go_router: 12.1.3
app_links: 6.3.2

# Puis:
flutter pub get
```

## Estimation

- **Effort**: XL (1-2 jours) - Migration significative
- **Risque**: Haut (navigation = coeur de l'app)

## Notes

### Strategie de Migration

1. **Option A**: Migration incrementale version par version
   - 12 -> 13 -> 14 -> 15 -> 16 -> 17
   - Plus sur mais plus long

2. **Option B**: Migration directe 12 -> 17
   - Plus rapide mais potentiellement plus d'erreurs a corriger d'un coup

**Recommandation**: Option B avec lecture approfondie des changelogs avant.

### Points Critiques

1. **ShellRoute**: Si utilise pour bottom nav, verifier attentivement
2. **Nested routes**: Verifier le comportement des routes imbriquees
3. **Typed routes**: go_router 17 supporte mieux les typed routes
4. **Observers**: Verifier les observers de navigation (analytics, etc.)

### Fichiers Impactes Potentiels

- `lib/app/router.dart` ou equivalent
- Tous les fichiers avec `context.go()`, `context.push()`, etc.
- Configuration deep links iOS/Android

### Tests Automatises

Si des tests de navigation existent:
```bash
flutter test test/navigation/
```

Ils devront probablement etre adaptes.
