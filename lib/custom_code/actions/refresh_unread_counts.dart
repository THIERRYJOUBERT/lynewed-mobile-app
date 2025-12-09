// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
// Imports custom functions
import '/core/services/app_badge_service.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!


Future<void> refreshUnreadCounts() async {
  try {
    // Rafraîchir le compteur de notifications
    final notifCount = await getUnreadNotificationsCount();
    FFAppState().unreadNotificationsCount = notifCount ?? 0;
    FFAppState().hasUnreadNotifications = (notifCount ?? 0) > 0;

    // Rafraîchir le compteur de messages
    final msgCount = await getUnreadMessagesCountAction();
    FFAppState().unreadMessagesCount = msgCount ?? 0;
    
    // Sync iOS app icon badge
    await AppBadgeService.instance.updateBadge();
  } catch (e) {
    // Silently fail
  }
}
