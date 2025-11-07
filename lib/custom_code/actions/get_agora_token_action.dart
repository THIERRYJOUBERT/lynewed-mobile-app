// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
import '/utils/secure_logger.dart';
import '/flutter_flow/custom_functions.dart' as functions;
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
    SecureLogger.info('📡 Calling Edge Function agora_token_issue...');
    final client = SupaFlow.client;

    // Calculer l'UID côté Flutter (source de vérité unique)
    final agoraUid = functions.generateAgoraUid(userId);
    SecureLogger.info('🔢 Calculated Agora UID in Flutter: $agoraUid');
    
    SecureLogger.info('📤 Sending request body: {channelName: ***REDACTED***, agoraUid: $agoraUid}');
    
    final response = await client.functions.invoke(
      'agora_token_issue',
      body: {
        'channelName': channelName,
        'agoraUid': agoraUid, // Envoyer l'UID calculé par Flutter
      },
    );

    SecureLogger.info('📥 Edge Function response received');
    SecureLogger.info('   Status: ${response.status}');
    SecureLogger.info('   Data type: ${response.data.runtimeType}');
    // ⚠️ Ne jamais logger response.data directement (contient le token Agora)
    
    if (response.status == 200) {
      SecureLogger.info('✅ Status 200 - Checking for token...');
      
      if (response.data != null) {
        SecureLogger.info('   Data is not null');
        
        if (response.data is Map) {
          SecureLogger.info('   Data is a Map');
          final dataMap = response.data as Map;
          SecureLogger.info('   Map keys: ${dataMap.keys}');
          
          if (dataMap.containsKey('token')) {
            final token = dataMap['token'];
            SecureLogger.info('   Token found! Length: ${token?.toString().length ?? 0}');
            
            if (token != null && token.toString().isNotEmpty) {
              SecureLogger.info('✅ Agora token received successfully');
              return token as String;
            } else {
              SecureLogger.error('❌ Token is null or empty');
              return null;
            }
          } else {
            SecureLogger.error('❌ Token key not found in response. Keys: ${dataMap.keys}');
            return null;
          }
        } else {
          SecureLogger.error('❌ Data is not a Map: ${response.data.runtimeType}');
          return null;
        }
      } else {
        SecureLogger.error('❌ Response data is null');
        return null;
      }
    } else {
      SecureLogger.error('❌ Edge Function returned status ${response.status}');
      // ⚠️ Ne pas logger error data (peut contenir données sensibles)
      return null;
    }
  } catch (e) {
    SecureLogger.error('💥 EXCEPTION in getAgoraTokenAction');
    SecureLogger.error('   Exception type: ${e.runtimeType}');
    // ⚠️ Stack trace désactivé en production pour éviter fuite d'infos techniques
    return null;
  }
}
