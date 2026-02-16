// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future<ChatRoomHeaderStruct?> getAnyProfileAsRoomHeader(
    String profileId) async {
  if (profileId.isEmpty) {
    return null;
  }

  try {
    // --- SOLUTION FINALE ET ROBUSTE ---
    // On appelle notre nouvelle RPC sécurisée qui contourne la RLS.
    final profileData =
        await SupaFlow.client.rpc('get_public_profile_details', params: {
      'p_profile_id': profileId,
    });

    if (profileData == null || profileData is! Map<String, dynamic>) {
      // La RPC a retourné null, le profil n'existe pas.
      return null;
    }

    // Helper pour parser le rôle
    UserRole? userRoleFromString(String? s) {
      switch ((s ?? '').toLowerCase()) {
        case 'professional':
          return UserRole.professional;
        case 'bride':
          return UserRole.bride;
        default:
          return null;
      }
    }

    // On mappe la réponse de la RPC vers notre structure ChatRoomHeaderStruct
    return ChatRoomHeaderStruct(
      roomType: RoomType.private, // Contexte simulé de chat privé
      otherProfileId: profileData['id']?.toString(),
      otherFullName: profileData['full_name']?.toString(),
      otherAvatarUrl:
          stringToImagePath(profileData['avatar_url']?.toString() ?? ''),
      otherRole: userRoleFromString(profileData['role']?.toString()),
    );
  } catch (e) {
    return null;
  }
}
