# Story S38: Custom Code - Profile Actions Migration

## Description

En tant que developpeur, je veux migrer les actions profile de custom_code vers les modules correspondants afin d'eliminer le code legacy.

## Criteres d'Acceptance (Gherkin)

- [ ] Given les actions profile dans custom_code When je les migre Then elles sont dans les modules Clean

- [ ] Given les imports des actions When je les supprime Then aucune erreur de compilation

- [ ] Given les fonctionnalites When je les teste Then tout fonctionne identiquement

## Fichiers Concernes

### Actions a Migrer
```
lib/custom_code/actions/
├── sign_up_bride.dart                      → Auth module
├── upload_avatar.dart                       → Auth module
├── save_profile_fields.dart                 → Auth module
├── check_tos_accepted.dart                  → Auth module
├── insert_legal_acceptance.dart             → Auth module
├── call_delete_account_edge_function.dart   → Auth module
├── save_user_preferences.dart               → Settings module
├── load_initial_session_data.dart           → Core/Session
├── get_user_market_region.dart              → Core/Locale
├── get_device_locale.dart                   → Core/Locale
├── get_favorited_professionals_action.dart  → Feed/Wishlist
├── toggle_wishlist_action.dart              → Feed/Wishlist
├── get_pro_item_details_action.dart         → Profile module
```

### Destinations
- Auth actions -> `lib/features/auth/data/`
- Settings actions -> `lib/features/settings/data/`
- Wishlist actions -> `lib/features/feed/data/`
- Session actions -> `lib/core/services/`

## Notes Techniques

### Auth Actions
```dart
// Dans AuthRemoteDatasource

@override
Future<AuthUserModel> signUpBride({
  required String email,
  required String password,
  String? displayName,
}) async {
  final response = await _supabase.auth.signUp(
    email: email,
    password: password,
    data: {'display_name': displayName, 'role': 'bride'},
  );

  if (response.user == null) throw AuthException('Sign up failed');
  return AuthUserModel.fromSupabaseUser(response.user!);
}

@override
Future<String> uploadAvatar(Uint8List bytes, String fileName) async {
  final userId = _supabase.auth.currentUser?.id;
  if (userId == null) throw NotAuthenticatedException();

  final path = 'avatars/$userId/$fileName';
  await _supabase.storage.from('avatars').uploadBinary(path, bytes);
  return _supabase.storage.from('avatars').getPublicUrl(path);
}

@override
Future<bool> hasAcceptedTerms(String userId) async {
  final response = await _supabase
      .from('user_legal_acceptances')
      .select()
      .eq('user_id', userId)
      .eq('document_type', 'tos')
      .maybeSingle();

  return response != null;
}

@override
Future<void> acceptTerms(String userId) async {
  await _supabase.from('user_legal_acceptances').insert({
    'user_id': userId,
    'document_type': 'tos',
    'version': '1.0',
    'accepted_at': DateTime.now().toIso8601String(),
  });
}

@override
Future<void> deleteAccount() async {
  await _supabase.functions.invoke('delete-account');
}
```

### Session Service
```dart
class SessionService {
  final SupabaseClient _supabase;

  SessionService(this._supabase);

  Future<SessionData> loadInitialData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw NotAuthenticatedException();

    final results = await Future.wait([
      _loadUserPreferences(userId),
      _loadNotificationSettings(userId),
      _getUnreadCounts(userId),
    ]);

    return SessionData(
      preferences: results[0] as UserPreferences,
      notificationSettings: results[1] as List<NotificationSetting>,
      unreadMessageCount: (results[2] as Map)['messages'] ?? 0,
      unreadNotificationCount: (results[2] as Map)['notifications'] ?? 0,
    );
  }

  Future<UserPreferences> _loadUserPreferences(String userId) async {
    final response = await _supabase
        .from('user_preferences')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    return response != null
        ? UserPreferences.fromJson(response)
        : const UserPreferences();
  }
}

class SessionData {
  final UserPreferences preferences;
  final List<NotificationSetting> notificationSettings;
  final int unreadMessageCount;
  final int unreadNotificationCount;

  const SessionData({
    required this.preferences,
    required this.notificationSettings,
    required this.unreadMessageCount,
    required this.unreadNotificationCount,
  });
}
```

### Migration Checklist
- [ ] `sign_up_bride` -> `AuthRemoteDatasource.signUpBride()`
- [ ] `upload_avatar` -> `AuthRemoteDatasource.uploadAvatar()`
- [ ] `save_profile_fields` -> `AuthRemoteDatasource.updateProfile()`
- [ ] `check_tos_accepted` -> `AuthRemoteDatasource.hasAcceptedTerms()`
- [ ] `insert_legal_acceptance` -> `AuthRemoteDatasource.acceptTerms()`
- [ ] `call_delete_account_edge_function` -> `AuthRemoteDatasource.deleteAccount()`
- [ ] `save_user_preferences` -> `SettingsRemoteDatasource.savePreferences()`
- [ ] `load_initial_session_data` -> `SessionService.loadInitialData()`
- [ ] `toggle_wishlist_action` -> `FeedRepository.toggleWishlist()`

## Definition of Done

- [ ] Toutes les actions profile migrees
- [ ] SessionService implemente
- [ ] Fichiers actions supprimes
- [ ] Tests passent
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen

## Dependances

- S11-S16 : Auth module
- S24 : Settings module

## Stories Dependantes

- S41 : FlutterFlow cleanup
