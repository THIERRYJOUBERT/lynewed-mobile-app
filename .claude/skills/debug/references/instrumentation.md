# Instrumentation Guide

> Patterns de logs temporaires pour debugging par langage/framework.
> RAPPEL: Tous les logs DOIVENT etre marques `// DEBUG - A RETIRER`

---

## Principe General

L'instrumentation sert a **observer** le comportement runtime, pas a modifier la logique.

**Regles d'or:**
1. Marquer TOUJOURS avec `// DEBUG - A RETIRER`
2. Logger la valeur ET son origine/contexte
3. Placer aux points strategiques (entree/sortie de fonction, conditions)
4. Inclure un timestamp si le timing est important

---

## Flutter / Dart

### Basic Logging

```dart
// DEBUG - A RETIRER: Trace user loading
print('// DEBUG - A RETIRER: userId=$userId at ${DateTime.now()}');
```

### With Context

```dart
// DEBUG - A RETIRER: API call context
debugPrint('// DEBUG - A RETIRER: [UserService.fetchUser] '
    'userId=$userId, authToken=${authToken.substring(0, 10)}...');
```

### Function Entry/Exit

```dart
Future<User> fetchUser(String userId) async {
  print('// DEBUG - A RETIRER: [ENTER] fetchUser($userId)'); // DEBUG - A RETIRER

  try {
    final user = await _api.getUser(userId);
    print('// DEBUG - A RETIRER: [EXIT] fetchUser -> ${user.name}'); // DEBUG - A RETIRER
    return user;
  } catch (e) {
    print('// DEBUG - A RETIRER: [ERROR] fetchUser -> $e'); // DEBUG - A RETIRER
    rethrow;
  }
}
```

### State Changes

```dart
void updateState(AppState newState) {
  print('// DEBUG - A RETIRER: State change: $currentState -> $newState'); // DEBUG - A RETIRER
  currentState = newState;
}
```

### Riverpod Provider

```dart
final userProvider = FutureProvider<User>((ref) async {
  print('// DEBUG - A RETIRER: userProvider building'); // DEBUG - A RETIRER
  final user = await ref.read(apiProvider).getUser();
  print('// DEBUG - A RETIRER: userProvider built: ${user.id}'); // DEBUG - A RETIRER
  return user;
});
```

---

## TypeScript / JavaScript

### Basic Logging

```typescript
// DEBUG - A RETIRER: Trace variable
console.log('// DEBUG - A RETIRER:', { userId, timestamp: Date.now() });
```

### With Stack Trace

```typescript
// DEBUG - A RETIRER: Call stack
console.trace('// DEBUG - A RETIRER: Where is this called from?');
```

### Object Inspection

```typescript
// DEBUG - A RETIRER: Full object
console.dir(user, { depth: null }); // DEBUG - A RETIRER
```

### Async Flow

```typescript
async function fetchData(id: string): Promise<Data> {
  console.log('// DEBUG - A RETIRER: [ENTER] fetchData', { id }); // DEBUG - A RETIRER

  const result = await api.get(id);
  console.log('// DEBUG - A RETIRER: [EXIT] fetchData', { result }); // DEBUG - A RETIRER

  return result;
}
```

### React Component

```tsx
function UserCard({ userId }: Props) {
  console.log('// DEBUG - A RETIRER: UserCard render', { userId }); // DEBUG - A RETIRER

  useEffect(() => {
    console.log('// DEBUG - A RETIRER: UserCard mount'); // DEBUG - A RETIRER
    return () => {
      console.log('// DEBUG - A RETIRER: UserCard unmount'); // DEBUG - A RETIRER
    };
  }, []);

  return <div>{userId}</div>;
}
```

---

## Python

### Basic Logging

```python
# DEBUG - A RETIRER: Trace variable
print(f'// DEBUG - A RETIRER: user_id={user_id}')
```

### With Timestamp

```python
import datetime

# DEBUG - A RETIRER: Timed trace
print(f'// DEBUG - A RETIRER: [{datetime.datetime.now()}] user_id={user_id}')
```

### Function Decorator

```python
def debug_trace(func):  # DEBUG - A RETIRER
    def wrapper(*args, **kwargs):
        print(f'// DEBUG - A RETIRER: [ENTER] {func.__name__}({args}, {kwargs})')
        result = func(*args, **kwargs)
        print(f'// DEBUG - A RETIRER: [EXIT] {func.__name__} -> {result}')
        return result
    return wrapper

@debug_trace  # DEBUG - A RETIRER
def process_user(user_id: str) -> User:
    ...
```

---

## Patterns Strategiques

### Timing Issues

```dart
// Pour les bugs de timing, inclure timestamps precis
final stopwatch = Stopwatch()..start(); // DEBUG - A RETIRER
print('// DEBUG - A RETIRER: [T+0ms] Starting operation'); // DEBUG - A RETIRER

await operation1();
print('// DEBUG - A RETIRER: [T+${stopwatch.elapsedMilliseconds}ms] After op1'); // DEBUG - A RETIRER

await operation2();
print('// DEBUG - A RETIRER: [T+${stopwatch.elapsedMilliseconds}ms] After op2'); // DEBUG - A RETIRER
```

### Race Conditions

```dart
// Pour les race conditions, identifier le thread/isolate
print('// DEBUG - A RETIRER: [${Isolate.current.debugName}] Accessing shared resource'); // DEBUG - A RETIRER
```

### Value Tracking

```dart
// Pour suivre une valeur a travers le code
const DEBUG_TRACE_USER_ID = true; // DEBUG - A RETIRER

void logUserId(String location, String? userId) { // DEBUG - A RETIRER
  if (DEBUG_TRACE_USER_ID) {
    print('// DEBUG - A RETIRER: [$location] userId=$userId');
  }
}

// Usage
logUserId('before_api_call', userId);
logUserId('after_api_call', response.userId);
```

---

## Cleanup Checklist

Apres debugging, utiliser cette commande pour trouver tous les logs:

```bash
# Find all debug markers
grep -rn "DEBUG - A RETIRER" lib/ test/

# Count occurrences
grep -c "DEBUG - A RETIRER" lib/**/*.dart test/**/*.dart

# For TypeScript
grep -rn "DEBUG - A RETIRER" src/ --include="*.ts" --include="*.tsx"
```

**RAPPEL: Zero marqueur doit rester apres le fix!**
