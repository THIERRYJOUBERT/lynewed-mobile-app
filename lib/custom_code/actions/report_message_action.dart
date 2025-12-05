// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
Future<bool> reportMessageAction(
  int messageId,
  String reason,
) async {
  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;

    // Le trigger "handle_message_report" s'occupera de masquer le message (is_deleted=true)
    final response = await client.from('reports').insert({
      'reporter_profile_id': userId,
      'reported_message_id': messageId,
      'reason': reason,
    });

    if (response.error != null) {
      return false;
    }
    return true;
  } catch (e) {
    return false;
  }
}
