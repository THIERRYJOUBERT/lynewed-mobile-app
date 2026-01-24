# Story S06: Chat - Data Layer Completion

## Description

En tant que developpeur, je veux completer la couche data du module Chat afin d'implementer toutes les operations de messagerie definies dans le domain layer.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `ChatRemoteDatasource` When j'analyse l'implementation Then je liste les methodes manquantes

- [ ] Given les methodes manquantes When je les implemente Then toutes les operations Supabase sont couvertes

- [ ] Given `ChatRepositoryImpl` When je complete l'implementation Then il implemente entierement `ChatRepository`

- [ ] Given `ContactRepositoryImpl` When je verifie Then il implemente entierement `ContactRepository`

- [ ] Given les implementations When j'ecris les tests Then les tests passent avec des mocks

## Fichiers Concernes

### Existants (a completer)
- `lib/features/chat/data/datasources/chat_remote_datasource.dart`
- `lib/features/chat/data/repositories/chat_repository_impl.dart`
- `lib/features/chat/data/repositories/contact_repository_impl.dart`

### A Creer si Manquants
- `lib/features/chat/data/models/chat_message_model.dart` - DTO pour mapping
- `lib/features/chat/data/models/chat_room_model.dart` - DTO pour mapping

### Tests a Creer
- `test/features/chat/data/repositories/chat_repository_impl_test.dart`
- `test/features/chat/data/datasources/chat_remote_datasource_test.dart`

## Notes Techniques

### Migration des Actions Custom Code
Ces actions doivent etre integrees dans le datasource/repository :

```
lib/custom_code/actions/
├── send_text_message_action.dart       → ChatRemoteDatasource.sendMessage()
├── delete_own_message_action.dart      → ChatRemoteDatasource.deleteMessage()
├── mark_room_read_action.dart          → ChatRemoteDatasource.markAsRead()
├── upload_and_send_images_action.dart  → ChatRemoteDatasource.sendMediaMessage()
├── upload_and_send_audio_action.dart   → ChatRemoteDatasource.sendAudioMessage()
├── archive_conversation_action.dart    → ChatRemoteDatasource.archiveConversation()
├── report_message_action.dart          → ChatRemoteDatasource.reportMessage()
├── get_room_header_action.dart         → ChatRemoteDatasource.getRoomHeader()
├── get_rooms_with_unread_counts_action.dart → ChatRemoteDatasource.getConversations()
```

### Datasource Pattern
```dart
abstract class ChatRemoteDatasource {
  Future<List<ChatMessageModel>> getMessages(String roomId, {int limit, String? before});
  Future<ChatMessageModel> sendTextMessage(String roomId, String content);
  Future<ChatMessageModel> sendMediaMessage(String roomId, List<String> urls);
  Future<ChatMessageModel> sendAudioMessage(String roomId, String audioUrl, Duration duration);
  Future<void> deleteMessage(String messageId);
  Future<void> markRoomAsRead(String roomId);
  Stream<ChatMessageModel> watchNewMessages(String roomId);
  // ... etc
}

class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  final SupabaseClient _supabase;

  ChatRemoteDatasourceImpl(this._supabase);

  @override
  Future<List<ChatMessageModel>> getMessages(String roomId, {int limit = 50, String? before}) async {
    var query = _supabase
        .from('chat_messages')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .limit(limit);

    if (before != null) {
      query = query.lt('created_at', before);
    }

    final response = await query;
    return response.map((e) => ChatMessageModel.fromJson(e)).toList();
  }
  // ... etc
}
```

### Repository Pattern
```dart
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource _remoteDatasource;

  ChatRepositoryImpl(this._remoteDatasource);

  @override
  Future<Result<List<ChatMessage>>> getMessages(String roomId, {int limit = 50, String? before}) async {
    try {
      final models = await _remoteDatasource.getMessages(roomId, limit: limit, before: before);
      final messages = models.map((m) => m.toEntity()).toList();
      return Success(messages);
    } on ServerException catch (e) {
      return Failure(ServerFailure(e.message));
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }
  // ... etc
}
```

## Definition of Done

- [ ] Audit des implementations existantes
- [ ] Actions custom code integrees
- [ ] Datasource complet et teste
- [ ] Repository complet et teste
- [ ] Models/DTOs avec mapping
- [ ] Tests avec mocks (mocktail)
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 8
**Complexite** : Elevee
**Risque** : Moyen

## Dependances

- S01 : Setup infrastructure
- S05 : Chat - Domain layer

## Stories Dependantes

- S07 : Chat - Presentation layer
- S36 : Custom Code - Chat actions migration
