// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!

Future<bool> deleteWeddingPin(String pinId) async {
  try {
    final client = SupaFlow.client;
    final res =
        await client.rpc('delete_wedding_pin', params: {'p_pin_id': pinId});

    // La RPC retourne `true` si une ligne a été mise à jour.
    if (res is bool) {
      return res;
    }

    return false;
  } catch (e) {
    debugPrint('deleteWeddingPin error: $e');
    return false;
  }
}
