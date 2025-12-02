// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future<bool> blockUserAction(String targetProfileId) async {
  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null || userId == targetProfileId) return false;

    // ON CONFLICT DO NOTHING rend l'action idempotente (sûre à appeler plusieurs fois)
    final response = await client.from('user_blocks').upsert({
      'blocker_profile_id': userId,
      'blocked_profile_id': targetProfileId,
    });

    if (response.error != null) {
      debugPrint('blockUserAction error: ${response.error!.message}');
      return false;
    }
    return true;
  } catch (e) {
    debugPrint('blockUserAction exception: $e');
    return false;
  }
}
