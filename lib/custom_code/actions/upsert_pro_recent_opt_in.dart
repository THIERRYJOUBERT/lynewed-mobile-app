// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future<bool> upsertProRecentOptIn(bool isOptIn) async {
  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;
    await client.from('pro_recent_locations').upsert({
      'profile_id': userId,
      'is_opt_in': isOptIn,
      'last_seen_at': DateTime.now().toIso8601String(),
      // coords_approx est mis à jour séparément
    }, onConflict: 'profile_id');
    return true;
  } catch (e) {
    debugPrint('upsertProRecentOptIn error: $e');
    return false;
  }
}
