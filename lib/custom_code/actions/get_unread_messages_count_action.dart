// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<int?> getUnreadMessagesCountAction() async {
  try {
    final client = SupaFlow.client;
    final currentUserId = client.auth.currentUser?.id;
    if (currentUserId == null) return 0;

    // Count chat unread (private + wedding rooms) via RPC
    final res = await client.rpc('get_rooms_with_unread_counts');

    int totalUnread = 0;

    final list = (res is Map && res['items'] is List)
        ? (res['items'] as List)
        : const [];

    for (final row in list) {
      if (row is! Map) continue;

      final unreadCount = (row['unreadCount'] is num)
          ? (row['unreadCount'] as num).toInt()
          : 0;

      totalUnread += unreadCount;
    }

    // Count marketplace unread messages
    final marketplaceRes = await client
        .from('marketplace_messages')
        .select()
        .eq('receiver_id', currentUserId)
        .eq('is_read', false)
        .count(CountOption.exact);

    totalUnread += marketplaceRes.count;

    return totalUnread;
  } catch (e) {
    return 0;
  }
}
