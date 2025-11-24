// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<List<ReplayItemStruct>?> fetchReplaysBundle() async {
  try {
    final client = SupaFlow.client;

    // Fetch all replays and their guest assignments
    // Sorting logic:
    // 1. Featured replays (is_featured = true) ordered by created_at DESC
    // 2. Non-featured replays ordered by created_at DESC
    // Only fetch published replays (is_published = true)
    final response = await client.from('replays').select('''
      id,
      title,
      description,
      youtube_url,
      thumbnail_url,
      published_at,
      is_featured,
      is_published,
      created_at,
      replay_guest_assignments (
        replay_guests (
          id,
          full_name,
          profession,
          avatar_url
        )
      )
    ''').eq('is_published', true).order('is_featured', ascending: false).order('created_at', ascending: false);

    final List<dynamic> data = response as List<dynamic>? ?? [];
    final List<ReplayItemStruct> replays = [];

    for (final replayData in data) {
      final List<ReplayGuestItemStruct> guests = [];
      final assignments =
          replayData['replay_guest_assignments'] as List<dynamic>? ?? [];

      for (final assignment in assignments) {
        final guestData = assignment['replay_guests'];
        if (guestData != null) {
          guests.add(ReplayGuestItemStruct(
            guestId: guestData['id'],
            fullName: guestData['full_name'],
            profession: guestData['profession'],
            avatarUrl: guestData['avatar_url'],
          ));
        }
      }

      final replayItem = ReplayItemStruct(
        replayId: replayData['id'],
        title: replayData['title'],
        description: replayData['description'],
        youtubeUrl: replayData['youtube_url'],
        thumbnailUrl: replayData['thumbnail_url'],
        publishedAt: DateTime.tryParse(replayData['published_at'] ?? ''),
        isFeatured: replayData['is_featured'] ?? false,
        guests: guests,
      );

      replays.add(replayItem);
    }

    return replays;
  } catch (e) {
    debugPrint('fetchReplaysBundle exception: $e');
    return null;
  }
}
