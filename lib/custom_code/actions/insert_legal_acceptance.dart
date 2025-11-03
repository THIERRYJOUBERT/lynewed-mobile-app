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

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future<bool> insertLegalAcceptance() async {
  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      print('insertLegalAcceptance error: User is not authenticated.');
      return false;
    }

    // Récupère les versions depuis les constantes de l'app
    final String tosVersion = FFAppConstants.tosVersion;
    final String privacyVersion = FFAppConstants.privacyVersion;

    await client.from('user_legal_acceptances').insert({
      'profile_id': userId,
      'tos_version': tosVersion,
      'privacy_version': privacyVersion,
      'accepted_at': DateTime.now().toIso8601String(),
    });

    return true;
  } catch (e) {
    print('insertLegalAcceptance error: $e');
    return false;
  }
}
