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

Future<bool> deleteUserPoi(String poiId) async {
  try {
    final client = SupaFlow.client;
    final res =
        await client.rpc('delete_user_poi', params: {'p_poi_id': poiId});

    // La RPC retourne `true` si une ligne a été supprimée, sinon `false`.
    if (res is bool) {
      return res;
    }

    return false;
  } catch (e) {
    print('deleteUserPoi error: $e');
    return false;
  }
}
