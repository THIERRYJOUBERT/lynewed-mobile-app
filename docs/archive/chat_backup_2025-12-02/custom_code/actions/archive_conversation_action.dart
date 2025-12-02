// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future<bool> archiveConversationAction(String roomId) async {
  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;

    // La RLS garantit qu'on ne met à jour que sa propre participation
    final response = await client
        .from('chat_room_participants')
        .update({'conversation_status': 'archived'})
        .eq('room_id', roomId)
        .eq('profile_id', userId);

    if (response.error != null) {
      debugPrint('archiveConversationAction error: ${response.error!.message}');
      return false;
    }
    return true;
  } catch (e) {
    debugPrint('archiveConversationAction exception: $e');
    return false;
  }
}
