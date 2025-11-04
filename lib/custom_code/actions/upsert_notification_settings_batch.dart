// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
Future<bool> upsertNotificationSettingsBatch(
  List<String> notificationTypes,
  bool inAppEnabled,
  bool pushEnabled,
) async {
  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;
    final rows = notificationTypes
        .map((t) => {
              'profile_id': userId,
              'notification_type': t,
              'in_app_enabled': inAppEnabled,
              'push_enabled': pushEnabled,
            })
        .toList();
    await client
        .from('notification_settings')
        .upsert(rows, onConflict: 'profile_id,notification_type');
    return true;
  } catch (e) {
    debugPrint('upsertNotificationSettingsBatch error: $e');
    return false;
  }
}
