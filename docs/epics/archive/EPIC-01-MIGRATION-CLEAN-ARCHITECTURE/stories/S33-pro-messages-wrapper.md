# Story S33: Pro - Messages Page Wrapper

## Description

En tant que developpeur, je veux creer un wrapper pour la page Messages Pro afin d'integrer le module Chat Clean Architecture.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `MessagesProWidget` When je cree un wrapper Then il utilise le module Chat

- [ ] Given la navigation existante When je la maintiens Then les routes fonctionnent

## Fichiers Concernes

### Pages Legacy
- `lib/pages/pro/messages_pro/messages_pro_widget.dart`
- `lib/pages/pro/messages_pro/messages_pro_model.dart`

### A Creer
- `lib/features/chat/presentation/pages/messages_pro_wrapper.dart`

## Notes Techniques

### Simple Wrapper
```dart
/// Wrapper pour maintenir la compatibilite avec la navigation FlutterFlow
class MessagesProWrapper extends StatelessWidget {
  const MessagesProWrapper({super.key});

  static const routeName = 'MessagesPro';
  static const routePath = '/messagesPro';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConversationsCubit(
        repository: getIt<ChatRepository>(),
        userRole: 'professional',
      ),
      child: const MessagesPage(userRole: 'professional'),
    );
  }
}
```

## Definition of Done

- [ ] Wrapper cree
- [ ] Navigation maintenue
- [ ] Tests de navigation
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 1
**Complexite** : Faible
**Risque** : Faible

## Dependances

- S07 : Chat - Presentation layer

## Stories Dependantes

- Aucune
