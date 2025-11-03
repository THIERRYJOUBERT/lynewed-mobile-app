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
      print('archiveConversationAction error: ${response.error!.message}');
      return false;
    }
    return true;
  } catch (e) {
    print('archiveConversationAction exception: $e');
    return false;
  }
}
