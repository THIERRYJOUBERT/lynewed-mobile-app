// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Toggles the wishlist status for a professional.
///
/// Returns true if now favorited, false if unfavorited, null on error.
///
/// Note: Feed module has FeedRepository.toggleFavorite() but it's not fully
/// connected to Supabase yet. This action is kept for legacy FlutterFlow pages.
///
/// See also: lib/features/feed/data/repositories/feed_repository_impl.dart
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
