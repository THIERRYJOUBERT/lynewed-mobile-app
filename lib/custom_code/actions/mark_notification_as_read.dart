// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
import '/utils/secure_logger.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
Future<void> markNotificationAsRead(String notificationId) async {
  try {
    await SupaFlow.client.rpc(
      'mark_notification_as_read',
      params: {'p_notification_id': notificationId},
    );
  } catch (e) {
    SecureLogger.error('Failed to mark notification as read', error: e);
  }
}
