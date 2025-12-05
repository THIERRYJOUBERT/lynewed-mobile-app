// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!


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
  }
}
