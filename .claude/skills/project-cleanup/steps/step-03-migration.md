# Step 03: Migrate to Clean Architecture

## Objective
Migrate FlutterFlow legacy code to Clean Architecture, using the Map module as the reference template.

## Reference: Map Module Structure

The Map module is 100% Clean Architecture and serves as the template:

```
lib/features/map/
├── domain/
│   ├── entities/          # Business objects (immutable)
│   ├── repositories/      # Abstract interfaces
│   ├── usecases/          # Business logic
│   └── utils/             # Domain utilities
├── data/
│   ├── datasources/       # External data sources
│   ├── models/            # DTOs, mappers
│   └── repositories/      # Interface implementations
├── presentation/
│   ├── pages/             # Full-screen widgets
│   ├── widgets/           # Reusable components
│   ├── sheets/            # Bottom sheets
│   ├── state/             # State management (ChangeNotifier)
│   ├── services/          # Presentation services
│   └── theme/             # Feature-specific theming
├── map.dart               # Barrel export
└── README.md              # Feature documentation
```

## Migration Priority

Based on initial assessment, migrate in this order:

1. **Chat feature** (partially migrated)
2. **Notifications feature** (partially migrated)
3. **Dashboard feature** (minimal)
4. **Pages/shared** (many FlutterFlow widgets)

## Migration Process for Each Feature

### Step 1: Analyze Current State

```
Launch exploration agent (model: sonnet):
- Read all files in lib/pages/{feature}/
- Read all files in lib/custom_code/ related to feature
- Identify data sources, business logic, UI code
- Map to Clean Architecture layers
```

### Step 2: Create Domain Layer

1. **Entities**: Extract business objects
   - Convert FlutterFlow structs to immutable classes
   - Remove UI dependencies

2. **Repository Interfaces**: Define abstractions
   ```dart
   abstract class ChatRepository {
     Future<List<ChatMessage>> getMessages(String roomId);
     Future<void> sendMessage(ChatMessage message);
   }
   ```

3. **Use Cases** (optional): Extract complex business logic

### Step 3: Create Data Layer

1. **Datasources**: Wrap Supabase calls
   ```dart
   class SupabaseChatDatasource {
     final SupabaseClient _client;

     Future<List<Map<String, dynamic>>> fetchMessages(String roomId) async {
       return await _client.from('chat_messages').select().eq('room_id', roomId);
     }
   }
   ```

2. **Models**: Create DTOs with fromJson/toJson
   ```dart
   class ChatMessageModel {
     final String id;
     final String content;

     factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ...
     Map<String, dynamic> toJson() => ...

     ChatMessage toEntity() => ChatMessage(id: id, content: content);
   }
   ```

3. **Repository Implementation**: Implement interfaces
   ```dart
   class ChatRepositoryImpl implements ChatRepository {
     final SupabaseChatDatasource _datasource;

     @override
     Future<List<ChatMessage>> getMessages(String roomId) async {
       final data = await _datasource.fetchMessages(roomId);
       return data.map((json) => ChatMessageModel.fromJson(json).toEntity()).toList();
     }
   }
   ```

### Step 4: Refactor Presentation Layer

1. **Extract State**: Move FFAppState dependencies to feature-specific state
   ```dart
   class ChatState extends ChangeNotifier {
     final ChatRepository _repository;
     List<ChatMessage> messages = [];

     Future<void> loadMessages(String roomId) async {
       messages = await _repository.getMessages(roomId);
       notifyListeners();
     }
   }
   ```

2. **Clean Widgets**: Remove FlutterFlow dependencies
   - Replace FlutterFlowTheme with LynewedDesignSystem
   - Remove FlutterFlowModel patterns
   - Use feature state instead of FFAppState

3. **Create Barrel Export**:
   ```dart
   // lib/features/chat/chat.dart
   export 'domain/entities/entities.dart';
   export 'domain/repositories/chat_repository.dart';
   export 'presentation/pages/chat_page.dart';
   export 'presentation/state/chat_state.dart';
   ```

### Step 5: Update Imports

Search and replace imports:
```dart
// BEFORE
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/schema/structs/index.dart';

// AFTER
import '/core/design/design.dart';
import '/features/chat/chat.dart';
```

## Validation After Each Migration

```bash
flutter analyze --no-fatal-infos
flutter test test/features/{feature}/
```

## Logging

After each feature migration:
```markdown
## Migration: {feature} - {date}

### Files Created
- lib/features/{feature}/domain/entities/...
- lib/features/{feature}/data/repositories/...
- etc.

### Files Modified
- lib/pages/{feature}/... (updated imports)

### Files Removed
- None (keep legacy until fully tested)

### Test Coverage
- Domain entities: ✅
- Repository: ⚠️ (needs more tests)
- Widgets: ❌ (no tests yet)

### Remaining FlutterFlow Dependencies
- FFAppState: 2 usages
- FlutterFlowTheme: 0 usages
```

## Completion Criteria

- Chat feature fully migrated
- Notifications feature fully migrated
- No new FlutterFlow imports added
- Tests pass for migrated features

## Next Step
Load `steps/step-04-tests.md`
