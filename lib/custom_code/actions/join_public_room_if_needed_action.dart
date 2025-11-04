// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future<bool> joinPublicRoomIfNeededAction(String roomId) async {
  try {
    final client = SupaFlow.client;
    final res = await client.rpc('join_public_room_if_needed', params: {
      'p_room_id': roomId,
    });
    // La RPC retourne l'UUID de la room en cas de succès
    return res != null && res.toString().isNotEmpty;
  } catch (e) {
    debugPrint('joinPublicRoomIfNeededAction error: $e');
    return false;
  }
}
