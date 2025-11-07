// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<void> refreshNotificationBadge() async {
  try {
    final resp = await SupaFlow.client.rpc('get_unread_notifications_count');
    final count = resp as int? ?? 0;
    FFAppState().update(() => FFAppState().hasUnreadNotifications = count > 0);
  } catch (e) {
    debugPrint('Error refreshing notification badge: $e');
  }
}
