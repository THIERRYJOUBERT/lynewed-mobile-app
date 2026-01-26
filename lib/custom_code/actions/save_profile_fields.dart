// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Saves profile fields (name, avatar, country) for the current user.
///
/// @Deprecated: Use AuthRepository.updateProfile() from the Clean Architecture
/// auth module instead. This function is kept for legacy FlutterFlow pages
/// that expect the FlutterFlow [PublicProfileStruct] return type.
///
/// Note: The Clean Architecture version returns [UserProfile] entity instead
/// of FlutterFlow's [PublicProfileStruct].
///
/// Migration path:
/// ```dart
/// // Old (deprecated):
/// final profile = await saveProfileFields(fullName, avatarUrl, country: country);
///
/// // New (recommended):
/// final authRepository = sl<AuthRepository>();
/// final params = UpdateProfileParams(
///   displayName: fullName,
///   avatarUrl: avatarUrl,
/// );
/// final result = await authRepository.updateProfile(params);
/// final profile = result.getOrNull(); // Returns UserProfile entity
/// ```
@Deprecated('Use AuthRepository.updateProfile() instead. See auth module.')
Future<PublicProfileStruct?> saveProfileFields(
  String fullName,
  String? avatarUrl, {
  String? country,
}) async {
  UserRole roleFromString(String? s) {
    switch (s) {
      case 'professional':
        return UserRole.professional;
      case 'bride':
      default:
        return UserRole.bride;
    }
  }

  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('not-authenticated');
    }

    final Map<String, dynamic> updates = {'full_name': fullName};
    if (avatarUrl != null) {
      updates['avatar_url'] = avatarUrl;
    }
    if (country != null && country.isNotEmpty) {
      updates['country'] = country;
    }

    await client.from('profiles').update(updates).eq('id', userId);

    final refreshedProfile =
        await client.from('profiles').select().eq('id', userId).single();

    final String finalAvatarUrl =
        refreshedProfile['avatar_url'] ?? avatarUrl ?? '';

    return PublicProfileStruct(
      id: userId,
      role: roleFromString(refreshedProfile['role']?.toString()),
      fullName: refreshedProfile['full_name'] ?? fullName,
      avatarUrl: finalAvatarUrl,
    );
  } catch (e) {
    return null;
  }
}
