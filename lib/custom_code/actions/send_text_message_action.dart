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

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
Future<bool> sendTextMessageAction(String roomId, String text) async {
  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;

    final content = text.trim();
    if (content.isEmpty) return false;

    // Supabase v2: l'appel lève une exception en cas d'erreur.
    // On n'inspecte plus response.error (qui n'existe plus).
    await client.from('chat_messages').insert({
      'room_id': roomId,
      'profile_id': userId,
      'message_type': 'text',
      'content': content,
    });

    return true;
  } catch (e) {
    // Si une erreur survient, elle sera catch ici.
    print('sendTextMessageAction exception: $e');
    return false;
  }
}
