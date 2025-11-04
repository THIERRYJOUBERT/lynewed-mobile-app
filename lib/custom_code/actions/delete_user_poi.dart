// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
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
    debugPrint('deleteUserPoi error: $e');
    return false;
  }
}
