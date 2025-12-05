// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<int?> getUnreadMessagesCountAction() async {
  try {
    final client = SupaFlow.client;
    
    // Appeler le RPC qui retourne les rooms avec unread counts
    final res = await client.rpc('get_rooms_with_unread_counts');
    
    // Calculer le total des messages non lus
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
    
    return totalUnread;
  } catch (e) {
    return 0;
  }
}
