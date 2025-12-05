// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future<bool> insertLegalAcceptance() async {
  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      return false;
    }

    // Récupère les versions depuis les constantes de l'app
    const String tosVersion = FFAppConstants.tosVersion;
    const String privacyVersion = FFAppConstants.privacyVersion;

    await client.from('user_legal_acceptances').insert({
      'profile_id': userId,
      'tos_version': tosVersion,
      'privacy_version': privacyVersion,
      'accepted_at': DateTime.now().toIso8601String(),
    });

    return true;
  } catch (e) {
    return false;
  }
}
