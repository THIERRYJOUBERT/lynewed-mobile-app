# Story S05: Chat - Domain Layer Completion

## Description

En tant que developpeur, je veux completer la couche domain du module Chat afin d'avoir une base solide et testable pour toutes les operations de messagerie.

## Criteres d'Acceptance (Gherkin)

- [ ] Given le module Chat existant When j'analyse `lib/features/chat/domain/` Then je liste les entites et repositories manquants

- [ ] Given les entites existantes When j'ajoute les entites manquantes Then toutes les operations Chat sont couvertes

- [ ] Given `ChatRepository` When je complete l'interface Then toutes les operations CRUD sont definies

- [ ] Given `ContactRepository` When je verifie l'interface Then les operations de contact request sont completes

- [ ] Given les nouvelles entites When j'ecris les tests unitaires Then 100% des tests passent

## Fichiers Concernes

### Existants (a verifier/completer)
- `lib/features/chat/domain/entities/chat_message.dart`
- `lib/features/chat/domain/entities/chat_room.dart`
- `lib/features/chat/domain/entities/conversation.dart`
- `lib/features/chat/domain/entities/contact_request.dart`
- `lib/features/chat/domain/entities/blocked_user.dart`
- `lib/features/chat/domain/entities/chat_entry_context.dart`
- `lib/features/chat/domain/entities/chat_enums.dart`
- `lib/features/chat/domain/repositories/chat_repository.dart`
- `lib/features/chat/domain/repositories/contact_repository.dart`

### A Creer si Manquants
- `lib/features/chat/domain/entities/chat_participant.dart` - Participant d'une room
- `lib/features/chat/domain/entities/message_attachment.dart` - Pieces jointes
- `lib/features/chat/domain/usecases/` - Use cases si necessaire

### Tests a Creer
- `test/features/chat/domain/entities/chat_message_test.dart`
- `test/features/chat/domain/entities/chat_room_test.dart`
- `test/features/chat/domain/entities/conversation_test.dart`

## Notes Techniques

### Entites a Verifier
```dart
// ChatMessage doit avoir :
class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String? senderName;
  final String? senderAvatarUrl;
  final MessageType type;
  final String? textContent;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final Duration? audioDuration;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isDeleted;
  final String? replyToId;
  // ...

  const ChatMessage({...});
  ChatMessage copyWith({...});
}
```

### Repository Interface Complete
```dart
abstract class ChatRepository {
  // Messages
  Future<Result<List<ChatMessage>>> getMessages(String roomId, {int limit, String? before});
  Future<Result<ChatMessage>> sendMessage(SendMessageParams params);
  Future<Result<void>> deleteMessage(String messageId);
  Future<Result<void>> markAsRead(String roomId);
  Stream<ChatMessage> watchNewMessages(String roomId);

  // Rooms
  Future<Result<ChatRoom>> getRoom(String roomId);
  Future<Result<ChatRoom>> createRoom(CreateRoomParams params);
  Future<Result<void>> archiveRoom(String roomId);
  Future<Result<void>> unarchiveRoom(String roomId);

  // Conversations list
  Future<Result<List<Conversation>>> getConversations({bool includeArchived});
  Stream<List<Conversation>> watchConversations();

  // Participants
  Future<Result<List<ChatParticipant>>> getRoomParticipants(String roomId);
}
```

### Tests Pattern
```dart
void main() {
  group('ChatMessage', () {
    test('should create with required fields', () {
      final message = ChatMessage(
        id: '123',
        roomId: 'room-1',
        senderId: 'user-1',
        type: MessageType.text,
        textContent: 'Hello',
        createdAt: DateTime.now(),
      );

      expect(message.id, '123');
      expect(message.type, MessageType.text);
    });

    test('copyWith should create new instance with updated fields', () {
      final original = ChatMessage(...);
      final updated = original.copyWith(textContent: 'Updated');

      expect(updated.textContent, 'Updated');
      expect(updated.id, original.id); // unchanged
    });
  });
}
```

## Definition of Done

- [ ] Audit des entites existantes realise
- [ ] Entites manquantes creees
- [ ] Repository interfaces completes
- [ ] Tests unitaires pour toutes les entites
- [ ] Documentation dans barrel export
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 3
**Complexite** : Faible (completion)
**Risque** : Faible

## Dependances

- S01 : Setup infrastructure (pour Result pattern)

## Stories Dependantes

- S06 : Chat - Data layer
- S07 : Chat - Presentation layer
