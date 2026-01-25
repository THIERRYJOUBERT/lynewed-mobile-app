# Story S11: Auth - Domain Layer

## Description

En tant que developpeur, je veux creer la couche domain pour le module Auth afin d'avoir une abstraction claire de l'authentification independante de Supabase.

## Criteres d'Acceptance (Gherkin)

- [x] Given le module Auth When je cree `lib/features/auth/domain/` Then la structure Clean Architecture est en place

- [x] Given l'entite `AuthUser` When je la cree Then elle contient toutes les informations utilisateur necessaires

- [x] Given l'entite `UserProfile` When je la cree Then elle contient les infos profil (bride/pro)

- [x] Given `AuthRepository` When je definis l'interface Then toutes les operations auth sont couvertes

- [x] Given les entites When j'ecris les tests Then 100% passent

## Fichiers Concernes

### Existants (a analyser)
- `lib/auth/supabase_auth/auth_util.dart`
- `lib/auth/supabase_auth/email_auth.dart`
- `lib/auth/supabase_auth/supabase_user_provider.dart`
- `lib/auth/auth_manager.dart`
- `lib/auth/base_auth_user_provider.dart`

### A Creer
- `lib/features/auth/auth.dart` - Barrel export
- `lib/features/auth/domain/entities/auth_user.dart`
- `lib/features/auth/domain/entities/user_profile.dart`
- `lib/features/auth/domain/entities/user_role.dart`
- `lib/features/auth/domain/entities/entities.dart` - Barrel
- `lib/features/auth/domain/repositories/auth_repository.dart`

### Tests
- `test/features/auth/domain/entities/auth_user_test.dart`
- `test/features/auth/domain/entities/user_profile_test.dart`

## Notes Techniques

### Entity AuthUser
```dart
/// Authenticated user from Supabase Auth
class AuthUser {
  final String id;
  final String email;
  final String? phone;
  final bool emailConfirmed;
  final DateTime? lastSignInAt;
  final DateTime createdAt;
  final Map<String, dynamic>? userMetadata;

  const AuthUser({
    required this.id,
    required this.email,
    this.phone,
    this.emailConfirmed = false,
    this.lastSignInAt,
    required this.createdAt,
    this.userMetadata,
  });

  AuthUser copyWith({...});
}
```

### Entity UserProfile
```dart
/// User profile from profiles table
class UserProfile {
  final String id;
  final String authUserId;
  final String? displayName;
  final String? avatarUrl;
  final UserRole role;
  final String? profession; // For professionals
  final String? companyName; // For professionals
  final String? bio;
  final bool isOnboardingComplete;
  final int? onboardingStep;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.authUserId,
    this.displayName,
    this.avatarUrl,
    required this.role,
    this.profession,
    this.companyName,
    this.bio,
    this.isOnboardingComplete = false,
    this.onboardingStep,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isBride => role == UserRole.bride;
  bool get isProfessional => role == UserRole.professional;

  UserProfile copyWith({...});
}
```

### Enum UserRole
```dart
enum UserRole {
  bride,
  professional,
  admin,
}

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.bride:
        return 'bride';
      case UserRole.professional:
        return 'professional';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'bride':
        return UserRole.bride;
      case 'professional':
        return UserRole.professional;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.bride;
    }
  }
}
```

### Repository Interface
```dart
abstract class AuthRepository {
  // Authentication
  Future<Result<AuthUser>> signInWithEmail(String email, String password);
  Future<Result<AuthUser>> signUpBride({
    required String email,
    required String password,
    String? displayName,
  });
  Future<Result<void>> signOut();
  Future<Result<void>> sendPasswordResetEmail(String email);
  Future<Result<void>> updatePassword(String newPassword);

  // Session
  Future<Result<AuthUser?>> getCurrentUser();
  Stream<AuthUser?> watchAuthState();
  bool get isAuthenticated;

  // Profile
  Future<Result<UserProfile?>> getCurrentProfile();
  Future<Result<UserProfile>> updateProfile(UpdateProfileParams params);
  Future<Result<String>> uploadAvatar(Uint8List imageBytes, String fileName);
  Future<Result<void>> deleteAccount();

  // Terms & Legal
  Future<Result<bool>> hasAcceptedTerms();
  Future<Result<void>> acceptTerms();
}
```

### Params Classes
```dart
class UpdateProfileParams {
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? phone;
  // ... autres champs

  const UpdateProfileParams({...});
}
```

## Definition of Done

- [x] Structure `lib/features/auth/domain/` creee
- [x] Entites AuthUser, UserProfile, UserRole
- [x] AuthRepository interface complete
- [x] Tests unitaires (37 tests)
- [x] Documentation barrel export
- [x] `flutter analyze --fatal-infos` passe (0 warnings)

## Implementation (2025-01-25)

### Fichiers Crees

| Fichier | Description |
|---------|-------------|
| `lib/features/auth/auth.dart` | Barrel export du module |
| `lib/features/auth/domain/entities/auth_user.dart` | Entite utilisateur authentifie |
| `lib/features/auth/domain/entities/user_profile.dart` | Entite profil utilisateur |
| `lib/features/auth/domain/entities/user_role.dart` | Enum des roles |
| `lib/features/auth/domain/entities/entities.dart` | Barrel entities |
| `lib/features/auth/domain/repositories/auth_repository.dart` | Interface repository + UpdateProfileParams |

### Tests Crees

| Fichier | Tests |
|---------|-------|
| `test/features/auth/domain/entities/auth_user_test.dart` | 11 tests |
| `test/features/auth/domain/entities/user_role_test.dart` | 12 tests |
| `test/features/auth/domain/entities/user_profile_test.dart` | 14 tests |

### Validation

- **flutter test**: 1721 tests passent (dont 37 nouveaux)
- **flutter analyze --fatal-infos**: 0 warnings

### Self-Critique

3 problemes mineurs documentes (tous acceptables):
1. userMetadata Map mutable (copie defensive dans data layer)
2. copyWith ne peut pas setter null explicitement (pattern standard)
3. UpdateProfileParams sans equals/hashCode (params object)

## Estimation

**Points** : 3
**Complexite** : Faible
**Risque** : Faible

## Dependances

- S01 : Setup infrastructure

## Stories Dependantes

- S12 : Auth - Data layer
- S13 : Auth - Presentation
