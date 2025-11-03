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
      print('blockUserAction error: ${response.error!.message}');
      return false;
    }
    return true;
  } catch (e) {
    print('blockUserAction exception: $e');
    return false;
  }
}
