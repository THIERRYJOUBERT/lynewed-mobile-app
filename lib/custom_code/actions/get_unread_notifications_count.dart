// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future<int> getUnreadNotificationsCount() async {
  try {
    final response =
        await SupaFlow.client.rpc('get_unread_notifications_count');
    // La réponse de la RPC sera directement l'entier.
    return response as int? ?? 0;
  } catch (e) {
    return 0;
  }
}
