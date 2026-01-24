# Story STORY-05: Tests Auth Module

## Description

En tant que developpeur, je veux avoir des tests unitaires pour le module Auth afin de garantir la fiabilite des flows d'authentification (email, Apple, Google).

## Points : 3

## Priorite : Moyenne

## Fichiers source a tester

### Auth Layer

| Fichier | Composant | Responsabilite |
|---------|-----------|----------------|
| `lib/auth/auth_manager.dart` | AuthManager, mixins | Interface d'authentification |
| `lib/auth/base_auth_user_provider.dart` | BaseAuthUser | User model abstrait |
| `lib/auth/supabase_auth/auth_util.dart` | Auth utilities | Helpers d'auth |
| `lib/auth/supabase_auth/email_auth.dart` | Email auth | Auth par email |
| `lib/auth/supabase_auth/supabase_auth_manager.dart` | SupabaseAuthManager | Implementation Supabase |
| `lib/auth/supabase_auth/supabase_user_provider.dart` | SupabaseUser | User Supabase |

## Criteres d'Acceptance

### AC1: Tests AuthManager Interface
- [ ] Test que AuthManager definit les methodes requises
- [ ] Test que les mixins (EmailSignInManager, AppleSignInManager, etc.) sont bien definis
- [ ] Test des signatures de methodes

### AC2: Tests BaseAuthUser
- [ ] Test creation user avec donnees minimales
- [ ] Test getters (uid, email, emailVerified, displayName)
- [ ] Test loggedIn vs not loggedIn states
- [ ] Test serialization si applicable

### AC3: Tests Auth Utilities
- [ ] Test currentUser getter
- [ ] Test loggedIn boolean
- [ ] Test helpers de validation email

### AC4: Tests SupabaseAuthManager (mocked)
- [ ] Test signOut() appelle la bonne methode Supabase
- [ ] Test deleteUser() flow
- [ ] Test updateEmail() flow
- [ ] Test resetPassword() flow

### AC5: Tests SupabaseUser
- [ ] Test creation depuis Supabase User
- [ ] Test getters derives (uid, email, displayName)
- [ ] Test currentUser static

### AC6: Qualite des tests
- [ ] Coverage > 50% sur auth/
- [ ] Tous les tests passent
- [ ] Temps d'execution < 5s

## Fichiers de Test a Creer

```
test/auth/
├── auth_manager_test.dart
├── base_auth_user_test.dart
└── supabase_auth/
    ├── supabase_auth_manager_test.dart
    └── supabase_user_provider_test.dart
```

## Notes Techniques

### Mocks necessaires

```dart
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
```

### Limitations

L'auth module depend fortement de Supabase et Flutter. Les tests doivent :
1. Mocker toutes les interactions Supabase
2. Ne pas tester l'UI (BuildContext)
3. Se concentrer sur la logique pure

### Pattern de test

```dart
void main() {
  group('AuthManager interface', () {
    test('should define signOut method', () {
      // Verify the interface contract
      // AuthManager is abstract, so we test implementations
    });
  });

  group('BaseAuthUser', () {
    test('should return null uid when not logged in', () {
      // Test the base class behavior
    });
  });

  group('SupabaseAuthManager', () {
    late MockSupabaseClient mockClient;
    late MockGoTrueClient mockAuth;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      when(() => mockClient.auth).thenReturn(mockAuth);
    });

    test('signOut should call supabase signOut', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      // Test implementation
    });
  });
}
```

### Fixtures de test

```dart
// test/auth/fixtures/auth_fixtures.dart

final testSupabaseUser = MockUser();

void setUpMockUser(MockUser mock) {
  when(() => mock.id).thenReturn('user-123');
  when(() => mock.email).thenReturn('test@example.com');
  when(() => mock.emailConfirmedAt).thenReturn(DateTime.now().toIso8601String());
  when(() => mock.userMetadata).thenReturn({
    'full_name': 'Test User',
    'avatar_url': 'https://example.com/avatar.jpg',
  });
}
```

## Contraintes

- **Pas de vrais appels Supabase** : Tout doit etre mocke
- **Pas de tests UI** : Les methodes avec BuildContext ne peuvent pas etre testees directement
- **Focus sur la logique** : Tester les transformations de donnees et les flows

## Definition of Done

- [ ] Fichiers de test crees
- [ ] Tests sur les parties testables (sans UI)
- [ ] Tous les tests passent (`flutter test test/auth/`)
- [ ] Aucun warning (`flutter analyze`)
- [ ] TRACKING.md mis a jour

## Estimation

- Interface tests : ~30min
- BaseAuthUser tests : ~30min
- SupabaseAuthManager tests : ~1h
- SupabaseUser tests : ~30min
- Review : ~30min

**Total** : ~3h
