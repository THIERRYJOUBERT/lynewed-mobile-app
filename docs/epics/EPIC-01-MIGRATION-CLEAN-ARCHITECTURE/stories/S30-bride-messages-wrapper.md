# Story S30: Bride - Messages Page Wrapper

## Description

En tant que developpeur, je veux creer un wrapper pour la page Messages Bride afin d'integrer le module Chat Clean Architecture.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `MessagesBridesWidget` When je cree un wrapper Then il utilise le module Chat

- [ ] Given la navigation existante When je la maintiens Then les routes fonctionnent

- [ ] Given la page legacy When elle n'est plus utilisee Then elle peut etre supprimee

## Fichiers Concernes

### Pages Legacy
- `lib/pages/bride/messages_brides/messages_brides_widget.dart`
- `lib/pages/bride/messages_brides/messages_brides_model.dart`

### A Creer/Modifier
- `lib/features/chat/presentation/pages/messages_brides_wrapper.dart`

## Notes Techniques

### Simple Wrapper
```dart
/// Wrapper pour maintenir la compatibilite avec la navigation FlutterFlow
/// Sera supprime une fois la migration complete.
class MessagesBridesWrapper extends StatelessWidget {
  const MessagesBridesWrapper({super.key});

  static const routeName = 'MessagesBrides';
  static const routePath = '/messagesBrides';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConversationsCubit(
        repository: getIt<ChatRepository>(),
        userRole: 'bride',
      ),
      child: const MessagesPage(userRole: 'bride'),
    );
  }
}
```

La majeure partie du travail est fait dans S07 (Chat - Presentation).
Cette story est principalement pour maintenir la compatibilite de navigation.

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
