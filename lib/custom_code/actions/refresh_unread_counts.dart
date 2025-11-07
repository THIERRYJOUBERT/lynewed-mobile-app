// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'index.dart'; // Imports other custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/get_unread_notifications_count.dart';
import '/custom_code/actions/get_unread_messages_count_action.dart';

Future<void> refreshUnreadCounts() async {
  try {
    // Rafraîchir le compteur de notifications
    final notifCount = await getUnreadNotificationsCount();
    FFAppState().update(() {
      FFAppState().unreadNotificationsCount = notifCount ?? 0;
      FFAppState().hasUnreadNotifications = (notifCount ?? 0) > 0;
    });

    // Rafraîchir le compteur de messages
    final msgCount = await getUnreadMessagesCountAction();
    FFAppState().update(() {
      FFAppState().unreadMessagesCount = msgCount ?? 0;
    });
  } catch (e) {
    debugPrint('Error refreshing unread counts: $e');
  }
}
