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
Future<bool> checkTosAccepted() async {
  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;

    // Récupère les versions depuis les constantes de l'app
    final String tosVersion = FFAppConstants.tosVersion;
    final String privacyVersion = FFAppConstants.privacyVersion;

    final rows = await client
        .from('user_legal_acceptances')
        .select('id')
        .eq('profile_id', userId)
        .eq('tos_version', tosVersion)
        .eq('privacy_version', privacyVersion)
        .limit(1);

    // Si on a trouvé au moins une ligne, c'est que l'utilisateur a accepté
    return (rows is List && rows.isNotEmpty);
  } catch (e) {
    print('checkTosAccepted error: $e');
    return false; // En cas d'erreur, on considère que ce n'est pas accepté
  }
}
