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
      final String tosVersion = FFAppConstants.tosVersion;
      final String privacyVersion = FFAppConstants.privacyVersion;

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
      print('signUpBride error: User creation failed');
      return false;
    }
  } catch (e) {
    // Gérer les erreurs (AuthException ou autres exceptions)
    print('signUpBride exception: $e');
    return false;
  }
}
