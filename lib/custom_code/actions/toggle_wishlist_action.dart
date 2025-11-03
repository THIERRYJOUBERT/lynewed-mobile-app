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
Future<bool?> toggleWishlistAction(String proProfileId) async {
  if (proProfileId.isEmpty) {
    print('toggleWishlistAction error: proProfileId is empty.');
    return null;
  }

  try {
    final data = await SupaFlow.client.rpc('toggle_wishlist', params: {
      'p_pro_profile_id': proProfileId,
    });

    if (data is Map<String, dynamic> && data.containsKey('isFavorited')) {
      return data['isFavorited'] as bool?;
    }

    // Si la RPC ne retourne pas le format attendu, on retourne null pour indiquer un problème.
    return null;
  } catch (e) {
    print('toggleWishlistAction error: $e');
    return null;
  }
}
