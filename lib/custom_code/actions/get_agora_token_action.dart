// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
import '/utils/secure_logger.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// custom_code/actions/get_agora_token_action.dart

Future<String?> getAgoraTokenAction(
  String channelName,
  String userId, // On garde le String pour la simplicité d'appel
) async {
  SecureLogger.functionStart('getAgoraTokenAction', params: {
    'channelName': '***REDACTED***',
    'userId': '***REDACTED***'
  });

  try {
    final client = SupaFlow.client;

    // La conversion se fait ici, de manière centralisée
    final agoraUid = userId.hashCode & 0x7FFFFFFF;

    final response = await client.functions.invoke(
      'agora_token_issue',
      body: {
        'channelName': channelName,
        'agoraUid': agoraUid, // On envoie bien l'Integer à l'Edge Function
      },
    );

    if (response.data != null && response.data['token'] != null) {
      SecureLogger.info('Agora token received successfully');
      return response.data['token'] as String;
    } else {
      SecureLogger.error('Agora token request failed', error: response.data);
      return null;
    }
  } catch (e) {
    SecureLogger.error('Agora token request exception', error: e);
    return null;
  }
}
