// Automatic FlutterFlow imports
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
import '/utils/secure_logger.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// custom_code/actions/update_video_session_status_action.dart

Future<bool> updateVideoSessionStatusAction(
  String sessionId,
  VideoSessionStatus newStatus,
) async {
  SecureLogger.functionStart('updateVideoSessionStatusAction', params: {
    'sessionId': '***REDACTED***',
    'newStatus': newStatus.name
  });
  
  try {
    final client = SupaFlow.client;

    // --- CORRECTION: Utilisation de .select() pour confirmer la mise à jour ---
    final response = await client
        .from('video_sessions')
        .update({'status': newStatus.name})
        .eq('id', sessionId)
        .select('id') // On demande de retourner l'ID si la mise à jour a réussi
        .maybeSingle();

    // Si la réponse n'est pas nulle, cela signifie que la ligne a été trouvée et mise à jour.
    if (response != null) {
      SecureLogger.info('Video session status updated successfully');
      return true;
    } else {
      SecureLogger.warning('Video session status update failed: Session not found or RLS issue');
      return false;
    }
  } catch (e) {
    SecureLogger.error('Video session status update exception', error: e);
    return false;
  }
}
