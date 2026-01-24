# Story STORY-01: Tests Chat Module (Domain + Data)

## Description

En tant que developpeur, je veux avoir des tests unitaires pour le module Chat afin de garantir la qualite et la stabilite des entites et du repository de chat.

## Points : 5

## Priorite : Haute

## Fichiers source a tester

### Domain Layer

| Fichier | Entites/Composants |
|---------|-------------------|
| `lib/features/chat/domain/entities/conversation.dart` | Conversation |
| `lib/features/chat/domain/entities/chat_message.dart` | ChatMessage |
| `lib/features/chat/domain/entities/chat_enums.dart` | ChatEntryStatus, ConversationStatus, MessageType, RoomType, UserRole, ReportReason |
| `lib/features/chat/domain/entities/chat_room.dart` | ChatRoom |
| `lib/features/chat/domain/entities/contact_request.dart` | ContactRequest |
| `lib/features/chat/domain/entities/blocked_user.dart` | BlockedUser |
| `lib/features/chat/domain/entities/chat_entry_context.dart` | ChatEntryContext |

### Data Layer

| Fichier | Composants |
|---------|------------|
| `lib/features/chat/data/repositories/chat_repository_impl.dart` | ChatRepositoryImpl |
| `lib/features/chat/data/repositories/contact_repository_impl.dart` | ContactRepositoryImpl |

## Criteres d'Acceptance

### AC1: Tests des entites Conversation
- [ ] Test creation avec champs requis
- [ ] Test `fromMap()` avec donnees camelCase
- [ ] Test `fromMap()` avec donnees snake_case
- [ ] Test `copyWith()` preserve les champs non modifies
- [ ] Test getters derives (`isPublic`, `displayName`, `displayAvatarUrl`, `lastMessagePreview`)
- [ ] Test egalite (`==` et `hashCode`)

### AC2: Tests des entites ChatMessage
- [ ] Test creation avec champs requis
- [ ] Test `fromMap()` parse correctement tous les types
- [ ] Test `toInsertMap()` serialise correctement
- [ ] Test `copyWith()` fonctionne correctement
- [ ] Test egalite

### AC3: Tests des enums Chat
- [ ] Test `fromString()` pour tous les enums avec valeurs valides
- [ ] Test `fromString()` retourne null pour valeurs invalides
- [ ] Test `toBackendValue()` pour ReportReason
- [ ] Test `displayLabel` getters

### AC4: Tests ChatRepositoryImpl
- [ ] Test `getConversations()` success et failure
- [ ] Test `getMessages()` avec pagination
- [ ] Test `sendTextMessage()` success et failure
- [ ] Test `sendImageMessage()` success
- [ ] Test `archiveConversation()` success et failure
- [ ] Test `markRoomAsRead()` success

### AC5: Qualite des tests
- [ ] Coverage > 80% sur domain/entities/
- [ ] Coverage > 60% sur data/repositories/
- [ ] Tous les tests passent
- [ ] Temps d'execution < 5s

## Fichiers de Test a Creer

```
test/features/chat/
├── domain/
│   └── entities/
│       ├── conversation_test.dart
│       ├── chat_message_test.dart
│       ├── chat_enums_test.dart
│       ├── chat_room_test.dart
│       ├── contact_request_test.dart
│       └── blocked_user_test.dart
└── data/
    └── repositories/
        ├── chat_repository_impl_test.dart
        └── contact_repository_impl_test.dart
```

## Notes Techniques

### Mocks necessaires

```dart
import 'package:mocktail/mocktail.dart';

class MockChatRemoteDatasource extends Mock implements ChatRemoteDatasource {}
class MockContactDatasource extends Mock implements ContactDatasource {}
```

### Fixtures de test

```dart
// test/features/chat/fixtures/chat_fixtures.dart

const testConversationMap = {
  'room_id': 'room-123',
  'room_type': 'private',
  'conversation_status': 'active',
  'unread_count': 5,
  'last_message_type': 'text',
  'last_message_text': 'Hello!',
  'last_message_at': '2025-01-24T10:00:00Z',
  'other_profile_id': 'user-456',
  'other_full_name': 'John Doe',
};

const testChatMessageMap = {
  'id': 1,
  'room_id': 'room-123',
  'profile_id': 'user-456',
  'content': 'Test message',
  'message_type': 'text',
  'is_deleted': false,
  'created_at': '2025-01-24T10:00:00Z',
};
```

### Pattern de test pour repository

```dart
void main() {
  late MockChatRemoteDatasource mockDatasource;
  late ChatRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockChatRemoteDatasource();
    repository = ChatRepositoryImpl(datasource: mockDatasource);
  });

  group('getConversations', () {
    test('should return success when datasource returns data', () async {
      // Arrange
      when(() => mockDatasource.getConversations())
          .thenAnswer((_) async => [testConversation]);

      // Act
      final result = await repository.getConversations();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data?.length, 1);
      verify(() => mockDatasource.getConversations()).called(1);
    });

    test('should return failure when datasource throws', () async {
      // Arrange
      when(() => mockDatasource.getConversations())
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.getConversations();

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, contains('Failed to load'));
    });
  });
}
```

## Definition of Done

- [ ] Tous les fichiers de test crees
- [ ] Tous les tests passent (`flutter test test/features/chat/`)
- [ ] Aucun warning (`flutter analyze`)
- [ ] Coverage mesure et documente
- [ ] TRACKING.md mis a jour

## Estimation

- Entites (AC1-AC3) : ~2h
- Repository (AC4) : ~2h
- Review et polish : ~1h

**Total** : ~5h (1 jour)
