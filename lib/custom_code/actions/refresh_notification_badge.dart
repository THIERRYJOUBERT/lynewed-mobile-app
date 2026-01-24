// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<void> refreshNotificationBadge() async {
  try {
    final resp = await SupaFlow.client.rpc('get_unread_notifications_count');
    final count = resp as int? ?? 0;
    FFAppState().update(() => FFAppState().hasUnreadNotifications = count > 0);
  } catch (e) {
    debugPrint('[refreshNotificationBadge] Error: $e');
  }
}
