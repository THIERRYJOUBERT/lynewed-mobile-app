// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
Future<void> markAllNotificationsAsRead() async {
  try {
    await SupaFlow.client.rpc('mark_all_notifications_as_read');
    
    // Mettre à jour le counter immédiatement
    FFAppState().update(() {
      FFAppState().unreadNotificationsCount = 0;
      FFAppState().hasUnreadNotifications = false;
    });
  } catch (e) {
    debugPrint('Error marking all notifications as read: $e');
  }
}
