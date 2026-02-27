// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future<bool> unblockUserAction(String targetProfileId) async {
  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await client
        .from('user_blocks')
        .delete()
        .eq('blocker_profile_id', userId)
        .eq('blocked_profile_id', targetProfileId);

    if (response.error != null) {
      return false;
    }
    return true;
  } catch (e) {
    return false;
  }
}
