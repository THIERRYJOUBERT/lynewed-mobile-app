// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
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
    print('upsertNotificationSettingsBatch error: $e');
    return false;
  }
}
