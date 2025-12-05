// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future<bool> deleteOwnMessageAction(int messageId) async {
  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;

    // La RLS garantit qu'on ne peut mettre à jour que ses propres messages
    final response = await client
        .from('chat_messages')
        .update({'is_deleted': true})
        .eq('id', messageId)
        .eq('profile_id', userId);

    if (response.error != null) {
      return false;
    }
    return true;
  } catch (e) {
    return false;
  }
}
