// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
import '/flutter_flow/flutter_flow_util.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
Future<void> markNotificationAsRead(String notificationId) async {
  try {
    await SupaFlow.client.rpc('mark_notification_as_read', params: {
      'p_notification_id': notificationId,
    });
    
    // Rafraîchir le badge de notifications
    final count = await SupaFlow.client.rpc('get_unread_notifications_count');
    final notifCount = count as int? ?? 0;
    FFAppState().update(() {
      FFAppState().unreadNotificationsCount = notifCount;
      FFAppState().hasUnreadNotifications = notifCount > 0;
    });
  } catch (e) {
    debugPrint('[markNotificationAsRead] Error: $e');
  }
}
