// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future<bool?> toggleWishlistAction(String proProfileId) async {
  if (proProfileId.isEmpty) {
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
    return null;
  }
}
