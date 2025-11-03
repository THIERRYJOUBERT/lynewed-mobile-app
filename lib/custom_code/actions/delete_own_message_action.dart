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
      print('deleteOwnMessageAction error: ${response.error!.message}');
      return false;
    }
    return true;
  } catch (e) {
    print('deleteOwnMessageAction exception: $e');
    return false;
  }
}
