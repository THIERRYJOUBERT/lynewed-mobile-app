// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
Future<bool> upsertNotificationSetting(
  String notificationType,
  bool inAppEnabled,
  bool pushEnabled,
) async {
  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;
    await client.from('notification_settings').upsert({
      'profile_id': userId,
      'notification_type': notificationType,
      'in_app_enabled': inAppEnabled,
      'push_enabled': pushEnabled,
    }, onConflict: 'profile_id,notification_type');
    return true;
  } catch (e) {
    return false;
  }
}
