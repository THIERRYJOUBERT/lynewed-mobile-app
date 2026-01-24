# Step 04: Add Tests

## Objective
Add unit tests for migrated features, following the Map module test pattern.

## Reference: Map Module Tests

```
test/features/map/
├── data/
│   └── repositories/
│       └── map_repository_test.dart
└── domain/
    ├── entities/
    │   ├── alert_details_test.dart
    │   ├── map_filter_test.dart
    │   ├── map_marker_test.dart
    │   ├── professional_details_test.dart
    │   └── wedding_details_test.dart
    └── usecases/
        └── get_marker_details_test.dart
```

## Test Priority

1. **Domain Entities**: Always test (immutable objects, equality, copyWith)
2. **Use Cases**: Test business logic
3. **Repository Implementations**: Test with mocked datasources
4. **Widgets**: Optional (complex UI logic only)

## Test Patterns

### Entity Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/chat/domain/entities/chat_message.dart';

void main() {
  group('ChatMessage', () {
    test('should create instance with required fields', () {
      const message = ChatMessage(
        id: '123',
        content: 'Hello',
        senderId: 'user1',
      );

      expect(message.id, '123');
      expect(message.content, 'Hello');
      expect(message.senderId, 'user1');
    });

    test('should support equality', () {
      const message1 = ChatMessage(id: '123', content: 'Hello', senderId: 'user1');
      const message2 = ChatMessage(id: '123', content: 'Hello', senderId: 'user1');

      expect(message1, equals(message2));
    });

    test('copyWith should create new instance with changed fields', () {
      const original = ChatMessage(id: '123', content: 'Hello', senderId: 'user1');
      final modified = original.copyWith(content: 'World');

      expect(modified.id, '123');
      expect(modified.content, 'World');
      expect(modified.senderId, 'user1');
    });
  });
}
```

### Repository Tests (with Mocks)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lynewed_beta/features/chat/data/datasources/supabase_chat_datasource.dart';
import 'package:lynewed_beta/features/chat/data/repositories/chat_repository_impl.dart';

class MockChatDatasource extends Mock implements SupabaseChatDatasource {}

void main() {
  late ChatRepositoryImpl repository;
  late MockChatDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockChatDatasource();
    repository = ChatRepositoryImpl(mockDatasource);
  });

  group('ChatRepositoryImpl', () {
    test('getMessages should return list of ChatMessage entities', () async {
      // Arrange
      when(() => mockDatasource.fetchMessages('room1')).thenAnswer(
        (_) async => [
          {'id': '1', 'content': 'Hello', 'sender_id': 'user1'},
        ],
      );

      // Act
      final messages = await repository.getMessages('room1');

      // Assert
      expect(messages.length, 1);
      expect(messages.first.content, 'Hello');
      verify(() => mockDatasource.fetchMessages('room1')).called(1);
    });

    test('getMessages should handle empty response', () async {
      when(() => mockDatasource.fetchMessages('room1')).thenAnswer(
        (_) async => [],
      );

      final messages = await repository.getMessages('room1');

      expect(messages, isEmpty);
    });
  });
}
```

### Use Case Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lynewed_beta/features/chat/domain/repositories/chat_repository.dart';
import 'package:lynewed_beta/features/chat/domain/usecases/send_message.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late SendMessageUseCase useCase;
  late MockChatRepository mockRepository;

  setUp(() {
    mockRepository = MockChatRepository();
    useCase = SendMessageUseCase(mockRepository);
  });

  group('SendMessageUseCase', () {
    test('should call repository sendMessage', () async {
      const message = ChatMessage(id: '1', content: 'Test', senderId: 'user1');
      when(() => mockRepository.sendMessage(message)).thenAnswer((_) async {});

      await useCase.execute(message);

      verify(() => mockRepository.sendMessage(message)).called(1);
    });
  });
}
```

## Execution Loop

For each migrated feature:

1. **Create test file structure**:
   ```bash
   mkdir -p test/features/{feature}/domain/entities
   mkdir -p test/features/{feature}/data/repositories
   ```

2. **Write entity tests** (mandatory):
   - One test file per entity
   - Test creation, equality, copyWith

3. **Write repository tests** (if data layer exists):
   - Mock datasources
   - Test happy path and error cases

4. **Run tests**:
   ```bash
   flutter test test/features/{feature}/
   ```

5. **Log progress**:
   ```markdown
   ## Tests Added - {feature} - {date}

   ### Files Created
   - test/features/{feature}/domain/entities/message_test.dart
   - test/features/{feature}/data/repositories/repository_test.dart

   ### Coverage
   | Layer | Files | Tests | Coverage |
   |-------|-------|-------|----------|
   | Domain | 3 | 15 | ~80% |
   | Data | 2 | 8 | ~60% |
   | Presentation | 0 | 0 | 0% |

   ### Test Results
   flutter test: ✅ All 23 tests passed
   ```

## Dependencies for Testing

Ensure these are in dev_dependencies:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0  # For mocking
```

## Validation

```bash
# Run all tests
flutter test

# Run specific feature tests
flutter test test/features/chat/

# With coverage (optional)
flutter test --coverage
```

## Completion Criteria

- All migrated features have domain entity tests
- Repository tests exist for data layer
- `flutter test` passes without failures
- Test count documented in cleanup-log.md

## Next Step
Load `steps/step-05-docs.md`
