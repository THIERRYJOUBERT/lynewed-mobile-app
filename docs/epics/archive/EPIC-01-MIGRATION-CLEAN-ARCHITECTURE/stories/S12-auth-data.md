# Story S12: Auth - Data Layer

## Description

En tant que developpeur, je veux implementer la couche data du module Auth afin d'encapsuler toute la logique Supabase Auth dans une implementation propre.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `AuthRemoteDatasource` When je l'implemente Then toutes les operations Supabase Auth sont encapsulees

- [ ] Given `AuthRepositoryImpl` When je l'implemente Then il implemente entierement `AuthRepository`

- [ ] Given le code legacy `lib/auth/` When je l'encapsule Then il peut etre progressivement remplace

- [ ] Given les actions custom code auth When je les integre Then elles sont dans le datasource

- [ ] Given les tests When je les execute Then ils passent avec des mocks

## Fichiers Concernes

### Code Legacy a Encapsuler
- `lib/auth/supabase_auth/auth_util.dart`
- `lib/auth/supabase_auth/email_auth.dart`
- `lib/auth/supabase_auth/supabase_user_provider.dart`
- `lib/auth/auth_manager.dart`

### Actions Custom Code
```
lib/custom_code/actions/
├── sign_up_bride.dart              → AuthRepositoryImpl.signUpBride()
├── check_tos_accepted.dart         → AuthRepositoryImpl.hasAcceptedTerms()
├── insert_legal_acceptance.dart    → AuthRepositoryImpl.acceptTerms()
├── call_delete_account_edge_function.dart → AuthRepositoryImpl.deleteAccount()
├── upload_avatar.dart              → AuthRepositoryImpl.uploadAvatar()
├── save_profile_fields.dart        → AuthRepositoryImpl.updateProfile()
```

### A Creer
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/data/models/auth_user_model.dart`
- `lib/features/auth/data/models/user_profile_model.dart`

### Tests
- `test/features/auth/data/repositories/auth_repository_impl_test.dart`

## Notes Techniques

### Datasource Implementation
```dart
abstract class AuthRemoteDatasource {
  Future<AuthUserModel> signInWithEmail(String email, String password);
  Future<AuthUserModel> signUpWithEmail(String email, String password, {String? displayName});
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updatePassword(String newPassword);
  AuthUserModel? getCurrentUser();
  Stream<AuthUserModel?> watchAuthState();
  Future<UserProfileModel?> getProfile(String userId);
  Future<UserProfileModel> updateProfile(String userId, Map<String, dynamic> data);
  Future<String> uploadAvatar(String userId, Uint8List bytes, String fileName);
  Future<void> deleteAccount();
  Future<bool> hasAcceptedTerms(String userId);
  Future<void> acceptTerms(String userId);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final SupabaseClient _supabase;

  AuthRemoteDatasourceImpl(this._supabase);

  @override
  Future<AuthUserModel> signInWithEmail(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw AuthException('Sign in failed');
    }

    return AuthUserModel.fromSupabaseUser(response.user!);
  }

  @override
  Future<AuthUserModel> signUpWithEmail(String email, String password, {String? displayName}) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );

    if (response.user == null) {
      throw AuthException('Sign up failed');
    }

    return AuthUserModel.fromSupabaseUser(response.user!);
  }

  @override
  Stream<AuthUserModel?> watchAuthState() {
    return _supabase.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user != null ? AuthUserModel.fromSupabaseUser(user) : null;
    });
  }

  @override
  Future<UserProfileModel?> getProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('auth_user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfileModel.fromJson(response);
  }

  @override
  Future<void> deleteAccount() async {
    // Call edge function
    await _supabase.functions.invoke('delete-account');
  }

  // ... autres methodes
}
```

### Model Classes
```dart
class AuthUserModel {
  final String id;
  final String email;
  final String? phone;
  final bool emailConfirmed;
  final DateTime? lastSignInAt;
  final DateTime createdAt;
  final Map<String, dynamic>? userMetadata;

  AuthUserModel({...});

  factory AuthUserModel.fromSupabaseUser(User user) {
    return AuthUserModel(
      id: user.id,
      email: user.email ?? '',
      phone: user.phone,
      emailConfirmed: user.emailConfirmedAt != null,
      lastSignInAt: user.lastSignInAt,
      createdAt: DateTime.parse(user.createdAt),
      userMetadata: user.userMetadata,
    );
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      email: email,
      phone: phone,
      emailConfirmed: emailConfirmed,
      lastSignInAt: lastSignInAt,
      createdAt: createdAt,
      userMetadata: userMetadata,
    );
  }
}
```

### Repository Implementation
```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl(this._remoteDatasource);

  @override
  Future<Result<AuthUser>> signInWithEmail(String email, String password) async {
    try {
      final model = await _remoteDatasource.signInWithEmail(email, password);
      return Success(model.toEntity());
    } on AuthException catch (e) {
      return Failure(AuthFailure(e.message));
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  bool get isAuthenticated => _remoteDatasource.getCurrentUser() != null;

  // ... autres methodes
}
```

## Definition of Done

- [ ] Datasource implemente
- [ ] Repository implemente
- [ ] Models avec mapping
- [ ] Actions custom code integrees
- [ ] Tests avec mocks
- [ ] Compatibilite avec auth legacy
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (auth = critique)

## Dependances

- S01 : Setup infrastructure
- S11 : Auth - Domain

## Stories Dependantes

- S13-S16 : Auth Presentation stories
- S38 : Custom Code - Profile actions
