// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Fetch replays filtered by user's market region (IN or GLOBAL)
/// Uses RPC to ensure market filtering is done server-side
Future<List<ReplayItemStruct>?> fetchReplaysBundle() async {
  try {
    final client = SupaFlow.client;

    // Use RPC to get replays filtered by market region
    final response = await client.rpc('get_replays_bundle');

    if (response == null) {
      return [];
    }

    final List<dynamic> data = response as List<dynamic>? ?? [];
    final List<ReplayItemStruct> replays = [];

    for (final replayData in data) {
      final List<ReplayGuestItemStruct> guests = [];
      final guestsData = replayData['guests'] as List<dynamic>? ?? [];

      for (final guestData in guestsData) {
        if (guestData != null) {
          guests.add(ReplayGuestItemStruct(
            guestId: guestData['guestId'],
            fullName: guestData['fullName'],
            profession: guestData['profession'],
            avatarUrl: guestData['avatarUrl'],
          ));
        }
      }

      final replayItem = ReplayItemStruct(
        replayId: replayData['id'],
        title: replayData['title'],
        description: replayData['description'],
        youtubeUrl: replayData['youtubeUrl'],
        thumbnailUrl: replayData['thumbnailUrl'],
        publishedAt: DateTime.tryParse(replayData['publishedAt'] ?? ''),
        isFeatured: replayData['isFeatured'] ?? false,
        guests: guests,
      );

      replays.add(replayItem);
    }

    return replays;
  } catch (e) {
    return null;
  }
}
