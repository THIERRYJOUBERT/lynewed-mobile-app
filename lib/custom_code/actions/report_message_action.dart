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
Future<bool> reportMessageAction(
  int messageId,
  String reason,
) async {
  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;

    // Le trigger "handle_message_report" s'occupera de masquer le message (is_deleted=true)
    final response = await client.from('reports').insert({
      'reporter_profile_id': userId,
      'reported_message_id': messageId,
      'reason': reason,
    });

    if (response.error != null) {
      print('reportMessageAction error: ${response.error!.message}');
      return false;
    }
    return true;
  } catch (e) {
    print('reportMessageAction exception: $e');
    return false;
  }
}
