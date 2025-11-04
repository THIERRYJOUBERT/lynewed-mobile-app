// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
Future<bool> signUpBride(
  String email,
  String password,
) async {
  if (email.isEmpty || password.isEmpty) {
    return false;
  }

  try {
    final client = SupaFlow.client;

    // Inscription avec Supabase
    final res = await client.auth.signUp(
      email: email,
      password: password,
      data: {'role': 'bride'}, // Métadonnées pour le rôle
    );

    // Vérifier si l'utilisateur a été créé avec succès
    if (res.user != null) {
      // L'utilisateur est créé et la session est active
      final String userId = res.user!.id;
      const String tosVersion = FFAppConstants.tosVersion;
      const String privacyVersion = FFAppConstants.privacyVersion;

      // Insérer l'acceptation des conditions légales
      await client.from('user_legal_acceptances').insert({
        'profile_id': userId,
        'tos_version': tosVersion,
        'privacy_version': privacyVersion,
        'accepted_at': DateTime.now().toIso8601String(),
      });

      // Tout s'est bien passé
      return true;
    } else {
      // Si l'utilisateur est null, il y a eu un problème lors de l'inscription
      debugPrint('signUpBride error: User creation failed');
      return false;
    }
  } catch (e) {
    // Gérer les erreurs (AuthException ou autres exceptions)
    debugPrint('signUpBride exception: $e');
    return false;
  }
}
