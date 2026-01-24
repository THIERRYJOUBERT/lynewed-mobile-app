# Story S04: Navigation System Refactoring

## Description

En tant que developpeur, je veux refactorer le systeme de navigation FlutterFlow vers un systeme Clean Architecture afin de permettre une migration incrementale des pages sans casser la navigation existante.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `lib/flutter_flow/nav/` When j'analyse la navigation Then je comprends tous les patterns utilises (go_router)

- [ ] Given le systeme de navigation When je cree des wrappers Then les nouvelles pages Clean peuvent coexister avec les pages FlutterFlow

- [ ] Given une page migree en Clean Architecture When je navigue vers elle Then la navigation fonctionne identiquement

- [ ] Given les routes existantes When je cree un index des routes Then `lib/core/navigation/routes.dart` liste toutes les routes

- [ ] Given le deep linking When je teste les liens Then ils fonctionnent toujours correctement

## Fichiers Concernes

### A Analyser
- `lib/flutter_flow/nav/nav.dart` - Configuration go_router
- `lib/flutter_flow/nav/serialization_util.dart` - Serialisation params
- `lib/index.dart` - Index des pages

### A Creer
- `lib/core/navigation/navigation.dart` - Barrel export
- `lib/core/navigation/routes.dart` - Constantes de routes
- `lib/core/navigation/router.dart` - Configuration router (si necessaire)
- `lib/core/navigation/route_guards.dart` - Guards d'authentification

### A Modifier
- `lib/flutter_flow/nav/nav.dart` - Ajouter routes vers features/

## Notes Techniques

### Strategie de Migration
1. **Phase 1** : Garder go_router existant
2. **Phase 2** : Ajouter routes vers `lib/features/`
3. **Phase 3** : Migrer progressivement les pages
4. **Phase 4** : Supprimer les routes legacy

### Pattern Wrapper
Pour maintenir la compatibilite :
```dart
// Wrapper dans lib/features/chat/presentation/pages/
class ChatDetailsPageWrapper extends StatelessWidget {
  // Parametres compatibles FlutterFlow
  final String? roomId;
  final String? roomType;

  const ChatDetailsPageWrapper({
    this.roomId,
    this.roomType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Convertir params legacy vers Clean
    return ChatDetailsPage(
      roomId: roomId ?? '',
      roomType: ChatRoomType.fromString(roomType),
    );
  }
}
```

### Routes Constants
```dart
abstract class AppRoutes {
  // Auth
  static const signIn = '/signIn';
  static const signUp = '/signUp';
  static const forgotPassword = '/forgotPassword';

  // Chat
  static const messages = '/messages';
  static const chatDetails = '/chatDetails';

  // Map
  static const map = '/map';

  // Wedding
  static const myWedding = '/myWedding';

  // ... etc
}
```

### Deep Links
Verifier que les deep links suivants fonctionnent :
- `lynewed://chat/{roomId}`
- `lynewed://profile/{profileId}`
- `lynewed://wedding/{weddingId}`

## Definition of Done

- [ ] Audit complet de la navigation realise
- [ ] Index des routes cree
- [ ] Pattern wrapper documente
- [ ] Au moins 1 page migree avec wrapper fonctionnel
- [ ] Deep links testes
- [ ] Documentation des routes
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Eleve (navigation = critique)

## Dependances

- S01 : Setup infrastructure
- S02 : FlutterFlow utilities
- S03 : Design system

## Stories Dependantes

- Toutes les stories de migration de pages
