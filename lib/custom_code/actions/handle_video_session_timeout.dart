// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
import '/utils/secure_logger.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// custom_code/actions/handle_video_session_timeout.dart

Future<void> handleVideoSessionTimeout(String sessionId) async {
  SecureLogger.functionStart('handleVideoSessionTimeout', params: {
    'sessionId': '***REDACTED***'
  });

  try {
    final client = SupaFlow.client;

    // Vérifier le statut actuel de la session
    final response = await client
        .from('video_sessions')
        .select('status')
        .eq('id', sessionId)
        .maybeSingle();

    if (response == null) {
      SecureLogger.debug('Video session not found (may have been deleted)');
      return;
    }

    final currentStatus = response['status'] as String?;

    // Si la session est toujours en pending après 30 secondes, la marquer comme missed
    if (currentStatus == 'pending') {
      SecureLogger.debug('Video session still pending, marking as missed');

      await client
          .from('video_sessions')
          .update({'status': 'missed'})
          .eq('id', sessionId)
          .select('id')
          .maybeSingle();

      SecureLogger.info('Video session marked as missed');
    } else {
      SecureLogger.debug('Video session status is $currentStatus, no action needed');
    }
  } catch (e) {
    SecureLogger.error('Video session timeout handler failed', error: e);
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
