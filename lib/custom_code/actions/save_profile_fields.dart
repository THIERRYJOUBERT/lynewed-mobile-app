// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
Future<PublicProfileStruct?> saveProfileFields(
  String fullName,
  String? avatarUrl,
) async {
  // CORRECTION : Le type de retour de la fonction est maintenant 'UserRole' (PascalCase).
  UserRole _roleFromString(String? s) {
    switch (s) {
      case 'professional':
        // CORRECTION : La valeur retournée utilise 'UserRole' (PascalCase) pour l'Enum.
        return UserRole.professional;
      case 'bride':
      default:
        // CORRECTION : La valeur retournée utilise 'UserRole' (PascalCase) pour l'Enum.
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

    await client.from('profiles').update(updates).eq('id', userId);

    // Relire le profil complet pour s'assurer que le rôle est inclus dans la réponse
    final refreshedProfile =
        await client.from('profiles').select().eq('id', userId).single();

    final String finalAvatarUrl =
        refreshedProfile['avatar_url'] ?? avatarUrl ?? '';

    return PublicProfileStruct(
      id: userId,
      role: _roleFromString(refreshedProfile['role']?.toString()),
      fullName: refreshedProfile['full_name'] ?? fullName,
      avatarUrl: finalAvatarUrl,
    );
  } catch (e) {
    print('saveProfileFields error: $e');
    return null;
  }
}
