// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future<bool> markRoomReadAction(String roomId) async {
  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;

    final nowIso = DateTime.now().toUtc().toIso8601String();

    // Utilisation de .rpc pour éviter des problèmes de RLS complexes sur UPDATE
    await client.rpc('mark_room_as_read', params: {
      'p_room_id': roomId,
      'p_profile_id': userId,
      'p_read_at': nowIso
    });

    return true;
  } catch (e) {
    debugPrint('markRoomReadAction exception: $e');
    return false;
  }
}
