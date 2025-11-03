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
    print('markRoomReadAction exception: $e');
    return false;
  }
}
