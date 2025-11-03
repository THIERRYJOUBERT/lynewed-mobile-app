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

// custom_code/actions/get_agora_token_action.dart

Future<String?> getAgoraTokenAction(
  String channelName,
  String userId, // On garde le String pour la simplicité d'appel
) async {
  debugPrint(
      '[DEBUG] getAgoraTokenAction: Requesting token for channel "$channelName" with userId "$userId"');

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
      debugPrint('[DEBUG] getAgoraTokenAction: Token received successfully.');
      return response.data['token'] as String;
    } else {
      debugPrint('[DEBUG] getAgoraTokenAction ERROR: ${response.data}');
      return null;
    }
  } catch (e) {
    debugPrint('[DEBUG] getAgoraTokenAction EXCEPTION: $e');
    return null;
  }
}
