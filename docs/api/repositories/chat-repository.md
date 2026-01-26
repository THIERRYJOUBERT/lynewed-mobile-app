# ChatRepository

**Location:** `lib/features/chat/domain/repositories/chat_repository.dart`
**Implementation:** `lib/features/chat/data/repositories/chat_repository_impl.dart`

---

## Description

Repository pour la messagerie temps réel. Gère les conversations privées et publiques, l'envoi de messages (texte, image, audio, document), et les subscriptions Supabase Realtime.

---

## Interface

```dart
abstract class ChatRepository {
  // Conversations
  Future<ChatResult<List<Conversation>>> getConversations();
  Future<ChatResult<List<Conversation>>> getPublicChatRooms();
  Future<ChatResult<void>> archiveConversation(String roomId);
  Future<ChatResult<void>> unarchiveConversation(String roomId);
  Future<ChatResult<Map<String, dynamic>?>> getOtherParticipantInfo(String roomId);
  Future<ChatResult<List<Map<String, dynamic>>>> getProfilesInfo(List<String> profileIds);

  // Participants
  Future<ChatResult<List<ChatParticipant>>> getRoomParticipants(String roomId);

  // Messages
  Future<ChatResult<List<ChatMessage>>> getMessages({
    required String roomId,
    int limit = 50,
    int? beforeId,
  });
  Future<ChatResult<ChatMessage>> sendTextMessage({required String roomId, required String content});
  Future<ChatResult<ChatMessage>> sendImageMessage({required String roomId, required String attachmentUrl});
  Future<ChatResult<ChatMessage>> sendAudioMessage({required String roomId, required String attachmentUrl});
  Future<ChatResult<ChatMessage>> sendDocumentMessage({
    required String roomId,
    required String attachmentUrl,
    required String attachmentName,
    required int attachmentSize,
    required String attachmentMimeType,
  });
  Future<ChatResult<void>> deleteMessage(int messageId);
  Future<ChatResult<void>> markRoomAsRead(String roomId);

  // Realtime
  Stream<ChatMessage> subscribeToMessages(String roomId);
  Stream<void> subscribeToConversationUpdates();
  void disposeSubscriptions();

  // Media
  Future<ChatResult<String>> uploadImage({required String roomId, required String filePath, required String fileName});
  Future<ChatResult<String>> uploadAudio({required String roomId, required String filePath, required String fileName});
  Future<ChatResult<String>> uploadDocument({required String roomId, required String filePath, required String fileName});
  Future<ChatResult<String>> getSignedUrl(String path);
}
```

---

## Result Wrapper

```dart
class ChatResult<T> {
  final T? data;
  final String? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}
```

---

## Méthodes Principales

### `getConversations()`

Récupère toutes les conversations de l'utilisateur courant.

**Retour:** `Future<ChatResult<List<Conversation>>>`

**Exemple:**
```dart
final result = await repository.getConversations();
if (result.isSuccess) {
  for (final conv in result.data!) {
    print('Room: ${conv.roomId} - ${conv.lastMessage}');
  }
}
```

---

### `getMessages()`

Récupère les messages d'une room avec pagination.

**Paramètres:**
- `roomId` (String): ID de la room
- `limit` (int): Nombre de messages (défaut: 50)
- `beforeId` (int?): ID du message pour pagination

**Retour:** `Future<ChatResult<List<ChatMessage>>>`

**Exemple:**
```dart
// Premiers messages
final result = await repository.getMessages(roomId: 'room-123');

// Charger plus (pagination)
final moreResult = await repository.getMessages(
  roomId: 'room-123',
  limit: 50,
  beforeId: result.data!.last.id,
);
```

---

### `sendTextMessage()`

Envoie un message texte.

**Paramètres:**
- `roomId` (String): ID de la room
- `content` (String): Contenu du message

**Retour:** `Future<ChatResult<ChatMessage>>`

**Exemple:**
```dart
final result = await repository.sendTextMessage(
  roomId: 'room-123',
  content: 'Bonjour !',
);

if (result.isSuccess) {
  print('Message envoyé: ${result.data!.id}');
}
```

---

### `sendImageMessage()`

Envoie un message image (après upload).

**Exemple:**
```dart
// 1. Upload l'image
final uploadResult = await repository.uploadImage(
  roomId: 'room-123',
  filePath: '/path/to/image.jpg',
  fileName: 'photo.jpg',
);

// 2. Envoyer le message
if (uploadResult.isSuccess) {
  await repository.sendImageMessage(
    roomId: 'room-123',
    attachmentUrl: uploadResult.data!,
  );
}
```

---

### `sendDocumentMessage()`

Envoie un document (PDF).

**Exemple:**
```dart
final uploadResult = await repository.uploadDocument(
  roomId: 'room-123',
  filePath: '/path/to/contract.pdf',
  fileName: 'contrat.pdf',
);

if (uploadResult.isSuccess) {
  await repository.sendDocumentMessage(
    roomId: 'room-123',
    attachmentUrl: uploadResult.data!,
    attachmentName: 'contrat.pdf',
    attachmentSize: 1024000, // bytes
    attachmentMimeType: 'application/pdf',
  );
}
```

---

### `subscribeToMessages()`

Stream temps réel des nouveaux messages d'une room.

**Paramètres:**
- `roomId` (String): ID de la room

**Retour:** `Stream<ChatMessage>`

**Exemple:**
```dart
repository.subscribeToMessages('room-123').listen((message) {
  print('Nouveau message: ${message.content}');
  // Mettre à jour l'UI
});
```

---

### `subscribeToConversationUpdates()`

Stream des updates de conversations (nouveau message dans n'importe quelle room).

**Exemple:**
```dart
repository.subscribeToConversationUpdates().listen((_) {
  // Recharger la liste des conversations
  loadConversations();
});
```

---

### `markRoomAsRead()`

Marque une room comme lue pour l'utilisateur courant.

**Exemple:**
```dart
await repository.markRoomAsRead('room-123');
```

---

## Utilisation avec Cubit

```dart
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  StreamSubscription? _messagesSubscription;

  ChatCubit(this._repository) : super(ChatState.initial());

  Future<void> loadMessages(String roomId) async {
    emit(state.copyWith(loading: true));

    final result = await _repository.getMessages(roomId: roomId);
    if (result.isSuccess) {
      emit(state.copyWith(messages: result.data, loading: false));
    }

    // S'abonner aux nouveaux messages
    _messagesSubscription = _repository.subscribeToMessages(roomId).listen((msg) {
      emit(state.copyWith(messages: [...state.messages, msg]));
    });
  }

  Future<void> sendMessage(String content) async {
    final result = await _repository.sendTextMessage(
      roomId: state.roomId,
      content: content,
    );
    // Le message sera ajouté via le stream realtime
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _repository.disposeSubscriptions();
    return super.close();
  }
}
```

---

## Notes

- Les messages utilisent Supabase Realtime pour les mises à jour instantanées
- Les médias sont uploadés dans Supabase Storage (`chat-media` bucket)
- Les URLs signées sont requises pour accéder aux médias privés
- Appeler `disposeSubscriptions()` pour nettoyer les subscriptions
- Les messages supprimés sont marqués `is_deleted=true` (soft delete)
