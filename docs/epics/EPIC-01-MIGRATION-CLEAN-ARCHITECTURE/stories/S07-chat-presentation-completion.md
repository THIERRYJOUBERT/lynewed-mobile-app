# Story S07: Chat - Presentation Layer Completion

## Description

En tant que developpeur, je veux completer la couche presentation du module Chat afin d'avoir une UI complete et testable pour la messagerie.

## Criteres d'Acceptance (Gherkin)

- [ ] Given les pages Chat existantes When j'analyse Then je liste les widgets et pages manquants

- [ ] Given `ChatRoomNotifier` When je complete le state management Then toutes les operations sont gerees

- [ ] Given `ConversationsCubit` When je verifie Then la liste des conversations est complete

- [ ] Given les widgets existants When j'ajoute les manquants Then l'UI Chat est complete

- [ ] Given les pages legacy `messages_brides` et `messages_pro` When je les remplace Then ils utilisent le nouveau module Chat

## Fichiers Concernes

### Existants (a verifier/completer)
- `lib/features/chat/presentation/bloc/chat_room_notifier.dart`
- `lib/features/chat/presentation/bloc/conversations_cubit.dart`
- `lib/features/chat/presentation/pages/chat_details_page.dart`
- `lib/features/chat/presentation/pages/messages_page.dart`
- `lib/features/chat/presentation/widgets/message_bubble.dart`
- `lib/features/chat/presentation/widgets/message_composer.dart`
- `lib/features/chat/presentation/widgets/message_list.dart`
- `lib/features/chat/presentation/widgets/conversation_tile.dart`
- `lib/features/chat/presentation/sheets/`

### Pages Legacy a Remplacer
- `lib/pages/bride/messages_brides/` - Liste conversations Bride
- `lib/pages/pro/messages_pro/` - Liste conversations Pro

### A Creer si Manquants
- `lib/features/chat/presentation/widgets/typing_indicator.dart`
- `lib/features/chat/presentation/widgets/read_receipt.dart`
- `lib/features/chat/presentation/pages/public_rooms_page.dart` (si applicable)

## Notes Techniques

### State Management Pattern
```dart
// ChatRoomNotifier pour une conversation
class ChatRoomNotifier extends ChangeNotifier {
  final ChatRepository _repository;
  final String roomId;

  ChatRoomState _state = ChatRoomState.initial();
  ChatRoomState get state => _state;

  ChatRoomNotifier({
    required ChatRepository repository,
    required this.roomId,
  }) : _repository = repository {
    _loadMessages();
    _subscribeToNewMessages();
  }

  Future<void> _loadMessages() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final result = await _repository.getMessages(roomId);
    result.when(
      success: (messages) {
        _state = _state.copyWith(
          isLoading: false,
          messages: messages,
        );
      },
      failure: (failure) {
        _state = _state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
    );
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    _state = _state.copyWith(isSending: true);
    notifyListeners();

    final result = await _repository.sendMessage(
      SendMessageParams(roomId: roomId, content: content),
    );
    // ... handle result
  }
}
```

### Integration avec Pages Legacy
```dart
// Wrapper pour compatibilite navigation
class MessagesBridesPageWrapper extends StatelessWidget {
  const MessagesBridesPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConversationsCubit(
        repository: context.read<ChatRepository>(),
        userRole: 'bride',
      ),
      child: const MessagesPage(userRole: 'bride'),
    );
  }
}
```

### Widgets Custom Code a Integrer
```
lib/custom_code/widgets/
├── chat_composer_widget.dart  → MessageComposer (existe deja?)
├── chat_message_list.dart     → MessageList (existe deja?)
├── audio_player_widget.dart   → AudioPlayerWidget
├── audio_recorder_widget.dart → AudioRecorderWidget (dans composer)
```

## Definition of Done

- [ ] State management complet (Notifier/Cubit)
- [ ] Toutes les pages Chat migrees
- [ ] Widgets custom code integres
- [ ] Pages legacy remplacees par wrappers
- [ ] Tests widgets (widget tests)
- [ ] Navigation fonctionnelle
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 8
**Complexite** : Elevee
**Risque** : Moyen (UI critique)

## Dependances

- S03 : Design system
- S04 : Navigation
- S05 : Chat - Domain
- S06 : Chat - Data

## Stories Dependantes

- S30 : Bride - Messages page wrapper
- S33 : Pro - Messages page wrapper
